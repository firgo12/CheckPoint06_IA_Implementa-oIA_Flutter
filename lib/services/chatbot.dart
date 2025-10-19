
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

import 'dart:convert' show utf8;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAIService {
  static GenerativeModel? _model;
  static dynamic _chat;

  // Ajuste o nome do modelo conforme seu provedor / quota
  static const _modelId = 'gemini-2.5-flash';

  static Future<void> initialize() async {
    // Cria a instância do modelo generativo
    _model = FirebaseAI.googleAI().generativeModel(model: _modelId);
  }

  static void startChatIfNeeded() {
    _chat ??= _model?.startChat();
  }

  // Envia mensagem de texto simples
  static Future<String> sendMessage(String text) async {
    if (_model == null) {
      throw Exception('FirebaseAIService not initialized. Call initialize() first.');
    }
    startChatIfNeeded();

    final prompt = Content.text(text);
    try {
      final response = await _chat!.sendMessage(prompt);
      return response.text ?? '';
    } catch (e, st) {
      debugPrint('FirebaseAIService sendMessage error: $e\n$st');
      rethrow;
    }
  }

  // Faz upload para Firebase Storage e cria uma chamada multimodal com referência gs://
  // Retorna o texto de resposta do modelo
  // Agora aceita bytes + filename para suportar web/mobile/desktop uniformemente
  static Future<String> analyzeImageAndChat(
    Uint8List fileBytes,
    String filename, {
    String promptText = 'Identify the movie in this poster and extract title, year and main info.',
    String? providedMime,
  }) async {
    if (_model == null) {
      throw Exception('FirebaseAIService not initialized. Call initialize() first.');
    }
    startChatIfNeeded();

    final mimeType = providedMime ?? lookupMimeType(filename) ?? 'image/jpeg';

    // Decide between enviar inline (sem bucket) ou fazer upload ao Storage
    const int kMaxInlineBytes = 20 * 1024 * 1024; // 20 MB
    final useInline = kIsWeb || fileBytes.lengthInBytes <= kMaxInlineBytes;

    try {
      if (useInline) {
        // Envia os dados inline diretamente ao modelo (sem Storage)
        final textPart = TextPart(promptText);
        final inlinePart = InlineDataPart(mimeType, fileBytes);

        final content = Content.multi([textPart, inlinePart]);
        final response = await _chat!.sendMessage(content);
        final respText = response.text ?? '';

        // Salvar no Firestore (registro que foi feito inline)
        try {
          // Firestore document max ~1MiB; avoid writing huge responseText
          final respBytes = utf8.encode(respText);
          String? responseStorageUrl;
          String storedResponseText = respText;
          const int maxFirestoreBytes = 900 * 1024; // 900 KB safety margin
          if (respBytes.length > maxFirestoreBytes) {
            // save full response as a .txt file in Storage and store link
            try {
              final textFileName = '${DateTime.now().millisecondsSinceEpoch}_response.txt';
              final textRef = FirebaseStorage.instance.ref().child('responses/$textFileName');
              final uploadTask = textRef.putData(Uint8List.fromList(respBytes), SettableMetadata(contentType: 'text/plain'));
              await uploadTask.whenComplete(() {});
              final bucket = textRef.bucket;
              final fullPath = textRef.fullPath;
              responseStorageUrl = 'gs://$bucket/$fullPath';
            } catch (e) {
              debugPrint('Falha ao salvar resposta grande no Storage: $e');
            }
            // store only truncated preview in Firestore
            storedResponseText = utf8.decode(respBytes.sublist(0, maxFirestoreBytes));
          }

          await FirebaseFirestore.instance.collection('image_analyses').add({
            'filename': filename,
            'mimeType': mimeType,
            'prompt': promptText,
            'responseText': storedResponseText,
            'responseStorageUrl': responseStorageUrl,
            'createdAt': FieldValue.serverTimestamp(),
            'storedVia': 'inline',
            'byteSize': fileBytes.lengthInBytes,
          });
        } catch (e) {
          debugPrint('Erro ao salvar análise no Firestore: $e');
        }

        return respText;
      } else {
        // Fallback: upload para Storage e enviar referência gs://
        // Sanitize filename: use timestamp + original extension to avoid special chars
        final ext = p.extension(filename);
        final safeExt = ext.replaceAll(RegExp(r'[^A-Za-z0-9\.-]'), '');
        final fileName = '${DateTime.now().millisecondsSinceEpoch}$safeExt';
        final storageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');

        final metadata = SettableMetadata(contentType: mimeType);
        final uploadTask = storageRef.putData(fileBytes, metadata);
        await uploadTask.whenComplete(() {});
        final meta = await storageRef.getMetadata();

        final bucket = storageRef.bucket;
        final fullPath = storageRef.fullPath;
        final storageUrl = 'gs://$bucket/$fullPath';

        final filePart = FileData(meta.contentType ?? mimeType, storageUrl);
        final textPart = TextPart(promptText);

        final content = Content.multi([textPart, filePart]);
        final response = await _chat!.sendMessage(content);
        final respText = response.text ?? '';

        // Salvar no Firestore
        try {
          await FirebaseFirestore.instance.collection('image_analyses').add({
            'storageUrl': storageUrl,
            'mimeType': meta.contentType ?? mimeType,
            'prompt': promptText,
            'responseText': respText,
            'createdAt': FieldValue.serverTimestamp(),
            'storedVia': 'storage',
          });
        } catch (e) {
          debugPrint('Erro ao salvar análise no Firestore: $e');
        }

        return respText;
      }
    } catch (e, st) {
      debugPrint('FirebaseAIService analyzeImageAndChat error: $e\n$st');
      rethrow;
    }
  }

  static void resetChat() {
    _chat = _model?.startChat();
  }
}
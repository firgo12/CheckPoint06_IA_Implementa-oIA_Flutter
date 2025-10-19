import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

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

  // Envia mensagem e retorna o texto de resposta (cadeia simples)
  static Future<String> sendMessage(String text) async {
    if (_model == null) {
      throw Exception('FirebaseAIService not initialized. Call initialize() first.');
    }
    startChatIfNeeded();

    // SDK desta versão espera um único Content (não uma List)
    final prompt = Content.text(text);
    try {
      final response = await _chat!.sendMessage(prompt);
      return response.text ?? '';
    } catch (e, st) {
      debugPrint('FirebaseAIService sendMessage error: $e\n$st');
      rethrow;
    }
  }

  // Opcional: reinicia o histórico da conversa
  static void resetChat() {
    _chat = _model?.startChat();
  }
}
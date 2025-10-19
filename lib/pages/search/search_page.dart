import 'dart:typed_data';
import 'dart:io' as io;
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movie_app/pages/chatbot/chatbot_page.dart';
import 'package:movie_app/pages/search/camera_capture_page.dart';
import 'package:movie_app/pages/search/web_camera_page.dart';
import 'package:movie_app/services/chatbot.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _isProcessing = false;

  Future<void> _pickAndAnalyzeImage() async {
    Uint8List? bytes;
    String? filename;
    // NOTE: Webcam/camera flows are commented out so the app doesn't ask for
    // camera permission. Instead the app will fetch an image from the
    // BACKEND_IMAGE_URL (if configured) or fall back to a local sample poster.
    //
    // Set BACKEND_IMAGE_URL to your server image path (e.g. a public URL or
    // Firebase Storage download URL). If left null, the local image in
    // images/ will be used.
    const String? BACKEND_IMAGE_URL = null; // <-- set your backend URL here

    Future<void> loadFromLocalSample() async {
      try {
        final samplePath = 'images/Demon-slayer-kimetsu-no-yaiba-infinity-cast_portuguese_pôster.jpg';
        final f = io.File(samplePath);
        if (await f.exists()) {
          bytes = await f.readAsBytes();
          filename = p.basename(samplePath);
        } else {
          debugPrint('Sample poster not found at $samplePath');
        }
      } catch (e) {
        debugPrint('Não foi possível ler imagem de exemplo: $e');
      }
    }

    // Try backend first (if configured), else use local sample.
    if (BACKEND_IMAGE_URL != null) {
      try {
        final resp = await http.get(Uri.parse(BACKEND_IMAGE_URL));
        if (resp.statusCode == 200) {
          bytes = resp.bodyBytes;
          filename = p.basename(Uri.parse(BACKEND_IMAGE_URL).path);
        } else {
          debugPrint('Backend image fetch failed: ${resp.statusCode}');
          await loadFromLocalSample();
        }
      } catch (e) {
        debugPrint('Erro ao buscar imagem no backend: $e');
        await loadFromLocalSample();
      }
    } else {
      await loadFromLocalSample();
    }

    // The old camera/webcam flows are intentionally commented out below.
    /*
    if (kIsWeb) {
      final result = await Navigator.push<List<dynamic>?>(
        context,
        MaterialPageRoute(builder: (_) => const WebCameraPage()),
      );
      if (result == null) return;
      bytes = result[0] as Uint8List;
      filename = result[1] as String;
    } else {
      final isDesktop = (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
      if (isDesktop) {
        final result = await Navigator.push<List<dynamic>?>(
          context,
          MaterialPageRoute(builder: (_) => const CameraCapturePage()),
        );
        if (result == null) return;
        bytes = result[0] as Uint8List;
        filename = result[1] as String;
      } else {
        // Mobile -> use image_picker
        try {
          final picker = ImagePicker();
          final XFile? picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
          if (picked == null) return;
          bytes = await picked.readAsBytes();
          filename = picked.name;
        } catch (e) {
          debugPrint('Erro ao acessar ImagePicker: $e');
          if (mounted) {
            await showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Câmera indisponível'),
                content: const Text('Não foi possível acessar a câmera neste ambiente.'),
                actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
              ),
            );
          }
          return;
        }
      }
    }
    */
    if (kIsWeb) {
      final result = await Navigator.push<List<dynamic>?>(
        context,
        MaterialPageRoute(builder: (_) => const WebCameraPage()),
      );
      if (result == null) return;
      bytes = result[0] as Uint8List;
      filename = result[1] as String;
    } else {
      final isDesktop = (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
      if (isDesktop) {
        // If we already loaded a sample bytes above, skip camera capture
        if (bytes != null && filename != null) {
          // proceed
        } else {
        final result = await Navigator.push<List<dynamic>?>(
          context,
          MaterialPageRoute(builder: (_) => const CameraCapturePage()),
        );
        if (result == null) return;
        bytes = result[0] as Uint8List;
        filename = result[1] as String;
        }
      } else {
      // Mobile / Web -> use image_picker
      try {
        final picker = ImagePicker();
        final XFile? picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
        if (picked == null) return;
        bytes = await picked.readAsBytes();
        filename = picked.name;
      } catch (e) {
        // Possível MissingPluginException em web ou plugin não registrado
        debugPrint('Erro ao acessar ImagePicker: $e');
        if (mounted) {
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Câmera indisponível'),
              content: const Text('Não foi possível acessar a câmera neste ambiente.\nTente executar o app no dispositivo (mobile) ou como app desktop (Windows) ou recarregue a aplicação.'),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
              ],
            ),
          );
        }
        return;
      }
    }}

    setState(() => _isProcessing = true);

    try {
      if (bytes == null || filename == null) {
        throw Exception('Nenhuma imagem encontrada para enviar ao backend.');
      }

      final resultText = await FirebaseAIService.analyzeImageAndChat(
        bytes!,
        filename!,
        promptText: 'Please identify this movie poster: extract title, year and main info. Also give a short sentiment summary from likely comments.',
      );

      FirebaseAIService.resetChat();
      await FirebaseAIService.sendMessage(resultText);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChatScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao analisar a imagem: $e')),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _isProcessing ? null : _pickAndAnalyzeImage,
            tooltip: 'Scan poster',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Imagem de fundo
          Positioned.fill(
            child: Image.asset(
              'images/movie_background3.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Opacidade sobre a imagem para melhorar a visibilidade do conteúdo
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.8),
            ),
          ),
          // Conteúdo da página
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: CupertinoSearchTextField(
                      padding: const EdgeInsets.all(10.0),
                      prefixIcon: const Icon(
                        CupertinoIcons.search,
                        color: Colors.grey,
                      ),
                      suffixIcon: const Icon(
                        Icons.cancel,
                        color: Colors.grey,
                      ),
                      style: const TextStyle(color: Colors.white),
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      onChanged: (value) {},
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Search',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          if (_isProcessing)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black26,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}


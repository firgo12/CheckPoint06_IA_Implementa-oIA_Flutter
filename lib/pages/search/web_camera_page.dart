// This page uses dart:html and must only be used on web (kIsWeb).
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:convert' show base64Decode, base64Encode, Utf8Encoder;
// Conditional import: web implementation registers the HtmlElementView factory,
// non-web stub is a no-op. This avoids referencing dart:ui.platformViewRegistry
// on non-web platforms where it's not available.
import 'web_register_view_stub.dart'
  if (dart.library.html) 'web_register_view.dart';

import 'package:flutter/material.dart';

class WebCameraPage extends StatefulWidget {
  const WebCameraPage({Key? key}) : super(key: key);

  @override
  State<WebCameraPage> createState() => _WebCameraPageState();
}

class _WebCameraPageState extends State<WebCameraPage> {
  html.VideoElement? _videoElement;
  html.MediaStream? _stream;
  bool _isReady = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {

      // Register a simple container factory first so HtmlElementView can be
      // constructed without race conditions. The factory returns a div with
      // an id that includes the viewId so we can reliably query it later.
      registerWebViewFactory('webcam', (int viewId) {
        final div = html.DivElement()..classes.add('webcam-container');
        div.id = 'webcam-$viewId';
        return div;
      });

      // Show the HtmlElementView (it will call the factory and insert the div)
      setState(() => _isReady = true);

      final Map<String, dynamic> constraints = {'video': true};
      _stream = await html.window.navigator.mediaDevices!.getUserMedia(constraints);
      _videoElement = html.VideoElement()
        ..autoplay = false
        ..muted = true
        ..setAttribute('playsinline', 'true')
        ..srcObject = _stream
        ..style.width = '100%'
        ..style.height = '100%';

      // The factory created a div with an id like 'webcam-<viewId>'. Wait for
      // it to exist in the DOM (race between Flutter building the HtmlElementView).
      html.Element? container;
      const int maxAttempts = 50; // up to ~5s
      int attempts = 0;
      while (container == null && attempts < maxAttempts) {
        // query by id prefix (matches 'webcam-<viewId>')
        container = html.document.querySelector('[id^="webcam-"]');
        if (container == null) {
          await Future.delayed(const Duration(milliseconds: 100));
          attempts++;
        }
      }

      if (container != null) {
        container.children.clear();
        container.append(_videoElement!);
        // Try to play the video; some browsers require a user gesture, but
        // calling play() after setting playsinline and muted usually works.
        try {
          await _videoElement!.play();
        } catch (playErr) {
          // If autoplay is blocked, leave the video element; user can still
          // press capture which will use the current frame when available.
          html.window.console.log('Video play() blocked or failed: $playErr');
        }
      } else {
        // Container never appeared; this indicates a problem with the
        // HtmlElementView registration or Flutter rendering. Throw to be
        // caught below and shown to the user.
        throw StateError('Webcam container element not found in DOM');
      }
    } catch (e) {
      debugPrint('Erro inicializando webcam web: $e');
      if (mounted) setState(() {
        _isReady = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _stream?.getTracks().forEach((t) => t.stop());
    super.dispose();
  }

  Future<void> _openPopupCameraAndReturn() async {
    // Open a popup that captures the webcam and posts the base64 image back
    final completer = Completer<Uint8List?>();

    void messageHandler(html.Event e) {
      try {
        final ev = e as html.MessageEvent;
        if (ev.data != null && ev.data is String && ev.data.startsWith('data:image')) {
          final dataUrl = ev.data as String;
          final base64Part = dataUrl.split(',')[1];
          final bytes = base64Decode(base64Part);
          if (!completer.isCompleted) completer.complete(Uint8List.fromList(bytes));
        }
      } catch (err) {
        if (!completer.isCompleted) completer.complete(null);
      }
    }

    html.window.addEventListener('message', messageHandler);

    final htmlContent = '''
    <!doctype html>
    <html>
    <body style="margin:0;display:flex;flex-direction:column;height:100vh;">
      <video id="v" autoplay playsinline muted style="flex:1;width:100%;height:100%;object-fit:cover;"></video>
      <div style="padding:8px;text-align:center;">
        <button id="c">Capturar</button>
        <button id="x">Cancelar</button>
      </div>
      <script>
        const video = document.getElementById('v');
        const btn = document.getElementById('c');
        const btnx = document.getElementById('x');
        navigator.mediaDevices.getUserMedia({video:true}).then(stream => { video.srcObject = stream; }).catch(e => { console.error(e); });
        btn.onclick = () => {
          const canvas = document.createElement('canvas');
          canvas.width = video.videoWidth; canvas.height = video.videoHeight;
          const ctx = canvas.getContext('2d');
          ctx.drawImage(video,0,0,canvas.width,canvas.height);
          const dataUrl = canvas.toDataURL('image/jpeg',0.92);
          if (window.opener) window.opener.postMessage(dataUrl, '*');
          window.close();
        };
        btnx.onclick = () => { window.close(); };
      </script>
    </body>
    </html>
    ''';

    final url = 'data:text/html;base64,${base64Encode(const Utf8Encoder().convert(htmlContent))}';
    final popup = html.window.open(url, 'webcam_capture', 'width=800,height=600');

    final result = await completer.future.timeout(const Duration(seconds: 30), onTimeout: () => null);
    html.window.removeEventListener('message', messageHandler);
    try {
      popup.close();
    } catch (_) {}
    if (result != null) {
      Navigator.of(context).pop(<dynamic>[result, 'web_capture.jpg']);
    }
  }

  Future<void> _capture() async {
    if (_videoElement == null) return;
    final canvas = html.CanvasElement(width: _videoElement!.videoWidth, height: _videoElement!.videoHeight);
    canvas.context2D.drawImageScaled(_videoElement!, 0, 0, canvas.width!, canvas.height!);
    final dataUrl = canvas.toDataUrl('image/jpeg', 0.92);
    // convert base64 -> bytes
    final base64 = dataUrl.split(',')[1];
    final bytes = base64Decode(base64);
    Navigator.of(context).pop(<dynamic>[Uint8List.fromList(bytes), 'web_capture.jpg']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Web Camera')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              child: _isReady && _videoElement != null
                  ? HtmlElementView(viewType: 'webcam')
                  : (_errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Erro: $_errorMessage'),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _errorMessage = null;
                                    _isReady = false;
                                  });
                                  _initCamera();
                                },
                                child: const Text('Tentar novamente'),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _openPopupCameraAndReturn,
                                child: const Text('Abrir em nova janela'),
                              ),
                            ],
                          ),
                        )
                      : const Center(child: Text('Inicializando câmera...'))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isReady ? _capture : null,
                  child: const Text('Capturar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

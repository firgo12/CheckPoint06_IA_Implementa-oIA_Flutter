import 'package:flutter/material.dart';

/// Stub implementation used on non-web platforms to avoid importing dart:html.
class WebCameraPage extends StatelessWidget {
  const WebCameraPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Web Camera (não suportado)')),
      body: const Center(child: Text('Web camera não suportada nesta plataforma.')), 
    );
  }
}

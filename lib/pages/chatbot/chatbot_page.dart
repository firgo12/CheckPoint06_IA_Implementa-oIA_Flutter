import 'package:flutter/material.dart';
import 'package:movie_app/services/chatbot.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final List<_Msg> _messages = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    FirebaseAIService.resetChat();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(text: text, fromUser: true));
      _isSending = true;
      _controller.clear();
    });

    try {
      final reply = await FirebaseAIService.sendMessage(text);
      setState(() {
        _messages.add(_Msg(text: reply, fromUser: false));
      });
    } catch (e) {
      setState(() {
        _messages.add(_Msg(text: 'Erro ao consultar a IA: $e', fromUser: false));
      });
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistente de Filmes (IA)'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                return Align(
                  alignment: m.fromUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: m.fromUser ? Colors.blueAccent : Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(m.text),
                  ),
                );
              },
            ),
          ),
          if (_isSending) const LinearProgressIndicator(minHeight: 2),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Pergunte sobre um filme, comentários, sentimento...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isSending ? null : _send,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool fromUser;
  _Msg({required this.text, required this.fromUser});
}
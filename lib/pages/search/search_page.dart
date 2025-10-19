import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagem de fundo
          Positioned.fill(
            child: Image.asset(
              'images/movie_background3.jpg', // Certifique-se de que a imagem está no diretório correto
              fit: BoxFit.cover,
            ),
          ),
          // Opacidade sobre a imagem para melhorar a visibilidade do conteúdo
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.8), // Ajuste a opacidade conforme necessário
            ),
          ),
          // Conteúdo da página
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
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
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Search',
                    style: TextStyle(color: Colors.white), // Cor do texto para contraste
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


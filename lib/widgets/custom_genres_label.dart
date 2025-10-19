import 'package:flutter/material.dart';

class GenresLabel extends StatelessWidget {
  final String genreName;
  const GenresLabel({super.key, required this.genreName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: SizedBox(
        width: 109.8,
        child: Chip(
          label: Center(
            child: Text(
              genreName,
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ),
      ),
    );
  }
}

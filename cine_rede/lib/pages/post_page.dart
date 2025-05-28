import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../db/database_helper.dart';
import '../models/post_model.dart';

class PostPage extends StatefulWidget {
  final String userId;

  const PostPage({super.key, required this.userId});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  File? _imagemSelecionada;
  final picker = ImagePicker();
  final descricaoController = TextEditingController();
  final notaController = TextEditingController();
  final tituloController = TextEditingController();
  List<String> generosSelecionados = [];

  final List<String> todosGeneros = [
    "Drama", "Comédia", "Terror", "Ação", "Suspense", "Romance",
    "Ficção Científica", "Fantasia", "Aventura", "Policial",
    "Musical", "Guerra", "Biográfico", "Infantil", "Super-herói", "Esportes"
  ];

  Future<void> _pegarImagem() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagemSelecionada = File(pickedFile.path);
      });
    }
  }

  Future<void> _enviarPostagem() async {
    if (_imagemSelecionada == null) return;
    if (tituloController.text.isEmpty) return;
    if (notaController.text.isEmpty) return;

    final post = PostModel(
      id: const Uuid().v4(),
      authorId: widget.userId,
      imageUrl: _imagemSelecionada!.path,
      description: descricaoController.text,
      movieNote: double.tryParse(notaController.text) ?? 0,
      movieTitle: tituloController.text,
      genres: generosSelecionados.join(', '),
      timestamp: DateTime.now().toIso8601String(),
    );

    final db = await DatabaseHelper.instance.database;
    await db.insert('posts', post.toMap());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Postagem')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _imagemSelecionada == null
                ? const Text('Nenhuma imagem selecionada')
                : Image.file(_imagemSelecionada!),
            ElevatedButton(
              onPressed: _pegarImagem,
              child: const Text('Selecionar Imagem'),
            ),
            TextField(
              controller: tituloController,
              decoration: const InputDecoration(labelText: 'Nome do Filme'),
            ),
            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            TextField(
              controller: notaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Nota (0 a 5)'),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: todosGeneros.map((genero) {
                final selecionado = generosSelecionados.contains(genero);
                return FilterChip(
                  label: Text(genero),
                  selected: selecionado,
                  onSelected: (value) {
                    setState(() {
                      if (value && generosSelecionados.length < 3) {
                        generosSelecionados.add(genero);
                      } else {
                        generosSelecionados.remove(genero);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _enviarPostagem,
              child: const Text('Publicar'),
            ),
          ],
        ),
      ),
    );
  }
}

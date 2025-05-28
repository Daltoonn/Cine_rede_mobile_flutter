import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cine_rede/models/post_model.dart';
import 'package:cine_rede/models/user_model.dart';
import 'package:cine_rede/db/database_helper.dart';

class FavoritosPage extends StatefulWidget {
  final UserModel user;

  const FavoritosPage({super.key, required this.user});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  List<PostModel> favoritos = [];

  @override
  void initState() {
    super.initState();
    carregarFavoritos();
  }

  Future<void> carregarFavoritos() async {
    final db = await DatabaseHelper.instance.database;

    // Pega os IDs dos posts favoritos do usuário
    final favoritosIds = await DatabaseHelper.instance.getPostsFavoritosDoUsuario(widget.user.id);

    // Busca todos os posts
    final maps = await db.query('posts');
    final todosPosts = maps.map((map) => PostModel.fromMap(map)).toList();

    // Filtra os posts que estão na lista de favoritos
    final postsFavoritos = todosPosts.where((post) => favoritosIds.contains(post.id)).toList();

    setState(() {
      favoritos = postsFavoritos;
    });
  }

  Future<void> _toggleFavorito(PostModel post) async {
    await DatabaseHelper.instance.toggleFavorito(widget.user.id, post.id);
    await carregarFavoritos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Favoritos'),
      ),
      body: favoritos.isEmpty
          ? const Center(child: Text('Você ainda não marcou nenhum favorito.'))
          : ListView.builder(
              itemCount: favoritos.length,
              itemBuilder: (context, index) {
                final post = favoritos[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.imageUrl.isNotEmpty && File(post.imageUrl).existsSync())
                        Image.file(File(post.imageUrl)),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '🎬 ${post.movieTitle}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Gêneros: ${post.genres}',
                          style: const TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                        child: Text(post.description),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('Nota: ${post.movieNote.toStringAsFixed(1)}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                        child: Text(
                          'Postado em: ${DateTime.parse(post.timestamp).toLocal().toString().split(".")[0]}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                      ButtonBar(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            tooltip: 'Remover dos favoritos',
                            onPressed: () => _toggleFavorito(post),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

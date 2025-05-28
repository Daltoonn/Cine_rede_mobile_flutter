import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cine_rede/models/user_model.dart';
import 'package:cine_rede/models/post_model.dart';
import 'package:cine_rede/pages/post_page.dart';
import 'package:cine_rede/pages/favoritos_page.dart';
import 'package:cine_rede/db/database_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cine_rede/pages/login_page.dart';

class HomePage extends StatefulWidget {
  final UserModel user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<PostModel> posts = [];
  List<PostModel> postsFiltrados = [];
  List<String> generosFiltroSelecionados = [];
  String textoFiltro = '';

  final List<String> todosGeneros = [
    "Drama", "Comédia", "Terror", "Ação", "Suspense", "Romance",
    "Ficção Científica", "Fantasia", "Aventura", "Policial",
    "Musical", "Guerra", "Biográfico", "Infantil", "Super-herói", "Esportes"
  ];

  List<String> favoritosIds = [];

  @override
  void initState() {
    super.initState();
    carregarPosts();
  }

  Future<void> carregarPosts() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('posts', orderBy: 'timestamp DESC');

    final listaPosts = maps.map((map) => PostModel.fromMap(map)).toList();

    // Buscar os IDs dos posts favoritos do usuário
    favoritosIds = await DatabaseHelper.instance.getPostsFavoritosDoUsuario(widget.user.id);

    setState(() {
      posts = listaPosts;
      aplicarFiltros();
    });
  }

  void aplicarFiltros() {
    List<PostModel> filtrados = posts;

    // Filtrar por texto do título (case insensitive)
    if (textoFiltro.isNotEmpty) {
      filtrados = filtrados.where((post) =>
          post.movieTitle.toLowerCase().contains(textoFiltro.toLowerCase())).toList();
    }

    // Filtrar por gêneros selecionados
    if (generosFiltroSelecionados.isNotEmpty) {
      filtrados = filtrados.where((post) {
        final generosPost = post.genres.split(',').map((g) => g.trim()).toList();
        return generosFiltroSelecionados.any((gf) => generosPost.contains(gf));
      }).toList();
    }

    setState(() {
      postsFiltrados = filtrados;
    });
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _confirmarExclusaoPost(String postId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir publicação'),
        content: const Text('Tem certeza que deseja excluir esta publicação? Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final db = await DatabaseHelper.instance.database;
      await db.delete('posts', where: 'id = ?', whereArgs: [postId]);
      await carregarPosts();
    }
  }

  void _editarPost(PostModel post) {
    final tituloController = TextEditingController(text: post.movieTitle);
    final descricaoController = TextEditingController(text: post.description);
    final notaController = TextEditingController(text: post.movieNote.toString());
    List<String> generosSelecionados = post.genres.split(',').map((e) => e.trim()).toList();
    File imagemSelecionada = File(post.imageUrl);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Editar Publicação'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  imagemSelecionada.existsSync()
                      ? Image.file(imagemSelecionada, height: 150)
                      : const Text('Nenhuma imagem'),
                  ElevatedButton(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        setState(() {
                          imagemSelecionada = File(picked.path);
                        });
                      }
                    },
                    child: const Text('Trocar imagem'),
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
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final db = await DatabaseHelper.instance.database;
                  await db.update(
                    'posts',
                    {
                      'movieTitle': tituloController.text.trim(),
                      'description': descricaoController.text.trim(),
                      'movieNote': double.tryParse(notaController.text.trim()) ?? post.movieNote,
                      'imageUrl': imagemSelecionada.path,
                      'genres': generosSelecionados.join(', ')
                    },
                    where: 'id = ?',
                    whereArgs: [post.id],
                  );
                  Navigator.pop(context);
                  await carregarPosts();
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _toggleFavorito(PostModel post) async {
    await DatabaseHelper.instance.toggleFavorito(widget.user.id, post.id);
    favoritosIds = await DatabaseHelper.instance.getPostsFavoritosDoUsuario(widget.user.id);
    setState(() {});
  }

  void _navegarParaFavoritos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FavoritosPage(user: widget.user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bem-vindo, ${widget.user.username.isNotEmpty ? widget.user.username : widget.user.email}!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Novo Post',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PostPage(userId: widget.user.id)),
              );
              await carregarPosts();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // Filtros de pesquisa
            TextField(
              decoration: const InputDecoration(
                labelText: 'Filtrar por nome do filme',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                textoFiltro = value;
                aplicarFiltros();
              },
            ),
            const SizedBox(height: 8),
            // Filtro por gêneros
            SizedBox(
              height: 45,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: todosGeneros.map((genero) {
                  final selecionado = generosFiltroSelecionados.contains(genero);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(genero),
                      selected: selecionado,
                      onSelected: (value) {
                        setState(() {
                          if (value) {
                            generosFiltroSelecionados.add(genero);
                          } else {
                            generosFiltroSelecionados.remove(genero);
                          }
                          aplicarFiltros();
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            // Botão para ir para favoritos
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.favorite),
                label: const Text('Ver Favoritos'),
                onPressed: _navegarParaFavoritos,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: postsFiltrados.isEmpty
                  ? const Center(child: Text('Nenhuma postagem encontrada.'))
                  : ListView.builder(
                      itemCount: postsFiltrados.length,
                      itemBuilder: (context, index) {
                        final post = postsFiltrados[index];
                        final ehAutor = post.authorId == widget.user.id;
                        final estaFavorito = favoritosIds.contains(post.id);

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
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
                                    icon: Icon(
                                      estaFavorito ? Icons.favorite : Icons.favorite_border,
                                      color: estaFavorito ? Colors.red : null,
                                    ),
                                    tooltip: estaFavorito ? 'Desfavoritar' : 'Favoritar',
                                    onPressed: () => _toggleFavorito(post),
                                  ),
                                  if (ehAutor) ...[
                                    TextButton(
                                      onPressed: () => _editarPost(post),
                                      child: const Text('Editar'),
                                    ),
                                    TextButton(
                                      onPressed: () => _confirmarExclusaoPost(post.id),
                                      child: const Text('Excluir'),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

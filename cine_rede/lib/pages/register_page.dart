import 'package:flutter/material.dart';
import 'package:cine_rede/db/database_helper.dart';
import 'package:cine_rede/models/user_model.dart';
import 'package:uuid/uuid.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  String? errorMessage;
  final uuid = const Uuid();

  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final username = usernameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Email e senha são obrigatórios.';
      });
      return;
    }

    var existingUser = await DatabaseHelper.instance.getUserByEmail(email);
    if (existingUser != null) {
      setState(() {
        errorMessage = 'Email já cadastrado.';
      });
      return;
    }

    final newUser = UserModel(
      id: uuid.v4(),
      email: email,
      password: password,
      username: username,
    );

    await DatabaseHelper.instance.insertUser(newUser);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuário criado com sucesso!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Nome de usuário (opcional)'),
            ),
            const SizedBox(height: 12),
            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: register,
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}

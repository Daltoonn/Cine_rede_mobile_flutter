import 'package:flutter/material.dart';
import 'package:cine_rede/pages/register_page.dart';
import 'package:cine_rede/db/database_helper.dart';
import 'package:cine_rede/models/user_model.dart';
import 'package:cine_rede/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? errorMessage;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Preencha todos os campos.';
      });
      return;
    }

    UserModel? user = await DatabaseHelper.instance.getUserByEmail(email);

    if (user == null) {
      setState(() {
        errorMessage = 'Usuário não encontrado.';
      });
    } else if (user.password != password) {
      setState(() {
        errorMessage = 'Senha incorreta.';
      });
    } else {
      setState(() {
        errorMessage = null;
      });

      // Redireciona para HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(user: user),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
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
            const SizedBox(height: 12),
            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: login,
              child: const Text('Entrar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              child: const Text('Criar uma nova conta'),
            )
          ],
        ),
      ),
    );
  }
}

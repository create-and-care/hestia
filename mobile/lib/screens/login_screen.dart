import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/api_client.dart';
import 'shopping_lists_screen.dart';

/// Écran de connexion : l'utilisateur colle l'URL de son instance Hestia et un
/// jeton API généré depuis le web (Tableau de bord → Jetons API, CDC §15).
/// Pas de flux e-mail/mot de passe ici — l'authentification par jeton API évite
/// de faire transiter le mot de passe du compte par le client mobile.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _serverController = TextEditingController(text: 'https://');
  final _tokenController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _loading = false;
  String? _error;

  Future<void> _connect() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final baseUrl = '${_serverController.text.trim()}/api/v1';
    final token = _tokenController.text.trim();
    final client = ApiClient(baseUrl: baseUrl, token: token);

    try {
      await client.get('/shopping_lists');
      await _storage.write(key: 'hestia_server_url', value: _serverController.text.trim());
      await _storage.write(key: 'hestia_api_token', value: token);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ShoppingListsScreen(client: client)),
      );
    } catch (error) {
      setState(() => _error = 'Connexion impossible : $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hestia')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _serverController,
              decoration: const InputDecoration(labelText: "URL de l'instance"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(labelText: 'Jeton API'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            FilledButton(
              onPressed: _loading ? null : _connect,
              child: _loading ? const CircularProgressIndicator() : const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}

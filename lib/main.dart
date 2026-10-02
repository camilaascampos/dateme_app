import 'package:flutter/material.dart';
import 'data/teste_criptografia.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Teste do banco')),
      body: FutureBuilder<String>(
        future: testarCriptografia(),
        builder: (context, snap) => Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Text(snap.data ?? 'Testando...'),
          ),
        ),
      ),
    ),
  ));
}
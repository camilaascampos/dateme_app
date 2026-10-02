import 'dart:io';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

/// Teste descartável: prova que o banco fica criptografado no aparelho.
Future<String> testarCriptografia() async {
  final log = StringBuffer();
  void ok(String m) => log.writeln('✅ $m');
  void falha(String m) => log.writeln('❌ $m');

  try {
    // 1. Configuração do SQLCipher no Android
  

    // 2. Chave aleatória guardada no armazenamento seguro do Android
    const storage = FlutterSecureStorage();
    var chave = await storage.read(key: 'chave_teste');
    if (chave == null) {
      final r = Random.secure();
      chave = List.generate(32, (_) => r.nextInt(256))
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();
      await storage.write(key: 'chave_teste', value: chave);
    }
    ok('Chave obtida do armazenamento seguro');

    // 3. Banco novo (apaga o de testes anteriores)
    final pasta = await getApplicationDocumentsDirectory();
    final caminho = p.join(pasta.path, 'teste_cripto.db');
    final arquivo = File(caminho);
    if (await arquivo.exists()) await arquivo.delete();

    Database abrir(String chaveHex) {
      final db = sqlite3.open(caminho);
      if (db.select('PRAGMA cipher_version;').isEmpty) {
        db.dispose();
        throw StateError('SQLCipher NÃO está disponível');
      }
      db.execute("PRAGMA key = \"x'$chaveHex'\";");
      return db;
    }

    // 4. Gravar e ler com a chave certa
    var db = abrir(chave);
    ok('SQLCipher disponível, versão ${db.select('PRAGMA cipher_version;').first.values.first}');
    db.execute('CREATE TABLE t (id INTEGER PRIMARY KEY, texto TEXT);');
    db.execute("INSERT INTO t (texto) VALUES ('segredo de teste');");
    final lido = db.select('SELECT texto FROM t;').first['texto'];
    ok('Gravou e leu: $lido');
    db.dispose();

    // 5. O arquivo em disco NÃO deve ser um SQLite legível
    final bytes = await arquivo.readAsBytes();
    final cabecalho = String.fromCharCodes(bytes.take(15));
    if (cabecalho == 'SQLite format 3') {
      falha('Arquivo SEM criptografia (cabeçalho legível)');
    } else {
      ok('Arquivo em disco está criptografado');
    }

    // 6. Chave errada deve falhar
    final errada = '0' * 64;
    try {
      final dbErrado = abrir(errada);
      dbErrado.select('SELECT * FROM t;');
      dbErrado.dispose();
      falha('Abriu com chave errada (não deveria)');
    } catch (_) {
      ok('Chave errada foi recusada');
    }

    // 7. Reabrir com a chave certa
    db = abrir(chave);
    final deNovo = db.select('SELECT texto FROM t;').first['texto'];
    ok('Reabriu com a chave certa: $deNovo');
    db.dispose();
  } catch (e) {
    falha('Erro: $e');
  }
  return log.toString();
}
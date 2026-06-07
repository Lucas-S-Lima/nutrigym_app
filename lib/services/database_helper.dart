import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Inicializa e gerencia o banco de dados SQLite do aplicativo,
/// funcionando em mobile, desktop e web.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _nomeBanco = 'nutrigym.db';
  static const _versao = 1;

  /// Permite que os testes injetem um banco em memória (ffi).
  static DatabaseFactory? factoryOverride;
  static String? pathOverride;

  Database? _db;

  Future<Database> get database async => _db ??= await _abrir();

  Future<Database> _abrir() async {
    final factory = factoryOverride ?? _factoryDaPlataforma();
    final caminho = pathOverride ??
        (kIsWeb
            ? _nomeBanco
            : p.join(await factory.getDatabasesPath(), _nomeBanco));

    return factory.openDatabase(
      caminho,
      options: OpenDatabaseOptions(
        version: _versao,
        onCreate: _criarTabelas,
      ),
    );
  }

  DatabaseFactory _factoryDaPlataforma() {
    if (kIsWeb) {
      return databaseFactoryFfiWeb;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        // O sqflite padrão já funciona nessas plataformas.
        return databaseFactory;
      default:
        // Linux, Windows e macOS usam a implementação FFI.
        sqfliteFfiInit();
        return databaseFactoryFfi;
    }
  }

  Future<void> _criarTabelas(Database db, int versao) async {
    await db.execute('''
      CREATE TABLE contas (
        email TEXT PRIMARY KEY,
        senha TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE usuarios (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        dataNascimento TEXT NOT NULL,
        genero TEXT NOT NULL,
        fotoPath TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE alimentos (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        categorias TEXT NOT NULL,
        tipo TEXT NOT NULL,
        fotoPath TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE cardapios (
        id TEXT PRIMARY KEY,
        usuarioId TEXT NOT NULL,
        cafeIds TEXT NOT NULL,
        almocoIds TEXT NOT NULL,
        jantaIds TEXT NOT NULL
      )
    ''');
  }
}

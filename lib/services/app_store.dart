import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/alimento.dart';
import '../models/cardapio.dart';
import '../models/usuario.dart';
import 'database_helper.dart';

/// Guarda todo o estado do aplicativo (login + dados cadastrados).
///
/// Os dados são persistidos em SQLite ([DatabaseHelper]); apenas a sessão
/// atual (quem está logado) fica em [SharedPreferences]. É um singleton
/// exposto via [AppStore.instance].
class AppStore extends ChangeNotifier {
  AppStore._();
  static final AppStore instance = AppStore._();

  static const _uuid = Uuid();

  // Chaves da sessão (SharedPreferences).
  static const _kLogado = 'logado';
  static const _kEmail = 'email_logado';

  late SharedPreferences _prefs;
  Database? _db;

  bool _logado = false;
  String? _emailLogado;

  /// Cache em memória dos dados, alimentado a partir do banco.
  final Map<String, String> _credenciais = {};
  final List<Usuario> _usuarios = [];
  final List<Alimento> _alimentos = [];
  final List<Cardapio> _cardapios = [];

  bool get logado => _logado;
  String? get emailLogado => _emailLogado;
  List<Usuario> get usuarios => List.unmodifiable(_usuarios);
  List<Alimento> get alimentos => List.unmodifiable(_alimentos);
  List<Cardapio> get cardapios => List.unmodifiable(_cardapios);

  /// Abre o banco, carrega os dados e a sessão. Chamar uma vez no início.
  Future<void> carregar() async {
    _prefs = await SharedPreferences.getInstance();
    _db = await DatabaseHelper.instance.database;

    _logado = _prefs.getBool(_kLogado) ?? false;
    _emailLogado = _prefs.getString(_kEmail);

    final contas = await _db!.query('contas');
    _credenciais
      ..clear()
      ..addEntries(contas
          .map((c) => MapEntry(c['email'] as String, c['senha'] as String)));

    _usuarios
      ..clear()
      ..addAll((await _db!.query('usuarios')).map(Usuario.fromMap));
    _alimentos
      ..clear()
      ..addAll((await _db!.query('alimentos')).map(Alimento.fromMap));
    _cardapios
      ..clear()
      ..addAll((await _db!.query('cardapios')).map(Cardapio.fromMap));

    notifyListeners();
  }

  // ----------------------- Autenticação -----------------------

  /// Cria uma nova conta de acesso e, automaticamente, o usuário
  /// correspondente. Retorna mensagem de erro ou null em sucesso.
  Future<String?> registrar({
    required String email,
    required String senha,
    required String nome,
    required DateTime dataNascimento,
    required Genero genero,
    String? fotoPath,
  }) async {
    final chave = email.trim().toLowerCase();
    if (_credenciais.containsKey(chave)) {
      return 'Já existe uma conta com este e-mail.';
    }
    await _db!.insert('contas', {'email': chave, 'senha': senha});
    _credenciais[chave] = senha;

    // Ao criar a conta, já cadastra o usuário — sem precisar criá-lo depois.
    await adicionarUsuario(
      nome: nome,
      dataNascimento: dataNascimento,
      genero: genero,
      fotoPath: fotoPath,
    );

    return entrar(email, senha);
  }

  /// Faz login. Retorna mensagem de erro ou null em sucesso.
  Future<String?> entrar(String email, String senha) async {
    final chave = email.trim().toLowerCase();
    if (!_credenciais.containsKey(chave)) {
      return 'Conta não encontrada. Crie um novo usuário.';
    }
    if (_credenciais[chave] != senha) {
      return 'Senha incorreta.';
    }
    _logado = true;
    _emailLogado = chave;
    await _prefs.setBool(_kLogado, true);
    await _prefs.setString(_kEmail, chave);
    notifyListeners();
    return null;
  }

  Future<void> sair() async {
    _logado = false;
    _emailLogado = null;
    await _prefs.setBool(_kLogado, false);
    await _prefs.remove(_kEmail);
    notifyListeners();
  }

  // ----------------------- Usuários -----------------------

  Future<void> adicionarUsuario({
    required String nome,
    required DateTime dataNascimento,
    required Genero genero,
    String? fotoPath,
  }) async {
    final usuario = Usuario(
      id: _uuid.v4(),
      nome: nome,
      dataNascimento: dataNascimento,
      genero: genero,
      fotoPath: fotoPath,
    );
    await _db!.insert('usuarios', usuario.toMap());
    _usuarios.add(usuario);
    notifyListeners();
  }

  List<Usuario> buscarUsuarios(String nome) {
    final termo = nome.trim().toLowerCase();
    if (termo.isEmpty) return usuarios;
    return _usuarios
        .where((u) => u.nome.toLowerCase().contains(termo))
        .toList();
  }

  Usuario? usuarioPorId(String id) => _usuarios
      .cast<Usuario?>()
      .firstWhere((u) => u?.id == id, orElse: () => null);

  // ----------------------- Alimentos -----------------------

  Future<void> adicionarAlimento({
    required String nome,
    required List<CategoriaAlimento> categorias,
    required TipoAlimento tipo,
    String? fotoPath,
  }) async {
    final alimento = Alimento(
      id: _uuid.v4(),
      nome: nome,
      categorias: categorias,
      tipo: tipo,
      fotoPath: fotoPath,
    );
    await _db!.insert('alimentos', alimento.toMap());
    _alimentos.add(alimento);
    notifyListeners();
  }

  List<Alimento> buscarAlimentos(String nome) {
    final termo = nome.trim().toLowerCase();
    if (termo.isEmpty) return alimentos;
    return _alimentos
        .where((a) => a.nome.toLowerCase().contains(termo))
        .toList();
  }

  Alimento? alimentoPorId(String id) => _alimentos
      .cast<Alimento?>()
      .firstWhere((a) => a?.id == id, orElse: () => null);

  /// Alimentos que pertencem a uma determinada categoria/refeição.
  List<Alimento> alimentosPorCategoria(CategoriaAlimento categoria) =>
      _alimentos.where((a) => a.categorias.contains(categoria)).toList();

  // ----------------------- Cardápios -----------------------

  Future<void> adicionarCardapio({
    required String usuarioId,
    required List<String> cafeIds,
    required List<String> almocoIds,
    required List<String> jantaIds,
  }) async {
    final cardapio = Cardapio(
      id: _uuid.v4(),
      usuarioId: usuarioId,
      cafeIds: cafeIds,
      almocoIds: almocoIds,
      jantaIds: jantaIds,
    );
    await _db!.insert('cardapios', cardapio.toMap());
    _cardapios.add(cardapio);
    notifyListeners();
  }

  /// Busca cardápios pelo nome do usuário associado.
  List<Cardapio> buscarCardapiosPorNomeUsuario(String nome) {
    final termo = nome.trim().toLowerCase();
    return _cardapios.where((c) {
      final u = usuarioPorId(c.usuarioId);
      if (u == null) return false;
      if (termo.isEmpty) return true;
      return u.nome.toLowerCase().contains(termo);
    }).toList();
  }
}

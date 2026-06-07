import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:meu_app/models/usuario.dart';
import 'package:meu_app/services/app_store.dart';
import 'package:meu_app/services/database_helper.dart';

void main() {
  setUpAll(() {
    // Usa um banco SQLite em memória para os testes.
    sqfliteFfiInit();
    DatabaseHelper.factoryOverride = databaseFactoryFfi;
    DatabaseHelper.pathOverride = inMemoryDatabasePath;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Criar conta persiste a conta e cria o usuário no banco', () async {
    final store = AppStore.instance;
    await store.carregar();

    final erro = await store.registrar(
      email: 'teste@nutrigym.com',
      senha: '1234',
      nome: 'Maria Teste',
      dataNascimento: DateTime(2000, 5, 20),
      genero: Genero.feminino,
    );

    expect(erro, isNull);
    expect(store.logado, isTrue);
    // Ao criar a conta, o usuário correspondente deve ter sido cadastrado.
    expect(store.usuarios.any((u) => u.nome == 'Maria Teste'), isTrue);

    // Os dados devem continuar disponíveis ao recarregar (lê do banco).
    await store.carregar();
    expect(store.usuarios.any((u) => u.nome == 'Maria Teste'), isTrue);
  });
}

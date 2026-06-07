import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:meu_app/models/alimento.dart';
import 'package:meu_app/models/usuario.dart';
import 'package:meu_app/services/app_store.dart';
import 'package:meu_app/services/database_helper.dart';
import 'package:meu_app/screens/login_screen.dart';
import 'package:meu_app/screens/home_screen.dart';
import 'package:meu_app/screens/creditos_screen.dart';
import 'package:meu_app/screens/compartilhamento_screen.dart';
import 'package:meu_app/screens/cadastro/cadastro_screen.dart';
import 'package:meu_app/screens/cadastro/cadastro_cardapio_screen.dart';
import 'package:meu_app/screens/consulta/consulta_screen.dart';
import 'package:meu_app/screens/consulta/consulta_usuario_screen.dart';

/// Tema idêntico ao do app (verde, Material 3, header verde).
final _tema = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
  useMaterial3: true,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
  ),
);

Future<void> _capturar(WidgetTester tester, Widget tela, String nome) async {
  await tester.pumpWidget(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: _tema,
    home: tela,
  ));
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('prints/$nome.png'),
  );
}

void main() {
  setUpAll(() async {
    await loadAppFonts(); // fontes reais => textos legíveis nos prints
    sqfliteFfiInit();
    DatabaseHelper.factoryOverride = databaseFactoryFfi;
    DatabaseHelper.pathOverride = inMemoryDatabasePath;
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Gera os prints das telas do NutriGym', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 900));

    final store = AppStore.instance;
    await store.carregar();

    // ---- Dados de exemplo para os prints ----
    await store.adicionarUsuario(
      nome: 'Ana Souza',
      dataNascimento: DateTime(1998, 3, 15),
      genero: Genero.feminino,
    );
    await store.adicionarAlimento(
      nome: 'Maçã',
      categorias: [CategoriaAlimento.cafe],
      tipo: TipoAlimento.fruta,
    );
    await store.adicionarAlimento(
      nome: 'Pão integral',
      categorias: [CategoriaAlimento.cafe],
      tipo: TipoAlimento.carboidrato,
    );
    await store.adicionarAlimento(
      nome: 'Frango grelhado',
      categorias: [CategoriaAlimento.almoco],
      tipo: TipoAlimento.proteina,
    );
    await store.adicionarAlimento(
      nome: 'Suco de laranja',
      categorias: [CategoriaAlimento.cafe],
      tipo: TipoAlimento.bebida,
    );

    String idDe(String nome) =>
        store.alimentos.firstWhere((a) => a.nome == nome).id;

    await store.adicionarCardapio(
      usuarioId: store.usuarios.first.id,
      cafeIds: [idDe('Maçã'), idDe('Pão integral')],
      almocoIds: [idDe('Frango grelhado')],
      jantaIds: [idDe('Frango grelhado')],
    );

    // ---- Captura das telas ----
    await _capturar(tester, const LoginScreen(), 'login');
    await _capturar(tester, const HomeScreen(), 'home');
    await _capturar(tester, const CadastroScreen(), 'cadastro');
    await _capturar(tester, const CadastroCardapioScreen(), 'cardapio');
    await _capturar(tester, const ConsultaScreen(), 'consulta');
    await _capturar(tester, const ConsultaUsuarioScreen(), 'consulta_usuario');
    await _capturar(tester, const CompartilhamentoScreen(), 'compartilhar');
    await _capturar(tester, const CreditosScreen(), 'creditos');

    // ---- Modal de compartilhamento ----
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _tema,
      home: const CompartilhamentoScreen(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.share).first);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('prints/compartilhar_modal.png'),
    );
  });
}

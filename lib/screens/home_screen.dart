import 'package:flutter/material.dart';

import '../services/app_store.dart';
import 'cadastro/cadastro_screen.dart';
import 'compartilhamento_screen.dart';
import 'consulta/consulta_screen.dart';
import 'creditos_screen.dart';
import 'login_screen.dart';

/// Tela Principal: apresentação do app e acesso aos módulos.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String nomeApp = 'NutriGym';

  Future<void> _sair(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair da aplicação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    await AppStore.instance.sair();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final opcoes = <_OpcaoMenu>[
      _OpcaoMenu(
        titulo: 'Cadastro de itens',
        descricao: 'Usuários, alimentos e cardápios',
        icone: Icons.add_circle_outline,
        destino: () => const CadastroScreen(),
      ),
      _OpcaoMenu(
        titulo: 'Consulta de itens',
        descricao: 'Pesquise usuários, alimentos e cardápios',
        icone: Icons.search,
        destino: () => const ConsultaScreen(),
      ),
      _OpcaoMenu(
        titulo: 'Compartilhamento',
        descricao: 'Compartilhe alimentos e cardápios',
        icone: Icons.share,
        destino: () => const CompartilhamentoScreen(),
      ),
      _OpcaoMenu(
        titulo: 'Créditos',
        descricao: 'Integrantes do grupo',
        icone: Icons.groups_outlined,
        destino: () => const CreditosScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(nomeApp),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () => _sair(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Apresentação do aplicativo.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 260,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Organize usuários, alimentos e monte cardápios '
                    'personalizados para café, almoço e janta.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'O que deseja fazer?',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...opcoes.map(
            (op) => Card(
              color: Colors.green,
              child: ListTile(
                leading: Icon(op.icone, color: Colors.white),
                title: Text(
                  op.titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  op.descricao,
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => op.destino()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpcaoMenu {
  _OpcaoMenu({
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.destino,
  });

  final String titulo;
  final String descricao;
  final IconData icone;
  final Widget Function() destino;
}

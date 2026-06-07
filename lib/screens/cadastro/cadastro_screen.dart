import 'package:flutter/material.dart';

import 'cadastro_alimento_screen.dart';
import 'cadastro_cardapio_screen.dart';
import 'cadastro_usuario_screen.dart';

/// Tela Cadastro: hub com as três opções de escrita de dados.
class CadastroScreen extends StatelessWidget {
  const CadastroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    final itens = <_ItemCadastro>[
      _ItemCadastro(
        titulo: 'Novo Usuário',
        descricao: 'Nome, foto e data de nascimento',
        icone: Icons.person_add_alt,
        destino: () => const CadastroUsuarioScreen(),
      ),
      _ItemCadastro(
        titulo: 'Novo Alimento',
        descricao: 'Nome, foto, categoria e tipo',
        icone: Icons.fastfood_outlined,
        destino: () => const CadastroAlimentoScreen(),
      ),
      _ItemCadastro(
        titulo: 'Novo Cardápio',
        descricao: 'Monte café, almoço e janta para um usuário',
        icone: Icons.menu_book_outlined,
        destino: () => const CadastroCardapioScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de itens')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: itens
            .map(
              (item) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cor.secondaryContainer,
                    child: Icon(item.icone, color: cor.onSecondaryContainer),
                  ),
                  title: Text(item.titulo),
                  subtitle: Text(item.descricao),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => item.destino()),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ItemCadastro {
  _ItemCadastro({
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

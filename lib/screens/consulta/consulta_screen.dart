import 'package:flutter/material.dart';

import 'consulta_alimento_screen.dart';
import 'consulta_cardapio_screen.dart';
import 'consulta_usuario_screen.dart';

/// Tela Consulta: hub com as três opções de leitura de dados.
class ConsultaScreen extends StatelessWidget {
  const ConsultaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    final itens = <_ItemConsulta>[
      _ItemConsulta(
        titulo: 'Buscar Usuário',
        descricao: 'Nome, foto e idade',
        icone: Icons.person_search_outlined,
        destino: () => const ConsultaUsuarioScreen(),
      ),
      _ItemConsulta(
        titulo: 'Buscar Alimento',
        descricao: 'Nome, foto, categoria e tipo',
        icone: Icons.search,
        destino: () => const ConsultaAlimentoScreen(),
      ),
      _ItemConsulta(
        titulo: 'Buscar Cardápio',
        descricao: 'Pelo nome do usuário',
        icone: Icons.menu_book_outlined,
        destino: () => const ConsultaCardapioScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Consulta de itens')),
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

class _ItemConsulta {
  _ItemConsulta({
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

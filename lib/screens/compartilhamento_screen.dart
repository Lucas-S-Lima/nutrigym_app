import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/alimento.dart';
import '../models/cardapio.dart';
import '../services/app_store.dart';
import '../widgets/foto_avatar.dart';

/// Tela de Compartilhamento: permite compartilhar alimentos e cardápios
/// através dos apps de compartilhamento do sistema.
class CompartilhamentoScreen extends StatelessWidget {
  const CompartilhamentoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Compartilhamento'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Alimento', icon: Icon(Icons.fastfood_outlined)),
              Tab(text: 'Cardápio', icon: Icon(Icons.menu_book_outlined)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ListaAlimentos(),
            _ListaCardapios(),
          ],
        ),
      ),
    );
  }
}

/// Exibe um modal com um link fictício de compartilhamento que pode ser
/// copiado para a área de transferência.
void _compartilhar(
  BuildContext context, {
  required String titulo,
  required String link,
}) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.share),
          const SizedBox(width: 8),
          Expanded(child: Text('Compartilhar $titulo')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Use o link abaixo para compartilhar:'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(ctx).dividerColor),
            ),
            child: SelectableText(
              link,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Fechar'),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.copy),
          label: const Text('Copiar link'),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: link));
            if (!ctx.mounted) return;
            Navigator.pop(ctx);
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Link copiado!')),
            );
          },
        ),
      ],
    ),
  );
}

/// Gera um link fictício para um item, a partir do seu tipo e id.
String _gerarLink(String tipo, String id) {
  final slug = id.replaceAll('-', '').substring(0, 8);
  return 'https://nutrigym.app/$tipo/$slug';
}

class _ListaAlimentos extends StatelessWidget {
  const _ListaAlimentos();

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final alimentos = store.alimentos;
        if (alimentos.isEmpty) {
          return const Center(child: Text('Nenhum alimento cadastrado.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: alimentos.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (context, i) {
            final Alimento a = alimentos[i];
            return ListTile(
              leading:
                  FotoAvatar(fotoPath: a.fotoPath, icone: Icons.fastfood),
              title: Text(a.nome),
              subtitle: Text('${a.categoriasTexto} • ${a.tipo.rotulo}'),
              trailing: IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'Compartilhar',
                onPressed: () => _compartilhar(
                  context,
                  titulo: a.nome,
                  link: _gerarLink('alimento', a.id),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ListaCardapios extends StatelessWidget {
  const _ListaCardapios();

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final cardapios = store.cardapios;
        if (cardapios.isEmpty) {
          return const Center(child: Text('Nenhum cardápio cadastrado.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: cardapios.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (context, i) {
            final Cardapio c = cardapios[i];
            final usuario = store.usuarioPorId(c.usuarioId);
            return ListTile(
              leading: const Icon(Icons.menu_book),
              title: Text('Cardápio de ${usuario?.nome ?? 'Usuário'}'),
              subtitle: Text(
                '${c.cafeIds.length} café • ${c.almocoIds.length} almoço • '
                '${c.jantaIds.length} janta',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'Compartilhar',
                onPressed: () => _compartilhar(
                  context,
                  titulo: 'Cardápio de ${usuario?.nome ?? 'Usuário'}',
                  link: _gerarLink('cardapio', c.id),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

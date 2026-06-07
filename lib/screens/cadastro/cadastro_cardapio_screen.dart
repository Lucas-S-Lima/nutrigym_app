import 'package:flutter/material.dart';

import '../../models/alimento.dart';
import '../../services/app_store.dart';

/// Cadastro de um novo cardápio: escolhe um usuário e monta as opções
/// de café (3), almoço (5) e janta (4) a partir dos alimentos cadastrados.
class CadastroCardapioScreen extends StatefulWidget {
  const CadastroCardapioScreen({super.key});

  @override
  State<CadastroCardapioScreen> createState() => _CadastroCardapioScreenState();
}

class _CadastroCardapioScreenState extends State<CadastroCardapioScreen> {
  String? _usuarioId;

  // Seleções por refeição (cada item é uma opção). As listas são dinâmicas:
  // o usuário adiciona/remove campos pelo botão "+" de cada refeição.
  final List<String?> _cafe = [null];
  final List<String?> _almoco = [null];
  final List<String?> _janta = [null];

  Future<void> _salvar() async {
    final store = AppStore.instance;
    if (_usuarioId == null) {
      _aviso('Selecione um usuário.');
      return;
    }
    final cafe = _cafe.whereType<String>().toList();
    final almoco = _almoco.whereType<String>().toList();
    final janta = _janta.whereType<String>().toList();

    if (cafe.isEmpty || almoco.isEmpty || janta.isEmpty) {
      _aviso('Preencha ao menos uma opção em cada refeição.');
      return;
    }

    await store.adicionarCardapio(
      usuarioId: _usuarioId!,
      cafeIds: cafe,
      almocoIds: almoco,
      jantaIds: janta,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cardápio cadastrado com sucesso!')),
    );
    Navigator.of(context).pop();
  }

  void _aviso(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Cardápio')),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final usuarios = store.usuarios;
          if (usuarios.isEmpty) {
            return const _Vazio(
              mensagem:
                  'Cadastre ao menos um usuário antes de criar um cardápio.',
            );
          }
          // Todos os alimentos ficam disponíveis em qualquer refeição.
          final opcoes = store.alimentos;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String>(
                initialValue: _usuarioId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Usuário',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                items: usuarios
                    .map((u) => DropdownMenuItem(
                          value: u.id,
                          child: Text(u.nome),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _usuarioId = v),
              ),
              const SizedBox(height: 8),
              _SecaoRefeicao(
                titulo: 'Café da manhã',
                icone: Icons.free_breakfast_outlined,
                opcoes: opcoes,
                selecoes: _cafe,
                onChanged: (i, v) => setState(() => _cafe[i] = v),
                onAdicionar: () => setState(() => _cafe.add(null)),
                onRemover: (i) => setState(() => _cafe.removeAt(i)),
              ),
              _SecaoRefeicao(
                titulo: 'Almoço',
                icone: Icons.lunch_dining_outlined,
                opcoes: opcoes,
                selecoes: _almoco,
                onChanged: (i, v) => setState(() => _almoco[i] = v),
                onAdicionar: () => setState(() => _almoco.add(null)),
                onRemover: (i) => setState(() => _almoco.removeAt(i)),
              ),
              _SecaoRefeicao(
                titulo: 'Janta',
                icone: Icons.dinner_dining_outlined,
                opcoes: opcoes,
                selecoes: _janta,
                onChanged: (i, v) => setState(() => _janta[i] = v),
                onAdicionar: () => setState(() => _janta.add(null)),
                onRemover: (i) => setState(() => _janta.removeAt(i)),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Salvar cardápio'),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Uma seção de refeição com campos de opção dinâmicos.
///
/// O botão "+" no cabeçalho adiciona um novo campo; cada campo tem um
/// ícone para removê-lo (mantendo sempre ao menos um).
class _SecaoRefeicao extends StatelessWidget {
  const _SecaoRefeicao({
    required this.titulo,
    required this.icone,
    required this.opcoes,
    required this.selecoes,
    required this.onChanged,
    required this.onAdicionar,
    required this.onRemover,
  });

  final String titulo;
  final IconData icone;
  final List<Alimento> opcoes;
  final List<String?> selecoes;
  final void Function(int indice, String? valor) onChanged;
  final VoidCallback onAdicionar;
  final void Function(int indice) onRemover;

  @override
  Widget build(BuildContext context) {
    final temOpcoes = opcoes.isNotEmpty;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$titulo (${selecoes.length})',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Adicionar opção',
                  icon: const Icon(Icons.add),
                  onPressed: temOpcoes ? onAdicionar : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!temOpcoes)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Nenhum alimento cadastrado.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              )
            else
              for (var i = 0; i < selecoes.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selecoes[i],
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Opção ${i + 1}',
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('— Nenhum —'),
                            ),
                            ...opcoes.map((a) => DropdownMenuItem(
                                  value: a.id,
                                  child: Text(a.nome),
                                )),
                          ],
                          onChanged: (v) => onChanged(i, v),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remover opção',
                        icon: const Icon(Icons.remove_circle_outline),
                        // Mantém sempre ao menos um campo.
                        onPressed:
                            selecoes.length > 1 ? () => onRemover(i) : null,
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _Vazio extends StatelessWidget {
  const _Vazio({required this.mensagem});
  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 48),
            const SizedBox(height: 12),
            Text(mensagem, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

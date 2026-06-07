import 'package:flutter/material.dart';

import '../../models/cardapio.dart';
import '../../services/app_store.dart';
import '../../services/formatador.dart';

/// Consulta de cardápio pelo nome do usuário: traz café, almoço e janta.
class ConsultaCardapioScreen extends StatefulWidget {
  const ConsultaCardapioScreen({super.key});

  @override
  State<ConsultaCardapioScreen> createState() => _ConsultaCardapioScreenState();
}

class _ConsultaCardapioScreenState extends State<ConsultaCardapioScreen> {
  final _buscaController = TextEditingController();
  List<Cardapio> _resultados =
      AppStore.instance.buscarCardapiosPorNomeUsuario('');

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _buscar(String termo) {
    setState(() => _resultados =
        AppStore.instance.buscarCardapiosPorNomeUsuario(termo));
  }

  Widget _refeicao(BuildContext context, String titulo, List<String> ids) {
    final nomes = Formatador.nomesAlimentos(ids);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (nomes.isEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 8, top: 2, bottom: 4),
            child: Text('— sem opções —'),
          )
        else
          ...nomes.map((n) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child: Text('• $n'),
              )),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Cardápio')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _buscaController,
              onChanged: _buscar,
              decoration: const InputDecoration(
                labelText: 'Buscar pelo nome do usuário',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _resultados.isEmpty
                ? const Center(child: Text('Nenhum cardápio encontrado.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _resultados.length,
                    itemBuilder: (context, i) {
                      final c = _resultados[i];
                      final usuario = store.usuarioPorId(c.usuarioId);
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cardápio de ${usuario?.nome ?? 'Usuário'}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const Divider(),
                              _refeicao(context, 'Café da manhã', c.cafeIds),
                              _refeicao(context, 'Almoço', c.almocoIds),
                              _refeicao(context, 'Janta', c.jantaIds),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

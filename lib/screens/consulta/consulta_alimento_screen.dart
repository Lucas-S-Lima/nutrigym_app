import 'package:flutter/material.dart';

import '../../models/alimento.dart';
import '../../services/app_store.dart';
import '../../widgets/foto_avatar.dart';

/// Consulta de alimento pelo nome: traz nome, foto, categoria e tipo.
class ConsultaAlimentoScreen extends StatefulWidget {
  const ConsultaAlimentoScreen({super.key});

  @override
  State<ConsultaAlimentoScreen> createState() => _ConsultaAlimentoScreenState();
}

class _ConsultaAlimentoScreenState extends State<ConsultaAlimentoScreen> {
  final _buscaController = TextEditingController();
  List<Alimento> _resultados = AppStore.instance.alimentos;

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _buscar(String termo) {
    setState(() => _resultados = AppStore.instance.buscarAlimentos(termo));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Alimento')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _buscaController,
              onChanged: _buscar,
              decoration: const InputDecoration(
                labelText: 'Buscar pelo nome',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _resultados.isEmpty
                ? const Center(child: Text('Nenhum alimento encontrado.'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _resultados.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, i) {
                      final a = _resultados[i];
                      return ListTile(
                        leading: FotoAvatar(
                          fotoPath: a.fotoPath,
                          icone: Icons.fastfood,
                        ),
                        title: Text(a.nome),
                        subtitle: Text(
                          'Categoria: ${a.categoriasTexto}\nTipo: ${a.tipo.rotulo}',
                        ),
                        isThreeLine: true,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

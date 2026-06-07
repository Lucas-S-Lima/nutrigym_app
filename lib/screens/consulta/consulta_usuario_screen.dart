import 'package:flutter/material.dart';

import '../../models/usuario.dart';
import '../../services/app_store.dart';
import '../../widgets/foto_avatar.dart';

/// Consulta de usuário pelo nome: traz nome, foto e idade.
class ConsultaUsuarioScreen extends StatefulWidget {
  const ConsultaUsuarioScreen({super.key});

  @override
  State<ConsultaUsuarioScreen> createState() => _ConsultaUsuarioScreenState();
}

class _ConsultaUsuarioScreenState extends State<ConsultaUsuarioScreen> {
  final _buscaController = TextEditingController();
  List<Usuario> _resultados = AppStore.instance.usuarios;

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _buscar(String termo) {
    setState(() => _resultados = AppStore.instance.buscarUsuarios(termo));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Usuário')),
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
                ? const Center(child: Text('Nenhum usuário encontrado.'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _resultados.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, i) {
                      final u = _resultados[i];
                      return ListTile(
                        leading: FotoAvatar(fotoPath: u.fotoPath),
                        title: Text(u.nome),
                        subtitle: Text('${u.idade} anos'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

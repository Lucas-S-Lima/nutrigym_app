import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'foto_avatar.dart';

/// Botão/área que permite escolher uma foto da galeria ou câmera e
/// devolve o caminho selecionado através de [onSelecionada].
class SeletorFoto extends StatelessWidget {
  const SeletorFoto({
    super.key,
    required this.fotoPath,
    required this.onSelecionada,
    this.icone = Icons.person,
  });

  final String? fotoPath;
  final ValueChanged<String?> onSelecionada;
  final IconData icone;

  Future<void> _escolher(BuildContext context, ImageSource origem) async {
    final picker = ImagePicker();
    final arquivo = await picker.pickImage(source: origem, imageQuality: 70);
    if (arquivo != null) onSelecionada(arquivo.path);
  }

  Future<void> _abrirOpcoes(BuildContext context) async {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(ctx);
                _escolher(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Câmera'),
              onTap: () {
                Navigator.pop(ctx);
                _escolher(context, ImageSource.camera);
              },
            ),
            if (fotoPath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remover foto'),
                onTap: () {
                  Navigator.pop(ctx);
                  onSelecionada(null);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          FotoAvatar(fotoPath: fotoPath, raio: 48, icone: icone),
          TextButton.icon(
            onPressed: () => _abrirOpcoes(context),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text(fotoPath == null ? 'Adicionar foto' : 'Alterar foto'),
          ),
        ],
      ),
    );
  }
}

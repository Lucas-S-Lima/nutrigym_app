import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Exibe a foto a partir de um caminho local, com fallback para um ícone.
///
/// Trata a diferença entre web (onde [Image.file] não funciona e o caminho
/// é uma URL de blob) e plataformas nativas.
class FotoAvatar extends StatelessWidget {
  const FotoAvatar({
    super.key,
    required this.fotoPath,
    this.raio = 28,
    this.icone = Icons.person,
  });

  final String? fotoPath;
  final double raio;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    ImageProvider? provider;
    final caminho = fotoPath;
    if (caminho != null && caminho.isNotEmpty) {
      provider = kIsWeb ? NetworkImage(caminho) : FileImage(File(caminho));
    }

    return CircleAvatar(
      radius: raio,
      backgroundColor: cor.primaryContainer,
      foregroundImage: provider,
      child: provider == null
          ? Icon(icone, size: raio, color: cor.onPrimaryContainer)
          : null,
    );
  }
}

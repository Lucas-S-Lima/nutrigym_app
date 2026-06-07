import 'package:flutter/material.dart';

/// Tela de Créditos: nomes completos dos integrantes do grupo.
class CreditosScreen extends StatelessWidget {
  const CreditosScreen({super.key});

  // TODO: substitua pelos nomes completos reais dos integrantes do grupo.
  static const List<String> integrantes = [
    'Integrante 1 - Bruno Vinicius Carvalho de Alencar',
    'Integrante 2 - Felipe de Arena Abreu Ramos Figueiredo',
    'Integrante 3 - João Victor Mesquita de Moraes Toledo',
    'Integrante 4 - Lucas da Silva Lima',
    'Integrante 5 - Rafael de Araújo Moreira',
  ];

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Créditos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: cor.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.groups, size: 48, color: cor.onPrimaryContainer),
                  const SizedBox(height: 8),
                  Text(
                    'Integrantes do grupo',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: cor.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...integrantes.map(
            (nome) => Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(nome),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

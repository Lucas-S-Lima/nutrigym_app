import 'package:flutter/material.dart';

import '../../models/alimento.dart';
import '../../services/app_store.dart';
import '../../widgets/seletor_foto.dart';

/// Cadastro de um novo alimento: nome, foto, categoria(s) e tipo.
class CadastroAlimentoScreen extends StatefulWidget {
  const CadastroAlimentoScreen({super.key});

  @override
  State<CadastroAlimentoScreen> createState() => _CadastroAlimentoScreenState();
}

class _CadastroAlimentoScreenState extends State<CadastroAlimentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final Set<CategoriaAlimento> _categorias = {};
  TipoAlimento? _tipo;
  String? _fotoPath;

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tipo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o tipo do alimento.')),
      );
      return;
    }

    await AppStore.instance.adicionarAlimento(
      nome: _nomeController.text.trim(),
      categorias: _categorias.toList(),
      tipo: _tipo!,
      fotoPath: _fotoPath,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alimento cadastrado com sucesso!')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Alimento')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SeletorFoto(
              fotoPath: _fotoPath,
              icone: Icons.fastfood,
              onSelecionada: (p) => setState(() => _fotoPath = p),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do alimento',
                prefixIcon: Icon(Icons.label_outline),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 20),
            Text(
              'Categoria (opcional)',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: CategoriaAlimento.values.map((c) {
                final marcado = _categorias.contains(c);
                return FilterChip(
                  label: Text(c.rotulo),
                  selected: marcado,
                  onSelected: (sel) => setState(() {
                    sel ? _categorias.add(c) : _categorias.remove(c);
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'Tipo',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: TipoAlimento.values.map((t) {
                return ChoiceChip(
                  label: Text(t.rotulo),
                  selected: _tipo == t,
                  onSelected: (_) => setState(() => _tipo = t),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _salvar,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Salvar alimento'),
            ),
          ],
        ),
      ),
    );
  }
}

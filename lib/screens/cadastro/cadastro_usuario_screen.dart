import 'package:flutter/material.dart';

import '../../models/usuario.dart';
import '../../services/app_store.dart';
import '../../widgets/seletor_foto.dart';

/// Cadastro de um novo usuário: nome, foto e data de nascimento.
class CadastroUsuarioScreen extends StatefulWidget {
  const CadastroUsuarioScreen({super.key});

  @override
  State<CadastroUsuarioScreen> createState() => _CadastroUsuarioScreenState();
}

class _CadastroUsuarioScreenState extends State<CadastroUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  DateTime? _dataNascimento;
  Genero? _genero;
  String? _fotoPath;

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final hoje = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime(hoje.year - 18),
      firstDate: DateTime(1900),
      lastDate: hoje,
      helpText: 'Data de nascimento',
    );
    if (data != null) setState(() => _dataNascimento = data);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dataNascimento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de nascimento.')),
      );
      return;
    }
    if (_genero == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o gênero.')),
      );
      return;
    }

    await AppStore.instance.adicionarUsuario(
      nome: _nomeController.text.trim(),
      dataNascimento: _dataNascimento!,
      genero: _genero!,
      fotoPath: _fotoPath,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuário cadastrado com sucesso!')),
    );
    Navigator.of(context).pop();
  }

  String _formatarData(DateTime data) =>
      '${data.day.toString().padLeft(2, '0')}/'
      '${data.month.toString().padLeft(2, '0')}/${data.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Usuário')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SeletorFoto(
              fotoPath: _fotoPath,
              icone: Icons.person,
              onSelecionada: (p) => setState(() => _fotoPath = p),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                prefixIcon: Icon(Icons.badge_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selecionarData,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data de nascimento',
                  prefixIcon: Icon(Icons.cake_outlined),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _dataNascimento == null
                      ? 'Toque para selecionar'
                      : _formatarData(_dataNascimento!),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Genero>(
              initialValue: _genero,
              decoration: const InputDecoration(
                labelText: 'Gênero',
                prefixIcon: Icon(Icons.wc_outlined),
                border: OutlineInputBorder(),
              ),
              items: Genero.values
                  .map((g) => DropdownMenuItem(
                        value: g,
                        child: Text(g.rotulo),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _genero = v),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _salvar,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Salvar usuário'),
            ),
          ],
        ),
      ),
    );
  }
}

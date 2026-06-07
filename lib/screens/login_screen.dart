import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/app_store.dart';
import 'home_screen.dart';

/// Tela de Login: permite entrar em uma conta existente ou criar uma nova.
///
/// Ao criar uma conta também são coletados nome completo, data de
/// nascimento e gênero — e o usuário correspondente é criado automaticamente.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _nomeController = TextEditingController();

  DateTime? _dataNascimento;
  Genero? _genero;
  bool _modoCriar = false;
  bool _carregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _nomeController.dispose();
    super.dispose();
  }

  String _formatarData(DateTime data) =>
      '${data.day.toString().padLeft(2, '0')}/'
      '${data.month.toString().padLeft(2, '0')}/${data.year}';

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

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    // Validações extras apenas no modo criar conta.
    if (_modoCriar) {
      if (_dataNascimento == null) {
        _aviso('Selecione a data de nascimento.');
        return;
      }
      if (_genero == null) {
        _aviso('Selecione o gênero.');
        return;
      }
    }

    setState(() => _carregando = true);
    final store = AppStore.instance;
    final email = _emailController.text;
    final senha = _senhaController.text;

    final erro = _modoCriar
        ? await store.registrar(
            email: email,
            senha: senha,
            nome: _nomeController.text.trim(),
            dataNascimento: _dataNascimento!,
            genero: _genero!,
          )
        : await store.entrar(email, senha);

    if (!mounted) return;
    setState(() => _carregando = false);

    if (erro != null) {
      _aviso(erro);
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _aviso(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _modoCriar ? 'Crie a sua conta' : 'Entre na sua conta',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Campos exclusivos da criação de conta.
                  if (_modoCriar) ...[
                    TextFormField(
                      controller: _nomeController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nome completo',
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Informe o nome completo'
                          : null,
                    ),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
                  ],

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Informe o e-mail';
                      }
                      if (!v.contains('@')) return 'E-mail inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _senhaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Informe a senha';
                      if (v.length < 4) return 'Mínimo de 4 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _carregando ? null : _enviar,
                      child: _carregando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_modoCriar ? 'Criar conta' : 'Entrar'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _carregando
                        ? null
                        : () => setState(() => _modoCriar = !_modoCriar),
                    child: Text(_modoCriar
                        ? 'Já tenho conta. Entrar'
                        : 'Não tenho conta. Criar novo usuário'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

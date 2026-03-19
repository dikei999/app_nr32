import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants.dart';
import '../../models/app_user.dart';
import '../../services/supabase_service.dart';

enum SignupMode { createOrganization, joinOrganization }

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _orgNameCtrl = TextEditingController();
  final _orgCodeCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _siapeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final _service = SupabaseService();
  SignupMode _mode = SignupMode.createOrganization;
  UserRole _role = UserRole.owner;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _orgNameCtrl.dispose();
    _orgCodeCtrl.dispose();
    _fullNameCtrl.dispose();
    _siapeCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final orgName = _orgNameCtrl.text.trim();
    final orgCode = _orgCodeCtrl.text.trim();
    final fullName = _fullNameCtrl.text.trim();
    final siape = _siapeCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (fullName.isEmpty || siape.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Preencha nome, SIAPE/SIGEPE, e-mail e senha.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'As senhas não conferem.');
      return;
    }
    if (_mode == SignupMode.createOrganization && orgName.isEmpty) {
      setState(() => _error = 'Informe o nome da organização.');
      return;
    }
    if (_mode == SignupMode.joinOrganization && orgCode.isEmpty) {
      setState(() => _error = 'Informe o código da organização/convite.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Role:
      // - Criar organização -> Owner
      // - Entrar em organização -> Admin ou Inspetor
      final role = _mode == SignupMode.createOrganization ? UserRole.owner : _role;

      final res = await _service.signUp(
        email: email,
        password: password,
        fullName: fullName,
        siape: siape,
        role: role,
      );

      final user = res.user;
      if (user == null) {
        throw Exception('Não foi possível criar o usuário (res.user nulo).');
      }

      String organizationId;

      if (_mode == SignupMode.createOrganization) {
        organizationId = await _service.createOrganization(
          name: orgName,
          type: 'hospital_ebserh',
          cnpjOrCode: orgCode.isEmpty ? null : orgCode,
        );
      } else {
        // Entrada por código: por enquanto usamos organizations.cnpj_or_code como "código".
        final org = await Supabase.instance.client
            .from('organizations')
            .select('id')
            .eq('cnpj_or_code', orgCode)
            .maybeSingle();
        if (org == null) {
          throw Exception('Organização não encontrada para o código informado.');
        }
        organizationId = org['id'].toString();
      }

      await _service.attachUserToOrganization(
        organizationId: organizationId,
        email: email,
        fullName: fullName,
        siape: siape,
        role: role,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado! Faça login para continuar.')),
      );
      Navigator.of(context).pop();
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Falha no cadastro: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Criar conta',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<SignupMode>(
                    segments: const [
                      ButtonSegment(
                        value: SignupMode.createOrganization,
                        label: Text('Criar minha organização'),
                        icon: Icon(Icons.apartment),
                      ),
                      ButtonSegment(
                        value: SignupMode.joinOrganization,
                        label: Text('Entrar em uma organização'),
                        icon: Icon(Icons.vpn_key),
                      ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: _loading
                        ? null
                        : (s) {
                            setState(() {
                              _mode = s.first;
                              _role = _mode == SignupMode.createOrganization
                                  ? UserRole.owner
                                  : UserRole.inspector;
                            });
                          },
                  ),
                  const SizedBox(height: 12),
                  if (_mode == SignupMode.createOrganization) ...[
                    TextField(
                      controller: _orgNameCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nome da organização',
                        hintText: 'Ex: Hospital Universitário de Timon - EBSERH',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _orgCodeCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'CNPJ ou código (opcional)',
                      ),
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    TextField(
                      controller: _orgCodeCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Código da organização/convite',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<UserRole>(
                      initialValue: _role,
                      decoration: const InputDecoration(labelText: 'Perfil'),
                      items: const [
                        DropdownMenuItem(
                          value: UserRole.inspector,
                          child: Text('Inspetor'),
                        ),
                        DropdownMenuItem(
                          value: UserRole.admin,
                          child: Text('Admin'),
                        ),
                      ],
                      onChanged: _loading ? null : (v) => setState(() => _role = v!),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: _fullNameCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Nome completo'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _siapeCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'SIAPE/SIGEPE'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Senha'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmCtrl,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(labelText: 'Confirmar senha'),
                  ),
                  const SizedBox(height: 12),
                  if (_error != null) ...[
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                  ],
                  ElevatedButton(
                    onPressed: _loading ? null : _handleSignup,
                    child: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Cadastrar'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _loading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Já tem conta? Faça login'),
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


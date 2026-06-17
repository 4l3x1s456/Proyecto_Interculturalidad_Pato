import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../widgets/auth_ornament.dart';
import '../widgets/brand_header.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum AuthMode { signIn, register }

class _AuthScreenState extends State<AuthScreen> {
  static const bool _allowRegister = true;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthMode _mode = AuthMode.signIn;
  bool _obscurePassword = true;
  bool _busy = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    if (!_allowRegister) {
      return;
    }
    setState(() {
      _mode = _mode == AuthMode.signIn ? AuthMode.register : AuthMode.signIn;
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _busy = true);
    final auth = AppScope.of(context).auth;
    final messenger = ScaffoldMessenger.of(context);

    final error = _mode == AuthMode.register
        ? await auth.register(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          )
        : await auth.signIn(
            email: _emailController.text,
            password: _passwordController.text,
          );

    if (!mounted) {
      return;
    }
    setState(() => _busy = false);

    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRegister = _allowRegister && _mode == AuthMode.register;
    final title = isRegister ? 'Registro' : 'Acceso';
    final action = isRegister ? 'Crear cuenta' : 'Iniciar sesion';
    final toggle = isRegister
        ? 'Ya tienes cuenta? Inicia sesion'
        : 'No tienes cuenta? Registrate';

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(gradient: AppGradients.auth),
            ),
          ),
          const AuthOrnament(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const BrandHeader(),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textStrong,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Explora culturas del Ecuador y su legado.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textSoft),
                              ),
                              const SizedBox(height: 20),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: isRegister
                                    ? TextFormField(
                                        key: const ValueKey('name-field'),
                                        controller: _nameController,
                                        textInputAction: TextInputAction.next,
                                        decoration: const InputDecoration(
                                          labelText: 'Nombre',
                                        ),
                                        validator: (value) {
                                          if (!isRegister) {
                                            return null;
                                          }
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Ingresa tu nombre';
                                          }
                                          return null;
                                        },
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              if (isRegister) const SizedBox(height: 12),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Correo',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Ingresa tu correo';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Correo no valido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  labelText: 'Contrasena',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingresa tu contrasena';
                                  }
                                  if (isRegister && value.length < 6) {
                                    return 'Minimo 6 caracteres';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) => _submit(),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _busy ? null : _submit,
                                  child: _busy
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(action),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_allowRegister) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _busy ? null : _toggleMode,
                        child: Text(toggle),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

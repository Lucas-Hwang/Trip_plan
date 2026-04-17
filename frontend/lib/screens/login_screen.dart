import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isRegister = false;

  Future<void> _submit() async {
    if (_isRegister) {
      await ref.read(authProvider.notifier).register(
            _emailCtrl.text.trim(),
            _passwordCtrl.text,
            _nameCtrl.text.trim(),
          );
    } else {
      await ref.read(authProvider.notifier).login(
            _emailCtrl.text.trim(),
            _passwordCtrl.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final error = authState.hasError ? authState.error.toString() : null;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.flight_takeoff, size: 64, color: Colors.deepOrange),
              const SizedBox(height: 16),
              Text(
                _isRegister ? '创建账号' : '欢迎回来',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_isRegister)
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: '昵称', prefixIcon: Icon(Icons.person)),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: '邮箱', prefixIcon: Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(labelText: '密码', prefixIcon: Icon(Icons.lock)),
                obscureText: true,
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: authState.isLoading ? null : _submit,
                child: authState.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_isRegister ? '注册' : '登录'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => _isRegister = !_isRegister),
                child: Text(_isRegister ? '已有账号？去登录' : '没有账号？去注册'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

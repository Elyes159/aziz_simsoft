import 'package:flutter/material.dart';
import 'package:simsoft/Firebase/Auth/login.dart';
import 'package:simsoft/Widgets/CustomButton.dart';
import 'package:simsoft/Widgets/customTextfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  String? _error;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final error = await _authService.login(
      email: _emailController.text,
      password: _passwordController.text,
      context: context,
    );

    setState(() {
      _isLoading = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/logo.png",
              color: Colors.black,
              height: 200,
              width: 200,
            ),
            SizedBox(
              height: 30,
            ),
            CustomTextFormField(
              controller: _emailController,
              label: "Email",
              isPassword: false,
            ),
            const SizedBox(height: 20),
            CustomTextFormField(
                controller: _passwordController,
                isPassword: true,
                label: 'Mot de passe'),
            const SizedBox(height: 20),
            CustomButton(
                onTap: _isLoading ? () {} : _handleLogin,
                buttonColor: _isLoading ? Colors.grey : Colors.black,
                label: _isLoading ? "Chargement..." : "Se connecter"),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}

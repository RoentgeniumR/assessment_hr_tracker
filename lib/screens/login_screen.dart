import 'package:assessment/models/login_request.dart';
import 'package:assessment/services/api_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _apiService = ApiService();
  String? _usernameError;
  String? _passwordError;
  bool _hasUsernameInteracted = false;
  bool _hasPasswordInteracted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_validateUsername);
    _passwordController.addListener(_validatePassword);
    _usernameFocusNode.addListener(_onUsernameFocusChange);
    _passwordFocusNode.addListener(_onPasswordFocusChange);
  }

  void _onUsernameFocusChange() {
    if (!_usernameFocusNode.hasFocus) {
      setState(() => _hasUsernameInteracted = true);
      _validateUsername();
    }
  }

  void _onPasswordFocusChange() {
    if (!_passwordFocusNode.hasFocus) {
      setState(() => _hasPasswordInteracted = true);
      _validatePassword();
    }
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  void _validateUsername() {
    if (!_hasUsernameInteracted) return;

    final username = _usernameController.text;
    if (username.isEmpty) {
      setState(() => _usernameError = 'Please enter your username');
    } else if (!isValidEmail(username)) {
      setState(() => _usernameError = 'Username must be a valid email address');
    } else {
      setState(() => _usernameError = null);
    }
  }

  void _validatePassword() {
    if (!_hasPasswordInteracted) return;

    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _passwordError = 'Please enter your password');
    } else if (password.length < 3) {
      setState(() => _passwordError = 'Password must be at least 3 characters');
    } else {
      setState(() => _passwordError = null);
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _hasUsernameInteracted = true;
      _hasPasswordInteracted = true;
      _isLoading = true;
    });

    try {
      final request = LoginRequest(
        username: _usernameController.text,
        password: _passwordController.text,
      );

      await _apiService.login(request);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/profiles');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
        setState(() {
          _isLoading = false;  // <-- ADD THIS INSIDE catch block
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _usernameController,
                  focusNode: _usernameFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: const OutlineInputBorder(),
                    errorText: _hasUsernameInteracted ? _usernameError : null,
                    suffixIcon:
                        _hasUsernameInteracted &&
                                _usernameController.text.isNotEmpty
                            ? Icon(
                              _usernameError == null
                                  ? Icons.check_circle
                                  : Icons.error,
                              color:
                                  _usernameError == null
                                      ? Colors.green
                                      : Colors.red,
                            )
                            : null,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    errorText: _hasPasswordInteracted ? _passwordError : null,
                    suffixIcon:
                        _hasPasswordInteracted &&
                                _passwordController.text.isNotEmpty
                            ? Icon(
                              _passwordError == null
                                  ? Icons.check_circle
                                  : Icons.error,
                              color:
                                  _passwordError == null
                                      ? Colors.green
                                      : Colors.red,
                            )
                            : null,
                  ),
                  obscureText: true,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 3) {
                      return 'Password must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_isLoading || _usernameError != null || _passwordError != null)
                        ? null
                        : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text('Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

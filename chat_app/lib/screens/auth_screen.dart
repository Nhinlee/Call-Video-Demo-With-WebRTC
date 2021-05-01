import 'dart:io';

import 'package:chat_app/providers/auth_provider.dart';
import 'package:chat_app/widgets/auth_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  void _submitAuthForm(
    String email,
    String password,
  ) async {
    print(email);
    print(password);
    await context.read<AuthProvider>().login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(
        submitForm: _submitAuthForm,
      ),
    );
  }
}

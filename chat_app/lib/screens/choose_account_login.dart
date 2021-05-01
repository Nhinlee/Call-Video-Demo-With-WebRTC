import 'package:chat_app/providers/auth_provider.dart';
import 'package:chat_app/utils/accounts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChooseAccountLogin extends StatelessWidget {
  void _login(AuthProvider authProvider, int accountIndex) async {
    await authProvider.login(
      accounts[accountIndex]['username'],
      accounts[accountIndex]['password'],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Account To Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Nhin'),
              style: ElevatedButton.styleFrom(padding: EdgeInsets.all(30)),
              onPressed: () => _login(auth, 0),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              child: Text('Luan'),
              style: ElevatedButton.styleFrom(padding: EdgeInsets.all(30)),
              onPressed: () => _login(auth, 1),
            ),
          ],
        ),
      ),
    );
  }
}

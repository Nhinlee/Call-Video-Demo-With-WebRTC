import 'package:chat_app/providers/auth_provider.dart';
import 'package:chat_app/screens/call_video_screen.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/choose_account_login.dart';
import 'package:chat_app/screens/incoming_call_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        )
      ],
      child: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return Container();
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.deepOrange,
              backgroundColor: Colors.pink,
              accentColor: Colors.deepPurple,
              accentColorBrightness: Brightness.dark,
              buttonTheme: ButtonTheme.of(context).copyWith(
                buttonColor: Colors.pink,
                textTheme: ButtonTextTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            home: Consumer<AuthProvider>(
              builder: (context, value, child) =>
                  value.token != null ? ChatScreen() : ChooseAccountLogin(),
            ),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case IncomingCallScreen.routeName:
                  {
                    final args = settings.arguments;
                    return MaterialPageRoute(
                      builder: (context) => IncomingCallScreen(
                        callerId: args,
                      ),
                    );
                  }
                case CallVideoScreen.routeName:
                  {
                    final args = settings.arguments as Map<String, dynamic>;
                    return MaterialPageRoute(
                      builder: (context) => CallVideoScreen(
                        isAnswer: args['isAnswer'],
                        callerId: args['callerId'],
                      ),
                    );
                  }
              }
              return null;
            },
          );
        },
      ),
    );
  }
}

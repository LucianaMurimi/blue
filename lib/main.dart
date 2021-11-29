import 'package:blue/screens/authenticate/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import './theme/styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     title: 'A2EI',
  //     debugShowCheckedModeBanner: false,
  //     theme: accessTheme(),
  //     home: SignIn(),
  //   );
  // }

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot){

        //----------------------------------------------------------------------
        if(snapshot.hasError){
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: accessTheme(),
            home: Scaffold(body: Center(child: Text('${snapshot.error}'))),
          );
        }

        //----------------------------------------------------------------------
        if(snapshot.connectionState == ConnectionState.done){
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: accessTheme(),
            home: SignIn(),
          );
        }

        //----------------------------------------------------------------------
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: accessTheme(),
          home: Scaffold(body: Center(child: Text("loading"))),
        );
      },
    );
  }
}



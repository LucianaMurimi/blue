import 'package:blue/screens/authenticate/sign_in.dart';
import 'package:blue/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();

    return Scaffold(
      backgroundColor: Colors.white,

      // App Bar
      //------------------------------------------------------------
      appBar: AppBar(
        backgroundColor: Color(0xFFffffff),
        iconTheme: IconThemeData(color: Color(0xFF005f81)),
        elevation: 2.0,
        toolbarHeight: 68.0,
        titleSpacing: 0,

        title: Text('MENU',
            style: TextStyle(color: Color(0xFFe0115f), fontSize: 14.0, fontWeight: FontWeight.bold, letterSpacing: 2)),
      ),
      body: Column(
        children: [
          ListTile(
            leading: Icon(Icons.bluetooth, size: 24.0, color: Color(0xFF005f81)),
            title: Text('Bluetooth Settings'),
            onTap: (){
              FlutterBluetoothSerial.instance.openSettings();
            },
          ),
          ListTile(
            leading: Icon(Icons.help_outline_rounded, size: 24.0, color: Color(0xFF005f81)),
            title: Text('Help'),
          ),
          ListTile(
            leading: Icon(Icons.report_problem_outlined, size: 24.0, color: Color(0xFF005f81),),
            title: Text('Report a Problem'),
          ),
          ListTile(
            leading: Icon(Icons.logout_rounded, size: 24.0, color: Color(0xFF005f81)),
            title: Text('Log Out'),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('LOG OUT?',  style: TextStyle(color: Color(0xFFe0115f), fontSize: 14.0, letterSpacing: 2.4)),
                      content: Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(onPressed: () async {
                          await _auth.signOut()
                              .then((value) => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignIn()),
                            )
                          });
                        },
                          child: Text('Yes', style: TextStyle(color: Color(0xFF005f81), fontWeight: FontWeight.bold),),
                        ),
                        TextButton(onPressed: (){
                          Navigator.pop(context, false);
                        },
                          child: Text('No', style: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.bold),),
                        )
                      ],
                    );
                  }
              );
            },
          ),
        ],
      ),

    );
  }
}

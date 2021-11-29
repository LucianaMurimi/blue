import 'package:flutter/material.dart';
import './blue_devices.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Image.asset("assets/images/logo.png", width: 160, height: 96),
                  Image.asset("assets/images/file.png", width: double.infinity, height: 216),
                  SizedBox(height: 20.0),
                  Text("Receive files via Bluetooth.",
                    style: TextStyle(fontSize: 12.8),
                  ),
                  SizedBox(height: 20.0),
                  Container(
                      padding: EdgeInsets.only(top: 4.0, bottom: 4.0),

                      decoration: BoxDecoration(
                        borderRadius: new BorderRadius.circular(24.0),
                        border: Border.all(color: Color(0xFFd3d3d3), width: 1),
                      ),
                      width: double.infinity,

                      child: TextButton(
                        child: Text('RECEIVE',
                            style: TextStyle(color: Color(0xFFe0115f), fontSize: 14.0, fontWeight: FontWeight.bold, letterSpacing: 2,)),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => BluetoothApp()));
                        },
                      )
                  ),

                ],
              ),
            ),
          ),
        ));
  }
}

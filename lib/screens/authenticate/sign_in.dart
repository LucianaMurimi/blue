import 'package:blue/screens/authenticate/otp.dart';
import 'package:blue/screens/authenticate/register.dart';
import 'package:blue/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:blue/services/phoneVerification.dart';
import 'package:blue/screens/blue_devices.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:blue/globals.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:password/password.dart';


class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final PhoneVerification _phoneAuth = PhoneVerification();

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();


  // Create storage
  final storage = new FlutterSecureStorage();

  bool obscurePassword = true;

  String username = '';
  String password = '';

  bool _loading = false;

  @override
  initState() {
    // TODO: implement initState
    initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    super.initState();
  }

  Future initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
      connectivityRes = result.toString();
      return result;

    } catch (err) {
      print(err);
      return;
    }

  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
      connectivityRes = result.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     body: LoadingOverlay(
       child: Center(
         child: SingleChildScrollView(
           child: Container(
             constraints: BoxConstraints(minHeight: MediaQuery. of(context). size. height),
             decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bg.jpg"),
                  fit: BoxFit.cover,
                ),
             ),
             padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),


             child: Form(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   // 1. logo
                   //------------------------------------------------------------
                   new Image.asset("assets/images/logo.png", width: 180, height: 80),

                   SizedBox(height: 28.0),

                   // 2. username TextFormField
                   //------------------------------------------------------------
                   Container(
                     padding: EdgeInsets.only(left: 20, right: 20),

                     decoration: BoxDecoration(
                       borderRadius: new BorderRadius.circular(24.0),
                       border: Border.all(color: Color(0xFFd3d3d3), width: 1,),
                     ),

                     child: TextFormField(
                       onChanged: (val) {setState(() => username = val);},

                       decoration: InputDecoration(
                         border: InputBorder.none,
                         labelText: 'username', labelStyle: TextStyle(fontSize: 12.8),
                         icon: IconButton(onPressed: (){}, icon: Icon(Icons.email, size: 16, color: Color(0xB3000000)),),
                       ),
                     ),

                   ),

                   SizedBox(height: 20.0),

                   // 3. password TextFormField
                   //------------------------------------------------------------
                   Container(
                     padding: EdgeInsets.only(left: 20, right: 20),

                     decoration: BoxDecoration(
                       borderRadius: new BorderRadius.circular(24.0),
                       border: Border.all(color: Color(0xFFd3d3d3), width: 1,),
                     ),

                     child: TextFormField(
                       obscureText: obscurePassword ? true : false,
                       onChanged: (val) {setState(() => password = val);},

                       decoration: InputDecoration(
                         border: InputBorder.none,
                         labelText: 'password', labelStyle: TextStyle(fontSize: 12.8),
                         icon: IconButton(
                           onPressed: (){setState(() {
                             obscurePassword = !obscurePassword;
                           });},
                           icon: obscurePassword ? Icon(Icons.visibility_off, size: 16, color: Color(0xB3000000))
                               : Icon(Icons.visibility, size: 16, color: Color(0xB3000000)),
                         ),
                       ),

                     ),

                   ),

                   SizedBox(height: 28.0),

                   // 4. login Button
                   //------------------------------------------------------------
                   Container(
                       padding: EdgeInsets.only(top: 6.0, bottom: 6.0),
                       width: double.infinity,

                       decoration: BoxDecoration(
                         // borderRadius: new BorderRadius.circular(24.0),
                         color: Color(0xFFb30e4c),
                       ),

                       child: TextButton(
                         onPressed: () async {
                           // print(username);
                           // print(password);
                           setState(() {
                             _loading = true;
                           });
                           try{

                             if( connectivityRes == "ConnectivityResult.none"){
                               // NO Internet -> offline authentication

                              // Read value
                               String? storedUsername = await storage.read(key: 'username');
                               String? hashedPassword = await storage.read(key: 'hashedPassword');

                               if((username.trim() == storedUsername) && (Password.verify(password, hashedPassword))){
                                 user = username.trim();
                                 setState(() {
                                   _loading = false;
                                   Navigator.push(
                                     context,
                                     MaterialPageRoute(builder: (context) => BluetoothApp()),
                                   );
                                 });
                               }else {
                                 setState(() {
                                   _loading = false;
                                   ScaffoldMessenger.of(context).showSnackBar(
                                       SnackBar(content: Text('An error occurred. Could not sign in!',
                                         style: TextStyle(color: Colors.red),
                                         textAlign: TextAlign.center,),
                                         backgroundColor: Color(0xFFffffff),)
                                   );
                                 });
                               }

                             } else {

                               dynamic result = await _auth.signInWithEmailAndPassword(username.trim(), password);

                               if(result != null){
                                 // generate OTP
                                 // Navigator.push(
                                 //   context,
                                 //   MaterialPageRoute(builder: (context) => PhoneVerification()),
                                 // );
                                 user = username.trim();
                                 setState(() {
                                   _loading = false;
                                   Navigator.push(
                                     context,
                                     MaterialPageRoute(builder: (context) => BluetoothApp()),
                                   );
                                 });



                               } else {
                                 // TODO: Handle errors
                                 setState(() {
                                   _loading = false;
                                   ScaffoldMessenger.of(context).showSnackBar(
                                       SnackBar(content: Text('An error occurred. Could not sign in!',
                                         style: TextStyle(color: Colors.red),
                                         textAlign: TextAlign.center,),
                                         backgroundColor: Color(0xFFffffff),)
                                   );
                                 });

                               }

                             }

                           } catch(err){
                             print(err);
                           }
                         },
                         child: Text('LOGIN',
                             style: TextStyle(color: Color(0xFFffffff), fontSize: 16.0, fontWeight: FontWeight.bold, letterSpacing: 2, wordSpacing: 3.6)),
                       )
                   ),

                   SizedBox(height: 20.0),

                   // 5. password | register links
                   //------------------------------------------------------------
                   Container(
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,

                       children: [
                         Text('Password'),
                         Text('    |    '),
                         InkWell(
                           child: Text('Register'),

                           onTap: (){
                             // On pressing the Register => the register screen is served

                             Navigator.push(
                               context,
                               MaterialPageRoute(builder: (context) => Register()),
                             );
                           },
                         )
                       ],
                     ),
                   )

                 ],
               ),
             ),

           ),
         ),
       ),
       isLoading: _loading,
       opacity: 0.7,
       progressIndicator: SpinKitCircle(color: Color(0xFFe0115f), size: 70.0),
       color: Color(0xFFc0c0c0),
     )
   );
  }
}

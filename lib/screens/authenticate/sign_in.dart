import 'package:blue/screens/authenticate/register.dart';
import 'package:blue/services/auth.dart';
import 'package:flutter/material.dart';

import '../home.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();

  bool obscurePassword = true;

  String username = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     body: Center(
       child: SingleChildScrollView(
         child: Container(
           padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),

           child: Form(
             child: Column(
               children: [
                 // 1. logo
                 //------------------------------------------------------------
                 new Image.asset("assets/images/logo.png", width: 160, height: 120),
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
                       labelText: 'username', labelStyle: TextStyle(fontSize: 10.0),
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
                       labelText: 'password', labelStyle: TextStyle(fontSize: 10.0),
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
                         print(username);
                         print(password);

                         try{
                           dynamic result = await _auth.signInWithEmailAndPassword(username, password);

                           if(result != null){
                             setState(() {
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(builder: (context) => HomePage()),
                               );
                             });

                           } else {
                             setState(() {
                               ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(content: Text('Could not sign in with the given credentials!',
                                     style: TextStyle(color: Colors.red),
                                     textAlign: TextAlign.center,),
                                     backgroundColor: Color(0xFFffffff),)
                               );
                             });

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
     )
   );
  }
}

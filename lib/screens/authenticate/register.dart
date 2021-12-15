import 'package:flutter/material.dart';
import 'package:blue/services/auth.dart';
import 'sign_in.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:password/password.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();


  // Define two states: username and password
  // These states keep track of the values being entered in the sign in form

  String username = '';
  String password = '';
  String confirmPassword = '';

  bool obscurePassword1 = true;
  bool obscurePassword2 = true;
  bool _loading = false;

  final secureStorage = new FlutterSecureStorage();

  //----------------------------------------------------------------------------
  storeLocally(username, password) async {
    var hashedPassword = Password.hash(password, new PBKDF2());

    await secureStorage.write(key: 'username', value: username);
    await secureStorage.write(key: 'hashedPassword', value: hashedPassword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Register SCREEN
      //    1. logo
      //    2. username TextFormField
      //    3. password TextFormField
      //    4. Register Button

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
                  // Associating the global `_formKey` with the form;
                  // this key will keep track of the state of our form.
                  key: _formKey,

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
                          validator: (val) => val!.isEmpty ? 'enter an email address' : null,
                          onChanged: (val) {
                            setState(() => username = val);
                          },

                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'example@gmail.com', labelStyle: TextStyle(fontSize: 12.8),
                            icon: IconButton(
                              onPressed: (){},
                              icon: Icon(Icons.email, size: 16, color: Color(0xB3000000)),
                            ),
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
                          obscureText: obscurePassword1 ? true : false,
                          validator: (val) => val!.length < 3 ? 'must have at least 6 characters' : null,
                          onChanged: (val) {
                            setState(() => password = val);
                          },

                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'password', labelStyle: TextStyle(fontSize: 12.8),
                            icon: IconButton(
                              onPressed: (){setState(() {
                                obscurePassword1 = !obscurePassword1;
                              });},
                              icon: obscurePassword1 ? Icon(Icons.visibility_off, size: 16, color: Color(0xB3000000),)
                                  : Icon(Icons.visibility, size: 16, color: Color(0xB3000000)),
                            ),
                          ),
                        ),

                      ),

                      SizedBox(height: 20.0,),

                      // 4. Confirm Password TextFormField
                      //------------------------------------------------------------
                      Container(
                        padding: EdgeInsets.only(left: 20, right: 20),

                        decoration: BoxDecoration(
                          borderRadius: new BorderRadius.circular(24.0),
                          border: Border.all(color: Color(0xFFd3d3d3), width: 1,),
                        ),

                        child: TextFormField(
                          obscureText: obscurePassword2 ? true : false,
                          validator: (val) => val! != password ? 'password mismatch' : null,
                          onChanged: (val) {
                            setState(() => confirmPassword = val);
                          },

                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'confirm password', labelStyle: TextStyle(fontSize: 12.8),
                            icon: IconButton(
                              onPressed: (){setState(() {
                                obscurePassword2 = !obscurePassword2;
                              });},
                              icon: obscurePassword2 ? Icon(Icons.visibility_off, size: 16, color: Color(0xB3000000),)
                                  : Icon(Icons.visibility, size: 16, color: Color(0xB3000000)),
                            ),
                          ),
                        ),

                      ),

                      SizedBox(height: 28.0),

                      // 5. login Button
                      //------------------------------------------------------------
                      Container(
                        padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        width: double.infinity,

                        decoration: BoxDecoration(color: Color(0xFFb30e4c),),

                        child: TextButton(
                          child: Text('Register',
                              style: TextStyle(color: Color(0xFFffffff), fontSize: 16.0, fontWeight: FontWeight.bold, letterSpacing: 2, wordSpacing: 3.6)),

                          onPressed: () async {
                            //----------------------------------------------------
                            if(_formKey.currentState!.validate()){
                              try{
                                setState(() {
                                  _loading = true;
                                });

                                dynamic result = await _auth.registerWithEmailAndPassword(username.trim(), password);

                                if(result != null){
                                  // registration successful
                                  await storeLocally(username.trim(), password).then((value){
                                    setState(() {
                                      _loading = false;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Registration successful!',
                                            style: TextStyle(color: Colors.green),
                                            textAlign: TextAlign.center,),
                                            backgroundColor: Color(0xFFffffff),)
                                      );
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => SignIn()),
                                      );
                                    });
                                  });

                                } else {
                                  // registration unsuccessful
                                  setState(() {
                                    _loading = false;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Could not register the user!',
                                          style: TextStyle(color: Colors.red),
                                          textAlign: TextAlign.center,),
                                          backgroundColor: Color(0xFFffffff),)
                                    );
                                  });
                                }
                                //----------------------------------------------------
                              } catch(err){
                                print(err);
                              }
                            }

                          },
                        ),

                      ),

                      SizedBox(height: 20.0),

                      // 6. login | exit
                      Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              InkWell(
                                child: Text('Login'),

                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => SignIn()),
                                  );
                                },
                              ),
                              Text('    |    '),
                              InkWell(
                                child: Text('Exit'),

                                onTap: (){

                                },
                              )
                            ],
                          )
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
      ),
    );
  }
}


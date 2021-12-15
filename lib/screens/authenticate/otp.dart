import 'package:blue/screens/blue_devices.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class OTP extends StatefulWidget {
  final FirebaseAuth phoneAuth;
  final String verificationId;

  const OTP(this.phoneAuth, this.verificationId);

  @override
  _OTPState createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  late String smsCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //------------------------------------------------------------------------
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg reg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),

            child: Column(
              children: [
                new Image.asset("assets/images/logo.png", width: 180, height: 80),
                SizedBox(height: 16.0),

                //--------------------------------------------------------------
                Text("A verification code has been sent to +254 7 * * * * * 958",
                  style: TextStyle(height: 1.5, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                Icon(Icons.check_circle, size: 28, color: Colors.green,),
                Divider(height: 24.0,),

                //--------------------------------------------------------------
                SizedBox(height: 8,),
                Text("Enter the verification code:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),

                //--------------------------------------------------------------
                OtpTextField(
                  numberOfFields: 6,
                  // fieldWidth: 48,
                  showFieldAsBox: true,
                  filled: true,
                  fillColor: Color(0xFFf2f2f2),
                  enabledBorderColor: Color(0xFF7f7f7f),
                  focusedBorderColor: Color(0xFF005f81),
                  cursorColor: Color(0xFF005f81),
                  textStyle: TextStyle(fontWeight: FontWeight.bold,),

                  onCodeChanged: (String code) {
                    //handle validation or checks here
                  },

                  onSubmit: (String verificationCode){
                    //runs when every textfield is filled
                    smsCode = verificationCode;
                    print("============================================");
                    print("SMS CODE: $smsCode");
                  },
                ),

                SizedBox(height: 28.0),

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


                        // print("================================================================");
                        // print("SMSCODE: ${smsCode}");
                        // Create a PhoneAuthCredential with the code
                        PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: widget.verificationId, smsCode: smsCode);

                        // Sign the user in (or link) with the credential
                        try {
                          await widget.phoneAuth.signInWithCredential(credential);
                          setState(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BluetoothApp()),
                            );
                          });

                        } catch(err) {
                          print(err);
                        }



                      },
                      child: Text('VERIFY & PROCEED',
                          style: TextStyle(color: Color(0xFFffffff), fontSize: 16.0, fontWeight: FontWeight.bold, letterSpacing: 2, wordSpacing: 3.6)),
                    )
                ),

                SizedBox(height: 20.0),

                //------------------------------------------------------------
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Text("Did not receive OTP ? ",),
                      InkWell(
                        child: Text('RESEND OTP',
                          style: TextStyle(color: Color(0xFF005f81), fontWeight: FontWeight.bold, letterSpacing: 2.4),
                        ),
                        onTap: (){

                        },
                      )
                    ]
                ),

              ],
            ),

          ),
        ),
      ),

    );
  }
}

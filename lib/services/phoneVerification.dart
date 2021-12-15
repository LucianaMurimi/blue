/*
PHONE VERIFICATION:
Phone authentication allows users to sign in to Firebase using their phone as the authenticator.
SMS message is sent to the user (using the provided phone number) containing a unique code(OTP).
Once the code has been authorized, the user is able to sign into Firebase.
*/

import 'package:blue/screens/authenticate/otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhoneVerification extends StatefulWidget {
  // const PhoneVerificationService({Key? key}) : super(key: key);

  @override
  _PhoneVerificationState createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  final FirebaseAuth phoneAuth = FirebaseAuth.instance;
  late String smsCode;

  Future phoneVerification() async{
    await phoneAuth.verifyPhoneNumber(
      phoneNumber: '+255 756 024 079',

      timeout: const Duration(seconds: 120),

      //1. verificationCompleted: Automatic handling of the SMS code on Android devices
      verificationCompleted: (PhoneAuthCredential credential) async {
        print("===============================================================");
        print('CREDENTIAL: $credential');
        // ANDROID ONLY!

        // Sign the user in (or link) with the auto-generated credential
        await phoneAuth.signInWithCredential(credential);
      },

      //----------------------------------------------------------------------
      //2. verificationFailed: Handle failure events such as invalid phone numbers or whether the SMS quota has been exceeded.
      verificationFailed: (FirebaseAuthException error) {
        if (error.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        }
        print("================================================================");
        print("ERRORCODE: ${error.code}");
      },

      //----------------------------------------------------------------------
      //3. codeSent: Handle when a code has been sent to the device from Firebase, used to prompt users to enter the code.
      codeSent: (String verificationId, int? forceResendingToken) async {
        print("===============================================================");
        print('VERIFICATION: $verificationId');


        //Update the UI - wait for the user to enter the SMS code
        setState(() {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OTP(phoneAuth, verificationId)),
          );
        });
        // String smsCode = '123456';

        // print("================================================================");
        // print("SMSCODE: ${smsCode}");
        // Create a PhoneAuthCredential with the code
        // PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);

        // Sign the user in (or link) with the credential
        // await _phoneAuth.signInWithCredential(credential);
      },

      //----------------------------------------------------------------------
      //4. codeAutoRetrievalTimeout: Handle a timeout of when automatic SMS code handling fails.
      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto-resolution timed out...
      },

    );
  }
  @override
  void initState() {
    super.initState();
    phoneVerification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("loading"),
    );
  }
}


// class PhoneVerificationService {
//   final FirebaseAuth _phoneAuth = FirebaseAuth.instance;
//
//   Future phoneVerification() async{
//     await _phoneAuth.verifyPhoneNumber(
//       phoneNumber: '+254 721 600 958',
//
//       timeout: const Duration(seconds: 60),
//
//       //1. verificationCompleted: Automatic handling of the SMS code on Android devices
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         print("===============================================================");
//         print('CREDENTIAL: $credential');
//         // ANDROID ONLY!
//
//         // Sign the user in (or link) with the auto-generated credential
//         await _phoneAuth.signInWithCredential(credential);
//       },
//
//       //----------------------------------------------------------------------
//       //2. verificationFailed: Handle failure events such as invalid phone numbers or whether the SMS quota has been exceeded.
//       verificationFailed: (FirebaseAuthException error) {
//         if (error.code == 'invalid-phone-number') {
//           print('The provided phone number is not valid.');
//         }
//         print("================================================================");
//         print("ERRORCODE: ${error.code}");
//       },
//
//       //----------------------------------------------------------------------
//       //3. codeSent: Handle when a code has been sent to the device from Firebase, used to prompt users to enter the code.
//       codeSent: (String verificationId, int? forceResendingToken) async {
//         print("===============================================================");
//         print('VERIFICATION: $verificationId');
//
//
//         //Update the UI - wait for the user to enter the SMS code
//         String smsCode = '123456';
//
//         print("================================================================");
//         print("SMSCODE: ${smsCode}");
//         // Create a PhoneAuthCredential with the code
//         PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
//
//         // Sign the user in (or link) with the credential
//         await _phoneAuth.signInWithCredential(credential);
//       },
//
//       //----------------------------------------------------------------------
//       //4. codeAutoRetrievalTimeout: Handle a timeout of when automatic SMS code handling fails.
//       codeAutoRetrievalTimeout: (String verificationId) {
//         // Auto-resolution timed out...
//       },
//
//     );
//   }
//
// }
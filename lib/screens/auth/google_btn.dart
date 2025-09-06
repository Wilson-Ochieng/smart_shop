// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:ionicons/ionicons.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:shop_smart/root_screen.dart';
// import 'package:shop_smart/services/my_app_functions.dart';

// class GoogleButton extends StatelessWidget {
//   const GoogleButton({super.key});
//   Future<void> _googleSignSignIn({required BuildContext context}) async {
//     try {
//       final googleSignIn = GoogleSignIn();
//       final googleAccount = await googleSignIn.signIn();
//       if (googleAccount != null) {
//         final googleAuth = await googleAccount.authentication;
//         if (googleAuth.accessToken != null && googleAuth.idToken != null) {
//           final authResults = await FirebaseAuth.instance
//               .signInWithCredential(GoogleAuthProvider.credential(
//             accessToken: googleAuth.accessToken,
//             idToken: googleAuth.idToken,
//           ));
//         }
//       }
//       WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//         Navigator.pushReplacementNamed(context, RootScreen.routName);
//       });
//     } on FirebaseException catch (error) {
//       await MyAppFunctions.showErrorOrWarningDialog(
//         context: context,
//         subtitle: error.message.toString(),
//         fct: () {},
//       );
//     } catch (error) {
//       await MyAppFunctions.showErrorOrWarningDialog(
//         context: context,
//         subtitle: error.toString(),
//         fct: () {},
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton.icon(
//       style: ElevatedButton.styleFrom(
//         elevation: 1,
//         padding: const EdgeInsets.all(12.0),
//         backgroundColor: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(
//             12.0,
//           ),
//         ),
//       ),
//       icon: const Icon(
//         Ionicons.logo_google,
//         color: Colors.red,
//       ),
//       label: const Text(
//         "Sign in with google",
//         style: TextStyle(color: Colors.black),
//       ),
//       onPressed: () async {
//         await _googleSignSignIn(context: context);
//       },
//     );
//   }
// }
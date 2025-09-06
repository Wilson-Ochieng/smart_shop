import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MpesaPayment extends StatefulWidget {
  const MpesaPayment({super.key});

  @override
  State<MpesaPayment> createState() => _MpesaPaymentState();
}

class _MpesaPaymentState extends State<MpesaPayment> {

  Future main() async {
  // To load the .env file contents into dotenv.
  // NOTE: fileName defaults to .env and can be omitted in this case.
  // Ensure that the filename corresponds to the path in step 1 and 2.
  await dotenv.load(fileName: ".env");
  //...runapp
}










  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
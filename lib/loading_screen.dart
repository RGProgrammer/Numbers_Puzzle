import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
            height: 100,
            width: 100,
            child: Image.asset("assets/images/logo.png")),
        const CircularProgressIndicator(
          backgroundColor: Colors.black,
          color: Colors.white,
        ),
      ])),
    );
  }
}

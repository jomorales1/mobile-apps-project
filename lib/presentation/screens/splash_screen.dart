import 'package:flutter/material.dart';
import 'dart:async';
import 'package:app_museos/presentation/widgets/navigation_drawer_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => NavigationDrawerWidget(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF8ba936),
      body: Center(
        child: Image.asset('assets/loadgif.gif', width: 100, height: 100),
      ),
    );
  }
}

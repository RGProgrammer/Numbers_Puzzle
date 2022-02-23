import 'package:flutter/material.dart';
import 'package:numbers_puzzle/loading_screen.dart';
import 'package:numbers_puzzle/models/assets.dart';

import 'package:numbers_puzzle/puzzle_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Numbers Puzzle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _loaded = false;

  Future<void> _loadAssets() async {
    await Sprites.loadAllSprites();
    setState(() {
      _loaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  @override
  Widget build(BuildContext context) {
    return _loaded ? const PuzzleView() : const LoadingScreen();
  }
}

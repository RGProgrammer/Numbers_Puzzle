import 'dart:ui' as ui;

import 'package:numbers_puzzle/sprite/load_image.dart';

class Sprites {
  static ui.Image? _ship;
  static get ship => _ship;
  static ui.Image? _thrust;
  static get thrust => _thrust;
  static ui.Image? _assistant;
  static get assistant => _assistant;

  static Future<bool> loadAllSprites() async {
    try {
      _ship ??= await loadUiImage("assets/images/sci_fi.png");
      _thrust ??= await loadUiImage("assets/images/thrust.png");
      _assistant ??= await loadUiImage("assets/images/assistant.png");
    } catch (e) {
      return false;
    }
    return true;
  }
}

//class Audios {}

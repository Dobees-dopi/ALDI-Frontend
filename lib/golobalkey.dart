import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart'; // Material 라이브러리 임포트

class Globals {
  static String userName = "";
  static String videoStreamUrl = '';
  static String baseUrl = 'mvp-iot.cahlp.kr';
  static String mac = '';
  static String ac = 'false';
  static String ph = 'false';
  static String tds = 'false';
  static String wa = 'false';
  static String ranng = '1년';
  static int ranng2 = 60;
  static String tagurl = '';
  static String tagname = '';
  static String fcmurl = '';
  static int userid = 0;
  static int homestate = 0;
}



class SecureStorage {
  static final _storage = FlutterSecureStorage();

  static Future<void> saveData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> loadData(String key) async {
    return await _storage.read(key: key);
  }
}


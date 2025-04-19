import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Resize_images {
  Future<File> compressImage(File file) async {
    File compressedFile = await FlutterNativeImage.compressImage(
      file.path,
      quality: 70,
    );
    return compressedFile;
  }

// 특정 캐시 파일 삭제
  Future<void> deleteCacheFile(String fileName) async {
    try {
      // 캐시 디렉토리 경로 얻기
      final cacheDir = await getTemporaryDirectory();
      final filePath = '${cacheDir.path}/$fileName';
      final cacheFile = File(filePath);

      // 파일이 존재하는지 확인 후 삭제
      if (await cacheFile.exists()) {
        await cacheFile.delete();
        print('Cache file deleted: $fileName');
      } else {
        print('Cache file not found: $fileName');
      }
    } catch (e) {
      print('Error deleting cache file: $e');
    }
  }
}

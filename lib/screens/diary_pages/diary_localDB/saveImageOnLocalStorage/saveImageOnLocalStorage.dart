import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:umi/screens/diary_pages/diary_localDB/resize_images.dart';

class SaveImageOnLocalStorage {
  Resize_images resize = Resize_images();
  // 최종적으로 프로필 추가가 실행되면 저장(1개만 가능)
  Future<String> _getProfileImageDirPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${appDir.path}/profile');
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    return imageDir.path;
  }

  // 1개의 이미지만 저장
  Future<String?> saveProfileImageToAppDir(XFile image) async {
    final imageDir = await _getProfileImageDirPath(); // 이미지를 저장할 디렉토리 경로 가져오기
    final originalFile = File(image.path); // XFile을 File로 변환
    final compressedFile = await resize.compressImage(originalFile); // 이미지 압축
    // 새 파일 이름 생성 (타임스탬프 사용)
    final fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
    print('compressedFile file size: ${await compressedFile.length()} bytes');

    print('Original file size: ${await originalFile.length()} bytes');

    // 저장할 파일 경로 설정
    final filePath = '$imageDir/$fileName';
    // 압축된 이미지를 해당 경로에 복사하여 저장
    await compressedFile.copy(filePath);

    // 새 파일 경로 반환
    return filePath;
  }

  Future<String> _getDiaryImageDirPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${appDir.path}/diary');
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    return imageDir.path;
  }

  // 2개 이상의 이미지 저장
  Future<List<String>> saveDiaryImagesToAppDir(List<XFile> images) async {
    final imageDir = await _getDiaryImageDirPath();
    List<File> compressedFiles = [];
    List<String> filePaths = []; // 파일 경로를 저장할 리스트 생성

    // XFile을 File로 변환
    List<File> files = images.map((image) => File(image.path)).toList();

    for (var image in files) {
      File compressedFile = await resize.compressImage(image);
      compressedFiles.add(compressedFile);
      print('compressedFile file size: ${await compressedFile.length()} bytes');
      print('Original file size: ${await image.length()} bytes');

      // 각 이미지에 대해 고유한 파일 이름 생성 및 저장
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${compressedFile.hashCode}.jpg';
      final filePath = '$imageDir/$fileName';
      await compressedFile.copy(filePath);

      // 파일 경로를 리스트에 추가
      filePaths.add(filePath);
    }

    // 파일 경로 리스트 반환
    return filePaths;
  }
}

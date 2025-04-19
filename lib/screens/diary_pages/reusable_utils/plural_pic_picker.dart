import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

// 2개이상의 사진을 List에 선택하고 싶을때 이걸 사용
class ImagePluralPickerController extends GetxController {
  final RxList<XFile> _selectedImages = RxList<XFile>([]);
  List<XFile> get selectedImages => _selectedImages;
  final RxList<String> _newImagesPath = RxList<String>([]);
  List<String> get newImagesPath => _newImagesPath;

  // 다이어리 수정페이지에서 사진을 추가할때 DB와 로컬에 추가하기 전에 추가할 사진을 보여준다
  void addNewPhoto() async {
    // 이미지 추가 로직
    _newImagesPath.value = _selectedImages
        .map((image) => image.path)
        .toList(); // .value를 사용하여 값 갱신
  }

  Future<void> pickImagesFromGallery() async {
    if (await requestPermission(Permission.photos)) {
      final ImagePicker _picker = ImagePicker();
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null) {
        _selectedImages.addAll(images);
        addNewPhoto();
        update();
      }
    }
  }

  Future<void> pickImageFromCamera() async {
    if (await requestPermission(Permission.camera)) {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        _selectedImages.add(image);
        Get.reload<ImagePluralPickerController>(); // 사진 추가 후 reload
        update();
      }
    }
  }

  Future<bool> requestPermission(Permission permission) async {
    final status = await permission.request();
    return status.isGranted;
  }

  Future<void> showPicker(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('갤러리'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await pickImagesFromGallery();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('카메라'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await pickImageFromCamera();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void reset() {
    _selectedImages.clear();
    _newImagesPath.clear();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

// 1개의 사진을 List에 선택하고 싶을때 이걸 사용
class ImagePickerController extends GetxController {
  final _selectedImage = Rxn<XFile>();

  XFile? get selectedImage => _selectedImage.value;

  Future<void> pickImageFromGallery() async {
    if (await requestPermission(Permission.photos)) {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      _selectedImage.value = image;
    }
  }

  Future<void> pickImageFromCamera() async {
    if (await requestPermission(Permission.camera)) {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      _selectedImage.value = image;
    }
  }

  // Function to handle permission requests
  Future<bool> requestPermission(Permission permission) async {
    final status = await permission.request();
    return status.isGranted;
  }

  // Function to show a dialog for choosing between Camera and Gallery
  void showPicker(BuildContext context) {
    showDialog(
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
                    await pickImageFromGallery();
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
    _selectedImage.value = null;
  }
}

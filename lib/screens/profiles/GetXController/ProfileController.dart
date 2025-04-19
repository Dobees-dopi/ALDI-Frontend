import 'package:get/get.dart';

class ProfileController extends GetxController {
  final RxInt selectedProfileId = 1.obs; // 초기값은 1으로 설정
  final RxString selectedProfileImagePath = ''.obs;
  final RxString selectedProfileName = ''.obs;
  RxList<Map<String, dynamic>> profileList = <Map<String, dynamic>>[].obs;

  void updateSelectedTagId(int newId) {
    selectedProfileId.value = newId;
  }

  void updateSelectedProfileImage(String imagePath) {
    selectedProfileImagePath.value = imagePath;
  }

  void updateSelectedProfileName(String profileName) {
    selectedProfileName.value = profileName;
  }

// 프로필이 추가되면 추가된 프로필로 이동하도록 전역변수로 관리
// dividePage는 페이지별 Map의 파라미터가 다르기때문에 1은 profile_add.dart,   2는 diary_menu.dart에서
  void updateListOfProfile(List<Map<String, dynamic>> newList, int dividePage) {
    // 리스트가 비어있지 않은 경우
    if (newList.isNotEmpty) {
      if (dividePage == 1) {
        // 페이지 1인 경우 (profile_add.dart)
        selectedProfileImagePath.value =
            newList.first['profileImages'] ?? ''; // 이미지 경로
        selectedProfileName.value =
            newList.first['profile_name'] ?? ''; // 프로필 이름
        selectedProfileId.value = newList.first['profile_id'] ?? ''; // 프로필 ID
      } else if (dividePage == 2) {
        // 페이지 2인 경우 (diary_menu.dart)
        selectedProfileImagePath.value =
            newList.first['photoPath'] ?? ''; // 이미지 경로
        selectedProfileName.value =
            newList.first['profileName'] ?? ''; // 프로필 이름
        selectedProfileId.value = newList.first['profile_id'] ?? ''; // 프로필 ID
      }
    } else {
      // 리스트가 비어있는 경우 초기화
      selectedProfileImagePath.value = '';
      selectedProfileName.value = '';
      selectedProfileId.value = 1;
    }
  }
}

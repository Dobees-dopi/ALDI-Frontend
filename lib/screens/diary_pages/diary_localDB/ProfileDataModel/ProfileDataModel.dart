import 'package:get/get.dart';

class Profile {
  final int profile_id;
  final String userid;
  final String profile_name;
  final String location;
  final String bigCategory;
  final String smallCategory;
  final String profileImages;

  Profile({
    required this.profile_id,
    required this.userid,
    required this.profile_name,
    required this.location,
    required this.bigCategory,
    required this.smallCategory,
    required this.profileImages,
  });

  // 데이터베이스 조회 결과(Map)를 Profile 객체로 변환하는 생성자
  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      profile_id: map['profile_id'],
      userid: map['userid'],
      profile_name: map['profile_name'],
      location: map['location'],
      bigCategory: map['big_category'],
      smallCategory: map['small_category'],
      profileImages: map['profileImages'],
    );
  }

  // toString 메서드 오버라이드
  @override
  String toString() {
    return 'Profile(profile_id: $profile_id, userid: $userid, name: $profile_name, location: $location, bigCategory: $bigCategory, smallCategory: $smallCategory, picPath: $profileImages)';
  }

  // call 메서드로 fromMap 호출
  Profile call(Map<String, dynamic> map) {
    return Profile.fromMap(map);
  }
}

class SelectedProfileController extends GetxController {
  // selectedProfileName과 selectedProfilePic를 RxString으로 변경합니다.
  var selectedProfileName = ''.obs;
  var selectedProfilePic = ''.obs;

  void updateSelectedProfile(String newName, String newPicPath) {
    selectedProfileName.value = newName;
    selectedProfilePic.value = newPicPath;
  }

  void reset() {
    selectedProfileName.value = '';
    selectedProfilePic.value = '';
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umi/screens/diary_pages/diary_localDB/SqlLite/diary_localDB.dart';
import 'package:http/http.dart' as http;
import 'package:umi/golobalkey.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'package:umi/theme.dart';
import 'package:umi/screens/diary_pages/diary_localDB/SqlLite/profile_localDB.dart'
    as selectDB;
import 'package:umi/screens/diary_pages/diary_localDB/ProfileDataModel/ProfileDataModel.dart';
import 'package:umi/screens/diary_pages/reusable_utils/plural_pic_picker.dart';
import 'package:umi/screens/diary_pages/diary_localDB/saveImageOnLocalStorage/saveImageOnLocalStorage.dart';
import 'package:umi/screens/profiles/GetXController/ProfileController.dart';
import 'package:image_picker/image_picker.dart';
import 'package:umi/screens/diary_pages/diary.dart';

class MemoDefaultPage extends StatefulWidget {
  final int selectedIndex;

  const MemoDefaultPage({Key? key, required this.selectedIndex})
      : super(key: key);

  @override
  _MemoDefaultPageState createState() => _MemoDefaultPageState();
}

class _MemoDefaultPageState extends State<MemoDefaultPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  Color buttonColor = Colors.blue;
  String _repeatOption = '반복안함';
  bool _isAlarmSet = false;
  File? selectedImage;
  List<File> selectedImages = [];
  late TextEditingController _contentController;
  late TextEditingController _titleController;
  DateTime? selectedMemoDate;
  SharedPreferences? prefs;
  String buttonText = "파랑";
  String tagname = '';
  String imageuerl = '';
  final String _whetagname = "프로필"; // 초기값 설정
  late StreamController<String> _imageStreamController;
  DateTime? selecday;
  bool isLoading = false;
  String? userid;
  final selectDB.DatabaseHelper _dbHelper = selectDB.DatabaseHelper();
  final imagePickerController = Get.find<ImagePluralPickerController>();
  SaveImageOnLocalStorage saveLocalStorage = SaveImageOnLocalStorage();
  String? selectedImageURL = '';
  String? selectedProfileName = '';
  int selectedProfileId = 1;
  final ProfileController selectedProfileIdController =
      Get.find<ProfileController>();
  SaveImageOnLocalStorage saveLocal = SaveImageOnLocalStorage();
  List<Map<String, String>> tags = [
    {
      'picture': 'assets/images/dummy_images/boat.png',
      'category': '보트',
    },
    {
      'picture': 'assets/images/dummy_images/kayak.png',
      'category': '카약',
    },
    {
      'picture': 'assets/images/dummy_images/paddle.png',
      'category': '패들',
    },
  ];

  // 여기에 초기 텍스트를 설정하십시오.
  //Color? argumentColor = Get.arguments as Color?; // 넘겨진 값이 Color 타입이라고 가정했습니다.

  String getWeekday(String date) {
    List<String> weekdays = ["월", "화", "수", "목", "금", "토", "일"];
    DateTime parsedDate = DateTime.parse(date);
    return weekdays[parsedDate.weekday - 1];
  }

  // Future<List<StatusTag>> fetchStatusTags() async {
  //   final url = Uri.parse('https://mvp-iot.cahlp.kr/diary/v1/status/tag/');
  //   try {
  //     final response = await http.get(url);

  //     if (response.statusCode == 200) {
  //       // Decode the response body using UTF-8
  //       String decodedResponse = utf8.decode(response.bodyBytes);
  //       print("Response from API: $decodedResponse"); // Print the response

  //       List<dynamic> jsonResponse = jsonDecode(decodedResponse)['detail'];
  //       return jsonResponse.map((tag) => StatusTag.fromJson(tag)).toList();
  //     } else {
  //       print('Request failed with status: ${response.statusCode}.');
  //       return [];
  //     }
  //   } catch (e) {
  //     print('Error fetching status tags: $e');
  //     return [];
  //   }
  // }

  void _changeRepeatOption(String newOption) {
    setState(() {
      _repeatOption = newOption;
    });
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _imageStreamController = StreamController<String>();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    final receivedDay = Get.arguments;
    if (receivedDay != null) {
      if (receivedDay is Color) {
        buttonColor = receivedDay;
      } else if (receivedDay is DateTime) {
        selectedMemoDate = receivedDay;
      }
    } else {
      buttonColor = Colors.blue; // 넘겨진 값이 없을 때 기본값으로 설정
    }
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    userid = Globals.userName;
    getSelectedProfile();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _imageStreamController.close();
    _animationController.dispose();
    Get.find<SelectedProfileController>().reset(); // 선택된 프로필 상태 초기화
    imagePickerController.reset(); // 누적된 사진데이터 초기화
    super.dispose();
  }

  void loadSharedPreferencesAndData() {
    // SharedPreferences에서 메모 제목 불러오기
    String? savedMemoTitle = prefs?.getString('title');
    if (savedMemoTitle != null) {
      setState(() {
        _titleController.text = savedMemoTitle;
      });
    }

    // SharedPreferences에서 메모 내용 불러오기
    String? savedMemoContent = prefs?.getString('content');
    if (savedMemoContent != null) {
      setState(() {
        _contentController.text = savedMemoContent;
      });
    }

    void saveSelectedImagesList() {
      List<String> imagePaths =
          selectedImages.map((image) => image.path).toList();
      prefs?.setStringList('selected_images', imagePaths);
    }

    // Load selected images from SharedPreferences
    List<String>? imagePaths = prefs?.getStringList('selected_images');
    if (imagePaths != null) {
      setState(() {
        selectedImages = imagePaths.map((path) => File(path)).toList();
      });
    }
  }

  TimeOfDay selectedTime = TimeOfDay.now(); // 현재 시간을 상태로 저장합니다.

  Future<List<Profile>> requestProfileData() async {
    if (userid == null) {
      throw Exception('User ID cannot be null');
    }

    List<Map<String, dynamic>> profileMaps =
        await _dbHelper.selectAllProfile(userid!);
    List<Profile> profiles =
        profileMaps.map((map) => Profile.fromMap(map)).toList();

    return profiles;
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Builder(
          builder: (BuildContext context) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: Temas.maincolor, // 헤더 배경색
                  onPrimary: Colors.white, // 헤더 텍스트 색상
                  onSurface: Colors.black, // 본문 텍스트 색상
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    backgroundColor: Temas.maincolor, // 버튼 배경색
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35), // 네모난 모양
                    ),
                  ),
                ),
                dialogTheme: DialogTheme(
                  shape: RoundedRectangleBorder(
                    // 라운드 모서리 추가
                    borderRadius: BorderRadius.circular(35), // 모서리 둥글기 정도
                  ),
                ),
              ),
              child: TimePickerDialog(
                initialTime: selectedTime,
              ),
            );
          },
        );
      },
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked; // Update the selected time
      });
    }
  }

  String formatDate(String dateStr) {
    DateTime parsedDate = DateTime.parse(dateStr);
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  }

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020, 8), // 기간 시작을 원하는 날짜로 설정
      lastDate: DateTime(2101), // 기간 끝을 원하는 날짜로 설정
      locale: const Locale('ko', 'KR'), // 한글 사용 설정
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Temas.maincolor, // 헤더 배경색
              onPrimary: Colors.white, // 헤더 텍스트 색상
              onSurface: Colors.black, // 본문 텍스트 색상
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                backgroundColor: Temas.maincolor, // 버튼 배경색
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35), // 네모난 모양
                ),
              ),
            ),
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                // 라운드 모서리 추가
                borderRadius: BorderRadius.circular(35), // 모서리 둥글기 정도
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _showRepeatOptionsDialog() async {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('반복 옵션 선택',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <String>['반복안함', '매일', '매주', '매월', '매년']
              .map((String option) => ListTile(
                    title: Text(option),
                    onTap: () => _changeRepeatOption(option),
                  ))
              .toList(),
        ),
      ),
    );
  }

  void showPermissionSettingDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('권한이 필요합니다',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0)),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('설정으로 이동',
                  style: TextStyle(color: Color(0xFF3E7FE0))),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
            TextButton(
              child: const Text('취소',
                  style: TextStyle(color: Color.fromARGB(255, 54, 54, 54))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showProfileDialog(BuildContext context) async {
    // 데이터 가져오기
    List<Profile> profiles = await requestProfileData();

    // 데이터가 없으면 메시지 표시
    if (profiles.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Profiles Found'),
          content: const Text('No profile data available.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final SelectedProfileController profileController =
        Get.find<SelectedProfileController>();

    // 데이터가 있으면 다이얼로그 표시
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Profile'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return ListTile(
                leading: Image.file(
                  File(profile.profileImages),
                  width: 50,
                  height: 50,
                ),
                title: Text(profile.profile_name),
                subtitle: Text(profile.location),
                onTap: () {
                  profileController.updateSelectedProfile(
                      profile.profile_name, profile.profileImages);
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> sendPostRequest() async {
    print('sendPostRequest 함수 시작'); // 함수 시작 부분에 로그 추가

    var uri = Uri.parse('https://mvp-iot.cahlp.kr/diary/v1/diary/data/add/');
    print('URI 설정 완료: $uri'); // URI 설정 확인
    DateTime combinedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    var now1 = DateTime.now();

    String formattedDate =
        '${selecday?.year}-${selecday?.month.toString().padLeft(2, '0')}-${selecday?.day.toString().padLeft(2, '0')}';
    String formattedNow1 = now1.toIso8601String().substring(0, 19);
    // Remove seconds from current time
    now1 = DateTime(now1.year, now1.month, now1.day, now1.hour, now1.minute);
    String formattedCombinedDateTime =
        combinedDateTime.toIso8601String().substring(0, 16);
    String alarmStatusValue = _isAlarmSet ? '알람사용' : '알람미사용';
    var request = http.MultipartRequest('POST', uri)
      ..fields['Diary_user_name'] = Globals.userName
      ..fields['Diary_where_tag_name'] = _whetagname
      ..fields['Diary_status_tag_name'] = tagname
      ..fields['Diary_title'] = _titleController.text //
      ..fields['Diary_memo'] = _contentController.text //

      ..fields['Diary_date'] = formattedCombinedDateTime
      ..fields['Diary_memo_date'] = formattedDate /////////
      ..fields['Diary_local_create'] = formattedNow1
      ..fields['Diary_alarm_repeat'] = _repeatOption //_repeatOption.toString()
      ..fields['Diary_alarm_status'] = alarmStatusValue
      ..files.add(
          await http.MultipartFile.fromPath('images', selectedImage!.path));

    try {
      var response = await request.send();
      if (response.statusCode == 201) {
        String responseBody = await response.stream.bytesToString();
        print(responseBody);
      } else {
        print('실패');
        String responseBody = await response.stream.bytesToString();
        print(responseBody);
      }
    } catch (e) {
      print('Error sending request: $e');
    }
  }

  Future<void> getSelectedProfile() async {
    setState(() {
      selectedProfileName =
          selectedProfileIdController.selectedProfileName.value;
      selectedImageURL =
          selectedProfileIdController.selectedProfileImagePath.value;
      selectedProfileId = selectedProfileIdController.selectedProfileId.value;
    });
  }

  Future<List<String>> getCompressedImagesPath(List<File> imageFiles) async {
    List<XFile> imageXFiles =
        imageFiles.map((file) => XFile(file.path)).toList();
    List<String> compressedImagePaths =
        await saveLocalStorage.saveDiaryImagesToAppDir(imageXFiles);
    return compressedImagePaths;
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('ko_KR');
    var now = DateTime.now();
    var formatter = DateFormat('yyyy년 MM월 dd일 EEEE', 'ko_KR');
    String formattedDate = formatter.format(now);
    final receivedday = Get.arguments;
    return WillPopScope(
        onWillPop: () async {
          if (Get.isSnackbarOpen) {
            Get.closeCurrentSnackbar();
          }
          Get.offNamed('diary');
          return true;
        },
        child: Scaffold(
          extendBodyBehindAppBar: false,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
              onPressed: () => Get.offNamed('diary'),
            ),
            title: Text(
              receivedday != null
                  ? '${receivedday.substring(0, 4)}년 ${receivedday.substring(5, 7)}월 ${receivedday.substring(8, 10)}일 ${getWeekday(receivedday)}요일'
                  : formattedDate,
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(
                color: const Color.fromARGB(255, 240, 240, 240),
                height: 2.0,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            StreamBuilder<String>(
                              stream: _imageStreamController.stream,
                              builder: (context, snapshot) {
                                Widget imageWidget;
                                if (snapshot.hasData &&
                                    snapshot.data!.isNotEmpty) {
                                  imageWidget = ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: snapshot.data!,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  );
                                } else {
                                  imageWidget = const Icon(
                                      Icons.person_outlined,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      size: 55);
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Container(
                                    child: GestureDetector(
                                      onTap: () {
                                        _showProfileDialog(context);
                                      },
                                      child: Obx(() {
                                        final profileController = Get.find<
                                            SelectedProfileController>();

                                        // 선택된 프로필의 이미지 경로와 이름을 가져옵니다.
                                        final profileName = profileController
                                                .selectedProfileName
                                                .value
                                                .isNotEmpty
                                            ? profileController
                                                .selectedProfileName
                                                .value // 선택된 프로필이 있다면(다이어리 추가 페이지에서)
                                            : selectedProfileName
                                                .toString(); // 기본값
                                        final profilePicPath = profileController
                                                .selectedProfileName
                                                .value
                                                .isNotEmpty
                                            ? profileController
                                                .selectedProfilePic.value
                                            : selectedImageURL.toString();
                                        return Container(
                                          child: Row(
                                            children: [
                                              // 프로필 이미지
                                              profilePicPath.isNotEmpty
                                                  ? ClipRRect(
                                                      // ClipRRect로 이미지 감싸기
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25.0),
                                                      child: Image.file(
                                                        File(profilePicPath),
                                                        width: 45,
                                                        height: 45,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )
                                                  : const Icon(
                                                      Icons.person,
                                                      size: 50,
                                                      color: Colors.grey,
                                                    ),

                                              // 사진과 글자 사이 간격 추가
                                              const SizedBox(
                                                  width: 10), // 원하는 간격 크기로 조절

                                              // 프로필 이름
                                              Text(
                                                profileName,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                );
                              },
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                  bottom: 10.0, left: 20.0, right: 20, top: 25),
                              color: const Color.fromARGB(255, 189, 189, 189),
                              height: 1.0,
                              width: MediaQuery.of(context).size.width,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20.0, top: 15.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('태그'),
                                            content: SizedBox(
                                              height: 300,
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: tags.map((tag) {
                                                    return ListTile(
                                                      onTap: () {
                                                        setState(() {
                                                          isLoading =
                                                              true; // 이미지 로딩 시작
                                                        });
                                                        if (tag['category'] !=
                                                            null) {
                                                          tagname =
                                                              tag['category']!;
                                                          prefs?.setString(
                                                              'content',
                                                              tagname);
                                                        }
                                                        if (tag['picture'] !=
                                                            null) {
                                                          imageuerl =
                                                              tag['picture']!;
                                                          prefs?.setString(
                                                              'content',
                                                              imageuerl);
                                                        }
                                                        Navigator.of(context)
                                                            .pop();
                                                        setState(() {
                                                          isLoading =
                                                              false; // 이미지 로딩 완료
                                                        });
                                                      },
                                                      leading: Image.asset(
                                                        tag['picture']!,
                                                        width: 50,
                                                        height: 50,
                                                      ),
                                                      title: Text(
                                                          tag['category']!),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            color: imageuerl.isEmpty
                                                ? Colors.grey
                                                : null, // 이미지 URL이 null이거나 비어있으면 회색, 아니면 null (이미지 표시)
                                            shape: BoxShape.circle,
                                            image: imageuerl.isNotEmpty
                                                ? DecorationImage(
                                                    // 이미지 URL이 null이 아니고 비어있지 않으면 이미지 표시
                                                    image:
                                                        AssetImage(imageuerl),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          tagname.isEmpty
                                              ? '태그를 선택해주세요'
                                              : tagname, // tagname이 비어있으면 'Select a Tag', 아니면 tagname 표시
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            ),
                            const SizedBox(height: 25.0),
                            Container(
                              margin: const EdgeInsets.only(
                                  bottom: 10.0, left: 20.0, right: 20.0),
                              color: const Color.fromARGB(255, 189, 189, 189),
                              height: 1.0,
                              width: MediaQuery.of(context).size.width,
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                top: 5,
                                left: 15.0,
                                right: 15.0,
                              ),
                              child: TextFormField(
                                maxLines: 1,
                                controller: _titleController,
                                onChanged: (value) {
                                  prefs?.setString('title', value);
                                },
                                decoration: InputDecoration(
                                  labelText: '제목',
                                  labelStyle:
                                      const TextStyle(color: Color(0xFF000000)),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Temas
                                            .maincolor), // 포커스를 받았을 때 테두리 색상을 파란색으로 설정
                                  ),
                                  border: const UnderlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '제목을 입력해주세요.';
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                  top: 25.0,
                                  left: 15.0,
                                  right: 15.0,
                                  bottom: 10.0),
                              height: MediaQuery.of(context).size.height * 0.2,
                              child: TextFormField(
                                maxLines: 11,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  height: 1.5,
                                  fontSize: 20.0,
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: '메모',
                                  labelStyle:
                                      const TextStyle(color: Color(0xFF000000)),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Temas
                                            .maincolor), // 포커스를 받았을 때 테두리 색상을 파란색으로 설정
                                  ),
                                ),
                                controller: _contentController,
                                onChanged: (value) {
                                  prefs?.setString('content', value);
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '메모을 입력해주세요.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Obx(() => SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  height:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: PageView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: imagePickerController
                                            .selectedImages.length +
                                        1, // +1은 추가 버튼을 위한 것입니다.
                                    itemBuilder: (context, index) {
                                      // 마지막 아이템일 경우 추가 버튼을 반환합니다.
                                      if (index ==
                                          imagePickerController
                                              .selectedImages.length) {
                                        return Stack(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  top: 20.0),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.9,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.9,
                                              child: GestureDetector(
                                                onTap: () =>
                                                    imagePickerController
                                                        .showPicker(
                                                            context), //이미지 선택
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Icon(Icons.add_a_photo,
                                                      size: 60,
                                                      color: Colors.grey[600]),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }

                                      // 나머지 아이템의 경우 이미지를 반환합니다.
                                      return Stack(
                                        children: <Widget>[
                                          Container(
                                            margin: const EdgeInsets.only(
                                                top: 20.0),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              image: DecorationImage(
                                                  image: FileImage(File(
                                                      imagePickerController
                                                          .selectedImages[index]
                                                          .path)),
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            top: 15,
                                            child: IconButton(
                                              icon: const Icon(Icons.clear,
                                                  color: Colors.black),
                                              onPressed: () {
                                                setState(() {
                                                  imagePickerController
                                                      .selectedImages
                                                      .removeAt(index);
                                                });
                                              },
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            //top: 15,
                                            top: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.45 -
                                                6, // 화면 높이의 중간
                                            child: FadeTransition(
                                              opacity: _animation,
                                              child: const Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 24), // 화살표 아이콘
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                )),
                            const SizedBox(height: 25.0),
                            Container(
                              margin: const EdgeInsets.only(
                                  bottom: 0, left: 20.0, right: 20.0),
                              color: const Color.fromARGB(255, 189, 189, 189),
                              height: 1.0,
                              width: MediaQuery.of(context).size.width,
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                  left: 13, right: 10, top: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    // 이 Row 위젯이 아이콘과 텍스트를 같은 줄에 배치합니다.
                                    children: [
                                      Icon(Icons
                                          .alarm), // 여기에서 원하는 아이콘으로 변경할 수 있습니다.
                                      SizedBox(width: 5),
                                      Text(
                                        '알람 여부',
                                        style: TextStyle(fontSize: 18.0),
                                      ),
                                    ],
                                  ),
                                  Switch(
                                    value:
                                        _isAlarmSet, // boolean state variable
                                    onChanged: (bool value) {
                                      setState(() {
                                        _isAlarmSet = value;
                                      });
                                    },
                                    activeColor: const Color(
                                        0xFF3E7FE0), // 버튼 색깔 (토글이 켜져 있을 때)
                                    inactiveThumbColor: const Color.fromARGB(
                                        255, 86, 86, 86), // 버튼 색깔 (토글이 꺼져 있을 때)
                                    activeTrackColor:
                                        Colors.blue[200], // 트랙 색깔 (토글이 켜져 있을 때)
                                    inactiveTrackColor: const Color.fromARGB(
                                        255, 220, 220, 220),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.only(top: 15.0, bottom: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(width: 13),
                                      const Icon(Icons.access_time),
                                      const SizedBox(width: 5),
                                      InkWell(
                                        onTap: () => _selectDate(context),
                                        child: Text(
                                          DateFormat(
                                                  'yyyy년 MM월 dd일 EEEE', 'ko_KR')
                                              .format(selectedDate),
                                          style:
                                              const TextStyle(fontSize: 18.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15.0),
                                    child: InkWell(
                                      onTap: () => _selectTime(context),
                                      child: Text(
                                        selectedTime.format(context),
                                        style: const TextStyle(fontSize: 18.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                top: 20.0,
                                left: 13,
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.cached),
                                  const SizedBox(width: 5.0),
                                  InkWell(
                                    onTap: _showRepeatOptionsDialog,
                                    child: Text(
                                      _repeatOption,
                                      style: const TextStyle(fontSize: 18.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 150.0),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: SizedBox(
                          width: 150.0,
                          height: 50.0,
                          child: ElevatedButton(
                            onPressed: () async {
                              var now = DateTime.now();
                              DateTime chosenDateTime = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  selectedTime.hour,
                                  selectedTime.minute);
                              // Remove seconds from current time
                              now = DateTime(now.year, now.month, now.day,
                                  now.hour, now.minute);

                              // selecday = (receivedday ?? now.toIso8601String());
                              //   if (_isAlarmSet) {
                              //     if(chosenDateTime.isAfter(now)){
                              //       selecday = (receivedday ?? now);
                              List<String> compressedImagesPath =
                                  await saveLocalStorage
                                      .saveDiaryImagesToAppDir(
                                          imagePickerController.selectedImages);

                              saveDiaryDataWithPhotos(
                                  context: context,
                                  title: _titleController.text,
                                  content: _contentController.text,
                                  alarmSet: _isAlarmSet,
                                  currentTime: now,
                                  selectedDate: selectedDate,
                                  selectedTime: selectedTime,
                                  repeatOption: _repeatOption,
                                  iconText: _whetagname,
                                  uploadDate:
                                      (receivedday ?? now.toIso8601String()),
                                  tagName:
                                      tagname, // Replace with actual tag name
                                  tagImageUrl:
                                      imageuerl, // Replace with actual tag image URL
                                  photoPaths: compressedImagesPath,
                                  profileId: selectedProfileIdController
                                      .selectedProfileId.value);

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const DiaryPage(
                                          selectedIndex: 0,
                                        )), // Replace 'YourScreen' with the name of your screen class
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3E7FE0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              '작성완료',
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

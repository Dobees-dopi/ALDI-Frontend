import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:umi/widgets/app_bar/app_bar.dart';
import 'package:umi/screens/diary_pages/diary_localDB/SqlLite/diary_localDB.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:umi/screens/diary_pages/diary_menu.dart';
import 'package:umi/screens/diary_pages/diary.dart';
import 'dart:async';
import 'package:umi/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:umi/screens/diary_pages/diary_localDB/saveImageOnLocalStorage/deleteImageOnLocalStorage.dart';
import 'package:umi/screens/diary_pages/diary_localDB/saveImageOnLocalStorage/saveImageOnLocalStorage.dart';
import 'package:image_picker/image_picker.dart';

import 'package:umi/screens/diary_pages/reusable_utils/plural_pic_picker.dart';

class DetailMemo extends StatefulWidget {
  final Map<String, dynamic> rowData = Get.arguments;

  @override
  _DetailMemoState createState() => _DetailMemoState();
}

class _DetailMemoState extends State<DetailMemo> {
  final _isEditing = false.obs;
  late bool _isAlarmSet; // Local state for the switch
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  TextEditingController _titleController = TextEditingController();
  String _repeatOption = '';
  TextEditingController _contentController = TextEditingController();
  String _tagname = "프로필을 선택해주세요"; // 초기값 설정
  late StreamController<String> _imageStreamController;
  File? selectedImage;
  String imagePath = '';
  final imagePickerController = Get.find<ImagePluralPickerController>();
  //Color color = Colors.red;
  String iconText = '';
  Color iconColor = Colors.red;
  final _imagePaths = RxList<String>([]);
  List<String> newImagePaths = [];
  bool isInitialImageAdd = true; // 첫 이미지 추가 여부

  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime _selectedDate = DateTime.now();
  final ValueNotifier<List<String>> imagePaths = ValueNotifier([]);
  String title = '';
  String content = '';

  String aramday = '';
  String aramtime = '';
  String tagname = "";
  int diary_id = 0;
  bool isDeleted = false; // 로컬DB에서 삭제가 되면 bool값을 반환
  bool isSelected = false; // 삭제할 이미지가 선택되었는지 파악
  final _selectedImagePaths = <String>[].obs; // RxList로 선언하여 여러 이미지 경로 관리

  String formatDate(String dateStr) {
    DateTime parsedDate = DateTime.parse(dateStr);
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  }

  String formatDateM(String dateStr) {
    DateTime parsedDate = DateTime.parse(dateStr);
    return DateFormat('yyyy-MM-dd HH:mm').format(parsedDate);
  }

  @override
  void initState() {
    super.initState();
    _imageStreamController = StreamController<String>();
    _titleController =
        TextEditingController(text: widget.rowData[DatabaseHelper.columnTitle]);
    _contentController = TextEditingController(
        text: widget.rowData[DatabaseHelper.columnContent]);
    // rowData의 값을 통해 스위치의 초기값 설정
    _isAlarmSet = widget.rowData[DatabaseHelper.columnAlarmSet] ==
        1; // 데이터베이스에서 1은 true, 0은 false로 가정
    _repeatOption = widget.rowData[DatabaseHelper.columnRepeatOption];
    //color = widget.rowData[DatabaseHelper.columnIconColor];
    title = widget.rowData[DatabaseHelper.columnTitle];
    content = widget.rowData[DatabaseHelper.columnContent];
    aramtime = widget.rowData[DatabaseHelper.columnSelectedTime];
    aramday = widget.rowData[DatabaseHelper.columnSelectedDate];
    diary_id = widget.rowData[DatabaseHelper.columnId];
    ever(_imagePaths, (_) {});
    requestImages(diary_id).then((imagePaths) {
      _imagePaths.addAll(imagePaths);
    });
  }

  @override
  void dispose() {
    imagePickerController.reset(); // 컨트롤러 해제
    super.dispose();
  }

  // 로컬DB에 추가된 글의 이미지를 불러오는 기능
  Future<List<String>> requestImages(int diaryId) async {
    final imagePathsq = await _dbHelper.getDiaryImagePaths(diaryId);
    return imagePathsq;
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light(
              primary: Temas.maincolor, // 헤더 배경색
              onPrimary: Colors.white, // 헤더 텍스트 색상
              onSurface: Colors.black, // 본문 텍스트 색상
            ),
            dialogBackgroundColor:
                Colors.grey[800], // Changes the dialog background color
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
                // Add rounded corners to the dialog
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            // Additional customizations can go here
          ),
          child: TimePickerDialog(
            initialTime: TimeOfDay.now(),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        aramtime = _selectedTime.format(context);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
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
    if (picked != null) {
      setState(() {
        _selectedDate = picked; // Store the selected date
        aramday = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  Future<void> _showRepeatOptionsDialog() async {
    String? selectedOption = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          '반복 옵션 선택',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <String>['반복 안함', '매일', '매주', '매월', '매년']
              .map((String option) => ListTile(
                    title: Text(option),
                    onTap: () {
                      Navigator.pop(context, option); // 팝업 닫고 선택한 옵션 반환
                    },
                  ))
              .toList(),
        ),
      ),
    );

    if (selectedOption != null) {
      // 사용자가 옵션을 선택했을 때만 업데이트
      setState(() {
        _repeatOption =
            selectedOption; // Use the selectedOption, which is non-null
      });
    }
  }

  Future<bool> editPhotosOnLocalDB(List<String> selectedImagePaths,
      List<String> newImagePaths, int diaryId) async {
    bool isDeleted = true;
    SaveImageOnLocalStorage saveLocalStorage = SaveImageOnLocalStorage();
    try {
      // 1. selectedImagePaths에 있는 이미지 경로들을 데이터베이스에서 삭제
      isDeleted = await _dbHelper.deletePhotoPaths(diaryId, selectedImagePaths);

      // 2. selectedImagePaths의 경로의 이미지를 삭제
      if (selectedImagePaths.isNotEmpty) {
        deleteImageFile(selectedImagePaths);
      }
      // 3. newImagePaths의 이미지를 인코딩 > 복사 > 로컬에 저장
      List<XFile> newImageXFiles =
          newImagePaths.map((path) => XFile(path)).toList();
      List<String> imagesPath =
          await saveLocalStorage.saveDiaryImagesToAppDir(newImageXFiles);
      // 4. newImagePaths에 있는 이미지 경로들을 데이터베이스에 추가
      await _dbHelper.updateImagePaths(diaryId, imagesPath);
    } catch (e) {
      print("Error editing photos on local DB: $e");
      isDeleted = false; // 예외 발생 시에도 false로 변경
    }

    return isDeleted;
  }

  @override
  Widget build(BuildContext context) {
    // 컨테이너에서 전달한 데이터를 받습니다.
    return WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => DiaryPage(
                      selectedIndex: 0,
                    )), // Replace 'YourScreen' with the name of your screen class
          );
          return true; // 실제로 뒤로 가기 액션을 중지합니다.
        },
        child: Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize:
                const Size.fromHeight(kToolbarHeight), // AppBar의 기본 높이를 사용
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: Color.fromARGB(255, 240, 240, 240), // 원하는 테두리 색상
                      width: 2 // 원하는 테두리 두께
                      ),
                ),
              ),
              child: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DiaryPage(
                              selectedIndex: 0,
                            )), // Replace 'YourScreen' with the name of your screen class
                  ),
                ),
                title: Text(
                  "${formatDate(widget.rowData[DatabaseHelper.columnUploadDate])}",
                  style: const TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.w600),
                ),
                centerTitle: true,
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                elevation: 0,
                actions: <Widget>[
                  IconButton(
                    onPressed: () async {
                      await edit_data();
                    },
                    icon: _isEditing.value
                        ? const Icon(Icons.check,
                            color: Colors.black) // 수정 상태일 때 완료 아이콘 표시
                        : const Icon(Icons.edit_outlined,
                            color: Colors.black), // 기본 상태일 때 편집 아이콘 표시
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.black),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(30.0),
                          ),
                        ),
                        builder: (BuildContext context) {
                          return SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: ListBody(
                                children: <Widget>[
                                  Center(
                                      child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 20.0),
                                    child: Container(
                                      width: 50,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(12),
                                        ),
                                      ),
                                    ),
                                  )),
                                  GestureDetector(
                                    child: const Padding(
                                      padding: EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          top: 10,
                                          bottom: 20),
                                      child: Text("공유하기",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 15,
                                          )),
                                    ),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      // Get.toNamed('/declaration');
                                    },
                                  ),
                                  const Divider(
                                    color: Colors.grey,
                                    height: 1,
                                    thickness: 1,
                                  ), // 선 추가
                                  GestureDetector(
                                    child: const Padding(
                                      padding: EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          top: 20,
                                          bottom: 20),
                                      child: Text(
                                        "전달하기",
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  const Divider(
                                    color: Colors.grey,
                                    height: 1,
                                    thickness: 1,
                                  ),
                                  GestureDetector(
                                    child: const Padding(
                                      padding: EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          top: 20,
                                          bottom: 20),
                                      child: Text("삭제하기",
                                          style: TextStyle(fontSize: 15)),
                                    ),
                                    onTap: () async {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                              '메모 삭제',
                                              textAlign: TextAlign.center,
                                            ),
                                            content: Text(
                                              '메모를 정말 삭제하시겠습니까?',
                                              textAlign: TextAlign.center,
                                            ),
                                            actions: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    // 첫 번째 버튼을 Expanded로 감싸서 좌측 영역을 균등하게 차지하도록 함
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop(); // Dismiss the dialog and returns false
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 10),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xFF3E7FE0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(25),
                                                        ),
                                                        child: Text(
                                                          '취소',
                                                          textAlign: TextAlign
                                                              .center, // 텍스트 중앙 정렬
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: 10), // 버튼 사이의 간격
                                                  Expanded(
                                                    // 두 번째 버튼을 Expanded로 감싸서 우측 영역을 균등하게 차지하도록 함
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        int id = widget.rowData[
                                                            DatabaseHelper
                                                                .columnId];
                                                        await _dbHelper
                                                            .deleteMemo(id);

                                                        // 모달 창 닫기
                                                        Navigator.of(context)
                                                            .pop();

                                                        if (Get
                                                            .isSnackbarOpen) {
                                                          Get.closeCurrentSnackbar();
                                                        }
                                                        Get.snackbar("메모 삭제",
                                                            "메모가 성공적으로 삭제되었습니다.");
                                                        Get.offNamed('/diary');
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 10),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xFF3E7FE0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(25),
                                                        ),
                                                        child: Text(
                                                          '삭제',
                                                          textAlign: TextAlign
                                                              .center, // 텍스트 중앙 정렬
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),

                                  const Divider(
                                    color: Colors.grey,
                                    height: 1,
                                    thickness: 1,
                                  ),
                                  GestureDetector(
                                    child: const Padding(
                                      padding: EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          top: 20,
                                          bottom: 10),
                                      child: Text("상세설정",
                                          style: TextStyle(fontSize: 15)),
                                    ),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          body: Padding(
            padding:
                EdgeInsets.only(top: 0, left: 16.0, right: 16.0, bottom: 16.0),
            child: ListView(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Obx 외부로 _selectedImagePaths 이동

                Obx(() {
                  final allImagePaths = [
                    ..._imagePaths,
                    ...imagePickerController.newImagesPath
                  ];

                  return Row(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 8.0,
                            crossAxisSpacing: 8.0,
                          ),
                          itemCount: allImagePaths.isEmpty
                              ? 1
                              : allImagePaths.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == allImagePaths.length) {
                              // 마지막 항목이거나 이미지가 없는 경우 추가 버튼 표시
                              return _isEditing.value
                                  ? IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () async {
                                        await imagePickerController
                                            .showPicker(context);
                                      },
                                    )
                                  : Container();
                            } else {
                              final imagePath = allImagePaths[index];
                              final isNewImage = imagePickerController
                                  .newImagesPath
                                  .contains(imagePath);

                              // Obx를 사용하여 isSelectedDeleteImage 상태를 감시하고 즉시 갱신
                              return Obx(() {
                                final isSelectedDeleteImage =
                                    _selectedImagePaths
                                        .contains(imagePath); // 선택 여부 확인

                                if (File(imagePath).existsSync()) {
                                  return Stack(
                                    children: [
                                      Image.file(
                                        File(imagePath),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                      if (_isEditing.value)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Visibility(
                                            visible: isNewImage,
                                            child: GestureDetector(
                                              onTap: () {
                                                imagePickerController
                                                    .newImagesPath
                                                    .remove(imagePath);
                                                imagePickerController
                                                    .selectedImages
                                                    .removeWhere((image) =>
                                                        image.path ==
                                                        imagePath);
                                              },
                                              child: Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.red,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  size: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (_isEditing.value && !isNewImage)
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: GestureDetector(
                                            onTap: () {
                                              // 클릭 시 _selectedImagePaths 리스트에 이미지 경로 추가/삭제
                                              if (isSelectedDeleteImage) {
                                                _selectedImagePaths
                                                    .remove(imagePath); // 선택 해제
                                                print(
                                                    "Removed: $_selectedImagePaths");
                                              } else {
                                                if (!_selectedImagePaths
                                                    .contains(imagePath)) {
                                                  _selectedImagePaths.add(
                                                      imagePath); // 중복 방지 후 추가
                                                  print(
                                                      "Added: $_selectedImagePaths");
                                                }
                                              }
                                            },
                                            child: Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isSelectedDeleteImage
                                                    ? Colors.blue
                                                    : Colors.transparent,
                                                border: Border.all(
                                                    color: Colors.white),
                                              ),
                                              child: isSelectedDeleteImage
                                                  ? const Icon(
                                                      Icons.check,
                                                      size: 16,
                                                      color: Colors.white,
                                                    )
                                                  : null,
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  );
                }),

                Container(
                  margin: const EdgeInsets.only(
                      bottom: 25.0, left: 0.0, right: 0.0, top: 25),
                  color: const Color.fromARGB(255, 189, 189, 189),
                  height: 1.0,
                  width: MediaQuery.of(context).size.width,
                ),
                if (_isEditing.value)
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: "제목",
                      labelStyle: TextStyle(color: Color(0xFF000000)),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                Temas.maincolor), // 포커스를 받았을 때 테두리 색상을 파란색으로 설정
                      ),
                      border: UnderlineInputBorder(),
                    ),
                  )
                else
                  Text("제목: $title", style: const TextStyle(fontSize: 20.0)),
                Container(
                  margin: const EdgeInsets.only(
                      bottom: 20.0, left: 0.0, right: 0.0, top: 20),
                  color: const Color.fromARGB(255, 189, 189, 189),
                  height: 1.0,
                  width: MediaQuery.of(context).size.width,
                ),
                if (_isEditing.value)
                  TextField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      labelText: "내용",
                      labelStyle: TextStyle(color: Color(0xFF000000)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                Temas.maincolor), // 포커스를 받았을 때 테두리 색상을 파란색으로 설정
                      ),
                    ),
                  )
                else
                  Text("내용: $content", style: const TextStyle(fontSize: 20.0)),
                Container(
                  margin: const EdgeInsets.only(
                      bottom: 20.0, left: 0.0, right: 0.0, top: 20),
                  color: const Color.fromARGB(255, 189, 189, 189),
                  height: 1.0,
                  width: MediaQuery.of(context).size.width,
                ),
                Container(
                  margin: const EdgeInsets.only(
                      bottom: 10.0, left: 0.0, right: 0.0, top: 20),
                  color: const Color.fromARGB(255, 189, 189, 189),
                  height: 1.0,
                  width: MediaQuery.of(context).size.width,
                ),
                Row(children: [
                  const Icon(Icons.alarm), // 여기에서 원하는 아이콘으로 변경할 수 있습니다.
                  const SizedBox(width: 5),
                  const Text(
                    '알람 여부',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                      value: _isAlarmSet,
                      activeColor:
                          Colors.blue, // Sets the color when the switch is on
                      activeTrackColor: Colors.blue[
                          200], // Optional: Sets the color of the track when the switch is on
                      inactiveThumbColor: Colors
                          .grey, // Optional: Sets the color of the thumb when the switch is off
                      inactiveTrackColor: Colors.grey[300], // Optiona
                      onChanged: (value) async {
                        setState(() {
                          _isAlarmSet = value;
                        });
                        // 스위치 상태 출력
                        print("스위치 상태: $_isAlarmSet");

                        try {
                          await _dbHelper.updateAlarmSetStatus(
                              widget.rowData[DatabaseHelper.columnId],
                              _isAlarmSet);
                        } catch (e) {
                          print("데이터베이스 업데이트 오류: $e");
                        }
                      }),
                ]),
                const SizedBox(
                  height: 10,
                ),
                Row(children: [
                  const Padding(
                    padding: EdgeInsets.only(
                      right: 5,
                    ),
                    child: Icon(Icons.access_time),
                  ),
                  GestureDetector(
                    onTap: _isEditing.value ? () => _selectDate(context) : null,
                    child:
                        Text("$aramday", style: const TextStyle(fontSize: 18.0)
                            // Add other text styling properties here
                            ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _isEditing.value ? () => _selectTime(context) : null,
                    child:
                        Text("$aramtime", style: const TextStyle(fontSize: 18.0)
                            // Add other text styling properties here
                            ),
                  ),
                ]),
                const SizedBox(
                  height: 20,
                ),
                Row(children: [
                  const Padding(
                    padding: EdgeInsets.only(
                      right: 5,
                    ),
                    child: Icon(Icons.cached),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_isEditing.value) {
                        _showRepeatOptionsDialog(); // 클릭 시 팝업 표시
                      }
                    },
                    child: Text(
                      "반복 옵션: $_repeatOption ",
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  )
                ]),
              ],
            ),
          ),
          bottomNavigationBar: const MyBottomNavigationBar(selectedIndex: 0),
        ));
  }

  Future<void> edit_data() async {
    if (_isEditing.value) {
      title = _titleController.text;
      content = _contentController.text;
      aramtime = _selectedTime.format(context);
      // 데이터 업데이트
      Map<String, dynamic> updatedRow = {
        DatabaseHelper.columnId:
            widget.rowData[DatabaseHelper.columnId], // ID는 변하지 않아야 함
        DatabaseHelper.columnTitle: _titleController.text,
        DatabaseHelper.columnContent: _contentController.text,
        DatabaseHelper.columnRepeatOption: _repeatOption, // 반복 옵션 업데이트
        DatabaseHelper.columnSelectedTime:
            _selectedTime.format(context), // Update the time
        DatabaseHelper.columnSelectedDate:
            DateFormat('yyyy-MM-dd').format(_selectedDate),
        DatabaseHelper.columnTagName:
            widget.rowData[DatabaseHelper.columnTagName],
      };
      await _dbHelper.updateMemo(updatedRow);

      // 체크박스에 체크된 이미지 경로를 이용해서 DB, 로컬파일 삭제 후 인덱스 경로에서 해당 이미지 경로 삭제
      bool isDeleted = await editPhotosOnLocalDB(
          _selectedImagePaths, imagePickerController.newImagesPath, diary_id);

      if (Get.isSnackbarOpen && isDeleted) {
        Get.closeCurrentSnackbar();
      }
      Get.snackbar("업데이트", "수정하신 내용이 저장되었습니다.");
    }
    setState(() {
      _isEditing.value = !_isEditing.value; // 수정 상태 토글
    });
  }
}

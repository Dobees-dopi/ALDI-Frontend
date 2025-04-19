import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:umi/screens/diary_pages/aram.dart';
import 'package:umi/widgets/app_bar/app_bar.dart';
import 'package:umi/screens/diary_pages/diary_localDB/SqlLite/diary_localDB.dart';
import 'package:umi/screens/diary_pages/gather_memo_contaier.dart';
import 'package:umi/widgets/surch_button.dart';//검색 버튼
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umi/golobalkey.dart';
import 'package:umi/screens/diary_pages/memo_container.dart';
import 'package:umi/theme.dart';
import 'package:umi/screens/profiles/GetXController/ProfileController.dart';

class Aram_GatherPage extends StatefulWidget {
  const Aram_GatherPage({Key? key}) : super(key: key);

  @override
  _Aram_GatherPageState createState() => _Aram_GatherPageState();
}

class _Aram_GatherPageState extends State<Aram_GatherPage> {
  late Future<List<Map<String, dynamic>>> _data;
  final ProfileController profileController = Get.find(); // 컨트롤러 인스턴스 가져오기

  // _Aram_GatherPageState 클래스 내에 있는 메서드들을 수정하세요.

  Future<void> _refreshData() async {
    setState(() {
      _data = DatabaseHelper.instance.queryRowsByCreationDateDesc();
    });
  }

  @override
  void initState() {
    super.initState();
    _data = DatabaseHelper.instance.queryRowsByCreationDateDesc();
    printSelectedDateaColumn();
  }

  Future<void> printSelectedDateaColumn() async {
    final dbHelper = DatabaseHelper.instance;
    List<Map<String, dynamic>> allRows =
        await dbHelper.queryAllRows(profileController.selectedProfileId.value);

    // 'selectedDatea' 컬럼의 모든 값을 추출해서 출력
    for (var row in allRows) {
      print(row[DatabaseHelper.columnUploadDate]);
    }
  }

  Future<void> checkAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedValue = prefs.getString('selectedTagName');

    if (storedValue == null || storedValue.isEmpty) {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.snackbar('프로필을 선택해주세요', '프로필을 선택해야 합니다');
    } else {
      // If storedValue is not null and not empty, proceed with the navigation
      Get.toNamed('/memodefault');
    }
  }

  void findAndPrintRows(
      BuildContext context, String title, String content) async {
    final dbHelper = DatabaseHelper.instance;
    List<Map<String, dynamic>> rows =
        await dbHelper.queryRowsByTitleOrContent(title, content);

    if (rows.isNotEmpty) {
      // 검색 결과가 있을 때만 모달 바텀 시트 표시
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min, // 팝업의 크기를 내용에 맞게 조절
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Container(
                  width: 50,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: rows.length,
                  itemBuilder: (BuildContext context, int index) {
                    final row = rows[index];
                    return MyContainer(rowData: row); // 검색 결과 표시
                  },
                ),
              ),
            ],
          );
        },
      );
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.snackbar("검색", "검색 결과가 없습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Get.isSnackbarOpen) {
          Get.closeCurrentSnackbar();
        }
        Get.back();
        return true;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize:
              const Size.fromHeight(kToolbarHeight), // AppBar의 기본 높이를 사용합니다.
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
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => Get.back(),
              ),
              title: const Text(
                '알람 모아보기',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  color: Colors.black,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String searchText = ''; // 검색 텍스트 저장을 위한 변수

                        void handleSearch() {
                          findAndPrintRows(context, searchText, searchText);
                          Navigator.of(context).pop(); // 다이얼로그 닫기
                        }

                        return AlertDialog(
                          title: Text(
                            '검색',
                            textAlign: TextAlign.center,
                          ),
                          content: TextField(
                            autofocus: true, // 자동 포커스 활성화
                            onChanged: (value) {
                              searchText = value;
                            },
                            onSubmitted: (value) =>
                                handleSearch(), // 키보드에서 완료를 누를 때 실행
                            decoration: InputDecoration(
                              hintText: "검색어를 입력하세요",
                              labelStyle:
                                  const TextStyle(color: Color(0xFF000000)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide(color: Temas.maincolor),
                              ),
                            ),
                          ),
                          actions: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => handleSearch(),
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        top: 15,
                                        bottom: 15,
                                        left: 30,
                                        right: 30),
                                    decoration: BoxDecoration(
                                      color: Temas.maincolor,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Text(
                                      '검색',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
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
              ],
              centerTitle: true,
              elevation: 0,
            ),
          ),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _data,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: Padding(
                padding: EdgeInsets.only(right: 30, left: 30, top: 10),
                child: GestureDetector(
                  onTap: () {
                    checkAndNavigate();
                  },
                  child: Container(
                    padding: EdgeInsets.all(20.0),
                    // ... Container 스타일링 ...
                    child: const Text(
                      '알람을 추가해보세요!!',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 22,
                        color: Color(0xFF3E7FE0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ));
            } else {
              // 데이터가 있는 경우
              List<Map<String, dynamic>> data = snapshot.data!;
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> item = data[index];
                  String selectedDateaText = item['SelectedDatea'].toString();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      GatherContainer(rowData: item), // 컨테이너 위젯 사용
                    ],
                  );
                },
              );
            }
          },
        ),
        bottomNavigationBar: const MyBottomNavigationBar(selectedIndex: 0),
      ),
    );
  }
}

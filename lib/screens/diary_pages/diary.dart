import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:umi/widgets/app_bar/app_bar.dart';
import 'package:shake/shake.dart';
import 'package:umi/screens/diary_pages/diary_localDB/SqlLite/diary_localDB.dart';
import 'package:umi/screens/diary_pages/memo_container.dart';
import 'package:umi/screens/diary_pages/diary_menu.dart';
import 'dart:collection';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:umi/theme.dart';
import 'package:umi/widgets/isOnline_Definder.dart';
import 'package:umi/screens/profiles/GetXController/ProfileController.dart';

class DiaryPage extends StatefulWidget {
  final int selectedIndex;

  const DiaryPage({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime selectedDate = DateTime.now();
  bool testBool = false;
  final ConnectivityController controller = Get.find(); // 컨트롤러 가져오기
  int? selectedProfileId;
  Map<DateTime, List> _eventsList = {};
  DateTime temporarySavedSelectedDay = DateTime.now();
  final ProfileController profileController = Get.find(); // 컨트롤러 인스턴스 가져오기

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  final matchingRows = RxList<Map<String, dynamic>>([]);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ShakeDetector? shakeDetector;
  double calendarHeight = 450; // 기본값은 5주일 때의 높이
  int eventCount = 10; // default value 테스트 값 TODO
  int calender_heigh_add = 80; //TODO 추가적인 캐린더 높이

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
                    return MyContainer(rowData: row);
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

// 프로필ID null이 뜨는 오류발생으로 수정중
  void _loadAndPrintAllData() async {
    final dbHelper = DatabaseHelper.instance;

    try {
      List<Map<String, dynamic>> rows = await dbHelper
          .queryAllRows(profileController.selectedProfileId.value);
      // 데이터 카운트를 위해 비워주기
      _eventsList.clear();

      print("Count of records for each unique date (yyyy-MM-dd):");

      Map<String, int> dateCountMap = {};

      for (var row in rows) {
        String? selectedDatea = row['selectedDate'];

        if (selectedDatea != null) {
          DateTime date = DateTime.parse(selectedDatea);
          String formattedDate =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

          if (!dateCountMap.containsKey(formattedDate)) {
            dateCountMap[formattedDate] = 0;
          }

          dateCountMap[formattedDate] = (dateCountMap[formattedDate] ?? 0) + 1;
        }
      }

      final Map<DateTime, List<String>> eventSource = {};

      dateCountMap.forEach((date, count) {
        DateTime parsedDate = DateTime.parse(date);
        List<String> events =
            List.generate(count, (index) => 'Event ${index + 1}');
        eventSource[parsedDate] = events;
      });

      // 기존 데이터를 지우고 새 데이터 추가
      _eventsList.addAll(eventSource);

      dateCountMap.forEach((date, count) {
        print("$date: $count records");
      });

      print("Event Source:");
      print('$eventSource' + '이벤트 소스');

      setState(() {}); // UI 업데이트
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> RequestCalendarDataFromLocalDB() async {
    final dbHelper = DatabaseHelper.instance;
    List<Map<String, dynamic>> newMatchingRows = RxList();
    newMatchingRows = await dbHelper.queryRowsBySelectedDatea(
        temporarySavedSelectedDay,
        profileController.selectedProfileId.value); // .value 사용

    setState(() {
      matchingRows.value = newMatchingRows;
    });
  }

  final Map<DateTime, List<String>> eventSource = {};

  int calculateWeeks(DateTime focusedDay) {
    DateTime firstDayOfCurrentMonth =
        DateTime(focusedDay.year, focusedDay.month, 1);
    DateTime lastDayOfCurrentMonth =
        DateTime(focusedDay.year, focusedDay.month + 1, 0);

    int daysFromPreviousMonth = firstDayOfCurrentMonth.weekday;
    int daysFromNextMonth = lastDayOfCurrentMonth.weekday;
    DateTime firstDayOfNextMonth = lastDayOfCurrentMonth.add(Duration(days: 1));

    int calculatedDay = firstDayOfNextMonth.day + daysFromNextMonth;

    if (calculatedDay > 7) {
      calculatedDay = -(calculatedDay - 14);
    } else {
      calculatedDay = -(calculatedDay - 7);
    }

    if (daysFromPreviousMonth == 7) {
      daysFromPreviousMonth -= 7;
    }

    int juday =
        (lastDayOfCurrentMonth.day + calculatedDay + daysFromPreviousMonth);
    return (juday / 7).ceil();
  }

  @override
  void initState() {
    _focusedDay = DateTime.now(); // or any other initial date you want

    int daysInMonth = getDaysInMonth(_focusedDay);

    DateTime firstDayOfMonth =
        DateTime(DateTime.now().year, DateTime.now().month, 1);
    int firstDayOfWeek = firstDayOfMonth
        .weekday; // This will give you the day of the week (1 = Monday, 7 = Sunday)

    String dayOfWeekName = DateFormat('EEEE').format(
        firstDayOfMonth); // This will give you the name of the day (e.g., "Monday")

    int weeks = ((daysInMonth + firstDayOfWeek - 1) / 7).ceil();

    if (weeks == 5 && firstDayOfWeek == 5) {
      weeks = 6;
    }
    print('Number of weeks in the current month: $weeks');
    print(
        'First day of the current month is: $dayOfWeekName (Day of the week: $firstDayOfWeek)');
    // Adjust calendar height based on the number of weeks
    if (weeks == 4) {
      calendarHeight = 330 + calender_heigh_add.toDouble();
    } else if (weeks == 5) {
      calendarHeight = 380 + calender_heigh_add.toDouble();
    } else if (weeks == 6) {
      calendarHeight = 430 + calender_heigh_add.toDouble();
    }

    shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: () {
        if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
          // endDrawer가 이미 열려 있다면 닫습니다.
          _scaffoldKey.currentState?.openDrawer();
        } else {
          // endDrawer가 닫혀 있다면 엽니다.
          _scaffoldKey.currentState?.openEndDrawer();
        }
      },
    );
    _loadAndPrintAllData();

    RequestCalendarDataFromLocalDB();
    reloadCalendarData();
    super.initState();
  }

  void reloadCalendarData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 200), () {
        _onDaySelected(DateTime.now(), DateTime.now());
      });
    });
  }

  int calculateWeeksBasedOnDays(int days) {
    return (days / 7).ceil();
  }

  int getDaysInMonth(DateTime date) {
    DateTime firstDayNextMonth = (date.month < 12)
        ? new DateTime(date.year, date.month + 1, 1)
        : new DateTime(date.year + 1, 1, 1);
    return firstDayNextMonth.subtract(Duration(days: 1)).day;
  }

  Future<void> checkAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedValue = prefs.getString('selectedTagName');
    Get.toNamed('/memodefault');
    {
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
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    DateTime normalizedSelectedDay =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

    setState(() {
      temporarySavedSelectedDay = normalizedSelectedDay;
      _selectedDay = normalizedSelectedDay;
      _focusedDay = focusedDay;
    });

    print("짧게 클릭한 날짜: $normalizedSelectedDay");

    // final dbHelper = DatabaseHelper.instance;
    // List<Map<String, dynamic>> newMatchingRows =
    //     await dbHelper.queryRowsBySelectedDatea(
    //         normalizedSelectedDay,
    //         selectedProfileId);

    // setState(() {
    //   matchingRows =
    //       newMatchingRows; // 선택한 날짜에 대한 데이터로 matchingRows를 업데이트합니다.
    // });
    RequestCalendarDataFromLocalDB();
  }

  @override
  void dispose() {
    shakeDetector?.stopListening();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _focusedDay, // 초기에 표시할 날짜
      firstDate: DateTime(2010, 10, 16), // 선택 가능한 최초 날짜
      lastDate: DateTime(2030, 3, 14), // 선택 가능한 마지막 날짜
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

    if (picked != null && picked != _focusedDay) {
      setState(() {
        _focusedDay = picked;
        _selectedDay = _focusedDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double appBarHeight = 0.0;

    final _events = LinkedHashMap<DateTime, List>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(_eventsList);

    List getEventForDay(DateTime day) {
      return _events[day] ?? [];
    }

    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed('/home');
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        extendBody: true,
        resizeToAvoidBottomInset: false,
        backgroundColor: Temas.backgroundcolor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color.fromARGB(0, 255, 255, 255),
            elevation: 0,

            // scrolledUnderElevation: 0,
          ),
        ),
        bottomNavigationBar:
            MyBottomNavigationBar(selectedIndex: widget.selectedIndex),
        body: Stack(
          children: [
            Column(
              children: [
                Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      height: _calendarFormat == CalendarFormat.month
                          ? calendarHeight
                          : 140.0 + calender_heigh_add,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Temas.backgroundcolor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(25.0),
                          bottomRight: Radius.circular(25.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 49, 49, 49)
                                .withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 10, // 아래쪽에서 10 픽셀 위에 위치하게 함
                      left: (MediaQuery.of(context).size.width - 50) /
                          2, // 화면 가로의 중앙에 위치하게 함
                      child: Container(
                        width: 50,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 203, 203, 203),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                    child: ListView.builder(
                  itemCount: matchingRows.isEmpty
                      ? 1
                      : matchingRows
                          .length, // 항목이 없으면 1, 있으면 matchingRows의 길이를 사용합니다.
                  itemBuilder: (context, index) {
                    if (matchingRows.isEmpty) {
                      // matchingRows에 항목이 없는 경우
                      return Padding(
                          padding:
                              EdgeInsets.only(right: 30, left: 30, top: 10),
                          child: GestureDetector(
                            onTap: () {
                              checkAndNavigate();
                            },
                            child: Container(
                              padding: EdgeInsets.all(
                                  20.0), // Padding for the text inside the container
                              decoration: BoxDecoration(
                                color: Temas.whitearea,
                            
                                borderRadius: BorderRadius.circular(35.0),
                              
                              ),
                              child: Text(
                                '클릭하여 일정을 추가해보세요',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                  color: Temas.maincolor,
                                ),
                                textAlign: TextAlign
                                    .center, // To center align the text inside the container
                              ),
                            ),
                          ));
                    } else {
                      final row = matchingRows[index];
                      return MyContainer(rowData: row);
                    }
                  },
                )),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Column(
                children: [
                 SizedBox(
                    height: 30,
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        GestureDetector(
                            onVerticalDragEnd: (details) {
                              if (details.primaryVelocity! < 0) {
                                setState(() {
                                  _calendarFormat = CalendarFormat.week;
                                });
                              } else if (details.primaryVelocity! > 0) {
                                setState(() {
                                  _calendarFormat = CalendarFormat.month;
                                });
                              }
                            },
                            child: TableCalendar(
                              locale: 'ko-KR',
                              firstDay: DateTime.utc(2010, 10, 16),
                              lastDay: DateTime.utc(2030, 3, 14),
                              focusedDay: _focusedDay,
                              selectedDayPredicate: (day) =>
                                  isSameDay(_selectedDay, day),
                              calendarFormat: _calendarFormat,
                              availableGestures:
                                  AvailableGestures.horizontalSwipe,
                              headerStyle: const HeaderStyle(
                                formatButtonVisible: false,
                                rightChevronVisible: false,
                                leftChevronVisible: false,
                                headerPadding: EdgeInsets.only(
                                  left: 15,
                                  top: 10,
                                  bottom: 10,
                                ),
                                titleTextStyle: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              eventLoader: getEventForDay,
                              calendarStyle: const CalendarStyle(
                                defaultTextStyle: TextStyle(fontSize: 18),
                                todayDecoration: BoxDecoration(
                                  color: Color(0xFF80A8DA),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              daysOfWeekStyle: const DaysOfWeekStyle(
                                weekdayStyle: TextStyle(fontSize: 16),
                                weekendStyle:
                                    TextStyle(fontSize: 16, color: Colors.blue),
                              ),
                              calendarBuilders: CalendarBuilders(
                                markerBuilder: (context, date, events) {
                                  if (events.isNotEmpty) {
                                    return Positioned(
                                      right: 1,
                                      bottom: 1,
                                      child: _buildEventsMarker(date, events),
                                    );
                                  }
                                },
                              ),

                              daysOfWeekHeight: 25,
                              onPageChanged: (focusedDay) {
                                setState(() {
                                  _focusedDay = focusedDay;
                                });

                                int weeks = calculateWeeks(_focusedDay);
                                if (weeks == 4) {
                                  calendarHeight =
                                      330 + calender_heigh_add.toDouble();
                                } else if (weeks == 5) {
                                  calendarHeight =
                                      380 + calender_heigh_add.toDouble();
                                } else if (weeks == 6) {
                                  calendarHeight =
                                      430 + calender_heigh_add.toDouble();
                                }
                              },

                              onDaySelected: _onDaySelected,

                              //Get.toNamed('/addfeed');

                              formatAnimationDuration:
                                  const Duration(milliseconds: 150),
                              pageAnimationDuration:
                                  const Duration(milliseconds: 150),
                              onDayLongPressed: (DateTime selectedDay,
                                  DateTime focusedDay) async {
                                // Retrieve the value from SharedPreferences
                                final prefs =
                                    await SharedPreferences.getInstance();
                                String? storedValue =
                                    prefs.getString('selectedTagName');

                                // Check if storedValue is empty or null
                                if (storedValue == null ||
                                    storedValue.isEmpty) {
                                  if (Get.isSnackbarOpen) {
                                    Get.closeCurrentSnackbar();
                                  }
                                  Get.snackbar('프로필을 선택해주세요', '프로필을 선택해야 합니다');
                                } else {
                                  // If storedValue is not empty, update selectedDate and navigate
                                  setState(() {
                                    selectedDate = selectedDay;
                                  });
                                  Get.toNamed('/memodefault',
                                      arguments: selectedDay.toString());
                                }
                              },
                            )),
                        Positioned(
                            top: 10, // 적절한 위치 조정이 필요합니다.
                            left: 15,
                            child: GestureDetector(
                                onLongPress: () {
                                  _selectDate(context);
                                },
                                child: Row(children: [
                                  Text(
                                    '2024년 2월',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.transparent),
                                  ),
                                  Icon(
                                    Icons.expand_more,
                                    color: Temas.textcolor,
                                    size: 30.0,
                                  ),
                                ]))),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.search,
                                    color: Temas.maincolor, size: 28.0),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      String searchText =
                                          ''; // 검색 텍스트 저장을 위한 변수

                                      void handleSearch() {
                                        findAndPrintRows(
                                            context, searchText, searchText);
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
                                            labelStyle: TextStyle(
                                                color: Temas.textcolor),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                              borderSide: BorderSide(
                                                  color: Temas.maincolor),
                                            ),
                                          ),
                                        ),
                                        actions: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              GestureDetector(
                                                onTap: () => handleSearch(),
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      top: 12,
                                                      bottom: 12,
                                                      left: 30,
                                                      right: 30),
                                                  decoration: BoxDecoration(
                                                    color: Temas.maincolor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                  ),
                                                  child: Text(
                                                    '검색',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Temas.whittext,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w600),
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
                              IconButton(
                                icon: Icon(
                                  Icons.navigation_outlined,
                                  color: Temas.maincolor,
                                  size: 28.0,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _focusedDay = DateTime.now();
                                    _selectedDay = _focusedDay;
                                  });
                                },
                              ),
                              // const SizedBox(width: 15),  // 간격을 만듭니다.
                              IconButton(
                                icon: Icon(
                                  Icons.notifications_outlined,
                                  color: Temas.maincolor,
                                  size: 28.0,
                                ),
                                onPressed: () {
                                  Get.toNamed('/notification');
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 80,
              right: 14,
              child: Container(
                height: 45.0, // adjust the height
                width: 95.0, // adjust the width
                child: FloatingActionButton.extended(
                    onPressed: () {
                      checkAndNavigate();
                    },
                    icon: Icon(
                      Icons.add,
                      color: Temas.whiticon,
                    ),
                    label: Text(
                      '일정',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Temas.whittext),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(35.0), // adjust the roundness
                    ),
                    backgroundColor: Temas.maincolor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildEventsMarker(DateTime date, List events) {
  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Temas.maincolor, // 마커 색상
    ),
    width: 20, // 마커 크기
    height: 20,
    child: Center(
      child: Text(
        '${events.length}', // 이벤트 개수 표시
        style: TextStyle().copyWith(
            color: Temas.whittext, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ),
  );
}

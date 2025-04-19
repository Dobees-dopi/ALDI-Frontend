import 'package:flutter/material.dart';
import 'package:umi/screens/diary_pages/diary_localDB/SqlLite/diary_localDB.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_plus/share_plus.dart';
import 'package:umi/spalsh_screen/global_config.dart';
import 'package:umi/screens/diary_pages/aram_text_style.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GatherContainer extends StatefulWidget {
  final Map<String, dynamic> rowData;

  GatherContainer({required this.rowData});

  @override
  _GatherContainerState createState() => _GatherContainerState();
}

class _GatherContainerState extends State<GatherContainer> {
  bool _isAlarmSet = false; // Local state for the switch
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  String formatDate(String dateStr) {
    DateTime parsedDate = DateTime.parse(dateStr);
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  }

  @override
  void initState() {
    super.initState();

    // rowData의 값을 통해 스위치의 초기값 설정
    _isAlarmSet = widget.rowData[DatabaseHelper.columnAlarmSet] ==
        1; // 데이터베이스에서 1은 true, 0은 false로 가정
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
        key: ValueKey(widget.rowData[DatabaseHelper.columnId]),
        startActionPane: ActionPane(
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                Share.share(GlobalConfig.shareText);
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.share,
              label: '공유하기',
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) async {
                bool? result = await showDialog(
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
                                  Navigator.of(context).pop(
                                      false); // Dismiss the dialog and returns false
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF3E7FE0),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Text(
                                    '취소',
                                    textAlign: TextAlign.center, // 텍스트 중앙 정렬
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10), // 버튼 사이의 간격
                            Expanded(
                              // 두 번째 버튼을 Expanded로 감싸서 우측 영역을 균등하게 차지하도록 함
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop(
                                      true); // Dismiss the dialog and returns true
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF3E7FE0),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Text(
                                    '삭제',
                                    textAlign: TextAlign.center, // 텍스트 중앙 정렬
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
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: '삭제',
            ),
          ],
        ),
        child: GestureDetector(
            onTap: () {
              // 데이터를 전달하는 코드
              Get.offNamed('/detailmemo', arguments: widget.rowData);
            },
            onLongPress: () async {
              bool? result = await showDialog(
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
                                Navigator.of(context).pop(
                                    false); // Dismiss the dialog and returns false
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: Color(0xFF3E7FE0),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  '취소',
                                  textAlign: TextAlign.center, // 텍스트 중앙 정렬
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10), // 버튼 사이의 간격
                          Expanded(
                            // 두 번째 버튼을 Expanded로 감싸서 우측 영역을 균등하게 차지하도록 함
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop(
                                    true); // Dismiss the dialog and returns true
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: Color(0xFF3E7FE0),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  '삭제',
                                  textAlign: TextAlign.center, // 텍스트 중앙 정렬
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

              if (result == true) {
                int id = widget.rowData[DatabaseHelper.columnId];
                await _dbHelper.deleteMemo(id);

                // 모달 창 닫기
                Navigator.of(context).pop();

                // (옵션) 삭제 완료 후 사용자에게 알림 표시
                Get.snackbar("메모 삭제", "메모가 성공적으로 삭제되었습니다.");
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0, left: 15),
              child: Container(
                padding: const EdgeInsets.only(right: 8, top: 10, left: 13),
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: _isAlarmSet
                      ? const Color.fromARGB(255, 255, 255, 255)
                      : Color.fromARGB(255, 213, 213, 213),
                  border: Border.all(
                    // 테두리 추가
                    color: const Color.fromARGB(255, 232, 232, 232), // 테두리 색상
                    width: 1, // 테두리 두께
                  ),
                  borderRadius: BorderRadius.circular(25.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 3), // 그림자 위치 조정
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 3,
                    ),

                    ExpandableText(
                      text: widget.rowData[DatabaseHelper.columnTitle],
                      textColor: _isAlarmSet
                          ? Colors.black
                          : Colors.grey, // Change color based on _isAlarmSet
                    ),
                    // Text("제목: ${widget.rowData[DatabaseHelper.columnTitle]}",),
                    const SizedBox(
                      height: 2,
                    ),

                    ExpandableText(
                      text: widget.rowData[DatabaseHelper.columnContent],
                      textColor: _isAlarmSet ? Colors.black : Colors.grey,
                    ),

                    //Text("내용: ${widget.rowData[DatabaseHelper.columnContent]}",),

                    Visibility(
                      visible: false,
                      child: Text(
                          "생성 시간: ${widget.rowData[DatabaseHelper.columnCurrentTime]}"),
                    ),
                    Row(children: [
                      Text(
                        "알람시간: ${formatDate(widget.rowData[DatabaseHelper.columnSelectedDate])} ",
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      Text(
                        "${widget.rowData[DatabaseHelper.columnSelectedTime]} ",
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      const Spacer(),
                      Switch(
                        value: _isAlarmSet,
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
                        },
                        activeColor: Color.fromARGB(255, 50, 108,
                            255), // Sets the color when the switch is on
                        activeTrackColor: Colors.blue[
                            200], // Optional: Sets the color of the track when the switch is on
                        inactiveThumbColor: Colors
                            .grey, // Optional: Sets the color of the thumb when the switch is off
                        inactiveTrackColor: Colors.grey[300],
                      ),
                    ]),
                    //  Text("알람 시간: ${widget.rowData[DatabaseHelper.columnSelectedTime]}"),
                    Visibility(
                      visible: false,
                      child: Text(
                          "반복 옵션: ${widget.rowData[DatabaseHelper.columnRepeatOption]}"),
                    ),

                    Visibility(
                      visible: false,
                      child: Text(
                          "해당 글이 있는 날짜: ${widget.rowData[DatabaseHelper.columnUploadDate]}"),
                    )
                    // 나머지 항목들
                  ],
                ),
              ),
            )));
  }
}

class CustomSlidableAction extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  CustomSlidableAction({
    required this.onTap,
    required this.icon,
    required this.label,
    this.backgroundColor = Colors.blue,
    this.iconColor = Colors.white,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(4.0), // 조정 가능한 마진
        padding: EdgeInsets.all(10.0), // 조정 가능한 패딩
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle, // 원형 모양
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: iconColor),
            Text(
              label,
              style: TextStyle(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

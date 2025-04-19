import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class AramContainer extends StatefulWidget {
  final int index;

  AramContainer({Key? key, required this.index}) : super(key: key);

  @override
  _AramContainerState createState() => _AramContainerState();
}

class _AramContainerState extends State<AramContainer> {
  bool _isSwitched = true;
  String get _switchPrefKey => 'switch_value_${widget.index}';

  String memo = '메모';
  String time = "03시 55분";
  String day = "2023년 9월 1일 ";
  String title = "제목";
  String mesage = "내용";
  String selectday = "3:15";

  BoxShadow boxShadow = BoxShadow(
    color: const Color.fromARGB(255, 152, 152, 152).withOpacity(0.3),
    spreadRadius: 1,
    blurRadius: 10,
    offset: const Offset(0, 0),
  );

  @override
  void initState() {
    super.initState();
    _loadSwitchValue();
  }

  _loadSwitchValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSwitched = prefs.getBool(_switchPrefKey) ?? true;
    });
  }

  _saveSwitchValue(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_switchPrefKey, value);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          _saveSwitchValue(_isSwitched);
          Get.back();
          return false;
        },
        child: GestureDetector(
          onTap: () {
            Get.toNamed('/detailmemo', arguments: {
              'memo': memo,
              'time': time,
              'day': day,
              'title': title,
              'message': mesage,
              'isSwitched': _isSwitched,
              'circleColor': Colors.blue,
            });
          },
          child: Container(
            width: double.infinity,
            margin:
                const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
            decoration: BoxDecoration(
              color: _isSwitched
                  ? Colors.white
                  : const Color.fromARGB(255, 235, 235, 235),
              borderRadius: BorderRadius.circular(20),
              boxShadow: _isSwitched ? [boxShadow] : [],
              border: Border.all(
                // 테두리 추가
                color: const Color.fromARGB(255, 230, 230, 230), // 테두리 색상
                width: 1, // 테두리 두께
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 12.5, top: 12.5, right: 12.5, bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            memo,
                            style: TextStyle(
                              fontSize: 16,
                              color: _isSwitched
                                  ? const Color.fromARGB(255, 0, 0, 0)
                                  : const Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        selectday,
                        style: TextStyle(
                          fontSize: 16,
                          color: _isSwitched
                              ? const Color.fromARGB(255, 0, 0, 0)
                              : const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  ExpandableText(text: title),
                  const SizedBox(height: 7),
                  ExpandableText(text: mesage),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.alarm,
                              color: _isSwitched
                                  ? const Color.fromARGB(255, 0, 0, 0)
                                  : const Color.fromARGB(255, 0, 0, 0),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              day + time,
                              style: TextStyle(
                                fontSize: 16,
                                color: _isSwitched
                                    ? const Color.fromARGB(255, 0, 0, 0)
                                    : const Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ],
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: _isSwitched,
                            onChanged: (bool value) {
                              setState(() {
                                _isSwitched = value;
                              });
                              _saveSwitchValue(value);
                            },
                            activeColor: const Color(0xFF3E7FE0),
                            inactiveThumbColor:
                                const Color.fromARGB(255, 86, 86, 86),
                            activeTrackColor: Colors.blue[200],
                            inactiveTrackColor:
                                const Color.fromARGB(255, 220, 220, 220),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final String moreText;

  ExpandableText({
    required this.text,
    this.maxLines = 1,
    this.moreText = " ..더보기",
  });

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isExpanded) {
      return InkWell(
        onTap: _toggleExpanded,
        child: Text(
          widget.text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: _toggleExpanded,
        child: Text(
          widget.text.length > 20
              ? widget.text.substring(0, 20) + widget.moreText
              : widget.text,
          maxLines: widget.maxLines,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
  }
}

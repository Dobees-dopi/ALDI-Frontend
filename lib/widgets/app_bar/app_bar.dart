import 'package:flutter/material.dart';
import 'package:get/get.dart'; // get 패키지를 import 합니다.
//import 'package:umi/screens/comunitiy_page/community.dart';
//import 'package:umi/screens/home_page/home.dart';
//import 'package:umi/screens/map_pages/map.dart';
//import 'package:umi/screens/additional_features_pages/additional.dart';
//import 'package:umi/screens/diary_pages/diary.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:umi/theme.dart';

class MyBottomNavigationBar extends StatefulWidget {
  final int? selectedIndex; // 추가
final Color? backgroundColor; // 새로운 속성 추s

  const MyBottomNavigationBar({Key? key, required this.selectedIndex, this.backgroundColor, })
      : super(key: key); // 수정

  @override
  MyBottomNavigationBarState createState() => MyBottomNavigationBarState();
}

class MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  late int? selectedIndex;

   @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
  }

    void _onItemTapped(int index) {
    if (index != selectedIndex) {
      setState(() {
        selectedIndex = index;
      });
      switch (selectedIndex) {
        case 0:
          if (Get.currentRoute != "/profile") {
            if (Get.isSnackbarOpen) {
              Get.closeCurrentSnackbar();
            }
            Get.offAllNamed('/profile');
          }
          break;

        case 1:
          if (Get.currentRoute != "/diary") {
            if (Get.isSnackbarOpen) {
              Get.closeCurrentSnackbar();
            }
            Get.toNamed('/diary');
          }
          break;
        case 2:
          if (Get.currentRoute != "/settingmain") {
            if (Get.isSnackbarOpen) {
              Get.closeCurrentSnackbar();
            }
            Get.offAllNamed('/settingmain');
          }
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [ 
    Positioned(
      top: 100,
      child: Container(
        height: 100,
        color: const Color.fromARGB(255, 0, 0, 0),
      ),
    ),
     Container(
      height: 65,   
      decoration: BoxDecoration(
       color: widget.backgroundColor ?? Colors.white,
      borderRadius: const BorderRadius.only( 
      topLeft: Radius.circular(25.0),
      topRight: Radius.circular(25.0),
    ),
    boxShadow: widget.backgroundColor == Colors.transparent 
  ? null  // 투명 배경일 경우 그림자 제거
  : [ // 그림자 추가
      BoxShadow(
        color: const Color.fromARGB(195, 178, 178, 178).withOpacity(0.2),
        spreadRadius: 1,
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
    border: Border.all(  // 테두리 추가
    color: const Color.fromARGB(255, 226, 226, 226), // 테두리 색상
    width: 0.5 // 테두리 두께
  ),
  ),
      child: Row(
        children: [
          Expanded(
            child: _buildNavItem(
              0,
              Icons.account_circle_outlined,
              Icons.account_circle,
              '프로필',
              selectedIndex == 0,
            ),
          ),
          Expanded(
            child: _buildNavItem(
              1,
              Icons.book_outlined,
              Icons.book,
              '일정',
              selectedIndex == 1,
            ),
          ),
          Expanded(
            child: _buildNavItem(
              2,
              Icons.settings_outlined,
              Icons.settings,
              '설정',
              selectedIndex == 2,
            ),
          ),
        ],
      ),
    ),
      ],
    );
  }

  Widget _buildNavItem(int index, IconData outlinedIcon, IconData filledIcon, String label, bool isSelected) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        color: Colors.transparent,
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? filledIcon : outlinedIcon,
            color: isSelected ? Temas.maincolor : Colors.black87,
            size: 27,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.inter(  // 이 부분을 수정하여 원하는 폰트를 적용하시면 됩니다.
              textStyle: TextStyle(
                color: isSelected ? Temas.maincolor: Temas.textcolor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      )
    );
}
}

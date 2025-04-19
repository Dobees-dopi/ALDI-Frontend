// diary_icon.dart

import 'package:flutter/material.dart';

class ColorIcons extends StatelessWidget {
  final Function(Color, String) onTap;

  ColorIcons({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _colorButtons(),
    );
  }

  List<Widget> _colorButtons() {
    // 텍스트와 색상을 맵으로 만들어 관리합니다.
    Map<Color, String> colorsAndTexts = {
      Colors.red: "빨강",
      Colors.yellow: "노랑",
      Colors.green: "초록",
      Colors.blue: "파랑",
      Colors.purple: "보라",
      Colors.orange: "주황",
      Colors.brown: "갈색",
      Colors.pink: "분홍",
      Colors.cyan: "청록",
      Colors.grey: "회색",
    };
    return colorsAndTexts.entries.map((entry) {
      return colorButtonWithText(entry.key, onTap, entry.value);
    }).toList();
  }
}

Widget colorButtonWithText(Color color, Function(Color, String) onTapFunction, String buttonText) {
  return InkWell(
    onTap: () => onTapFunction(color, buttonText),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(buttonText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              )
          ),
        ],
      ),
    ),
  );
}

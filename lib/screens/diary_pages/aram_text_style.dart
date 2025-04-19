import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final String moreText;
  final Color textColor; // Add this line

  ExpandableText({
    required this.text,
    this.maxLines = 1,
    this.moreText = " ..더보기",
    required this.textColor, // Add this line
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: widget.textColor,
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: _toggleExpanded,
        child: Text(
          widget.text.length > 17
              ? widget.text.substring(0, 17) + widget.moreText
              : widget.text,
          maxLines: widget.maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: widget.textColor,
          ),
        ),
      );
    }
  }
}
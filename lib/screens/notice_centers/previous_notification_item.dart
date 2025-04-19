import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:umi/screens/notice_centers/detail_notice.dart';

class PreviousNotificationItem extends StatefulWidget {
  final String title;
  final String subtitle;
  final String time;
  final bool hasBottomBorder;

  const PreviousNotificationItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.time,
    this.hasBottomBorder = true,
  }) : super(key: key);

  @override
  _PreviousNotificationItemState createState() => _PreviousNotificationItemState();
}

class _PreviousNotificationItemState extends State<PreviousNotificationItem> {
  bool _isExpanded = false; // 펼쳐진 상태를 추적하는 변수

  void _navigateToDetailPage() {
    Get.to(
      () => NotificationDetailPage(), // 여기에 이동할 페이지 클래스를 지정합니다.
      arguments: {
        'title': widget.title,
        'subtitle': widget.subtitle,
        'time': widget.time,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_isExpanded) {
          _navigateToDetailPage(); // 페이지 이동 함수 호출
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
        padding: const EdgeInsets.only(bottom: 3, right: 20, left: 20, top: 18),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          border: widget.hasBottomBorder
              ? const Border(
                  bottom: BorderSide(
                    color: Colors.black12,
                    width: 0.5,
                  ),
                )
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Left side: Texts
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        widget.time,
                        style: const TextStyle(
                          color: Colors.black38,
                          fontSize: 11.0,
                        ),
                      ),
                    ],
                  ),
                ),
                // Right side: Image icon in a rounded box
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Icon(
                    Icons.image,
                    color: Colors.grey,
                    size: 30,
                  ),
                ),
              ],
            ),
            // Arrow and expanded content
            AnimatedCrossFade(
              firstChild: Container(), // 펼쳐지지 않은 상태
              secondChild: Column(
                children: [
                  const SizedBox(height: 10.0),
                  Text(
                    "This is the additional content that is shown when the item is expanded.",
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300), // 애니메이션 지속 시간
            ),
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded; // 화살표 아이콘 클릭 시 확장/축소 전환
                  });
                },
                child: Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.black45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

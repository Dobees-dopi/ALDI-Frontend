import 'package:flutter/material.dart';

class SearchButton extends StatefulWidget {
  final BuildContext parentContext;

  SearchButton(this.parentContext);

  @override
  SearchButtonState createState() => SearchButtonState();

  void showPopup(BuildContext context) => createState().showPopup(context);
}

class SearchButtonState extends State<SearchButton> {
  List<String> _chipLabels = ['0', '1', '2', '3', '4', '5', '7', '8', '9', '1331313', '32323'];
  final FocusNode _focusNode = FocusNode(); // FocusNode 초기화

  @override
  void dispose() {
    _focusNode.dispose(); // FocusNode 해제
    super.dispose();
  }

  void showPopup(BuildContext context) {
    void _removeChip(int index) {
      if (index >= 0 && index < _chipLabels.length) {
        setState(() {
          _chipLabels.removeAt(index);
        });
      }
    }

    void _removeAllChips() {
      setState(() {
        _chipLabels.clear();
      });
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        // FocusScope.of(context).requestFocus(_focusNode) 이전에 렌더링이 완료되도록 함
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              padding: const EdgeInsets.only(right: 5, left: 5, top: 30, bottom: 5),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Builder(
                builder: (BuildContext context) {
                  // 렌더링 후에 포커스를 요청
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).requestFocus(_focusNode);
                  });

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
           Container(
  alignment: Alignment.center, // 수평 및 수직 기준으로 가운데 정렬
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center, // Row의 자식들이 수평으로 가운데 정렬되도록 설정
    crossAxisAlignment: CrossAxisAlignment.center, // Row의 자식들이 수직으로 가운데 정렬되도록 설정
    children: [
      IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          FocusScope.of(context).unfocus();
          Navigator.pop(context);
        },
      ),
    Expanded(
  child: Padding(
    padding: const EdgeInsets.only(bottom: 15.0), // 아래쪽 여백 추가
    child: TextField(
      focusNode: _focusNode,
      autofocus: true,
      decoration: const InputDecoration(
        labelText: '검색',
        labelStyle: TextStyle(color: Colors.black),
        border: InputBorder.none, // 아래쪽 선을 없앰
        focusedBorder: InputBorder.none, // 포커스 시에도 아래쪽 선이 나타나지 않도록 설정
      ),
    ),
  ),
),


    ],
  ),
)
,
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
                        child: SingleChildScrollView(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start, // 상단 정렬
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(bottom: 10.0),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 235, 235, 235),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            '최근검색',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                            
                                            },
                                            child: const Text(
                                              '모두 삭제',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                         
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),
                              Container(
                                alignment: Alignment.topLeft,
                                height: 100,
                                child: const Padding(
                                  padding: EdgeInsets.only(top: 8.0, left: 13),
                                  child: Text(
                                    '검색결과',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 235, 235, 235),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => showPopup(context),
      child: Text('Show Popup'),
    );
  }
}

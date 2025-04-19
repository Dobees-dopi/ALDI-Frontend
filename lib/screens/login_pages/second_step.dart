import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:umi/golobalkey.dart';
import 'package:umi/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SecondStepDialogContent extends StatefulWidget {
  @override
  _SecondStepDialogContentState createState() => _SecondStepDialogContentState();
}

class _SecondStepDialogContentState extends State<SecondStepDialogContent> {
  @override
  void initState() {
    super.initState();
  }

  final List<String> agreementTexts = [
    '아래 약관에 모두 동의합니다.',
    '서비스이용약관 동의 (필수)',
    '개인정보처리방침 동의 (필수)',
    '커뮤니티 이용규칙 확인 (필수)',
    '광고성 정보 수신 동의 (선택)',
  ];

  List<bool> agreementStates = List<bool>.filled(5, false);
  List<String> errorMessages = List<String>.filled(5, '');

  final List<void Function()> agreementFunctions = [
    // Define functions here for each agreement if needed
    () {},
    () {},
    () {},
    () {},
    () {},
  ];

  bool get isAllChecked {
    for (int i = 1; i < agreementStates.length - 1; i++) {
      if (!agreementStates[i]) {
        return false;
      }
    }
    return true;
  }

  void checkForUncheckedAgreements() {
    bool anyUnchecked = false;
    for (int i = 1; i < agreementTexts.length - 1; i++) {
      if (!agreementStates[i]) {
        anyUnchecked = true;
        setState(() {
          errorMessages[i] = '동의해주세요.';
        });
      } else {
        setState(() {
          errorMessages[i] = '';
        });
      }
    }

    if (!anyUnchecked) {
      if (Globals.userName.isEmpty) {
                  Get.toNamed('/hardwarelogin');
      } else {
        Get.offAllNamed('/hardware');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 20, left: 20, top: 25, bottom: 25),
    
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
       
          Column(
            children: [
              Text(
                '약관동의',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: Colors.black26,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.only(left: 10, right: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          child: Text(
                            agreementTexts[0], // "전체동의" (Select All)
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color.fromARGB(191, 0, 0, 0),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onPressed: agreementFunctions[0],
                        ),
                      ),
                    ),
              Theme(
  data: Theme.of(context).copyWith(
    unselectedWidgetColor: Colors.black26,
    checkboxTheme: CheckboxThemeData(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity(horizontal: -4.0, vertical: -4.0), // Adjusts the size
      side: BorderSide(color: Colors.black45, width: 1.0), // Border color and thickness
    ),
  ),
  child: Checkbox(
    value: agreementStates[0],
    onChanged: (value) {
      setState(() {
        agreementStates[0] = value ?? false;
        for (int i = 1; i < agreementStates.length; i++) {
          agreementStates[i] = agreementStates[0];
        }
      });
    },
    activeColor: Color.fromARGB(255, 255, 1, 1),
  ),
)

                  ],
                ),
              ),
              const SizedBox(height: 10), // Space between the two containers

              // Container for the other agreements
              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                     border: Border.all(
                    color: Colors.black26,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                   padding: const EdgeInsets.only(left: 20, right: 20, top:5, bottom: 5),
                child: Column(
  children: [
    ...List.generate(
      agreementTexts.length - 1,
      (index) => Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child:
      Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min, // Minimize the space used by the Row
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, // Remove default padding
                      minimumSize: Size(0, 0), // Remove minimum size constraints
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Minimize tap target size
                    ),
                    child: Text(
                      agreementTexts[index + 1],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: agreementFunctions[index + 1],
                  ),
                ),
              ),
              Theme(
         data: Theme.of(context).copyWith(
    unselectedWidgetColor: Colors.black26,
    checkboxTheme: CheckboxThemeData(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity(horizontal: -4.0, vertical: -4.0), // Adjusts the size
      side: BorderSide(color: Colors.black45, width: 1.0), // Border color and thickness
    ),
  ),
                child: Checkbox(
                  value: agreementStates[index + 1],
                  onChanged: (value) {
                    setState(() {
                      agreementStates[index + 1] = value ?? false;
                    });
                  },
                  activeColor: Color.fromARGB(255, 255, 1, 1),
                ),
              ),
            ],
          ),
          if (errorMessages[index + 1].isNotEmpty)
            Text(
              errorMessages[index + 1],
              style: const TextStyle(
                color: Color.fromARGB(189, 255, 56, 56),
                fontSize: 10,
              ),
            ),
        ],
      ),
      ),
    ),
  ],
)

              ),
              const SizedBox(height: 20), // Space before the next section
              Text(
                'SNS 계정으로 간편로그인하기',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10), // Space between text and buttons
          Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    // First button
    ElevatedButton(
      onPressed: () {
        checkForUncheckedAgreements();
      },
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(0), // Ensure the button stays circular
        backgroundColor: Colors.blue, // Button color
        minimumSize: Size(45, 45), // Set size of the button
      ),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
      ),
    ),
    // Second button
    ElevatedButton(
      onPressed: () {
        checkForUncheckedAgreements();
      },
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(0),
        backgroundColor: Colors.red,
        minimumSize: Size(45, 45),
      ),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
      ),
    ),
    // Third button
    ElevatedButton(
      onPressed: () {
        checkForUncheckedAgreements();
      },
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(0),
        backgroundColor: Colors.green,
        minimumSize: Size(45, 45),
      ),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
      ),
    ),
  ],
),

              const SizedBox(height: 30), // Space before the final text
              Text(
                '이메일로 회원가입하기',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
                
            ],
          ),
        ],
      ),
    );
  }
}

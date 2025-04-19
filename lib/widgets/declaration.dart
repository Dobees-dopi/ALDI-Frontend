import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

class PhoneNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text.replaceAll('-', '');
    newText = newText.substring(0, min(11, newText.length));

    if (newText.length <= 3) {
      return newValue.copyWith(text: newText);
    } else if (newText.length <= 7) {
      return newValue.copyWith(
        text: newText.substring(0, 3) + '-' + newText.substring(3),
      );
    } else {
      return newValue.copyWith(
        text: newText.substring(0, 3) +
            '-' +
            newText.substring(3, 7) +
            '-' +
            newText.substring(7),
      );
    }
  }
}

class DeclarationPage extends StatefulWidget {
  @override
  _DeclarationPageState createState() => _DeclarationPageState();
}

class _DeclarationPageState extends State<DeclarationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final List<String> _categories = ['사기', '비속어', '금전 요구', '협박', '비허가'];
  String? _selectedCategory;

  bool validatePhoneOrEmail() {
    if (_phoneController.text.isEmpty && _emailController.text.isEmpty) {
      return false;
    }
    return true;
  }

  @override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      if (_phoneController.text.isNotEmpty ||
          _emailController.text.isNotEmpty ||
          _titleController.text.isNotEmpty ||
          _contentController.text.isNotEmpty) {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('주의'),
            content: const Text('작성 중인 내용이 있습니다. 정말로 나가시겠습니까?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('아니오'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('예'),
              ),
            ],
          ),
        ) ?? false; 
      } else {
        return true;
      }
    },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () async {
              if (_phoneController.text.isNotEmpty ||
                  _emailController.text.isNotEmpty ||
                  _titleController.text.isNotEmpty ||
                  _contentController.text.isNotEmpty) {
                final result = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('경고'),
                    content: const Text('작성 중인 내용이 있습니다. 정말로 나가시겠습니까?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('아니오'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('예'),
                      ),
                    ],
                  ),
                );

                if (result ?? false) {
                  Get.back();
                }
              } else {
                Get.back();
              }
            },
          ),
          title: const Text(
            '문의하기',
            style: TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(25.0),
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                  DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('카테고리 선택',
                      style: TextStyle(fontSize: 20,
                        color: Color.fromARGB(255, 106, 106, 106),
                      ),),
                    value: _selectedCategory,
                    items: _categories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          textAlign: TextAlign.left,
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                  ),
                  TextFormField(
                    controller: _phoneController,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      labelText: '전화번호',
                      border: UnderlineInputBorder(),
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(13),
                      PhoneNumberInputFormatter(),
                    ],
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (!validatePhoneOrEmail()) {
                        return '전화번호 또는 이메일을 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.022),
                   TextFormField(
                    controller: _emailController,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      border: UnderlineInputBorder(),
                    ),
                    validator: (value) {
                      if (!validatePhoneOrEmail()) {
                        return '전화번호 또는 이메일을 입력해주세요.';
                      }
                      if (value == null || value.isEmpty) {
                        return null; // it's OK if email is empty
                      }
                      String pattern =
                          r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,3}$';
                      RegExp regExp = RegExp(pattern);
                      if (!regExp.hasMatch(value)) {
                        return '올바른 이메일 형식이 아닙니다';
                      }
                      return null;
                    },
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.022),
                  TextFormField(
                    controller: _titleController,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      labelText: '제목',
                      border: UnderlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '제목을 입력해주세요.';
                      }
                      return null;
                    },
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  TextFormField(
                    controller: _contentController,
                    maxLines: 9,
                    decoration: const InputDecoration(
                      labelText: '신고 내용',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '내용을 입력해주세요.';
                      }
                      return null;
                    },
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                  ElevatedButton(
                    child: const Text('신고',
                      style: TextStyle(fontSize: 20,
                        color: Color.fromARGB(255, 253, 7, 7),),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        print('선택한 카테고리: $_selectedCategory');
                        print('Phone: ${_phoneController.text}');
                        print('Email: ${_emailController.text}');
                        print('Title: ${_titleController.text}');
                        print('Content: ${_contentController.text}');
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) {
                            return const AlertDialog(
                              content: Text('전송되었습니다.'),
                            );
                          },
                        ).then((value) => Get.back());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

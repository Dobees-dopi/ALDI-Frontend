import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:umi/theme.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
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

class InquirePage extends StatefulWidget {
  @override
  _InquirePageState createState() => _InquirePageState();
}

class _InquirePageState extends State<InquirePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final List<String> _categories = ['제품 문의', '투자 문의', '앱 문의', '개발 문의', '기타 문의'];
  String _selectedCategory = '제품 문의';

  bool validatePhoneOrEmail() {
    if (_phoneController.text.isEmpty && _emailController.text.isEmpty) {
      return false;
    }
    return true;
  }


   InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
       filled: true,
 fillColor: Colors.white, // 필드 내부 색상
      contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0), // Increase vertical padding to adjust height
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Temas.maincolor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      labelStyle: const TextStyle(
        color: Colors.black38,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
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
          ) ??
              false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color.fromARGB(255, 240, 240, 240), // Border color
                  width: 2, // Border width
                ),
              ),
            ),
            child: AppBar(
              automaticallyImplyLeading: false,
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
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: const Color.fromARGB(255, 255, 255, 255), // White AppBar background
              elevation: 0,
              centerTitle: true,
            ),
          ),
        ),
        body: Container(
          color: Colors.grey[100], // Gray body background
       
          child: ListView(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child:
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(height:20),

                    Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Padding(
padding: const EdgeInsets.only(left: 10),
    child: Text(
      '문의 카테고리',
      style: TextStyle(fontSize: 15.0,
      fontWeight: FontWeight.w600,
      color: Colors.black54),
    ),
    ),
                      Container(  
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), // 둥근 테두리
        border: Border.all(color: Colors.black12), // 테두리 색상
          color: Colors.white, // 드롭다운 배경색
      ),
    padding: const EdgeInsets.only(right:3), // 드롭다운 내 여백
      child: DropdownButtonHideUnderline( // 기본 언더라인을 숨김
        child: DropdownButton2<String>(
             value: _selectedCategory,
         // icon: const Icon(Icons.arrow_drop_down),
          iconStyleData: const IconStyleData(
            iconSize: 24,
            iconEnabledColor: Colors.black54,
          ),
          style:  TextStyle(
            color: Temas.maincolor,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
          onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                      },
               items: _categories.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            textAlign: TextAlign.left,
                          ),
                        );
                      }).toList(),
        ),
      ),
                  ),]),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _phoneController,
                      maxLines: 1,
                      decoration: _inputDecoration('전화번호'),
                      style: const TextStyle(fontSize: 20),
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
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      maxLines: 1,
                      decoration: _inputDecoration('이메일'),
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
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _titleController,
                      maxLines: 1,
                      decoration: _inputDecoration('제목'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '제목을 입력해주세요.';
                        }
                        return null;
                      },
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _contentController,
                      maxLines: 9,
                      decoration: _inputDecoration('내용'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '내용을 입력해주세요.';
                        }
                        return null;
                      },
                      style: const TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 30),
                   GestureDetector(
              
                onTap: () async {
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
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 110.0, vertical: 10.0),
                  decoration: BoxDecoration(
        color: Temas.maincolor,
              
                    borderRadius: BorderRadius.circular(25.0),
                       boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 0), // 그림자의 위치 조정
          ),
        ],
                  ),
                  child: const Text(
                    '전송',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.w600,
                      fontSize: 15
                    ),
                  ),
                ),
              ),
                         SizedBox(height: 30),
                  ],
                ),
              ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

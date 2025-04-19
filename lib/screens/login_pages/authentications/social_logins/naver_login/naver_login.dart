import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:dio/dio.dart';

final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();

class NaverLoginPage extends StatefulWidget {
  const NaverLoginPage({Key? key}) : super(key: key);
  
  @override
  _NaverLoginPageState createState() => new _NaverLoginPageState();
}

class _NaverLoginPageState extends State<NaverLoginPage> {
List<String> logMessages = [];  // 화면에 표시될 로그 메시지들
String currentUrl = 'http://192.168.0.7:8000/users/naverlogin' ; // To store the current URL
  final TextEditingController _urlController = TextEditingController();

String? inputUrl; // 텍스트 필드에서 입력받은 URL

final _controller = TextEditingController(); // 텍스트 필드 컨트롤러


@override
void initState() {
  super.initState();
      _urlController.text = currentUrl; // 초기 URL 설정
    _urlController.addListener(_updateCurrentUrl); // 값이 바뀔 때마다 리스너 추가
}

  @override
  void dispose() {
    _urlController.dispose(); // 컨트롤러 리소스 해제
    super.dispose();
  }

  _updateCurrentUrl() {
    setState(() {
      currentUrl = _urlController.text;
    });
  }
 void _log(String message) {
    print(message);
    setState(() {
      logMessages.add(message);
    });
  }
  final Dio _dio = Dio();
  bool isLogin = false;
  String? accesToken;
  String? expiresAt;
  String? tokenType;
  String? name;
  String? refreshToken;
  String? email;
  String? gender;
  String? birthday;
  String? age;
  String? birthyear;
  String? mobile;


  void _showSnackError(String error) {
    snackbarKey.currentState?.showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(error.toString()),
      ),
    );
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flutter Naver Login Sample',
          style: TextStyle(color: Colors.white),
        ),
      ),
     
body: ListView(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      children: [
        _buildUserInfoSection(),
        _buildButtonSection(),
        _buildLogMessagesSection(),
      ],
    ),




      
    );
  }

Widget _buildUserInfoSection() {
  return Column(
    children: [
      Text('isLogin: $isLogin\n'),
      Text('accesToken: $accesToken\n'),
      Text('refreshToken: $refreshToken\n'),
      Text('tokenType: $tokenType\n'),
      Text('user: $name\n'),
      Text('email: $email\n'),
      Text('gender: $gender\n'),
      Text('birthday: $birthday\n'),
      Text('age: $age\n'),
      Text('birthyear: $birthyear\n'),
      Text('mobile: $mobile\n'),
    ],
  );
}

Widget _buildButtonSection() {
  return Column(
    children: [
      ElevatedButton(
        onPressed: buttonLoginPressed,
        child: const Text("LogIn"),
      ),
      ElevatedButton(
        onPressed: buttonLogoutPressed,
        child: const Text("LogOut"),
      ),
      ElevatedButton(
        onPressed: buttonLogoutAndDeleteTokenPressed,
        child: const Text("LogOutAndDeleteToken"),
      ),
      ElevatedButton(
        onPressed: buttonTokenPressed,
        child: const Text("GetToken"),
      ),
      ElevatedButton(
        onPressed: buttonGetUserPressed,
        child: const Text("GetUser"),
      ),
      ElevatedButton(
        onPressed: () {
          Get.offAllNamed('/loginsuccess');
        },
        child: const Text("로그인"),
      ),
      ElevatedButton(
  onPressed: buttonDisconnectPressed,
  child: const Text("Disconnect"),
),

      ElevatedButton(
        onPressed: () async {
          await _sendTokensToServer(accesToken!, refreshToken!); // !를 사용하여 null 값이 아님을 확신
        },
        child: const Text("토큰 전송"),
      ),
      Column(
  children: <Widget>[
    // URL을 입력받는 텍스트 필드
    TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: 'URL 입력',
        hintText: 'http://example.com(이거 실제 아님)',
      ),
      onChanged: (value) {
        inputUrl = value; // 텍스트 필드의 값을 inputUrl 변수에 저장
      },
    ),
    SizedBox(height: 20), // 간격 추가
    // 완료 버튼
    ElevatedButton(
      child: Text('완료'),
      onPressed: () {
        setState(() {
          if (inputUrl != null && inputUrl!.isNotEmpty) {
            currentUrl = inputUrl!; // inputUrl 값을 currentUrl에 설정
            _controller.clear(); // 텍스트 필드 내용 지우기
          }
        });
      },
    ),
    SizedBox(height: 20), // 간격 추가
    Text('현재 URL: $currentUrl'), // 현재 설정된 URL 표시
  ],
)
,
    ],
  );
}

Widget _buildLogMessagesSection() {
  return Column(
    children: List.generate(
      logMessages.length,
      (index) => ListTile(
        title: Text(logMessages[index]),
      ),
    ),
  );
}

Future<void> buttonDisconnectPressed() async {
  try {
    await FlutterNaverLogin.logOut();
    setState(() {
      isLogin = false;
      accesToken = null;
      tokenType = null;
      name = null;
    });
    _log("Disconnected Successfully");
  } catch (error) {
    _showSnackError(error.toString());
    _log("Disconnect Error: $error");
  }
}

Future<void> _sendTokensToServer(String accessToken, String refreshToken) async {
    final url = 'https://testapi.cahlp.kr/users/naverlogin';  // URL 업데이트

    try {
      var response = await _dio.post(
        currentUrl,
        data: {
          'access_token': accessToken,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        _log('토큰 전송 성공: ${response.data}');
        _log("Data: ${response?.data}");
        _log("Status Code: ${response?.statusCode}");
      } else {
        _log('토큰 전송 실패: ${response.data}');
        
      }
    } on DioException catch (e) {
      if (e.response != null) {
        _log("Data: ${e.response?.data}");
        _log("Status Code: ${e.response?.statusCode}");
      } else {
        _log("Error message: ${e.message}");
      }
    }
  }

  Future<void> buttonLoginPressed() async {
    try {
      final NaverLoginResult res = await FlutterNaverLogin.logIn();
      setState(() {
        name = res.account.nickname;
        isLogin = true;
      });
      _log("Login Success - Nickname: $name");
      if (accesToken != null && refreshToken != null) {
        await _sendTokensToServer(accesToken!, refreshToken!);
      }
    } catch (error) {
      _showSnackError(error.toString());
     _log("Login Error: $error");
    }
  }

Future<void> buttonTokenPressed() async {
  try {
    final NaverAccessToken res = await FlutterNaverLogin.currentAccessToken;
    setState(() {
      refreshToken = res.refreshToken;
      accesToken = res.accessToken;
      tokenType = res.tokenType;
    });
    _log("Token - RefreshToken: $refreshToken, AccessToken: $accesToken, TokenType: $tokenType");
  } catch (error) {
    _showSnackError(error.toString());
    _log("Token Error: $error");
  }
}

Future<void> buttonLogoutPressed() async {
  try {
    // 서버에 로그아웃 상태를 전송하고 성공 여부를 확인합니다.
    bool logoutSuccess = await _sendLogoutStatusToServer(accesToken);
    
    if (logoutSuccess) {
      await FlutterNaverLogin.logOutAndDeleteToken();
      setState(() {
        isLogin = false;
        accesToken = null;
        tokenType = null;
        name = null;
      });
      _log("Logout Success");
    } else {
      _log("Logout failed after communicating with the server.");
    }
  } catch (error) {
    _showSnackError(error.toString());
    _log("Logout Error: $error");
  }
}

Future<bool> _sendLogoutStatusToServer(String? accessToken) async {
  final url = 'http://192.168.0.11:8000/users/naverlogout'; // 서버 URL로 대체하세요

  try {
    var response = await _dio.post(
      url,
      data: {
        'access_token': accessToken,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      // 서버에서 받은 JSON 응답을 로그에 표시
      _log('서버 응답: ${response.data}');

      _log('서버에 로그아웃 상태 전송 성공');
      return true;
    } else {
      _log('서버에 로그아웃 상태 전송 실패: ${response.data}');
      return false;
    }
  } catch (e) {
    _log('서버에 로그아웃 상태 전송 중 오류 발생: $e');
    return false;
  }
}


Future<void> buttonLogoutAndDeleteTokenPressed() async {
  try {
    await FlutterNaverLogin.logOutAndDeleteToken();
    setState(() {
      isLogin = false;
      accesToken = null;
      tokenType = null;
      name = null;
    });
    print("Logout and Delete Token Success");
  } catch (error) {
    _showSnackError(error.toString());
    print("Logout and Delete Token Error: $error");
  }
}

Future<void> buttonGetUserPressed() async {
  try {
    final NaverAccountResult res = await FlutterNaverLogin.currentAccount();
    setState(() {
      name = res.name;
      email = res.email; // 이메일
      gender = res.gender; // 성별
      birthday = res.birthday; // 생일
      age = res.age; // 연령대
      birthyear = res.birthyear; // 출생년도
      mobile = res.mobile; // 휴대전화번호
    });
   _log("Get User Success - Name: $name, Email: $email, Gender: $gender, Birthday: $birthday, Age: $age, Birthyear: $birthyear, Mobile: $mobile");
  } catch (error) {
    _showSnackError(error.toString());
   _log("Get User Error: $error");
  }
}

}
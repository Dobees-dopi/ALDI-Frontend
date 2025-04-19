import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';

enum LoginPlatform { none, google }

class SampleScreen extends StatefulWidget {
  @override
  _SampleScreenState createState() => _SampleScreenState();
}

class _SampleScreenState extends State<SampleScreen> {
  LoginPlatform _loginPlatform = LoginPlatform.none;
  final Dio _dio = Dio();
String? _googleAccessToken;

  List<String> logMessages = [];  // 화면에 표시될 로그 메시지들

  String currentUrl = 'http://192.168.0.7:8000/users/googlelogin'; 
  final TextEditingController _urlController = TextEditingController();

  String? inputUrl;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _urlController.text = currentUrl;
    _urlController.addListener(_updateCurrentUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
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

  void signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
 _googleAccessToken = googleAuth.accessToken;
      // 바로 받아온 엑세스 토큰을 보여줍니다.
      _showAccessToken(googleAuth.accessToken);

      _log('이름= ${googleUser.displayName}');
      _log('email = ${googleUser.email}');
      _log('id = ${googleUser.id}');
      _log('photo URL = ${googleUser.photoUrl}');

      setState(() {
        _loginPlatform = LoginPlatform.google;
      });

      // 바로 토큰을 서버에 전송합니다.
      _sendTokensToServer(googleAuth.accessToken!);
    }
  }

  void _showAccessToken(String? token) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('받아온 Google Access Token'),
          content: Text(token ?? 'No Access Token'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendTokensToServer(String accessToken) async {
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

  void signOutFromGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    _log('Google 로그아웃 성공');

    setState(() {
        _loginPlatform = LoginPlatform.none;
    });
  }

 _sendLogoutStatusToServer(String? accessToken) async {
    final url = 'http://192.168.0.11:8000/users/googlelogout'; // 서버 URL로 대체하세요

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
  _log('서버에 로그아웃 상태 전송 성공');
 signOutFromGoogle(); // 함수를 호출하는 부분을 수정
  return true;
}else {
        _log('서버에 로그아웃 상태 전송 실패: ${response.data}');
        return false;
      }
    } catch (e) {
      _log('서버에 로그아웃 상태 전송 중 오류 발생: $e');
      return false;
    }
  }

  void disconnectFromGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.disconnect();

    _log('Google 연결 끊기 성공');

    setState(() {
        _loginPlatform = LoginPlatform.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: signInWithGoogle,
              child: const Text('Log in with Google'),
            ),

      ElevatedButton(
  onPressed: () {
    _sendLogoutStatusToServer(_googleAccessToken);
  },
  child: const Text('Google에서 로그아웃'),
),

ElevatedButton(
    onPressed: disconnectFromGoogle,
    child: const Text('Google 연결 끊기'),
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
             Expanded(
                child: ListView.builder(
                  itemCount: logMessages.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(logMessages[index]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

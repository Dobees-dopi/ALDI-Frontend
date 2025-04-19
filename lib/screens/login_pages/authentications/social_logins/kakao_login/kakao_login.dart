import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';


class KakaoLoginPage extends StatefulWidget {
  @override
  _KakaoLoginPageState createState() => _KakaoLoginPageState();
}

class _KakaoLoginPageState extends State<KakaoLoginPage> {
final Dio _dio = Dio();
List<String> logMessages = [];  // 화면에 표시될 로그 메시지들

// List of URLs
final List<String> urls = [
  'http://192.168.0.7:8000/users/kakaologin',
  'https://testapi.cahlp.kr/users/kakaologin',
];

String currentUrl = 'http://192.168.0.11:8000/users/kakaocallback' ; // To store the current URL
  final TextEditingController _urlController = TextEditingController();

String? inputUrl; // 텍스트 필드에서 입력받은 URL

final _controller = TextEditingController(); // 텍스트 필드 컨트롤러


@override
void initState() {
  super.initState();
  currentUrl = urls[0];  // By default, the first URL is selected
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

  Future<void> _sendTokensToServer(String accessToken, String refreshToken) async {
   // final url = 'http://192.168.0.11:8000/users/kakaocallback';  // URL 업데이트

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

Future<void> _loginWithKakao() async {
    OAuthToken token;

    if (await isKakaoTalkInstalled()) {
      try {
        token = await UserApi.instance.loginWithKakaoTalk();
        _log('Access token: ${token.accessToken}');
        _log('Refresh token: ${token.refreshToken}');
        _log('카카오톡으로 로그인 성공');

       if (token. accessToken != null && token. refreshToken != null) {
        await _sendTokensToServer(token. accessToken!, token.refreshToken!);
      }


      } catch (error) {
        _log('카카오톡으로 로그인 실패 $error');
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        await _loginWithKakaoAccount();
      }
    } else {
      await _loginWithKakaoAccount();
    }

    await _getUserInfo();
    await _requestAdditionalScopes();
}


  Future<void> _loginWithKakaoAccount() async {
    try {
      OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
      _log('Access token: ${token.accessToken}');
      _log('Refresh token: ${token.refreshToken}');
      _log('카카오계정으로 로그인 성공');

      // Send tokens to the server
      await _sendTokensToServer(token.accessToken!, token.refreshToken!);



    } catch (error) {
      _log('카카오계정으로 로그인 실패 $error');
    }
  }

  
Future<void> _lognotuomKakao() async {
try {
  await UserApi.instance.logout();
  print('로그아웃 성공, SDK에서 토큰 삭제');
} catch (error) {
  print('로그아웃 실패, SDK에서 토큰 삭제 $error');
}
}

Future<void> _lognoFromKakao() async {
 try {
  await UserApi.instance.unlink();
  _log('연결 끊기 성공, SDK에서 토큰 삭제');
} catch (error) {
  _log('연결 끊기 실패 $error');
}
}
Future<void> someFunction() async {
  TokenManager tokenManager = DefaultTokenManager();
  OAuthToken? storedToken = await tokenManager.getToken(); // token의 이름을 storedToken으로 변경

  if (storedToken != null) {
    final accessToken = storedToken.accessToken;
     _log(accessToken);
    await _sendLogoutStatusToServer(accessToken);
  } else {
    _log('저장된 토큰이 없습니다.');
  }
}



  Future<bool> _sendLogoutStatusToServer(String? accessToken) async {
    final url = 'http://192.168.0.11:8000/users/kakaologout'; // 서버 URL로 대체하세요

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

  Future<void> _getUserInfo() async {
    try {
      User user = await UserApi.instance.me();
      _log('사용자 정보 요청 성공(응답 아님. 기존에 있던것)'
            '\n회원번호: ${user.id}'
          '\n닉네임: ${user.kakaoAccount?.profile?.nickname}'
          '\n이메일: ${user.kakaoAccount?.email}'
          '\n성별: ${user.kakaoAccount?.gender}'
          '\n생일: ${user.kakaoAccount?.birthday}'
          '\n연령대: ${user.kakaoAccount?.ageRange}');
          
    } catch (error) {
      _log('사용자 정보 요청 실패 $error');
    }
  }

  Future<void> _requestAdditionalScopes() async {
    User user;

    try {
      user = await UserApi.instance.me();
    } catch (error) {
      _log('사용자 정보 요청 실패 $error');
      return;
    }

    List<String> scopes = [];

    if (user.kakaoAccount?.emailNeedsAgreement == true) scopes.add('account_email');
    if (user.kakaoAccount?.birthdayNeedsAgreement == true) scopes.add('birthday');
    if (user.kakaoAccount?.genderNeedsAgreement == true) scopes.add('gender');
    if (user.kakaoAccount?.ageRangeNeedsAgreement == true) scopes.add('age_range');
    
    if (scopes.isNotEmpty) {
      try {
        OAuthToken token = await UserApi.instance.loginWithNewScopes(scopes);
        _log('현재 사용자가 동의한 동의 항목: ${token.scopes}');
        await _getUserInfo();
      } catch (error) {
        _log('추가 동의 요청 실패: $error');
      }
    }
  }
Future<void> _checkTokenValidity() async {
  if (await AuthApi.instance.hasToken()) {
    try {
      AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
     _log('토큰 유효성 체크 성공 ${tokenInfo.id} ${tokenInfo.expiresIn}');
      
      // 토큰 정보 조회 부분
      try {
        AccessTokenInfo tokenDetails = await UserApi.instance.accessTokenInfo();
        _log('토큰 정보 보기 성공'
              '\n회원정보: ${tokenDetails.id}'
              '\n만료시간: ${tokenDetails.expiresIn} 초');
      } catch (error) {
        _log('토큰 정보 보기 실패 $error');
      }

    } catch (error) {
      if (error is KakaoException && error.isInvalidTokenError()) {
        _log('토큰 만료 $error');
      } else {
        _log('토큰 정보 조회 실패 $error');
      }

      try {
        OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
       _log('로그인 성공 ${token.accessToken}');
      } catch (error) {
        _log('로그인 실패 $error');
      }
    }
  } else {
   _log('발급된 토큰 없음');
    try {
      OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
      _log('로그인 성공 ${token.accessToken}');
    } catch (error) {
     _log('로그인 실패 $error');
    }
  }
}

@override
Widget build(BuildContext context) {
  return MaterialApp(
    home: Scaffold(
       extendBodyBehindAppBar: true,
      body: 
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30),  // 버튼 사이의 간격
            ElevatedButton(
              onPressed: _loginWithKakao,
              child: const Text('카카오로 로그인'),
            ),
            SizedBox(height: 20),  // 버튼 사이의 간격
            ElevatedButton(
              onPressed: _lognoFromKakao,  // 로그아웃 메서드 연결
              child: const Text('카카오 연결끊기'),
            ),
            SizedBox(height: 20),  // 버튼 사이의 간격
  ElevatedButton(
              onPressed: _checkTokenValidity,
              child: const Text('토큰 유효성 확인'),
            ),
             SizedBox(height: 20),  // 버튼 사이의 간격
             ElevatedButton(
                onPressed: someFunction,
                child: const Text('카카오 로그아웃'),
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
    ),
  );
}


}

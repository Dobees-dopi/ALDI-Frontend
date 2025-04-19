import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:umi/screens/diary_pages/diary.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'screens/diary_pages/aram_data/aram_set.dart';
import 'page_rout.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:umi/widgets/isOnline_Definder.dart';

import 'package:umi/screens/diary_pages/diary_localDB/ProfileDataModel/ProfileDataModel.dart';
import 'package:umi/screens/diary_pages/reusable_utils/singural_pic_picker.dart';
import 'package:umi/screens/diary_pages/reusable_utils/plural_pic_picker.dart';
import 'package:umi/screens/profiles/GetXController/ProfileController.dart';
import 'package:umi/widgets/offline_cover.dart';
import 'package:easy_localization/easy_localization.dart'; // 다국어 패키지 import
import 'package:umi/manage_GetXRoute/routeController.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 초기화
  await AndroidAlarmManager.initialize(); // Android Alarm Manager 초기화
  await EasyLocalization.ensureInitialized(); // easy_localization 초기화


  KakaoSdk.init(
      nativeAppKey: '692b1fcbcecf19be42d4d5753523c380'); // 카카오 SDK 초기화

  final notificationService = NotificationService(); // 알림 서비스 생성
  await notificationService.init(); // 알림 서비스 초기화

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firebase Messaging 설정
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    badge: true,
    alert: true,
    sound: true,
  );

  // GetX 컨트롤러 주입
  Get.put(SelectedProfileController());
  Get.put(ImagePickerController(), permanent: true);
  Get.put(ImagePluralPickerController(), permanent: true);
  Get.put(ConnectivityController(), permanent: true);
  Get.put(ProfileController());
  Get.put(RouteController(), permanent: true);

  print(
      'User granted permission: ${settings.authorizationStatus == AuthorizationStatus.authorized}'); // 권한 확인 로그 출력

  // Android 알림 채널 설정
  var channel = const AndroidNotificationChannel(
    'high_importance_channel', // 채널 ID
    'High Importance Notifications', // 채널 이름
    description: 'This channel is used for important notifications.', // 설명
    importance: Importance.high, // 높은 중요도 설정
  );

  // Flutter 알림 플러그인 설정
  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel); // Android 알림 채널 생성

  // Firebase 메시지를 수신하는 리스너 설정
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    // 푸시 알림 표시
    if (message.notification != null) {
      flutterLocalNotificationsPlugin.show(
          message.hashCode,
          message.notification?.title,
          message.notification?.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher', // 앱 아이콘 설정
            ),
          ));
    }
  });


  // 화면 회전 방향 설정 (세로 고정)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 한국어 날짜 포맷팅 초기화
  await initializeDateFormatting('ko_KR', null);

  // 상태바 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 투명 상태바
      statusBarIconBrightness: Brightness.dark, // 상태바 아이콘 밝기 설정
    ),
  );

  // 앱 실행
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', 'US'), Locale('ko', 'KR')], // 지원하는 언어 설정
      path: 'assets/translations', // 번역 파일 경로
      fallbackLocale: Locale('ko', 'KR'), // 기본 언어 설정 (지원하지 않는 언어일 경우)
      useOnlyLangCode: true, // 국가 코드 무시하고 언어 코드만 사용
      child: MyApp(), // 앱 위젯 실행
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("현재 설정된 언어: ${context.locale}");
    return GetMaterialApp(
        localizationsDelegates:
            context.localizationDelegates, // easy_localization 위젯의 delegates 설정
        supportedLocales: context.supportedLocales, // 지원하는 로케일 설정
        locale: context.locale, // 현재 로케일을 설정하여 디바이스의 언어를 따름
        debugShowCheckedModeBanner: false, // 디버그 배너 비활성화
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue, // 기본 테마 색상 설정
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Color(0xFF3E7FE0), // 커서 색상 설정
          ),
          splashColor: Colors.transparent, // 스플래시 색상 제거
          highlightColor: Colors.transparent, // 강조 색상 제거
          useMaterial3: true, // Material 3 적용
          scaffoldBackgroundColor: Colors.white, // 배경 색상 설정
          dialogBackgroundColor: Colors.white, // 다이얼로그 배경 색상 설정
          appBarTheme: const AppBarTheme(
            scrolledUnderElevation: 0, // 스크롤 시 그림자 제거
            elevation: 0.0, // 앱바 그림자 제거
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(), // 텍스트 입력창 스타일 설정
          ),
        ),
        themeMode: ThemeMode.system, // 시스템 모드에 따라 테마 설정
        initialRoute: '/spalsh', // 초기 화면 라우트 설정
        navigatorObservers: [GetObserver(MiddleWare.observer)],
        initialBinding: BindingsBuilder(() {

        }),
        getPages: [
          GetPage(
            name: '/home',
            page: () => const AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.dark,
              child: DiaryPage(selectedIndex:1), // 홈 화면 설정
            ),
          ),
          ...AppRoutes.routes, // 페이지 라우트 설정
        ],
        transitionDuration: const Duration(milliseconds: 350), // 페이지 전환 시간 설정
        defaultTransition: Transition.noTransition, // 기본 페이지 전환 효과 없음

        //오프라인 감지하여 화면 가리기
        builder: (context, child) {
          final ConnectivityController connectivityController = Get.find();
          final routeController = Get.find<RouteController>();

          return Obx(() {
            // Obx 또는 GetBuilder로 감싸기
            if (routeController.currentRoute.value == '/diary') {
              return child!;
            }

            if (!connectivityController.isOnline.value) {
              return routeController.currentPageIsHome.value
                  ? Stack(
                      children: [
                        child!,
                        const OfflineOverlay(),
                      ],
                    )
                  : child!;
            }

            return child!;
          });
        });
  }
}

class MiddleWare {
  static observer(Routing? routing) {
    final routeController = Get.find<RouteController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      routeController.currentRoute.value = Get.routing.current;

      routeController.currentPageIsHome.value =
          Get.routing.current != '/spalsh';

      print(
          'Current route in MiddleWare: ${routeController.currentPageIsHome.value}');
    });
  }
}

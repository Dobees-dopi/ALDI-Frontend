import 'package:get/get.dart';

import 'package:umi/screens/additional_features_pages/additional_conduct.dart';
import 'package:umi/screens/commit_pages/commit.dart';

//다이어리
import 'package:umi/screens/diary_pages/diary.dart';
import 'package:umi/screens/diary_pages/add_diary_data.dart';
import 'package:umi/screens/diary_pages/aram_gather.dart';

import 'package:umi/screens/profiles/profile.dart';


import 'package:umi/screens/notice_centers/notice_centers.dart';



import 'package:umi/screens/login_pages/authentications/join.dart';
import 'package:umi/screens/login_pages/authentications/login.dart';
// ...다른 페이지들에 대한 임포트...
import 'package:umi/screens/settings/setting_main.dart';

import 'package:umi/spalsh_screen/splash.dart'; //첫 로딩 화면
//로그인화면
import 'package:umi/screens/login_pages/first_step.dart';
import 'package:umi/screens/login_pages/login_faild.dart';
import 'package:umi/screens/login_pages/login_success.dart';
import 'package:umi/screens/login_pages/user_imformatin.dart';
import 'package:umi/screens/login_pages/inquire.dart';
//소셜 로그인
import 'package:umi/screens/login_pages/authentications/social_logins/google_login/google_login.dart';
import 'package:umi/screens/login_pages/authentications/social_logins/kakao_login/kakao_login.dart';
import 'package:umi/screens/login_pages/authentications/social_logins/naver_login/naver_login.dart';

import 'package:umi/widgets/declaration.dart'; //신고하기
import 'package:umi/screens/diary_pages/editing_diary_detail.dart';

import 'package:umi/screens/login_pages/authentications/pass_resat.dart';
import 'package:umi/screens/profiles/aquarium_profiles/profile_add_don_t_use.dart';
import 'package:umi/screens/profiles/aquarium_profiles/profile_update.dart';


import 'screens/licensess/licenses.dart';


class AppRoutes {
  static final List<GetPage> routes = [
    GetPage(
      name: '/spalsh',
      page: () => Splash(),
    ),
    GetPage(
      name: '/diary',
      page: () => const DiaryPage(selectedIndex: 1),
    ),

    GetPage(
      name: '/commit',
      page: () => const CommitPage(),
    ),

    GetPage(
      name: '/notification',
      page: () => const NoticePage(), //알림
    ),

    GetPage(
      name: '/additionalcon',
      page: () => const Additional(), //더보기 수정
    ),
    GetPage(
      name: '/settingmain',
      page: () => SettingmainPage(selectedIndex: 2), //설정
    ),
    GetPage(
      name: '/memodefault',
      page: () => const MemoDefaultPage(selectedIndex: 1),
    ),
    //첫 세팅 및 로그인 화면
    GetPage(
      name: '/firststep',
      page: () => const FirstStepPage(),
    ),
    GetPage(
      name: '/loginfaild',
      page: () => const LoginFaildPage(), //로그인 실패
    ),
    GetPage(
      name: '/loginsuccess',
      page: () => const LoginSuccess(), //로그인 성공
    ),
    GetPage(
      name: '/userinformation',
      page: () => const UserInformation(), //유저 정보
    ),
    GetPage(
      name: '/googlelogin',
      page: () => SampleScreen(), //구글 로그인
    ),
    GetPage(
      name: '/kakaologin',
      page: () => KakaoLoginPage(), //카카오 로그인
    ),
    GetPage(
      name: '/naverlogin',
      page: () => const NaverLoginPage(), //네이버 로그인
    ),

    GetPage(
      name: '/inquire',
      page: () => InquirePage(), //문의
    ),
    GetPage(
      name: '/allarams',
      page: () => const Aram_GatherPage(), //
    ),
    GetPage(
      name: '/profile',
      page: () => const CommunityProfilePage(selectedIndex: 0), //
    ),
    GetPage(
      name: '/declaration',
      page: () => DeclarationPage(), //
    ),
    GetPage(
      name: '/detailmemo',
      page: () => DetailMemo(), //
    ),


    GetPage(
      name: '/hardwarelogin',
      page: () => HarwareLoginPage(), //
    ),
    GetPage(
      name: '/hardwarejoin',
      page: () => HardwareJoinPage(), //
    ),
    GetPage(
      name: '/passreset',
      page: () => PassResetPage(), //
    ),

    GetPage(
      name: '/profiladde',
      page: () => ProfileAddScreen(), //
    ),
    GetPage(
      name: '/profilup',
      page: () => ProfileupScreen(), //
    ),

    GetPage(
      name: '/licenses',
      page: () => OssLicensesPage(),
    ),
  ];
// ...다른 라우트들...
}

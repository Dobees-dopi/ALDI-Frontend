import 'package:get/get.dart';

class RouteController extends GetxController {
  var currentRoute = ''.obs;
  var currentPageIsHome = false.obs; // 현재 페이지가 '/home'인지 여부
}

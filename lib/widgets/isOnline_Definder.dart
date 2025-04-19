import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

abstract class ConnectivityObserver {
  Stream<bool> observe();
}

class NetworkConnectivityObserver implements ConnectivityObserver {
  bool isOnline = true;
  final _connectivity = Connectivity();
  Connectivity get connectivity => _connectivity;

  @override
  Stream<bool> observe() {
    return _connectivity.onConnectivityChanged.map((event) {
      if (event.contains(ConnectivityResult.wifi) ||
          event.contains(ConnectivityResult.ethernet) ||
          event.contains(ConnectivityResult.mobile)) {
        return isOnline = true; // 온라인 상태
      } else {
        return isOnline = false; // 오프라인 상태
      }
    });
  }
}

class ConnectivityController extends GetxController {
  final NetworkConnectivityObserver _networkConnectivityObserver =
      NetworkConnectivityObserver();

  var isOnline = false.obs; // Observable boolean

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    observe().listen((isOnlineStatus) {
      if (isOnline.value != isOnlineStatus) {
        isOnline.value = isOnlineStatus;
        if (isOnlineStatus) {
          debugPrint('온라인 테스트');
        }
      }
    });
  }

  Stream<bool> observe() {
    return _networkConnectivityObserver.observe();
  }
}


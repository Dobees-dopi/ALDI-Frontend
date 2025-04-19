import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherButton extends StatefulWidget {
  @override
  _WeatherButtonState createState() => _WeatherButtonState();
}

class _WeatherButtonState extends State<WeatherButton> {
  Future<Map?>? _weatherData;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

 _loadSavedWeatherData() async {
  final prefs = await SharedPreferences.getInstance();
  String? savedData = prefs.getString('weatherData');

  if (savedData != null) {
    return json.decode(savedData);
  }
  return null;
}

_loadWeather({bool forceRefresh = false}) async {
  if (!forceRefresh) {
    Map? savedData = await _loadSavedWeatherData();
    if (savedData != null) {
      setState(() {
        _weatherData = Future.value(savedData);
      });
      return;
    }
  }

  Position? position = await getCurrentLocation();
  if (position != null) {
    setState(() {
      _weatherData = fetchWeather(position.latitude, position.longitude);
    });
  }
}



  _saveWeatherData(Map weatherData) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('weatherData', json.encode(weatherData));
    print("Saved Weather Data: $weatherData");
  }

  Future<Map?> _loadWeatherDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    var savedWeatherData = prefs.getString('weatherData');
    if (savedWeatherData != null) {
      return json.decode(savedWeatherData);
    }
    return null;
  }

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('위치 서비스가 사용 중지되었습니다.');
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      print('위치 권한이 영구적으로 거부되었습니다.');
      return null;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        print('위치 권한이 거부되었습니다.');
        return null;
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<Map?> fetchWeather(double lat, double lon) async {
    final apiKey = '6ebbfae9b6e8c75d75f32f06c4cd19ec'; // 여기에 OpenWeatherMap API 키를 입력하세요.
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=kr'));

    if (response.statusCode == 200) {
  Map? jsonData = json.decode(response.body);
  print(jsonData);

  if (jsonData != null) {
    _saveWeatherData(jsonData);  // null 체크 후에 저장
  }

  return jsonData;
} else {
  print('날씨 로딩 실패');
  return null;
}

  }

  @override
Widget build(BuildContext context) {
  return Stack(
    children: [

      FutureBuilder<Map?>(
        future: _weatherData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Lottie.asset('assets/animations/lizard.json', width: 50, height: 50),
            );
          } else if (snapshot.hasError) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.red[200],
              child: Text("오류: ${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox.shrink();
          } else {
            var description = snapshot.data!['weather'][0]['description'];
            var temp = snapshot.data!['main']['temp'].toString();
            var humidity = snapshot.data!['main']['humidity'].toString();
            var feelslike = snapshot.data!['main']['feels_like'].toString();
            var cityName = snapshot.data!['name'];
            var iconId = snapshot.data!['weather'][0]['icon'];
            var iconUrl = 'http://openweathermap.org/img/w/$iconId.png';

            return Container(
              padding: const EdgeInsets.only(top: 10, bottom: 15, left: 15, right: 15),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 214, 235, 255),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color.fromARGB(255, 233, 233, 233), width: 1),
      boxShadow: [
        BoxShadow(
          color: const Color.fromARGB(255, 202, 202, 202).withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 3,
          offset: const Offset(0, 4),  // x와 y 축의 그림자 위치
        ),
      ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('$cityName',
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(iconUrl, width: 50, height: 50),
                          const SizedBox(height: 10),
                          Text('$description',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16
                          ),),
                        ],
                      )
                    ],
                  ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('현재 온도: $temp°C', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          Text('체감 온도: $feelslike°C',style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          Text('습도: $humidity%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                   
                ],
              ),
            );
          }
        },
      ),
      
      Positioned(
       top: 10,
        right: 0,
        child: ElevatedButton(
  onPressed: () {
    _loadWeather(forceRefresh: true);
  },
  style: ButtonStyle(
    fixedSize: MaterialStateProperty.all<Size>(const Size(30, 30)), // 버튼의 크기를 50x50으로 변경
    shape: MaterialStateProperty.all<CircleBorder>(
      const CircleBorder()
    ),
    padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(0)), // 패딩을 0으로 설정하여 아이콘을 중앙에 위치시킴
  ),
  child: const Icon(Icons.refresh, color: Color.fromARGB(255, 49, 118, 255)),
)

      ),
    ],
  );
}

}

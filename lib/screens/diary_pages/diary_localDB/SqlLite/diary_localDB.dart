import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
//알람
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:umi/screens/diary_pages/diary_localDB/saveImageOnLocalStorage/deleteImageOnLocalStorage.dart';

class DatabaseHelper {
  static const databaseName = "MyDatabase.db";
  static const _databaseVersion = 7;

  static const table = 'diary_table';

  static const columnId = '_id';
  static const columnTitle = 'title';
  static const columnContent = 'content';
  static const columnAlarmSet = 'alarmSet';
  static const columnCurrentTime = 'currentTime';
  static const columnSelectedDate = 'selectedDate';
  static const columnSelectedTime = 'selectedTime';
  static const columnRepeatOption = 'repeatOption';
  static const columnIconText = 'iconText';
  static const columnUploadDate = 'uploadDate';
  static const columnTagName = 'tagName';
  static const columnTagImageUrl = 'tagImageUrl';
  static const columnImagesPath = 'photoPath';
  static const columnProfileId = 'profileId';
// DatabaseHelper 클래스 내부에 추가하세요.

  Future<List<Map<String, dynamic>>> queryRowsByTitleOrContent(
      String title, String content) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db.query(
      table,
      where: '$columnTitle = ? OR $columnContent = ?',
      whereArgs: [title, content],
    );

    return results;
  } //검색

  Future<List<Map<String, dynamic>>> queryRowsBySelectedDatea(
      DateTime selectedDate, int? selectedProfileId) async {
    Database db = await instance.database;

    // selectedProfileId가 null이 아닌 경우에만 where 조건에 추가
    String whereClause = 'DATE($columnUploadDate) = DATE(?)';
    List<dynamic> query_Where = [selectedDate.toIso8601String()];

    if (selectedProfileId != null) {
      whereClause += ' AND profileId = ?';
      query_Where.add(selectedProfileId);
    }

    List<Map<String, dynamic>> matchingRows =
        await db.query(table, where: whereClause, whereArgs: query_Where);

    return matchingRows;
  }

  Future<List<Map<String, dynamic>>> queryRowsByMonth(DateTime month) async {
    Database db = await instance.database;
    int year = month.year;
    int monthNumber = month.month;

    List<Map<String, dynamic>> allRows = await db.query(table);

    List<Map<String, dynamic>> matchingRows = allRows.where((row) {
      DateTime rowDate = DateTime.parse(row[columnUploadDate]);
      return rowDate.year == year && rowDate.month == monthNumber;
    }).toList();

    return matchingRows;
  }

  Future<int> updateMemo(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // DatabaseHelper 클래스 내에 추가하세요.
  Future<List<Map<String, dynamic>>> queryRowsByCreationDateDesc() async {
    Database db = await instance.database;
    return await db.query(table,
        orderBy: "$columnSelectedDate ASC, $columnSelectedTime ASC");
  }

  Future<int> updateAlarmSetStatus(int id, bool alarmSetStatus) async {
    final db = await database;
    final int newValue = alarmSetStatus ? 1 : 0;
    return await db.update(
      table,
      {columnAlarmSet: newValue},
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteMemo(int id) async {
    //삭제
    Database db = await instance.database;
    return await db.delete(
      table, // 'my_table' 대신 table 상수 사용
      where: '$columnId = ?', // 'id' 대신 columnId 상수 사용
      whereArgs: [id],
    );
  }

  // DatabaseHelper 클래스를 싱글톤으로 만들기 위한 생성자
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // SQLite 데이터베이스에 대한 참조를 유지
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // 데이터베이스를 열고 경로를 반환하는 메서드
  // 데이터베이스를 열고 초기화하는 메서드
  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'umiDB.db'); // 데이터베이스 경로 설정

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onOpen: (db) {
        // 데이터베이스가 열릴 때 외래 키 설정
        db.execute('PRAGMA foreign_keys = ON;');
      },
    );
  }

// 데이터베이스가 처음 생성될 때 호출되는 콜백
  Future<void> _onCreate(Database db, int version) async {
    try {
      // 프로필 테이블 생성 - 다른 테이블에서 참조되므로 가장 먼저 생성
      await db.execute('''
      CREATE TABLE profile_add (
        profile_id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_name TEXT,
        location TEXT,
        big_category TEXT,
        small_category TEXT,
        profileImages TEXT,
        userid TEXT
      )
    ''');

      // 메모 테이블 생성
      await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnTitle TEXT NOT NULL,
        $columnContent TEXT NOT NULL,
        $columnAlarmSet INTEGER NOT NULL,
        $columnCurrentTime TEXT NOT NULL,
        $columnSelectedDate TEXT NOT NULL,
        $columnSelectedTime TEXT NOT NULL,
        $columnRepeatOption TEXT NOT NULL,
        $columnIconText TEXT NOT NULL,
        $columnUploadDate TEXT NOT NULL,
        $columnTagName TEXT,
        $columnTagImageUrl TEXT,
        profileId INTEGER,
        FOREIGN KEY (profileId) REFERENCES profile_add(profile_id) ON DELETE CASCADE
      )
    ''');

      // 다이어리 이미지 테이블 생성
      await db.execute('''
      CREATE TABLE diaryImages (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        diaryId INTEGER,
        $columnImagesPath TEXT,
        profileId INTEGER,
        FOREIGN KEY (diaryId) REFERENCES $table($columnId),
        FOREIGN KEY (profileId) REFERENCES profile_add(profile_id) ON DELETE CASCADE
      )
    ''');
      // 마지막으로 선택한 프로필
      await db.execute('''
        CREATE TABLE lastUsedProfile (
        profileName TEXT,
        $columnImagesPath TEXT,
        profile_id INTEGER
  )
''');

      print('Tables created successfully');
    } catch (e) {
      print('Error during table creation: $e');
    }
  }

  // UseCase
  // 1. 다이어리에서 수정버튼을 눌러서 체크박스로 체크를 한 사진을 삭제하는 기능
  Future<bool> deletePhotoPaths(
      int diaryId, List<String> selectedPhotos) async {
    final db = await instance.database;
    for (String imagePath in selectedPhotos) {
      await db.delete(
        'diaryImages',
        where: '$columnImagesPath = ? AND diaryId = ?',
        whereArgs: [imagePath, diaryId],
      );
    }
    bool isDeleted = await deleteImageFile(selectedPhotos);
    return isDeleted;
  }

  // 새로운 행을 테이블에 삽입하는 메서드
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // 프로필ID를 취득해서 데이터를 달력에 표시
  Future<List<Map<String, dynamic>>> queryAllRows(int? profileId) async {
    print('$profileId' + 'DB에서 받는 프로필아이디');
    Database db = await instance.database;

    // 필터링이 필요 없는 경우
    if (profileId == null) {
      return await db.query(table);
    }

    // profileId로 필터링된 쿼리
    return await db.query(
      table,
      where: 'profileId = ?', // 'profileId' 컬럼에서 profileId와 같은 값을 찾습니다.
      whereArgs: [profileId], // where 절에서 사용할 값
    );
  }

  // 다이어리 수정 메서드에서 체크된 이미지 삭제
  Future<int> deleteImagePhotoPaths(
      List<String> selectedImagePaths, int diaryId) async {
    final db = await DatabaseHelper.instance.database;
    if (selectedImagePaths.isEmpty) {
      return 0; // 삭제할 이미지 경로가 없으면 0 반환
    }

    try {
      // WHERE 절 조건 문자열 생성
      final whereClause =
          '${DatabaseHelper.columnImagesPath} IN (${List.filled(selectedImagePaths.length, '?').join(', ')}) AND diaryId = ?';

      // whereArgs 리스트 생성
      final whereArgs = [...selectedImagePaths, diaryId];

      // 삭제 쿼리 실행
      return await db.delete(
        'diaryImages',
        where: whereClause,
        whereArgs: whereArgs,
      );
    } catch (e) {
      print('Error deleting image paths: $e');
      return 0; // 오류 발생 시 0 반환
    }
  }

  // 다이어리 수정 페이지에서 사진을 추가하는 기능
  Future<int> updateImagePaths(int diaryId, List<String> imagepaths) async {
    final db = await DatabaseHelper.instance.database;
    int result = 0; // 추가된 레코드 수를 추적하기 위한 변수

    try {
      for (String path in imagepaths) {
        // 각 이미지 경로를 테이블에 삽입
        await db.insert(
          'diaryImages', // 테이블 이름
          {
            'diaryId': diaryId, // 다이어리 ID
            'photoPath': path, // 이미지 경로
            // 필요하다면 추가 컬럼 값들 추가
          },
          conflictAlgorithm: ConflictAlgorithm.replace, // 충돌 시 기존 데이터 덮어쓰기
        );
        result++;
      }
    } catch (e) {
      print('Error inserting image paths: $e');
    }

    return result; // 추가된 레코드 수 반환
  }

  // 다이어리 기능의 추가된 글의 이미지를 불러오는 기능
  Future<List<String>> getDiaryImagePaths(int? diaryId) async {
    final db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.query('diaryImages',
        columns: ['photoPath'], // 필요한 컬럼만 선택 (여기서는 이미지 경로)
        where: 'diaryId = ?',
        whereArgs: [diaryId]);

    return List.generate(maps.length, (i) {
      return maps[i]['photoPath'];
    });
  }
}

Future<void> saveDiaryDataWithPhotos(
    {required BuildContext context,
    required String title,
    required String content,
    required bool alarmSet,
    required DateTime currentTime,
    required DateTime selectedDate,
    required TimeOfDay selectedTime,
    required String repeatOption,
    required String iconText,
    required String uploadDate,
    required String tagName,
    required String tagImageUrl,
    required List<String> photoPaths,
    required int? profileId}) async {
  final db = await DatabaseHelper.instance.database;

  // Start a transaction
  await db.transaction((txn) async {
    // Insert diary entry
    final diaryId = await txn.insert(DatabaseHelper.table, {
      DatabaseHelper.columnTitle: title,
      DatabaseHelper.columnContent: content,
      DatabaseHelper.columnAlarmSet: alarmSet ? 1 : 0,
      DatabaseHelper.columnCurrentTime: currentTime.toIso8601String(),
      DatabaseHelper.columnSelectedDate: selectedDate.toIso8601String(),
      DatabaseHelper.columnSelectedTime: selectedTime.format(context),
      DatabaseHelper.columnRepeatOption: repeatOption,
      DatabaseHelper.columnIconText: iconText,
      DatabaseHelper.columnUploadDate: uploadDate,
      DatabaseHelper.columnTagName: tagName,
      DatabaseHelper.columnTagImageUrl: tagImageUrl,
      DatabaseHelper.columnProfileId: profileId
    });

    // Insert photos
    for (var photoPath in photoPaths) {
      await txn.insert(
        'diaryImages',
        {
          'diaryId': diaryId, // Use the foreign key reference
          DatabaseHelper.columnImagesPath:
              photoPath, // Ensure this column exists and matches
          'profileId': profileId, // 현재 활성화된 프로필의 ID 추가
        },
      );
    }
  });

  if (alarmSet) {
    scheduleAlarm(selectedDate, selectedTime, context);
    print('Alarm scheduled');
  }
}

const platform = MethodChannel('com.example.app/alarm');

Future<void> showFullScreenAlarm() async {
  try {
    await platform.invokeMethod('showFullScreenAlarm');
  } on PlatformException catch (e) {
    print("Failed to show full screen alarm: '${e.message}'.");
  }
}

void backgroundTask() {
  // 로컬 알림 초기화
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid =
      const AndroidInitializationSettings('app_icon');
  var initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // 여기서 알림을 표시하는 로직을 구현하세요.
  _showNotification(flutterLocalNotificationsPlugin);
}

Future<void> _showNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'your_channel_id', 'your_channel_name',
      importance: Importance.max, priority: Priority.high);
  var platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
      0, '알람 제목', '알람 내용', platformChannelSpecifics);
}

Future<void> scheduleAlarm(
    DateTime selectedDate, TimeOfDay selectedTime, BuildContext context) async {
  final DateTime alarmDateTime = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    selectedTime.hour,
    selectedTime.minute,
  );
  print("$alarmDateTime");

  if (await Permission.scheduleExactAlarm.request().isGranted) {
    // 권한이 부여된 경우 알람 예약
    await AndroidAlarmManager.oneShotAt(
      alarmDateTime,
      0,
      backgroundTask,
      exact: true,
      wakeup: true,
    );
    print('Alarm scheduled');
  } else {
    // 권한이 거부된 경우 사용자에게 안내 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('정확한 알람 예약을 위해 권한이 필요합니다.')),
    );
  }
}

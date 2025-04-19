import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:umi/screens/diary_pages/diary_localDB/saveImageOnLocalStorage/deleteImageOnLocalStorage.dart';
import 'package:umi/screens/diary_pages/diary_localDB/SqlLite/diary_localDB.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // 프로필 로컬DB 생성
  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'umiDB.db');

    return await openDatabase(
      dbPath,
      version: 2,
    );
  }

  // 프로필 추가
  Future<void> insertProfile(Map<String, dynamic> profile) async {
    final db = await database;
    await db.insert('profile_add', profile);
  }

  Future<int?> getLastProfileId() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT MAX(profile_id) as maxId FROM profile_add');
    return result.isNotEmpty ? result.first['maxId'] as int? : null;
  }

  // 모든 프로필 리스트 추출
  Future<List<Map<String, dynamic>>> selectProfile(String? userid) async {
    final db = await database;
    return await db.query(
      'profile_add',
      columns: [
        'profileImages',
        'profile_name',
        'profile_id'
      ], // 'pic_path'와 'name' 컬럼만 선택
      where: 'userid = ?',
      whereArgs: [userid],
    );
  }

  // 프로필 정보에서 이름과 이미지만 추출
  Future<List<Map<String, dynamic>>> getProfileToshowList(
      int? profileId) async {
    final db = await database;
    return await db.query(
      'profile_add',
      columns: [
        'profileImages',
        'profile_name',
        'profile_id'
      ], // 'pic_path'와 'name' 컬럼만 선택
      where: 'profile_id = ?',
      whereArgs: [profileId],
    );
  }

  Future<List<Map<String, dynamic>>> selectAllProfile(String? userid) async {
    final db = await database;
    return await db.query(
      'profile_add',
      where: 'userid = ?',
      whereArgs: [userid],
    );
  }

  // 달력이 있는 다이어리 페이지에서 프로필을 추가/변경하는 버튼의 사진을 불러오는 객체
  Future<String> getProfileImagePath(String userid) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('profile_add',
        columns: ['profileImages'], where: 'userid = ?', whereArgs: [userid]);

    if (maps.isEmpty) {
      return 'No data'; // 데이터가 없을 경우 'No data' 반환
    } else {
      return maps[0]['profileImages'] as String;
    }
  }

  // 달력이 있는 다이어리 페이지에서 프로필을 추가/변경하는 버튼의 리스트를 불러오는 객체
  Future<List<Map<String, dynamic>>> getProfileData(String userid) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'profile_add',
      columns: ['profile_name', 'profileImages'], // 필요한 컬럼만 선택
      where: 'userid = ?',
      whereArgs: [userid],
    );
    // 쿼리 결과를 맵 리스트로 변환하며 인덱스 추가
    return List.generate(maps.length, (i) {
      final map = maps[i];
      map['index'] = i; // 인덱스 추가
      return map;
    });
  }

  // 프로필을 삭제하면 해당 프로필로 등록한 모든 데이터 삭제
  Future<bool> deleteProfileAndRelatedDate(int? profileId) async {
    bool isDeletedAllData = true;
    if (profileId == null) return false;

    final db = await database;

    try {
      // 1. profile_add 테이블에서 profileImages 경로 가져오기
      List<Map<String, dynamic>> profileImags = await db.query(
        'profile_add',
        columns: ['profileImages'],
        where: 'profile_id = ?',
        whereArgs: [profileId],
      );

      // 2. 가져온 profileImages 경로를 리스트로 변환
      List<String> profileImagePaths =
          profileImags.map((row) => row['profileImages'] as String).toList();

      // 3. 로컬에 저장된 profileImages 삭제
      bool profileImageDeleted = await deleteImageFile(profileImagePaths);
      if (!profileImageDeleted) {
        isDeletedAllData = false;
      }

      // 4. diaryImages 테이블에서 해당 profileId를 가진 행 조회하여 이미지 경로 가져오기
      List<Map<String, dynamic>> diaryImages = await db
          .query('diaryImages', where: 'photoPath = ?', whereArgs: [profileId]);

      // diaryImages 출력
      print(diaryImages);

      // 5. 가져온 이미지 경로들을 리스트로 변환
      List<String> diaryImagePaths =
          diaryImages.map((row) => row['photoPath'] as String).toList();

      // 6. 실제 이미지 파일 삭제 (for 루프 사용)
      for (String imagePath in diaryImagePaths) {
        bool isDeleted = await deleteImageFile([imagePath]);
        if (!isDeleted) {
          // 하나라도 삭제 실패하면 false로 변경
          isDeletedAllData = false;
        }
      }

      // 7. profile_add 테이블에서 해당 profileId를 가진 행 삭제 (CASCADE로 인해 관련 데이터도 삭제됨)
      int deletedRows = await db.delete(
        'profile_add',
        where: 'profile_id = ?',
        whereArgs: [profileId],
      );
      if (deletedRows == 0) {
        isDeletedAllData = false;
      }
    } catch (e) {
      print("Error deleting profile and related data: $e");
      isDeletedAllData = false;
    }

    return isDeletedAllData;
  }

  // 마지막으로 사용한 프로필 정보 저장
  Future<void> insertOrUpdateLastUsedProfile(
      List<Map<String, dynamic>> newList) async {
    final db = await database;

    // 새로운 프로필 정보
    final String profileName = newList.first['profile_name'] ?? '';
    final String photoPath = newList.first['profileImages'] ?? '';
    final int profileId = newList.first['profile_id'] ?? '';

    // 삽입/업데이트할 데이터
    final Map<String, dynamic> profileData = {
      'profileName': profileName,
      'photoPath': photoPath,
      'profile_id': profileId, // 프로필 ID
    };

    // 1. profile_id로 기존 데이터가 있는지 확인
    final List<Map<String, dynamic>> result = await db.query('lastUsedProfile');

    if (result.isEmpty) {
      // 2. 데이터가 없으면 insert
      await db.insert('lastUsedProfile', profileData);
      print('Inserted new profile');
    } else {
      // 3. 데이터가 있으면 update (profile_id 기준으로)
      await db.update(
        'lastUsedProfile',
        profileData,
      );
    }
  }

  // 프로필 정보 저장
  Future<Map<String, dynamic>?> getLastUsedProfile() async {
    final db = await database;

    // lastUsedProfile 테이블에서 데이터를 조회
    final List<Map<String, dynamic>> result = await db.query('lastUsedProfile');

    if (result.isNotEmpty) {
      // 데이터가 있으면 첫 번째 항목을 반환
      return result.first;
    } else {
      // 데이터가 없으면 null 반환
      return null;
    }
  }

  // 프로필ID가 1단계 높은 프로필을 조회, 만약 프로필이 가장 작은 값이라면 한단계 큰 프로필로 조회
  // 프로필을 삭제하고 위 혹은 아래의 프로필로 전환하기 위해서 생성
  Future<Map<String, dynamic>?> getLargestOrLowestProfileBelow(
      int profileId) async {
    final db = await database;

    // 필요한 컬럼만 지정하여 쿼리
    final List<Map<String, dynamic>> largestProfile = await db.query(
      'profile_add',
      columns: ['profile_id', 'profile_name', 'profileImages'], // 선택한 컬럼들
      where: 'profile_id < ?',
      whereArgs: [profileId],
      orderBy: 'profile_id DESC',
      limit: 1,
    );

    if (largestProfile.isNotEmpty) {
      return largestProfile.first; // 가장 큰 값을 반환
    } else {
      // 만약 profile_id보다 작은 값이 없으면, profile_id보다 큰 값 중 가장 작은 값 찾기
      final List<Map<String, dynamic>> lowestProfile = await db.query(
        'profile_add',
        columns: ['profile_id', 'profile_name', 'profileImages'], // 선택한 컬럼들
        where: 'profile_id > ?',
        whereArgs: [profileId],
        orderBy: 'profile_id ASC',
        limit: 1,
      );

      if (lowestProfile.isNotEmpty) {
        return lowestProfile.first; // 가장 작은 값을 반환
      } else {
        return null; // 작은 값도 없고, 큰 값도 없으면 null 반환
      }
    }
  }
}

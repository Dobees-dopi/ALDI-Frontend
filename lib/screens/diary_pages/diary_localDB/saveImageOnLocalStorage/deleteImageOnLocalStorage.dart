import 'dart:io';

Future<bool> deleteImageFile(List<String> imagePaths) async {
  bool allDeleted = true; // 모든 파일 삭제 성공 여부를 나타내는 변수
  try {
    for (String imagePath in imagePaths) {
      final file = File(imagePath);

      if (await file.exists()) {
        await file.delete();
        print('이미지 파일 삭제 성공: $imagePath');
      } else {
        print('이미지 파일이 존재하지 않습니다: $imagePath');
        allDeleted = false; // 하나라도 삭제 실패하면 false로 변경
      }
    }
  } catch (e) {
    print('이미지 파일 삭제 오류: $e');
    allDeleted = false; // 예외 발생 시에도 false로 변경
  }
  return allDeleted; // 모든 파일 삭제 성공 여부 반환
}

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2966D8),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'MyFlight',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        toolbarHeight: 100,
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          // 업로드 카드
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: const Color(0xFFF5FAFF),
                border: Border.all(color: Color(0xFF2966D8), width: 1.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 파란 정사각형
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2966D8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 업로드 텍스트
                  const Text(
                    '출입국 기록서 업로드',
                    style: TextStyle(
                      color: Color(0xFF2966D8),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 안내 텍스트
                  const Text(
                    '사진을 찍거나 갤러리에서 선택하세요',
                    style: TextStyle(
                      color: Color(0xFF8A8A8A),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          // 버튼 2개
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2966D8),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(100, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('카메라', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 24),
              OutlinedButton(
                onPressed: pickAndUploadFile,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2966D8),
                  side: const BorderSide(color: Color(0xFF2966D8), width: 1.5),
                  minimumSize: const Size(100, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('갤러리', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> pickAndUploadFile() async {
  // 1. 파일 선택 (이미지)
  final result = await FilePicker.platform.pickFiles(type: FileType.image);
  if (result != null && result.files.single.path != null) {
    final filePath = result.files.single.path!;
    final fileName = result.files.single.name;

    // 2. Storage에 업로드
    final ref = FirebaseStorage.instance.ref().child('uploads/$fileName');
    await ref.putFile(File(filePath));

    // 3. 다운로드 URL 얻기 (필요시)
    final url = await ref.getDownloadURL();
    print('업로드 완료! 다운로드 URL: $url');
  }
} 
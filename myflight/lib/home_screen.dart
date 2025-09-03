import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // OCR로 텍스트 추출
  Future<String> extractTextFromImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer();
    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();
    return recognizedText.text;
  }

  // 날짜 추출 (여러 형식 지원)
  List<String> extractDates(String text) {
    // 다양한 날짜 형식 지원: 2024.01.15, 2024-01-15, 2024/01/15, 24.01.15 등
    final datePatterns = [
      RegExp(r'\d{4}[.\-/]\d{2}[.\-/]\d{2}'),  // 2024.01.15
      RegExp(r'\d{2}[.\-/]\d{2}[.\-/]\d{4}'),  // 15.01.2024
      RegExp(r'\d{2}[.\-/]\d{2}[.\-/]\d{2}'),  // 24.01.15
    ];
    
    List<String> dates = [];
    for (var pattern in datePatterns) {
      final matches = pattern.allMatches(text);
      for (var match in matches) {
        dates.add(match.group(0)!);
      }
    }
    return dates.toSet().toList(); // 중복 제거
  }

  // 국가명 추출 (한글/영문 지원)
  List<String> extractCountries(String text) {
    final countryPatterns = [
      // 영문 국가명
      RegExp(r'(KOREA|JAPAN|USA|THAILAND|SINGAPORE|MALAYSIA|VIETNAM|PHILIPPINES|CHINA|TAIWAN|HONG KONG|MACAU|INDIA|NEPAL|MYANMAR|LAOS|CAMBODIA|BRUNEI|INDONESIA|AUSTRALIA|NEW ZEALAND|CANADA|UNITED KINGDOM|FRANCE|GERMANY|ITALY|SPAIN|SWITZERLAND|AUSTRIA|NETHERLANDS|BELGIUM|SWEDEN|NORWAY|DENMARK|FINLAND|RUSSIA|TURKEY|EGYPT|UAE|SAUDI ARABIA|QATAR|BAHRAIN|KUWAIT|JORDAN|ISRAEL|SOUTH AFRICA|KENYA|TANZANIA|MOROCCO|BRAZIL|ARGENTINA|CHILE|PERU|MEXICO|CUBA)', caseSensitive: false),
      // 한글 국가명
      RegExp(r'(한국|일본|미국|태국|싱가포르|말레이시아|베트남|필리핀|중국|대만|홍콩|마카오|인도|네팔|미얀마|라오스|캄보디아|브루나이|인도네시아|호주|뉴질랜드|캐나다|영국|프랑스|독일|이탈리아|스페인|스위스|오스트리아|네덜란드|벨기에|스웨덴|노르웨이|덴마크|핀란드|러시아|터키|이집트|아랍에미리트|사우디아라비아|카타르|바레인|쿠웨이트|요단|이스라엘|남아프리카공화국|케냐|탄자니아|모로코|브라질|아르헨티나|칠레|페루|멕시코|쿠바)'),
    ];
    
    List<String> countries = [];
    for (var pattern in countryPatterns) {
      final matches = pattern.allMatches(text);
      for (var match in matches) {
        countries.add(match.group(0)!);
      }
    }
    return countries.toSet().toList(); // 중복 제거
  }

  // 출입국 유형 판단 (출국/입국)
  String detectEntryType(String text) {
    if (text.contains('출국') || text.contains('DEPARTURE') || text.contains('DEP')) {
      return '출국';
    } else if (text.contains('입국') || text.contains('ARRIVAL') || text.contains('ARR')) {
      return '입국';
    }
    return '미확인';
  }

  // 갤러리에서 이미지 선택 후 OCR 및 업로드
  Future<void> pickAndUploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;
        
        print('=== OCR 텍스트 추출 시작 ===');
        
        // 1. OCR로 텍스트 추출
        final extractedText = await extractTextFromImage(filePath);
        print('추출된 텍스트:\n$extractedText');
        
        // 2. 날짜 추출
        final dates = extractDates(extractedText);
        print('추출된 날짜: $dates');
        
        // 3. 국가명 추출
        final countries = extractCountries(extractedText);
        print('추출된 국가: $countries');
        
        // 4. 출입국 유형 판단
        final entryType = detectEntryType(extractedText);
        print('출입국 유형: $entryType');
        
        // 5. Firebase Storage에 업로드 (임시 주석 처리)
        // final ref = FirebaseStorage.instance.ref().child('uploads/$fileName');
        // await ref.putFile(File(filePath));
        // final url = await ref.getDownloadURL();
        
        print('=== 처리 완료 ===');
        print('OCR 완료! 파일: $fileName');
        print('날짜: $dates');
        print('국가: $countries');
        print('유형: $entryType');
        
        // 성공 메시지 표시 (나중에 UI로 변경 가능)
        if (countries.isNotEmpty || dates.isNotEmpty) {
          print('🎉 성공적으로 정보를 추출했습니다!');
        }
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  // 카메라로 사진 촬영 후 OCR 및 업로드
  Future<void> takePhotoAndUpload() async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        final file = File(photo.path);
        final fileName = photo.name;
        
        print('=== OCR 텍스트 추출 시작 ===');
        
        // 1. OCR로 텍스트 추출
        final extractedText = await extractTextFromImage(photo.path);
        print('추출된 텍스트:\n$extractedText');
        
        // 2. 날짜 추출
        final dates = extractDates(extractedText);
        print('추출된 날짜: $dates');
        
        // 3. 국가명 추출
        final countries = extractCountries(extractedText);
        print('추출된 국가: $countries');
        
        // 4. 출입국 유형 판단
        final entryType = detectEntryType(extractedText);
        print('출입국 유형: $entryType');
        
        // 5. Firebase Storage에 업로드 (임시 주석 처리)
        // final ref = FirebaseStorage.instance.ref().child('uploads/$fileName');
        // await ref.putFile(file);
        // final url = await ref.getDownloadURL();
        
        print('=== 처리 완료 ===');
        print('카메라 OCR 완료! 파일: $fileName');
        print('날짜: $dates');
        print('국가: $countries');
        print('유형: $entryType');
        
        // 성공 메시지 표시 (나중에 UI로 변경 가능)
        if (countries.isNotEmpty || dates.isNotEmpty) {
          print('🎉 성공적으로 정보를 추출했습니다!');
        }
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

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
                    '출입국/여권 스탬프 업로드',
                    style: TextStyle(
                      color: Color(0xFF2966D8),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 안내 텍스트
                  const Text(
                    '출입국기록서 또는 여권 스탬프를 촬영하세요\nOCR로 자동 추출됩니다',
                    textAlign: TextAlign.center,
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
                onPressed: takePhotoAndUpload,
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
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;

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

  // OCR 결과를 다이얼로그로 표시
  void _showOCRResult({
    required String fileName,
    required List<String> dates,
    required List<String> countries,
    required String entryType,
    required String fullText,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'OCR 추출 완료!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2966D8),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // 추출된 정보
                if (countries.isNotEmpty) ...[
                  _buildInfoCard(
                    icon: Icons.public,
                    title: '추출된 국가',
                    content: countries.join(', '),
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                ],
                
                if (dates.isNotEmpty) ...[
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: '추출된 날짜',
                    content: dates.take(5).join(', ') + (dates.length > 5 ? ' 외 ${dates.length - 5}개' : ''),
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),
                ],
                
                _buildInfoCard(
                  icon: Icons.flight_takeoff,
                  title: '출입국 유형',
                  content: entryType,
                  color: Colors.orange,
                ),
                
                const SizedBox(height: 20),
                
                // 전체 텍스트 보기 (접기/펼치기)
                ExpansionTile(
                  title: const Text(
                    '전체 추출 텍스트',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        fullText.isEmpty ? '텍스트를 추출하지 못했습니다.' : fullText,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // 버튼들
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2966D8),
                          side: const BorderSide(color: Color(0xFF2966D8)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('닫기'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // TODO: 여행기록 페이지로 이동하며 데이터 전달
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('여행기록에 저장되었습니다!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2966D8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('저장'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 정보 카드 위젯
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                content,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 갤러리에서 이미지 선택 후 OCR 및 업로드
  Future<void> pickAndUploadFile() async {
    if (_isLoading) return;
    
    try {
      setState(() => _isLoading = true);
      
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;
        
        // OCR로 텍스트 추출
        final extractedText = await extractTextFromImage(filePath);
        
        // 날짜, 국가, 유형 추출
        final dates = extractDates(extractedText);
        final countries = extractCountries(extractedText);
        final entryType = detectEntryType(extractedText);
        
        // 결과 표시
        _showOCRResult(
          fileName: fileName,
          dates: dates,
          countries: countries,
          entryType: entryType,
          fullText: extractedText,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류 발생: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 카메라로 사진 촬영 후 OCR 및 업로드
  Future<void> takePhotoAndUpload() async {
    if (_isLoading) return;
    
    try {
      setState(() => _isLoading = true);
      
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        final fileName = photo.name;
        
        // OCR로 텍스트 추출
        final extractedText = await extractTextFromImage(photo.path);
        
        // 날짜, 국가, 유형 추출
        final dates = extractDates(extractedText);
        final countries = extractCountries(extractedText);
        final entryType = detectEntryType(extractedText);
        
        // 결과 표시
        _showOCRResult(
          fileName: fileName,
          dates: dates,
          countries: countries,
          entryType: entryType,
          fullText: extractedText,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류 발생: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
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
      body: Stack(
        children: [
          Column(
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
                      // 비행기 아이콘
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2966D8),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2966D8).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.flight_takeoff,
                          color: Colors.white,
                          size: 32,
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
                    onPressed: _isLoading ? null : takePhotoAndUpload,
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
                    onPressed: _isLoading ? null : pickAndUploadFile,
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
          
          // 로딩 오버레이
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'OCR 처리 중...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
} 
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRResult {
  final List<String> dates;
  final List<String> countries;
  final String entryType;
  final String fullText;

  OCRResult({
    required this.dates,
    required this.countries,
    required this.entryType,
    required this.fullText,
  });
}

class OCRService {
  static final TextRecognizer _textRecognizer = TextRecognizer();

  // OCR로 텍스트 추출
  static Future<String> extractTextFromImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      throw Exception('텍스트 인식 실패: $e');
    }
  }

  // 날짜 추출 (여러 형식 지원)
  static List<String> extractDates(String text) {
    final datePatterns = [
      RegExp(r'\d{4}[.\-/]\d{2}[.\-/]\d{2}'),  // 2024.01.15
      RegExp(r'\d{2}[.\-/]\d{2}[.\-/]\d{4}'),  // 15.01.2024
      RegExp(r'\d{2}[.\-/]\d{2}[.\-/]\d{2}'),  // 24.01.15
    ];
    
    Set<String> dates = {};
    for (var pattern in datePatterns) {
      final matches = pattern.allMatches(text);
      for (var match in matches) {
        dates.add(match.group(0)!);
      }
    }
    return dates.toList();
  }

  // 국가명 추출 (한글/영문 지원)
  static List<String> extractCountries(String text) {
    final countryPatterns = [
      // 영문 국가명
      RegExp(r'(KOREA|JAPAN|USA|THAILAND|SINGAPORE|MALAYSIA|VIETNAM|PHILIPPINES|CHINA|TAIWAN|HONG KONG|MACAU|INDIA|NEPAL|MYANMAR|LAOS|CAMBODIA|BRUNEI|INDONESIA|AUSTRALIA|NEW ZEALAND|CANADA|UNITED KINGDOM|FRANCE|GERMANY|ITALY|SPAIN|SWITZERLAND|AUSTRIA|NETHERLANDS|BELGIUM|SWEDEN|NORWAY|DENMARK|FINLAND|RUSSIA|TURKEY|EGYPT|UAE|SAUDI ARABIA|QATAR|BAHRAIN|KUWAIT|JORDAN|ISRAEL|SOUTH AFRICA|KENYA|TANZANIA|MOROCCO|BRAZIL|ARGENTINA|CHILE|PERU|MEXICO|CUBA)', caseSensitive: false),
      // 한글 국가명
      RegExp(r'(한국|일본|미국|태국|싱가포르|말레이시아|베트남|필리핀|중국|대만|홍콩|마카오|인도|네팔|미얀마|라오스|캄보디아|브루나이|인도네시아|호주|뉴질랜드|캐나다|영국|프랑스|독일|이탈리아|스페인|스위스|오스트리아|네덜란드|벨기에|스웨덴|노르웨이|덴마크|핀란드|러시아|터키|이집트|아랍에미리트|사우디아라비아|카타르|바레인|쿠웨이트|요단|이스라엘|남아프리카공화국|케냐|탄자니아|모로코|브라질|아르헨티나|칠레|페루|멕시코|쿠바)'),
    ];
    
    Set<String> countries = {};
    for (var pattern in countryPatterns) {
      final matches = pattern.allMatches(text);
      for (var match in matches) {
        countries.add(match.group(0)!);
      }
    }
    return countries.toList();
  }

  // 출입국 유형 판단
  static String detectEntryType(String text) {
    if (text.contains('출국') || text.contains('DEPARTURE') || text.contains('DEP')) {
      return '출국';
    } else if (text.contains('입국') || text.contains('ARRIVAL') || text.contains('ARR')) {
      return '입국';
    }
    return '미확인';
  }

  // 종합 OCR 분석
  static Future<OCRResult> analyzeImage(String imagePath) async {
    final fullText = await extractTextFromImage(imagePath);
    
    return OCRResult(
      dates: extractDates(fullText),
      countries: extractCountries(fullText),
      entryType: detectEntryType(fullText),
      fullText: fullText,
    );
  }

  // 리소스 정리
  static void dispose() {
    _textRecognizer.close();
  }
} 
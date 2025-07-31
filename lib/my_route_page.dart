import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MyRoutePage extends StatelessWidget {
  const MyRoutePage({super.key});

  // mock 데이터: 출발지/도착지 위도, 경도, 공항명, 날짜
  static final List<Map<String, dynamic>> mockRoutes = [
    {
      'from': LatLng(37.4602, 126.4407), // 인천국제공항
      'to': LatLng(35.7732, 140.3874),   // 나리타국제공항
      'fromName': '인천국제공항',
      'toName': '나리타국제공항',
      'depart': '2019.08.04',
      'arrive': '2019.08.07',
      'duration': '4일',
    },
    {
      'from': LatLng(37.4602, 126.4407), // 인천국제공항
      'to': LatLng(34.6937, 135.5023),   // 오사카 간사이공항(임의)
      'fromName': '인천국제공항',
      'toName': '간사이국제공항',
      'depart': '2020.01.12',
      'arrive': '2020.01.20',
      'duration': '8일',
    },
    {
      'from': LatLng(37.4602, 126.4407), // 인천국제공항
      'to': LatLng(40.6413, -73.7781),   // 뉴욕 JFK
      'fromName': '인천국제공항',
      'toName': 'JFK국제공항',
      'depart': '2021.05.03',
      'arrive': '2021.05.10',
      'duration': '7일',
    },
    {
      'from': LatLng(37.4602, 126.4407), // 인천국제공항
      'to': LatLng(48.3538, 11.7861),    // 뮌헨공항
      'fromName': '인천국제공항',
      'toName': '뮌헨국제공항',
      'depart': '2022.09.15',
      'arrive': '2022.09.22',
      'duration': '7일',
    },
    {
      'from': LatLng(37.4602, 126.4407), // 인천국제공항
      'to': LatLng(51.4700, -0.4543),    // 런던 히드로
      'fromName': '인천국제공항',
      'toName': '히드로공항',
      'depart': '2023.03.28',
      'arrive': '2023.04.02',
      'duration': '5일',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final first = mockRoutes[0];
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2966D8),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '✈️ 나의 여행 경로',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        toolbarHeight: 80,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 지도 영역 (flutter_map)
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFB3C7E6)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(40, 120),
                    initialZoom: 2.8,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.myflight',
                    ),
                    PolylineLayer(
                      polylines: [
                        for (final route in mockRoutes)
                          Polyline(
                            points: [route['from'], route['to']],
                            color: Colors.orange,
                            strokeWidth: 4,
                          ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        for (final route in mockRoutes) ...[
                          Marker(
                            width: 36,
                            height: 36,
                            point: route['from'],
                            child: const Icon(Icons.circle, color: Colors.green, size: 20),
                          ),
                          Marker(
                            width: 36,
                            height: 36,
                            point: route['to'],
                            child: const Icon(Icons.circle, color: Colors.red, size: 20),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 여행 정보 카드 리스트
            Expanded(
              child: ListView.separated(
                itemCount: mockRoutes.length,
                separatorBuilder: (context, idx) => const SizedBox(height: 16),
                itemBuilder: (context, idx) {
                  final route = mockRoutes[idx];
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFFE0E0E0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '✈️ ${route['fromName']} → ${route['toName']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.event, size: 18, color: Colors.redAccent),
                            const SizedBox(width: 4),
                            Text('출발: ${route['depart']}'),
                            const SizedBox(width: 16),
                            const Icon(Icons.home, size: 18, color: Colors.brown),
                            const SizedBox(width: 4),
                            Text('도착: ${route['arrive']}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.timer, size: 18, color: Colors.blueGrey),
                            const SizedBox(width: 4),
                            Text('여행 기간: ${route['duration']}', style: const TextStyle(color: Color(0xFF2966D8))),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            // 공유 버튼
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.link, color: Colors.white),
                label: const Text(
                  '여행 경로 공유하기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2966D8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
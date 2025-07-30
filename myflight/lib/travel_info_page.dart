import 'package:flutter/material.dart';

class TravelInfoPage extends StatelessWidget {
  TravelInfoPage({super.key});

  final List<Map<String, String>> mockTravelList = [
    {
      '출국일': '2019.08.04',
      '입국일': '2019.08.07',
    },
    {
      '출국일': '2020.01.12',
      '입국일': '2020.01.20',
    },
    {
      '출국일': '2021.05.03',
      '입국일': '2021.05.10',
    },
    {
      '출국일': '2022.09.15',
      '입국일': '2022.09.22',
    },
    {
      '출국일': '2023.03.28',
      '입국일': '2023.04.02',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2966D8),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '여행 정보 확인',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        toolbarHeight: 80,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        itemCount: mockTravelList.length,
        itemBuilder: (context, idx) {
          final travel = mockTravelList[idx];
          return Container(
            margin: const EdgeInsets.only(bottom: 32),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.assignment, color: Colors.brown, size: 20),
                    const SizedBox(width: 6),
                    const Text(
                      '인식된 출입국 정보',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F8EC),
                          border: Border.all(color: Color(0xFF6FCF97)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('출국일', style: TextStyle(color: Color(0xFF6FCF97), fontWeight: FontWeight.bold)),
                            Text(travel['출국일'] ?? '', style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F8EC),
                          border: Border.all(color: Color(0xFF6FCF97)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('입국일', style: TextStyle(color: Color(0xFF6FCF97), fontWeight: FontWeight.bold)),
                            Text(travel['입국일'] ?? '', style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(Icons.flight_takeoff, color: Color(0xFF2966D8), size: 20),
                    const SizedBox(width: 6),
                    const Text(
                      '여행지 정보 입력',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    hintText: '출발지를 입력하세요 (예: 인천국제공항)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: '도착지를 입력하세요 (예: 나리타국제공항)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 
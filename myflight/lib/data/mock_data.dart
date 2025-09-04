import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/travel_route.dart';

class MockData {
  static final List<TravelRoute> mockRoutes = [
    TravelRoute(
      from: LatLng(37.4602, 126.4407),
      to: LatLng(35.7732, 140.3874),
      fromName: '인천국제공항',
      toName: '나리타국제공항',
      fromCity: '서울',
      toCity: '도쿄',
      depart: '2019.08.04',
      arrive: '2019.08.07',
      duration: '4일',
      distance: '1,160km',
      color: Colors.orange,
    ),
    TravelRoute(
      from: LatLng(37.4602, 126.4407),
      to: LatLng(34.6937, 135.5023),
      fromName: '인천국제공항',
      toName: '간사이국제공항',
      fromCity: '서울',
      toCity: '오사카',
      depart: '2020.01.12',
      arrive: '2020.01.20',
      duration: '8일',
      distance: '890km',
      color: Colors.blue,
    ),
    TravelRoute(
      from: LatLng(37.4602, 126.4407),
      to: LatLng(40.6413, -73.7781),
      fromName: '인천국제공항',
      toName: 'JFK국제공항',
      fromCity: '서울',
      toCity: '뉴욕',
      depart: '2021.05.03',
      arrive: '2021.05.10',
      duration: '7일',
      distance: '10,900km',
      color: Colors.red,
    ),
    TravelRoute(
      from: LatLng(37.4602, 126.4407),
      to: LatLng(48.3538, 11.7861),
      fromName: '인천국제공항',
      toName: '뮌헨국제공항',
      fromCity: '서울',
      toCity: '뮌헨',
      depart: '2022.09.15',
      arrive: '2022.09.22',
      duration: '7일',
      distance: '8,400km',
      color: Colors.purple,
    ),
    TravelRoute(
      from: LatLng(37.4602, 126.4407),
      to: LatLng(51.4700, -0.4543),
      fromName: '인천국제공항',
      toName: '히드로공항',
      fromCity: '서울',
      toCity: '런던',
      depart: '2023.03.28',
      arrive: '2023.04.02',
      duration: '5일',
      distance: '8,800km',
      color: Colors.green,
    ),
  ];

  // 여행 통계 계산
  static Map<String, String> getTravelStats() {
    return {
      'totalTrips': '${mockRoutes.length}회',
      'countries': '5개국',
      'totalDistance': '30,150km',
    };
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

class MyRoutePage extends StatefulWidget {
  const MyRoutePage({super.key});

  @override
  State<MyRoutePage> createState() => _MyRoutePageState();
}

class _MyRoutePageState extends State<MyRoutePage> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  bool _isFullScreen = false;
  int _selectedRouteIndex = -1;
  late AnimationController _animationController;
  late Animation<double> _animation;

  static final List<Map<String, dynamic>> mockRoutes = [
    {
      'from': LatLng(37.4602, 126.4407),
      'to': LatLng(35.7732, 140.3874),
      'fromName': '인천국제공항',
      'toName': '나리타국제공항',
      'fromCity': '서울',
      'toCity': '도쿄',
      'depart': '2019.08.04',
      'arrive': '2019.08.07',
      'duration': '4일',
      'distance': '1,160km',
      'color': Colors.orange,
    },
    {
      'from': LatLng(37.4602, 126.4407), 
      'to': LatLng(34.6937, 135.5023),
      'fromName': '인천국제공항',
      'toName': '간사이국제공항',
      'fromCity': '서울',
      'toCity': '오사카',
      'depart': '2020.01.12',
      'arrive': '2020.01.20',
      'duration': '8일',
      'distance': '890km',
      'color': Colors.blue,
    },
    {
      'from': LatLng(37.4602, 126.4407), 
      'to': LatLng(40.6413, -73.7781), 
      'fromName': '인천국제공항',
      'toName': 'JFK국제공항',
      'fromCity': '서울',
      'toCity': '뉴욕',
      'depart': '2021.05.03',
      'arrive': '2021.05.10',
      'duration': '7일',
      'distance': '10,900km',
      'color': Colors.red,
    },
    {
      'from': LatLng(37.4602, 126.4407), 
      'to': LatLng(48.3538, 11.7861), 
      'fromName': '인천국제공항',
      'toName': '뮌헨국제공항',
      'fromCity': '서울',
      'toCity': '뮌헨',
      'depart': '2022.09.15',
      'arrive': '2022.09.22',
      'duration': '7일',
      'distance': '8,400km',
      'color': Colors.purple,
    },
    {
      'from': LatLng(37.4602, 126.4407), 
      'to': LatLng(51.4700, -0.4543), 
      'fromName': '인천국제공항',
      'toName': '히드로공항',
      'fromCity': '서울',
      'toCity': '런던',
      'depart': '2023.03.28',
      'arrive': '2023.04.02',
      'duration': '5일',
      'distance': '8,800km',
      'color': Colors.green,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 곡선 경로 생성 (대원 경로 시뮬레이션)
  List<LatLng> _generateCurvedPath(LatLng start, LatLng end) {
    final List<LatLng> points = [];
    const int segments = 50;
    
    // 거리 계산 (대략적)
    final double distance = _calculateDistance(start, end);
    
    // 거리에 따른 곡률 조정
    double maxCurve;
    if (distance < 2000) {
      maxCurve = 2.0; // 근거리 (일본, 중국 등) - 약간의 곡선
    } else if (distance < 5000) {
      maxCurve = 4.0; // 중거리 (동남아시아 등)
    } else if (distance < 10000) {
      maxCurve = 6.0; // 장거리 (유럽 등)
    } else {
      maxCurve = 8.0; // 초장거리 (미주 등)
    }
    
    for (int i = 0; i <= segments; i++) {
      final double ratio = i / segments;
      
      // 선형 보간
      final double lat = start.latitude + (end.latitude - start.latitude) * ratio;
      final double lng = start.longitude + (end.longitude - start.longitude) * ratio;
      
      // 곡률 추가 (거리에 따라 조정된 고도 시뮬레이션)
      final double curve = math.sin(ratio * math.pi) * maxCurve;
      
      points.add(LatLng(lat + curve, lng));
    }
    
    return points;
  }

  // 두 지점 간 거리 계산 (km)
  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371; // 지구 반지름 (km)
    
    final double lat1Rad = start.latitude * math.pi / 180;
    final double lat2Rad = end.latitude * math.pi / 180;
    final double deltaLatRad = (end.latitude - start.latitude) * math.pi / 180;
    final double deltaLngRad = (end.longitude - start.longitude) * math.pi / 180;
    
    final double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLngRad / 2) * math.sin(deltaLngRad / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  // 지도 전체화면 토글
  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
    _animationController.forward(from: 0);
  }

  // 경로 선택
  void _selectRoute(int index) {
    setState(() {
      _selectedRouteIndex = index;
    });
    
    if (index >= 0) {
      final route = mockRoutes[index];
      _mapController.move(route['from'], 6.0);
    }
  }

  // 모든 경로가 보이도록 지도 조정
  void _fitAllRoutes() {
    if (mockRoutes.isEmpty) return;
    
    double minLat = mockRoutes.first['from'].latitude;
    double maxLat = mockRoutes.first['from'].latitude;
    double minLng = mockRoutes.first['from'].longitude;
    double maxLng = mockRoutes.first['from'].longitude;
    
    for (final route in mockRoutes) {
      final from = route['from'] as LatLng;
      final to = route['to'] as LatLng;
      
      minLat = math.min(minLat, math.min(from.latitude, to.latitude));
      maxLat = math.max(maxLat, math.max(from.latitude, to.latitude));
      minLng = math.min(minLng, math.min(from.longitude, to.longitude));
      maxLng = math.max(maxLng, math.max(from.longitude, to.longitude));
    }
    
    final bounds = LatLngBounds(
      LatLng(minLat - 5, minLng - 5),
      LatLng(maxLat + 5, maxLng + 5),
    );
    
    _mapController.fitCamera(CameraFit.bounds(bounds: bounds));
  }

  Widget _buildInteractiveMap() {
    return Container(
      width: double.infinity,
      height: _isFullScreen ? MediaQuery.of(context).size.height - 100 : 300,
      decoration: BoxDecoration(
        borderRadius: _isFullScreen ? BorderRadius.zero : BorderRadius.circular(12),
        border: _isFullScreen ? null : Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: _isFullScreen ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: _isFullScreen ? BorderRadius.zero : BorderRadius.circular(12),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(37.4602, 126.4407),
                initialZoom: 3.0,
                minZoom: 2.0,
                maxZoom: 18.0,
                // 인터랙션 설정
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                  enableMultiFingerGestureRace: true,
                ),
                // 경계 설정
                cameraConstraint: CameraConstraint.contain(
                  bounds: LatLngBounds(
                    LatLng(-85, -180),
                    LatLng(85, 180),
                  ),
                ),
              ),
              children: [
                // 지도 타일
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.myflight',
                  maxZoom: 18,
                ),
                
                // 곡선 경로
                PolylineLayer(
                  polylines: [
                    for (int i = 0; i < mockRoutes.length; i++) ...[
                      Polyline(
                        points: _generateCurvedPath(
                          mockRoutes[i]['from'],
                          mockRoutes[i]['to'],
                        ),
                        color: _selectedRouteIndex == i 
                            ? mockRoutes[i]['color']
                            : mockRoutes[i]['color'].withOpacity(0.6),
                        strokeWidth: _selectedRouteIndex == i ? 6.0 : 4.0,
                        pattern: _selectedRouteIndex == i 
                            ? const StrokePattern.solid()
                            : const StrokePattern.dotted(),
                      ),
                    ],
                  ],
                ),
                
                // 마커
                MarkerLayer(
                  markers: [
                    for (int i = 0; i < mockRoutes.length; i++) ...[
                      // 출발지 마커
                      Marker(
                        width: 32,
                        height: 32,
                        point: mockRoutes[i]['from'],
                        child: GestureDetector(
                          onTap: () => _selectRoute(i),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.flight_takeoff,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      // 도착지 마커
                      Marker(
                        width: 32,
                        height: 32,
                        point: mockRoutes[i]['to'],
                        child: GestureDetector(
                          onTap: () => _selectRoute(i),
                          child: Container(
                            decoration: BoxDecoration(
                              color: mockRoutes[i]['color'],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.flight_land,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            
            // 지도 컨트롤러
            Positioned(
              top: 10,
              right: 10,
              child: Column(
                children: [
                  // 전체화면 버튼
                  FloatingActionButton.small(
                    heroTag: "fullscreen",
                    onPressed: _toggleFullScreen,
                    backgroundColor: Colors.white,
                    child: Icon(
                      _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                      color: const Color(0xFF2966D8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 전체 경로 보기 버튼
                  FloatingActionButton.small(
                    heroTag: "fit",
                    onPressed: _fitAllRoutes,
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.my_location,
                      color: Color(0xFF2966D8),
                    ),
                  ),
                ],
              ),
            ),
            
            // 선택된 경로 정보
            if (_selectedRouteIndex >= 0)
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 40,
                            color: mockRoutes[_selectedRouteIndex]['color'],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${mockRoutes[_selectedRouteIndex]['fromCity']} → ${mockRoutes[_selectedRouteIndex]['toCity']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${mockRoutes[_selectedRouteIndex]['depart']} • ${mockRoutes[_selectedRouteIndex]['duration']} • ${mockRoutes[_selectedRouteIndex]['distance']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _selectRoute(-1),
                            icon: const Icon(Icons.close, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullScreen) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF2966D8),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            '✈️ 여행 경로 지도',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            onPressed: _toggleFullScreen,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ),
        body: _buildInteractiveMap(),
      );
    }

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
        toolbarHeight: 70,
        actions: [
          // 공유 버튼을 헤더에 추가
          IconButton(
            onPressed: () {
              // 공유 기능 구현
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('여행 경로를 공유합니다!'),
                  backgroundColor: Color(0xFF2966D8),
                ),
              );
            },
            icon: const Icon(
              Icons.share,
              color: Colors.white,
              size: 24,
            ),
            tooltip: '여행 경로 공유',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 지도 영역 (고정)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildInteractiveMap(),
            ),
          ),
          
          // 여행 통계 (스크롤과 함께 움직임)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('총 여행', '${mockRoutes.length}회', Icons.flight_takeoff),
                    _buildStatItem('방문 국가', '5개국', Icons.public),
                    _buildStatItem('총 거리', '30,150km', Icons.straighten),
                  ],
                ),
              ),
            ),
          ),
          
          // 여행 목록 헤더
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  const Icon(Icons.list_alt, color: Color(0xFF2966D8), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    '여행 기록',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2966D8),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${mockRoutes.length}개의 여행',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 여행 정보 카드 리스트 (확장된 영역)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, idx) {
                  final route = mockRoutes[idx];
                  final isSelected = _selectedRouteIndex == idx;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => _selectRoute(isSelected ? -1 : idx),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isSelected ? route['color'].withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? route['color'] : const Color(0xFFE0E0E0),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: route['color'].withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ] : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
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
                                Container(
                                  width: 4,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: route['color'],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '✈️ ${route['fromCity']} → ${route['toCity']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          color: isSelected ? route['color'] : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${route['fromName']} → ${route['toName']}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  isSelected ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: isSelected ? route['color'] : Colors.grey,
                                  size: 24,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.event, size: 14, color: Colors.green),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${route['depart']} ~ ${route['arrive']}',
                                              style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.timer, size: 14, color: Colors.blue),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${route['duration']}',
                                              style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.straighten, size: 14, color: Colors.orange),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${route['distance']}',
                                              style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: mockRoutes.length,
              ),
            ),
          ),
           
          // 하단 여백 (네비게이션 바 공간 확보)
          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF2966D8), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2966D8),
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
} 
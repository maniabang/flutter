import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'data/mock_data.dart';
import 'models/travel_route.dart';
import 'utils/map_utils.dart';
import 'widgets/travel_route_card.dart';

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

  List<TravelRoute> get routes => MockData.mockRoutes;
  Map<String, String> get stats => MockData.getTravelStats();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
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

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
    
    if (_isFullScreen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _selectRoute(int index) {
    setState(() {
      _selectedRouteIndex = index;
    });
    
    if (index >= 0) {
      final route = routes[index];
      _mapController.move(route.from, 5.0);
    }
  }

  void _fitAllRoutes() {
    final allPoints = <LatLng>[];
    for (var route in routes) {
      allPoints.add(route.from);
      allPoints.add(route.to);
    }
    
    if (allPoints.isNotEmpty) {
      final bounds = MapUtils.calculateBounds(allPoints);
      _mapController.fitCamera(CameraFit.bounds(bounds: bounds));
    }
  }

  void _shareRoute() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('여행 경로를 공유합니다!'),
        backgroundColor: Color(0xFF2966D8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
        IconButton(
          onPressed: _shareRoute,
          icon: const Icon(
            Icons.share,
            color: Colors.white,
            size: 24,
          ),
          tooltip: '여행 경로 공유',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildMapSection()),
        SliverToBoxAdapter(child: _buildStatsSection()),
        SliverToBoxAdapter(child: _buildListHeader()),
        _buildRouteList(),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildMapSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              _buildFlutterMap(),
              _buildMapControls(),
              if (_selectedRouteIndex >= 0) _buildSelectedRouteInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlutterMap() {
    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: LatLng(37.4602, 126.4407),
        initialZoom: 2.0,
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.myflight',
        ),
        PolylineLayer(polylines: _buildPolylines()),
        MarkerLayer(markers: _buildMarkers()),
      ],
    );
  }

  List<Polyline> _buildPolylines() {
    return routes.asMap().entries.map((entry) {
      final index = entry.key;
      final route = entry.value;
      final isSelected = _selectedRouteIndex == index;
      
      return Polyline(
        points: MapUtils.generateCurvedPath(route.from, route.to),
        strokeWidth: isSelected ? 4.0 : 2.5,
        color: isSelected ? route.color : route.color.withOpacity(0.7),
      );
    }).toList();
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];
    
    for (int i = 0; i < routes.length; i++) {
      final route = routes[i];
      final isSelected = _selectedRouteIndex == i;
      
      markers.addAll([
        _buildMarker(route.from, Icons.flight_takeoff, route.color, isSelected, () => _selectRoute(i)),
        _buildMarker(route.to, Icons.flight_land, route.color, isSelected, () => _selectRoute(i)),
      ]);
    }
    
    return markers;
  }

  Marker _buildMarker(LatLng point, IconData icon, Color color, bool isSelected, VoidCallback onTap) {
    return Marker(
      point: point,
      width: isSelected ? 35 : 25,
      height: isSelected ? 35 : 25,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.8),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: isSelected ? 20 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      top: 12,
      right: 12,
      child: Column(
        children: [
          _buildControlButton(
            icon: _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
            onPressed: _toggleFullScreen,
            tooltip: _isFullScreen ? '전체화면 종료' : '전체화면',
          ),
          const SizedBox(height: 8),
          _buildControlButton(
            icon: Icons.zoom_out_map,
            onPressed: _fitAllRoutes,
            tooltip: '전체 경로 보기',
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: const Color(0xFF2966D8)),
        tooltip: tooltip,
        iconSize: 20,
      ),
    );
  }

  Widget _buildSelectedRouteInfo() {
    final route = routes[_selectedRouteIndex];
    
    return Positioned(
      bottom: 12,
      left: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '✈️ ${route.routeDescription}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: route.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${route.depart} ~ ${route.arrive} • ${route.duration} • ${route.distance}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
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
            _buildStatItem('총 여행', stats['totalTrips']!, Icons.flight_takeoff),
            _buildStatItem('방문 국가', stats['countries']!, Icons.public),
            _buildStatItem('총 거리', stats['totalDistance']!, Icons.straighten),
          ],
        ),
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

  Widget _buildListHeader() {
    return Padding(
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
            '${routes.length}개의 여행',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final route = routes[index];
            final isSelected = _selectedRouteIndex == index;
            
            return TravelRouteCard(
              route: route,
              isSelected: isSelected,
              onTap: () => _selectRoute(isSelected ? -1 : index),
            );
          },
          childCount: routes.length,
        ),
      ),
    );
  }
} 
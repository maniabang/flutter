import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

class MapUtils {
  // Haversine 공식으로 두 지점 간 거리 계산
  static double calculateDistance(LatLng start, LatLng end) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, start, end);
  }

  // 거리에 따른 곡선 경로 생성
  static List<LatLng> generateCurvedPath(LatLng start, LatLng end) {
    final distance = calculateDistance(start, end);
    
    // 거리에 따른 곡선 높이 조정 (2-8도)
    double curvature;
    if (distance < 2000) {
      curvature = 2.0; // 단거리: 완만한 곡선
    } else if (distance < 5000) {
      curvature = 4.0; // 중거리: 보통 곡선
    } else {
      curvature = 6.0; // 장거리: 큰 곡선
    }
    
    return _generateBezierCurve(start, end, curvature);
  }

  // 베지어 곡선으로 경로 생성
  static List<LatLng> _generateBezierCurve(LatLng start, LatLng end, double curvature) {
    List<LatLng> points = [];
    const int numPoints = 50;
    
    // 중간점 계산 (곡선의 제어점)
    double midLat = (start.latitude + end.latitude) / 2;
    double midLng = (start.longitude + end.longitude) / 2;
    
    // 곡선 높이 조정 (북쪽으로 올리기)
    midLat += curvature;
    
    LatLng controlPoint = LatLng(midLat, midLng);
    
    // 베지어 곡선 점들 생성
    for (int i = 0; i <= numPoints; i++) {
      double t = i / numPoints;
      double lat = math.pow(1 - t, 2) * start.latitude +
                   2 * (1 - t) * t * controlPoint.latitude +
                   math.pow(t, 2) * end.latitude;
      double lng = math.pow(1 - t, 2) * start.longitude +
                   2 * (1 - t) * t * controlPoint.longitude +
                   math.pow(t, 2) * end.longitude;
      
      points.add(LatLng(lat, lng));
    }
    
    return points;
  }

  // 모든 경로를 포함하는 경계 계산
  static LatLngBounds calculateBounds(List<LatLng> points) {
    if (points.isEmpty) {
      return LatLngBounds(
        LatLng(0, 0),
        LatLng(0, 0),
      );
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }

    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }
} 
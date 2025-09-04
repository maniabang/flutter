import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class TravelRoute {
  final LatLng from;
  final LatLng to;
  final String fromName;
  final String toName;
  final String fromCity;
  final String toCity;
  final String depart;
  final String arrive;
  final String duration;
  final String distance;
  final Color color;

  const TravelRoute({
    required this.from,
    required this.to,
    required this.fromName,
    required this.toName,
    required this.fromCity,
    required this.toCity,
    required this.depart,
    required this.arrive,
    required this.duration,
    required this.distance,
    required this.color,
  });

  // Map에서 TravelRoute 객체로 변환
  factory TravelRoute.fromMap(Map<String, dynamic> map) {
    return TravelRoute(
      from: map['from'] as LatLng,
      to: map['to'] as LatLng,
      fromName: map['fromName'] as String,
      toName: map['toName'] as String,
      fromCity: map['fromCity'] as String,
      toCity: map['toCity'] as String,
      depart: map['depart'] as String,
      arrive: map['arrive'] as String,
      duration: map['duration'] as String,
      distance: map['distance'] as String,
      color: map['color'] as Color,
    );
  }

  // TravelRoute 객체를 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'from': from,
      'to': to,
      'fromName': fromName,
      'toName': toName,
      'fromCity': fromCity,
      'toCity': toCity,
      'depart': depart,
      'arrive': arrive,
      'duration': duration,
      'distance': distance,
      'color': color,
    };
  }

  // 편의 메서드: 도시 경로 문자열
  String get routeDescription => '$fromCity → $toCity';
  
  // 편의 메서드: 공항 경로 문자열
  String get airportDescription => '$fromName → $toName';
} 
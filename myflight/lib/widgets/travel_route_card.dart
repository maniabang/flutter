import 'package:flutter/material.dart';
import '../models/travel_route.dart';

class TravelRouteCard extends StatelessWidget {
  final TravelRoute route;
  final bool isSelected;
  final VoidCallback onTap;

  const TravelRouteCard({
    super.key,
    required this.route,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isSelected ? route.color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? route.color : const Color(0xFFE0E0E0),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: route.color.withOpacity(0.3),
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
              _buildRouteHeader(),
              const SizedBox(height: 12),
              _buildRouteDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteHeader() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 35,
          decoration: BoxDecoration(
            color: route.color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '✈️ ${route.routeDescription}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: isSelected ? route.color : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                route.airportDescription,
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
          color: isSelected ? route.color : Colors.grey,
          size: 24,
        ),
      ],
    );
  }

  Widget _buildRouteDetails() {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        children: [
          Row(
            children: [
              _buildInfoChip(
                '${route.depart} ~ ${route.arrive}',
                Icons.event,
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip(
                route.duration,
                Icons.timer,
                Colors.blue,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                route.distance,
                Icons.straighten,
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
} 
import 'package:flutter/material.dart';

class StatisticsItemComponent extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isMobile;

  const StatisticsItemComponent({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 12,
        vertical: isMobile ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isMobile ? 14 : 16, color: Colors.blue.shade700),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '$label: ',
              style: TextStyle(
                fontSize: isMobile ? 10 : 12,
                color: Colors.grey.shade700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
              fontSize: isMobile ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

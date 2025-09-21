import 'package:flutter/material.dart';
import 'package:flutter_scrapper/view/components/statistics_item_component.dart';

class StatisticsSectionComponent extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;
  final int paragraphCount;
  final int linkCount;
  final int imageCount;
  final int headingCount;
  final int schemaCount;

  const StatisticsSectionComponent({
    super.key,
    required this.isMobile,
    required this.isTablet,
    required this.paragraphCount,
    required this.linkCount,
    required this.imageCount,
    required this.headingCount,
    required this.schemaCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : (isTablet ? 16 : 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart_rounded,
                color: Colors.blue.shade700,
                size: isMobile ? 20 : 24,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Sayfa İstatistikleri',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 16 : (isTablet ? 18 : 20),
                    color: Colors.blue.shade800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: isMobile ? 8 : 12,
                runSpacing: isMobile ? 8 : 12,
                children: [
                  StatisticsItemComponent(
                    label: 'Paragraf',
                    value: paragraphCount.toString(),
                    icon: Icons.format_align_left_rounded,
                    isMobile: isMobile,
                  ),
                  StatisticsItemComponent(
                    label: 'Bağlantı',
                    value: linkCount.toString(),
                    icon: Icons.link_rounded,
                    isMobile: isMobile,
                  ),
                  StatisticsItemComponent(
                    label: 'Görsel',
                    value: imageCount.toString(),
                    icon: Icons.image_rounded,
                    isMobile: isMobile,
                  ),
                  StatisticsItemComponent(
                    label: 'Başlık',
                    value: headingCount.toString(),
                    icon: Icons.title_rounded,
                    isMobile: isMobile,
                  ),
                  StatisticsItemComponent(
                    label: 'Schema',
                    value: schemaCount.toString(),
                    icon: Icons.code_rounded,
                    isMobile: isMobile,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

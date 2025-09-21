import 'package:flutter/material.dart';

class HeadingsComponent extends StatelessWidget {
  final List<Map<String, String>> headings;

  const HeadingsComponent({super.key, required this.headings});

  @override
  Widget build(BuildContext context) {
    if (headings.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade100, Colors.orange.shade200],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.title_rounded,
                  size: 64,
                  color: Colors.orange.shade600,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Başlık bulunamadı',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bu sayfada H1-H6 başlık etiketi bulunamadı',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        return ListView.builder(
          padding: EdgeInsets.all(isWide ? 24 : 16),
          itemCount: headings.length,
          itemBuilder: (context, index) {
            final heading = headings[index];
            final level = heading['level'] ?? '';
            final text = heading['text'] ?? '';

            return Container(
              margin: EdgeInsets.only(bottom: isWide ? 16 : 12),
              child: _buildHeadingCard(level, text, heading, isWide),
            );
          },
        );
      },
    );
  }

  Widget _buildHeadingCard(
    String level,
    String text,
    Map<String, String> heading,
    bool isWide,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, _getHeadingColor(level)],
        ),
        borderRadius: BorderRadius.circular(isWide ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: _getHeadingBorderColor(level).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: _getHeadingBorderColor(level), width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(isWide ? 20 : 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 12 : 10,
                vertical: isWide ? 8 : 6,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getHeadingBadgeColor(level),
                    _getHeadingBadgeColor(level).withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: _getHeadingBadgeColor(level).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getHeadingIcon(level),
                    size: isWide ? 16 : 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    level.toUpperCase(),
                    style: TextStyle(
                      fontSize: isWide ? 13 : 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: _getHeadingFontSize(level, isWide),
                      fontWeight: _getHeadingFontWeight(level),
                      color: Colors.grey.shade800,
                      height: 1.4,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (heading['id']?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.tag_rounded,
                            size: 14,
                            color: Colors.blue.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ID: ${heading['id']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (heading['class']?.isNotEmpty == true) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.style_rounded,
                            size: 14,
                            color: Colors.purple.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Class: ${heading['class']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.purple.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getHeadingIcon(String level) {
    switch (level) {
      case 'h1':
        return Icons.looks_one_rounded;
      case 'h2':
        return Icons.looks_two_rounded;
      case 'h3':
        return Icons.looks_3_rounded;
      case 'h4':
        return Icons.looks_4_rounded;
      case 'h5':
        return Icons.looks_5_rounded;
      case 'h6':
        return Icons.looks_6_rounded;
      default:
        return Icons.title_rounded;
    }
  }

  Color _getHeadingColor(String level) {
    switch (level) {
      case 'h1':
        return Colors.red.shade50;
      case 'h2':
        return Colors.orange.shade50;
      case 'h3':
        return Colors.amber.shade50;
      case 'h4':
        return Colors.green.shade50;
      case 'h5':
        return Colors.blue.shade50;
      case 'h6':
        return Colors.purple.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  Color _getHeadingBorderColor(String level) {
    switch (level) {
      case 'h1':
        return Colors.red.shade300;
      case 'h2':
        return Colors.orange.shade300;
      case 'h3':
        return Colors.amber.shade300;
      case 'h4':
        return Colors.green.shade300;
      case 'h5':
        return Colors.blue.shade300;
      case 'h6':
        return Colors.purple.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  Color _getHeadingBadgeColor(String level) {
    switch (level) {
      case 'h1':
        return Colors.red.shade600;
      case 'h2':
        return Colors.orange.shade600;
      case 'h3':
        return Colors.amber.shade600;
      case 'h4':
        return Colors.green.shade600;
      case 'h5':
        return Colors.blue.shade600;
      case 'h6':
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  double _getHeadingFontSize(String level, bool isWide) {
    final baseSizes = {
      'h1': 20.0,
      'h2': 18.0,
      'h3': 17.0,
      'h4': 16.0,
      'h5': 15.0,
      'h6': 14.0,
    };

    final size = baseSizes[level] ?? 14.0;
    return isWide ? size + 2 : size;
  }

  FontWeight _getHeadingFontWeight(String level) {
    switch (level) {
      case 'h1':
      case 'h2':
        return FontWeight.bold;
      case 'h3':
      case 'h4':
        return FontWeight.w600;
      default:
        return FontWeight.w500;
    }
  }
}

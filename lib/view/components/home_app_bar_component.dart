import 'package:flutter/material.dart';

class HomeAppBarComponent extends StatelessWidget
    implements PreferredSizeWidget {
  final bool isLoading;
  final VoidCallback onClearData;
  final Size screenSize;

  const HomeAppBarComponent({
    super.key,
    required this.isLoading,
    required this.onClearData,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const Icon(Icons.analytics, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'SEO Analiz Aracı',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: screenSize.width < 400 ? 16 : 20,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1565C0),
      elevation: 4,
      shadowColor: Colors.blue.withValues(alpha: 0.3),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1976D2), Color(0xFF1565C0), Color(0xFF0D47A1)],
          ),
        ),
      ),
      actions: [
        if (isLoading)
          Container(
            margin: const EdgeInsets.all(16),
            width: 20,
            height: 20,
            child: const CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: onClearData,
          tooltip: 'Temizle',
          splashRadius: 24,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

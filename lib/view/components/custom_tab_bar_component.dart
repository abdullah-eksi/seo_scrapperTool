import 'package:flutter/material.dart';

class CustomTabBarComponent extends StatelessWidget {
  final List<TabData> tabs;
  final List<Widget> tabViews;

  const CustomTabBarComponent({
    super.key,
    required this.tabs,
    required this.tabViews,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: DefaultTabController(
        length: tabs.length,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive tab bar - ekran genişliğine göre
            final isSmallScreen =
                constraints.maxWidth < 600; // Daha büyük breakpoint
            final tabHeight = isSmallScreen ? 60.0 : 48.0;

            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: isSmallScreen
                      ? _buildWrapTabBar(tabHeight, context)
                      : _buildRegularTabBar(tabHeight),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 12,
                      left: 12,
                      right: 12,
                    ),
                    child: TabBarView(children: tabViews),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRegularTabBar(double tabHeight) {
    return TabBar(
      indicator: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade600, Colors.indigo.shade600],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.25),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.grey.shade600,
      labelPadding: EdgeInsets.zero,
      tabs: tabs.map((tab) => _buildTab(tab, tabHeight)).toList(),
    );
  }

  Widget _buildWrapTabBar(double tabHeight, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Her satırda maksimum 3 tab olacak şekilde genişlik hesapla
          final availableWidth = constraints.maxWidth - 16; // padding için
          final tabWidth = (availableWidth - 16) / 3; // 3 tab + spacing için

          return Wrap(
            spacing: 8,
            runSpacing: 12,

            children: tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              return SizedBox(
                width: tabWidth,
                child: _buildWrapTab(tab, index, tabHeight, context),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildWrapTab(
    TabData tab,
    int index,
    double tabHeight,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        DefaultTabController.of(context).animateTo(index);
      },
      child: Container(
        height: tabHeight,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade600, Colors.indigo.shade600],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.25),
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              child: Stack(
                clipBehavior: Clip.none, // kaymasın diye
                children: [
                  Icon(
                    tab.icon,
                    size: 14,
                    color: Colors.white,
                  ), // icon küçültüldü
                  if (tab.count != null && tab.count! > 0)
                    Positioned(
                      top: -12, // badge daha yakın
                      right: -15,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 3,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red.shade500, Colors.red.shade700],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            tab.count! > 99 ? '99+' : '${tab.count}',
                            style: const TextStyle(
                              fontSize: 12, // yazı küçültüldü
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 1),
            Flexible(
              child: Text(
                tab.title,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(TabData tab, double tabHeight) {
    return Tab(
      height: tabHeight,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 22,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(tab.icon, size: 16),
                  if (tab.count != null && tab.count! > 0)
                    Positioned(
                      top: -4,
                      right: -10,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red.shade500, Colors.red.shade600],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            tab.count! > 99 ? '99+' : '${tab.count}',
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                tab.title,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TabData {
  final String title;
  final IconData icon;
  final int? count;

  const TabData({required this.title, required this.icon, this.count});
}

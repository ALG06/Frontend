import 'package:flutter/material.dart';
import '../navigation/tab_item.dart';

class NavBar extends StatelessWidget {
  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;

  const NavBar({
    super.key,
    required this.currentTab,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentTab.index,
      type: BottomNavigationBarType.fixed,
      onTap: (index) => onSelectTab(TabItem.values[index]),
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white,
      selectedIconTheme:
          const IconThemeData(size: 30), // Bigger size for selected icons
      unselectedIconTheme:
          const IconThemeData(size: 24), // Default size for unselected icons
      items: [
        _buildItem(TabItem.home),
        _buildItem(TabItem.donate),
        _buildItem(TabItem.campaign),
        _buildItem(TabItem.locations),
        _buildItem(TabItem.settings),
      ],
    );
  }

  BottomNavigationBarItem _buildItem(TabItem tabItem) {
    IconData icon;

    switch (tabItem) {
      case TabItem.home:
        icon = Icons.home;
        break;
      case TabItem.donate:
        icon = Icons.money;
        break;
      case TabItem.campaign:
        icon = Icons.campaign;
        break;
      case TabItem.locations:
        icon = Icons.location_on;
        break;
      case TabItem.settings:
        icon = Icons.settings;
        break;
    }

    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: tabItem.name,
    );
  }
}

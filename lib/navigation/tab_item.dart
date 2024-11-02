enum TabItem { home, donate, locations, settings, campaign }

extension TabItemExtension on TabItem {
  String get name {
    switch (this) {
      case TabItem.home:
        return 'Home';
      case TabItem.donate:
        return 'Donar';
      case TabItem.locations:
        return 'Locaciones';
      case TabItem.campaign:
        return 'Campañas';
      case TabItem.settings:
        return 'Configuración';
    }
  }
}

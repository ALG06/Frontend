enum TabItem { home, donate, campaign, locations, settings }

extension TabItemExtension on TabItem {
  String get name {
    switch (this) {
      case TabItem.home:
        return 'Home';
      case TabItem.donate:
        return 'Donar';
      case TabItem.campaign:
        return 'Campañas';
      case TabItem.locations:
        return 'Locaciones';
      case TabItem.settings:
        return 'Configuración';
    }
  }
}

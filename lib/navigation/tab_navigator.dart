import 'package:flutter/material.dart';
import '../views/home_view.dart';
import '../views/donations/donate_view.dart';
import '../views/locations_view.dart';
import '../views/settings_view.dart';
import '../views/campaign_view.dart';
import 'tab_item.dart';

class TabNavigator extends StatelessWidget {
  const TabNavigator({
    super.key,
    required this.navigatorKey,
    required this.tabItem,
  });

  final GlobalKey<NavigatorState>? navigatorKey;
  final TabItem tabItem;

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    return {
      '/': (context) {
        switch (tabItem) {
          case TabItem.home:
            return const HomeView();
          case TabItem.donate:
            return const DonateView();
          case TabItem.campaign:
            return const CampaignView();
          case TabItem.locations:
            return const LocationsView();
          case TabItem.settings:
            return const SettingsView();
        }
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    final routeBuilders = _routeBuilders(context);

    return Navigator(
      key: navigatorKey,
      initialRoute: '/',
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => routeBuilders[routeSettings.name!]!(context),
        );
      },
    );
  }
}

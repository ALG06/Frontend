import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'tab_item.dart';
import 'tab_navigator.dart';
import '../layout/navbar.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends State<App> {
  var _currentTab = TabItem.home;
  final _navigatorKeys = {
    TabItem.home: GlobalKey<NavigatorState>(),
    TabItem.donate: GlobalKey<NavigatorState>(),
    TabItem.campaign: GlobalKey<NavigatorState>(),
    TabItem.locations: GlobalKey<NavigatorState>(),
    TabItem.settings: GlobalKey<NavigatorState>(),
  };

  @override
  void initState() {
    super.initState();
    // Check auth status when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AuthService>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (bool didPop) {
        if (!didPop) {
          // Handle back button - return to home tab
          setState(() => _currentTab = TabItem.home);
        }
      },
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            _buildOffstageNavigator(TabItem.home),
            _buildOffstageNavigator(TabItem.donate),
            _buildOffstageNavigator(TabItem.campaign),
            _buildOffstageNavigator(TabItem.locations),
            _buildOffstageNavigator(TabItem.settings),
          ],
        ),
        bottomNavigationBar: NavBar(
          currentTab: _currentTab,
          onSelectTab: _selectTab,
        ),
      ),
    );
  }

  void _selectTab(TabItem tabItem) {
    if (tabItem == _currentTab) {
      // Pop to first route if already on tab
      _navigatorKeys[tabItem]!.currentState!.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentTab = tabItem);
    }
  }

  Widget _buildOffstageNavigator(TabItem tabItem) {
    return Offstage(
      offstage: _currentTab != tabItem,
      child: TabNavigator(
        navigatorKey: _navigatorKeys[tabItem],
        tabItem: tabItem,
      ),
    );
  }
}

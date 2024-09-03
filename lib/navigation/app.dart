import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import '../services/auth_service.dart';
import '../views/auth/auth_view.dart';
import '../views/auth/loading_view.dart';
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
    _initializeAuth();
    _setupUniLinks();
  }

  Future<void> _initializeAuth() async {
    await context.read<AuthService>().checkAuthStatus();
  }

  Future<void> _setupUniLinks() async {
    // Handle incoming links while the app is running
    uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        context.read<AuthService>().handleAuthCallback(uri);
      }
    }, onError: (err) {
      debugPrint('Failed to handle incoming link: $err');
    });

    // Handle incoming links when app was terminated
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        context.read<AuthService>().handleAuthCallback(initialUri);
      }
    } catch (e) {
      debugPrint('Failed to get initial uri: $e');
    }
  }

  void _selectTab(TabItem tabItem) {
    if (tabItem == _currentTab) {
      // if the current tab is tapped again, this will pop all the router in the tab stack until the first route is reached.
      _navigatorKeys[tabItem]!.currentState!.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentTab = tabItem);
    }
  }

  Widget _buildOffstageNavigator(TabItem tabItem) {
    // This build all the views, but just shows the current tab.
    return Offstage(
      offstage: _currentTab != tabItem,
      child: TabNavigator(
        navigatorKey: _navigatorKeys[tabItem],
        tabItem: tabItem,
      ),
    );
  }

  Widget _buildAuthenticatedApp() {
    return PopScope(
      onPopInvoked: (bool didPop) {
        if (!didPop) {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // Show loading screen while checking auth status
        if (authService.isLoading) {
          return const MaterialApp(home: AuthLoadingView());
        }

        // Show auth screen if not authenticated
        if (!authService.isAuthenticated) {
          return const MaterialApp(home: AuthView());
        }

        // Show main app if authenticated
        return MaterialApp(
          theme: Theme.of(context),
          home: _buildAuthenticatedApp(),
        );
      },
    );
  }
}

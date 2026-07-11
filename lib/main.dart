// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'app/app.dart';
import 'router/app_router.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main_tabs_screen.dart';
import 'screens/products/product_details_screen.dart';
import 'screens/hospitality/lodge_detail_screen.dart';
import 'screens/events/event_detail_screen.dart';
import 'screens/shops/shop_details_screen.dart';
import 'screens/properties/property_details_screen.dart';
import 'theme/app_colors.dart';
import 'widgets/no_internet_listener.dart';

// Import Providers and API Client Architecture
import 'core/api/api_client.dart'; 
import 'models/lodge_model.dart';
import 'models/event_model.dart';
import 'providers/auth_provider.dart';

// 🌟 GLOBAL NAVIGATION KEY DEFINITION FOR DEEP-LINK OVERLAYS
final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (WebViewPlatform.instance == null) {
    WebViewPlatform.instance = AndroidWebViewPlatform();
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint("FLUTTER ERROR: ${details.exception}");
  };

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

// 🌟 FIX: Inject the AppRouterMixin to handle the web browser parsing on startup natively!
class _MainAppState extends ConsumerState<MainApp>  {


  @override
  Widget build(BuildContext context) {
    // 🔄 Listen directly to the active Auth State at the app application root
    final authState = ref.watch(authProvider);

    return NoInternetListener(
      child: MaterialApp(
        navigatorKey: globalNavigatorKey, 
        scaffoldMessengerKey: scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        title: 'MalaTrade',

        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: const ColorScheme.light(
            primary: AppColors.mangoOrange,
            secondary: AppColors.leafGreen,
            surface: Colors.white,
            onPrimary: Colors.white,
            onSurface: AppColors.darkText,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.darkText,
            centerTitle: true,
          ),
        ),

        // 🚀 Dynamic Entry Point: Open tabs view by default. 
        // The AppRouterMixin will automatically overlay the deep-linked screen on top!
        home: authState.isLoading
    ? const SplashScreen()
    : const MainTabsScreen(key: ValueKey('main-tabs')),

        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const MainTabsScreen(), 
        },
      ),
    );
  }
}

// ============================================================================
// 🌟 DEEP LINK BRIDGE SHELLS
// Fetches records on the fly directly through your unified ApiClient architecture.
// ============================================================================

class LodgeDeepLinkBridge extends StatefulWidget {
  final int lodgeId;
  const LodgeDeepLinkBridge({Key? key, required this.lodgeId}) : super(key: key);

  @override
  State<LodgeDeepLinkBridge> createState() => _LodgeDeepLinkBridgeState();
}

class _LodgeDeepLinkBridgeState extends State<LodgeDeepLinkBridge> {
  final ApiClient _client = ApiClient();
  Future<Lodge>? _future;

  @override
  void initState() {
    super.initState();
    _future = _client.get(
      'lodges/${widget.lodgeId}/',
      fromJson: (json) => Lodge.fromJson(json),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Lodge>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppColors.mangoOrange)),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text("Error")),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Could not load the shared lodge information.\nIt may have been unlisted.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ),
          );
        }
        return LodgeDetailScreen(lodge: snapshot.data!);
      },
    );
  }
}

class EventDeepLinkBridge extends StatefulWidget {
  final int eventId;
  const EventDeepLinkBridge({Key? key, required this.eventId}) : super(key: key);

  @override
  State<EventDeepLinkBridge> createState() => _EventDeepLinkBridgeState();
}

class _EventDeepLinkBridgeState extends State<EventDeepLinkBridge> {
  final ApiClient _client = ApiClient();
  Future<EventModel>? _future;

  @override
  void initState() {
    super.initState();
    _future = _client.get(
      'events/${widget.eventId}/',
      fromJson: (json) => EventModel.fromJson(json),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EventModel>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppColors.mangoOrange)),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text("Error")),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Could not load the shared event information.\nIt may have ended.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ),
          );
        }
        return EventDetailScreen(event: snapshot.data!);
      },
    );
  }
}
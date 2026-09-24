import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../core/services/app_update_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late final AppUpdateService updateService;

  @override
  void initState() {
    super.initState();

    updateService = AppUpdateService(ApiClient());

    _initFlow();
  }
Future<void> _initFlow() async {
  debugPrint('🚀 SPLASH: START');

  await Future.delayed(const Duration(seconds: 2));

  debugPrint('🚀 SPLASH: AFTER DELAY');

  if (!mounted) return;

  try {
    debugPrint('🚀 SPLASH: BEFORE VERSION CHECK');

    final canContinue = await updateService.checkVersion(context);

    debugPrint('🚀 SPLASH: VERSION CHECK RESULT = $canContinue');

    if (!mounted) return;

    if (!canContinue) {
      debugPrint('🚨 SPLASH: BLOCKED BY VERSION CHECK');
      return;
    }

    debugPrint('🚀 SPLASH: NAVIGATING TO HOME');

    Navigator.of(context).pushReplacementNamed('/home');

  } catch (e, stack) {
    debugPrint('❌ SPLASH ERROR: $e');
    debugPrint('$stack');

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed('/home');
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade100,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/app_icon.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'MalaTrade',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Post.Sell.Grow.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.blue.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
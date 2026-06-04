import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart' as auth;
import '../../providers/api_provider.dart';


import '../../models/lodge_model.dart';
import '../../widgets/hospitality/lodge_card.dart';
import '../../theme/design_system/app_spacing.dart';

import '../../theme/app_colors.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/main_drawer.dart';
import '../../widgets/app_scaffold.dart';

class MyLodgesScreen extends ConsumerStatefulWidget {
  const MyLodgesScreen({super.key});

  @override
  ConsumerState<MyLodgesScreen> createState() =>
      _MyLodgesScreenState();
}

class _MyLodgesScreenState extends ConsumerState<MyLodgesScreen> {

  bool isLoading = true;
  List<Lodge> lodges = [];

  @override
  void initState() {
    super.initState();
    debugPrint("🚀 INIT STATE CALLED");
    fetchMyLodges();
  }

  Future<void> fetchMyLodges() async {
    try {
      debugPrint("📡 FETCH MY LODGES STARTED");

      setState(() => isLoading = true);

      final api = ref.read(apiClientProvider);

      debugPrint("🌐 CALLING API: lodges/my_lodges/");

      final response = await api.getList<Lodge>(
        "lodges/my_lodges/",
        fromJson: (json) {
          debugPrint("📦 PARSING LODGE JSON: $json");
          return Lodge.fromJson(json);
        },
      );

      debugPrint("✅ API RETURNED: ${response.length} lodges");

      for (var l in response) {
        debugPrint("🏠 Lodge: ${l.name} | ID: ${l.id}");
      }

      setState(() {
        lodges = response;
      });

    } catch (e, stack) {
      debugPrint("❌ ERROR loading lodges: $e");
      debugPrint("📌 STACK TRACE: $stack");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load lodges")),
      );

    } finally {
      debugPrint("🏁 FETCH COMPLETE");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    debugPrint("BUILD RUNNING - lodges: ${lodges.length}");

    final authState = ref.watch(auth.authProvider);
    final user = authState.user;

    debugPrint("CURRENT USER: ${user?.id}");

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('My Lodge'),),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())

          : lodges.isEmpty
              ? const Center(child: Text("No lodges found"))

              : RefreshIndicator(
                  onRefresh: fetchMyLodges,
                  child: ListView.builder(
                    padding: EdgeInsets.all(AppSpacing.md),
                    itemCount: lodges.length,

                    itemBuilder: (context, index) {
                      final lodge = lodges[index];

                      final isOwner =
                          user?.id != null &&
                          lodge.ownerId != null &&
                          user!.id == lodge.ownerId;

                      debugPrint(
                        "🔐 OWNER CHECK => Lodge: ${lodge.name} | "
                        "User: ${user?.id} | Owner: ${lodge.ownerId} | "
                        "isOwner: $isOwner",
                      );

                      return LodgeCard(
                        lodge: lodge,
                        isOwner: isOwner,
                      );
                    },
                  ),
                ),
    );
  }
}
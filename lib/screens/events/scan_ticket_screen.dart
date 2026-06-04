import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

import '../../core/api/api_client.dart';
import '../../utils/app_toast.dart';
import '../../widgets/main_app_bar.dart';
import '../../theme/design_system/app_spacing.dart';
// Import your Analytics Service
import '../../services/analytics_service.dart';

class ScanTicketScreen extends StatefulWidget {
  const ScanTicketScreen({super.key});

  @override
  State<ScanTicketScreen> createState() => _ScanTicketScreenState();
}

class _ScanTicketScreenState extends State<ScanTicketScreen> {
  final ApiClient api = ApiClient();
  final AudioPlayer player = AudioPlayer();
  final AnalyticsService analyticsService = AnalyticsService();

  bool isProcessing = false;
  Map<String, dynamic>? ticketData;
  bool isSuccess = false;

  @override
  void initState() {
    super.initState();
    
    // Track when the user opens the ticket scanning scanner panel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      analyticsService.logEvent('view_ticket_scanner');
    });
  }

  // =========================
  // SOUND HELPERS
  // =========================
  Future<void> playSuccess() async {
    await player.play(AssetSource('sounds/success.mp3'));
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 200);
    }
  }

  Future<void> playError() async {
    await player.play(AssetSource('sounds/error.mp3'));
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 400);
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (isProcessing) return;

    final code = capture.barcodes.first.rawValue;
    if (code == null) return;

    setState(() {
      isProcessing = true;
      isSuccess = false;
    });

    try {
      analyticsService.logEvent('qr_code_detected');

      final response = await api.post(
        'tickets/check-in/',
        data: {"qr_code": code.toString()},
        fromJson: (json) => json,
      );

      if (!mounted) return;

      // SUCCESS
      await playSuccess();

      AppToast.success(
        context,
        response['message'] ?? "Check-in successful",
      );

      // Track successful check-in
      final responseData = response['data'];
      final eventId = responseData?['event_id'] ?? 'unknown';
      analyticsService.logEvent('ticket_checkin_success_event_id_$eventId');

      setState(() {
        ticketData = responseData;
        isSuccess = true;
      });

    } catch (e) {
      await playError();

      String message = "Something went wrong";

      if (e is Exception) {
        message = e.toString().replaceAll("Exception: ", "");
      }

      // 🔥 TRY TO GET REAL BACKEND MESSAGE (DIO)
      if (e.toString().contains("DioException")) {
        try {
          final dioError = e as dynamic;
          final responseData = dioError.response?.data;

          if (responseData != null &&
              responseData is Map &&
              responseData['message'] != null) {
            message = responseData['message'];
          }
        } catch (_) {
          message = "Request failed. Please try again.";
        }
      }

      analyticsService.logEvent('ticket_checkin_failed');
      AppToast.error(context, message);
    }

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => isProcessing = false);
    }
  }

  void _resetScanner() {
    analyticsService.logEvent('click_scan_next_ticket');
    setState(() {
      ticketData = null;
      isProcessing = false;
      isSuccess = false;
    });
  }

  // =========================
  // SCANNER FRAME OVERLAY
  // =========================
  Widget _scannerFrame() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSuccess ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.error,
            width: 3,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.qr_code_scanner,
            color: Theme.of(context).colorScheme.surface,
            size: 40,
          ),
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text("$title: ${value ?? ''}"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ticketData == null
        ? Stack(
            children: [
              MobileScanner(onDetect: _onDetect),
              _scannerFrame(),
            ],
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "CHECK-IN SUCCESSFUL",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                _infoTile("Event", ticketData!['event_title']),
                _infoTile("Ticket", ticketData!['ticket_number']),
                _infoTile("Attendee", ticketData!['attendee_name']),

                const SizedBox(height: AppSpacing.md),

                const Text(
                  "Ticket Items",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                if (ticketData!['ticket_items'] != null)
                  ...List.generate(
                    (ticketData!['ticket_items'] as List).length,
                    (i) {
                      final item = ticketData!['ticket_items'][i];
                      return Text(
                        "• ${item['name']} (${item['type']}) x${item['quantity']}",
                      );
                    },
                  ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _resetScanner,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text("Scan Next Ticket"),
                  ),
                ),
              ],
            ),
          );
  }
}
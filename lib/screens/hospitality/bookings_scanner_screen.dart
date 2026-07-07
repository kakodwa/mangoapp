import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

import '../../providers/api_provider.dart';
import '../../utils/app_toast.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../widgets/web_footer.dart';

class BookingQrScannerScreen extends ConsumerStatefulWidget {
  const BookingQrScannerScreen({super.key});

  @override
  ConsumerState<BookingQrScannerScreen> createState() =>
      _BookingQrScannerScreenState();
}

class _BookingQrScannerScreenState
    extends ConsumerState<BookingQrScannerScreen> {
  final AudioPlayer player = AudioPlayer();

  bool isProcessing = false;
  bool isSuccess = false;

  Map<String, dynamic>? bookingData;





  // =========================
  // SOUND + VIBRATION
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

  // =========================
  // SCAN LOGIC
  // =========================
  void _onDetect(BarcodeCapture capture) async {
    if (isProcessing) return;

    final code = capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      isProcessing = true;
      isSuccess = false;
    });

  try {
  final api = ref.read(apiClientProvider);

  final res = await api.post(
    "bookings/scan_qr/",
    data: {"qr_data": code.trim()},
    fromJson: (json) => json,
  );

  await playSuccess();

  setState(() {
    bookingData = res;
    isSuccess = true;
  });

  AppToast.success(
    context,
    res['message'] ?? "Check-in successful",
  );
} catch (e) {
  await playError();

  AppToast.error(context, "Invalid QR or scan failed");
}
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => isProcessing = false);
    }
  }

  // =========================
  // RESET SCANNER
  // =========================
  void _reset() {
    setState(() {
      bookingData = null;
      isProcessing = false;
      isSuccess = false;
    });
  }

  // =========================
  // SCANNER FRAME (FORT STYLE)
  // =========================
  Widget _scannerFrame() {
    return Center(
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSuccess ? Colors.green : Colors.redAccent,
            width: 3,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.qr_code_scanner,
            size: 40,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // =========================
  // INFO TILE
  // =========================
  Widget _infoTile(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text("$title: $value"),
    );
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Booking Scanner"),
        actions: [
          if (bookingData != null)
            IconButton(
              onPressed: _reset,
              icon: const Icon(Icons.refresh),
            )
        ],
      ),

      body: bookingData == null
          // =========================
          // CAMERA MODE
          // =========================
          ? Stack(
              children: [
                MobileScanner(onDetect: _onDetect),
                _scannerFrame(),
              ],
            )

          // =========================
          // RESULT MODE
          // =========================
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "CHECK-IN SUCCESSFUL",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _infoTile("Booking Ref", bookingData!['booking_reference']),
                  _infoTile("Room", bookingData!['room_number']),
                  _infoTile("Status", bookingData!['booking_status']),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text("Scan Next Booking"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
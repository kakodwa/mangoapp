// lib/screens/hospitality/bookings_scanner_screen.dart

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

class _BookingQrScannerScreenState extends ConsumerState<BookingQrScannerScreen> {
  final AudioPlayer player = AudioPlayer();
  
  // Controller to manually toggle camera hardware states
  late final MobileScannerController _scannerController;

  bool isCameraInitialized = false;
  bool isProcessing = false;
  bool isSuccess = false;
  Map<String, dynamic>? bookingData;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      autoStart: false,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    player.dispose();
    super.dispose();
  }

  void _startCameraScanner() async {
    setState(() {
      isCameraInitialized = true;
    });
    try {
      await _scannerController.start();
    } catch (e) {
      AppToast.error(context, "Could not access hardware camera channel.");
      setState(() {
        isCameraInitialized = false;
      });
    }
  }

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
      await _scannerController.stop();

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
  void _resetScanner() async {
    setState(() {
      bookingData = null;
      isProcessing = false;
      isSuccess = false;
    });
    await _scannerController.start();
  }

  // =========================
  // SCANNER FRAME
  // =========================
  Widget _scannerFrame() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSuccess ? Theme.of(context).colorScheme.secondary : Colors.orange,
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

  // =========================
  // INFO TILE
  // =========================
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
        child: Text("$title: $value"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: bookingData == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: AppSpacing.lg),
                        if (!isCameraInitialized)
                          Container(
                            width: double.infinity,
                            height: 350,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey.shade500),
                                const SizedBox(height: AppSpacing.sm),
                                ElevatedButton(
                                  onPressed: _startCameraScanner,
                                  child: const Text("Start Camera Scanner"),
                                ),
                              ],
                            ),
                          )
                        else
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              height: 400,
                              child: Stack(
                                children: [
                                  MobileScanner(
                                    controller: _scannerController,
                                    onDetect: _onDetect,
                                  ),
                                  _scannerFrame(),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    )
                  : Column(
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
                        _infoTile("Booking Ref", bookingData!['booking_reference'] ?? ''),
                        _infoTile("Room", bookingData!['room_number'] ?? ''),
                        _infoTile("Status", bookingData!['booking_status'] ?? ''),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _resetScanner,
                            icon: const Icon(Icons.qr_code_scanner),
                            label: const Text("Scan Next Booking"),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 40),
          const WebFooter(),
        ],
      ),
    );
  }
}
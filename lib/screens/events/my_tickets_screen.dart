import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

import '../../utils/download_permissions.dart';


import '../../providers/tickets_provider.dart';
import '../../theme/app_colors.dart';
import 'ticket_detail_screen.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/app_scaffold.dart';

import 'package:flutter/foundation.dart';


class MyTicketsScreen extends ConsumerStatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  ConsumerState<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends ConsumerState<MyTicketsScreen> {
  final Map<int, GlobalKey> ticketKeys = {};


Future<void> captureTicket(GlobalKey key) async {
  try {

    final boundary =
        key.currentContext!.findRenderObject()
            as RenderRepaintBoundary;

    final image = await boundary.toImage(pixelRatio: 3.0);

    final byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    final pngBytes = byteData!.buffer.asUint8List();

    // ================= WEB =================
    if (kIsWeb) {

      await Share.shareXFiles(
        [
          XFile.fromData(
            pngBytes,
            mimeType: 'image/png',
            name: 'ticket.png',
          ),
        ],
        text: "🎟 My Event Ticket",
      );

      return;
    }

    // ================= MOBILE =================

    final allowed = await requestStoragePermission();

    if (!allowed) {

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Storage permission denied",
            ),
          ),
        );
      }

      return;
    }

    // Save directly to Downloads folder
    final downloadsDir =
        Directory('/storage/emulated/0/Download');

    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    final fileName =
        'ticket_${DateTime.now().millisecondsSinceEpoch}.png';

    final filePath =
        path.join(downloadsDir.path, fileName);

    final file = File(filePath);

    await file.writeAsBytes(pngBytes);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Ticket saved to Downloads",
          ),
        ),
      );
    }

    // Optional share after save
    await Share.shareXFiles(
      [XFile(file.path)],
      text: "🎟 My Event Ticket",
    );

  } catch (e) {

    debugPrint("Capture error: $e");

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to save ticket",
          ),
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final ticketsAsync = ref.watch(myTicketsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('My Tickets'),),
      body: ticketsAsync.when(
        data: (tickets) {
          if (tickets.isEmpty) {
            return const Center(child: Text("No tickets yet"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];

              // create unique key per ticket
              ticketKeys.putIfAbsent(
                ticket.id,
                () => GlobalKey(),
              );

              final key = ticketKeys[ticket.id]!;

              return Column(
                children: [
                  RepaintBoundary(
                    key: key,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TicketDetailScreen(ticket: ticket),
                            ),
                          );
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // LEFT QR
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.mangoLight
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ticket.qrCodeUrl != null
                                  ? ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      child: Image.network(
                                        ticket.qrCodeUrl!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      Icons.confirmation_number,
                                      color: AppColors.mangoOrange,
                                    ),
                            ),

                            const SizedBox(width: 12),

                            // CENTER CONTENT
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ticket.eventTitle,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text(context),
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children:
                                        ticket.items.map((item) {
                                      return Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.mangoOrange
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(
                                                  8),
                                        ),
                                        child: Text(
                                          "${item.ticketTypeName} ×${item.quantity}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                AppColors.mangoOrange,
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    "MWK ${ticket.totalAmount.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text(context),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: ticket.paymentStatus ==
                                              "paid"
                                          ? AppColors.leafGreen
                                              .withOpacity(0.15)
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      ticket.paymentStatus
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            ticket.paymentStatus ==
                                                    "paid"
                                                ? AppColors.leafGreen
                                                : Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ================= DOWNLOAD BUTTON =================
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () =>
                            captureTicket(key),
                        icon: const Icon(Icons.download),
                        label: const Text("Download Ticket"),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
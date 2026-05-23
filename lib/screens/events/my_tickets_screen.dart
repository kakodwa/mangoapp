import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/tickets_provider.dart';
import '../../theme/app_colors.dart';
import 'ticket_detail_screen.dart';
import '../../widgets/app_scaffold.dart';

import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:io' as io;
import '../../theme/design_system/app_spacing.dart';

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
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // ===================== WEB =====================
    if (kIsWeb) {
      final blob = html.Blob([pngBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "ticket.png")
        ..click();

      html.Url.revokeObjectUrl(url);
      return;
    }

    // ===================== MOBILE (Android / iOS) =====================
    final dir = await getTemporaryDirectory();
    final file = io.File('${dir.path}/ticket.png');

    await file.writeAsBytes(pngBytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: "🎟 My Event Ticket",
    );
  } catch (e) {
    debugPrint("Capture error: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    final ticketsAsync = ref.watch(myTicketsProvider);

    return AppScaffold(
      appBar: AppBar(
        title: const Text("My Tickets"),
      ),
      body: ticketsAsync.when(
        data: (tickets) {
          if (tickets.isEmpty) {
            return const Center(child: Text("No tickets yet"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.sm),
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
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
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

                            const SizedBox(width: AppSpacing.sm),

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

                                  const SizedBox(height: AppSpacing.xs),

                                  Text(
                                    "MWK ${ticket.totalAmount.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text(context),
                                    ),
                                  ),

                                  const SizedBox(height: AppSpacing.xs),

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
                                          : Theme.of(context).colorScheme.error.withOpacity(0.1),
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
                                                : Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
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
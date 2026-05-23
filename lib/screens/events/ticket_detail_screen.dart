import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_system/app_spacing.dart';

class TicketDetailScreen extends StatelessWidget {
  final dynamic ticket;

  const TicketDetailScreen({
    super.key,
    required this.ticket,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("My Ticket"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // ================= TICKET CARD =================
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                children: [
                  // ================= HEADER =================
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.mangoOrange,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.eventTitle,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Ticket #: ${ticket.ticketNumber}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // ================= QR CODE =================
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    child: ticket.qrCodeUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              ticket.qrCodeUrl,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            height: 220,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.qr_code,
                              size: 120,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // ================= DETAILS =================
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow(context, "Quantity", "${ticket.quantity}"),
                        _infoRow(context, "Total", "MWK ${ticket.totalAmount}"),

                        const SizedBox(height: 10),

                        // ================= ITEMS =================
                        if (ticket.items != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Ticket Types",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),

                              ...ticket.items.map<Widget>((item) {
                                return Container(
                                  margin: EdgeInsets.only(bottom: 6),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(item.ticketTypeName ?? ""),
                                      Text("x${item.quantity}"),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),

                        const SizedBox(height: AppSpacing.md),

                        // ================= STATUS =================
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: ticket.paymentStatus == "paid"
                                ? AppColors.leafGreen.withOpacity(0.15)
                                : Theme.of(context).colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            ticket.paymentStatus.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ticket.paymentStatus == "paid"
                                  ? AppColors.leafGreen
                                  : Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        Text(
                          "Show this QR code at the entrance",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title, style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

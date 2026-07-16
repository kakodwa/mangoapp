// lib/screens/events/ticket_detail_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../widgets/web_footer.dart';

class TicketDetailScreen extends StatelessWidget {
  final dynamic ticket;

  const TicketDetailScreen({
    super.key,
    required this.ticket,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 650;
    
    // Grid alignment parameters for the sub-ticket breakdown list
    final int crossAxisCount = isMobile ? 1 : 2;
    final double crossAxisSpacing = AppSpacing.md;
    final double mainAxisSpacing = AppSpacing.md;
    
    // Extract ticket items cleanly safely
    final List<dynamic> subItems = ticket.items ?? [];

    return CustomScrollView(
      slivers: [
        // ================= HERO PRESENTATION HEADER & QR DISPLAY =================
        SliverPadding(
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: !isMobile ? (screenWidth - 850) / 2 : AppSpacing.md,
          ),
          sliver: SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  // Dynamic Top Header Banner
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: const BoxDecoration(
                      color: AppColors.mangoOrange,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.eventTitle ?? "Event Ticket",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Ticket #: ${ticket.ticketNumber ?? ''}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Core Verification QR Code
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: ticket.qrCodeUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              ticket.qrCodeUrl,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            height: 200,
                            width: 200,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.qr_code_2,
                              size: 110,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                  ),

                  // Aggregated Financial Metrics Block
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Column(
                      children: [
                        _infoRow(context, "Global Aggregated Quantity", "${ticket.quantity ?? 0}"),
                        _infoRow(context, "Total Amount Transacted", "MWK ${ticket.totalAmount ?? 0}"),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: ticket.paymentStatus == "paid"
                                ? AppColors.leafGreen.withOpacity(0.12)
                                : Theme.of(context).colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            (ticket.paymentStatus ?? "unpaid").toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ticket.paymentStatus == "paid"
                                  ? AppColors.leafGreen
                                  : Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),

        // ================= ADAPTIVE SUB-TICKETS TITLE HEADER =================
        if (subItems.isNotEmpty)
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: !isMobile ? (screenWidth - 850) / 2 : AppSpacing.md,
            ),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Associated Live Sub-Ticket Matrix",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          ),

        // ================= RESPONSIVE LAYOUT GRID =================
        if (subItems.isNotEmpty)
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: !isMobile ? (screenWidth - 850) / 2 : AppSpacing.md,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: mainAxisSpacing,
                crossAxisSpacing: crossAxisSpacing,
                childAspectRatio: isMobile ? 4.5 : 3.5,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = subItems[index];
                  return Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.ticketTypeName ?? "Standard Entry",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Validation Queue Dynamic Item",
                                style: TextStyle(
                                  fontSize: 11, 
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.mangoOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "x${item.quantity ?? 0}",
                            style: const TextStyle(
                              color: AppColors.mangoOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: subItems.length,
              ),
            ),
          ),

        // ================= FOOTER ATTACHMENT =================
        const SliverToBoxAdapter(
          child: SizedBox(height: 60),
        ),
        const SliverToBoxAdapter(
          child: WebFooter(),
        ),
      ],
    );
  }

  Widget _infoRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
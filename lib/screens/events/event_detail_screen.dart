// lib/screens/events/event_detail_screen.dart

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../widgets/web_footer.dart';
import '../../widgets/reviews/review_section_widget.dart';
import '../../providers/auth_provider.dart';
import '../../models/event_model.dart';
import '../../models/event_ticket_type_model.dart';
import '../../utils/app_toast.dart';
import '../../theme/app_colors.dart';
import '../../widgets/shop_map_modal.dart';
import 'buy_ticket_screen.dart';
import '../auth/login_screen.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/app_fab.dart';
import '../../theme/design_system/app_spacing.dart';

// Analytics Import
import '../../services/analytics_service.dart';

class EventDetailScreen extends ConsumerWidget {
  final EventModel event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AnalyticsService analyticsService = AnalyticsService();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      analyticsService.logEvent('view_event_details_id_${event.id}');
    });

    final totalSeats = event.ticketTypes.fold<int>(
      0,
      (sum, item) => sum + item.totalSeats,
    );

    final availableSeats = event.ticketTypes.fold<int>(
      0,
      (sum, item) => sum + item.availableSeats,
    );

    final soldTickets = totalSeats - availableSeats;
    final soldPercentage = totalSeats == 0 ? 0.0 : soldTickets / totalSeats;

    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isAuthenticated;

    void _openWhatsApp(String phone) async {
      final uri = Uri.parse("https://wa.me/$phone");
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        AppToast.info(context, "Could not open WhatsApp");
      }
    }

    return Material(
      color: const Color(0xFFF5F7FA),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              // Allow buffer room over the persistent bottom navigation button frame
              padding: const EdgeInsets.only(bottom: 90),
              child: CustomScrollView(
                slivers: [
                  // ======================
                  // EVENT HERO BANNER
                  // ======================
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 280,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            event.banner,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.25),
                                alignment: Alignment.center,
                                child: const Icon(Icons.image, size: 50),
                              );
                            },
                          ),
                          // Modern ambient layout gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.15),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.45),
                                ],
                              ),
                            ),
                          ),
                          // Featured status badge anchor framework
                          if (event.isFeatured)
                            Positioned(
                              top: AppSpacing.sm,
                              left: AppSpacing.md,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  "FEATURED",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.surface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // ======================
                  // MAIN SUMMARY ELEMENT
                  // ======================
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(.04),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 14),
                            // Location Specifications
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text(
                                    "${event.venue}, ${event.city}",
                                    style: TextStyle(color: Colors.grey.withOpacity(0.8), fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Date Specifications
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  event.eventDate,
                                  style: TextStyle(color: Colors.grey.withOpacity(0.8), fontWeight: FontWeight.w500),
                                ),
                                const Spacer(),
                                Text(
                                  "${event.startTime} - ${event.endTime}",
                                  style: TextStyle(color: Colors.grey.withOpacity(0.8), fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            // Grid Metric Specifications Matrix Row
                            Row(
                              children: [
                                Expanded(
                                  child: statCard(
                                    title: "Tickets",
                                    value: totalSeats.toString(),
                                    icon: Icons.confirmation_num,
                                    context: context,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: statCard(
                                    title: "Available",
                                    value: availableSeats.toString(),
                                    icon: Icons.event_available,
                                    context: context,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: statCard(
                                    title: "Sold",
                                    value: soldTickets.toString(),
                                    icon: Icons.people,
                                    context: context,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            // Live Ticket Allocation Linear Progress Vector Indicator
                            LinearProgressIndicator(
                              value: soldPercentage,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(30),
                              backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.25),
                              color: AppColors.primary(context),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              "${(soldPercentage * 100).toStringAsFixed(0)}% tickets sold",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 26),
                            // Ticket Categorizations Section Header
                            const Text(
                              "Available Tickets",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 14),
                        ...event.ticketTypes.map((ticket) => ticketCard(context, ticket)),
                      ],
                    ),
                  ),
                ),
              ),

              // ======================
              // DESCRIPTION DOCUMENT FRAME
              // ======================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(.04),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Description",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          event.description,
                          style: TextStyle(
                            height: 1.6,
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ===================================
              // CUSTOMER REVIEWS SLIVER ADAPTER
              // ===================================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: ReviewSectionWidget(
                    targetType: 'event',
                    targetId: event.id,
                    isOwner: false,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 160)),
              const SliverToBoxAdapter(
                child: WebFooter(),
                ),
            ],
          ),
        ),
      ),

      // ===================================
      // UNIFIED RIGHT ACCESSIBILITY PANEL FAB SYSTEM
      // ===================================
      Positioned(
        bottom: 110, // Elevated to stack comfortably above the buy ticket bottom navigation deck
        right: 16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🗺 MAP ACTIONS FAB BOUND
            if (event.latitude != null && event.longitude != null) ...[
              AppFab(
                heroTag: "map_event_fab",
                icon: Icons.map_outlined,
                tooltip: "Open Map Tracking",
                onPressed: () {
                  analyticsService.logEvent('click_event_map_id_${event.id}');
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => ShopMapModal(
                      shopLat: event.latitude!,
                      shopLng: event.longitude!,
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
            ],

            // 💬 SOCIAL CONNECT WHATSAPP FAB BOUND
            if (event.organizerPhoneNumber != null && event.organizerPhoneNumber!.isNotEmpty) ...[
              AppFab(
                heroTag: "whatsapp_event_fab",
                icon:FontAwesomeIcons.whatsapp,
                tooltip: "Chat with Organizer",
                onPressed: () {
                  analyticsService.logEvent('click_event_whatsapp_id_${event.id}');
                  if (!isLoggedIn) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                    return;
                  }
                  final phone = event.organizerPhoneNumber;
                  if (phone == null || phone.isEmpty) {
                    AppToast.info(context, "No WhatsApp coordinate setup available");
                    return;
                  }
                  _openWhatsApp(phone);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
            ],



AppFab(
  heroTag: "share_event_fab",
  icon: Icons.share_outlined,
  tooltip: "Share Event",
  onPressed: () async {
    // 🌟 Capture layout context safely prior to triggering the async share engine
    final RenderBox? box = context.findRenderObject() as RenderBox?;

    final String eventUrl = "${Uri.base.origin}/event/${event.id}"; // cite: event_detail_screen.dart

    final String shareMessage = "🎫 *${event.title}*\n" // cite: event_detail_screen.dart
        "📅 Date: ${event.eventDate}\n" // cite: event_detail_screen.dart
        "📍 Venue: ${event.venue}, ${event.city}\n\n" // cite: event_detail_screen.dart
        "🔗 Book ticket allocations safely here:\n$eventUrl"; // cite: event_detail_screen.dart

    analyticsService.logEvent('event_shared_${event.id}'); // cite: event_detail_screen.dart

    // 🌟 Create anchor coordinate bounds fallback to ensure stability on mobile viewports
    final Rect shareBounds = box != null 
        ? (box.localToGlobal(Offset.zero) & box.size)
        : const Rect.fromLTWH(0, 0, 100, 100);

    try {
      await Share.share(
        shareMessage, // cite: event_detail_screen.dart
        subject: 'Look what I found on Mangochi!', // cite: event_detail_screen.dart
        sharePositionOrigin: shareBounds,
      );
    } catch (e) {
      debugPrint("Event sharing failed: $e");
    }
  },
),
          ],
        ),
      ),

      // =========================
      // BUY TRANSACTION SYSTEM NAVIGATION RAIL
      // =========================
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(.06),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.confirmation_num, color: Colors.white),
                label: const Text(
                  "Buy Ticket",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  analyticsService.logEvent('click_buy_ticket_button_event_id_${event.id}');

                  if (event.ticketTypes.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No ticket inventory allotments published yet")),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BuyTicketScreen(event: event),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ],
  ),
);
}

  Widget statCard({
    required String title,
    required String value,
    required IconData icon,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary(context)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget ticketCard(BuildContext context, EventTicketTypeModel ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary(context).withOpacity(.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.confirmation_num, color: AppColors.primary(context)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.name.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  "${ticket.availableSeats} seats available",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            "MWK ${ticket.price.toStringAsFixed(0)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primary(context),
            ),
          ),
        ],
      ),
    );
  }
}
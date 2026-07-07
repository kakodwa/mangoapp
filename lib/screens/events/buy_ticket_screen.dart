import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../models/event_model.dart';
import '../../utils/app_toast.dart';
import '../payments/payment_checkout_screen.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../widgets/web_footer.dart';
import '../../widgets/main_drawer.dart';
import '../../widgets/main_app_bar.dart';
import '../../services/analytics_service.dart';

class SelectedTicket {
  final int id;
  final String name;
  final double price;
  int quantity;

  SelectedTicket({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 0,
  });
}

class BuyTicketScreen extends StatefulWidget {
  final EventModel event;

  const BuyTicketScreen({
    super.key,
    required this.event,
  });

  @override
  State<BuyTicketScreen> createState() => _BuyTicketScreenState();
}

class _BuyTicketScreenState extends State<BuyTicketScreen> {
  bool loading = false;
  final ApiClient api = ApiClient();
  final AnalyticsService analyticsService = AnalyticsService();
  List<SelectedTicket> selectedTickets = [];

  @override
  void initState() {
    super.initState();

    // Track when the user opens the ticket selection view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      analyticsService.logEvent('view_ticket_selection_event_id_${widget.event.id}');
    });

    // ================= INIT TICKETS =================
    selectedTickets = widget.event.ticketTypes.map((t) {
      print("TICKET TYPE => ${t.id} ${t.name}");

      return SelectedTicket(
        id: t.id,
        name: t.name,
        price: t.price,
        quantity: 0,
      );
    }).toList();
  }

  // ================= TOTAL =================
  double get total {
    return selectedTickets.fold(
      0,
      (sum, t) => sum + (t.price * t.quantity),
    );
  }

  // ================= BUY =================
  Future<void> buyTicket() async {
    try {
      setState(() => loading = true);

      final ticketData = selectedTickets
          .where((t) => t.quantity > 0)
          .map((t) => {
                "ticket_type_id": t.id,
                "quantity": t.quantity,
              })
          .toList();

      // ================= VALIDATION =================
      if (ticketData.isEmpty) {
        analyticsService.logEvent('validation_failed_zero_tickets_event_id_${widget.event.id}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Select at least one ticket",
            ),
          ),
        );
        return;
      }

      // Track purchase checkout intention right before API invocation
      analyticsService.logEvent('click_confirm_ticket_purchase_event_id_${widget.event.id}');

      // ================= DEBUG =================
      print("========== REQUEST ==========");
      print({
        "event_id": widget.event.id,
        "tickets": ticketData,
      });
      print("=============================");

      // ================= API =================
      final res = await api.post(
        'tickets/purchase/',
        data: {
          "event_id": widget.event.id,
          "tickets": ticketData,
        },
        fromJson: (json) => json,
      );

      print("TICKET RESPONSE => $res");

      final ticket = res['ticket'];

      if (ticket == null) {
        throw Exception("Ticket not returned");
      }

      final int ticketId = ticket['id'];

      final double amount = double.tryParse(
            ticket['total_amount'].toString(),
          ) ??
          0;

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentCheckoutScreen(
            transactionId: ticketId,
            amount: amount,
            purpose: "event_ticket",
            referenceType: "ticket",
          ),
        ),
      );
    } on DioException catch (e) {
      print("BUY ERROR STATUS => ${e.response?.statusCode}");
      print("BUY ERROR DATA => ${e.response?.data}");

      String message = "Request failed";
      final data = e.response?.data;

      if (data is Map) {
        if (data["error"] != null) {
          message = data["error"].toString();
        } else if (data["errors"] != null) {
          final errors = data["errors"];

          if (errors is Map && errors.isNotEmpty) {
            final firstKey = errors.keys.first;
            final firstValue = errors[firstKey];

            if (firstValue is List && firstValue.isNotEmpty) {
              message = firstValue.first.toString();
            } else {
              message = firstValue.toString();
            }
          }
        } else if (data.values.isNotEmpty) {
          final first = data.values.first;
          if (first is List && first.isNotEmpty) {
            message = first.first.toString();
          } else {
            message = first.toString();
          }
        }
      } else if (data is String) {
        message = data;
      }

      analyticsService.logEvent('error_ticket_purchase_api_event_id_${widget.event.id}');
      AppToast.error(context, message);
    } catch (e) {
      print("BUY ERROR => $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Ticket'), // Fixed structural typo from 'Bay Ticket'
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // ================= TITLE =================
            Text(
              widget.event.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ================= TICKETS =================
            Expanded(
              child: ListView(
                children: selectedTickets.map((t) {
                  return Container(
                    margin: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.name.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              "MWK ${t.price.toStringAsFixed(0)}",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // ================= MINUS =================
                        IconButton(
                          onPressed: () {
                            if (t.quantity > 0) {
                              analyticsService.logEvent('decrement_ticket_id_${t.id}_event_id_${widget.event.id}');
                              setState(() {
                                t.quantity--;
                              });
                            }
                          },
                          icon: const Icon(Icons.remove),
                        ),

                        Text(
                          t.quantity.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // ================= ADD =================
                        IconButton(
                          onPressed: () {
                            analyticsService.logEvent('increment_ticket_id_${t.id}_event_id_${widget.event.id}');
                            setState(() {
                              t.quantity++;
                            });
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            // ================= TOTAL =================
            Text(
              "Total: MWK ${total.toStringAsFixed(0)}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // ================= BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : buyTicket,
                child: loading
                    ? CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.surface,
                      )
                    : const Text(
                        "Confirm Purchase",
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
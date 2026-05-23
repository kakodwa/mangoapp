import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/payment_model.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/main_drawer.dart';
import '../../widgets/app_scaffold.dart';

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final paymentsAsync = ref.watch(myPaymentsProvider);

    return AppScaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const MainAppBar(title: 'Payment History'),
      body: paymentsAsync.when(

        data: (payments) {

          if (payments.isEmpty) {
            return const Center(
              child: Text("No payments found"),
            );
          }

          return ListView.builder(
            itemCount: payments.length,

            itemBuilder: (context, index) {

              final payment = payments[index];

              return Card(
                margin: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                child: ListTile(

                  leading: Icon(
                    payment.status == "completed"
                        ? Icons.check_circle
                        : Icons.pending,

                    color: payment.status == "completed"
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary,
                  ),

                  title: Text(
                    "MWK ${payment.amount}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(payment.purposeDisplay),

                      Text(payment.paymentMethodDisplay),

                      if (payment.orderNumber != null)
                        Text(
                          "Order: ${payment.orderNumber}"
                        ),

                      if (payment.propertyTitle != null)
                        Text(payment.propertyTitle!),

                      Text(payment.paymentReference),
                    ],
                  ),

                  trailing: Text(
                    payment.statusDisplay,
                    style: TextStyle(
                      color: payment.status == "completed"
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              );
            },
          );
        },

        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (e, _) => Center(
          child: Text("Error: $e"),
        ),
      ),
    );
  }
}
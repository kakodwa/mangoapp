import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/products_provider.dart';
<<<<<<< HEAD
import '../../theme/design_system/app_button.dart';
=======
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
import '../../providers/api_provider.dart';
import 'checkout_screen.dart';
import '../../widgets/main_app_bar.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: const MainAppBar(title: 'Shopping Cart'),
      backgroundColor: const Color(0xFFF6F7FB),

      body: cart.isEmpty
          ? Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_cart_outlined,
                        size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Add items to get started',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Continue Shopping'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [

                // =========================
                // CART ITEMS
                // =========================
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cart[index];

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          children: [

                            // IMAGE
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey[200],
                                child: item.product.hasImage
                                    ? Image.network(
                                        item.product.safeImage ?? '',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.image),
                                      )
                                    : const Icon(Icons.image),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // DETAILS
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    "MWK ${item.product.price.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // =========================
                                  // QUANTITY CONTROL (MODERN)
                                  // =========================
<<<<<<< HEAD
           
Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 4,
  ),
  decoration: BoxDecoration(
    color: Colors.grey[100],
    borderRadius: BorderRadius.circular(20),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    GestureDetector(
  onTap: () {
    if (item.quantity > 1) {
      final updatedCart = [...cart];

      updatedCart[index] = CartItem(
        product: item.product,
        quantity: item.quantity - 1,
      );

      ref
          .read(cartProvider.notifier)
          .state = updatedCart;
    }
  },
  child: const Icon(
    Icons.remove,
    size: 18,
  ),
),

Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 10,
  ),
  child: Text(
    item.quantity.toString(),
    style: const TextStyle(
      fontWeight: FontWeight.bold,
    ),
  ),
),

GestureDetector(
  onTap: () {
    if (item.quantity <
        item.product.stock) {
      final updatedCart = [...cart];

      updatedCart[index] = CartItem(
        product: item.product,
        quantity: item.quantity + 1,
      );

      ref
          .read(cartProvider.notifier)
          .state = updatedCart;
    }
  },
  child: const Icon(
    Icons.add,
    size: 18,
  ),
),
    ],
  ),
),
=======
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [

                                        GestureDetector(
                                          onTap: () {
                                            if (item.quantity > 1) {
                                              item.quantity--;
                                              ref.refresh(cartProvider);
                                            }
                                          },
                                          child: const Icon(
                                            Icons.remove,
                                            size: 18,
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Text(
                                            item.quantity.toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        GestureDetector(
                                          onTap: () {
                                            if (item.quantity <
                                                item.product.stock) {
                                              item.quantity++;
                                              ref.refresh(cartProvider);
                                            }
                                          },
                                          child: const Icon(
                                            Icons.add,
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                                ],
                              ),
                            ),

                            // REMOVE
                            IconButton(
                              onPressed: () {
                                ref
                                    .read(removeFromCartProvider)
                                    .call(item.product.id);
                              },
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // =========================
                // CHECKOUT SUMMARY (STICKY)
                // =========================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      )
                    ],
                  ),
                  child: Column(
                    children: [

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Items (${cart.length})",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "MWK ${total.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Shipping"),
                          Text("MWK 0.00"),
                        ],
                      ),

                      const Divider(height: 20),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "MWK ${total.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

<<<<<<< HEAD
                      AppButton(
                        text: "Checkout",
                        fullWidth: true,
                         onPressed: () {
=======
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CheckoutScreen(
                                  items: cart,
                                  total: total,
                                ),
                              ),
                            );
                          },
<<<<<<< HEAD
                        ),
=======
                          child: const Text("Proceed to Checkout"),
                        ),
                      ),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
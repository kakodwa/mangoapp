// lib/screens/cart/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/web_footer.dart';
import '../../providers/products_provider.dart';
import '../../theme/design_system/app_button.dart';
import '../../providers/api_provider.dart';
import '../../utils/app_toast.dart';
import '../main_tabs_screen.dart'; 
import 'checkout_screen.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({Key? key}) : super(key: key);

  String _formatAttributes(Map<String, dynamic>? attributes) {
    if (attributes == null || attributes.isEmpty) return "Standard Option";
    return attributes.entries.map((e) => "${e.key}: ${e.value}").join(", ");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Material(
      color: const Color(0xFFF5F7FA),
      child: cart.isEmpty
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
                    Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
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
                  ],
                ),
              ),
            )
          : CustomScrollView( // ✅ FIXED: Whole body is now a single unified scroll canvas
              slivers: [
                // ========================================================
                // 1. LIST OF CART ITEMS
                // ========================================================
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = cart[index];
                        final liveProductAsync = ref.watch(productDetailsProvider(item.product.id));
                        final int maxAvailableStock = item.variant != null ? item.variant!.stock : item.product.stock;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Container(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                            errorBuilder: (_, __, ___) => const Icon(Icons.image),
                                          )
                                        : const Icon(Icons.image),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // DETAILS
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      const SizedBox(height: 6),

                                      liveProductAsync.when(
                                        loading: () => const Text("Loading options...", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                        error: (_, __) => Text("Options: ${_formatAttributes(item.variant?.attributes)}", style: const TextStyle(fontSize: 11)),
                                        data: (liveProduct) {
                                          if (liveProduct.variants.isEmpty) return const SizedBox.shrink();

                                          final selectedValue = liveProduct.variants.any((v) => _formatAttributes(v.attributes) == _formatAttributes(item.variant?.attributes))
                                              ? liveProduct.variants.firstWhere((v) => _formatAttributes(v.attributes) == _formatAttributes(item.variant?.attributes))
                                              : liveProduct.variants.first;

                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade50,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.orange.shade200, width: 1),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<dynamic>(
                                                value: selectedValue,
                                                isDense: true,
                                                dropdownColor: Colors.white,
                                                icon: Icon(Icons.arrow_drop_down, color: Colors.orange.shade900, size: 20),
                                                style: TextStyle(fontSize: 12, color: Colors.orange.shade900, fontWeight: FontWeight.w600),
                                                onChanged: (newVariant) {
                                                  if (newVariant != null) {
                                                    ref.read(removeFromCartProvider).call(item.product.id, item.variant?.attributes);
                                                    ref.read(addToCartProvider).call(liveProduct, item.quantity, newVariant);
                                                    AppToast.success(context, "Option selected successfully!");
                                                  }
                                                },
                                                items: liveProduct.variants.map((v) {
                                                  final bool isNoStock = v.stock <= 0;
                                                  return DropdownMenuItem<dynamic>(
                                                    value: v,
                                                    enabled: !isNoStock,
                                                    child: Text(
                                                      "${_formatAttributes(v.attributes)}" + (isNoStock ? " (SOLD OUT)" : " (Stock: ${v.stock})"),
                                                      style: TextStyle(
                                                        color: isNoStock ? Colors.grey.shade400 : Colors.black87,
                                                        decoration: isNoStock ? TextDecoration.lineThrough : null,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "MWK ${item.product.price.toStringAsFixed(2)}",
                                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 10),

                                      // QUANTITY CONTROL
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                                                  ref.read(addToCartProvider).call(item.product, -1, item.variant);
                                                }
                                              },
                                              child: const Icon(Icons.remove, size: 18),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Text(
                                                item.quantity.toString(),
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                if (item.quantity < maxAvailableStock) {
                                                  ref.read(addToCartProvider).call(item.product, 1, item.variant);
                                                }
                                              },
                                              child: const Icon(Icons.add, size: 18),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // REMOVE BUTTON
                                IconButton(
                                  onPressed: () {
                                    ref.read(removeFromCartProvider).call(item.product.id, item.variant?.attributes);
                                  },
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: cart.length,
                    ),
                  ),
                ),

                // ========================================================
                // 2. CHECKOUT SUMMARY (NOW INLINE SCROLLABLE FOR FOOTER)
                // ========================================================
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Items (${cart.length})", style: const TextStyle(fontWeight: FontWeight.w500)),
                            Text("MWK ${total.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text("Shipping"),
                            Text("MWK 0.00"),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(
                              "MWK ${total.toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // lib/screens/cart/cart_screen.dart

AppButton(
  text: "Checkout",
  fullWidth: true,
  onPressed: () {
    // Look up the parent MainTabsScreen instance context safely
    final tabsScreen = MainTabsScreen.of(context);
    
    if (tabsScreen != null) {
      // ✅ Triggers seamless tab shifting to index 41 inline!
      tabsScreen.navigateToCheckout(cart, total);
    } else {
      // Fallback route push to ensure it doesn't break if loaded standalone
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CheckoutScreen(items: cart, total: total),
        ),
      );
    }
  },
),
                      ],
                    ),
                  ),
                ),

                // ========================================================
                // 3. WEB FOOTER (REACHABLE AT THE VERY BOTTOM)
                // ========================================================
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 24.0),
                    child: WebFooter(),
                  ),
                ),
              ],
            ),
    );
  }
}
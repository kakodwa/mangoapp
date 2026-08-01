// lib/screens/orders/orders_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/order_model.dart';
import '../../models/delivery.dart';
import '../../providers/api_provider.dart';
import '../../widgets/web_footer.dart';

// Navigation Shell Import
import '../main_tabs_screen.dart';

// Design System Imports
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_badge.dart';
import '../../theme/design_system/app_loader.dart';
import '../../theme/design_system/app_info_box.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';
import '../../theme/app_colors.dart';
import '../../utils/price_helper.dart';

extension CapitalizeString on String {
  String toCapitalized() {
    if (isEmpty) return this;
    final lower = toLowerCase();
    return "${lower[0].toUpperCase()}${lower.substring(1)}";
  }
}

// Widget that fetches & renders masked customer delivery code FOR A SPECIFIC SELLER
class SellerDeliveryCodeWidget extends ConsumerStatefulWidget {
  final int orderId;
  final int sellerId;

  const SellerDeliveryCodeWidget({
    Key? key,
    required this.orderId,
    required this.sellerId,
  }) : super(key: key);

  @override
  ConsumerState<SellerDeliveryCodeWidget> createState() =>
      _SellerDeliveryCodeWidgetState();
}

class _SellerDeliveryCodeWidgetState
    extends ConsumerState<SellerDeliveryCodeWidget> {
  bool _isLoading = true;
  bool _isObscured = true;
  String? _customerCode;
  String? _deliveryStatus;

  @override
  void initState() {
    super.initState();
    _fetchDeliveryInfo();
  }

  Future<void> _fetchDeliveryInfo() async {
    try {
      final apiClient = ref.read(apiClientProvider);

      // Fetch list of deliveries for this order
      final deliveries = await apiClient.getList<Delivery>(
        'deliveries/by_order/?order_id=${widget.orderId}',
        fromJson: (json) => Delivery.fromJson(json),
      );

      // Find delivery that matches this specific seller
      final sellerDelivery = deliveries.firstWhere(
        (d) => d.sellerId == widget.sellerId,
        orElse: () => deliveries.firstWhere(
          (d) => d.customerDeliveryCode != null,
          orElse: () => Delivery(id: 0, status: 'pending', orderNumber: ''),
        ),
      );

      if (mounted) {
        setState(() {
          _customerCode = sellerDelivery.customerDeliveryCode;
          _deliveryStatus = sellerDelivery.status;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        margin: const EdgeInsets.only(top: AppSpacing.xs),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.04),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.mangoOrange,
              ),
            ),
            SizedBox(width: 8),
            Text(
              "Loading verification code...",
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_customerCode == null || _customerCode!.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, size: 14, color: Colors.grey),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _deliveryStatus == 'in_transit' || _deliveryStatus == 'picked_up'
                    ? "Code generated upon dispatch."
                    : "Verification code will appear when package is in transit.",
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    final maskedCode = '•' * _customerCode!.length;

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.mangoOrange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.mangoOrange.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "DELIVERY VERIFICATION CODE",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _isObscured ? maskedCode : _customerCode!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.5,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                icon: Icon(
                  _isObscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.mangoOrange,
                ),
                tooltip: _isObscured ? 'Show Code' : 'Hide Code',
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.grey),
                tooltip: 'Copy Code',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _customerCode!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Delivery code copied to clipboard!"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// State container to bundle paginated order lists cleanly
class OrdersPaginationState {
  final List<Order> orders;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;

  const OrdersPaginationState({
    required this.orders,
    required this.isLoading,
    required this.hasMore,
    this.errorMessage,
  });

  OrdersPaginationState copyWith({
    List<Order>? orders,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
  }) {
    return OrdersPaginationState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }
}

// Managed auto-pagination controller provider
class OrdersNotifier extends AutoDisposeNotifier<OrdersPaginationState> {
  int _currentPage = 1;

  @override
  OrdersPaginationState build() {
    _currentPage = 1;
    Future.microtask(() => fetchNextPage());
    return const OrdersPaginationState(
      orders: [],
      isLoading: false,
      hasMore: true,
    );
  }

  Future<void> fetchNextPage() async {
    if (state.isLoading || !state.hasMore || _currentPage < 1) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final apiClient = ref.read(apiClientProvider);

      final fetchedOrders = await apiClient.getList(
        'orders/?page=$_currentPage',
        fromJson: (json) => Order.fromJson(json),
      );

      if (fetchedOrders.isEmpty) {
        state = state.copyWith(isLoading: false, hasMore: false);
      } else {
        _currentPage++;
        state = state.copyWith(
          orders: [...state.orders, ...fetchedOrders],
          isLoading: false,
          hasMore: fetchedOrders.length >= 10,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    _currentPage = 1;
    state = const OrdersPaginationState(
      orders: [],
      isLoading: false,
      hasMore: true,
      errorMessage: null,
    );
    await fetchNextPage();
  }
}

final ordersPaginationProvider =
    NotifierProvider.autoDispose<OrdersNotifier, OrdersPaginationState>(() {
  return OrdersNotifier();
});

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final ScrollController _scrollController = ScrollController();
  final Set<int> expandedOrders = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 250) {
      ref.read(ordersPaginationProvider.notifier).fetchNextPage();
    }
  }

  void toggleOrder(int orderId) {
    setState(() {
      expandedOrders.contains(orderId)
          ? expandedOrders.remove(orderId)
          : expandedOrders.add(orderId);
    });
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');
    return "$hour:$minute:$second";
  }

  String _formatFullDateTime(DateTime date) {
    return "${_formatDate(date)} at ${_formatTime(date)}";
  }

  // ================= PDF GENERATION =================

  Future<void> _generateAndDownloadPdf(Order order) async {
    final pdf = pw.Document();

    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/images/logo.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (e) {
      debugPrint("Could not load logo asset for PDF: $e");
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (logoImage != null)
                          pw.Container(
                            height: 65,
                            child: pw.Image(logoImage),
                          ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          "OFFICIAL ORDER INVOICE",
                          style: pw.TextStyle(
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.orange800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          "Order #${order.orderNumber}",
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          "Status: ${order.status.toUpperCase()}",
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 18),
                pw.Divider(),
                pw.SizedBox(height: 10),

                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        "Placed On: ${_formatFullDateTime(order.createdAt)}",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        "Platform: Malatrade Marketplace",
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 16),

                pw.Text(
                  "Order Items",
                  style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),

                pw.TableHelper.fromTextArray(
                  headers: ['Item Description', 'Quantity', 'Total Price (MWK)'],
                  data: order.items.map((item) {
                    return [
                      item.productName,
                      '${item.quantity}',
                      item.totalPrice.toStringAsFixed(2),
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellAlignment: pw.Alignment.centerLeft,
                ),

                pw.SizedBox(height: 16),

                if (order.sellerOrders.isNotEmpty) ...[
                  pw.Text(
                    "Shops Breakdown",
                    style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),

                  pw.TableHelper.fromTextArray(
                    headers: ['Shop Name', 'Status', 'Delivery', 'Subtotal (MWK)'],
                    data: order.sellerOrders.map((seller) {
                      return [
                        seller.shopName,
                        seller.status.toUpperCase(),
                        (seller.deliveryStatus ?? 'pending').toUpperCase(),
                        seller.subtotal.toStringAsFixed(2),
                      ];
                    }).toList(),
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    cellAlignment: pw.Alignment.centerLeft,
                  ),
                ],

                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 10),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Total Amount Paid:",
                      style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      "MWK ${order.totalAmount.toStringAsFixed(2)}",
                      style: pw.TextStyle(
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.orange,
                      ),
                    ),
                  ],
                ),

                pw.Spacer(),

                pw.Center(
                  child: pw.Text(
                    "Thank you for shopping with Malatrade!",
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontStyle: pw.FontStyle.italic,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Malatrade_Order_${order.orderNumber}.pdf',
    );
  }

  // ================= UI BUILDERS =================

  Widget _buildItem(OrderItem item) {
    final variantText = item.variantAttributes != null && item.variantAttributes!.isNotEmpty
        ? item.variantAttributes!.entries.map((e) => "${e.key}: ${e.value}").join(", ")
        : "";

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.productImage,
              width: 55,
              height: 55,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 55,
                height: 55,
                color: Colors.grey.withOpacity(0.12),
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName.toCapitalized(),
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (variantText.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    variantText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mangoOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  "Qty: ${item.quantity}".toCapitalized(),
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatWithCommas(item.totalPrice),
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final isExpanded = expandedOrders.contains(order.id);
    final isMultiVendor = order.sellerOrders.length > 1;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => toggleOrder(order.id),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.mangoOrange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: AppColors.mangoOrange,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order #${order.orderNumber}".toCapitalized(),
                            style: AppTypography.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(order.createdAt).toCapitalized(),
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.mangoOrange),
                      tooltip: "Download Invoice PDF",
                      onPressed: () => _generateAndDownloadPdf(order),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppBadge(
                      text: order.status.toCapitalized(),
                      type: order.status.toLowerCase() == 'completed'
                          ? BadgeType.success
                          : BadgeType.warning,
                    ),
                    Text(
                      "MWK ${order.totalAmount.toStringAsFixed(2)}",
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: AppSpacing.md),
                  Divider(color: Colors.grey.withOpacity(0.15)),
                  const SizedBox(height: AppSpacing.sm),
                  
                  // ℹ️ DYNAMIC MULTI-VENDOR INFORMATION BANNER
                  if (isMultiVendor)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.blue.withOpacity(0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.local_shipping_outlined,
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Multi-Vendor Shipment Notice",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "This order contains items from ${order.sellerOrders.length} different sellers. Deliveries will arrive separately, and each driver requires their own unique verification code upon arrival.",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade700,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.mangoOrange.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.mangoOrange.withOpacity(0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/logo.png',
                                  height: 22,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.storefront_rounded,
                                    size: 18,
                                    color: AppColors.mangoOrange,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Malatrade Order Details",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.mangoOrange,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.mangoOrange.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "Verified Order",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.mangoOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Divider(height: 1, color: AppColors.mangoOrange.withOpacity(0.12)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              "Order Date & Time: ",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _formatFullDateTime(order.createdAt),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    "Order items".toCapitalized(),
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...order.items.map(_buildItem).toList(),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    "Shops breakdown".toCapitalized(),
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  
                  // 🎯 SHOPS BREAKDOWN CARDS WITH CLICKABLE SHOP HEADER & EMBEDDED VERIFICATION CODE
                  ...order.sellerOrders.map((sellerOrder) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.withOpacity(0.08)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🛍️ CLICKABLE SHOP HEADER
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              if (sellerOrder.shopId != null) {
                                final tabsScreen = MainTabsScreen.of(context);
                                if (tabsScreen != null) {
                                  tabsScreen.navigateToShopDetails(sellerOrder.shopId!);
                                }
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Row(
                                children: [
                                  if (sellerOrder.shopLogo != null && sellerOrder.shopLogo!.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        sellerOrder.shopLogo!,
                                        width: 22,
                                        height: 22,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.store,
                                          size: 18,
                                          color: AppColors.mangoOrange,
                                        ),
                                      ),
                                    )
                                  else
                                    const Icon(Icons.store, size: 18, color: AppColors.mangoOrange),

                                  const SizedBox(width: AppSpacing.xs),

                                  Expanded(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            sellerOrder.shopName,
                                            style: AppTypography.titleSmall.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                              decoration: TextDecoration.underline,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 10,
                                          color: AppColors.mangoOrange,
                                        ),
                                      ],
                                    ),
                                  ),

                                  AppBadge(
                                    text: sellerOrder.status.toCapitalized(),
                                    type: sellerOrder.status.toLowerCase() == 'completed'
                                        ? BadgeType.success
                                        : BadgeType.warning,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            "Subtotal: MWK ${sellerOrder.subtotal.toStringAsFixed(2)}",
                            style: AppTypography.bodyMedium,
                          ),
                          Text(
                            "Delivery Status: ${sellerOrder.deliveryStatus ?? 'pending'}".toCapitalized(),
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          
                          // 🔑 EMBEDDED CODE WIDGET SPECIFIC TO THIS SELLER
                          SellerDeliveryCodeWidget(
                            orderId: order.id,
                            sellerId: sellerOrder.sellerId,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paginationState = ref.watch(ordersPaginationProvider);

    if (paginationState.orders.isEmpty && paginationState.isLoading) {
      return Center(child: AppLoader.inline());
    }

    if (paginationState.orders.isEmpty && paginationState.errorMessage != null) {
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppInfoBox(
                      type: AppInfoType.error,
                      message: "Failed to load orders: ${paginationState.errorMessage}".toCapitalized(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(ordersPaginationProvider.notifier).refresh();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mangoOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: WebFooter(),
          ),
        ],
      );
    }

    // ================= CENTERED RECTANGLE EMPTY STATE =================
    if (paginationState.orders.isEmpty && !paginationState.isLoading) {
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 360),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.lg,
                    horizontal: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.12),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.mangoOrange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_long_outlined,
                          size: 26,
                          color: AppColors.mangoOrange,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        "No Orders Found",
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        "You haven't placed any marketplace orders yet. Items you purchase will appear here along with tracking and invoice info.",
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: WebFooter(),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(ordersPaginationProvider.notifier).refresh();
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.md,
            ),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: paginationState.orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      return _buildOrderCard(paginationState.orders[index]);
                    },
                  ),
                ),
              ),
            ),
          ),

          if (paginationState.isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Center(child: AppLoader.inline()),
              ),
            ),

          const SliverToBoxAdapter(
            child: WebFooter(),
          ),
        ],
      ),
    );
  }
}
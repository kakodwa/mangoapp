import 'package:flutter/material.dart';
import '../../widgets/web_footer.dart';
class MangoHubSpecScreen extends StatefulWidget {
  const MangoHubSpecScreen({Key? key}) : super(key: key);

  @override
  State<MangoHubSpecScreen> createState() => _MangoHubSpecScreenState();
}

class _MangoHubSpecScreenState extends State<MangoHubSpecScreen> with SingleTickerProviderStateMixin {
  late TabController _workflowTabController;

  @override
  void initState() {
    super.initState();
    // 4 Tabs for the 4 distinct workflows
    _workflowTabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _workflowTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('MangoHub Product Spec', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Intro Card
            _buildHeroCard(),
            const SizedBox(height: 24),

            // Section 1: Core Marketplace
            _buildSectionHeader('1. Core Marketplace Ecosystem'),
            const SizedBox(height: 12),
            _buildMarketplaceGrid(),
            const SizedBox(height: 28),

            // Section 2: Smart Escrow Workflows
            _buildSectionHeader('2. Smart Escrow & Transactions'),
            const SizedBox(height: 8),
            Text(
              'Funds are safely held by MangoHub and released via real-world milestones.',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            _buildEscrowWorkflowTabs(),
            const SizedBox(height: 28),

            // Section 3: Financial & Refund Infrastructure
            _buildSectionHeader('3. Financial & Refund Infrastructure'),
            const SizedBox(height: 12),
            _buildFinancialInfrastructure(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
    );
  }

  Widget _buildHeroCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'MangoHub Marketplace',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'A unified, multi-service digital marketplace designed to bridge the gap between daily commerce, lifestyle services, and secure fintech.',
              style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketplaceGrid() {
    final modules = [
      {
        'title': 'Retail & E-Commerce',
        'icon': Icons.shopping_bag_outlined,
        'desc': 'Digital storefronts, universal cart, and direct checkout native to the app.'
      },
      {
        'title': 'Real Estate',
        'icon': Icons.home_work_outlined,
        'desc': 'Verified agents only. Exact location data is gated to prevent scams.'
      },
      {
        'title': 'Event Ticketing',
        'icon': Icons.confirmation_number_outlined,
        'desc': 'Tiered pricing, digital tickets, and app-native QR validation at the door.'
      },
      {
        'title': 'Hospitality & Lodging',
        'icon': Icons.hotel_outlined,
        'desc': 'Direct bookings backed by live room calendars to prevent overbooking.'
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final item = modules[index];
        return Card(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            key: ValueKey(item['title']),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFFFF3E0),
                  child: Icon(item['icon'] as IconData, color: const Color(0xFFFF9800)),
                ),
                const SizedBox(height: 12),
                Text(
                  item['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    item['desc'] as String,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.3),
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEscrowWorkflowTabs() {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          TabBar(
            controller: _workflowTabController,
            isScrollable: true,
            labelColor: const Color(0xFFFF9800),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFFFF9800),
            tabs: const [
              Tab(text: 'Shops'),
              Tab(text: 'Tickets'),
              Tab(text: 'Lodging'),
              Tab(text: 'Properties'),
            ],
          ),
          SizedBox(
            height: 180,
            child: TabBarView(
              controller: _workflowTabController,
              children: [
                _buildWorkflowStepView([
                  'Customer pays & funds locked in escrow.',
                  'Rider/Seller delivers physical item.',
                  'Customer provides Unique Delivery Code.',
                  'Seller inputs code to instantly release funds.'
                ]),
                _buildWorkflowStepView([
                  'Customer purchases digital event ticket.',
                  'Revenue securely held by MangoHub.',
                  'Organizer scans ticket using in-app scanner at entry.',
                  'Check-in instantly releases funds to organizer.'
                ]),
                _buildWorkflowStepView([
                  'Customer books room via live calendar.',
                  'Funds held securely in platform escrow.',
                  'Lodge owner scans booking QR code at check-in.',
                  'Funds instantly transfer to owner\'s account.'
                ]),
                _buildWorkflowStepView([
                  'Exact GPS/Contact data hidden behind Viewing Fee.',
                  'User pays fee -> details instantly unlocked.',
                  'App opens GPS map route & schedules physical visit.',
                  'Fee processes and releases immediately to property owner.'
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowStepView(List<String> steps) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: steps.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: const Color(0xFFE8F5E9),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    steps[index],
                    style: const TextStyle(fontSize: 13, color: Color(0xFF424242)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFinancialInfrastructure() {
    return Column(
      children: [
        // Gateway status
        Card(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Payment Gateway: Paychangu', style: TextStyle(fontWeight: FontWeight.bold)),
                Divider(height: 20),
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
                    SizedBox(width: 8),
                    Text('TNM Mpamba & Airtel Money (Live)'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.watch_later_outlined, color: Colors.orange, size: 18),
                    SizedBox(width: 8),
                    Text('Visa Card Payments (Coming Soon)'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Refund Protection Policies
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.5)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.security, color: Color(0xFF10B981)),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Escrow Protection Policy', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                    SizedBox(height: 4),
                    Text('Shops, Events, and Bookings feature a 100% refund guarantee if compliance milestones are unmet.', style: TextStyle(fontSize: 12, color: Color(0xFF2E7D32))),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, color: Colors.redAccent),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Real Estate Exception', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC62828))),
                    SizedBox(height: 4),
                    Text('Property Viewing Fees are strictly non-refundable due to the instantaneous release of proprietary GPS data & contact pathways.', style: TextStyle(fontSize: 12, color: Color(0xFFD32F2F))),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
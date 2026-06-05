import 'package:flutter/material.dart';
// Ensure correct paths according to your project structure
import '../../theme/app_colors.dart';
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_badge.dart';
import '../../theme/design_system/app_info_box.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';

class MangoHubScreen extends StatefulWidget {
  const MangoHubScreen({super.key});

  @override
  State<MangoHubScreen> createState() => _MangoHubScreenState();
}

class _MangoHubScreenState extends State<MangoHubScreen> {
  int _selectedWorkflowIndex = 0;

  // Data matching the infographic specifications
  final List<Map<String, dynamic>> _workflows = [
    {
      "title": "RETAIL/SHOP WORKFLOWS",
      "color": Colors.orange,
      "steps": [
        {"title": "1. Customer Pays", "sub": "Customer purchases an item via PayChangu."},
        {"title": "2. Funds Held", "sub": "Funds are immediately locked in escrow."},
        {"title": "3. Rider Delivers", "sub": "Item is delivered to the customer."},
        {"title": "4. Customer Gives Code", "sub": "Rider/Shop requests unique Delivery Code."},
        {"title": "5. Seller Enters Code", "sub": "Seller or rider inputs the customer code."},
        {"title": "6. Funds Released", "sub": "Transaction complete. Funds instantly released."}
      ]
    },
    {
      "title": "EVENT TICKET WORKFLOWS",
      "color": Colors.deepOrange,
      "steps": [
        {"title": "1. Customer Buys", "sub": "Customer purchases an event ticket."},
        {"title": "2. Revenue Held", "sub": "Revenue is securely held by MangoHub."},
        {"title": "3. Customer Presents", "sub": "Digital Ticket presented at venue entry."},
        {"title": "4. Organizer Scans", "sub": "Authorized organizer scans using MangoHub app."},
        {"title": "5. Funds Released", "sub": "Check-in is registered and funds released."}
      ]
    },
    {
      "title": "LODGE & BOOKING WORKFLOWS",
      "color": Colors.blueGrey,
      "steps": [
        {"title": "1. Customer Books", "sub": "Customer books a room and pays via platform."},
        {"title": "2. Funds Held", "sub": "Funds are held securely in escrow."},
        {"title": "3. Customer Presents", "sub": "Upon arrival, customer presents QR code."},
        {"title": "4. Lodge Scans", "sub": "Lodge owner scans using MangoHub app scanner."},
        {"title": "5. Funds Released", "sub": "Check-in triggers release of payment to owner."}
      ]
    },
    {
      "title": "PROPERTY VIEWING WORKFLOWS",
      "color": Colors.redAccent,
      "steps": [
        {"title": "1. Pay Viewing Fee", "sub": "User pays the required viewing fee."},
        {"title": "2. Instant Unlocks", "sub": "App instantly reveals precise GPS and contact details."},
        {"title": "3. Fee Released", "sub": "Once details are successfully accessed, fee is released."}
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'MangoHub Ecosystem', 
          style: AppTypography.headlineMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.mangoOrange,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildSectionHeader("1. CORE MARKETPLACE ECOSYSTEM"),
            const SizedBox(height: AppSpacing.sm),
            _buildCoreEcosystemGrid(),
            const SizedBox(height: AppSpacing.lg),
            _buildSectionHeader("2. SMART ESCROW & TRANSACTION WORKFLOW"),
            const SizedBox(height: AppSpacing.sm),
            _buildWorkflowSelector(),
            const SizedBox(height: AppSpacing.md),
            _buildWorkflowTimeline(),
            const SizedBox(height: AppSpacing.md),
            _buildCommissionBanner(),
            const SizedBox(height: AppSpacing.lg),
            _buildSectionHeader("3. FINANCIAL INFRASTRUCTURE & POLICIES"),
            const SizedBox(height: AppSpacing.sm),
            _buildFinancialAndPoliciesSection(),
            const SizedBox(height: AppSpacing.md),
            _buildContactInfoBox(),
          ],
        ),
      ),
    );
  }

  // --- SECTION BUILDERS ---

  Widget _buildHeaderSection() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_bag, color: AppColors.mangoOrange, size: 40),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "MangoHub", 
                      style: AppTypography.displayMedium,
                    ),
                    Text(
                      "Everything Local. One Hub.", 
                      style: TextStyle(
                        fontSize: 14, 
                        color: AppColors.leafGreen, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          const Text(
            "MangoHub is a unified, multi-service digital marketplace designed to bridge the gap between daily commerce, lifestyle services, and secure fintech. By integrating shopping, hospitality, real estate, event ticketing, and instant mobile payments into a single platform, MangoHub eliminates the friction of switching between multiple apps.",
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.mangoOrange,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: AppTypography.titleMedium.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildCoreEcosystemGrid() {
    final coreServices = [
      {"icon": Icons.shopping_cart, "title": "A. RETAIL & E-COMMERCE", "desc": "Seller frontends, universal cart checkout, and direct product management."},
      {"icon": Icons.home, "title": "B. REAL ESTATE", "desc": "Verified agents only. Anti-scam protection, hidden location mapping until unlocked."},
      {"icon": Icons.confirmation_number, "title": "C. EVENT TICKETING", "desc": "Tiered digital pricing (General, VIP), in-app dynamic native QR code entry checks."},
      {"icon": Icons.hotel, "title": "D. HOSPITALITY & LODGING", "desc": "Real-time calendar anti-double booking sync & multi-room reservation states."}
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.82,
      ),
      itemCount: coreServices.length,
      itemBuilder: (context, index) {
        final service = coreServices[index];
        return AppCard(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.mangoLight.withOpacity(0.15),
                child: Icon(service["icon"] as IconData, color: AppColors.mangoOrange),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                service["title"] as String, 
                style: AppTypography.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Expanded(
                child: Text(
                  service["desc"] as String,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.darkText.withOpacity(0.7)),
                  overflow: TextOverflow.fade,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkflowSelector() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _workflows.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedWorkflowIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: ChoiceChip(
              label: Text(
                _workflows[index]["title"].toString().split(' ')[0],
              ),
              selected: isSelected,
              selectedColor: _workflows[index]["color"],
              labelStyle: AppTypography.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.darkText,
              ),
              onSelected: (selected) {
                if (selected) setState(() => _selectedWorkflowIndex = index);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkflowTimeline() {
    var selectedData = _workflows[_selectedWorkflowIndex];
    List<Map<String, String>> steps = List<Map<String, String>>.from(selectedData["steps"]);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  selectedData["title"],
                  style: AppTypography.headlineSmall.copyWith(color: selectedData["color"]),
                ),
              ),
              const AppBadge(text: "Escrow Locked", type: BadgeType.warning),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: selectedData["color"],
                        child: Text(
                          "${index + 1}", 
                          style: AppTypography.labelSmall.copyWith(color: Colors.white),
                        ),
                      ),
                      if (index != steps.length - 1)
                        Container(width: 2, height: 40, color: Colors.grey.shade300),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(steps[index]["title"]!, style: AppTypography.titleMedium),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          steps[index]["sub"]!, 
                          style: AppTypography.bodySmall.copyWith(color: AppColors.darkText.withOpacity(0.7)),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ),
                  )
                ],
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildCommissionBanner() {
    return AppInfoBox(
      type: AppInfoType.info,
      icon: Icons.percent,
      message: "MANGOHUB COMMISSION: Platform standard takes a 10% cut structure for every completed pipeline transaction handled natively across all business verticals.",
    );
  }

  Widget _buildFinancialAndPoliciesSection() {
    return Column(
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("3. Financial Infrastructure", style: AppTypography.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.payment, color: Colors.white),
                ),
                title: const Text("PayChangu Native Gateway", style: AppTypography.titleSmall),
                subtitle: Text(
                  "Powers all operations natively for instant local mobile wallets (TNM Mpamba, Airtel Money).", 
                  style: AppTypography.bodySmall.copyWith(color: AppColors.darkText.withOpacity(0.7)),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.credit_card, color: Colors.white),
                ),
                title: const Text("Card Payments", style: AppTypography.titleSmall),
                subtitle: Text(
                  "Visa active implementation pipeline for international processing capability.", 
                  style: AppTypography.bodySmall.copyWith(color: AppColors.darkText.withOpacity(0.7)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Refund & Protection Rules", style: AppTypography.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              AppInfoBox(
                type: AppInfoType.success,
                icon: Icons.shield_outlined,
                message: "Escrow Protection: Funds safely covered for Shops, Events, Bookings. Non-delivery defaults to 100% refund configuration workflow state.",
              ),
              const SizedBox(height: AppSpacing.xs),
              AppInfoBox(
                type: AppInfoType.error,
                icon: Icons.gavel_outlined,
                message: "Real Estate Exception: Property Viewing Fee is strictly non-refundable due to instantaneous precise navigation maps data reveal logic.",
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildContactInfoBox() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.leafGreen.withOpacity(0.15),
            child: const Icon(Icons.phone, color: AppColors.leafGreen),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("For Support & Inquiries", style: AppTypography.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  "+265 993 344 56", 
                  style: AppTypography.headlineSmall.copyWith(color: AppColors.leafGreen),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
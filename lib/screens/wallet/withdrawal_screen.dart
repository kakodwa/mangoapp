import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/web_footer.dart';
import '../main_tabs_screen.dart';

class WithdrawalScreen extends ConsumerStatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  ConsumerState<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends ConsumerState<WithdrawalScreen> {
  final _formKey = GlobalKey<FormState>();
  String _payoutMethod = 'mobile_money'; // Default payout channel

  final _amountController = TextEditingController();
  final _holderController = TextEditingController();
  final _accountOrPhoneController = TextEditingController();
  
  String? _selectedBankUuid;
  final _branchController = TextEditingController();

  final List<Map<String, String>> _malawiBanks = [
    {"name": "National Bank of Malawi", "uuid": "82310dd1-ec9b-4fe7-a32c-2f262ef08681"},
    {"name": "Standard Bank", "uuid": "da310dd1-ec9b-4fe7-a32c-2f262ef08699"},
    {"name": "FDH Bank", "uuid": "fa450dd1-bc9b-4fe7-a32c-2f262ef08611"},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _holderController.dispose();
    _accountOrPhoneController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    final success = await ref.read(withdrawalProvider.notifier).requestWithdrawal(
          amount: amount,
          payoutMethod: _payoutMethod,
          holderName: _holderController.text.trim(),
          accountNumber: _accountOrPhoneController.text.trim(),
          bankName: _payoutMethod == 'bank_transfer' 
              ? _malawiBanks.firstWhere((b) => b['uuid'] == _selectedBankUuid, orElse: () => {})['name'] 
              : null,
          bankUuid: _payoutMethod == 'bank_transfer' ? _selectedBankUuid : null,
          branch: _payoutMethod == 'bank_transfer' ? _branchController.text.trim() : null,
        );

    if (success && mounted) {
      // 1. Force Riverpod to re-fetch wallet balance & pending payouts from backend
      ref.invalidate(walletProvider);

      // 2. Refresh withdrawal history list so the new cashout appears instantly
      ref.invalidate(historicalWithdrawalsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Withdrawal request submitted successfully!'),
            ],
          ),
          backgroundColor: AppColors.leafGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      
      // 3. Redirect directly to Cashout History Screen
      MainTabsScreen.of(context)?.navigateToPayoutHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final withdrawalState = ref.watch(withdrawalProvider);
    final walletAsync = ref.watch(walletProvider);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 900;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(
            vertical: 24.0,
            horizontal: isLargeScreen ? (screenWidth - 750) / 2 : 16.0,
          ),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 750),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- TOP BAR: BRAND ORANGE HEADER CARD WITH BALANCE & PAYMENT BADGES ---
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF97316), Color(0xFFC2410C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF97316).withOpacity(0.25),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Available Wallet Balance",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    walletAsync.when(
                                      data: (wallet) => Text(
                                        '${wallet.currency} ${wallet.balance.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      loading: () => const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      ),
                                      error: (_, __) => const Text(
                                        'MWK 0.00',
                                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            const Divider(color: Colors.white24, height: 1),
                            const SizedBox(height: 14),

                            // Payment Gateway Banner Image inside Orange Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.verified_user_rounded, color: Colors.white, size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      'Supported Methods',
                                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Image.network(
                                    'https://www.malatrade.com/media/Payment_method.png',
                                    height: 26,
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.high,
                                    isAntiAlias: true,
                                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- SECTION 1: PAYOUT METHOD SELECTOR ---
                      const Text(
                        "Select Payout Channel",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildChannelCard(
                              id: 'mobile_money',
                              title: 'Mobile Money',
                              subtitle: 'Airtel / TNM Mpamba',
                              icon: Icons.phone_android_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildChannelCard(
                              id: 'bank_transfer',
                              title: 'Bank Transfer',
                              subtitle: 'Direct Account Deposit',
                              icon: Icons.account_balance_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // --- SECTION 2: CASHOUT DETAILS FORM CARD ---
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Payout Details",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 18),

                            // Amount Input
                            TextFormField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: _modernInputDecoration('Amount to Withdraw (MWK)', Icons.payments_outlined),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Please enter an amount';
                                final val = double.tryParse(v);
                                if (val == null || val <= 0) return 'Enter a valid amount';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Recipient Name Input
                            TextFormField(
                              controller: _holderController,
                              decoration: _modernInputDecoration('Recipient Full Name', Icons.person_outline_rounded),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Recipient name is required' : null,
                            ),
                            const SizedBox(height: 16),

                            // Account / Phone Input
                            TextFormField(
                              controller: _accountOrPhoneController,
                              keyboardType: TextInputType.number,
                              decoration: _modernInputDecoration(
                                _payoutMethod == 'mobile_money' 
                                    ? 'Mobile Number (e.g. 099... or 088...)' 
                                    : 'Bank Account Number',
                                _payoutMethod == 'mobile_money' ? Icons.phone_outlined : Icons.numbers_rounded,
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Account identifier is required' : null,
                            ),
                            const SizedBox(height: 16),

                            // Dynamic Bank Fields
                            if (_payoutMethod == 'bank_transfer') ...[
                              DropdownButtonFormField<String>(
                                value: _selectedBankUuid,
                                decoration: _modernInputDecoration('Select Destination Bank', Icons.account_balance_outlined),
                                borderRadius: BorderRadius.circular(12),
                                items: _malawiBanks.map((bank) {
                                  return DropdownMenuItem(
                                    value: bank['uuid'],
                                    child: Text(bank['name']!, style: const TextStyle(fontSize: 14)),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedBankUuid = val),
                                validator: (v) => v == null ? 'Please select your bank' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _branchController,
                                decoration: _modernInputDecoration('Bank Branch Name / City', Icons.location_city_outlined),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Branch location is required' : null,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- SUBMIT CASHOUT BUTTON ---
                      ElevatedButton(
                        onPressed: withdrawalState.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.leafGreen,
                          disabledBackgroundColor: AppColors.leafGreen.withOpacity(0.6),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                        child: withdrawalState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send_rounded, color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Confirm & Process Cashout',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
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

  // --- HELPER 1: SEGMENTED SELECTION CARDS ---
  Widget _buildChannelCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final bool isSelected = _payoutMethod == id;

    return InkWell(
      onTap: () => setState(() => _payoutMethod = id),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mangoOrange.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.mangoOrange : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.mangoOrange : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? AppColors.mangoOrange : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER 2: MODERN INPUT STYLING ---
  InputDecoration _modernInputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13.5),
      floatingLabelStyle: const TextStyle(color: AppColors.mangoOrange, fontWeight: FontWeight.bold),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.mangoOrange, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
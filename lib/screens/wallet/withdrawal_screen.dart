import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/web_footer.dart';
import '../main_tabs_screen.dart'; // Core structural coordinator layout

class WithdrawalScreen extends ConsumerStatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  ConsumerState<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends ConsumerState<WithdrawalScreen> {
  final _formKey = GlobalKey<FormState>();
  String _payoutMethod = 'mobile_money'; // Default selector value

  final _amountController = TextEditingController();
  final _holderController = TextEditingController();
  final _accountOrPhoneController = TextEditingController();
  
  // Bank selection state placeholders
  String? _selectedBankUuid;
  final _branchController = TextEditingController();

  // PayChangu Registered Bank Options List lookup database structure
  final List<Map<String, String>> _malawiBanks = [
    {"name": "National Bank of Malawi", "uuid": "82310dd1-ec9b-4fe7-a32c-2f262ef08681"},
    {"name": "Standard Bank", "uuid": "da310dd1-ec9b-4fe7-a32c-2f262ef08699"},
    {"name": "FDH Bank", "uuid": "fa450dd1-bc9b-4fe7-a32c-2f262ef08611"},
  ];

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
              ? _malawiBanks.firstWhere((b) => b['uuid'] == _selectedBankUuid)['name'] 
              : null,
          bankUuid: _payoutMethod == 'bank_transfer' ? _selectedBankUuid : null,
          branch: _payoutMethod == 'bank_transfer' ? _branchController.text.trim() : null,
        );

    if (success && mounted) {
      ref.invalidate(walletProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cashout request submitted!'), backgroundColor: Colors.green),
      );
      
      // Instead of killing the context tree using pop, safely route back to the wallet overview tab index
      MainTabsScreen.of(context)?.setSelectedIndex(20);
    }
  }

  @override
  Widget build(BuildContext context) {
    final withdrawalState = ref.watch(withdrawalProvider);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 900;

    // Removed the standalone Scaffold component layer and explicit internal AppBar target.
    // The transaction workflow now shares the navigation parameters of MainTabsScreen natively.
    if (withdrawalState.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.mangoOrange));
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(
            vertical: 16.0,
            // Standardizes responsive side margins for desktop web viewports
            horizontal: isLargeScreen ? (screenWidth - 800) / 2 : 16.0,
          ),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Segmented choice button toggles selection modes layout
                      DropdownButtonFormField<String>(
                        value: _payoutMethod,
                        decoration: InputDecoration(
                          labelText: "Payout Destination",
                          prefixIcon: const Icon(Icons.payment, color: AppColors.mangoOrange),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'mobile_money', child: Text('Mobile Money (Airtel / Mpamba)')),
                          DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Account Payout')),
                        ],
                        onChanged: (val) => setState(() => _payoutMethod = val!),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _inputDecoration('Amount (MWK)', Icons.attach_money),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _holderController,
                        decoration: _inputDecoration('Recipient Name', Icons.person),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _accountOrPhoneController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          _payoutMethod == 'mobile_money' ? 'Phone Number (e.g. 099... or 088...)' : 'Account Number',
                          Icons.numbers,
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),

                      // Conditionally reveal extra inputs if Bank target selected
                      if (_payoutMethod == 'bank_transfer') ...[
                        DropdownButtonFormField<String>(
                          value: _selectedBankUuid,
                          decoration: _inputDecoration('Select Bank Name', Icons.account_balance),
                          items: _malawiBanks.map((bank) {
                            return DropdownMenuItem(value: bank['uuid'], child: Text(bank['name']!));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedBankUuid = val),
                          validator: (v) => v == null ? 'Please choose a bank target' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _branchController,
                          decoration: _inputDecoration('Bank Branch Location', Icons.location_city),
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 14),
                      ],

                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.leafGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Confirm Cashout', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Structured spacing layout baseline buffer
        const SliverToBoxAdapter(
          child: SizedBox(height: 40),
        ),
        
        // ================= WEB FOOTER =================
        // Safely bound to the structural scroll root to render beneath the centered form block
        const SliverToBoxAdapter(
          child: WebFooter(),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: AppColors.mangoOrange),
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
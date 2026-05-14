import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  int _selectedTab = 0; // 0 = Resident (CNIC), 1 = Overseas (NICOP)
  final _nameController = TextEditingController();
  final _cnicController = TextEditingController();
  final _mobileController = TextEditingController();

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cnicController.dispose();
    _mobileController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDeep,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          const SachBackgroundGlow(),
          FadeTransition(
            opacity: _fade,
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 24.0,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitle(),
                            const SizedBox(height: 24),
                            _buildTabSelector(),
                            const SizedBox(height: 24),
                            _buildFormFields(),
                            const SizedBox(height: 24),
                            _buildKycSection(),
                            const SizedBox(height: 24),
                            SachGradientButton(
                              label: 'Create Secure Account',
                              icon: Icons.shield_rounded,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: 20),
                            _buildSignInLink(),
                            const SizedBox(height: 24),
                            _buildFooter(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: kBgCard,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: kGold,
          size: 20,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Image.asset(
            'assets/images/sach_logo.png',
            height: 48,
            fit: BoxFit.contain,
          ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFF4DD97A), kGold],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Create Account',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 2),
        // Bilingual subtitle
        Text(
          'Register securely with government verification',
          style: TextStyle(color: kTextSub, fontSize: 13),
        ),
        Text(
          'حکومتی تصدیق کے ساتھ محفوظ طریقے سے رجسٹر کریں',
          style: TextStyle(color: kTextSub, fontSize: 11.5),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kDivider, width: 1.5),
      ),
      child: Row(
        children: [
          _tab('Resident (CNIC)', 0),
          const SizedBox(width: 4),
          _tab('Overseas (NICOP)', 1),
        ],
      ),
    );
  }

  Widget _tab(String label, int index) {
    final selected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? kGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: kGreen.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : kTextSub,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SachLabel('Full Name'),
        TextFormField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          textCapitalization: TextCapitalization.words,
          decoration: sachInputDecoration(
            hint: 'Enter your full name',
            prefixIcon: Icon(
              Icons.person_outline_rounded,
              color: kGold,
              size: 20,
            ),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Full name is required';
            if (v.trim().length < 3)
              return 'Name must be at least 3 characters';
            return null;
          },
        ),
        const SizedBox(height: 18),

        SachLabel(_selectedTab == 0 ? 'CNIC Number' : 'NICOP Number'),
        TextFormField(
          controller: _cnicController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
          inputFormatters: [_CnicFormatter()],
          decoration: sachInputDecoration(
            hint: _selectedTab == 0 ? '00000-0000000-0' : 'NICOP Number',
            prefixIcon: Icon(Icons.credit_card_rounded, color: kGold, size: 20),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) {
              return _selectedTab == 0
                  ? 'CNIC is required'
                  : 'NICOP is required';
            }
            final digits = v.replaceAll('-', '');
            if (digits.length != 13) {
              return 'Enter a valid 13-digit ${_selectedTab == 0 ? 'CNIC' : 'NICOP'}';
            }
            return null;
          },
        ),
        const SizedBox(height: 18),

        const SachLabel('Mobile Number'),
        TextFormField(
          controller: _mobileController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.phone,
          inputFormatters: [_PhoneFormatter()],
          decoration: sachInputDecoration(
            hint: '+92 300 0000000',
            prefixIcon: Icon(Icons.smartphone_rounded, color: kGold, size: 20),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Mobile number is required';
            final digits = v.replaceAll(RegExp(r'\D'), '');
            if (digits.length < 11)
              return 'Enter a valid Pakistani mobile number';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildKycSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGold.withOpacity(0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: kGold.withOpacity(0.05),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: kGold,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'SACH Verification',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SachGradientButton(
            label: 'Biometric Fingerprint Scan',
            icon: Icons.fingerprint_rounded,
            onPressed: () => showBiometricSheet(context),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: Divider(color: kDivider, thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or',
                  style: TextStyle(color: kTextSub, fontSize: 12),
                ),
              ),
              Expanded(child: Divider(color: kDivider, thickness: 1)),
            ],
          ),
          const SizedBox(height: 14),
          SachOutlineButton(
            label: 'Send Mobile OTP',
            icon: Icons.smartphone_rounded,
            onPressed: () => showOtpSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already registered? ',
          style: TextStyle(color: kTextSub, fontSize: 13),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pushReplacementNamed('/login'),
          child: Text(
            'Sign in here',
            style: TextStyle(
              color: kGold,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: kGold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: kGreen,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '© 2025 SACH. All rights reserved.',
              style: TextStyle(color: kTextSub, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const SachFooterLinks(),
      ],
    );
  }
}

// ─── CNIC Formatter ───────────────────────────────────────────────────────────
class _CnicFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue next,
  ) {
    final digits = next.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 13; i++) {
      if (i == 5 || i == 12) buffer.write('-');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return next.copyWith(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

// ─── Phone Formatter ──────────────────────────────────────────────────────────
class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue next,
  ) {
    String text = next.text;
    if (!text.startsWith('+92')) text = '+92';
    return next.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

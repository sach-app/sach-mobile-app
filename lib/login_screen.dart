import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _cnicController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
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
    _cnicController.dispose();
    _passwordController.dispose();
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
      appBar: AppBar(
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
      ),
      body: Stack(
        children: [
          // Ambient glow
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
                        vertical: 32.0,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 32),
                            _buildFormCard(),
                            const SizedBox(height: 24),
                            _buildAltLogin(),
                            const SizedBox(height: 24),
                            _buildSecurityBadge(),
                            const SizedBox(height: 28),
                            _buildRegisterLink(),
                            const SizedBox(height: 8),
                            const SachFooterLinks(),
                            Text(
                              '© 2025 SACH. All rights reserved.',
                              style: TextStyle(color: kTextSub, fontSize: 11),
                            ),
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

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Image.asset(
          'assets/images/sach_logo.png',
          height: 64,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 18),
        // Bilingual heading
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFF4DD97A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'SACH Portal Access',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 6),
        // EN + UR subtitle
        Column(
          children: [
            Text(
              'Secure Government Authentication',
              style: TextStyle(color: kTextSub, fontSize: 12.5),
            ),
            const SizedBox(height: 2),
            Text(
              'محفوظ حکومتی تصدیق',
              style: TextStyle(
                color: kTextSub,
                fontSize: 12,
                fontFamily: 'Roboto',
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kGreen.withOpacity(0.18), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: kGreen.withOpacity(0.06),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CNIC field
          const SachLabel('CNIC / Official ID'),
          TextFormField(
            controller: _cnicController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            inputFormatters: [_CnicFormatter()],
            decoration: sachInputDecoration(
              hint: '00000-0000000-0',
              prefixIcon: Icon(
                Icons.credit_card_rounded,
                color: kGold,
                size: 20,
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'CNIC is required';
              final digits = v.replaceAll('-', '');
              if (digits.length != 13) return 'Enter a valid 13-digit CNIC';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Password field
          const SachLabel('Secure Password or OTP'),
          TextFormField(
            controller: _passwordController,
            obscureText: !_showPassword,
            style: const TextStyle(color: Colors.white),
            decoration: sachInputDecoration(
              hint: 'Enter your password or OTP',
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: kGold,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _showPassword
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: kTextSub,
                  size: 20,
                ),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: kGold,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Primary CTA — glowing
          SachGradientButton(
            label: 'Authenticate & Sign In',
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildAltLogin() {
    return Column(
      children: [
        _dividerRow(),
        const SizedBox(height: 16),
        SachOutlineButton(
          label: 'Login via SMS OTP',
          icon: Icons.smartphone_rounded,
          onPressed: () => showOtpSheet(context),
        ),
      ],
    );
  }

  Widget _dividerRow() {
    return Row(
      children: [
        Expanded(child: Divider(color: kDivider, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('or', style: TextStyle(color: kTextSub, fontSize: 12)),
        ),
        Expanded(child: Divider(color: kDivider, thickness: 1)),
      ],
    );
  }

  Widget _buildSecurityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: kGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: kGreen.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_rounded, color: kGold, size: 14),
          const SizedBox(width: 8),
          Text(
            'Secured via JWT Authentication & Blockchain',
            style: TextStyle(
              color: kTextSub,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(color: kTextSub, fontSize: 13),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pushReplacementNamed('/signup'),
          child: Text(
            'Register as Citizen',
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
}

// ─── CNIC Input Formatter ─────────────────────────────────────────────────────
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

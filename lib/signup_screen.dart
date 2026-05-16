  import 'dart:convert';
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:http/http.dart' as http;
  import 'api_config.dart';
  import 'theme.dart';

  class SignupScreen extends StatefulWidget {
    const SignupScreen({super.key});

    @override
    State<SignupScreen> createState() => _SignupScreenState();
  }

  class _SignupScreenState extends State<SignupScreen>
      with SingleTickerProviderStateMixin {
    final _formKey = GlobalKey<FormState>();
    int _selectedTab = 0;
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _cnicController = TextEditingController();
    final _mobileController = TextEditingController();
    final _passwordController = TextEditingController();
    bool _isPasswordVisible = false;
    bool _isLoading = false;

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
      _emailController.dispose();
      _cnicController.dispose();
      _mobileController.dispose();
      _passwordController.dispose();
      _fadeCtrl.dispose();
      super.dispose();
    }

    Future<void> _submit() async {
      if (!(_formKey.currentState?.validate() ?? false)) return;

      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/user/signup'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'full_name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'cnic': _cnicController.text.trim(),
            'phone': _mobileController.text.trim(),
            'password': _passwordController.text,
          }),
        );

        if (!mounted) return;

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created successfully. Please login.')),
          );
          Navigator.of(context).pushReplacementNamed('/login');
        } else {
          final data = jsonDecode(response.body);
          final errorDetail = data['detail'] ?? 'Registration failed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorDetail.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Network error. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
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
                              _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(color: kGold),
                                    )
                                  : SachGradientButton(
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

          const SachLabel('Email Address'),
          TextFormField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.emailAddress,
            decoration: sachInputDecoration(
              hint: 'Enter your email address',
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: kGold,
                size: 20,
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(v.trim())) {
                return 'Enter a valid email address';
              }
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
              if (digits.length != 12 || !digits.startsWith('923'))
                return 'Enter a valid 10-digit Pakistani mobile number';
              return null;
            },
          ),
          const SizedBox(height: 18),

          const SachLabel('Password'),
          TextFormField(
            controller: _passwordController,
            style: const TextStyle(color: Colors.white),
            obscureText: !_isPasswordVisible,
            decoration: sachInputDecoration(
              hint: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: kGold, size: 20),
            ).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: kGold,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 8) return 'Password must be at least 8 characters';
              return null;
            },
          ),
        ],
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

  class _PhoneFormatter extends TextInputFormatter {
    @override
    TextEditingValue formatEditUpdate(
      TextEditingValue old,
      TextEditingValue next,
    ) {
      String digits = next.text.replaceAll(RegExp(r'\D'), '');
      if (digits.startsWith('92')) digits = digits.substring(2);
      if (digits.startsWith('0')) digits = digits.substring(1);
      if (digits.isNotEmpty && digits[0] != '3') digits = '';
      if (digits.length > 10) digits = digits.substring(0, 10);
      final text = '+92 $digits';
      return next.copyWith(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

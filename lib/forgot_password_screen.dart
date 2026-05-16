import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'theme.dart';
import 'api_config.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 0;
  bool _isLoading = false;

  final _formKey0 = GlobalKey<FormState>();
  final _cnicController = TextEditingController();

  final _formKey1 = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  final _formKey2 = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _cnicController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _requestReset() async {
    if (!(_formKey0.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/user/forgot-password'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'cnic': _cnicController.text.trim()}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() => _step = 1);
      } else {
        final data = jsonDecode(response.body);
        final detail = data['detail'] ?? 'Failed to request reset';
        _showError(detail.toString());
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Network error. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _verifyOtpLocal() {
    if (!(_formKey1.currentState?.validate() ?? false)) return;
    setState(() => _step = 2);
  }

  Future<void> _confirmReset() async {
    if (!(_formKey2.currentState?.validate() ?? false)) return;

    if (_passwordController.text != _confirmController.text) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/user/reset-password'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'cnic': _cnicController.text.trim(),
          'otp': _otpController.text.trim(),
          'new_password': _passwordController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: kGold, size: 18),
                const SizedBox(width: 10),
                const Text('Password reset successfully', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
            backgroundColor: kBgCard,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
      } else {
        final data = jsonDecode(response.body);
        final detail = data['detail'] ?? 'Failed to reset password';
        _showError(detail.toString());
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Network error. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDeep,
      appBar: AppBar(
        backgroundColor: kBgCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kGold, size: 18),
          onPressed: () {
            if (_step > 0) {
              setState(() => _step--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Password Recovery',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: Stack(
        children: [
          const SachBackgroundGlow(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: kBgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kGreen.withOpacity(0.18), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 24, offset: const Offset(0, 10)),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildStepContent(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0: return _buildStep0();
      case 1: return _buildStep1();
      case 2: return _buildStep2();
      default: return const SizedBox();
    }
  }

  Widget _buildStep0() {
    return Form(
      key: _formKey0,
      child: Column(
        key: const ValueKey(0),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter CNIC',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your 13-digit CNIC to receive a 6-digit OTP on your registered email.',
            style: TextStyle(color: kTextSub, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 24),
          const SachLabel('CNIC / Official ID'),
          TextFormField(
            controller: _cnicController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            inputFormatters: [_CnicFormatter()],
            decoration: sachInputDecoration(
              hint: '00000-0000000-0',
              prefixIcon: const Icon(Icons.credit_card_rounded, color: kGold, size: 20),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'CNIC is required';
              final digits = v.replaceAll('-', '');
              if (digits.length != 13) return 'Enter a valid 13-digit CNIC';
              return null;
            },
          ),
          const SizedBox(height: 32),
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: kGold))
              : SachGradientButton(label: 'Send OTP', onPressed: _requestReset),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _formKey1,
      child: Column(
        key: const ValueKey(1),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter OTP',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Please enter the 6-digit OTP sent to your registered email address.',
            style: TextStyle(color: kTextSub, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 24),
          const SachLabel('6-Digit OTP'),
          TextFormField(
            controller: _otpController,
            style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 12),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: sachInputDecoration(hint: '------').copyWith(counterText: ''),
            validator: (v) {
              if (v == null || v.isEmpty) return 'OTP is required';
              if (v.length != 6) return 'Enter a 6-digit OTP';
              return null;
            },
          ),
          const SizedBox(height: 32),
          SachGradientButton(label: 'Verify & Continue', onPressed: _verifyOtpLocal),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _formKey2,
      child: Column(
        key: const ValueKey(2),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Set New Password',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Your new password must be at least 8 characters long.',
            style: TextStyle(color: kTextSub, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 24),
          const SachLabel('New Password'),
          TextFormField(
            controller: _passwordController,
            obscureText: !_showPassword,
            style: const TextStyle(color: Colors.white),
            decoration: sachInputDecoration(
              hint: 'Enter new password',
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: kGold, size: 20),
              suffixIcon: IconButton(
                icon: Icon(_showPassword ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: kTextSub, size: 20),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (v.length < 8) return 'Minimum 8 characters required';
              return null;
            },
          ),
          const SizedBox(height: 16),
          const SachLabel('Confirm New Password'),
          TextFormField(
            controller: _confirmController,
            obscureText: !_showConfirm,
            style: const TextStyle(color: Colors.white),
            decoration: sachInputDecoration(
              hint: 'Confirm new password',
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: kGold, size: 20),
              suffixIcon: IconButton(
                icon: Icon(_showConfirm ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: kTextSub, size: 20),
                onPressed: () => setState(() => _showConfirm = !_showConfirm),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              return null;
            },
          ),
          const SizedBox(height: 32),
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: kGold))
              : SachGradientButton(label: 'Reset Password', onPressed: _confirmReset),
        ],
      ),
    );
  }
}

class _CnicFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 13; i++) {
      if (i == 5 || i == 12) buffer.write('-');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return next.copyWith(text: str, selection: TextSelection.collapsed(offset: str.length));
  }
}

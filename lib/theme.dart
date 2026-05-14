import 'package:flutter/material.dart';

// ─── Color Palette — Pakistan Government ─────────────────────────────────────
const Color kBgDeep = Color(0xFF050F08); // deep forest black-green
const Color kBgCard = Color(0xFF0C1F10); // dark emerald card
const Color kGreen = Color(0xFF01763A); // Pakistan flag green
const Color kGold = Color(0xFFD4AF37); // government gold
const Color kEmerald = Color(0xFF4CAF50); // muted emerald
const Color kDivider = Color(0xFF132B18); // dark green divider
const Color kTextSub = Color(0xFF6B8C6E); // muted green-gray
const Color kInputBg = Color(0xFF0F2414); // input field bg

// ─── Background Glow Blobs ────────────────────────────────────────────────────
/// Drop this into a [Stack] as the first child to get the same ambient glow
/// effect used on the home/splash screen.
class SachBackgroundGlow extends StatelessWidget {
  const SachBackgroundGlow({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Positioned(
          top: -size.height * 0.12,
          left: -size.width * 0.25,
          child: _GlowBlob(color: kGold, radius: 260),
        ),
        Positioned(
          bottom: -size.height * 0.08,
          right: -size.width * 0.25,
          child: _GlowBlob(color: kGreen, radius: 230),
        ),
        Positioned(
          top: size.height * 0.42,
          left: size.width * 0.35,
          child: _GlowBlob(color: kEmerald, radius: 150),
        ),
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double radius;
  const _GlowBlob({required this.color, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.14), Colors.transparent],
        ),
      ),
    );
  }
}

// ─── Input Decoration ────────────────────────────────────────────────────────
InputDecoration sachInputDecoration({
  required String hint,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: kTextSub, fontSize: 14),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: kInputBg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: kDivider, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: kDivider, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: kGreen, width: 1.5),
    ),
  );
}

// ─── Gradient Button ─────────────────────────────────────────────────────────
class SachGradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;

  const SachGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kGreen, Color(0xFF015C2E)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: kGreen.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Secondary Outline Button ─────────────────────────────────────────────────
class SachOutlineButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;

  const SachOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: kGreen.withOpacity(0.4), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          foregroundColor: Colors.white,
          backgroundColor: kInputBg,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: kGold),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w600,
                fontSize: 15,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────
class SachLabel extends StatelessWidget {
  final String text;
  const SachLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.75),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─── Footer Links ─────────────────────────────────────────────────────────────
class SachFooterLinks extends StatelessWidget {
  const SachFooterLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _link('Privacy Policy'),
          _dot(),
          _link('Terms of Service'),
          _dot(),
          _link('Help Center'),
        ],
      ),
    );
  }

  Widget _link(String label) => Text(
    label,
    style: TextStyle(
      color: kTextSub,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    ),
  );

  Widget _dot() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: Text('·', style: TextStyle(color: kTextSub, fontSize: 11)),
  );
}


// ─── SMS OTP Sheet ────────────────────────────────────────────────────────────
void showOtpSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: const _OtpSheet(),
    ),
  );
}

class _OtpSheet extends StatefulWidget {
  const _OtpSheet();
  @override
  State<_OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends State<_OtpSheet> {
  final List<TextEditingController> _ctrs = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  bool _verified = false;
  int _resendSeconds = 30;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Auto-focus first box
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nodes[0].requestFocus();
    });
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_resendSeconds > 0) _resendSeconds--;
      });
      return _resendSeconds > 0;
    });
  }

  @override
  void dispose() {
    for (final c in _ctrs) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  void _onChanged(String val, int index) {
    if (val.length == 1 && index < 5) {
      _nodes[index + 1].requestFocus();
    } else if (val.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }
  }

  void _verify() {
    setState(() => _verified = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: kGreen.withOpacity(0.2), width: 1.5),
      ),
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: kDivider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),

          // Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kGreen.withOpacity(0.1),
              border: Border.all(color: kGreen.withOpacity(0.35), width: 1.5),
            ),
            child: const Icon(
              Icons.smartphone_rounded,
              color: kGreen,
              size: 28,
            ),
          ),
          const SizedBox(height: 20),

          Text(
            _verified ? 'OTP Verified!' : 'Enter SMS OTP',
            style: TextStyle(
              color: _verified ? kGold : Colors.white.withOpacity(0.95),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _verified
                ? 'You have been authenticated successfully'
                : 'A 6-digit code has been sent to your registered\nmobile number via SMS',
            textAlign: TextAlign.center,
            style: TextStyle(color: kTextSub, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 32),

          // OTP boxes
          if (!_verified) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (i) => _OtpBox(
                  controller: _ctrs[i],
                  focusNode: _nodes[i],
                  onChanged: (v) => _onChanged(v, i),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Verify button
            SachGradientButton(label: 'Verify OTP', onPressed: _verify),
            const SizedBox(height: 16),

            // Resend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the code? ",
                  style: TextStyle(color: kTextSub, fontSize: 13),
                ),
                _resendSeconds > 0
                    ? Text(
                        'Resend in ${_resendSeconds}s',
                        style: TextStyle(color: kTextSub, fontSize: 13),
                      )
                    : GestureDetector(
                        onTap: () {
                          setState(() => _resendSeconds = 30);
                          _startResendTimer();
                        },
                        child: Text(
                          'Resend OTP',
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
            ),
          ] else ...[
            // Success icon
            Icon(Icons.check_circle_rounded, color: kGold, size: 64),
          ],

          const SizedBox(height: 16),

          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: kTextSub, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Single OTP digit box ──────────────────────────────────────────────────────
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: kInputBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: kDivider, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: kDivider, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kGold, width: 2),
          ),
        ),
      ),
    );
  }
}

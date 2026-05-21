import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'dashboard_screen.dart';
import 'my_firs_screen.dart';
import 'alerts_screen.dart';
import 'profile_screen.dart';
import 'file_fir_screen.dart';
import 'edit_profile_screen.dart';
import 'main_screen.dart';
import 'app_nav.dart';

class AppRefreshObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      triggerGlobalRefresh();
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (route is PageRoute) {
      triggerGlobalRefresh();
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const SachApp());
}

class SachApp extends StatelessWidget {
  const SachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SACH',
      theme: ThemeData(brightness: Brightness.dark, fontFamily: 'Roboto'),
      home: const SachSplashScreen(),
      navigatorObservers: [AppRefreshObserver()],
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const MainScreen(),
        '/my_firs': (context) => const MyFirsScreen(),
        '/alerts': (context) => const AlertsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/file_fir': (context) => const FileFirScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
      },
    );
  }
}

// ─── Splash-local colors (mirror theme.dart) ────────────────────────────
const Color kBgDeep = Color(0xFF050F08);
const Color kBgCard = Color(0xFF0C1F10);
const Color kCyan = Color(0xFF01763A); // Pakistan flag green
const Color kPurple = Color(0xFFD4AF37); // SACH gold
const Color kAccentEnd = Color(0xFF4CAF50); // Muted emerald
const Color kDivider = Color(0xFF132B18);
const Color kTextSub = Color(0xFF6B8C6E);

// ─── Animated Splash Screen ────────────────────────────────────────────────
class SachSplashScreen extends StatefulWidget {
  const SachSplashScreen({super.key});

  @override
  State<SachSplashScreen> createState() => _SachSplashScreenState();
}

class _SachSplashScreenState extends State<SachSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _contentCtrl;
  late final AnimationController _shimmerCtrl;
  late final AnimationController _glowCtrl;
  late final AnimationController _lineCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _shimmer;
  late final Animation<double> _glow;
  late final Animation<double> _lineWidth;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _lineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoScale = CurvedAnimation(
      parent: _logoCtrl,
      curve: Curves.elasticOut,
    ).drive(Tween(begin: 0.4, end: 1.0));
    _logoFade = CurvedAnimation(
      parent: _logoCtrl,
      curve: Curves.easeIn,
    ).drive(Tween(begin: 0.0, end: 1.0));

    _contentFade = CurvedAnimation(
      parent: _contentCtrl,
      curve: Curves.easeIn,
    ).drive(Tween(begin: 0.0, end: 1.0));
    _contentSlide = CurvedAnimation(
      parent: _contentCtrl,
      curve: Curves.easeOutCubic,
    ).drive(Tween(begin: const Offset(0, 0.12), end: Offset.zero));

    _shimmer = CurvedAnimation(
      parent: _shimmerCtrl,
      curve: Curves.easeInOut,
    ).drive(Tween(begin: -1.5, end: 2.5));
    _glow = CurvedAnimation(
      parent: _glowCtrl,
      curve: Curves.easeInOut,
    ).drive(Tween(begin: 0.3, end: 0.8));
    _lineWidth = CurvedAnimation(
      parent: _lineCtrl,
      curve: Curves.easeOutCubic,
    ).drive(Tween(begin: 0.0, end: 1.0));

    // Stagger animations
    Future.delayed(const Duration(milliseconds: 100), () {
      _logoCtrl.forward().then((_) {
        _lineCtrl.forward();
        Future.delayed(
          const Duration(milliseconds: 200),
          () => _contentCtrl.forward(),
        );
      });
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _contentCtrl.dispose();
    _shimmerCtrl.dispose();
    _glowCtrl.dispose();
    _lineCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDeep,
      body: Stack(
        children: [
          // ── Background particle glow ──
          const _BackgroundGlow(),

          // ── Main content ──
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28.0,
                      vertical: 40.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),

                        // Animated Logo with shimmer
                        FadeTransition(
                          opacity: _logoFade,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: _ShimmerLogo(shimmer: _shimmer, glow: _glow),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Animated accent line
                        AnimatedBuilder(
                          animation: _lineWidth,
                          builder: (context, _) {
                            return Container(
                              width: 120 * _lineWidth.value,
                              height: 1.5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(1),
                                gradient: LinearGradient(
                                  colors: [
                                    kPurple.withOpacity(0.0),
                                    kPurple.withOpacity(0.6),
                                    kPurple.withOpacity(0.0),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 8),

                        // Subtitle
                        FadeTransition(
                          opacity: _logoFade,
                          child: Text(
                            'Secure Authenticated Complaint Handling',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: kPurple.withOpacity(0.9),
                              letterSpacing: 3.0,
                            ),
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Auth card
                        SlideTransition(
                          position: _contentSlide,
                          child: FadeTransition(
                            opacity: _contentFade,
                            child: const _AuthCard(),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Footer
                        FadeTransition(
                          opacity: _contentFade,
                          child: _FooterBadge(),
                        ),

                        const SizedBox(height: 16),
                      ],
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
}

// ─── Background glow blobs ─────────────────────────────────────────────────
class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Positioned(
          top: -size.height * 0.15,
          left: -size.width * 0.2,
          child: _GlowBlob(color: kPurple, radius: 280),
        ),
        Positioned(
          bottom: -size.height * 0.05,
          right: -size.width * 0.2,
          child: _GlowBlob(color: kCyan, radius: 240),
        ),
        Positioned(
          top: size.height * 0.4,
          left: size.width * 0.3,
          child: _GlowBlob(color: kAccentEnd, radius: 160),
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
          colors: [color.withOpacity(0.18), Colors.transparent],
        ),
      ),
    );
  }
}

// ─── Shimmer Logo ──────────────────────────────────────────────────────────
class _ShimmerLogo extends StatelessWidget {
  final Animation<double> shimmer;
  final Animation<double> glow;
  const _ShimmerLogo({required this.shimmer, required this.glow});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([shimmer, glow]),
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kPurple.withOpacity(glow.value * 0.2),
                blurRadius: 50,
                spreadRadius: 10,
              ),
            ],
          ),
          child: ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment(shimmer.value - 0.5, -0.3),
                end: Alignment(shimmer.value + 0.5, 0.3),
                colors: const [
                  Color(0xFFD4AF37),
                  Color(0xFFFFF8DC),
                  Color(0xFFD4AF37),
                ],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: Image.asset(
              'assets/images/sach_logo.png',
              height: 90,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}

// ─── Auth Card ─────────────────────────────────────────────────────────────
class _AuthCard extends StatelessWidget {
  const _AuthCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: kCyan.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: kCyan.withOpacity(0.08),
            blurRadius: 48,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          // Card header
          Center(
            child: Text(
              'Citizen Access Portal',
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),

          const SizedBox(height: 24),
          _Divider(),
          const SizedBox(height: 24),

          // Register button
          _GradientButton(
            onPressed: () => Navigator.of(context).pushNamed('/signup'),
            icon: Icons.fingerprint_rounded,
            label: 'Register via SACH',
          ),

          const SizedBox(height: 14),

          // Login button
          _OutlineButton(
            onPressed: () => Navigator.of(context).pushNamed('/login'),
            icon: Icons.shield_outlined,
            label: 'Secure Login',
          ),

          const SizedBox(height: 20),

          // Trust row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TrustBadge(
                icon: Icons.lock_rounded,
                label: 'End-to-End Encrypted',
              ),
              const SizedBox(width: 4),
              Container(width: 1, height: 12, color: kDivider),
              const SizedBox(width: 4),
              _TrustBadge(icon: Icons.verified_rounded, label: 'SACH Verified'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: kDivider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Choose an option',
            style: TextStyle(color: kTextSub, fontSize: 11, letterSpacing: 0.5),
          ),
        ),
        Expanded(child: Container(height: 1, color: kDivider)),
      ],
    );
  }
}

class _GradientButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  const _GradientButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kCyan, kPurple],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: kPurple.withOpacity(_hovering ? 0.55 : 0.3),
              blurRadius: _hovering ? 24 : 14,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: kCyan.withOpacity(_hovering ? 0.3 : 0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Text(
                widget.label,
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
      ),
    );
  }
}

class _OutlineButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  const _OutlineButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  State<_OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<_OutlineButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        decoration: BoxDecoration(
          color: _hovering
              ? Colors.white.withOpacity(0.04)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovering
                ? kCyan.withOpacity(0.5)
                : Colors.white.withOpacity(0.12),
            width: 1.5,
          ),
        ),
        child: TextButton(
          onPressed: widget.onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: Colors.white.withOpacity(0.85),
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: kCyan.withOpacity(0.7)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: kTextSub,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ─── Gradient Text ─────────────────────────────────────────────────────────
class _GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  const _GradientText(this.text, {required this.style});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.white, Color(0xFF4DD97A), kPurple],
        stops: [0.0, 0.5, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}

// ─── Footer Badge ──────────────────────────────────────────────────────────
class _FooterBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: kCyan.withOpacity(0.06),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: kCyan.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kCyan,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Identity verification via Mock NADRA API',
            style: TextStyle(
              color: kPurple.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

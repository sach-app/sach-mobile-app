import 'package:flutter/material.dart';
import 'theme.dart';
import 'locale_store.dart';
import 'app_strings.dart';
import 'fir_model.dart';
import 'fir_store.dart';
import 'sach_route.dart';

// Forward-declare to avoid circular imports — resolved at call site via dynamic navigation.
// Each screen passes its "current page index" so its own tab isn't tapped.

/// Global notifier for the main application tab index (0=Home, 1=MyFirs, 2=Alerts, 3=Profile)
final appTabNotifier = ValueNotifier<int>(0);

/// Build the standard 3-dots [PopupMenuButton] used on every screen.
///
/// [currentIdx] — 0=Home/Dashboard, 1=My FIRs, 2=Alerts, 3=Profile
/// [extraItems] — optional screen-specific items prepended before nav items
Widget buildAppMenu(
  BuildContext context,
  int currentIdx, {
  List<PopupMenuEntry<String>> extraItems = const [],
}) {
  return PopupMenuButton<String>(
    icon: Icon(
      Icons.more_vert_rounded,
      color: Colors.white.withOpacity(0.6),
      size: 22,
    ),
    color: kBgCard,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    onSelected: (value) => _handleMenuAction(context, value),
    itemBuilder: (_) {
      final items = <PopupMenuEntry<String>>[
        ...extraItems,
        if (extraItems.isNotEmpty) const PopupMenuDivider(height: 1),
        // ── Language toggle ──────────────────────────────────
        _menuItem(Icons.language_rounded, S.switchLang, 'lang'),
        const PopupMenuDivider(height: 1),
        // ── Navigate to all other pages ──────────────────────
        if (currentIdx != 0)
          _menuItem(Icons.home_rounded, S.goToDashboard, 'nav_home'),
        if (currentIdx != 1)
          _menuItem(Icons.folder_open_rounded, S.goToMyFirs, 'nav_my_firs'),
        if (currentIdx != 2)
          _menuItem(Icons.notifications_rounded, S.goToAlerts, 'nav_alerts'),
        if (currentIdx != 3)
          _menuItem(Icons.person_rounded, S.goToProfile, 'nav_profile'),
        _menuItem(
          Icons.add_circle_outline_rounded,
          S.fileNewFir,
          'nav_file_fir',
        ),
        const PopupMenuDivider(height: 1),
        // ── Sign out ─────────────────────────────────────────
        _menuItem(Icons.logout_rounded, S.signOut, 'sign_out', danger: true),
      ];
      return items;
    },
  );
}

Future<void> _handleMenuAction(BuildContext context, String value) async {
  switch (value) {
    case 'lang':
      LocaleStore.instance.toggle();
      break;
    case 'edit_profile':
      Navigator.of(context).pushNamed('/edit_profile');
      break;
    case 'nav_home':
      appTabNotifier.value = 0;
      Navigator.of(context).popUntil((route) => route.settings.name == '/dashboard');
      break;
    case 'nav_my_firs':
      appTabNotifier.value = 1;
      Navigator.of(context).popUntil((route) => route.settings.name == '/dashboard');
      break;
    case 'nav_alerts':
      appTabNotifier.value = 2;
      Navigator.of(context).popUntil((route) => route.settings.name == '/dashboard');
      break;
    case 'nav_profile':
      appTabNotifier.value = 3;
      Navigator.of(context).popUntil((route) => route.settings.name == '/dashboard');
      break;
    case 'nav_file_fir':
      final result = await sachPush<FirItem>(context, const _FileFirProxy());
      if (result != null && context.mounted) FirStore.instance.add(result);
      break;
    case 'sign_out':
      Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
      break;
  }
}

PopupMenuItem<String> _menuItem(
  IconData icon,
  String label,
  String value, {
  bool danger = false,
}) {
  return PopupMenuItem<String>(
    value: value,
    padding: EdgeInsets.zero,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: danger ? Colors.redAccent : kGold, size: 18),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: danger ? Colors.redAccent : Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  );
}

// Proxy widgets to avoid circular imports — they import and show the real screen.
class _DashProxy extends StatelessWidget {
  const _DashProxy();
  @override
  Widget build(BuildContext context) {
    // Lazy import at build time
    return const _LazyScreen(tag: 'dashboard');
  }
}

class _MyFirsProxy extends StatelessWidget {
  const _MyFirsProxy();
  @override
  Widget build(BuildContext context) => const _LazyScreen(tag: 'my_firs');
}

class _AlertsProxy extends StatelessWidget {
  const _AlertsProxy();
  @override
  Widget build(BuildContext context) => const _LazyScreen(tag: 'alerts');
}

class _ProfileProxy extends StatelessWidget {
  const _ProfileProxy();
  @override
  Widget build(BuildContext context) => const _LazyScreen(tag: 'profile');
}

class _FileFirProxy extends StatelessWidget {
  const _FileFirProxy();
  @override
  Widget build(BuildContext context) => const _LazyScreen(tag: 'file_fir');
}

// ignore: must_be_immutable
class _LazyScreen extends StatelessWidget {
  final String tag;
  const _LazyScreen({required this.tag});

  @override
  Widget build(BuildContext context) {
    // Use pushReplacementNamed so this blank proxy screen is removed from
    // the stack — fixes the double-back-tap issue.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      switch (tag) {
        case 'dashboard':
          Navigator.of(context).pushReplacementNamed('/dashboard');
          break;
        case 'my_firs':
          Navigator.of(context).pushReplacementNamed('/my_firs');
          break;
        case 'alerts':
          Navigator.of(context).pushReplacementNamed('/alerts');
          break;
        case 'profile':
          Navigator.of(context).pushReplacementNamed('/profile');
          break;
        case 'file_fir':
          Navigator.of(context).pushReplacementNamed('/file_fir');
          break;
      }
    });
    return const Scaffold(backgroundColor: Color(0xFF061009));
  }
}

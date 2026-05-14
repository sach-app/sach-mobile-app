import 'package:flutter/material.dart';
import 'theme.dart';

/// Shared SACH branded header bar used across all main screens.
///
/// Displays the SACH logo image followed by a gold vertical divider
/// and the page title. Optional [actions] can be added to the right.
class SachHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final String? subtitle;

  const SachHeader({
    super.key,
    required this.title,
    this.actions,
    this.subtitle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        color: kBgCard,
        border: Border(bottom: BorderSide(color: kDivider, width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // SACH Logo
            Image.asset(
              'assets/images/sach_logo.png',
              height: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            // Vertical gold divider
            Container(
              width: 1.5,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    kGold.withOpacity(0.0),
                    kGold.withOpacity(0.5),
                    kGold.withOpacity(0.0),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Page title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle!,
                        style: TextStyle(
                          color: kGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Actions
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }
}

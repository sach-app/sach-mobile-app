import 'dart:convert';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'api_service.dart';

void showChangePasswordDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => const _ChangePasswordDialog(),
  );
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_newController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.put(
        '/user/change-password',
        {
          'current_password': _currentController.text,
          'new_password': _newController.text,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: kGold, size: 18),
                const SizedBox(width: 10),
                const Text('Password changed successfully', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
            backgroundColor: kBgCard,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      } else {
        final data = jsonDecode(response.body);
        final detail = data['detail'] ?? 'Failed to change password';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(detail.toString()), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error.'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kBgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Change Password',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SachLabel('Current Password'),
              TextFormField(
                controller: _currentController,
                obscureText: _obscureCurrent,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: sachInputDecoration(
                  hint: 'Enter current password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: kGold, size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureCurrent ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: kTextSub, size: 18),
                    onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              SachLabel('New Password'),
              TextFormField(
                controller: _newController,
                obscureText: _obscureNew,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: sachInputDecoration(
                  hint: 'Enter new password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: kGold, size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: kTextSub, size: 18),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              SachLabel('Confirm Password'),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: sachInputDecoration(
                  hint: 'Confirm new password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: kGold, size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: kTextSub, size: 18),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: kTextSub)),
        ),
        _isLoading
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: kGold, strokeWidth: 2),
                ),
              )
            : TextButton(
                onPressed: _submit,
                child: const Text('Change', style: TextStyle(color: kGold, fontWeight: FontWeight.w700)),
              ),
      ],
    );
  }
}

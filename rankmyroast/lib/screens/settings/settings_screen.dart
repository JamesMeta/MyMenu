import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:rankmyroast/classes/mixin/snackbar_service.dart';
import 'package:rankmyroast/common_widgets/confirmation_dialog_widget.dart';
import 'package:rankmyroast/services/supabase_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SnackbarService {
  final TextEditingController _usernameController = TextEditingController();
  bool _isChangingUsername = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontSize: 32),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.green,
      body: Container(
        decoration: const BoxDecoration(color: Colors.green),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                Text(
                  'Manage your profile and account preferences.',
                  style: TextStyle(color: Colors.white, fontSize: 15.sp),
                ),
                SizedBox(height: 28.h),
                _buildSettingSection(
                  icon: Icons.person_outline,
                  title: 'Change username',
                  description: 'Choose how other people see you.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _usernameController,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'New username',
                          prefixIcon: const Icon(Icons.alternate_email),
                          filled: true,
                          fillColor: const Color(0xFFF7F9F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed:
                              _isChangingUsername
                                  ? null
                                  : () => _changeUsername(
                                    _usernameController.text.trim(),
                                  ),
                          icon: const Icon(Icons.check, size: 18),
                          label: Text(
                            _isChangingUsername ? 'Saving...' : 'Save username',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                _buildSettingSection(
                  icon: Icons.delete_outline,
                  title: 'Delete account',
                  description: 'Permanently remove your account and data.',
                  isDestructive: true,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () => deleteAccount(context),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete account'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFB3261E),
                        side: const BorderSide(color: Color(0xFFE5A6A1)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingSection({
    required IconData icon,
    required String title,
    required String description,
    required Widget child,
    bool isDestructive = false,
  }) {
    final accentColor =
        isDestructive ? const Color(0xFFB3261E) : const Color(0xFF2F6B3A);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(235),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withAlpha(35)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF23452B).withAlpha(18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: accentColor, size: 25),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: const Color(0xFF1D2B20),
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: TextStyle(
                        color: const Color(0xFF68756B),
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          child,
        ],
      ),
    );
  }

  Future<void> deleteAccount(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (BuildContext context) => ConfirmationDialogWidget(
            title: "Delete Account",
            content:
                "Are you sure you want to delete your account? This action cannot be undone.",
            confirmButtonText: "Delete",
            cancelButtonText: "Cancel",
            isDestructiveAction: true,
          ),
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await Supabase.instance.client.rpc('delete_user_account');

      await Supabase.instance.client.auth.signOut();

      if (context.mounted) {
        context.go("/login");
      }
    } on PostgrestException catch (error) {
      if (context.mounted) {
        showErrorSnackbar(
          context,
          'Failed to delete account: ${error.message}',
        );
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackbar(context, 'An unexpected error occurred.');
      }

      if (context.mounted) {
        context.go("/login");
      }
    }
  }

  Future<bool> _changeUsername(String newUsername) async {
    if (!mounted) {
      return false;
    }

    final response = await showDialog(
      context: context,
      builder:
          (context) => ConfirmationDialogWidget(
            title: "Change Username",
            content: "Are you sure you want to change your username?",
            confirmButtonText: "Change",
            cancelButtonText: "Cancel",
          ),
    );

    if (response != true) {
      return false;
    }

    setState(() => _isChangingUsername = true);

    try {
      final response = await SupabaseHelper.users.setUsername(newUsername);
      if (response && mounted) {
        showSuccessSnackbar(context, 'Username changed successfully!');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      showSnackbar(context, 'Failed to change username: $e');
      return false;
    } finally {
      if (mounted) {
        setState(() => _isChangingUsername = false);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}

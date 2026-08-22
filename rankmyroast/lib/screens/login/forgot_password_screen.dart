import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:rankmyroast/classes/mixin/snackbar_service.dart';
import 'package:rankmyroast/screens/login/classes/clipped_container.dart';
import 'package:rankmyroast/screens/login/classes/login_screen_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ForgotPasswordStep { email, otp, newPassword }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SnackbarService {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  ForgotPasswordStep _step = ForgotPasswordStep.email;
  bool _isLoading = false;
  bool _isResending = false;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return PopScope<void>(
      canPop: _step == ForgotPasswordStep.email,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goToPreviousStep();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _goToPreviousStep,
          ),
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Container(color: Colors.green),
            Center(
              child: SingleChildScrollView(
                child: ClipPath(
                  clipper: ClippedContainer(),
                  child: Container(
                    constraints: BoxConstraints(minHeight: height * 0.68),
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 56,
                    ),
                    child: Center(child: _buildCurrentStep()),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case ForgotPasswordStep.email:
        return _buildEmailInputField();
      case ForgotPasswordStep.otp:
        return _buildOtpInputField();
      case ForgotPasswordStep.newPassword:
        return _buildNewPasswordInputField();
    }
  }

  Widget _buildStepContent({
    required String title,
    required String message,
    required Widget field,
    required String buttonText,
    required VoidCallback? onPressed,
    Widget? footer,
  }) {
    return Column(
      children: [
        Text(title, style: LoginScreenTheme.sectionTitleStyle),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center),
        SizedBox(height: LoginScreenTheme.sizeBoxSpacingHeight * 2),
        field,
        SizedBox(height: LoginScreenTheme.sizeBoxSpacingHeight * 2),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPressed,
            style: LoginScreenTheme.elevatedButtonStyle,
            child:
                _isLoading
                    ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
        if (footer != null) footer,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int? maxLength,
    bool obscureText = false,
  }) {
    return Container(
      height: LoginScreenTheme.textFieldContainerHeight,
      width: LoginScreenTheme.textFieldContainerWidth,
      decoration: LoginScreenTheme.textFieldContainerDecoration,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        obscureText: obscureText,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,

        decoration: InputDecoration(
          border: InputBorder.none, // Removes default underline
          enabledBorder:
              InputBorder.none, // Ensures no underline when unfocused
          focusedBorder: InputBorder.none, // Ensures no underline when focused
          counterText: '',
          labelText: null,
          hintText: maxLength != null ? '00000000' : label,
          hintStyle: const TextStyle(color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildEmailInputField() {
    return _buildStepContent(
      title: 'Reset Password',
      message: 'Enter your email and we will send you an 8-digit code.',
      field: _buildTextField(
        controller: _emailController,
        label: 'Email',
        keyboardType: TextInputType.emailAddress,
      ),
      buttonText: 'Send Reset Code',
      onPressed: _isLoading ? null : _handleSendCode,
    );
  }

  Widget _buildOtpInputField() {
    return _buildStepContent(
      title: 'Check Your Email',
      message:
          'Enter the 8-digit code sent to ${_emailController.text.trim()}.',
      field: _buildTextField(
        controller: _otpController,
        label: '8-digit code',
        keyboardType: TextInputType.number,
        maxLength: 8,
      ),
      buttonText: 'Verify Code',
      onPressed: _isLoading ? null : _handleVerifyCode,
      footer: Column(
        children: [
          TextButton(
            onPressed: _isResending || _isLoading ? null : _handleResend,
            child:
                _isResending
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Text(
                      "Didn't receive it? Resend code",
                      style: LoginScreenTheme.textButtonTextStyle,
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewPasswordInputField() {
    return _buildStepContent(
      title: 'Create New Password',
      message: 'Choose a strong password for your account.',
      field: _buildTextField(
        controller: _newPasswordController,
        label: 'New password',
        obscureText: true,
      ),
      buttonText: 'Set New Password',
      onPressed: _isLoading ? null : _handleSetPassword,
    );
  }

  void _goToPreviousStep() {
    if (_isLoading || !mounted) return;
    if (_step == ForgotPasswordStep.email) {
      context.pop();
      return;
    }
    setState(() {
      _step =
          _step == ForgotPasswordStep.newPassword
              ? ForgotPasswordStep.otp
              : ForgotPasswordStep.email;
    });
  }

  Future<void> _handleSendCode() async {
    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      showSnackbar(context, 'Please enter a valid email address.');
      return;
    }
    setState(() => _isLoading = true);
    final sent = await sendPasswordResetEmail(email);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (sent) _step = ForgotPasswordStep.otp;
    });
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (mounted) showSnackbar(context, 'Reset code sent. Check your inbox.');
      return true;
    } on AuthException catch (error) {
      if (mounted) {
        showSnackbar(context, 'Unable to send reset code: ${error.message}');
      }
      return false;
    }
  }

  Future<void> _handleVerifyCode() async {
    final token = _otpController.text.trim();
    if (token.length != 8) {
      showSnackbar(context, 'Please enter the full 8-digit code.');
      return;
    }
    setState(() => _isLoading = true);
    final verified = await verifyResetOtp(
      email: _emailController.text.trim(),
      token: token,
    );
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (verified) _step = ForgotPasswordStep.newPassword;
    });
  }

  Future<bool> verifyResetOtp({
    required String email,
    required String token,
  }) async {
    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );

      if (response.session != null) {
        return true;
      } else {
        if (mounted) showSnackbar(context, 'That code was not accepted.');
      }
    } on AuthException catch (error) {
      if (mounted) {
        showSnackbar(context, 'Invalid or expired code: ${error.message}');
      }
    }
    return false;
  }

  Future<void> _handleResend() async {
    setState(() => _isResending = true);
    await sendPasswordResetEmail(_emailController.text.trim());
    if (mounted) setState(() => _isResending = false);
  }

  Future<void> _handleSetPassword() async {
    final password = _newPasswordController.text;
    if (password.length < 6) {
      showSnackbar(context, 'Password must be at least 6 characters.');
      return;
    }
    setState(() => _isLoading = true);
    await setNewPassword(password);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> setNewPassword(String newPassword) async {
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (mounted) {
        showSnackbar(context, "Password updated successfully.");
        context.go('/base');
      }
    } on AuthException catch (error) {
      if (mounted) {
        showSnackbar(context, 'Unable to update password: ${error.message}');
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }
}

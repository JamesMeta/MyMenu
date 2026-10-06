import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mymenu/classes/mixin/snackbar_service.dart';
import 'package:mymenu/services/supabase_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

const serverClientId =
    "474584121880-5f7qh4hd4eonbpirt35mnddrlmahma9n.apps.googleusercontent.com";

class SignInWithGoogle with SnackbarService {
  static Future<void> handleSignInWithGoogle(BuildContext context) async {
    try {
      final signInResponse = await signInWithGoogle();
      if (context.mounted) {
        if (signInResponse?.user?.role == "authenticated") {
          await SupabaseHelper.users.addUser();
          await SupabaseHelper.groups.createPersonalGroup();
          if (context.mounted) context.go('/base');
        } else {
          SnackbarService.showSnackbarStatic(
            context,
            'Sign in failed. Please try again.',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarService.showSnackbarStatic(
          context,
          'Error: ${e.toString().split("code: ").last}',
        );
      }
    }
  }

  static Future<AuthResponse?> signInWithGoogle() async {
    final GoogleSignIn signIn = GoogleSignIn.instance;

    // 1. Mandatory initialization step
    await signIn.initialize(serverClientId: serverClientId);

    // 2. Authenticate user via Credential Manager sheet
    final GoogleSignInAccount googleUser;
    try {
      googleUser = await signIn.authenticate();
    } catch (e) {
      return null;
    }

    // 3. Retrieve the ID token from authentication
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      return null;
    }

    // 4. Pass token to Supabase
    final response = await SupabaseHelper.auth.authSigninWithIdToken(
      idToken,
      OAuthProvider.google,
    );

    return response;
  }
}

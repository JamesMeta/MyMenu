import 'package:flutter/material.dart';
import 'package:mymenu/services/supabase_helper.dart';
import 'package:go_router/go_router.dart';

class SignOutDialogWidget extends StatelessWidget {
  const SignOutDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Logout"),
      content: Text("Are you sure you want to logout?"),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            await _signOut(context);
          },
          child: Text("Log Out", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await SupabaseHelper.auth.authSignOut();

    if (context.mounted) {
      context.go("/login");
    }
  }
}

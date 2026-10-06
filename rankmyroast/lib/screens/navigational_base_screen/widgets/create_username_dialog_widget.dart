import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rankmyroast/services/supabase_helper.dart';

class CreateUsernameDialogWidget extends StatefulWidget {
  const CreateUsernameDialogWidget({super.key});

  @override
  State<CreateUsernameDialogWidget> createState() =>
      _CreateUsernameDialogWidgetState();
}

class _CreateUsernameDialogWidgetState
    extends State<CreateUsernameDialogWidget> {
  final TextEditingController usernameController = TextEditingController();

  bool isLoading = false;
  bool isValidUsername = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Create Username",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "In order to collaborate with others you must first make a username",
          ),
          SizedBox(height: 12),
          TextField(
            controller: usernameController,
            decoration: InputDecoration(
              labelText: "Username",
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          if (!isValidUsername) ...[
            SizedBox(height: 8),
            Text(
              "Username must be unique and can only contain letters, numbers, and underscores.",
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],

          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              final usernameSet = await _setUsername(usernameController.text);
              setState(() {
                isLoading = false;
                isValidUsername = usernameSet;
              });
              if (usernameSet && context.mounted) {
                context.pop();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child:
                isLoading
                    ? CircularProgressIndicator()
                    : Text(
                      "Set Username",
                      style: TextStyle(color: Colors.white),
                    ),
          ),
        ],
      ),
    );
  }

  Future<bool> _isUsernameValid(final String username) async {
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    final validUsername = await SupabaseHelper.users.checkUsernameUniqueness(
      username,
    );

    return usernameRegex.hasMatch(username) && validUsername;
  }

  Future<bool> _setUsername(final String username) async {
    if (!await _isUsernameValid(username)) {
      return false;
    }

    final usernameUpdated = await SupabaseHelper.users.setUsername(username);
    return usernameUpdated;
  }
}

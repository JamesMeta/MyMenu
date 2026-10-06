import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mymenu/services/supabase_helper.dart';

class TakePhotoBottomModalWidget extends StatelessWidget {
  final bool includeRemoveImage;

  const TakePhotoBottomModalWidget({
    super.key,
    required this.includeRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Photo Library'),
            onTap: () async {
              final file = await _pickPhoto();
              if (context.mounted) {
                context.pop(file);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Camera'),
            onTap: () async {
              final file = await _takePhoto();
              if (context.mounted) {
                context.pop(file);
              }
            },
          ),
          includeRemoveImage
              ? ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove Current Image'),
                onTap: () {
                  if (context.mounted) {
                    context.pop(true);
                  }
                },
              )
              : SizedBox(),
        ],
      ),
    );
  }

  Future<File?> _takePhoto() async {
    final image = await SupabaseHelper.storage.pickImageFromCamera();
    return image;
  }

  Future<File?> _pickPhoto() async {
    final image = await SupabaseHelper.storage.pickImageFromGallery();
    return image;
  }
}

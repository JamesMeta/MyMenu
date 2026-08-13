import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseHelperLogging {
  static final _client = Supabase.instance.client;

  Future<void> logEvent({
    required String type,
    required String location,
    required String content,
  }) async {
    try {
      await _client.from('logging').insert({
        'type': type,
        'location': location,
        'content': content,
        'device_information': await getDeviceInfo(),
        'user_id': _client.auth.currentUser?.id,
      });

      if (kDebugMode) {
        print('Logging event: $type, $location, $content');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to log event: $type, $location, $content $e');
      }
    }
  }

  Future<List<String>> getDeviceInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    final List<String> report = [
      'timestamp ${DateTime.now().toUtc().toIso8601String()}',
      'timezone ${DateTime.now().timeZoneName}',
      'locale ${Platform.localeName}',
      '''app {
        "appName" "${packageInfo.appName}",
        "packageName" "${packageInfo.packageName}",
        "version" "${packageInfo.version}",
        "buildNumber" "${packageInfo.buildNumber}",
      }''',
      '''environment {
        'isDebug' $kDebugMode,
        'isProfile' $kProfileMode,
        'isRelease' $kReleaseMode,
        'isWeb' $kIsWeb ,
      }''',
    ];

    final android = await deviceInfo.androidInfo;
    report.addAll([
      'platform Android',
      'model ${android.model}',
      'brand ${android.brand}',
      'manufacturer ${android.manufacturer}',
      'isPhysicalDevice ${android.isPhysicalDevice}',
      'sdkVersion ${android.version.sdkInt}',
      'releaseVersion ${android.version.release}',
      'buildId ${android.id}',
      'supportedAbis ${android.supportedAbis}',
    ]);
    return report;
  }
}

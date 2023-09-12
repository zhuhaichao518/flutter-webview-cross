import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'webview_windows_platform_interface.dart';

/// An implementation of [WebviewWindowsPlatform] that uses method channels.
class MethodChannelWebviewWindows extends WebviewWindowsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('webview_windows');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}

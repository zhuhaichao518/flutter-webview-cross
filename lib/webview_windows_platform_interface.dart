import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'webview_windows_method_channel.dart';

abstract class WebviewWindowsPlatform extends PlatformInterface {
  /// Constructs a WebviewWindowsPlatform.
  WebviewWindowsPlatform() : super(token: _token);

  static final Object _token = Object();

  static WebviewWindowsPlatform _instance = MethodChannelWebviewWindows();

  /// The default instance of [WebviewWindowsPlatform] to use.
  ///
  /// Defaults to [MethodChannelWebviewWindows].
  static WebviewWindowsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WebviewWindowsPlatform] when
  /// they register themselves.
  static set instance(WebviewWindowsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

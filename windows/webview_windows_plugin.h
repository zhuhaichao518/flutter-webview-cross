#ifndef FLUTTER_PLUGIN_WEBVIEW_WINDOWS_PLUGIN_H_
#define FLUTTER_PLUGIN_WEBVIEW_WINDOWS_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace webview_windows {

class WebviewWindowsPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  WebviewWindowsPlugin();

  virtual ~WebviewWindowsPlugin();

  // Disallow copy and assign.
  WebviewWindowsPlugin(const WebviewWindowsPlugin&) = delete;
  WebviewWindowsPlugin& operator=(const WebviewWindowsPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace webview_windows

#endif  // FLUTTER_PLUGIN_WEBVIEW_WINDOWS_PLUGIN_H_

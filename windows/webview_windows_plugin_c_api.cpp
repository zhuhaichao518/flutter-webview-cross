#include "include/webview_windows/webview_windows_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "webview_windows_plugin.h"

void WebviewWindowsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  webview_windows::WebviewWindowsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

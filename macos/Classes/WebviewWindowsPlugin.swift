import Cocoa
import FlutterMacOS

public class WebviewWindowsPlugin: NSObject, FlutterPlugin {
  var webView2Wrapper = WebView2Wrapper()
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "io.jns.webview.win", binaryMessenger: registrar.messenger)
    let instance = WebviewWindowsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    //case "initialize":
      //webView2Wrapper.initWebView()
    case "navigate":
      webView2Wrapper.navigate()
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

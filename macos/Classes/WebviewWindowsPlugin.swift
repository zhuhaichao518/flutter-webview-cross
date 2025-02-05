import Cocoa
import FlutterMacOS
import MapKit
import AppKit
import CoreGraphics

var webView2Wrapper = WebView2Wrapper()

class MapViewFactory: NSObject, FlutterPlatformViewFactory {
  private var messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func create(
    withViewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> NSView {
    return MapView(
      frame: CGRect(x: 0, y: 0, width: 200, height: 200),
      viewIdentifier: viewId,
      arguments: args,
      binaryMessenger: messenger)
  }

  // Returns the FlutterMessageCodec used to decode any creation arguments passed via
  // the AppKitView creationParams constructor argument.
  //
  // This method is optional, but if left unimplemented, the `arguments` argument to the create
  // method above will be nil.
  func createArgsCodec() -> (FlutterMessageCodec & NSObjectProtocol)? {
    return FlutterStandardMessageCodec.sharedInstance()
  }
}

class MapView: NSView {
  var mapView: NSView?//MKMapView?//NSView?
    var mapView2: MKMapView?//M
    var inited = false
  //var webView2Wrapper = WebView2Wrapper()
  init(
    frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?,
    binaryMessenger messenger: FlutterBinaryMessenger?
  ) {
    super.init(frame: frame)
    super.wantsLayer = true
    super.frame = CGRect(x: 0, y: 0, width: 200, height: 200)

    //mapView = NSView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
    //super.layer?.backgroundColor = NSColor.black.cgColor;
    let channelName = "bracken.jp/mapview_macos_\(viewId)"
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger!)
    channel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      self?.handle(call, result: result)
    })
      
    //if var arguments = args as? [String: Any] {
    //  arguments["animated"] = false
    //  handleSetRegion(arguments)
    //}
    //super.addSubview(mapView!)
      //mapView2 = MKMapView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
      //super.addSubview(mapView2!)
    //NSLayoutConstraint.activate([
    //  mapView!.leadingAnchor.constraint(equalTo: self.leadingAnchor),
    //  mapView!.trailingAnchor.constraint(equalTo: self.trailingAnchor),
    //])
    //WebView2Wrapper().initWebView(self);
  }
    override var frame:NSRect{
        didSet{
            let children = self.subviews
            children.first?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height);
            print("New frame is:\(frame)");


            //CGWheelCount wheelCount = 2; // 1 for Y-only, 2 for Y-X, 3 for Y-X-Z
            //int32_t xScroll = −1; // Negative for right
            //int32_t yScroll = −2; // Negative for down
            //CGEventRef cgEvent = CGEventCreateScrollWheelEvent(NULL, kCGScrollEventUnitLine, wheelCount, yScroll, xScroll);

            // You can post the CGEvent to the event stream to have it automatically sent to the window under the cursor
            //CGEventPost(kCGHIDEventTap, cgEvent);

            //NSEvent *theEvent = [NSEvent eventWithCGEvent:cgEvent];
            //CFRelease(cgEvent);

            // Or you can send the NSEvent directly to a view
            //[children.first? scrollWheel:theEvent];

            //children.first?.interpretKeyEvents([scrollEvent])
            //setNeedsDisplay(NSRect(x:0,y:0,width: self.frame.width, height: self.frame.height));
            //super.layoutSubtreeIfNeeded()
            //self.needsLayout = false;
            //self.layout()
        }
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if self.window != nil  && inited == false {
            webView2Wrapper.initWebView(self)
            inited = true
        }
    }
    
    override func resize(withOldSuperviewSize oldSize:NSSize){
        super.resize(withOldSuperviewSize: oldSize)
    }
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    super.wantsLayer = true
    super.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
    mapView = nil
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "setRegion":
        let args = call.arguments as! [String: Any]
        handleSetRegion(args)
      //case "initialize":
        //todo: maybe we can use mapView as a bridge?
        //webView2Wrapper.initWebView(self)
      case "resize":
        super.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
      case "navigation":
        if let args = call.arguments as? [String:Any],
           let url = args["url"] as? String{
            webView2Wrapper.navigate(url)
        }
      case "pointerdown":
        if let args = call.arguments as? [String:Any],
           let x = args["dx"] as? CGFloat,
           let y = args["dy"] as? CGFloat{
            var mouseLocation = NSEvent.mouseLocation
            mouseLocation.x = x
            mouseLocation.y = y
            let mouseEvent = NSEvent.mouseEvent(with: .leftMouseDown, location: mouseLocation, modifierFlags: [], timestamp: TimeInterval(), windowNumber: 0, context: nil, eventNumber: 0, clickCount: 1, pressure: 1.0)
            
            self.subviews.first?.mouseDown(with: mouseEvent!)
        }
      //case "scrollup":
         
      default:
        result(FlutterMethodNotImplemented)
      }
  }
    
  public func handleSetRegion(_ args: [String: Any]) {
    let centerArg = args["center"] as! [String: Double]
    let region = MKCoordinateRegion(
      center: CLLocation(
        latitude: centerArg["latitude"]!,
        longitude: centerArg["longitude"]!
      ).coordinate,
      latitudinalMeters: args["latitudinalMeters"] as! Double,
      longitudinalMeters: args["longitudinalMeters"] as! Double)
    let animated = args["animated"] as! Bool
    //mapView?.setRegion(region, animated: animated)
  }
}

public class WebviewWindowsPlugin: NSObject, FlutterPlugin {
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let factory = MapViewFactory(messenger: registrar.messenger)
    registrar.register(factory, withId: "@views/mapview-view-type")
      
    let channel = FlutterMethodChannel(name: "io.jns.webview.win", binaryMessenger: registrar.messenger)
    let instance = WebviewWindowsPlugin()
      
    webView2Wrapper.initEnvironment()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

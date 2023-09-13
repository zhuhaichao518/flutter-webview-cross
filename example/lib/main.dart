import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';

import 'package:webview_windows/platformview_test.dart';

import 'src/deformable_native_view.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // For full-screen example
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(navigatorKey: navigatorKey, home: ExampleBrowser());
  }
}

class ExampleBrowser extends StatefulWidget {
  @override
  State<ExampleBrowser> createState() => _ExampleBrowser();
}

class _ExampleBrowser extends State<ExampleBrowser> {
  final _controller = WebviewController();
  final _textController = TextEditingController();
  final List<StreamSubscription> _subscriptions = [];
  bool _isWebviewSuspended = false;

  double opacity = 1.0;
  double radius = 30;
  double scale = 0.75;
  double angle = 0;
  double textAngle = 0;
  bool forward = true;

  MethodChannel channel = MethodChannel('bracken.jp/mapview_macos_0');

  // Hacked in hardcoded locations - extract location setting as methods and move to Dart.
  final List<CoordinateRegion> _regions = const <CoordinateRegion>[
    // Kyoto Gosho zoomed out.
    CoordinateRegion(
        center: Location(latitude: 35.02517, longitude: 135.76354),
        latitudinalMeters: 1000000,
        longitudinalMeters: 1000000),
    // Kyoto Gosho zoomed in.
    CoordinateRegion(
        center: Location(latitude: 35.02517, longitude: 135.76354),
        latitudinalMeters: 10000,
        longitudinalMeters: 10000),
    // Kyoto Gosho more zoomed in.
    CoordinateRegion(
        center: Location(latitude: 35.02517, longitude: 135.76354),
        latitudinalMeters: 1000,
        longitudinalMeters: 1000),
    // Kyoto Gosho zoomed out.
    CoordinateRegion(
        center: Location(latitude: 34.98538, longitude: 135.76320),
        latitudinalMeters: 10000,
        longitudinalMeters: 10000),
    // Osaka-jou zoomed out.
    CoordinateRegion(
        center: Location(
            latitude: 34.687602115847326, longitude: 135.5263715730193),
        latitudinalMeters: 10000,
        longitudinalMeters: 10000),
    // Osaka-jou zoomed out.
    CoordinateRegion(
        center: Location(
            latitude: 34.687602115847326, longitude: 135.5263715730193),
        latitudinalMeters: 3000,
        longitudinalMeters: 3000),
    // Osaka-jou zoomed out.
    CoordinateRegion(
        center: Location(
            latitude: 34.687602115847326, longitude: 135.5263715730193),
        latitudinalMeters: 10000,
        longitudinalMeters: 10000),
    // Osaka-jou zoomed out.
    CoordinateRegion(
        center: Location(
            latitude: 34.687602115847326, longitude: 135.5263715730193),
        latitudinalMeters: 100000,
        longitudinalMeters: 100000),
  ];
  int _region = 0;

  GlobalKey mapviewkey = GlobalKey();

  @override
  void initState() {
    super.initState();
    //initPlatformState();
  }

  Future<void> initPlatformState() async {
    // Optionally initialize the webview environment using
    // a custom user data directory
    // and/or a custom browser executable directory
    // and/or custom chromium command line flags
    //await WebviewController.initializeEnvironment(
    //    additionalArguments: '--show-fps-counter');

    try {
      await _controller.initialize();
      _subscriptions.add(_controller.url.listen((url) {
        _textController.text = url;
      }));

      _subscriptions
          .add(_controller.containsFullScreenElementChanged.listen((flag) {
        debugPrint('Contains fullscreen element: $flag');
        windowManager.setFullScreen(flag);
      }));

      await _controller.setBackgroundColor(Colors.transparent);
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await _controller.loadUrl('https://flutter.dev');

      if (!mounted) return;
      setState(() {});
    } on PlatformException catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: Text('Error'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Code: ${e.code}'),
                      Text('Message: ${e.message}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: Text('Continue'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ));
      });
    }
  }

  Widget compositeView() {
    /*if (!_controller.value.isInitialized) {
      return const Text(
        'Not Initialized',
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {*/
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Card(
            elevation: 0,
            child: Row(children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'URL',
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  controller: _textController,
                  onSubmitted: (val) {
                    _controller.loadUrl(val);
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                splashRadius: 20,
                onPressed: () {
                  _controller.reload();
                },
              ),
              IconButton(
                icon: Icon(Icons.developer_mode),
                tooltip: 'Open DevTools',
                splashRadius: 20,
                onPressed: () {
                  //_controller.openDevTools();
                  MapView mpview = mapviewkey.currentContext?.widget as MapView;
                  channel.invokeMethod("initialize");
                },
              )
            ]),
          ),
          Expanded(
              child: Card(
                  color: Colors.transparent,
                  elevation: 0,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Stack(
                    children: [
                      //Webview(
                      //  _controller,
                      //  permissionRequested: _onPermissionRequested,
                      //),
                      DeformableNativeView(
                        angle: -4 * 3.1415926 / 180 * angle,
                        opacity: opacity,
                        radius: radius,
                        scale: scale,
                        child:
                            MapView(key: mapviewkey, region: _regions[_region]),
                      ),
                      StreamBuilder<LoadingState>(
                          stream: _controller.loadingState,
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.data == LoadingState.loading) {
                              return LinearProgressIndicator();
                            } else {
                              return SizedBox();
                            }
                          }),
                    ],
                  ))),
        ],
      ),
    );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: _isWebviewSuspended ? 'Resume webview' : 'Suspend webview',
        onPressed: () async {
          if (_isWebviewSuspended) {
            await _controller.resume();
          } else {
            await _controller.suspend();
          }
          setState(() {
            _isWebviewSuspended = !_isWebviewSuspended;
          });
        },
        child: Icon(_isWebviewSuspended ? Icons.play_arrow : Icons.pause),
      ),
      appBar: AppBar(
          title: StreamBuilder<String>(
        stream: _controller.title,
        builder: (context, snapshot) {
          return Text(
              snapshot.hasData ? snapshot.data! : 'WebView (Windows) Example');
        },
      )),
      body: Center(
        child: compositeView(),
      ),
    );
  }

  Future<WebviewPermissionDecision> _onPermissionRequested(
      String url, WebviewPermissionKind kind, bool isUserInitiated) async {
    final decision = await showDialog<WebviewPermissionDecision>(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('WebView permission requested'),
        content: Text('WebView has requested permission \'$kind\''),
        actions: <Widget>[
          TextButton(
            onPressed: () =>
                Navigator.pop(context, WebviewPermissionDecision.deny),
            child: const Text('Deny'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, WebviewPermissionDecision.allow),
            child: const Text('Allow'),
          ),
        ],
      ),
    );

    return decision ?? WebviewPermissionDecision.none;
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _controller.dispose();
    super.dispose();
  }
}

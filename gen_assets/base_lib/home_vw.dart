import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart';
import 'utils.dart';
import 'screen_vm.dart';
import 'package:flutter/gestures.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({ super.key, });
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {

  late Map<String, dynamic> configData;
  double progress = 0;
  bool showSplash = true;
  bool showProgress = true;
  InAppWebViewController? webViewController;
  InAppWebViewOptions settings = InAppWebViewOptions(
    mediaPlaybackRequiresUserGesture: false,
    useShouldOverrideUrlLoading: true,
    javaScriptCanOpenWindowsAutomatically: true,
    javaScriptEnabled: true,
    allowFileAccessFromFileURLs: true,
  );
  String baseURL = '';
  bool pullToRefreshSupport = false;
  bool pullToRefreshInline = false;
  bool pullRefreshState = false;
  late bool prfFreshStart;
  late PullToRefreshController pullToRefreshController;
  bool initialSuccess = false;
  bool loadFoundError = false;
  bool isRefreshingPg = true;
  String errorMessage = "Load Failed\nTap On The Above Logo To Retry";
  bool configMetaReady = false;

  void onSetupReady(InAppWebViewController controller) async {
    webViewController = controller;
    webViewController?.addJavaScriptHandler(handlerName: 'GNR_set_pts', callback: (args) {
      if (!pullToRefreshSupport) return false;
      setState(() { pullRefreshState = args[0][0]; });
      return true;
    });
    webViewController?.loadUrl(urlRequest: URLRequest(url: Uri.parse( baseURL )));
  }

  void setupPullToRefreshJS() { if (!pullToRefreshSupport) return;
    webViewController?.evaluateJavascript(
        source:
        "var gnr_scel = []; var gnr_sctp = [];"
        "var gnr_scos = function(){"
            "var a = this;"
            "return window.flutter_inappwebview.callHandler('GNR_set_pts', [ a.scrollTop == 0 ? true : false ]);"
        "};"
        "document.querySelectorAll('html, body, div').forEach(function(el){"
            "var a = window.getComputedStyle(el);"
            "if ((a.overflowY == 'scroll') || (a.overflowY == 'overlay') || (a.overflowY == 'auto')) { gnr_scel.push(el); }"
        "});"
        "document.addEventListener('scroll', function(){"
            "return window.flutter_inappwebview.callHandler('GNR_set_pts', [ window.scrollY == 0 ? true : false ]);"
        "});"
    );
  }

  void updatePullToRefreshJS() { if (!pullToRefreshSupport) return;
    webViewController?.evaluateJavascript(
        source:
        "gnr_sctp.forEach(function(value){ value['a'].removeEventListener('scroll', gnr_scos); });"
        "gnr_sctp = [];"
        "gnr_scel.forEach(function(el){"
            "var a = window.getComputedStyle(el),"
            "b = parseFloat(a.height);"
            "if ((a.display !== 'none') || (a.visibility !== 'hidden')) { gnr_sctp.push({ a: el, b: isNaN(b) ? 0 : b }); }"
        "});"
        "gnr_sctp.sort(function(a,b){ return (b.b - a.b) });"
        "if (gnr_sctp[0]) { gnr_sctp[0]['a'].addEventListener('scroll', gnr_scos); }"
    );
  }

  Widget setupWebView(Widget webView, double screenW, double screenH) {
    return pullToRefreshSupport
    ? pullToRefreshInline
      ? RefreshIndicator(
          onRefresh: () async => webViewController?.reload(), color: colorAccent,
          child: SingleChildScrollView(
            physics: pullToRefreshSupport
              ? pullRefreshState ? const AlwaysScrollableScrollPhysics() : null
              : null,
            child: SizedBox(
              width: screenW + (screenW * 0.0005), height: screenH,
              child: GestureDetector(
                onPanUpdate: !pullRefreshState
                ? null
                : (details) {
                  if (!(details.delta.dy > 0) && !isRefreshingPg) { setState(() { pullRefreshState = false; }); }
                },
                behavior: HitTestBehavior.translucent,
                child: webView,
              ),
            ),
          ),
        )
      : webView
    : webView;
  }

  Future<void> initProcess() async {
    String jsonString = await rootBundle.loadString('assets/raw/config.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    configData = jsonMap.map((key, value) { return MapEntry(key, value); });
    baseURL = configData['baseUrl'];
    if (configData['pullToRefresh']) {
      pullToRefreshSupport = !(kIsWeb || ![ TargetPlatform.iOS, TargetPlatform.android ].contains(defaultTargetPlatform));
      pullToRefreshInline = configData['pullToRefreshInline'] ? configData['pullToRefreshInline'] : false;
    }
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(color: colorAccent,),
      onRefresh: () async {
        if (Platform.isAndroid) { webViewController?.reload(); }
        else if (Platform.isIOS) {
          webViewController?.loadUrl(urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
    setState(() { configMetaReady = true; });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initProcess());
  }

  @override
  Widget build(BuildContext context) {

    SizeConfig().init(context);
    double screenW = SizeConfig.safeBlockHorizontal * 100;
    double screenH = SizeConfig.safeBlockVertical * 100;

    return WillPopScope(
      onWillPop: () async {
        bool? canGoBack = await webViewController?.canGoBack();
        if (canGoBack!) { webViewController?.goBack(); return false;
        }
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false, backgroundColor: colorPrimary,
        body: SafeArea(
          child: Stack(children: [ Container(),
            // WebView
            Positioned(
              width: screenW + (screenW * 0.0005), height: screenH, left: -(screenW * 0.0005),
              child: configMetaReady
              ? setupWebView(
                InAppWebView(
                  pullToRefreshController: pullToRefreshSupport
                  ? pullToRefreshInline ? null : pullToRefreshController
                  : null,
                  initialUserScripts: UnmodifiableListView<UserScript>([]),
                  onWebViewCreated: (controller) async => onSetupReady(controller),
                  onLoadStart: (controller, url) async {
                    prfFreshStart = true;
                    isRefreshingPg = true; loadFoundError = false;
                    progress = 0; showProgress = true; pullRefreshState = false;
                    setState(() { });
                  },
                  onLoadError: (controller, url, code, message) async {
                    loadFoundError = true; pullToRefreshController.endRefreshing();
                  },
                  onLoadStop: (controller, url) async {
                    isRefreshingPg = false; progress = 0; showProgress = false;
                    pullToRefreshController.endRefreshing();
                    if (!loadFoundError) { initialSuccess = true; }
                    if (initialSuccess) { showSplash = false;
                      if (loadFoundError) { pullRefreshState = true; }
                      if (!loadFoundError && prfFreshStart && pullToRefreshSupport && pullToRefreshInline) { prfFreshStart = false;
                        setupPullToRefreshJS();
                        if (pullToRefreshSupport) { pullRefreshState = true; }
                      }
                    }
                    setState(() {  });
                  },
                  onScrollChanged: (controller, int x, int y) { },
                  shouldOverrideUrlLoading: (controller, navigationAction) async {
                    var uri = navigationAction.request.url!;
                    var schemes = [ 'http', 'https', 'file', 'chrome', 'data', 'javascript', 'about' ];

                    debugPrint( (!schemes.contains(uri.scheme)).toString() );

                    if (!schemes.contains(uri.scheme)) { if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,); return NavigationActionPolicy.CANCEL;
                    } }
                    return NavigationActionPolicy.ALLOW;
                  },
                  onProgressChanged: (controller, progs) {
                    if (progress == 100) { pullToRefreshController.endRefreshing();
                    }
                    setState(() { progress = progs / 100; });
                  },
                  onUpdateVisitedHistory: (controller, url, isReload) {
                    if (!isRefreshingPg && !loadFoundError && pullToRefreshSupport && pullToRefreshInline) {
                      updatePullToRefreshJS();
                    }
                  },
                  onConsoleMessage: (controller, consoleMessage) { debugPrint(consoleMessage.message); },
                  ),
                screenW, screenH
              )
              : Container(),
            ),
            // Progress Indication
            progressWidget(showProgress, progress, screenW, screenH),
            // Splash
            splashWidget(showSplash, isRefreshingPg, errorMessage, screenW, screenH, () {
              if (!showSplash || isRefreshingPg || initialSuccess || (webViewController == null)) return;
              webViewController?.reload();
            })
          ]),
        ),
      ),
    );
  }
}

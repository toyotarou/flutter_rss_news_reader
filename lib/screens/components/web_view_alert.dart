import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewAlert extends StatefulWidget {
  const WebViewAlert({super.key, required this.url});

  final String url;

  @override
  // ignore: library_private_types_in_public_api
  _WebViewAlertState createState() => _WebViewAlertState();
}

class _WebViewAlertState extends State<WebViewAlert> {
  late InAppWebViewController webViewController;

  late PullToRefreshController pullToRefreshController;

  double progress = 0;

  ///
  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(onRefresh: () async => webViewController.reload());
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                onWebViewCreated: (controller) => webViewController = controller,
                pullToRefreshController: pullToRefreshController,
                onLoadStart: (controller, url) => pullToRefreshController.beginRefreshing(),
                onLoadStop: (controller, url) async => pullToRefreshController.endRefreshing(),
                onProgressChanged: (controller, progressValue) => setState(() => progress = progressValue / 100),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

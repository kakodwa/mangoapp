import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VisaPaymentWebView extends StatefulWidget {
  final String checkoutUrl; // Simply pass the URL returned from backend
  final VoidCallback onSuccess;

  const VisaPaymentWebView({
    super.key,
    required this.checkoutUrl,
    required this.onSuccess,
  });

  @override
  State<VisaPaymentWebView> createState() => _VisaPaymentWebViewState();
}

class _VisaPaymentWebViewState extends State<VisaPaymentWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Optional: Handle loading progress bar updates here
          },
          onPageStarted: (String url) {
            debugPrint("🏁 WebView started loading page: $url");
          },
          onPageFinished: (String url) {
            debugPrint("🏁 WebView finished loading page: $url");
          },
          onNavigationRequest: (NavigationRequest request) {
            final String operationalUrl = request.url.toLowerCase();
            
            // 🚨 Console Print: View the exact redirection string live during runtime tests
            debugPrint("🔍 WEBVIEW CURRENTLY NAVIGATING TO: ${request.url}");

            // 🎯 INTERCEPT TRIGGER: Highly resilient keywords lookups guard against 
            // structural path deviations, missing '/api/' string sequences, or trailing slash issues.
            if (operationalUrl.contains('payments/payment/return/') || operationalUrl.contains('status=completed')) {
              debugPrint("🎯 Success redirection captured! Closing WebView frame natively.");
              
              // 1. Force close WebView screen native stack container immediately
              Navigator.of(context).pop(); 
              
              // 2. Trigger your background polling and processing spinner dialogs
              widget.onSuccess(); 
              
              // 3. Stop WebView from attempting to parse or paint the HTML page markup code on screen
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl)); // Direct secure loading
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Secure Card Checkout"),
        elevation: 0,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
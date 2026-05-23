import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VisaPaymentWebView extends StatefulWidget {

  final Map<String, dynamic> paymentData;

  const VisaPaymentWebView({
    super.key,
    required this.paymentData,
  });

  @override
  State<VisaPaymentWebView> createState() =>
      _VisaPaymentWebViewState();
}

class _VisaPaymentWebViewState
    extends State<VisaPaymentWebView> {

  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    final data = widget.paymentData;

    final html = '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<script src="https://in.paychangu.com/js/popup.js"></script>

<style>
body{
  font-family: Arial;
  padding:20px;
}

button{
  width:100%;
  height:55px;
  border:none;
  border-radius:12px;
  background:#0A84FF;
  color:white;
  font-size:18px;
  font-weight:bold;
}
</style>

</head>

<body>

<h2>Visa Card Payment</h2>

<p>Your order is MWK ${data['amount']}</p>

<button type="button" onclick="makePayment()">
Pay Now
</button>

<script>

function makePayment(){

PaychanguCheckout({

"public_key": "${data['public_key']}",

"tx_ref": "${data['tx_ref']}",

"amount": ${data['amount']},

"currency": "MWK",

"callback_url": "${data['callback_url']}",

"return_url": "${data['return_url']}",

"customer":{

"email": "${data['email']}",

"first_name":"${data['first_name']}",

"last_name":"${data['last_name']}"

},

"customization": {

"title": "${data['title']}",

"description": "${data['description']}"

},

"meta": {

"payment_reference": "${data['tx_ref']}"

}

});

}

</script>

</body>
</html>
''';

    controller =
        WebViewController()
          ..setJavaScriptMode(
            JavaScriptMode.unrestricted,
          )
          ..loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Visa Payment"),
      ),

      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
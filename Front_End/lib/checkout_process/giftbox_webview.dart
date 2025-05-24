import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GiftBoxWebView extends StatefulWidget {
  @override
  _GiftBoxWebViewState createState() => _GiftBoxWebViewState();
}

class _GiftBoxWebViewState extends State<GiftBoxWebView> {
  late InAppWebViewController _webViewController;

  Future<void> saveBoxSelection() async {
    try {
      final jsResult = await _webViewController.evaluateJavascript(
        source: 'getSelectedBoxData()',
      );

      String cleanedResult = jsResult.toString();
      if (cleanedResult.startsWith('"') && cleanedResult.endsWith('"')) {
        cleanedResult = cleanedResult
            .substring(1, cleanedResult.length - 1)
            .replaceAll(r'\"', '"');
      }

      final data = jsonDecode(cleanedResult);
      print("✅ بيانات المستخدم: $data");

      final response = await http.post(
        Uri.parse("http://192.168.88.100:5000/api/box/saveBoxChoice"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": "noor123", ...data}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("✅ تم الحفظ في MongoDB!")));
      } else {
        print("❌ خطأ: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('عرض صندوق الهدية ثلاثي الأبعاد'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            tooltip: "احفظ اختياراتي",
            onPressed: saveBoxSelection,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri("https://giftboxes3d.vercel.app/"),
              ),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(javaScriptEnabled: true),
                android: AndroidInAppWebViewOptions(useHybridComposition: true),
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                return ServerTrustAuthResponse(
                  action: ServerTrustAuthResponseAction.PROCEED,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: saveBoxSelection,
                icon: Icon(Icons.save),
                label: Text("احفظ اختياراتي"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

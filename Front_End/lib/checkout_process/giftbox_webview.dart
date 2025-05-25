import 'package:cadeau_project/chosing_card_images/choosing_Card_for_Gift.dart';
import 'package:cadeau_project/custom/theme.dart';
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
      print("✅User's Data: $data");

      final response = await http.post(
        Uri.parse("http://192.168.88.100:5000/api/box/saveBoxChoice"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": "noor123", ...data}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context);
        // ).showSnackBar(SnackBar(content: Text("✅ Saved Successfully!")));
        // ✅ NEW: Navigate to CardImage page after saving
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChoosingCardForGift()),
        );
      } else {
        print("❌ Wrong: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // Set background to white
        foregroundColor: Colors.black, // Set text and icons to black
        title: Text(
          '3D Gift Box Viewer',
          style: TextStyle(
            color: Colors.black,
            fontSize: FlutterFlowTheme.of(context)?.titleMedium?.fontSize ?? 20,
          ),
        ),

        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.save,
              color: Colors.black,
            ), // Icon color black
            tooltip: "Save",
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
                icon: const Icon(
                  Icons.save,
                  color: Colors.white,
                ), // ensure icon is white too
                label: Text(
                  "Save and Continue",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize:
                        FlutterFlowTheme.of(context)?.titleMedium?.fontSize ??
                        16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

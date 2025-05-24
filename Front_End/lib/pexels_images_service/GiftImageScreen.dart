import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CardGeneratorPage extends StatefulWidget {
  @override
  _CardGeneratorPageState createState() => _CardGeneratorPageState();
}

class _CardGeneratorPageState extends State<CardGeneratorPage> {
  String userMessage = '';
  String userName = '';
  String? imageUrl;

  final String apiKey =
      'qoAWVmBHLI0loV2Zd1s6ckjnTSdgIwccVfJtKZAJQ1xolrBOaEcBfO5V';

  Future<void> fetchCardImage() async {
    final response = await http.get(
      Uri.parse(
        'https://api.pexels.com/v1/search?query=greeting card&per_page=20',
      ),
      headers: {'Authorization': apiKey},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List photos = data['photos'];
      final randomIndex = Random().nextInt(photos.length);
      setState(() {
        imageUrl = photos[randomIndex]['src']['large'];
      });
    } else {
      print('Failed to load image');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCardImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("بطاقتك")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (imageUrl != null)
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(imageUrl!),
                  if (userMessage.isNotEmpty || userName.isNotEmpty)
                    Positioned(
                      bottom: 20,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        color: Colors.black.withOpacity(0.5),
                        child: Text(
                          '$userMessage\nمن: $userName',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(labelText: "رسالتك"),
              onChanged: (val) => setState(() => userMessage = val),
            ),
            TextField(
              decoration: InputDecoration(labelText: "اسمك"),
              onChanged: (val) => setState(() => userName = val),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchCardImage,
              child: Text("بطاقة جديدة 🎨"),
            ),
          ],
        ),
      ),
    );
  }
}

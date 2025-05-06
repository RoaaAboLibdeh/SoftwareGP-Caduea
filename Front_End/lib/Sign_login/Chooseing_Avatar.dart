import 'package:cadeau_project/userHomePage/userHomePage.dart';
import 'package:flutter/material.dart';
import 'package:avatar_plus/avatar_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '/custom/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Chooseing_Avatar extends StatefulWidget {
  final String userId;

  const Chooseing_Avatar({super.key, required this.userId});

  @override
  State<Chooseing_Avatar> createState() => _Chooseing_AvatarState();
}

class _Chooseing_AvatarState extends State<Chooseing_Avatar> {
  String? selectedAvatar;
  final List<String> avatars = [
    'ak',
    '3311bb6338d7888219',
    '4',
    'jonny',
    'vv',
    'lm',
    '895llkb6',
    'pplo8851',
    'pplo8c5',
    'pplo8r5',
    'pplo8r53',
    'pplo8r575',
    'p44fl8r5',
    'ppl887568r5',
    'ederfotfr',
    'vcfrtg5o654m',
    'qw3w244otr6tg',
    'bgtiyp56',
    'mk88uh2go11',
    '5g5t8y96fo3d',
    'roa',
    'banana1',
  ];

  Future<void> _updateUserAvatar() async {
    if (selectedAvatar == null) return;

    try {
      final response = await http.put(
        Uri.parse('http://192.168.88.100:5000/api/users/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'avatar': selectedAvatar}),
      );

      if (response.statusCode == 200) {
        print('Avatar updated successfully');
        // Navigate to userHomePage after successful update
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => userHomePage(
                    userId: widget.userId,
                  ), // Replace with your actual home page widget
            ),
          );
        }
      } else {
        print('Failed to update avatar: ${response.body}');
      }
    } catch (e) {
      print('Error updating avatar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double boxSize = MediaQuery.of(context).size.width - 20;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF998BCF),
        automaticallyImplyLeading: false,
        title: Text(
          'Cadeau',
          style: GoogleFonts.dancingScript(
            color: Colors.white,
            fontSize: 33,
            letterSpacing: 0.0,
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(
                blurRadius: 2,
                color: Colors.black.withOpacity(0.1),
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        elevation: 2,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            "Your Shopping Sidekick Awaits!",
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontSize: 16,
              fontFamily: 'Outfit',
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 134, 61, 179),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Choose a fun avatar to join you on your gift-finding journey",
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontSize: 14,
              fontFamily: 'Outfit',
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                padding: const EdgeInsets.all(8),
                children:
                    avatars.map((avatarName) {
                      bool isSelected = selectedAvatar == avatarName;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedAvatar = avatarName;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  isSelected
                                      ? Color(0xFF998BCF)
                                      : Colors.transparent,
                              width: 4,
                            ),
                          ),
                          child: AvatarPlus(
                            avatarName,
                            height: double.infinity,
                            width: double.infinity,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed:
                selectedAvatar != null
                    ? () async {
                      await _updateUserAvatar();
                    }
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF998BCF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: Text(
              'Choose',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

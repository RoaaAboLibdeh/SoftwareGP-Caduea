import 'package:flutter/material.dart';

class OwnerThings extends StatelessWidget {
  const OwnerThings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Owner Dashboard')),
      body: Center(child: Text('Welcome, Owner!')),
    );
  }
}

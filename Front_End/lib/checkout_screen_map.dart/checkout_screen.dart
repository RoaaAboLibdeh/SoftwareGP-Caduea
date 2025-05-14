import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  LocationData? _currentLocation;
  String _address = '';
  bool _isLoading = true;
  final String _geoapifyApiKey = '0809d2de7b584f37951e1ab0c9024317';

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    fetchUserLocation();
  }

  Future<void> fetchUserLocation() async {
    try {
      final location = Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      final userLocation = await location.getLocation();

      final url =
          'https://api.geoapify.com/v1/geocode/reverse?lat=${userLocation.latitude}&lon=${userLocation.longitude}&apiKey=$_geoapifyApiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['features'][0]['properties']['formatted'];

        if (!mounted) return;

        setState(() {
          _currentLocation = userLocation;
          _address = address;
          _isLoading = false;
        });
      } else {
        setState(() {
          _address = 'فشل في جلب العنوان من الخادم';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _address = 'حدث خطأ: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('موقع التوصيل'),
        backgroundColor: Colors.deepPurple,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _currentLocation == null
              ? const Center(child: Text('لم يتم تحديد الموقع'))
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      '✔ عنوان المستخدم: $_address',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(
                          _currentLocation!.latitude!,
                          _currentLocation!.longitude!,
                        ),
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                _currentLocation!.latitude!,
                                _currentLocation!.longitude!,
                              ),
                              width: 60,
                              height: 60,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}

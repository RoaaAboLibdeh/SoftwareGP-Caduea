import 'package:cadeau_project/custom/theme.dart';
import 'package:cadeau_project/home_page_payment.dart';
import 'package:cadeau_project/models/userCart_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CheckoutScreen extends StatefulWidget {
  final String userId;
  final List<CartItem> cartItems;
  final double subtotal;
  final double shipping;
  final double total;
  final Map<String, dynamic> giftBoxData;
  final Map<String, dynamic> giftCardData;
  final String paymentMethod;

  const CheckoutScreen({
    Key? key,
    required this.userId,
    required this.cartItems,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.giftBoxData,
    required this.giftCardData,
    required this.paymentMethod,
  }) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  LocationData? _currentLocation;
  String _address = '';
  bool _isLoading = true;
  final String _geoapifyApiKey = '0809d2de7b584f37951e1ab0c9024317';

  final MapController _mapController = MapController();

  // Add a method to create the order:
  Future<void> _createOrder() async {
    try {
      final orderData = {
        'userId': widget.userId,
        'items':
            widget.cartItems
                .map(
                  (item) => {
                    'productId': item.product.id,
                    'name': item.product.name,
                    'price': item.product.price,
                    'quantity': item.quantity,
                    'imageUrl':
                        item.product.imageUrls.isNotEmpty
                            ? item.product.imageUrls[0]
                            : '',
                  },
                )
                .toList(),
        'giftBox': widget.giftBoxData,
        'giftCard': widget.giftCardData,
        'deliveryDetails': {
          'address': _address,
          'latitude': _currentLocation?.latitude,
          'longitude': _currentLocation?.longitude,
        },
        'paymentMethod': widget.paymentMethod,
        'totalAmount': widget.total,
        'status': 'pending',
      };

      final response = await http.post(
        Uri.parse('http://192.168.88.100:5000/api/orders/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );

      if (response.statusCode == 201) {
        // Order created successfully
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePagePayment()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create order')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

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
          _address = 'Failed to fetch address from server';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _address = 'An error occurred.: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(
          'Delivery Location',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
            fontFamily: 'Outfit',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: Color.fromARGB(255, 79, 6, 6),
          ),
        ),
        backgroundColor: Color(0xFFF7F7F7),
        elevation: 0,
      ),

      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _currentLocation == null
              ? const Center(child: Text('Location not specified'))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_pin,
                              color: Colors.deepPurple,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _address,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
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
                      ),
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              await _createOrder();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePagePayment()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 79, 6, 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Proceed to Payment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

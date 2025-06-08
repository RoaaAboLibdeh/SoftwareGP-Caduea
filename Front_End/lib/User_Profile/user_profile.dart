import 'package:cadeau_project/User_Profile/users_favorites.dart';
import 'package:cadeau_project/User_Profile/users_orders.dart';
import 'package:cadeau_project/User_Profile/users_reviews.dart';
import 'package:cadeau_project/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/custom/theme.dart';
import '/userHomePage/userHomePage.dart';
import '/userCart/userCart.dart';
import '/Categories/ListCategories.dart';

class Profile16SimpleProfileWidget extends StatefulWidget {
  final String userId;

  const Profile16SimpleProfileWidget({Key? key, required this.userId})
    : super(key: key);

  @override
  _Profile16SimpleProfileWidgetState createState() =>
      _Profile16SimpleProfileWidgetState();
}

class _Profile16SimpleProfileWidgetState
    extends State<Profile16SimpleProfileWidget> {
  Map<String, dynamic>? userData;
  Map<String, dynamic>? pointsData;
  bool isLoading = true;
  bool isPointsLoading = true;
  bool isDarkMode = false;
  String selectedCurrency = 'USD';
  final List<String> currencies = ['USD', 'EUR', 'GBP', 'JPY', 'AED'];

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
    _fetchUserData();
    _fetchPointsData();
  }

  Future<void> _loadUserPreferences() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCurrency = prefs.getString('currency') ?? 'USD';
    });
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.88.100:5000/api/users/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load user data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching user data: $e');
    }
  }

  Future<void> _fetchPointsData() async {
    try {
      final url = Uri.parse(
        'http://192.168.88.100:5000/api/points/${widget.userId}',
      );
      print('Fetching points data from: $url'); // Debug log

      final response = await http.get(url);
      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          setState(() {
            pointsData = data;
            isPointsLoading = false;
          });
        } else {
          throw Exception('Invalid points data format: ${response.body}');
        }
      } else {
        throw Exception(
          'Failed to load points data. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in _fetchPointsData: $e'); // Detailed error log
      setState(() {
        isPointsLoading = false;
      });

      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load points data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _changeCurrency(String newCurrency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', newCurrency);
    setState(() {
      selectedCurrency = newCurrency;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    await themeProvider.toggleTheme(value);
  }

  Widget _buildPointsCard() {
    // Convert all integer values to double explicitly
    final availablePoints = (pointsData?['availablePoints'] ?? 0).toDouble();
    final lifetimeEarned =
        (pointsData?['lifetimePointsEarned'] ?? 0).toDouble();
    final lifetimeUsed = (pointsData?['lifetimePointsUsed'] ?? 0).toDouble();

    // Calculate progress safely (avoid division by zero)
    final progress =
        lifetimeEarned > 0 ? availablePoints / lifetimeEarned : 0.0;
    final nextTierPoints = _calculateNextTierPoints(availablePoints.toInt());

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'REWARD POINTS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Icon(Icons.star, color: Colors.amber),
              ],
            ),
            SizedBox(height: 16),
            Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                SizedBox(height: 8),
                Text(
                  nextTierPoints > 0
                      ? 'Earn ${nextTierPoints - availablePoints} more points for next reward tier'
                      : 'You\'ve reached the highest reward tier!',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Points',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      '$availablePoints',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 164, 145, 240),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed:
                      availablePoints >= 100
                          ? () => _showRedeemDialog(context)
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 164, 145, 240),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text('Redeem', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lifetime Earned',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '$lifetimeEarned',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lifetime Redeemed',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '$lifetimeUsed',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _calculateNextTierPoints(int currentPoints) {
    if (currentPoints < 100) return 100;
    if (currentPoints < 250) return 250;
    if (currentPoints < 500) return 500;
    if (currentPoints < 1000) return 1000;
    return 0;
  }

  Future<void> _showRedeemDialog(BuildContext context) async {
    final availablePoints = pointsData?['availablePoints'] ?? 0;
    int pointsToRedeem = 100;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Redeem Reward Points'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Available Points: $availablePoints'),
                  SizedBox(height: 16),
                  Text('How many points would you like to redeem?'),
                  SizedBox(height: 16),
                  Slider(
                    value: pointsToRedeem.toDouble(),
                    min: 100,
                    max: availablePoints.toDouble(),
                    divisions: (availablePoints ~/ 100).clamp(1, 10),
                    label: '$pointsToRedeem points',
                    onChanged: (value) {
                      setState(() {
                        pointsToRedeem = value.round();
                      });
                    },
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${pointsToRedeem} points = \$${(pointsToRedeem / 100).toStringAsFixed(2)} discount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final response = await http.post(
                        Uri.parse(
                          'http://192.168.88.100:5000/api/points/redeem',
                        ),
                        headers: {'Content-Type': 'application/json'},
                        body: json.encode({
                          'userId': widget.userId,
                          'pointsToRedeem': pointsToRedeem,
                        }),
                      );

                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Successfully redeemed $pointsToRedeem points!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        await _fetchPointsData();
                        Navigator.pop(context);
                      } else {
                        throw Exception('Failed to redeem points');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error redeeming points: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 164, 145, 240),
                  ),
                  child: Text('Redeem'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Color.fromARGB(255, 164, 145, 240)),
      title: Text(title),
      trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Theme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Profile'),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.star, color: Colors.amber),
              onPressed: () {},
            ),
            IconButton(icon: Icon(Icons.edit), onPressed: () {}),
          ],
        ),
        body:
            isLoading || isPointsLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                userData?['avatarUrl'] ??
                                    'https://via.placeholder.com/150',
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              userData?['name'] ?? 'User',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              userData?['email'] ?? 'email@example.com',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      _buildPointsCard(),
                      SizedBox(height: 24),
                      Text(
                        'ACCOUNT SETTINGS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildSettingsCard(
                        children: [
                          _buildSettingsItem(
                            icon: Icons.person_outline,
                            title: 'Personal Information',
                            onTap: () {},
                          ),
                          Divider(height: 1),
                          _buildSettingsItem(
                            icon: Icons.location_on_outlined,
                            title: 'Shipping Addresses',
                            onTap: () {},
                          ),
                          Divider(height: 1),
                          _buildSettingsItem(
                            icon: Icons.credit_card_outlined,
                            title: 'Payment Methods',
                            onTap: () {},
                          ),
                          Divider(height: 1),
                          _buildSettingsItem(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            onTap: () {},
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text(
                        'APP SETTINGS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildSettingsCard(
                        children: [
                          _buildSettingsItem(
                            icon: Icons.dark_mode_outlined,
                            title: 'Dark Mode',
                            trailing: Switch(
                              value: isDarkMode,
                              onChanged: _toggleDarkMode,
                              activeColor: Color.fromARGB(255, 164, 145, 240),
                            ),
                          ),
                          Divider(height: 1),
                          _buildSettingsItem(
                            icon: Icons.currency_exchange,
                            title: 'Currency',
                            trailing: DropdownButton<String>(
                              value: selectedCurrency,
                              underline: Container(),
                              items:
                                  currencies.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  _changeCurrency(newValue);
                                }
                              },
                            ),
                          ),
                          Divider(height: 1),
                          _buildSettingsItem(
                            icon: Icons.language_outlined,
                            title: 'Language',
                            trailing: Text('English'),
                            onTap: () {},
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text(
                        'ACTIONS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildSettingsCard(
                        children: [
                          _buildSettingsItem(
                            icon: Icons.shopping_bag_outlined,
                            title: 'My Orders',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          UsersOrders(userId: widget.userId),
                                ),
                              );
                            },
                          ),
                          Divider(height: 1),
                          _buildSettingsItem(
                            icon: Icons.favorite_outline,
                            title: 'Wishlist',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          UsersFavorite(userId: widget.userId),
                                ),
                              );
                            },
                          ),
                          Divider(height: 1),
                          _buildSettingsItem(
                            icon: Icons.star_outline,
                            title: 'Reviews',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          UsersReviews(userId: widget.userId),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text(
                        'SUPPORT',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildSettingsCard(
                        children: [
                          _buildSettingsItem(
                            icon: Icons.help_outline,
                            title: 'Help Center',
                            onTap: () {},
                          ),
                          Divider(height: 1),
                          _buildSettingsItem(
                            icon: Icons.headset_mic_outlined,
                            title: 'Contact Us',
                            onTap: () {},
                          ),
                          Divider(height: 1),
                          _buildSettingsItem(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Privacy Policy',
                            onTap: () {},
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 164, 145, 240),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text('Log Out'),
                        ),
                      ),
                    ],
                  ),
                ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 3,
          onTap: (index) {
            if (index == 3) return;

            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => userHomePage(userId: widget.userId),
                ),
              );
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoriesPage(userId: widget.userId),
                ),
              );
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CartWidget(userId: widget.userId),
                ),
              );
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Color.fromARGB(255, 164, 145, 240),
          unselectedItemColor: Colors.grey[600],
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(
                Icons.home,
                color: Color.fromARGB(255, 164, 145, 240),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category_outlined),
              activeIcon: Icon(
                Icons.category,
                color: Color.fromARGB(255, 164, 145, 240),
              ),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(
                Icons.shopping_cart,
                color: Color.fromARGB(255, 164, 145, 240),
              ),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(
                Icons.person,
                color: Color.fromARGB(255, 164, 145, 240),
              ),
              label: 'Me',
            ),
          ],
        ),
      ),
    );
  }
}

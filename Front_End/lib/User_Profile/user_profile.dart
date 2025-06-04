import 'package:cadeau_project/User_Profile/users_favorites.dart';
import 'package:cadeau_project/User_Profile/users_orders.dart';
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
// import '/order_history/order_history.dart'; // You'll need to create this

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
  bool isLoading = true;
  bool isDarkMode = false;
  String selectedCurrency = 'USD';
  final List<String> currencies = ['USD', 'EUR', 'GBP', 'JPY', 'AED'];

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
    _fetchUserData();
  }

  Future<void> _loadUserPreferences() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCurrency = prefs.getString('currency') ?? 'USD';
    });
    // No need to set isDarkMode here as ThemeProvider handles it
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

  Future<void> _changeCurrency(String newCurrency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', newCurrency);
    setState(() {
      selectedCurrency = newCurrency;
    });
    // You might want to add a provider or other state management to update the currency app-wide
  }

  Future<void> _toggleDarkMode(bool value) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    await themeProvider.toggleTheme(value);
    // Remove the setState call as ThemeProvider will notify listeners
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
              icon: Icon(Icons.edit),
              onPressed: () {
                // Navigate to edit profile page
              },
            ),
          ],
        ),
        body:
            isLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header
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
                      SizedBox(height: 32),

                      // Account Settings Section
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
                            onTap: () {
                              // Navigate to personal info page
                            },
                          ),
                          Divider(height: 1),
                          _buildSettingsItem(
                            icon: Icons.location_on_outlined,
                            title: 'Shipping Addresses',
                            onTap: () {
                              // Navigate to addresses page
                            },
                          ),
                          Divider(height: 1),
                          _buildSettingsItem(
                            icon: Icons.credit_card_outlined,
                            title: 'Payment Methods',
                            onTap: () {
                              // Navigate to payment methods page
                            },
                          ),
                          Divider(height: 1),
                          _buildSettingsItem(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            onTap: () {
                              // Navigate to notifications settings
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 24),

                      // App Settings Section
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
                            onTap: () {
                              // Show language selection dialog
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Actions Section
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
                              // Navigate to reviews
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Support Section
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
                            onTap: () {
                              // Navigate to help center
                            },
                          ),
                          Divider(height: 1),
                          _buildSettingsItem(
                            icon: Icons.headset_mic_outlined,
                            title: 'Contact Us',
                            onTap: () {
                              // Navigate to contact us
                            },
                          ),
                          Divider(height: 1),
                          _buildSettingsItem(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Privacy Policy',
                            onTap: () {
                              // Show privacy policy
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Logout Button
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // Implement logout functionality
                          },
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
                            //  iconColor: context Text('Log Out'),
                          ),
                          child: null,
                        ),
                      ),
                    ],
                  ),
                ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 3, // 'Me' tab is selected
          onTap: (index) {
            if (index == 3) return; // Already on profile page

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
}

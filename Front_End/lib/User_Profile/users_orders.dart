import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class UsersOrders extends StatefulWidget {
  final String userId;

  const UsersOrders({Key? key, required this.userId}) : super(key: key);

  @override
  _UsersOrdersState createState() => _UsersOrdersState();
}

class _UsersOrdersState extends State<UsersOrders> {
  List<dynamic> orders = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUserOrders();
  }

  Future<void> _fetchUserOrders() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.88.100:5000/api/orders/user/${widget.userId}',
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          orders = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load orders. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching orders: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('My Orders', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (errorMessage.isNotEmpty) {
      return Center(
        child: Text(errorMessage, style: TextStyle(color: Colors.red)),
      );
    }
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No orders yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Start shopping to see your orders here',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (context, index) => SizedBox(height: 16),
      itemBuilder: (context, index) => _buildOrderCard(orders[index]),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final createdAt = DateTime.parse(order['createdAt']).toLocal();
    final formattedDate = DateFormat(
      'MMM dd, yyyy - hh:mm a',
    ).format(createdAt);
    final totalAmount = order['totalAmount'].toStringAsFixed(2);
    final status = order['status'].toString().toUpperCase();
    final orderId = order['_id'].substring(0, 8).toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order header
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORDER #$orderId',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, thickness: 1, color: Colors.grey[100]),

          // Order items preview
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                ...order['items']
                    .take(2)
                    .map<Widget>(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: _buildOrderItem(item),
                      ),
                    ),
                if (order['items'].length > 2) ...[
                  Text(
                    '+ ${order['items'].length - 2} more items',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  SizedBox(height: 8),
                ],
              ],
            ),
          ),

          // Order summary
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                if (order['giftBox'] != null || order['giftCard'] != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.card_giftcard,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Gift options included',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$$totalAmount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // View details button
          TextButton(
            onPressed: () => _showOrderDetails(context, order),
            style: TextButton.styleFrom(
              minimumSize: Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ),
            child: Text(
              'VIEW ORDER DETAILS',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            item['imageUrl'],
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['name'], style: TextStyle(fontWeight: FontWeight.w500)),
              SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '\$${item['price'].toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '× ${item['quantity']}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Spacer(),
                  Text(
                    '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'shipped':
        return Colors.blue;
      case 'delivery':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    final createdAt = DateTime.parse(order['createdAt']).toLocal();
    final formattedDate = DateFormat(
      'MMM dd, yyyy - hh:mm a',
    ).format(createdAt);
    final totalAmount = order['totalAmount'].toStringAsFixed(2);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order summary
                        _buildDetailSection(
                          title: 'Order Summary',
                          children: [
                            _buildDetailRow(
                              'Order ID',
                              order['_id'].substring(0, 8).toUpperCase(),
                            ),
                            _buildDetailRow('Date', formattedDate),
                            _buildDetailRow(
                              'Status',
                              order['status'].toString().toUpperCase(),
                            ),
                            _buildDetailRow(
                              'Payment Method',
                              order['paymentMethod'],
                            ),
                          ],
                        ),

                        // Items
                        _buildDetailSection(
                          title: 'Items (${order['items'].length})',
                          children: [
                            ...order['items'].map<Widget>(
                              (item) => Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: _buildOrderItem(item),
                              ),
                            ),
                          ],
                        ),

                        // Gift options
                        if (order['giftBox'] != null ||
                            order['giftCard'] != null)
                          _buildDetailSection(
                            title: 'Gift Options',
                            children: [
                              if (order['giftBox'] != null) ...[
                                _buildDetailRow(
                                  'Gift Box',
                                  order['giftBox']['box'],
                                ),
                                _buildDetailRow(
                                  'Box Color',
                                  order['giftBox']['boxColor'],
                                ),
                                _buildDetailRow(
                                  'Lid Color',
                                  order['giftBox']['lidColor'],
                                ),
                                _buildDetailRow(
                                  'Ribbon Color',
                                  order['giftBox']['ribbonColor'],
                                ),
                                SizedBox(height: 8),
                              ],
                              if (order['giftCard'] != null) ...[
                                _buildDetailRow(
                                  'From',
                                  order['giftCard']['senderName'],
                                ),
                                _buildDetailRow(
                                  'To',
                                  order['giftCard']['recipientName'],
                                ),
                                _buildDetailRow(
                                  'Message',
                                  order['giftCard']['message'],
                                ),
                              ],
                            ],
                          ),

                        // Delivery
                        _buildDetailSection(
                          title: 'Delivery',
                          children: [
                            _buildDetailRow(
                              'Address',
                              order['deliveryDetails']['address'],
                            ),
                            SizedBox(height: 8),
                            Container(
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey[100],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.map_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Payment summary
                        _buildDetailSection(
                          title: 'Payment Summary',
                          children: [
                            _buildDetailRow(
                              'Subtotal',
                              '\$${(order['totalAmount'] * 0.9).toStringAsFixed(2)}',
                            ),
                            _buildDetailRow(
                              'Shipping',
                              '\$${(order['totalAmount'] * 0.1).toStringAsFixed(2)}',
                            ),
                            Divider(),
                            _buildDetailRow(
                              'Total',
                              '\$$totalAmount',
                              valueStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: valueStyle ?? TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class Review {
  final String id;
  final String userName;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final String nameInitial; // Add this field

  Review({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.nameInitial, // Include in constructor
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final userName = json['userName'] ?? 'Anonymous';
    return Review(
      id: json['_id'] ?? '',
      userName: userName,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] ?? '',
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      nameInitial:
          userName.isNotEmpty
              ? userName[0].toUpperCase()
              : 'A', // Extract first letter
    );
  }
}

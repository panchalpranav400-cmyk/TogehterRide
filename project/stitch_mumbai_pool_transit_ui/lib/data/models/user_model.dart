class UserModel {
  final String id;
  final String name;
  final String role; // 'passenger' | 'driver'
  final String phone;
  final String rating;
  final bool isVerified;
  final String vehicleNumber;
  final String vehicleModel;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
    required this.rating,
    required this.isVerified,
    this.vehicleNumber = '',
    this.vehicleModel = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String,
      rating: json['rating'] as String,
      isVerified: json['is_verified'] as bool? ?? false,
      vehicleNumber: json['vehicle_number'] as String? ?? '',
      vehicleModel: json['vehicle_model'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'phone': phone,
      'rating': rating,
      'is_verified': isVerified,
      'vehicle_number': vehicleNumber,
      'vehicle_model': vehicleModel,
    };
  }
}

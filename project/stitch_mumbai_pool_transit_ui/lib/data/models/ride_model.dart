class RideModel {
  final String rideId;
  final String driverName;
  final String vehicleInfo;
  final String origin;
  final String destination;
  final double fare;
  final String eta;
  final int seatsAvailable;
  final String status; // 'matching', 'requested', 'active', 'completed'

  RideModel({
    required this.rideId,
    required this.driverName,
    required this.vehicleInfo,
    required this.origin,
    required this.destination,
    required this.fare,
    required this.eta,
    required this.seatsAvailable,
    required this.status,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      rideId: json['ride_id'] as String,
      driverName: json['driver_name'] as String,
      vehicleInfo: json['vehicle_info'] as String,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      fare: (json['fare'] as num).toDouble(),
      eta: json['eta'] as String,
      seatsAvailable: json['seats_available'] as int,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ride_id': rideId,
      'driver_name': driverName,
      'vehicle_info': vehicleInfo,
      'origin': origin,
      'destination': destination,
      'fare': fare,
      'eta': eta,
      'seats_available': seatsAvailable,
      'status': status,
    };
  }
}

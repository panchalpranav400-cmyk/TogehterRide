import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ride_model.dart';

class RideRepository {
  final _supabase = Supabase.instance.client;

  Future<List<RideModel>> getAvailablePools(String origin, String destination) async {
    try {
      var query = _supabase.from('rides').select();
      
      if (origin.isNotEmpty) {
        query = query.ilike('origin', '%$origin%');
      }
      if (destination.isNotEmpty) {
        query = query.ilike('destination', '%$destination%');
      }

      final response = await query;
      
      return (response as List<dynamic>)
          .map((data) => RideModel.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Supabase query failed: $e. Falling back to mock data.');
      return _getMockPools(origin, destination);
    }
  }

  List<RideModel> _getMockPools(String origin, String destination) {
    return [
      RideModel(
        rideId: 'SH-MUM-802',
        driverName: 'Rajesh Sharma',
        vehicleInfo: 'Maruti Suzuki Ertiga (MH 02 CZ 4482)',
        origin: origin.isNotEmpty ? origin : 'Andheri East, WEH Metro Station',
        destination: destination.isNotEmpty ? destination : 'BKC Trident - G Block',
        fare: 120.0,
        eta: '12 mins',
        seatsAvailable: 2,
        status: 'matching',
      ),
      RideModel(
        rideId: 'SH-MUM-419',
        driverName: 'Priya Desai',
        vehicleInfo: 'Hyundai Aura (MH 01 BG 9102)',
        origin: origin.isNotEmpty ? origin : 'Bandra Station West',
        destination: destination.isNotEmpty ? destination : 'Lower Parel West',
        fare: 95.0,
        eta: '7 mins',
        seatsAvailable: 1,
        status: 'matching',
      ),
    ];
  }
}

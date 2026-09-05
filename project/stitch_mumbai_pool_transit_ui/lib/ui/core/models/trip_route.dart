import 'package:latlong2/latlong.dart';

/// A passenger's searched pickup/dropoff, carried from [PassengerHomeView]
/// through the booking flow so downstream screens can render the real
/// geocoded route instead of fixed demo labels.
class TripRoute {
  final String originLabel;
  final String destinationLabel;
  final LatLng? originCoordinate;
  final LatLng? destinationCoordinate;

  const TripRoute({
    required this.originLabel,
    required this.destinationLabel,
    this.originCoordinate,
    this.destinationCoordinate,
  });
}

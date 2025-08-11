class CoordinatesPair {
   double latitude;
   double longitude;
   String? address;

  CoordinatesPair({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  @override
  String toString() {
    return '$latitude,$longitude';
  }
}

int computeDeliveryFeeIqD(double distanceKm) {
  final d = distanceKm;
  if (d <= 3) return 1000;
  if (d <= 5) return 2000;
  if (d <= 8) return 3000;
  if (d <= 12) return 4000;
  if (d <= 15) return 5000;
  // beyond 15km, grow modestly per km
  return 5000 + ((d - 15).ceil()) * 500;
}

const int kServiceFeeIqD = 1000;

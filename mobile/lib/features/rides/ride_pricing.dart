int computeRidePrice({required String role, required double distanceKm}) {
  final d = distanceKm;
  int price = 0;
  if (role == 'taxi') {
    // Base 2000 + increments per brackets
    price = 2000;
    if (d <= 0) return price + 500; // treat zero as 0-2 => +500
    if (d <= 2) return price + 500;
    if (d <= 4) return price + 1000;
    if (d <= 6) return price + 2000;
    if (d <= 8) return price + 3500;
    if (d <= 10) return price + 4500;
    if (d <= 12) return price + 5500;
    if (d <= 15) return price + 7000;
    if (d <= 20) return price + 10000;
    if (d <= 25) return price + 13000;
    if (d <= 30) return price + 15000;
    if (d <= 40) return price + 20000;
    if (d <= 50) return price + 25000; // corrected per user
    return price + 25000 + (((d - 50).ceil()) * 1000); // fallback beyond 50km
  }
  if (role == 'tuk_tuk') {
    // Base 1000 + brackets
    price = 1000;
    if (d <= 2) return price + 500;
    if (d <= 3) return price + 1000;
    if (d <= 4) return price + 1500;
    if (d <= 6) return price + 2000;
    if (d <= 7) return price + 3000;
    if (d <= 10) return price + 5000;
    return price + 5000 + (((d - 10).ceil()) * 500);
  }
  if (role == 'stuta') {
    // No base, pure brackets
    if (d <= 5) return 5000;
    if (d <= 10) return 10000;
    if (d <= 15) return 15000; // corrected per user
    return 15000 + (((d - 15).ceil()) * 1000);
  }
  if (role == 'kia_haml') {
    if (d <= 3) return 5000;
    if (d <= 5) return 10000;
    if (d <= 8) return 15000;
    if (d <= 10) return 20000;
    if (d <= 20) return 25000;
    if (d <= 30) return 30000;
    if (d <= 40) return 40000;
    if (d <= 50) return 50000;
    if (d <= 60) return 60000;
    if (d <= 70) return 70000;
    if (d <= 80) return 80000;
    if (d <= 90) return 90000;
    if (d <= 100) return 100000;
    return 100000 + (((d - 100).ceil()) * 2000);
  }
  return 0;
}

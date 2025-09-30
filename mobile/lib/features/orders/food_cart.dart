class FoodCartItem {
  final Map<String, dynamic> offer;
  int quantity;
  FoodCartItem({required this.offer, required this.quantity});
}

class FoodCart {
  FoodCart._();
  static final FoodCart I = FoodCart._();

  final List<FoodCartItem> _items = [];
  List<FoodCartItem> get items => List.unmodifiable(_items);

  void add(Map<String, dynamic> offer, {int qty = 1}) {
    final id = offer['id']?.toString();
    final existing = _items.where((e) => e.offer['id']?.toString() == id).toList();
    if (existing.isNotEmpty) {
      existing.first.quantity += qty;
    } else {
      _items.add(FoodCartItem(offer: offer, quantity: qty));
    }
  }

  void remove(String offerId) {
    _items.removeWhere((e) => e.offer['id']?.toString() == offerId);
  }

  void updateQty(String offerId, int qty) {
    for (final it in _items) {
      if (it.offer['id']?.toString() == offerId) {
        it.quantity = qty;
        break;
      }
    }
  }

  int get itemsTotal {
    int sum = 0;
    for (final it in _items) {
      final price = (it.offer['price'] as num?)?.toInt() ?? 0;
      sum += price * it.quantity;
    }
    return sum;
  }

  void clear() => _items.clear();
}

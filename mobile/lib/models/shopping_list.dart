/// Modèle de données côté client — reflète uniquement la forme JSON exposée par
/// `api/v1` (aucune règle de gestion ici, cf. CDC §14).
class ShoppingListItem {
  ShoppingListItem({
    required this.id,
    required this.name,
    required this.checked,
    this.quantity,
    this.unit,
    this.rayon,
  });

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) => ShoppingListItem(
        id: json['id'] as int,
        name: json['name'] as String,
        checked: json['checked'] as bool? ?? false,
        quantity: json['quantity'],
        unit: json['unit'] as String?,
        rayon: json['rayon'] as String?,
      );

  final int id;
  final String name;
  final bool checked;
  final dynamic quantity;
  final String? unit;
  final String? rayon;
}

class ShoppingList {
  ShoppingList({required this.id, required this.name, this.icon, this.items = const []});

  factory ShoppingList.fromJson(Map<String, dynamic> json) => ShoppingList(
        id: json['id'] as int,
        name: json['name'] as String,
        icon: json['icon'] as String?,
        items: (json['items'] as List<dynamic>? ?? [])
            .map((item) => ShoppingListItem.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  final int id;
  final String name;
  final String? icon;
  final List<ShoppingListItem> items;
}

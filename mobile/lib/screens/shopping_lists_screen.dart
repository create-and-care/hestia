import 'package:flutter/material.dart';

import '../models/shopping_list.dart';
import '../services/api_client.dart';

/// Premier écran de parité fonctionnelle (Courses, CDC §9.1) — volontairement
/// minimal : liste + coche, sans catalogue produit ni scan code-barres pour
/// l'instant (caméra native à câbler dans un chantier ultérieur, cf. CDC §14).
class ShoppingListsScreen extends StatefulWidget {
  const ShoppingListsScreen({super.key, required this.client});

  final ApiClient client;

  @override
  State<ShoppingListsScreen> createState() => _ShoppingListsScreenState();
}

class _ShoppingListsScreenState extends State<ShoppingListsScreen> {
  List<ShoppingList> _lists = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final json = await widget.client.get('/shopping_lists');
      setState(() {
        _lists = (json as List<dynamic>)
            .map((item) => ShoppingList.fromJson(item as Map<String, dynamic>))
            .toList();
        _error = null;
      });
    } catch (error) {
      setState(() => _error = 'Chargement impossible : $error');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🛒 Courses')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : ListView.builder(
                    itemCount: _lists.length,
                    itemBuilder: (context, index) {
                      final list = _lists[index];
                      return ListTile(
                        leading: Text(list.icon ?? '🛒'),
                        title: Text(list.name),
                        subtitle: Text('${list.items.length} article(s)'),
                      );
                    },
                  ),
      ),
    );
  }
}

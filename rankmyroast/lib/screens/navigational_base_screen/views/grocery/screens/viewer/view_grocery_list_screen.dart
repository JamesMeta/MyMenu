import 'package:flutter/material.dart';
import 'package:rankmyroast/classes/modals/grocery_list.dart';

class ViewGroceryListScreen extends StatefulWidget {
  final GroceryList? extra;

  const ViewGroceryListScreen({super.key, required this.extra});

  @override
  State<ViewGroceryListScreen> createState() => _ViewGroceryListScreenState();
}

class _ViewGroceryListScreenState extends State<ViewGroceryListScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

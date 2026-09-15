import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rankmyroast/classes/mixin/snackbar_service.dart';
import 'package:rankmyroast/classes/modals/grocery.dart';
import 'package:rankmyroast/classes/modals/grocery_list.dart';
import 'package:rankmyroast/services/supabase_helper.dart';

class ViewGroceryListScreen extends StatefulWidget {
  final GroceryList? extra;

  const ViewGroceryListScreen({super.key, required this.extra});

  @override
  State<ViewGroceryListScreen> createState() => _ViewGroceryListScreenState();
}

class _ViewGroceryListScreenState extends State<ViewGroceryListScreen>
    with SnackbarService {
  late final GroceryList? _groceryList;
  late final List<Grocery> _uncheckedItems;
  late final List<Grocery> _checkedItems;
  bool _showCheckedItems = false;
  bool _isEditingTitle = false;

  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    _groceryList = widget.extra;
    _uncheckedItems =
        _groceryList?.groceryList.where((item) => !item.completed).toList() ??
        [];
    _checkedItems =
        _groceryList?.groceryList.where((item) => item.completed).toList() ??
        [];
    _titleController.text = _groceryList?.name ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<GroceryList?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && context.mounted) {
          context.pop(_groceryList);
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_isEditingTitle)
                TextField(
                  controller: _titleController,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(border: InputBorder.none),
                  onChanged: (value) {
                    _groceryList?.name = value;
                  },
                  onSubmitted: (_) {
                    setState(() {
                      _isEditingTitle = false;
                    });
                  },
                )
              else
                GestureDetector(
                  onTap:
                      _groceryList == null
                          ? null
                          : () {
                            _titleController.text = _groceryList.name;
                            _titleController
                                .selection = TextSelection.collapsed(
                              offset: _titleController.text.length,
                            );
                            setState(() {
                              _isEditingTitle = true;
                            });
                          },
                  child: Text(
                    _groceryList?.name ?? 'No Grocery List',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              ListView(
                shrinkWrap: true,
                children: [
                  _groceryList != null
                      ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: _uncheckedItems.length,
                        itemBuilder: (context, index) {
                          final item = _uncheckedItems[index];
                          return _buildListTile(item, _uncheckedItems);
                        },
                      )
                      : Center(child: Text('No grocery list provided.')),

                  if (!_showCheckedItems) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showCheckedItems = true;
                            });
                          },
                          child: Text('Show Checked Items'),
                        ),
                      ],
                    ),
                  ],

                  if (_showCheckedItems) ...[
                    Divider(),

                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _checkedItems.length,
                      itemBuilder: (context, index) {
                        final item = _checkedItems[index];
                        return _buildListTile(item, _checkedItems);
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(Grocery item, List<Grocery> groceryListPointer) {
    return ListTile(
      title: Text(item.item),
      leading: Checkbox(
        value: item.completed,
        onChanged: (value) {
          setState(() {
            item.completed = !item.completed;
          });
          _updateGroceryItemCompletion(item).then((success) {
            if (success == false && mounted) {
              showSnackbar(context, "Failed to update item.");
            }
          });
        },
      ),
      trailing: IconButton(
        onPressed: () {
          setState(() {
            groceryListPointer.remove(item);
          });
          _deleteGroceryItem(item).then((success) {
            if (success == false && mounted) {
              showSnackbar(context, "Failed to delete item.");
            }
          });
        },
        icon: Icon(Icons.delete, color: Colors.grey[600]),
      ),
    );
  }

  Future<bool?> _updateGroceryItemCompletion(Grocery item) async {
    final response = await SupabaseHelper.grocery.updateGrocery(item);
    return response;
  }

  Future<bool?> _deleteGroceryItem(Grocery item) async {
    final response = await SupabaseHelper.grocery.deleteGrocery(item);
    return response;
  }
}

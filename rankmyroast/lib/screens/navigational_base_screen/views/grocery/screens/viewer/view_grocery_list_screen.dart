import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rankmyroast/classes/mixin/snackbar_service.dart';
import 'package:rankmyroast/classes/modals/grocery.dart';
import 'package:rankmyroast/classes/modals/grocery_list.dart';
import 'package:rankmyroast/common_widgets/inline_editable_title.dart';
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

  late final String _title;

  @override
  void initState() {
    _groceryList = widget.extra;
    _uncheckedItems =
        _groceryList?.groceryList.where((item) => !item.completed).toList() ??
        [];
    _checkedItems =
        _groceryList?.groceryList.where((item) => item.completed).toList() ??
        [];
    _title = _groceryList?.name ?? '';
    super.initState();
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
              InlineEditableTitle(
                initialText: _title,
                onSubmitted: (value) => _updateGroceryListName(value),
              ),
              const SizedBox(height: 16),

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

  Future<bool?> _updateGroceryListName(String newName) async {
    if (_groceryList == null) return false;

    final oldName = _groceryList.name;

    setState(() {
      _groceryList.name = newName;
    });

    final response = await SupabaseHelper.grocery.updateGroceryListName(
      _groceryList.id,
      newName,
    );
    if (response == false) {
      setState(() {
        _groceryList.name = oldName;
      });
    }
    return response;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  bool _isEditingTitle = false;

  late final String _title;

  final List<Grocery> _recentlyCompleted = [];

  List<Grocery> get _uncheckedItems =>
      _groceryList?.groceryList
          .where((item) => !item.completed || _recentlyCompleted.contains(item))
          .toList() ??
      [];

  List<Grocery> get _checkedItems =>
      _groceryList?.groceryList
          .where((item) => item.completed && !_recentlyCompleted.contains(item))
          .toList() ??
      [];

  @override
  void initState() {
    _groceryList = widget.extra;
    // Instead of storing separate lists, use getters:

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
        backgroundColor: Colors.green,
        appBar: AppBar(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(100),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InlineEditableTitle(
                  initialText: _title,
                  onSubmitted: (value) => _updateGroceryListName(value),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLinesEdit: 2,
                  maxLinesStatic: 2,
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: ListView(
                    physics: AlwaysScrollableScrollPhysics(),
                    children: [
                      _groceryList != null
                          ? ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _uncheckedItems.length + 1,
                            itemBuilder: (context, index) {
                              if (index == _uncheckedItems.length) {
                                return ListTile(
                                  leading: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: 48,
                                      minHeight: 48,
                                    ),
                                    child: Icon(Icons.add),
                                  ),
                                  title: Text('Add Item'),
                                  onTap: () {
                                    final newItem = Grocery(
                                      id: DateTime.now().millisecondsSinceEpoch,
                                      item: '',
                                      completed: false,
                                      groceryListId: _groceryList.id,
                                    );
                                    setState(() {
                                      _groceryList.groceryList.add(newItem);
                                    });
                                  },
                                );
                              }

                              final item = _uncheckedItems[index];
                              return _buildListTile(
                                item,
                                _groceryList.groceryList,
                              );
                            },
                          )
                          : Center(child: Text('No grocery list provided.')),

                      Divider(),

                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _checkedItems.length,
                        itemBuilder: (context, index) {
                          final item = _checkedItems[index];
                          return _buildListTile(item, _checkedItems);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(Grocery item, List<Grocery> groceryListPointer) {
    return ListTile(
      title: InlineEditableTitle(
        initialText: item.item,
        onSubmitted: (value) => _updateGroceryItemName(item, value),
        textAlign: TextAlign.start,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.normal),
        maxLinesEdit: 1,
        maxLinesStatic: 5,
      ),
      leading: Checkbox(
        value: item.completed,
        onChanged: (value) {
          setState(() {
            item.completed = !item.completed;
            if (item.completed) {
              _recentlyCompleted.add(item);
            } else {
              _recentlyCompleted.remove(item);
            }
          });
          _updateGroceryItemCompletion(item).then((updatedItem) {
            if (updatedItem == null && mounted) {
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

  Future<Grocery?> _updateGroceryItemCompletion(Grocery item) async {
    final response = await SupabaseHelper.grocery.updateGrocery(item);
    return response;
  }

  Future<Grocery?> _updateGroceryItemName(Grocery item, String newName) async {
    final oldName = item.item;
    setState(() {
      item.item = newName;
    });

    final response = await SupabaseHelper.grocery.upsertGrocery(item);
    if (response == null) {
      setState(() {
        item.item = oldName;
      });
    } else {
      setState(() {
        final index = _groceryList!.groceryList.indexWhere(
          (test) => test.id == item.id,
        );
        if (index != -1) {
          _groceryList.groceryList[index] = response;
        }
      });
    }

    return response;
  }

  Future<bool?> _deleteGroceryItem(Grocery item) async {
    final response = await SupabaseHelper.grocery.deleteGrocery(item);

    if (response == true) {
      setState(() {
        _groceryList?.groceryList.remove(item);
      });
    }

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

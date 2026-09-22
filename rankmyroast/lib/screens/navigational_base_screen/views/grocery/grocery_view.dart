import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rankmyroast/classes/modals/grocery.dart';
import 'package:rankmyroast/classes/modals/grocery_list.dart';
import 'package:rankmyroast/classes/modals/group.dart';
import 'package:rankmyroast/classes/modals/list_order.dart';
import 'package:rankmyroast/screens/navigational_base_screen/views/grocery/widgets/create_list_dialog_widget.dart';
import 'package:rankmyroast/screens/navigational_base_screen/views/grocery/widgets/grocery_list_grid_tile_widget.dart';
import 'package:rankmyroast/services/sqlite_helper.dart';
import 'package:rankmyroast/services/supabase_helper.dart';

const String routeName = '/grocery';

class GroceryView extends StatefulWidget {
  const GroceryView({super.key});

  @override
  State<GroceryView> createState() => _GroceryViewState();
}

class _GroceryViewState extends State<GroceryView> {
  late Future<List<GroceryList>?> _grocery;
  late Future<List<Group>?> _groups;

  @override
  void initState() {
    _grocery = _getGroceryList();
    _groups = _getGroups();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FutureBuilder(
            future: _grocery,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Active Lists",
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "No active groups found",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Expanded(child: SizedBox()),
                    IconButton(
                      onPressed: () async {
                        await _showCreateListDialog();
                      },
                      icon: Icon(Icons.add, color: Colors.white, size: 22.sp),
                      constraints: BoxConstraints(
                        minWidth: 40.w,
                        minHeight: 40.w,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          side: BorderSide(color: Colors.transparent, width: 1),
                        ),
                      ),
                    ),
                  ],
                );
              }

              if (!snapshot.hasData ||
                  snapshot.connectionState == ConnectionState.done) {
                return Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Active Lists ",
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "${snapshot.data!.length} lists(s) found",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(width: 2),
                            GestureDetector(
                              onTap:
                                  () => setState(() {
                                    _refreshData();
                                  }),
                              child: Icon(
                                Icons.refresh_rounded,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Expanded(child: SizedBox()),
                    IconButton(
                      onPressed: () async {
                        await _showCreateListDialog();
                      },
                      icon: Icon(Icons.add, color: Colors.white, size: 22.sp),
                      constraints: BoxConstraints(
                        minWidth: 40.w,
                        minHeight: 40.w,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          side: BorderSide(color: Colors.transparent, width: 1),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                SupabaseHelper.logging.logEvent(
                  type: "error",
                  location: "grocery_view.dart:31",
                  content: "Error fetching grocery: ${snapshot.error}",
                );

                return Text(
                  "Error fetching lists: ${snapshot.error}",
                  style: TextStyle(color: Colors.red),
                );
              }
            },
          ),
          Expanded(
            child: FutureBuilder(
              future: _grocery,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.connectionState == ConnectionState.done) {
                  final grocery = snapshot.data;

                  if (grocery != null && grocery.isNotEmpty) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        const double idealItemWidth = 140.0;

                        int crossAxisCount =
                            (constraints.maxWidth / idealItemWidth).floor();

                        if (crossAxisCount < 2) crossAxisCount = 2;

                        return RefreshIndicator(
                          onRefresh: () async {
                            await _refreshData();
                          },
                          color: Colors.white, // Color of the spinner
                          backgroundColor: Colors.green,
                          child: GridView.builder(
                            shrinkWrap: true,

                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: 0.95,
                                  mainAxisSpacing: 2,
                                  crossAxisSpacing: 2,
                                ),
                            itemCount: grocery.length,
                            itemBuilder: (context, index) {
                              final list = grocery[index];
                              return GestureDetector(
                                onTap: () async {},
                                child: GroceryListGridTileWidget(
                                  groceryList: list,
                                  refreshCallback: () => _refreshData(),
                                  openedCallback:
                                      () => _updateListOrder(list.id),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  } else if (grocery != null && grocery.isEmpty) {
                    return Column(
                      children: [
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              // Industry standard: await the refresh logic directly
                              // so the indicator stays visible until the data is fetched.
                              await _refreshData();
                            },
                            child: ListView(
                              // This is the critical line:
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  // Ensure the empty state takes up the full height
                                  // so the entire screen is "pullable"
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  child: const Center(
                                    child: Text("No recipes found"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Center(child: Text("The Data is null"));
                  }
                } else {
                  return Center(child: Text("The Data is never coming"));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      _grocery = _getGroceryList();
    });
  }

  Future<List<GroceryList>?> _getGroceryList() async {
    final sqliteHelper = SqliteHelper();

    final response = await SupabaseHelper.grocery.getGroceriesForUser();

    if (response != null) {
      final List<GroceryList> groceryLists = response;
      final List<ListOrder> listOrders = await sqliteHelper.getListOrders();
      await sqliteHelper.clearListOrdersForLegacyLists(
        groceryLists.map((groceryList) => groceryList.id.toString()).toList(),
      );

      if (!sqliteHelper.pastListOrdersContainsCurrentLists(
        groceryLists.map((item) => item.id).toList(),
        listOrders,
      )) {
        sqliteHelper.insertListOrder(
          groceryLists
              .map(
                (groceryList) => {
                  'list_id': groceryList.id,
                  'last_updated': DateTime.now().toIso8601String(),
                },
              )
              .toList(),
        );
      }

      final updatedListOrders = await sqliteHelper.getListOrders();

      groceryLists.sort((a, b) {
        final aOrder = updatedListOrders.firstWhere(
          (order) => order.listId == a.id,
          orElse: () => ListOrder(listId: a.id, lastUpdated: DateTime.now()),
        );
        final bOrder = updatedListOrders.firstWhere(
          (order) => order.listId == b.id,
          orElse: () => ListOrder(listId: b.id, lastUpdated: DateTime.now()),
        );
        return bOrder.lastUpdated.compareTo(aOrder.lastUpdated);
      });

      return groceryLists;
    } else {
      SupabaseHelper.logging.logEvent(
        type: "error",
        location: "grocery_view.dart:258",
        content: "Error fetching grocery: $response",
      );
      return null;
    }
  }

  Future<bool?> _showCreateListDialog() async {
    final List<Group> groups = await _groups ?? [];

    if (!mounted) {
      return null;
    }

    final response = await showDialog(
      context: context,
      builder: (context) => CreateListDialogWidget(groups: groups),
    );

    return response;
  }

  Future<List<Group>?> _getGroups() async {
    return SupabaseHelper.groups.getGroupsForUser();
  }

  Future<void> _updateListOrder(String listId) async {
    final sqliteHelper = SqliteHelper();
    await sqliteHelper.updateListOrder(listId, DateTime.now());
  }
}

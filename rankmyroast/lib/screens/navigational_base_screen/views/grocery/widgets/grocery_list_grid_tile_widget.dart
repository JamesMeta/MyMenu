import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rankmyroast/classes/modals/grocery_list.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroceryListGridTileWidget extends StatefulWidget {
  final GroceryList groceryList;
  final VoidCallback refreshCallback;
  final VoidCallback openedCallback;

  const GroceryListGridTileWidget({
    super.key,
    required this.groceryList,
    required this.refreshCallback,
    required this.openedCallback,
  });

  @override
  State<GroceryListGridTileWidget> createState() =>
      _GroceryListGridTileWidgetState();
}

class _GroceryListGridTileWidgetState extends State<GroceryListGridTileWidget> {
  late GroceryList _groceryList;

  @override
  void initState() {
    _groceryList = widget.groceryList;

    // sort the grocery list items by completed status
    _groceryList.groceryList.sort((a, b) {
      if (a.completed && !b.completed) {
        return 1;
      } else if (!a.completed && b.completed) {
        return -1;
      } else {
        return 0;
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        widget.openedCallback();

        final response = await context.push(
          '/base/grocery/list-viewer',
          extra: _groceryList,
        );

        if (response is! GroceryList) {
          widget.refreshCallback();
        } else {
          setState(() {
            _groceryList = response;
          });
        }
      },
      child: GridTile(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(59, 22, 59, 1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color.fromARGB(255, 22, 59, 1),
                width: 1.2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                    child: Text(
                      _groceryList.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 4),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _groceryList.groceryList.length,
                      itemBuilder: (context, index) {
                        return _buildItemRow(
                          _groceryList.groceryList[index].item,
                          _groceryList.groceryList[index].completed,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemRow(String item, bool completed) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            width: 24.0, // Standard checkbox icon size
            height: 24.0,
            child: Checkbox(
              value: completed,
              onChanged: (changed) {},
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(
                horizontal: VisualDensity.minimumDensity,
                vertical: VisualDensity.minimumDensity,
              ),
            ),
          ),
        ),
        Expanded(flex: 7, child: Text(item, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

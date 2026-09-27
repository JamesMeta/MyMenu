import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:rankmyroast/classes/modals/grocery_list.dart';

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
    super.initState();
    _groceryList = widget.groceryList;
    _sortItems();
  }

  @override
  void didUpdateWidget(covariant GroceryListGridTileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.groceryList != oldWidget.groceryList) {
      _groceryList = widget.groceryList;
      _sortItems();
    }
  }

  void _sortItems() {
    // Sort uncompleted items first, then completed items
    _groceryList.groceryList.sort((a, b) {
      if (a.completed && !b.completed) {
        return 1;
      } else if (!a.completed && b.completed) {
        return -1;
      } else {
        return 0;
      }
    });
  }

  Future<void> _handleTap(BuildContext context) async {
    widget.openedCallback();

    final response = await context.push(
      '/base/grocery/list-viewer',
      extra: _groceryList,
    );

    if (!context.mounted) return;

    if (response is! GroceryList) {
      widget.refreshCallback();
    } else {
      setState(() {
        _groceryList = response;
        _sortItems();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalCount = _groceryList.groceryList.length;
    final int completedCount =
        _groceryList.groceryList.where((item) => item.completed).length;

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleTap(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(totalCount, completedCount),
                  Expanded(
                    child: _buildBody(totalCount, completedCount),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int totalCount, int completedCount) {
    final bool isAllDone = totalCount > 0 && completedCount == totalCount;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      color: Colors.green,
      child: Row(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            color: Colors.white,
            size: 15.sp,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              _groceryList.name,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_groceryList.groupId != null) ...[
            SizedBox(width: 4.w),
            Icon(
              Icons.group_rounded,
              size: 13.sp,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ],
          if (totalCount > 0) ...[
            SizedBox(width: 6.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: isAllDone
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isAllDone) ...[
                    Icon(
                      Icons.check,
                      size: 10.sp,
                      color: Colors.green.shade800,
                    ),
                    SizedBox(width: 2.w),
                  ],
                  Text(
                    isAllDone ? "Done" : "$completedCount/$totalCount",
                    style: TextStyle(
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w700,
                      color: isAllDone ? Colors.green.shade800 : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(int totalCount, int completedCount) {
    if (totalCount == 0) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_shopping_cart_rounded,
                size: 26.sp,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 4.h),
              Text(
                "No items yet",
                style: TextStyle(
                  fontSize: 11.5.sp,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                "Tap to add",
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final previewItems = _groceryList.groceryList.take(3).toList();
    final remainingCount = totalCount - previewItems.length;
    final double progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ...previewItems.map(
                  (item) => _buildItemRow(item.item, item.completed),
                ),
                if (remainingCount > 0)
                  Padding(
                    padding: EdgeInsets.only(top: 2.h, left: 19.w),
                    child: Text(
                      "+$remainingCount more",
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? Colors.green : Colors.green.shade600,
              ),
              minHeight: 4.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(String item, bool completed) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.5.h),
      child: Row(
        children: [
          Icon(
            completed
                ? Icons.check_circle_rounded
                : Icons.circle_outlined,
            size: 13.sp,
            color: completed ? Colors.green : Colors.grey.shade400,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              item,
              style: TextStyle(
                fontSize: 11.5.sp,
                color: completed ? Colors.grey.shade400 : Colors.grey.shade800,
                decoration: completed ? TextDecoration.lineThrough : null,
                decorationColor: Colors.grey.shade400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}


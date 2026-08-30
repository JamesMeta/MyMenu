import 'package:flutter/material.dart';
import 'package:rankmyroast/classes/modals/grocery_list.dart';

class GroceryListGridTileWidget extends StatelessWidget {
  final GroceryList groceryList;

  const GroceryListGridTileWidget({super.key, required this.groceryList});

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[600]!),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(groceryList.name),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: groceryList.groceryList.length,
                    itemBuilder: (context, index) {
                      return _buildItemRow(
                        groceryList.groceryList[index].item,
                        groceryList.groceryList[index].completed,
                      );
                    },
                  ),
                ),
              ],
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

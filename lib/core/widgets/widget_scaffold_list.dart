import 'package:flutter/material.dart';

import '../../config/textstyle/app_sizes.dart';
import 'widget_app_bar.dart';
import 'widget_search_bar.dart';

class WidgetScaffoldList extends StatelessWidget {
  final String title;
  final TextEditingController searchController;
  final String searchHint;
  final Function(String) onChanged;
  final Function() onClear;
  final Function() onSortTap;
  final Widget buildListItems;

  const WidgetScaffoldList({
    super.key,
    required this.title,
    required this.searchController,
    required this.searchHint,
    required this.onChanged,
    required this.onClear,
    required this.onSortTap,
    required this.buildListItems,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetAppBar(
        title: title,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.size16,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  WidgetSearchBar(
                    controller: searchController,
                    hintText: searchHint,
                    onChanged: onChanged,
                    onClear: onClear,
                  ),
                  AppSizes.spaceWidth8,
                  IconButton(
                    icon: Icon(Icons.sort, size: AppSizes.size24),
                    onPressed: onSortTap,
                  ),
                ],
              ),
              AppSizes.spaceHeight16,
              Expanded(
                child: buildListItems,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

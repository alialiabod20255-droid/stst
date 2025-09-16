import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class SearchBarWidget extends StatelessWidget {
  final Function(String) onSearch;

  const SearchBarWidget({
    super.key,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextField(
        onSubmitted: onSearch,
        decoration: InputDecoration(
          hintText: 'ابحث عن باقات الورود...',
          prefixIcon: Icon(
            Icons.search,
            color: AppTheme.primaryPink,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
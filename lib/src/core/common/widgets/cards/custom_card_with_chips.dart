import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class CustomCardWithChips extends StatelessWidget {
  final double height;
  final double margin;
  final double padding;
  final double borderRadius;
  final String title;
  final String description;
  final List<String> chips;
  final Color cardColor;
  final VoidCallback? onTap; // ✅ Accepts an onTap function
  const CustomCardWithChips({
    super.key,
    this.height = 200,
    this.margin = 16,
    this.padding = 16,
    this.borderRadius = 10,
    this.title = '',
    this.description = '',
    this.chips = const [],
    this.cardColor = AppPallete.greyColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        margin: EdgeInsets.all(margin).copyWith(
          bottom: 4,
        ),
        padding: EdgeInsets.all(margin),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: chips
                        .map(
                          (_) => Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Chip(
                              label: Text(
                                _,
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text('1 min')
          ],
        ),
      ),
    );
  }
}

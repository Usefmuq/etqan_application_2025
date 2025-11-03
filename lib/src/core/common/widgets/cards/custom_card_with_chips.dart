import 'package:flutter/material.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';

class CustomCardWithChips extends StatelessWidget {
  final double height;
  final double margin;
  final double padding;
  final double borderRadius;
  final String title;
  final String description;
  final List<String> chips;
  final Color cardColor;
  final VoidCallback? onTap;

  const CustomCardWithChips({
    super.key,
    this.height = 200,
    this.margin = 16,
    this.padding = 16,
    this.borderRadius = 16,
    this.title = '',
    this.description = '',
    this.chips = const [],
    this.cardColor = AppPallete.cardColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: margin),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: Container(
          height: height,
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chips row
              if (chips.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: chips.map(
                      (chip) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: Chip(
                            label: Text(
                              chip,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            backgroundColor:
                                AppPallete.primaryLavender.withAlpha(30),
                            labelStyle: const TextStyle(
                              color: AppPallete.primaryLavender,
                            ),
                            shape: const StadiumBorder(),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),

              // Title and Description
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppPallete.textPrimary,
                    ),
                  ),
                  if (description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppPallete.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),

              // Footer Info (like time)
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '1 min ago',
                  style: TextStyle(
                    color: AppPallete.greyColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

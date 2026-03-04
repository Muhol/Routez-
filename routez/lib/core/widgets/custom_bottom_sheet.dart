import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../constants/app_colors.dart';

class CustomBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;

  const CustomBottomSheet({super.key, required this.child, this.title});

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CustomBottomSheet(title: title, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.dividerLight,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
          ),
          const SizedBox(height: AppSizes.p16),
          if (title != null) ...[
            Text(
              title!,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.p16),
          ],
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

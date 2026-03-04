import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Widget? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: isLoading ? () {} : onPressed,
              icon: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : (icon ?? const SizedBox.shrink()),
              label: Text(text),
            )
          : ElevatedButton.icon(
              onPressed: isLoading ? () {} : onPressed,
              icon: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : (icon ?? const SizedBox.shrink()),
              label: Text(text),
            ),
    );
  }
}

import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool resizeToAvoidBottomInset;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ), // Ensures it looks good on wide screens
          child: body,
        ),
      ),
      bottomNavigationBar: bottomNavigationBar != null
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: bottomNavigationBar,
              ),
            )
          : null,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}

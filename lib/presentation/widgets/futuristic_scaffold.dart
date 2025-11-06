import 'dart:ui';
import 'package:flutter/material.dart';

class FuturisticScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final Widget? bottomNav;
  final List<Widget>? actions;
  const FuturisticScaffold({super.key, required this.body, required this.title, this.bottomNav, this.actions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title, style: const TextStyle(letterSpacing: 1.2)), actions: actions),
      extendBody: true,
      bottomNavigationBar: bottomNav,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F1115), Color(0xFF131A2A)],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: const SizedBox.shrink(),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

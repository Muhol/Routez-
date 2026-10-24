import 'package:flutter/material.dart';

/// A horizontal scroller that runs edge to edge and fades its content out
/// at the left/right screen edges.
///
/// The fade only appears on a side once there is content hidden beyond it:
/// at rest the first item sits fully visible at [padding].left, and the left
/// fade grows in as the user scrolls. The right fade disappears once the end
/// of the list is reached.
class EdgeFadeScroller extends StatefulWidget {
  final EdgeInsets padding;
  final double fadeWidth;
  final Widget child;

  const EdgeFadeScroller({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.fadeWidth = 28,
  });

  @override
  State<EdgeFadeScroller> createState() => _EdgeFadeScrollerState();
}

class _EdgeFadeScrollerState extends State<EdgeFadeScroller> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    // Rebuild once after the first layout so scroll extents are known
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // 0 = no fade on that side, 1 = full fade
        double left = 0;
        double right = 1;
        if (_controller.hasClients &&
            _controller.position.hasContentDimensions) {
          final pos = _controller.position;
          left = (pos.pixels / widget.fadeWidth).clamp(0.0, 1.0);
          right = ((pos.maxScrollExtent - pos.pixels) / widget.fadeWidth)
              .clamp(0.0, 1.0);
        }

        return ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (rect) {
            final fade = (widget.fadeWidth / rect.width).clamp(0.0, 0.5);
            return LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 1 - left),
                Colors.black,
                Colors.black,
                Colors.black.withValues(alpha: 1 - right),
              ],
              stops: [0.0, fade, 1.0 - fade, 1.0],
            ).createShader(rect);
          },
          child: child,
        );
      },
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: widget.padding,
        child: widget.child,
      ),
    );
  }
}

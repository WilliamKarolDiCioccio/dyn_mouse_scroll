import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'scroll_state.dart';

class DynMouseScroll extends StatelessWidget {
  final ScrollController controller;
  final ScrollPhysics mobilePhysics;
  final int durationMS;
  final double scrollSpeed;
  final Curve animationCurve;
  final Function(BuildContext, ScrollController, ScrollPhysics) builder;

  const DynMouseScroll({
    super.key,
    required this.controller,
    this.mobilePhysics = kMobilePhysics,
    this.durationMS = 380,
    this.scrollSpeed = 2,
    this.animationCurve = Curves.easeOutQuart,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ScrollState>(
      create: (context) => ScrollState(
        controller,
        mobilePhysics,
        durationMS,
      ),
      builder: (context, _) {
        final scrollState = context.read<ScrollState>();
        final controller = scrollState.controller;
        final physics = context.select((ScrollState s) => s.physics);

        // ignore: unused_local_variable
        final updateState = context.select((ScrollState s) => s.updateState);

        scrollState.handlePipelinedScroll?.call();

        return Listener(
          onPointerSignal: (signalEvent) => scrollState.handleDesktopScroll(
            signalEvent,
            scrollSpeed,
            animationCurve,
          ),
          onPointerDown: scrollState.handleTouchScroll,
          child: builder(
            context,
            controller,
            physics,
          ),
        );
      },
    );
  }
}

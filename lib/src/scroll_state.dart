import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

// Constants for mobile and desktop scroll physics
const kMobilePhysics = BouncingScrollPhysics();
const kDesktopPhysics = NeverScrollableScrollPhysics();

class ScrollState with ChangeNotifier {
  final ScrollController controller; // The scroll controller that manages scrolling
  ScrollPhysics physics = kMobilePhysics; // Physics for controlling how scroll behaves
  double futurePosition = 0; // Target future scroll position
  bool updateState = false; // Used for state updates

  final ScrollPhysics mobilePhysics; // Mobile-specific physics (for touch screens)
  final int durationMS; // Duration of scroll animations in milliseconds

  bool prevDeltaPositive = false; // Tracks scroll direction
  double? lastLock; // Used to lock scroll position

  Future<void>? _animationEnd; // Future that tracks the scroll animation end

  Function()? handlePipelinedScroll; // Function to handle pipelined scrolls

  // Constructor that initializes the controller, mobile physics, and animation duration
  ScrollState(
    this.controller,
    this.mobilePhysics,
    this.durationMS,
  );

  // Utility function to calculate the maximum delta to apply to the scroll position
  static double calcMaxDelta(ScrollController controller, double delta) {
    return delta > 0
        ? math.min(controller.position.pixels + delta,
                controller.position.maxScrollExtent) - controller.position.pixels
        : math.max(controller.position.pixels + delta,
                controller.position.minScrollExtent) - controller.position.pixels;
  }

  // Handles desktop scroll events like mouse wheel and touchpad scrolls
  void handleDesktopScroll(
    PointerSignalEvent event,
    double scrollSpeed,
    Curve animationCurve, [
    bool readLastDirection = true,
  ]) {
    // Ensure we are using desktop physics or reset when needed
    if (physics == kMobilePhysics || lastLock != null) {
      if (lastLock != null) updateState = !updateState;

      if (event is PointerScrollEvent) {
        double posPixels = controller.position.pixels;

        // If at scroll limits, prevent further scrolling
        if ((posPixels == controller.position.minScrollExtent && event.scrollDelta.dy < 0) ||
            (posPixels == controller.position.maxScrollExtent && event.scrollDelta.dy > 0)) {
          return;
        } else {
          // Switch to desktop physics when needed
          physics = kDesktopPhysics;
          bool outOfBounds = posPixels < controller.position.minScrollExtent ||
              posPixels > controller.position.maxScrollExtent;
          double calcDelta = calcMaxDelta(controller, event.scrollDelta.dy);

          // Jump to the new scroll position calculated by delta
          if (!outOfBounds) {
            controller.jumpTo(lastLock ?? (posPixels - calcDelta));
          }

          double deltaDelta = calcDelta - event.scrollDelta.dy;

          // Handle additional scroll events that are pipelined
          handlePipelinedScroll = () {
            handlePipelinedScroll = null;
            double currPos = controller.position.pixels;
            double currDelta = event.scrollDelta.dy;

            // Condition to lock scroll position at the current point
            bool shouldLock = lastLock != null
                ? (lastLock == currPos)
                : (posPixels != currPos + deltaDelta &&
                    (currPos != controller.position.maxScrollExtent || currDelta < 0) &&
                    (currPos != controller.position.minScrollExtent || currDelta > 0));

            // Lock or move the scroll position based on conditions
            if (!outOfBounds && shouldLock) {
              controller.jumpTo(posPixels);
              lastLock = posPixels;
              controller.position.moveTo(posPixels).whenComplete(() {
                physics = kMobilePhysics;
                notifyListeners(); // Notify listeners once scroll completes
              });
              return;
            } else {
              // Continue scrolling or reset the lock
              if (lastLock != null || outOfBounds) {
                controller.jumpTo(lastLock != null
                    ? posPixels
                    : (currPos - calcMaxDelta(controller, currDelta)));
              }
              lastLock = null;

              handleDesktopScroll(event, scrollSpeed, animationCurve, false);
            }
          };

          notifyListeners(); // Notify listeners about changes
        }
      }

      return;
    } else if (event is PointerScrollEvent) {
      // Normal scroll handling (not out of bounds or locked)
      bool currentDeltaPositive = event.scrollDelta.dy > 0;

      if (readLastDirection && currentDeltaPositive == prevDeltaPositive) {
        // Adjust future scroll position based on scroll delta
        futurePosition += event.scrollDelta.dy * scrollSpeed;
      } else {
        // Set future scroll position directly
        futurePosition =
            controller.position.pixels + event.scrollDelta.dy * scrollSpeed;
      }

      prevDeltaPositive = event.scrollDelta.dy > 0;

      // Animate to the new scroll position
      Future<void> animationEnd = _animationEnd = controller.animateTo(
        futurePosition,
        duration: Duration(milliseconds: durationMS),
        curve: animationCurve,
      );

      // Once animation is complete, revert to mobile physics if still using desktop physics
      animationEnd.whenComplete(() {
        if (animationEnd == _animationEnd && physics == kDesktopPhysics) {
          physics = mobilePhysics;
          notifyListeners(); // Notify listeners after the animation ends
        }
      });
    }
  }

  // Handles touch scroll events (for mobile and touch screens)
  void handleTouchScroll(PointerDownEvent event) {
    if (physics == kDesktopPhysics) {
      // Revert to mobile physics when touch input is detected
      physics = mobilePhysics;
      notifyListeners(); // Notify listeners of the change
    }
  }
}

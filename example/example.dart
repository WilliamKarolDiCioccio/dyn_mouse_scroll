import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const LinkedPhysicsApp());
}

class BasicUsageApp extends StatelessWidget {
  const BasicUsageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: DynMouseScroll(
          controller: ScrollController(),
          builder: (context, controller, physics) => ListView(
            controller: controller,
            physics: physics,
            children: List.generate(
              40,
              (index) => Container(
                height: 500,
                color: (index % 2 == 0) ? Colors.redAccent : Colors.blueAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomSettingsUsageApp extends StatelessWidget {
  const CustomSettingsUsageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: DynMouseScroll(
          controller: ScrollController(),
          durationMS: 500,
          scrollSpeed: 4.4,
          animationCurve: Curves.easeOutQuart,
          builder: (context, controller, physics) => ListView(
            controller: controller,
            physics: physics,
            children: List.generate(
              40,
              (index) => Container(
                height: 500,
                color: (index % 2 == 0) ? Colors.redAccent : Colors.blueAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LinkedPhysicsApp extends StatelessWidget {
  const LinkedPhysicsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    MyScrollingWidget(
                        height: 100, colors: [Colors.blue, Colors.red]),
                    MyScrollingWidget(
                        height: 200, colors: [Colors.yellow, Colors.green]),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    MyScrollingWidget(
                        height: 150, colors: [Colors.purple, Colors.orange]),
                    MyScrollingWidget(
                        height: 80, colors: [Colors.black, Colors.white])
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MyScrollingWidget extends StatelessWidget {
  final List<Color> colors;
  final double height;

  const MyScrollingWidget({
    Key? key,
    required this.colors,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DynMouseScroll(
        controller: ScrollController(),
        builder: (
          context,
          controller,
          physics,
        ) =>
            ListView(
          controller: controller,
          physics: physics,
          children: List.generate(
            50,
            (index) => Container(
              width: MediaQuery.of(context).size.width / 2,
              height: height,
              color: (index % 2 == 0) ? colors[0] : colors[1],
            ),
          ),
        ),
      ),
    );
  }
}

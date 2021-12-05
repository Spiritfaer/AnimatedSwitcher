import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Animated Switcher',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Animated Switcher Demo'),
      initialBinding: BindingsBuilder.put(() => StateController()),
    );
  }
}

class StateController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  RxString message = 'Fade In'.obs;
  late Rx<Key> key = const ValueKey('value').obs;

  @override
  void onInit() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animationController.addStatusListener(_listener);

    key.value = ValueKey(message.value);
    super.onInit();
  }

  @override
  void onClose() {
    _animationController.dispose();
    super.onClose();
  }

  void _listener(AnimationStatus status) {
    if (status == AnimationStatus.reverse) {
      message.value = 'Fade Out';
      key.value = ValueKey(message.value);
    } else if (status == AnimationStatus.forward) {
      message.value = 'Fade In';
      key.value = ValueKey(message.value);
    }
    log('status = $status', name: '_listener');
  }
}

class MyHomePage extends GetView<StateController> {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Obx(
        () => TransitionTextWidget(
          animationController: controller._animationController,
          message: controller.message.value,
        ),
      ),
      floatingActionButton: ElevatedButton.icon(
        label: Obx(() => Text('${controller.message}')),
        icon: const Icon(Icons.play_arrow),
        onPressed: () {
          final status = controller._animationController.status;
          if (status == AnimationStatus.dismissed) {
            controller._animationController.forward();
          } else if (status == AnimationStatus.completed) {
            controller._animationController.reverse();
          }
        },
      ),
    );
  }
}

class TransitionTextWidget extends StatelessWidget {
  final AnimationController animationController;
  final String message;

  const TransitionTextWidget({
    Key? key,
    required this.animationController,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animationController,
      child: Center(
        child: AnimatedSwitcher(
          duration: Duration(
              milliseconds:
                  animationController.duration?.inMilliseconds ?? 1000),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: const Offset(0, 0),
              ).animate(animation),
              child: child,
            );
          },
          child: Text(
            message,
            key: ValueKey(message),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 36,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isBusy = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    isBusy = false;
                  });
                },
                icon: const Icon(Icons.refresh))
          ],
        ),
        body: PaginationScrollListener(
          isLoading: isBusy,
          onReachedTargetPosition: () {
            setState(() {
              isBusy = true;
            });
            print('called');
          },
          targetPosition: (maxExtent) => maxExtent * 0.7,
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                height: 200,
                color: Colors.green,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

typedef TargetPosition = double Function(double maxExtent);

class PaginationScrollListener extends StatefulWidget {
  const PaginationScrollListener({
    super.key,
    required this.child,
    required this.isLoading,
    required this.targetPosition,
    required this.onReachedTargetPosition,
  });

  ///function that you want to call when you reach specified position
  final VoidCallback onReachedTargetPosition;

  ///child [Widget that can generate Scroll Events Like ListView]
  final Widget child;

  ///Your State
  final bool isLoading;

  ///Position in pixels
  final TargetPosition targetPosition;
  @override
  State<PaginationScrollListener> createState() =>
      _PaginationScrollListenerState();
}

class _PaginationScrollListenerState extends State<PaginationScrollListener> {
  Timer? _timer;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PaginationScrollListener oldWidget) {
    _timer?.cancel();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final metrics = notification.metrics;
        if (metrics.pixels >= widget.targetPosition(metrics.maxScrollExtent)) {
          if (_timer?.isActive ?? false) return false;
          if (widget.isLoading) return false;
          _timer = Timer(Duration.zero, widget.onReachedTargetPosition);
        }
        return false;
      },
      child: widget.child,
    );
  }
}

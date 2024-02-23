import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Pretendard'
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  static const String _text = 'Pretendard 프리텐다드';
  static const TextStyle _baseStyle = TextStyle(
    fontSize: 24
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'Let\'s make an animation using Variable Font!'
            ),
            WaveTextWidget(
                text: _text,
                style: _baseStyle
            ),
          ],
        ),
      ),
    );
  }
}


class WaveTextWidget extends StatefulWidget {

  final String text;
  final TextStyle style;

  const WaveTextWidget({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  State<WaveTextWidget> createState() => _WaveTextWidgetState();
}

class _WaveTextWidgetState extends State<WaveTextWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3), lowerBound: 0, upperBound: math.pi);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {

            return Text.rich(
                TextSpan(
                    children: List.generate(widget.text.length, (index) {

                      final variable = math.sin((_controller.value - index/widget.text.length) * 2) / 2 + 0.5;
                      final value = 100 + 900 * variable;

                      return TextSpan(
                        text: widget.text[index],
                        style: widget.style.copyWith(
                            fontVariations: [
                              FontVariation('wght', value),
                            ]
                        ),
                      );
                    })
                )
            );
          }
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const HelloNext());
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const HelloNext();
//   }
// }

class HelloNext extends StatefulWidget {
  const HelloNext({super.key});

  @override
  State<HelloNext> createState() => _HelloNextState();
}

class _HelloNextState extends State<HelloNext> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Animation<double>> animations = [];

  final List<String> logos = ['images/flutter_icon.png', 'images/nextjs_icon.png'];
  final String hello = 'Hello! NextJS';


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));
    _controller.addStatusListener((status) {
      if(status == AnimationStatus.completed){
        _controller.reset();
      }
    });

    for(int i=0; i<hello.length+2; i++){
      animations.add(
          Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: _controller,
                  curve: Interval(
                      i == 0 ? 0 : 1/(hello.length+2)*(i-0.7),
                      1/(hello.length+2)*(i+1),
                      curve: Curves.easeOutSine
                  )
              )
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Directionality(
      textDirection: TextDirection.ltr,

      child: Center(
        child: GestureDetector(
          onTap: (){
            if(_controller.isDismissed){
              _controller.forward();
            }
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(hello.length+2, (index) {

                return Wave(
                    listenable: animations[index],
                    child: index == 0 || index == hello.length+1
                        ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Image.asset(
                        index == 0 ? logos.first : logos.last,
                        width: 36,
                      ),
                    )
                        : Text(
                      hello[index-1],
                      style: GoogleFonts.roboto(fontSize: 36),
                      textDirection: TextDirection.ltr,
                    )
                );
              }),

            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class Wave extends AnimatedWidget {
  const Wave({
    Key? key,
    required super.listenable,
    required this.child
  }) : super(key: key);

  final Widget child;

  Animation<double> get _animation => listenable as Animation<double>;
  final double _height = 20;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animation,
        child: child,
        builder: (_, child) {
          final double dy = -math.sin(_animation.value * math.pi) * _height;
          return Transform.translate(
              offset: Offset(
                  0, dy
              ),
              child: child!
          );
        }
    );
  }
}

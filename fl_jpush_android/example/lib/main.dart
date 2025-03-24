import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        title: 'FlJPush with Android',
        home: Scaffold(
            appBar: AppBar(title: const Text('FlJPush with Android')),
            body: const Center(child: Text('集成厂商通道'))));
  }
}

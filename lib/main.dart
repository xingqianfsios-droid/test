import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/game_controller.dart';
import 'views/home_view.dart';
import 'views/game_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Xiangqi Pro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const HomeView()),
        GetPage(
          name: '/game',
          page: () => const GameView(),
          binding: BindingsBuilder(() {
            Get.put(GameController());
          }),
        ),
      ],
    );
  }
}

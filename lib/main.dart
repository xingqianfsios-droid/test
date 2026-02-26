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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B6914),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5E6C8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3C2415),
          foregroundColor: Color(0xFFE8D5B0),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE8D5B0),
            letterSpacing: 4,
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFFF5E6C8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF8B6914), width: 1.5),
          ),
          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3C2415),
          ),
          contentTextStyle: const TextStyle(
            fontSize: 15,
            color: Color(0xFF5C3A1E),
            height: 1.6,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF8B6914),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B6914),
            foregroundColor: const Color(0xFFF5E6C8),
          ),
        ),
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

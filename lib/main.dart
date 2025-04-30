import 'package:currencyconv/binding/currency_binding.dart';
import 'package:currencyconv/view/currency_screen.dart';
import 'package:currencyconv/controller/currency_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyController = Get.put(CurrencyController(), permanent: true);
    
    return Obx(() => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currency Converter',
      themeMode: currencyController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.black87),
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
          bodySmall: TextStyle(color: Colors.black45),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        colorScheme: ColorScheme.light(
          primary: Colors.purple[700]!,
          secondary: Colors.deepPurple[500]!,
          error: Colors.red[700]!,
          onPrimary: Colors.white,
        ),
        hintColor: Colors.grey[400],
        dividerColor: Colors.grey[300],
        disabledColor: Colors.grey[400],
      ),
      
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        cardTheme: CardTheme(
          color: Colors.grey[850],
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          bodySmall: TextStyle(color: Colors.white60),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        colorScheme: ColorScheme.dark(
          primary: Colors.deepPurple[300]!,
          secondary: Colors.purple[300]!,
          error: Colors.red[300]!,
          onPrimary: Colors.white,
        ),
        hintColor: Colors.grey[500],
        dividerColor: Colors.grey[700],
        disabledColor: Colors.grey[600],
      ),
      
      initialRoute: '/currency',
      getPages: [
        GetPage(
          name: '/currency',
          page: () => CurrencyView(),
          binding: CurrencyBinding(),
        )
      ],
    ));
  }
}
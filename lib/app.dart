import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'models/app_data.dart';
import 'screens/home/home_screen.dart';

class CondoLeituraApp extends StatelessWidget {
  const CondoLeituraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppData>(
          create: (_) => AppData()..load(),
        ),
      ],
      child: MaterialApp(
        title: 'CondoLeitura',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
        builder: (context, child) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
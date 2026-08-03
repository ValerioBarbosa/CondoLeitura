import 'package:flutter/material.dart';

import '../screens/condominiums/condominium_details_screen.dart';
import '../screens/condominiums/condominium_form_screen.dart';
import '../screens/condominiums/condominium_list_screen.dart';
import '../screens/home/home_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const home = '/home';
  static const condominiums = '/condominiums';
  static const condominiumForm = '/condominiums/form';
  static const condominiumDetails = '/condominiums/details';

  static Map<String, WidgetBuilder> get routes => {
        home: (_) => const HomeScreen(),
        condominiums: (_) => const CondominiumListScreen(),
        condominiumForm: (_) => const CondominiumFormScreen(),
        condominiumDetails: (_) => const CondominiumDetailsScreen(),
      };
}

import 'package:get/get.dart';

import '../modules/print/bindings/print_binding.dart';
import '../modules/print/views/print_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.print;

  static final routes = [
    GetPage(
      name: _Paths.print,
      page: () => const PrintView(),
      binding: PrintBinding(),
    ),
  ];
}

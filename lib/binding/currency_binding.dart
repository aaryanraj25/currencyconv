import 'package:currencyconv/controller/currency_controller.dart';
import 'package:get/get.dart';

class CurrencyBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CurrencyController());
  }
}

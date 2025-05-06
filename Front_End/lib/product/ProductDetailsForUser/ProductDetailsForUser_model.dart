// lib/pages/ProductDetailsForUser_model.dart
import '/custom/form_field_controller.dart';
import 'package:flutter/material.dart';

class ProductDetailsModel extends ChangeNotifier {
  int countControllerValue = 1;
  String? dropDownValue1;
  String? dropDownValue2;
  FormFieldController<String>? dropDownValueController1;
  FormFieldController<String>? dropDownValueController2;

  void updateCount(int newValue) {
    countControllerValue = newValue;
    notifyListeners();
  }

  @override
  void dispose() {
    dropDownValueController1?.dispose();
    dropDownValueController2?.dispose();
    super.dispose();
  }
}

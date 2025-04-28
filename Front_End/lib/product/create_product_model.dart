// ignore_for_file: unused_import

import '/custom/choice_chips.dart';
import '/custom/icon_button.dart';
import '/custom/theme.dart';
import '/custom/util.dart';
import '/custom/widgets.dart';
import '/custom/form_field_controller.dart';
import '/custom/upload_data.dart';
import 'dart:ui';
import 'create_product_widget.dart' show CreateProductWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CreateProductModel extends FlutterFlowModel<CreateProductWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  bool isDataUploading1 = false;
  FFUploadedFile uploadedLocalFile1 = FFUploadedFile(
    bytes: Uint8List.fromList([]),
  );

  bool isDataUploading2 = false;
  FFUploadedFile uploadedLocalFile2 = FFUploadedFile(
    bytes: Uint8List.fromList([]),
  );

  bool isDataUploading3 = false;
  FFUploadedFile uploadedLocalFile3 = FFUploadedFile(
    bytes: Uint8List.fromList([]),
  );

  // State field(s) for productName widget.
  FocusNode? productNameFocusNode;
  TextEditingController? productNameTextController;
  String? Function(BuildContext, String?)? productNameTextControllerValidator;
  // State field(s) for description widget.
  FocusNode? descriptionFocusNode;
  TextEditingController? descriptionTextController;
  String? Function(BuildContext, String?)? descriptionTextControllerValidator;
  // State field(s) for key widget.
  FocusNode? keyFocusNode;
  TextEditingController? keyTextController;
  String? Function(BuildContext, String?)? keyTextControllerValidator;
  // State field(s) for ChoiceChips widget.
  FormFieldController<List<String>>? choiceChipsValueController1;
  List<String>? get choiceChipsValues1 => choiceChipsValueController1?.value;
  set choiceChipsValues1(List<String>? val) =>
      choiceChipsValueController1?.value = val;
  // State field(s) for ChoiceChips widget.
  FormFieldController<List<String>>? choiceChipsValueController2;
  List<String>? get choiceChipsValues2 => choiceChipsValueController2?.value;
  set choiceChipsValues2(List<String>? val) =>
      choiceChipsValueController2?.value = val;
  // State field(s) for minprice widget.
  FocusNode? minpriceFocusNode;
  TextEditingController? minpriceTextController;
  String? Function(BuildContext, String?)? minpriceTextControllerValidator;
  // State field(s) for maxprice widget.
  FocusNode? maxpriceFocusNode;
  TextEditingController? maxpriceTextController;
  String? Function(BuildContext, String?)? maxpriceTextControllerValidator;
  // State field(s) for dicount widget.
  bool? dicountValue;
  // State field(s) for diciuntamount widget.
  FocusNode? diciuntamountFocusNode;
  TextEditingController? diciuntamountTextController;
  String? Function(BuildContext, String?)? diciuntamountTextControllerValidator;
  // State field(s) for keywords widget.
  FocusNode? keywordsFocusNode;
  TextEditingController? keywordsTextController;
  String? Function(BuildContext, String?)? keywordsTextControllerValidator;

  FocusNode? stockFocusNode;
  TextEditingController? stockTextController;
  String? Function(BuildContext, String?)? StockTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    productNameFocusNode?.dispose();
    productNameTextController?.dispose();

    descriptionFocusNode?.dispose();
    descriptionTextController?.dispose();

    keyFocusNode?.dispose();
    keyTextController?.dispose();

    minpriceFocusNode?.dispose();
    minpriceTextController?.dispose();

    maxpriceFocusNode?.dispose();
    maxpriceTextController?.dispose();

    diciuntamountFocusNode?.dispose();
    diciuntamountTextController?.dispose();

    keywordsFocusNode?.dispose();
    keywordsTextController?.dispose();

    stockFocusNode?.dispose();
    stockTextController?.dispose();
  }
}

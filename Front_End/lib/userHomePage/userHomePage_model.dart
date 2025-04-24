import '/custom/util.dart';
import 'userHomePage.dart' show userHomePage;
import 'package:flutter/material.dart';

class BasepageanotherchoiceModel extends FlutterFlowModel<userHomePage> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}

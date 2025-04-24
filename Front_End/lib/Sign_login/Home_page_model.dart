import '/custom/util.dart';
// ignore: unused_import
import '/custom/util.dart' as random_data;
import 'package:cadeau_project/Sign_login/Authentication.dart'
    show HomePageWidget;
import 'package:flutter/material.dart';
import '/custom/util.dart';
import '/custom/form_field_controller.dart';

class HomePageModel extends FlutterFlowModel<HomePageWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;

  // State field(s) for name-signup widget.
  FocusNode? nameSignupFocusNode;
  TextEditingController? nameSignupTextController;
  String? Function(BuildContext, String?)? nameSignupTextControllerValidator;
  // State field(s) for email-sigup widget.
  FocusNode? emailSigupFocusNode;
  TextEditingController? emailSigupTextController;
  String? Function(BuildContext, String?)? emailSigupTextControllerValidator;
  // State field(s) for password-signup widget.
  FocusNode? passwordSignupFocusNode;
  TextEditingController? passwordSignupTextController;
  late bool passwordSignupVisibility;
  String? Function(BuildContext, String?)?
  passwordSignupTextControllerValidator;
  // State field(s) for confirmpass-sup widget.
  FocusNode? confirmpassSupFocusNode;
  TextEditingController? confirmpassSupTextController;
  late bool confirmpassSupVisibility;
  String? Function(BuildContext, String?)?
  confirmpassSupTextControllerValidator;
  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;
  // State field(s) for Email-login widget.
  FocusNode? emailLoginFocusNode;
  TextEditingController? emailLoginTextController;
  String? Function(BuildContext, String?)? emailLoginTextControllerValidator;
  // State field(s) for pass-login widget.
  FocusNode? passLoginFocusNode;
  TextEditingController? passLoginTextController;
  late bool passLoginVisibility;
  String? Function(BuildContext, String?)? passLoginTextControllerValidator;

  @override
  void initState(BuildContext context) {
    passwordSignupVisibility = false;
    confirmpassSupVisibility = false;
    passLoginVisibility = false;
  }

  @override
  void dispose() {
    tabBarController?.dispose();
    nameSignupFocusNode?.dispose();
    nameSignupTextController?.dispose();

    emailSigupFocusNode?.dispose();
    emailSigupTextController?.dispose();

    passwordSignupFocusNode?.dispose();
    passwordSignupTextController?.dispose();

    confirmpassSupFocusNode?.dispose();
    confirmpassSupTextController?.dispose();

    emailLoginFocusNode?.dispose();
    emailLoginTextController?.dispose();

    passLoginFocusNode?.dispose();
    passLoginTextController?.dispose();
  }
}

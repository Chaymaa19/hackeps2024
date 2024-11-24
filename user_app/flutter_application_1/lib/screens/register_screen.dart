import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/constants.dart';
import 'package:flutter_application_1/pages/pages.dart';
import 'package:flutter_application_1/widgets/widgets.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
   bool mobile =
        MediaQuery.of(context).size.width > maxMobileSize ? false : true;
    if (mobile || !kIsWeb) {
      return Scaffold(
        appBar: const CustomAppBar(title: "Register"),
        drawer: customDrawer(context),
        body: ListView(
          children: [RegisterPage()],
        ),
      );
    } else {
      return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: const CustomAppBar(title: "Register"),
          drawer: customDrawer(context),
          body: RegisterPage());
    }
  }
}

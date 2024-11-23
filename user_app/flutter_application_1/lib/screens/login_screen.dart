import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/constants.dart';
import 'package:flutter_application_1/config/aut_service.dart';
import 'package:flutter_application_1/pages/pages.dart';
import 'package:flutter_application_1/widgets/widgets.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
   bool mobile =
        MediaQuery.of(context).size.width > maxMobileSize ? false : true;
    if (mobile || !kIsWeb) {
      return Scaffold(
        appBar: const CustomAppBar(title: "Login"),
        drawer: customDrawer(context),
        body: ListView(
          children: [LoginPage()],
        ),
      );
    } else {
      return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: const CustomAppBar(title: "Login"),
          drawer: customDrawer(context),
          body: LoginPage());
    }
  }
}

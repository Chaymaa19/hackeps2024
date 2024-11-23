import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/constants.dart';
import 'package:flutter_application_1/config/aut_service.dart';
import 'package:flutter_application_1/pages/pages.dart';
import 'package:flutter_application_1/widgets/widgets.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthService.isLoggedIn();
    if (!isLoggedIn) {
      context.go("/login");
    }

    bool mobile =
        MediaQuery.of(context).size.width > maxMobileSize ? false : true;
    if (mobile || !kIsWeb) {
      return Scaffold(
        appBar: const CustomAppBar(title: "Home"),
        drawer: customDrawer(context),
        body: ListView(
          children: [HomePageMobile()],
        ),
      );
    } else {
      return Scaffold(
          appBar: const CustomAppBar(title: "Home"),
          drawer: customDrawer(context),
          body: HomePage(),
      );
    }
  }
}

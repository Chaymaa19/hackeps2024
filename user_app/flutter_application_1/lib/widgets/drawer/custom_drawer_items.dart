import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/constants.dart';
import 'package:go_router/go_router.dart';

Widget drawerItems(BuildContext context) {
  bool isMobile =
      MediaQuery.of(context).size.width > maxMobileSize ? false : true;
  return Wrap(
    children: [
      ListTile(
          leading: const Icon(
            Icons.home_outlined,
            color: Colors.white,
          ),
          title: const Text(
            "Home",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          onTap: () {
            context.pop();
            context.go('/');
            context.push('/');
          }),
    ],
  );
}

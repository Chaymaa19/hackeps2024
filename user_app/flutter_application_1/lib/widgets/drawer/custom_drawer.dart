import 'package:flutter/material.dart';
import 'custom_drawer_header.dart';
import 'custom_drawer_items.dart';

Widget customDrawer(BuildContext context) {
  return Drawer(
    backgroundColor: Colors.black,
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          drawerHeader(context),
          drawerItems(context),
        ],
      ),
    ),
  );
}

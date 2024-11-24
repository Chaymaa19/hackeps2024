import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Widget drawerHeader(BuildContext context) {
    String text = "Sign In";
    bool isMobile = MediaQuery.of(context).size.width > 700 ? false : true;
    return Material(
        color: Colors.blue,
        child: InkWell(
            onTap: () {
              // TODO: go to profile
            },
            child: Container(
              padding: EdgeInsets.only(
                top: 24 + MediaQuery.of(context).padding.top,
                bottom: 24,
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 52,
                    backgroundColor: Colors.black,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            )));
}
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/constants.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  const CustomAppBar({super.key, required this.title});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(appBArHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    bool mobile =
        MediaQuery.of(context).size.width > maxMobileSize ? false : true;
    return AppBar(
      automaticallyImplyLeading: mobile ? true : false,
      leading: mobile || !kIsWeb
          ? Builder(builder: (context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
              );
            })
          : null,
      title: mobile || !kIsWeb
          ? Row(
              children: [
                Image.asset(
                  "assets/images/logopaeria-color.png",
                  width: 65,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            )
          : Row(children: [
              InkWell(
                onTap: () {
                  context.go('/');
                  context.push('/');
                },
                child: Image.asset(
                  'assets/images/logopaeria-color.png',
                  width: 65,
                ), 
              ),
              const SizedBox(width: 16),
              Align(
                  alignment: Alignment.center,
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
            ]),
      backgroundColor: Colors.blue,
      elevation: 0,
      centerTitle: false,
    );
  }
}

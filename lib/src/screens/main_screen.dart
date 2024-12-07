import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hot_diamond_admin/src/screens/add_items/add_items.dart';
import 'package:hot_diamond_admin/src/screens/home/home_screen.dart';
import 'package:hot_diamond_admin/src/screens/list_of_items/list_of_items.dart';
import 'package:hot_diamond_admin/src/screens/notifications/notification_screen.dart';
import 'package:hot_diamond_admin/src/screens/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  static List<Widget> screens = [
    const HomeScreen(),
    const ListOfItems(),
    const AddItemScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  static const List<String> listOfStrings = [
    'Home',
    'items',
    'Add Item',
    'Notifications',
    'Profile',
  ];

  static const List<IconData> listOfIcons = [
    Icons.home_sharp,
    Icons.menu,
    Icons.add,
    Icons.notifications,
    Icons.account_circle_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final double displayWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
        height: displayWidth * 0.16,
        margin: EdgeInsets.symmetric(
          horizontal: displayWidth * 0.04,
          vertical: displayWidth * 0.03,
        ),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: listOfIcons.length,
          itemBuilder: (context, index) {
            final isSelected = index == currentIndex;
            return GestureDetector(
              onTap: () {
                setState(() {
                  currentIndex = index;
                  HapticFeedback.lightImpact();
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: isSelected ? displayWidth * 0.36 : displayWidth * 0.11,
                  margin: EdgeInsets.symmetric(horizontal: displayWidth * 0.002),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        listOfIcons[index],
                        color: isSelected ? Colors.black : Colors.white,
                        size: displayWidth * 0.05,
                      ),
                      if (isSelected)
                        Flexible( // Wrap Text with Flexible
                          child: Padding(
                            padding: EdgeInsets.only(left: displayWidth * 0.02),
                            child: Text(
                              listOfStrings[index],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontSize: displayWidth * 0.04,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

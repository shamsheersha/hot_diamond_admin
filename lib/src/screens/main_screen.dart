
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hot_diamond_admin/src/screens/add_items/add_items.dart';
import 'package:hot_diamond_admin/src/screens/home/home_screen.dart';
import 'package:hot_diamond_admin/src/screens/list_of_items/list_of_items.dart';
import 'package:hot_diamond_admin/src/screens/profile/settings_screen.dart';
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
    const SettingsScreen(),
  ];

  static const List<String> listOfStrings = [
    'Home',
    'Items',
    'Add Item',
    'Settings',
  ];

  static const List<IconData> listOfIcons = [
    Icons.home_sharp,
    Icons.menu,
    Icons.add,
    Icons.settings,
  ];

  bool get isWeb => MediaQuery.of(context).size.width > 600;

  @override
  Widget build(BuildContext context) {
    final double displayWidth = MediaQuery.of(context).size.width;
    
    final double navBarHeight = isWeb ? 60 : displayWidth * 0.15;
    final double verticalMargin = isWeb ? 12 : displayWidth * 0.03;

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: Container(
        height: navBarHeight,
        margin: EdgeInsets.symmetric(
          horizontal: displayWidth * 0.04,
          vertical: verticalMargin,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            listOfIcons.length,
            (index) {
              final isSelected = index == currentIndex;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    currentIndex = index;
                    HapticFeedback.lightImpact();
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: isWeb ? 16 : displayWidth * 0.03,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        listOfIcons[index],
                        color: isSelected ? Colors.black : Colors.white,
                        size: isWeb ? 24 : displayWidth * 0.05,
                      ),
                      if (isSelected) ...[
                        SizedBox(width: isWeb ? 8 : displayWidth * 0.02),
                        Text(
                          listOfStrings[index],
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: isWeb ? 16 : displayWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
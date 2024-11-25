import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/splash/splash_bloc.dart';
import 'package:hot_diamond_admin/src/screens/login/login_screen.dart';
import 'package:hot_diamond_admin/src/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState() {
    super.initState();
    _checkLogged();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: BlocBuilder<SplashBloc, SplashState>(
          builder: (context, state) {
            return AnimatedOpacity(
              opacity: state.opacity,
              duration: const Duration(seconds: 3),
              child: Image.asset(
                  'assets/840ccc14-b0e1-4ec2-8b65-3332ab05c32b_page-0003.png'),
            );
          },
        ),
      ),
    );
  }

  _checkLogged() async {
    final prefs = await SharedPreferences.getInstance();
    final isLOggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLOggedIn) {
      Future.delayed(const Duration(seconds: 3),(){
        if(mounted){
          Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()));
        }
      });
      
    } else{
      Future.delayed(const Duration(seconds: 3),(){
        if(mounted){
          Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()));
        }
      });
    }
  }
}

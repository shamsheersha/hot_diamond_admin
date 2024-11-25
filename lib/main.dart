import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/login/login_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/splash/splash_bloc.dart';
import 'package:hot_diamond_admin/src/screens/splash/splash.dart';

void main() {
   WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SplashBloc()..add(StartSplash()),
          ),
          BlocProvider(
            create: (context) => LoginBloc(),
          )
        ],
        child: MaterialApp(
          title: 'HOT_DIAMOND_ADMIN',
          theme: ThemeData(
              primaryColor: Colors.red,
              appBarTheme: const AppBarTheme(color: Colors.white,),
              scaffoldBackgroundColor: Colors.white),
          debugShowCheckedModeBanner: false,
          
          home: const Splash(),
        ));
  }
}

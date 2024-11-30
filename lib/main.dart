import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hot_diamond_admin/src/controllers/category/category_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/category/category_event.dart';
import 'package:hot_diamond_admin/src/controllers/category/category_state.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/item/item_event.dart';
import 'package:hot_diamond_admin/src/controllers/login/login_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/splash/splash_bloc.dart';
import 'package:hot_diamond_admin/src/screens/splash/splash.dart';
import 'package:hot_diamond_admin/src/services/firebase_category_service/firebase_category_service.dart';
import 'package:hot_diamond_admin/src/services/firebase_item_service/firebase_item_service.dart';
import 'package:hot_diamond_admin/src/services/image_cloudinary_service/image_cloudinary_service.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ImageCloudinaryService imageCloudinaryService = ImageCloudinaryService();
    final FirebaseItemService firebaseItemService = FirebaseItemService();
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SplashBloc()..add(StartSplash()),
          ),
          BlocProvider(
            create: (context) => LoginBloc(),
          ),
          BlocProvider(
            create: (context) => CategoryBloc(FirebaseCategoryService())..add(FetchCategories()),
          ),
          BlocProvider(
            create: (context) => ItemBloc(imageCloudinaryService,firebaseItemService)..add(FetchItemsEvent()),
          )
        ],
        child: MaterialApp(
          title: 'HOT_DIAMOND_ADMIN',
          theme: ThemeData(
              primaryColor: Colors.red,
              appBarTheme: const AppBarTheme(
                color: Colors.transparent,
              ),
              textSelectionTheme: TextSelectionThemeData(selectionHandleColor: Colors.black,),
              scaffoldBackgroundColor: Colors.grey[100]),
          debugShowCheckedModeBanner: false,
          home: const Splash(),
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:news_blog/constants/theme_provider.dart';
import 'package:news_blog/screens/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
       providers: [
        ChangeNotifierProvider<ThemeProvider>(
            create: ((context) => ThemeProvider())),
      ],
      child: FutureBuilder(
          future: Firebase.initializeApp(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.done) {
              final themeProvider = Provider.of<ThemeProvider>(context);
    
              return ScreenUtilInit(
                minTextAdapt: true,
                splitScreenMode: true,
                builder: (_) =>
               GetMaterialApp(
                  theme: MyThemes.lightTheme,
                  themeMode: themeProvider.themeMode!,
                  darkTheme: MyThemes.darkTheme,
                  debugShowCheckedModeBanner: false,
                  title: 'News App',
                  
                  home: const HomePage(),
                ),
              );
            }
    
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child:  CircularProgressIndicator(),
                ),
              ),
            ); //Show circularProgress
          }),
    );
  }
}



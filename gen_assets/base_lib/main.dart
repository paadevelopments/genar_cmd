import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';
import 'home_vw.dart';

void main() {
  var mySystemTheme = SystemUiOverlayStyle.light.copyWith(
    systemNavigationBarColor: colorPrimary,
  );
  SystemChrome.setSystemUIOverlayStyle(mySystemTheme);
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {

  const MyApp({ super.key });

  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage(splashIcon), context);
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: colorPrimary,),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

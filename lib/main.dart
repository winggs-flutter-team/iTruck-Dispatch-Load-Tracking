import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/frebase_dynamic_link.dart';
import 'package:itruck_dispatch/providers/all_companies_provider.dart';
import 'package:itruck_dispatch/providers/all_users_provider.dart';
import 'package:itruck_dispatch/providers/dispatcher_loads_provider.dart';
import 'package:flutter/services.dart';
import 'package:itruck_dispatch/push_notifications_services.dart';
import 'package:itruck_dispatch/views/widgets/disclouser_screen.dart';
import 'package:itruck_dispatch/views/widgets/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'views/dispatcher/widgets/pickup_details_form.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: kPrimaryColor, statusBarIconBrightness: Brightness.dark));
  await Firebase.initializeApp();
  await PushNotificationService().setupInteractedMessage();
  runApp(riverpod.ProviderScope(child: MyApp()));

  RemoteMessage? initialMessage =
      (await FirebaseMessaging.instance.getInitialMessage());
  if (initialMessage != null) {
    // App received a notification when it was killed
    // AppToForeground.appToForeground();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'iTruck',
          theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            primaryColor: kPrimaryColor,
            scaffoldBackgroundColor: Colors.grey.shade100,
          ),
          home: const SplashScreen(),
        );
      },
      providers: [
        ChangeNotifierProvider<AllUserProvider>(
            create: (_) => AllUserProvider()),
        ChangeNotifierProvider<AllCompaniesProvider>(
            create: (_) => AllCompaniesProvider()),
        ChangeNotifierProvider<DispatcherLoadsProvider>(
            create: (_) => DispatcherLoadsProvider()),
      ],
    );
  }
}

import 'package:bizbook/backend/auth.dart';
import 'package:bizbook/cus_page/cus_dashboard.dart';
import 'package:bizbook/firebase_options.dart';
import 'package:bizbook/pages/dashboard.dart';
import 'package:bizbook/pages/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  late bool isAuth = false;
  final prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('customerId') && prefs.containsKey('customerName')) {
    isAuth = true;
  }
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthService()..checkAuthStatus(),
      child: MyApp(
        isAuth: isAuth,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isAuth;
  const MyApp({super.key, required this.isAuth});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return MaterialApp(
        title: 'BiZBook',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: (authService.isAuthenticated)
            ? const Dashboard()
            : isAuth
                ? CusDashboard()
                : LoginPage());
  }
}

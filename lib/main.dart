import 'package:flutter/material.dart';
import 'package:wannabet/pages/home.dart';
import 'package:wannabet/intro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wannabet/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables before Firebase initialization
  await dotenv.load(fileName: ".env");
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  Hive.registerAdapter(UserObjectAdapter());
  await Hive.openBox<UserObject>('userBox');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Used to be Color(0xFFFEF8FF)
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // Used to be Color(0xFFFEF8FF)
          elevation: 0,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.white, // Used to be Color(0xFFFEF8FF)
          elevation: 0,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasData) {
            return HomePage();
          } else {
            return IntroPage();
          }
        },
      ),
    );
  }
}

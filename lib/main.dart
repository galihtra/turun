// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turun/data/providers/running/running_provider.dart';
import 'package:turun/data/services/auth_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:turun/data/wrapper/auth_wrapper.dart';
import 'package:turun/resources/colors_app.dart';

import 'data/providers/user/user_provider.dart';
import 'pages/running/run_share_screen_demo.dart'; // Demo for testing                                                    

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  String supabaseKey = dotenv.env['SUPABASE_KEY'] ?? '';
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [  
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RunningProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'TuRun',
            theme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: AppColors.backgroundColor,
            ),
            // TEMPORARY: Change to RunShareScreenDemo for testing
            // home: child,
            home: child,
          );
        },
        child: const AuthWrapper(),
      ),
    );
  }
}
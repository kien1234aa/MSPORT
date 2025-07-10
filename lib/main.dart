import 'package:flutter/material.dart';
import 'package:msport/routers/app_router.dart';
import 'package:msport/untils/AppLaunchChecker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: "https://aejmidrpergglildqomq.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFlam1pZHJwZXJnZ2xpbGRxb21xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk2Mzc0ODMsImV4cCI6MjA2NTIxMzQ4M30.sbPFjcJjRahLqr-lh0Gk9ksIBHRSwXuV0Od5KeM4xlc",
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AppLaunchChecker.isFirstLaunch(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        final isFirstLaunch = snapshot.data!;
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter(isFirstLaunch: isFirstLaunch),
        );
      },
    );
  }
}

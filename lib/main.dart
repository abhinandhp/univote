import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/auth/authgateway.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://zpnuuitlfymfcljtzzyw.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpwbnV1aXRsZnltZmNsanR6enl3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzNzcyMTAsImV4cCI6MjA1Nzk1MzIxMH0.NcbQljzfWqKegyLMVbdi0dKnxTzebMfSOLwMPGMZD7o",
    realtimeClientOptions: RealtimeClientOptions(
      timeout: Duration(seconds: 10),
    ),
  );
  debugDefaultTargetPlatformOverride = TargetPlatform.android;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: AuthGate());
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/auth/authgateway.dart';
import 'package:univote/pages/admin/adminDash.dart';
import 'package:univote/pages/admin/adminhome.dart';
import 'package:univote/pages/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://zpnuuitlfymfcljtzzyw.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpwbnV1aXRsZnltZmNsanR6enl3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzNzcyMTAsImV4cCI6MjA1Nzk1MzIxMH0.NcbQljzfWqKegyLMVbdi0dKnxTzebMfSOLwMPGMZD7o",
    realtimeClientOptions: RealtimeClientOptions(timeout: Duration(seconds: 10))
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: AdminHome());
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/mock_backend.dart';
import 'ui/voice_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MockBackendService()),
      ],
      child: MaterialApp(
        title: 'Grok Voice Assistant',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const VoiceScreen(),
        },
      ),
    );
  }
}

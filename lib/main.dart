import 'package:flutter/material.dart';

import './pages/generator_page.dart';
import './pages/scanner_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const AqrApp());
}

class AqrApp extends StatelessWidget {
  const AqrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      darkTheme: ThemeData(
        appBarTheme: const AppBarTheme(centerTitle: true),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
      ),
      theme: ThemeData(
        appBarTheme: const AppBarTheme(centerTitle: true),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
      ),
      themeMode: ThemeMode.system,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [const ScannerPage(), const GeneratorPage()];
    return Scaffold(
      body: SafeArea(child: pages[currentPageIndex]),
      bottomNavigationBar: NavigationBar(
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scanner',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code),
            label: 'Generator',
          ),
        ],
        onDestinationSelected: (value) {
          setState(() {
            currentPageIndex = value;
          });
        },
        selectedIndex: currentPageIndex,
      ),
    );
  }
}

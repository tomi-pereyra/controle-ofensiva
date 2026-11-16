import 'package:flutter/material.dart';
import 'controllers/streak_controller.dart';
import 'services/storage_service.dart';
import 'views/home_screen.dart';
import 'views/rewards_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  final streakController = StreakController(storageService);
  await streakController.initialize();

  runApp(StreakApp(controller: streakController));
}

class StreakApp extends StatelessWidget {
  final StreakController controller;

  const StreakApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ofensiva',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFFFF5400),
        scaffoldBackgroundColor: const Color(0xFFFCFCFD),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFCFCFD),
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFFFF5400),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
        ),
      ),
      home: MainNavigation(controller: controller),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final StreakController controller;

  const MainNavigation({super.key, required this.controller});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Quando o app volta do background (ex: no dia seguinte), revalida a ofensiva
    if (state == AppLifecycleState.resumed) {
      widget.controller.refreshStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(controller: widget.controller),
      RewardsScreen(controller: widget.controller),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.local_fire_department_outlined),
            selectedIcon: Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF5400)),
            label: 'Ofensiva',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events_rounded, color: Color(0xFFFF5400)),
            label: 'Recompensas',
          ),
        ],
      ),
    );
  }
}

// lib/main.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:stockstalk/src/repositories/favorites_repository.dart';
import 'package:stockstalk/src/repositories/stock_repository.dart';
import 'package:stockstalk/src/services/stock_service.dart';
import 'package:stockstalk/src/view_models/favorites_view_model.dart';
import 'package:stockstalk/src/view_models/home_view_model.dart';
import 'package:stockstalk/src/view_models/search_view_model.dart';
import 'firebase_options.dart';
import 'src/views/widgets/bottom_nav_bar.dart';
import 'src/views/pages/home_page.dart';
import 'src/views/pages/favorites_page.dart';
import 'src/views/pages/search_page.dart';
import 'src/views/pages/profile_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firebase Database 초기화
  FirebaseDatabase.instance.setPersistenceEnabled(true); // 오프라인 지원을 위한 설정

  await dotenv.load(fileName: ".env");

  // StockService와 Repository 인스턴스 생성
  final stockService = StockService();
  final stockRepository = StockRepositoryImpl(stockService);
  final favoritesRepository = FirebaseFavoritesRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(stockRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchViewModel(stockRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesViewModel(favoritesRepository),
        ),
      ],
      child: const StockstalkApp(),
    ),
  );
}

class StockstalkApp extends StatelessWidget {
  const StockstalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stockstalk',
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const FavoritesPage(),
    const SearchPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

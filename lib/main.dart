import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:photo_manager/photo_manager.dart';

import 'state/indexing_state.dart';
import 'state/search_state.dart';
import 'ui/gallery/gallery_screen.dart';
import 'ui/search/search_screen.dart';
import 'ui/people/people_screen.dart';
import 'ui/tags/tags_screen.dart';
import 'services/indexing_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize background work dispatcher
  await Workmanager().initialize(IndexingService.callbackDispatcher);
  // Ensure photo_manager performs permission checks (Android 13+/iOS limited access)
  PhotoManager.setIgnorePermissionCheck(false);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IndexingState()),
        ChangeNotifierProvider(create: (_) => SearchState()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  final _pages = const [
    GalleryScreen(),
    SearchScreen(),
    PeopleScreen(),
    TagsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.photo), label: 'Gallery'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.people), label: 'People'),
          NavigationDestination(icon: Icon(Icons.label), label: 'Tags'),
        ],
        onDestinationSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}

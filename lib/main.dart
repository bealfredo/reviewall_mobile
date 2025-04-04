import 'package:flutter/material.dart';
import 'package:reviewall_mobile/resenha_app.dart';

void main() {
  runApp(NavigationBarApp());
}


// Navigation

class NavigationBarApp extends StatelessWidget {
  const NavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: ThemeData(useMaterial3: true), home: const NavigationExample());
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.redAccent,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          // NavigationDestination(
          //   selectedIcon: Icon(Icons.home),
          //   icon: Icon(Icons.home_outlined),
          //   label: 'Home',
          // ),
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Badge(child: Icon(Icons.photo)),
            label: 'Mídias',
          ),


          NavigationDestination(
            icon: Badge(child: Icon(Icons.star)),
            label: 'Resenhas de filmes',
          ),

          NavigationDestination(
            icon: Badge(child: Icon(Icons.add)),
            label: 'Add'
          ),
        ],
      ),
      body:
          <Widget>[
            /// Home page
            Card(
              shadowColor: Colors.transparent,
              margin: const EdgeInsets.all(8.0),
              child: SizedBox.expand(
                child: Center(child: Text('Another page', style: theme.textTheme.titleLarge)),
              ),
            ),

            /// Mídias page
            MediaListScaffold(),

            /// Resenhas de filmes page
            ReviewApp(),

            /// Add page
            FormularioAddResenhaScaffold()
          ][currentPageIndex],
    );
  }
}
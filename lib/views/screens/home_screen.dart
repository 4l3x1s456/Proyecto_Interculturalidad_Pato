import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import 'camera_screen.dart';
import 'cultures_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  bool _progressLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_progressLoaded) {
      _progressLoaded = true;
      // Sincroniza el progreso del usuario (Firestore) tras iniciar sesion.
      AppScope.of(context).progress.startSync();
    }
  }

  @override
  Widget build(BuildContext context) {
    const titles = ['Culturas', 'Camara', 'Perfil'];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_index])),
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() => _index = value);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.public), label: 'Culturas'),
          NavigationDestination(icon: Icon(Icons.camera_alt), label: 'Camara'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_index) {
      case 1:
        return const CameraScreen();
      case 2:
        return const ProfileScreen();
      case 0:
      default:
        return const CulturesScreen();
    }
  }
}

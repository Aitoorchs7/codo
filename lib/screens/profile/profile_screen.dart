import 'package:codo/admins/auth_service.dart';
import 'package:codo/app/app_routes.dart';
import 'package:codo/models/profile.dart';
import 'package:codo/repositories/profile_repository.dart';
import 'package:codo/screens/profile/medal_grid.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Profile?> _profile;

  @override
  void initState() {
    super.initState();
    _profile = _load();
  }

  Future<Profile?> _load() async {
    final user = await AuthService().currentUser();
    if (user == null) return null;
    return ProfileRepository().getProfile(user.uid);
  }

  Future<void> _signOut() async {
    await AuthService().signOut();
    if (!mounted) return;
    // Vacía la pila: atrás no vuelve al inicio con la sesión cerrada.
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<Profile?>(
              future: _profile,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('No se pudo cargar tu perfil.'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            _profile = _load();
                          });
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  );
                }
                final profile = snapshot.data;
                if (profile == null) {
                  return const Text('Todavía no tienes perfil.');
                }
                return Text(
                  'Hola, ${profile.displayName}',
                  style: textTheme.headlineMedium,
                );
              },
            ),
          ),
          const Expanded(child: MedalGrid()),
          const SizedBox(height: 12),
          FilledButton(onPressed: _signOut, child: const Text('Cerrar sesión')),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

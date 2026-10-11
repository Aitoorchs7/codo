import 'package:codo/admins/auth_service.dart';
import 'package:codo/app/app_routes.dart';
import 'package:flutter/material.dart';

// Pantalla provisional hasta tener la barra inferior.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () async {
            await AuthService().signOut();
            if (!context.mounted) return;
            // Vacía la pila: atrás no vuelve al inicio con la sesión cerrada.
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
                  (route) => false,
            );
          },
          child: const Text('Cerrar sesión'),
        ),
      ),
    );
  }
}
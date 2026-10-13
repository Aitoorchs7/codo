
import 'package:flutter/material.dart';

class CodoNavBar extends StatelessWidget{
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const CodoNavBar({super.key, required this.selectedIndex, required this.onSelected});


  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      destinations:const[
        NavigationDestination(icon: Icon(Icons.today), label: 'Hoy'),
        NavigationDestination(icon: Icon(Icons.bolt), label: 'Ahora'),
        NavigationDestination(icon: Icon(Icons.handshake), label: 'Pacto'),
        NavigationDestination(icon: Icon(Icons.group), label: 'Amigos'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
      ]
    );
  }
}



import 'package:codo/app/app_routes.dart';
import 'package:codo/models/live_session.dart';
import 'package:codo/repositories/live_session_repository.dart';
import 'package:codo/screens/profile/session_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SessionsMapScreen extends StatefulWidget{
  const SessionsMapScreen({super.key});

  @override
  State<SessionsMapScreen> createState() => _SessionsMapScreenState();
}

class _SessionsMapScreenState extends State<SessionsMapScreen> {
  final _repository = LiveSessionRepository();
  // Se crea una sola vez: si fuera dentro de build, cada repintado abriría otra suscripción
  late final Stream<List<LiveSession>> _sessions =
  _repository.watchRecentPublic(limit: 50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
      body: StreamBuilder<List<LiveSession>>(
        stream: _sessions,
        builder: (context, snapshot) {
          // Solo las que tienen ubicación: la ubicación es opcional
          final located = (snapshot.data ?? const <LiveSession>[])
              .where((s) => s.latitude != null && s.longitude != null);
          return Stack(children: [
            FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(40.42, -3.70),
                // Madrid, provisional hasta el paso 3
                initialZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'codo.com.codo', // lo exige la política de OSM
                ),
                MarkerLayer(markers: [
                  for (final s in located)
                    Marker(
                      point: LatLng(s.latitude!, s.longitude!),
                      width: 48,
                      height: 48,
                      child: IconButton(
                        icon: const Icon(Icons.location_on),
                        color: Theme.of(context).colorScheme.primary,
                        tooltip: s.description,
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.sessionDetail,
                          arguments: SessionDetailArgs(session: s),
                        ),
                      ),
                    ),
                ]),
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('OpenStreetMap contributors'),
                  ],
                ),
              ], // fin de las capas del mapa
            ), // fin de FlutterMap
            // Encima del mapa, como hermanos suyos en el Stack
            if (snapshot.connectionState == ConnectionState.waiting)
              const LinearProgressIndicator(),
            if (snapshot.hasError)
              const Card(
                child: ListTile(title: Text('No se pudieron cargar las sesiones')),
              ),
          ]); // fin de la lista del Stack, del Stack y del return
        },
      )
    );
  }
}
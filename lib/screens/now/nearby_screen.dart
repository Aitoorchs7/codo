
import 'package:codo/app/app_routes.dart';
import 'package:codo/models/live_session.dart';
import 'package:codo/screens/now/session_labels.dart';
import 'package:codo/screens/profile/session_detail_screen.dart';
import 'package:codo/utils/nearby_isolate.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

// Lo que el mapa le pasa a esta pantalla por la ruta
class NearbyArgs {
  const NearbyArgs({required this.me, required this.sessions});
  final LatLng me;
  final List<LiveSession> sessions; // ya filtradas: todas tienen ubicación
}
class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key, required this.me, required this.sessions});
  final LatLng me;
  final List<LiveSession> sessions;
  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  final _sorter = NearbySorter();

  double _progress = 0;

  List<Nearby>? _order;
  var _failed = false;

  @override
  void initState() {
    super.initState();
    _sort();
  }

  Future<void> _sort() async {
    setState(() { _failed = false; _order = null; _progress = 0; });
    // De cada sesión solo viaja al isolate su coordenada
    final points = [
      for (final s in widget.sessions) LatLng(s.latitude!, s.longitude!),
    ];
    try {
      final watch = Stopwatch()..start();// para medir el tiempo
      final order = await _sorter.sort(
        widget.me,
        points,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      debugPrint('Cerca de mí ${points.length} sesiones en ${watch.elapsedMilliseconds} ms');
      if (!mounted) return;
      setState(() => _order = order);
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }
  // «≈» porque las posiciones guardadas están redondeadas a ~1 km
  String _formatDistance(double m) => m < 1000
      ? '≈ ${m.round()} m'
      : '≈ ${(m / 1000).toStringAsFixed(1)} km';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cerca de mí')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 1. Error
    if (_failed) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No se pudo calcular la distancia'),
            TextButton(onPressed: _sort, child: const Text('Reintentar')),
          ],
        ),
      );
    }
    // 2. Cargando: la barra muestra el avance real que manda el isolate
    final order = _order;
    if (order == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(value: _progress),
            const SizedBox(height: 8),
            Text('Calculando distancias… ${(_progress * 100).round()} %'),
          ],
        ),
      );
    }
    // 3. Vacío
    if (order.isEmpty) {
      return const Center(child: Text('Nadie cerca ha compartido su ubicación'));
    }
    // 4. Datos: una fila por sesión, de la más cercana a la más lejana
    return ListView.builder(
      itemCount: order.length,
      itemBuilder: (context, i) {
        final (index, meters) = order[i];  // desestructura el record
        final s = widget.sessions[index];  // el índice apunta a la sesión original
        return ListTile(
          title: Text(s.description),
          subtitle: Text('${categoryLabel(s.category)} · ${s.creatorName}'),
          trailing: Text(_formatDistance(meters)),
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.sessionDetail,
            arguments: SessionDetailArgs(session: s),
          ),
        );
      },
    );
  }
}
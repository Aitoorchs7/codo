import 'package:codo/admins/weather_failure.dart';
import 'package:codo/repositories/weather_repository.dart';
import 'package:codo/utils/net_log.dart';
import 'package:codo/utils/request_pool.dart';
import 'package:flutter/material.dart';

// Pantalla de pruebas de AI2 (PSP): no sale en la versión release.
// Los textos van sin localizar a propósito: es una herramienta de desarrollo.
class NetLabScreen extends StatefulWidget {
  const NetLabScreen({super.key});

  @override
  State<NetLabScreen> createState() => _NetLabScreenState();
}

class _NetLabScreenState extends State<NetLabScreen>
    with SingleTickerProviderStateMixin {
  final _repository = WeatherRepository();

  // La rueda gira sin parar: si el hilo principal se bloquea, se ve cómo se para
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  // Mayor hueco entre dos fotogramas mientras se carga (a 60 Hz lo normal son ~16 ms)
  final _frameClock = Stopwatch()..start();
  int _lastTick = 0;
  int _maxGap = 0;
  bool _measuring = false;

  DecodeMode _mode = DecodeMode.mainThread;
  double _years = 10;
  bool _loading = false;
  WeatherError? _error;
  DecodeReport? _report;

  // Bloque 2: pool de K peticiones
  bool _injectFailures = false;
  bool _poolRunning = false;
  final List<PoolReport> _bench = [];
  Map<RequestState, int> _counts = {};

  // Mismas 32 peticiones con K = 1, 4, 8 y 16, una pasada detrás de otra
  Future<void> _runBench() async {
    setState(() {
      _poolRunning = true;
      _bench.clear();
    });
    try {
      for (final k in const [1, 4, 8, 16]) {
        final report = await _repository.loadGrid(
          k: k,
          failEvery: _injectFailures ? 5 : null,
          onChange: _onPoolChange,
        );
        if (!mounted) return;
        setState(() => _bench.add(report));
      }
    } finally {
      if (mounted) setState(() => _poolRunning = false);
    }
  }

  // Cuenta cuántas peticiones hay en cada estado cada vez que una cambia
  void _onPoolChange(List<PoolTask<double>> tasks) {
    if (!mounted) return;
    setState(() {
      _counts = {
        for (final s in RequestState.values)
          s: tasks.where((t) => t.state == s).length,
      };
    });
  }

  @override
  void initState() {
    super.initState();
    _spin.addListener(_onTick);
  }

  void _onTick() {
    final now = _frameClock.elapsedMilliseconds;
    if (_measuring && now - _lastTick > _maxGap) _maxGap = now - _lastTick;
    _lastTick = now;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _report = null;
    });
    _maxGap = 0;
    _measuring = true;
    try {
      // Coordenadas genéricas (centro de Madrid): ningún dato personal
      final report = await _repository.measureArchive(
        lat: 40.42,
        lon: -3.70,
        years: _years.round(),
        mode: _mode,
      );
      if (!mounted) return;
      setState(() => _report = report);
    } on WeatherFailure catch (e) {
      if (!mounted) return; // si se cerró la pantalla (cancelled), no se pinta nada
      setState(() => _error = e.error);
    } finally {
      // Si el bloqueo acaba justo antes de este punto, el hueco se ve en el SIGUIENTE
      // fotograma: hay que esperarlo antes de dejar de medir
      await WidgetsBinding.instance.endOfFrame;
      _measuring = false;
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    _repository.dispose(); // mata el isolate si sigue vivo y cierra el cliente HTTP
    super.dispose();
  }

  String _errorText(WeatherError e) => switch (e) {
        WeatherError.timeout => 'La red tarda demasiado. Reintenta.',
        WeatherError.noConnection => 'Sin conexión. Revisa la red y reintenta.',
        WeatherError.server => 'El servidor ha fallado. Reintenta en un rato.',
        WeatherError.badData => 'La respuesta no tiene el formato esperado.',
        WeatherError.cancelled => 'Cancelado.',
      };

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final report = _report;
    return Scaffold(
      appBar: AppBar(title: const Text('Laboratorio de red')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: RotationTransition(
              turns: _spin,
              child: Icon(
                Icons.autorenew,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
                semanticLabel: 'Animación de prueba',
              ),
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<DecodeMode>(
            segments: const [
              ButtonSegment(value: DecodeMode.mainThread, label: Text('Principal')),
              ButtonSegment(value: DecodeMode.isolateRun, label: Text('Isolate.run')),
              ButtonSegment(value: DecodeMode.cancellable, label: Text('Cancelable')),
            ],
            selected: {_mode},
            onSelectionChanged: _loading ? null : (s) => setState(() => _mode = s.first),
          ),
          const SizedBox(height: 8),
          Text('Años de datos: ${_years.round()}', style: text.bodyMedium),
          Slider(
            value: _years,
            min: 1,
            max: 20,
            divisions: 19,
            label: '${_years.round()}',
            onChanged: _loading ? null : (v) => setState(() => _years = v),
          ),
          FilledButton(
            onPressed: _loading ? null : _load,
            child: Text(_loading ? 'Cargando…' : 'Cargar y medir'),
          ),
          const SizedBox(height: 16),
          if (_error != null) ...[
            Text(_errorText(_error!), style: text.bodyLarge),
            TextButton(onPressed: _load, child: const Text('Reintentar')),
          ],
          if (report != null)
            Text(
              'Modo: ${report.mode.name}\n'
              'Tamaño: ${(report.bytes / 1024 / 1024).toStringAsFixed(2)} MB\n'
              'Red (await): ${report.netMs} ms\n'
              'jsonDecode en hilo principal: '
              '${report.decodeMs < 0 ? '—' : '${report.decodeMs} ms'}\n'
              'Decodificar + resumir: ${report.workMs} ms\n'
              'Mayor hueco entre fotogramas: $_maxGap ms\n'
              '${report.summary.hours} h · media ${report.summary.avgTemp.toStringAsFixed(1)} °C'
              ' · máx ${report.summary.maxTemp.toStringAsFixed(1)} °C'
              ' · lluvia ${report.summary.totalRain.toStringAsFixed(0)} mm',
              style: text.bodyLarge,
            ),
          const Divider(height: 32),
          Text('Bloque 2 · K peticiones a la vez', style: text.titleMedium),
          SwitchListTile(
            title: const Text('Provocar fallos (1 de cada 5 falla la 1.ª vez)'),
            value: _injectFailures,
            onChanged: _poolRunning ? null : (v) => setState(() => _injectFailures = v),
          ),
          FilledButton(
            onPressed: _poolRunning ? null : _runBench,
            child: Text(_poolRunning ? 'Midiendo…' : 'Medir K = 1, 4, 8 y 16'),
          ),
          const SizedBox(height: 8),
          if (_counts.isNotEmpty)
            Text(
              'En cola ${_counts[RequestState.queued]} · '
              'en curso ${_counts[RequestState.running]} · '
              'terminadas ${_counts[RequestState.done]} · '
              'fallidas ${_counts[RequestState.failed]}',
              style: text.bodyLarge,
            ),
          for (final r in _bench)
            Text(
              'K = ${r.k.toString().padLeft(2)} → ${r.totalMs} ms '
              '(${r.done} bien, ${r.failed} fallidas)',
              style: text.bodyLarge,
            ),
          const SizedBox(height: 16),
          Text('Traza', style: text.titleMedium),
          // Las últimas líneas; la traza completa sale también por consola (debugPrint)
          for (final line in NetLog.lines.reversed.take(10))
            Text(line, style: text.bodySmall?.copyWith(fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

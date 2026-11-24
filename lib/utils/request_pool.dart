import 'dart:collection';
import 'dart:math';

import 'package:codo/utils/net_log.dart';

// Estados de una petición (bloque 2 de AI2)
enum RequestState { queued, running, done, failed }

// Una petición dentro del pool: qué hay que hacer y cómo va
class PoolTask<T> {
  PoolTask(this.id, this.run);
  final String id;
  final Future<T> Function() run;

  RequestState state = RequestState.queued;
  int attempts = 0;
  T? result;
}

// Pool de K trabajadores: como mucho K peticiones en curso a la vez.
// Cada trabajador saca una tarea de la cola, la hace (con reintentos) y saca la siguiente.
class RequestPool {
  RequestPool({
    required this.k,
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 200),
    this.shouldRetry = _always,
    this.onChange,
  }) : assert(k > 0);

  final int k;
  final int maxRetries; // reintentos además del primer intento
  final Duration baseDelay; // espera creciente: 200, 400, 800 ms…
  final bool Function(Object error) shouldRetry;
  final void Function()? onChange; // avisa a la pantalla cuando cambia un estado

  static bool _always(Object _) => true;

  Future<List<PoolTask<T>>> runAll<T>(List<PoolTask<T>> tasks) async {
    final queue = Queue.of(tasks);
    for (final t in tasks) {
      NetLog.log(t.id, 'en cola');
    }

    // Un trabajador: mientras quede algo en la cola, lo saca y lo hace.
    // isNotEmpty y removeFirst van seguidos, sin await en medio: en Dart nadie más
    // puede tocar la cola entre las dos líneas, así que no hace falta cerrojo.
    Future<void> worker(int w) async {
      while (queue.isNotEmpty) {
        final task = queue.removeFirst();
        await _runWithRetry(task, w);
      }
    }

    // Se lanzan K trabajadores (o menos, si hay menos tareas) y se espera a todos
    final workers = min(k, tasks.length);
    await Future.wait([for (var w = 1; w <= workers; w++) worker(w)]);
    return tasks;
  }

  Future<void> _runWithRetry<T>(PoolTask<T> task, int w) async {
    while (true) {
      task.attempts++;
      _set(task, RequestState.running, 'en curso (trabajador $w, intento ${task.attempts})');
      try {
        task.result = await task.run();
        _set(task, RequestState.done, 'terminada');
        return;
      } catch (e) {
        final retriesLeft = task.attempts <= maxRetries && shouldRetry(e);
        if (!retriesLeft) {
          _set(task, RequestState.failed, 'fallida tras ${task.attempts} intentos ($e)');
          return;
        }
        // Espera creciente: base · 2^(intento-1). El trabajador espera; los demás siguen.
        final wait = baseDelay * pow(2, task.attempts - 1).toInt();
        _set(task, RequestState.queued,
            'falló ($e); reintento en ${wait.inMilliseconds} ms');
        await Future<void>.delayed(wait);
      }
    }
  }

  void _set(PoolTask task, RequestState state, String message) {
    task.state = state;
    NetLog.log(task.id, message);
    onChange?.call();
  }
}

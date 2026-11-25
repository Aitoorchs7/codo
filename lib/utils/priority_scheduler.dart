import 'dart:async';
import 'dart:collection';

import 'package:codo/utils/net_log.dart';

// Bloque 4 de AI2: lo que pide el usuario va antes que la sincronización de fondo
enum Priority { user, background }

class _Job<T> {
  _Job(this.id, this.priority, this.work);
  final String id;
  final Priority priority;
  final Future<T> Function() work;
  final completer = Completer<T>();
  final waited = Stopwatch()..start(); // cuánto lleva en la cola

  Future<void> run() async {
    try {
      completer.complete(await work());
    } catch (e, s) {
      completer.completeError(e, s);
    }
  }
}

// Cola con dos filas (usuario y fondo) y [slots] peticiones en curso como mucho.
// Regla: con un hueco libre, se atiende primero al usuario.
// Anti-hambre: tras [fairEvery] peticiones de usuario seguidas, si hay alguna de fondo
// esperando, pasa UNA de fondo. Con fairEvery = null no hay regla (el fondo puede no
// ejecutarse nunca si el usuario no para).
class PriorityScheduler {
  PriorityScheduler({this.slots = 1, this.fairEvery = 3})
      : assert(slots > 0),
        assert(fairEvery == null || fairEvery > 0);

  final int slots;
  final int? fairEvery;

  final _user = Queue<_Job>();
  final _background = Queue<_Job>();
  int _running = 0;
  int _userStreak = 0; // peticiones de usuario seguidas desde la última de fondo

  Future<T> submit<T>(String id, Priority priority, Future<T> Function() work) {
    final job = _Job<T>(id, priority, work);
    (priority == Priority.user ? _user : _background).add(job);
    NetLog.log(id, 'encolada (${priority.name}) · '
        'en cola: usuario ${_user.length}, fondo ${_background.length}');
    _pump();
    return job.completer.future;
  }

  // Llena los huecos libres. Sin await: elegir y arrancar va seguido, nadie se cuela
  void _pump() {
    while (_running < slots && (_user.isNotEmpty || _background.isNotEmpty)) {
      final job = _next();
      _running++;
      NetLog.log(job.id, 'EMPIEZA (${job.priority.name}) tras esperar '
          '${job.waited.elapsedMilliseconds} ms · racha usuario $_userStreak');
      job.run().whenComplete(() {
        _running--;
        NetLog.log(job.id, 'termina');
        _pump(); // al quedar un hueco, entra la siguiente
      });
    }
  }

  _Job _next() {
    final limit = fairEvery;
    final backgroundTurn = _background.isNotEmpty &&
        (_user.isEmpty || (limit != null && _userStreak >= limit));
    if (backgroundTurn) {
      _userStreak = 0;
      return _background.removeFirst();
    }
    _userStreak++;
    return _user.removeFirst();
  }
}

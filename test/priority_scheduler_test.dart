import 'package:codo/utils/priority_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

// Trabajo simulado: apunta cuándo EMPIEZA y tarda 5 ms (sin red)
Future<void> Function() _work(List<String> started, String name) => () async {
      started.add(name);
      await Future<void>.delayed(const Duration(milliseconds: 5));
    };

void main() {
  test('user requests overtake queued background requests', () async {
    final started = <String>[];
    final s = PriorityScheduler(slots: 1, fairEvery: 3);
    final futures = [
      for (var i = 0; i < 4; i++)
        s.submit('bg$i', Priority.background, _work(started, 'bg$i')),
      for (var i = 0; i < 2; i++)
        s.submit('u$i', Priority.user, _work(started, 'u$i')),
    ];
    await Future.wait(futures);
    // bg0 ya había empezado (estaba solo); el resto del fondo espera a los del usuario
    expect(started, ['bg0', 'u0', 'u1', 'bg1', 'bg2', 'bg3']);
  });

  test('with fairEvery 2 one background request passes every 2 user requests', () async {
    final started = <String>[];
    final s = PriorityScheduler(slots: 1, fairEvery: 2);
    final futures = [
      for (var i = 0; i < 2; i++)
        s.submit('bg$i', Priority.background, _work(started, 'bg$i')),
      for (var i = 0; i < 6; i++)
        s.submit('u$i', Priority.user, _work(started, 'u$i')),
    ];
    await Future.wait(futures);
    expect(started, ['bg0', 'u0', 'u1', 'bg1', 'u2', 'u3', 'u4', 'u5']);
  });

  test('without the rule background waits until the user stops (starvation)', () async {
    final started = <String>[];
    final s = PriorityScheduler(slots: 1, fairEvery: null);
    final futures = [
      for (var i = 0; i < 2; i++)
        s.submit('bg$i', Priority.background, _work(started, 'bg$i')),
      for (var i = 0; i < 6; i++)
        s.submit('u$i', Priority.user, _work(started, 'u$i')),
    ];
    await Future.wait(futures);
    expect(started, ['bg0', 'u0', 'u1', 'u2', 'u3', 'u4', 'u5', 'bg1']);
  });

  test('never runs more requests at once than slots', () async {
    var running = 0;
    var maxRunning = 0;
    final s = PriorityScheduler(slots: 2);
    final futures = [
      for (var i = 0; i < 8; i++)
        s.submit('j$i', i.isEven ? Priority.user : Priority.background, () async {
          running++;
          if (running > maxRunning) maxRunning = running;
          await Future<void>.delayed(const Duration(milliseconds: 5));
          running--;
        }),
    ];
    await Future.wait(futures);
    expect(maxRunning, 2);
  });

  test('a failing request reports its error and the queue keeps going', () async {
    final started = <String>[];
    final s = PriorityScheduler(slots: 1);
    final failing = s.submit<void>('bad', Priority.user, () async {
      started.add('bad');
      throw Exception('falla');
    });
    final next = s.submit('ok', Priority.user, _work(started, 'ok'));
    await expectLater(failing, throwsException);
    await next;
    expect(started, ['bad', 'ok']);
  });
}

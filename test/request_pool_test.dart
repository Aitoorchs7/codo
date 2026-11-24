import 'package:codo/utils/request_pool.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('never runs more than K tasks at the same time', () async {
    var running = 0;
    var maxRunning = 0;
    final tasks = [
      for (var i = 0; i < 20; i++)
        PoolTask<int>('t$i', () async {
          running++;
          if (running > maxRunning) maxRunning = running;
          await Future<void>.delayed(const Duration(milliseconds: 10));
          running--;
          return i;
        }),
    ];
    await RequestPool(k: 4).runAll(tasks);
    expect(maxRunning, 4);
    expect(tasks.every((t) => t.state == RequestState.done), isTrue);
  });

  test('retries a failing task and ends done', () async {
    var calls = 0;
    final task = PoolTask<int>('r1', () async {
      calls++;
      if (calls < 3) throw Exception('falla');
      return 7;
    });
    await RequestPool(k: 1, baseDelay: const Duration(milliseconds: 1))
        .runAll([task]);
    expect(task.state, RequestState.done);
    expect(task.attempts, 3);
    expect(task.result, 7);
  });

  test('gives up after maxRetries and marks the task failed', () async {
    final task = PoolTask<int>('r2', () async => throw Exception('siempre'));
    await RequestPool(
      k: 1,
      maxRetries: 2,
      baseDelay: const Duration(milliseconds: 1),
    ).runAll([task]);
    expect(task.state, RequestState.failed);
    expect(task.attempts, 3); // 1 intento + 2 reintentos
  });

  test('does not retry when shouldRetry says no', () async {
    final task = PoolTask<int>('r3', () async => throw const FormatException());
    await RequestPool(k: 1, shouldRetry: (e) => e is! FormatException)
        .runAll([task]);
    expect(task.state, RequestState.failed);
    expect(task.attempts, 1);
  });

  test('waits longer on each retry (exponential backoff)', () async {
    final stamps = <int>[];
    final clock = Stopwatch()..start();
    final task = PoolTask<int>('r4', () async {
      stamps.add(clock.elapsedMilliseconds);
      throw Exception('falla');
    });
    await RequestPool(
      k: 1,
      maxRetries: 3,
      baseDelay: const Duration(milliseconds: 20),
    ).runAll([task]);
    final gaps = [for (var i = 1; i < stamps.length; i++) stamps[i] - stamps[i - 1]];
    // 20, 40 y 80 ms como mínimo
    expect(gaps[0], greaterThanOrEqualTo(20));
    expect(gaps[1], greaterThanOrEqualTo(40));
    expect(gaps[2], greaterThanOrEqualTo(80));
  });
}

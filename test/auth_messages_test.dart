import 'package:codo/admins/auth_failure.dart';
import 'package:codo/screens/auth/auth_messages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('authErrorMessage gives a distinct non-empty text to every AuthError', () {
    final messages = AuthError.values.map(authErrorMessage).toList();

    expect(messages.every((m) => m.isNotEmpty), isTrue);
    // Si dos errores comparten texto, el usuario no sabría distinguirlos.
    expect(messages.toSet().length, AuthError.values.length);
  });
}
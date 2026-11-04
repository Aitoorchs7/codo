// Fallos al modificar sesiones; la pantalla decide el texto
enum SessionError { permissionDenied, notFound, network, unknown }

class SessionFailure implements Exception {
  final SessionError error;
  const SessionFailure(this.error);
}
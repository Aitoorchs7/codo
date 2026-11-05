//Fallos al elegir una foto; la pantalla decide el texto
enum PhotoError{cameraDenied, galleryDenied, noCamera, unknown, compressFailed}

class PhotoFailure implements Exception {
  final PhotoError error;
  const PhotoFailure(this.error);
}
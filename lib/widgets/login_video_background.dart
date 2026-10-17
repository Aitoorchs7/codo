import 'package:codo/app/codo_colors.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// Fondo del login: vídeo en bucle y sin sonido, recortado para llenar la
// pantalla. Mientras carga (o si falla) se ve su primer fotograma.
class LoginVideoBackground extends StatefulWidget {
  const LoginVideoBackground({super.key, required this.child});

  // Lo que se pinta encima del fondo (la pantalla).
  final Widget child;

  @override
  State<LoginVideoBackground> createState() => _LoginVideoBackgroundState();
}

class _LoginVideoBackgroundState extends State<LoginVideoBackground> {
  final _controller = VideoPlayerController.asset(
    'assets/videos/fondo_login_video.mp4',
  );

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.setVolume(0);
      await _controller.play();
      if (mounted) setState(() {});
    } catch (_) {
      // Si el vídeo falla se queda la imagen: el fondo nunca queda en negro.
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = _controller.value.size;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/imagenes_app/login_poster.webp',
          fit: BoxFit.cover,
        ),
        if (_controller.value.isInitialized)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        // Velo oscuro: el login es siempre oscuro, también en modo claro.
        DecoratedBox(
          decoration: BoxDecoration(
            color: CodoColors.dark.bgBottom.withValues(alpha: 0.35),
          ),
        ),
        widget.child,
      ],
    );
  }
}
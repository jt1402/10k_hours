import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ten_k_hours/features/pursuits/presentation/create_pursuit_screen.dart';
import 'package:ten_k_hours/features/pursuits/presentation/home_screen.dart';
import 'package:ten_k_hours/features/sessions/presentation/timer_screen.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const HomeScreen(),
      ),
      GoRoute(
        path: '/create',
        builder: (_, _) => const CreatePursuitScreen(),
      ),
      GoRoute(
        path: '/pursuit/:id',
        builder: (_, state) => TimerScreen(
          pursuitId: int.parse(state.pathParameters['id']!),
        ),
      ),
    ],
  );
}

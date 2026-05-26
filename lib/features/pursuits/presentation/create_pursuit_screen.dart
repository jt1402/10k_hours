import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreatePursuitScreen extends ConsumerWidget {
  const CreatePursuitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('New pursuit')),
      body: const Center(child: Text('coming in next task')),
    );
  }
}

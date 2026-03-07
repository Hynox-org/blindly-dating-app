import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/call/provider/global_call_listener.dart';

class GlobalCallInitializer extends ConsumerStatefulWidget {
  final Widget child;

  const GlobalCallInitializer({super.key, required this.child});

  @override
  ConsumerState<GlobalCallInitializer> createState() =>
      _GlobalCallInitializerState();
}

class _GlobalCallInitializerState extends ConsumerState<GlobalCallInitializer>
    with WidgetsBindingObserver {

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    Future.microtask(() {
      if (!_initialized) {
        _initialized = true;

        print("🚀 Starting Global Call Listener");

        ref.read(incomingCallProvider.notifier).start();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // Do NOT stop listener here unless app exits
    // otherwise calls may stop working after rebuild

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      print("🔄 App resumed → restarting call listener");

      ref.read(incomingCallProvider.notifier).start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
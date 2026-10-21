import 'dart:async';

import 'package:flutter/widgets.dart';

/// Refreshes clock content at minute boundaries and when the app resumes.
class MinuteClock extends StatefulWidget {
  const MinuteClock({
    required this.builder,
    this.now = DateTime.now,
    super.key,
  });

  final Widget Function(BuildContext context, DateTime now) builder;
  final DateTime Function() now;

  @override
  State<MinuteClock> createState() => _MinuteClockState();
}

class _MinuteClockState extends State<MinuteClock> with WidgetsBindingObserver {
  Timer? _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _now = widget.now();
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    final Duration elapsed = Duration(
      seconds: _now.second,
      milliseconds: _now.millisecond,
      microseconds: _now.microsecond,
    );
    _timer = Timer(const Duration(minutes: 1) - elapsed, _refresh);
  }

  void _refresh() {
    setState(() => _now = widget.now());
    _schedule();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
    } else {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _now);
}

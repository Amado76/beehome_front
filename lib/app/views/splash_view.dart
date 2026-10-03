import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/config/models/version.dart';
import '../../design_system/theme/app_tokens.dart';
import '../../l10n/generated/app_localizations.dart';
import '../view_models/app_view_model.dart';
import 'splash_layout.dart';

class SplashView extends StatefulWidget {
  const SplashView({required this.viewModel, this.backgroundImage, super.key});

  final AppViewModel viewModel;
  final ImageProvider<Object>? backgroundImage;

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3800),
  );
  bool _motionEnabled = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _motionEnabled = !MediaQuery.disableAnimationsOf(context);
    if (_motionEnabled) {
      if (!_animation.isAnimating) _animation.repeat();
    } else {
      _animation.stop();
      _animation.value = 0;
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final List<String> phrases = [
      strings.splashPreparing,
      strings.splashOrganizing,
      strings.splashLoading,
      strings.splashReady,
      strings.splashHoney,
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // Selects the style by width and passes it to the header, hero, and footer.
            final SplashLayout layout = SplashLayout.forWidth(
              constraints.maxWidth,
            );
            final Size canvas = layout.canvasSize(constraints.biggest);
            return Center(
              child: SizedBox(
                width: canvas.width,
                height: canvas.height,
                child: DecoratedBox(
                  decoration: layout.frameDecoration,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(layout.frameRadius),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (widget.backgroundImage != null)
                          RepaintBoundary(
                            child: Image(
                              image: widget.backgroundImage!,
                              fit: BoxFit.cover,
                              excludeFromSemantics: true,
                              errorBuilder:
                                  (
                                    BuildContext context,
                                    Object error,
                                    StackTrace? stack,
                                  ) => const SizedBox.expand(),
                            ),
                          ),
                        SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: canvas.height,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(layout.padding),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _header(strings, layout),
                                  _hero(strings, phrases, layout),
                                  _footer(strings, layout),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _hero(
    AppLocalizations strings,
    List<String> phrases,
    SplashLayout layout,
  ) => Center(
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: layout.heroPadding),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: layout.contentWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _mascot(layout),
            const SizedBox(height: 20),
            Text.rich(
              const TextSpan(
                children: [
                  TextSpan(text: 'Bee'),
                  TextSpan(
                    text: 'Home',
                    style: TextStyle(color: AppColors.honeyDark),
                  ),
                ],
              ),
              style: layout.brandStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              strings.splashTagline,
              textAlign: TextAlign.center,
              style: layout.tagline,
            ),
            const SizedBox(height: 32),
            _progress(strings.loadingSession, layout),
            const SizedBox(height: 14),
            ListenableBuilder(
              listenable: widget.viewModel,
              builder: (BuildContext context, Widget? child) =>
                  AnimatedSwitcher(
                    duration: _motionEnabled
                        ? const Duration(milliseconds: 250)
                        : Duration.zero,
                    child: Row(
                      key: ValueKey(widget.viewModel.splashPhraseIndex),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _Dot(size: 8),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            phrases[widget.viewModel.splashPhraseIndex],
                            textAlign: TextAlign.center,
                            style: layout.caption,
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _header(AppLocalizations strings, SplashLayout layout) => SizedBox(
    width: double.infinity,
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (BuildContext context, Widget? child) {
                  final double pulse = (_animation.value * 3) % 1;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_motionEnabled)
                        Transform.scale(
                          scale: 1 + pulse,
                          child: Opacity(
                            opacity: (1 - pulse) * .5,
                            child: const _Dot(size: 8),
                          ),
                        ),
                      const _Dot(size: 8),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'BEEHOME',
              style: layout.smallCaption.copyWith(
                color: AppColors.mutedInk.withValues(alpha: .55),
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        Text(
          strings.splashNotebook.toUpperCase(),
          style: layout.smallCaption.copyWith(
            color: AppColors.mutedInk.withValues(alpha: .55),
          ),
        ),
      ],
    ),
  );

  Widget _mascot(SplashLayout layout) => ExcludeSemantics(
    child: SizedBox(
      width: layout.mascotWidth + 26,
      height: layout.mascotHeight,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (BuildContext context, Widget? child) {
          final double lift =
              (1 - math.cos(_animation.value * math.pi * 2)) / 2;
          return Stack(
            alignment: Alignment.center,
            children: [
              if (layout.showFlightTrail)
                Positioned(
                  top: 0,
                  left: 0,
                  width: 170,
                  height: 110,
                  child: CustomPaint(
                    painter: _FlightTrailPainter(_animation.value),
                  ),
                ),
              Positioned(
                bottom: 0,
                child: Transform.scale(
                  scale: 1 - lift * .15,
                  child: Container(
                    width: layout.shadowWidth,
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: AppColors.ink.withValues(alpha: .12 - lift * .06),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ink.withValues(alpha: .07),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Transform.translate(
                key: const ValueKey('floating-mascot'),
                offset: Offset(0, -13 * lift),
                child: Transform.rotate(
                  angle: math.sin(_animation.value * math.pi * 2) * .025,
                  child: child,
                ),
              ),
            ],
          );
        },
        child: Image.asset(
          'assets/mascote_splash.png',
          width: layout.mascotWidth,
          height: layout.mascotHeight - 20,
          fit: BoxFit.contain,
        ),
      ),
    ),
  );

  Widget _progress(String label, SplashLayout layout) => Semantics(
    label: label,
    child: Container(
      key: const ValueKey('splash-progress'),
      width: layout.progressWidth,
      height: 12,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.progressTrack,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.ink.withValues(alpha: .1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) =>
              AnimatedBuilder(
                animation: _animation,
                builder: (BuildContext context, Widget? child) => Stack(
                  children: [
                    Positioned(
                      left: _motionEnabled
                          ? constraints.maxWidth * (_animation.value * 1.5 - .5)
                          : constraints.maxWidth * .25,
                      width: constraints.maxWidth * .5,
                      top: 0,
                      bottom: 0,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.honeyLight,
                              AppColors.honey,
                              AppColors.honeyDark,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ),
      ),
    ),
  );

  Widget _footer(AppLocalizations strings, SplashLayout layout) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.ink.withValues(alpha: .04),
          border: Border.all(color: AppColors.ink.withValues(alpha: .05)),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _Dot(size: 8, color: AppColors.success),
            const SizedBox(width: 8),
            Flexible(
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'v${AppVersion.current}',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: ' • ${strings.splashFooter}'),
                  ],
                ),
                textAlign: TextAlign.center,
                style: layout.smallCaption.copyWith(
                  color: AppColors.mutedInk.withValues(alpha: .9),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 4),
      Text(
        strings.splashFooterCaption,
        textAlign: TextAlign.center,
        style: layout.smallCaption.copyWith(
          color: AppColors.mutedInk.withValues(alpha: .5),
        ),
      ),
    ],
  );
}

class _Dot extends StatelessWidget {
  const _Dot({required this.size, this.color = AppColors.honey});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}

class _FlightTrailPainter extends CustomPainter {
  const _FlightTrailPainter(this.phase);

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..moveTo(10, 85)
      ..cubicTo(40, 95, 60, 60, 85, 75)
      ..cubicTo(110, 90, 120, 45, 150, 40);
    final Paint paint = Paint()
      ..color = AppColors.honeyDark.withValues(alpha: .4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (final metric in path.computeMetrics()) {
      for (
        double offset = -10 + (phase * 60) % 10;
        offset < metric.length;
        offset += 10
      ) {
        canvas.drawPath(
          metric.extractPath(math.max(0, offset), math.max(0, offset + 4)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_FlightTrailPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

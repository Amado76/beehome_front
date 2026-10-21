import 'package:beehome/features/scratchpad/views/scratchpad_editor.dart';
import 'package:beehome/design_system/theme/app_theme.dart';
import 'package:beehome/features/family_workspace/views/family_home_view.dart';
import 'package:beehome/features/family_workspace/views/workspace_form.dart';
import 'package:beehome/features/family_workspace/views/pastel_color_picker.dart';
import 'package:beehome/features/scratchpad/views/drawing_canvas.dart';
import 'package:beehome/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/workspace_fakes.dart';

void main() {
  testWidgets('swiping cards opens the tapped note for editing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final harness = WorkspaceHarness();
    addTearDown(harness.dispose);
    await tester.runAsync(harness.start);
    await harness.home.createNote('First note');
    await harness.home.createNote('Second note');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FamilyHomeView(
          viewModel: harness.home,
          languageSelector: const SizedBox.shrink(),
          onSignOut: () {},
          onChangePassword: () {},
        ),
      ),
    );
    await tester.pump();
    final list = find.byKey(ValueKey('board-notes-${adult.id}'));
    expect(find.text('2 active notes'), findsOneWidget);
    await tester.ensureVisible(list);
    await tester.drag(list, const Offset(-280, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('First note'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ScratchpadEditor>(find.byType(ScratchpadEditor))
          .profileName,
      'First note',
    );
    expect(harness.home.notes, hasLength(2));
    await tester.tap(find.byTooltip('Delete note'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(ScratchpadEditor), findsOneWidget);
    expect(harness.home.notes, hasLength(2));
    await tester.tap(find.byTooltip('Delete note'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete note'));
    await tester.pumpAndSettle();
    expect(find.byType(ScratchpadEditor), findsNothing);
    expect(harness.home.notes.single.title, 'Second note');
    expect(find.text('1 active note'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'login without a family opens creation directly without the chooser',
    (tester) async {
      final harness = WorkspaceHarness();
      harness.families.families = [];
      addTearDown(harness.dispose);
      await tester.runAsync(harness.start);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FamilyHomeView(
            viewModel: harness.home,
            languageSelector: const SizedBox.shrink(),
            onSignOut: () {},
            onChangePassword: () {},
          ),
        ),
      );
      expect(find.byType(WorkspaceForm), findsOneWidget);
      expect(
        tester.widget<WorkspaceForm>(find.byType(WorkspaceForm)).canClose,
        isTrue,
      );
      expect(find.text('Choose a family'), findsNothing);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets('custom palette keeps the chosen hue in the pastel range', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PastelColorPicker(
            selected: '#BFDBFE',
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Choose a pastel color'));
    await tester.pumpAndSettle();
    final slider = tester.widget<Slider>(find.byType(Slider).first);
    slider.onChanged!(270);
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Done'));
    await tester.pumpAndSettle();
    expect(selected, matches(RegExp(r'^#[0-9A-F]{6}$')));
    final hsl = HSLColor.fromColor(PastelColorPicker.decode(selected));
    expect(hsl.hue, closeTo(270, 1));
    expect(hsl.lightness, inInclusiveRange(.78, .92));
  });
  testWidgets('family setup supports enlarged text on a small phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final harness = WorkspaceHarness();
    addTearDown(harness.dispose);
    await tester.runAsync(harness.start);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: WorkspaceForm(
          viewModel: harness.home,
          mode: WorkspaceFormMode.editFamily,
          onClose: () {},
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('family creation only requires a name', (tester) async {
    final WorkspaceHarness harness = WorkspaceHarness();
    harness.families.families = [];
    addTearDown(harness.dispose);
    await tester.runAsync(harness.start);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WorkspaceForm(
          viewModel: harness.home,
          mode: WorkspaceFormMode.createFamily,
          onClose: () {},
        ),
      ),
    );
    expect(find.text('Family timezone'), findsNothing);
    await tester.enterText(find.byType(TextFormField).first, 'New family');
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Done'));
    await tester.runAsync(() async {
      await tester.tap(find.widgetWithText(FilledButton, 'Done'));
      await harness.settle();
    });
    await tester.pump();
    expect(harness.families.createCount, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets(
    'concluding first setup saves the pending member and creates the family once',
    (tester) async {
      final harness = WorkspaceHarness();
      harness.families.families = [];
      addTearDown(harness.dispose);
      await tester.runAsync(harness.start);
      bool closed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WorkspaceForm(
            viewModel: harness.home,
            mode: WorkspaceFormMode.createFamily,
            onClose: () => closed = true,
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField).first, 'New family');
      await tester.enterText(find.byType(TextFormField).at(1), 'Alex');
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Done'));
      await tester.runAsync(() async {
        await tester.tap(find.widgetWithText(FilledButton, 'Done'));
        await harness.settle();
      });
      await tester.pump();
      expect(closed, isTrue);
      expect(harness.families.createCount, 1);
      expect(harness.profiles.saves, [
        (null, '#BBF7D0', false),
        (adult.id, '#BBF7D0', true),
      ]);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  for (final Size size in [const Size(390, 844), const Size(1024, 768)]) {
    testWidgets(
      'home at $size shares profile selection and opens handwriting',
      (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final WorkspaceHarness harness = WorkspaceHarness();
        addTearDown(harness.dispose);
        await tester.runAsync(harness.start);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: FamilyHomeView(
              viewModel: harness.home,
              languageSelector: const SizedBox.shrink(),
              onSignOut: () {},
              onChangePassword: () {},
            ),
          ),
        );
        await tester.pump();
        expect(find.text('FREE BOARD'), findsOneWidget);
        expect(find.text('0 of 1 completed'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Sam').first);
        await tester.pump();
        await tester.pump();
        expect(harness.home.selected?.id, child.id);
        expect(find.text('FREE BOARD'), findsOneWidget);
        expect(find.text('0 of 1 completed'), findsOneWidget);
        await tester.tap(find.text('Alex').first);
        await tester.pump();
        await tester.pump();
        await tester.ensureVisible(find.text('NEW NOTE'));
        await tester.tap(find.text('NEW NOTE'));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.byKey(const ValueKey('note-title')), findsOneWidget);
        await tester.enterText(
          find.byKey(const ValueKey('note-title')),
          'Shopping',
        );
        await tester.pump();
        await tester.pump();
        expect(find.byType(DrawingCanvas), findsOneWidget);
        final Finder canvas = find.byType(DrawingCanvas);
        await tester.ensureVisible(canvas);
        final Offset start = tester.getCenter(canvas);
        final ScrollableState editorScroll = tester.state<ScrollableState>(
          find.ancestor(of: canvas, matching: find.byType(Scrollable)).first,
        );
        final double scrollOffset = editorScroll.position.pixels;
        final TestGesture gesture = await tester.startGesture(start);
        await gesture.moveBy(const Offset(0, -40));
        await tester.pump();
        await gesture.moveBy(const Offset(0, -40));
        await tester.pump();
        await gesture.up();
        expect(editorScroll.position.pixels, scrollOffset);
        await tester.pump(const Duration(milliseconds: 1500));
        await tester.pump();
        expect(harness.drawings.writes, isNotEmpty);
        expect(
          harness.drawings.writes.last.strokes.single.points.length,
          greaterThan(1),
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
  testWidgets('small mobile supports enlarged text without overflow', (
    WidgetTester tester,
  ) async {
    final originalErrorHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      debugPrint(details.toString());
      originalErrorHandler?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalErrorHandler);
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final WorkspaceHarness harness = WorkspaceHarness();
    addTearDown(harness.dispose);
    await tester.runAsync(harness.start);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (BuildContext context, Widget? child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: FamilyHomeView(
          viewModel: harness.home,
          languageSelector: const SizedBox.shrink(),
          onSignOut: () {},
          onChangePassword: () {},
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

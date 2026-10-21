import 'package:beehome/design_system/theme/app_theme.dart';
import 'package:beehome/features/family_workspace/views/workspace_form.dart';
import 'package:beehome/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/workspace_fakes.dart';

void main() {
  testWidgets('task form creates a daily task for multiple profiles', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final harness = WorkspaceHarness();
    addTearDown(harness.dispose);
    await tester.runAsync(harness.start);
    bool closed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WorkspaceForm(
          viewModel: harness.home,
          mode: WorkspaceFormMode.addTask,
          onClose: () => closed = true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<CheckboxListTile>(
            find.widgetWithText(CheckboxListTile, adult.name),
          )
          .value,
      isTrue,
    );
    await tester.enterText(find.byType(TextFormField), 'Escovar os dentes');
    await tester.tap(find.text('Repetir diariamente'));
    await tester.tap(find.text(child.name));
    final save = find.byType(FilledButton);
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(harness.planning.routineMembers, [adult.id, child.id]);
    expect(harness.planning.routines.single.$1, 'Escovar os dentes');
    expect(closed, isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

# beehome

A new Flutter project.

## Local checks

Enable the repository's commit checks in this clone:

```sh
./scripts/install-git-hooks.sh
```

The pre-commit hook runs `dart format .`,
`flutter analyze --fatal-infos --fatal-warnings`, and `flutter test`. Dart files
changed by the formatter are added to the Git stage automatically. Analyzer or
test failures stop the commit.

#!/bin/sh
set -eu

repo_root="$(git rev-parse --show-toplevel)"
git -C "$repo_root" config core.hooksPath .githooks

echo "Git hooks enabled for this checkout: $repo_root/.githooks"

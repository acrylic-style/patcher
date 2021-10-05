#!/usr/bin/env bash
export target="$1"
export branch="$2"
basedir="$(pwd -P)"
git="git -c commit.gpgsign=false -c core.safecrlf=false"
echo "Rebuilding patch files... ($target)"
mkdir -p "$basedir/$target-Patches"
cd "$basedir/$target-Patches" || exit 1
rm -rf -- *.patch
cd "$basedir/$target" || exit 1
$git format-patch --zero-commit --full-index --no-signature --no-stat -N -o "$basedir/$target-Patches/" "upstream/$branch" >/dev/null
cd "$basedir" || exit 1
$git add -A "$basedir/$target-Patches"
cd "$basedir/$target-Patches" || exit 1
for patch in *.patch; do
  echo "$patch"
  diffs=$($git diff --staged "$patch" | grep --color=none -E "^(\+|\-)" | grep --color=none -Ev "(\-\-\- a|\+\+\+ b|^.index)")
  if [ "x$diffs" == "x" ] ; then
    $git restore "$patch" >/dev/null
    $git checkout -- "$patch" >/dev/null
  fi
done
echo "  Patches saved for $target to $target-Patches/"
#!/usr/bin/env bash
export target="$1"
export branch="$2"
basedir="$(pwd -P)"
git="git -c commit.gpgsign=false"
apply="$git am --3way --ignore-whitespace"
windows="$([[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]] && echo "true" || echo "false")"
mkdir -p "$basedir/$target-Patches"
echo "Resetting $target..."
mkdir -p "$basedir/$target"
cd "$basedir/$target" || exit 1
$git init
$git remote rm upstream > /dev/null 2>&1
$git remote add upstream "$basedir/work/$target" >/dev/null 2>&1
$git checkout "$branch" 2>/dev/null || $git checkout -b "$branch"
$git fetch upstream >/dev/null 2>&1
$git reset --hard "upstream/$branch"

cd "$basedir/$target" || exit 1
echo "  Applying patches to $target..."
$git am --abort >/dev/null 2>&1
if [[ $windows == "true" ]]; then
  echo "  Using workaround for Windows ARG_MAX constraint"
  find "$basedir/$target-Patches/"*.patch -print0 | xargs -0 $apply
else
  $apply "$basedir/$target-Patches/"*.patch
fi
if [ "$?" != "0" ]; then
  echo "  Something did not apply cleanly to $target."
  echo "  Please review above details and finish the apply then"
  echo "  save the changes with rebuildPatches.sh"
  if [[ $windows == "true" ]]; then
    echo ""
    echo "  Because you're on Windows you'll need to finish the AM,"
    echo "  rebuild all patches, and then re-run the patch apply again."
    echo "  Consider using the scripts with Windows Subsystem for Linux."
  fi
  exit 1
else
  echo "  Patches applied cleanly to $target"
fi

#!/usr/bin/env bash
export target="$1"
export branch="$2"
declare -A GH_URL
GH_URL[someProject]='https://github.com/foo/bar'
if [ ! -e "work/$target" ]; then
  mkdir -p "work"
  git clone "${GH_URL[$target]}" "work/$target"
fi
(
  echo "Updating data" &&
  # git submodule update --init &&
  cd "work/$target" &&
  git fetch --all &&
  git checkout "$branch" &&
  git reset --hard "origin/$branch" &&
  cd ../.. &&
  echo "Updated data"
) || exit 1

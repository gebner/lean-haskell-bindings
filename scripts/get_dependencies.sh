#!/bin/bash
set -ex

mkdir -p deps

pushd deps > /dev/null

if [ -d lean ]; then
    pushd lean > /dev/null
    git pull
else
    git clone git@github.com:leanprover/lean.git
    pushd lean > /dev/null
fi


mkdir -p build
pushd build > /dev/null

if [ ! -f build.ninja ]; then
    cmake -DCMAKE_BUILD_TYPE=DEBUG -G Ninja ../src
fi

ninja libleanshared.dylib
popd > /dev/null # deps/lean/build
popd > /dev/null # deps/lean
popd > /dev/null # deps


if [ ! -f cabal.config ]; then
cat <<EOF > cabal.config
extra-include-dirs: $PWD/deps/lean/src/api
extra-lib-dirs:     $PWD/lean/build
EOF

    wget https://www.stackage.org/lts-2/cabal.config -O - >> cabal.config
fi
cabal sandbox init
cabal update
cabal install c2hs
cabal install --only-dependencies

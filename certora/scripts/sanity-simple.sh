#!/bin/sh

make -C certora munged-simple

certoraRun \
    certora/munged-simple/DLL.sol \
    --verify DLL:certora/specs/sanity.spec \
    --loop_iter 7 \
    --optimistic_loop \
    --send_only \
    --staging \
    --msg "Simple DLL sanity" \
    $@

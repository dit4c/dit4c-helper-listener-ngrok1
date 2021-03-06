#!/usr/bin/env bats

IMAGE="$BATS_TEST_DIRNAME/../dist/ngrokd.linux.amd64.aci"
RKT_DIR="$BATS_TMPDIR/rkt-env"
RKT_STAGE1="$BATS_TEST_DIRNAME/../build/rkt/stage1-coreos.aci"
RKT="$BATS_TEST_DIRNAME/../build/rkt/rkt --dir=$RKT_DIR"

teardown() {
  sudo $RKT gc --grace-period=0s
}

@test "ngrokd binary runs" {
  run sudo $RKT run --insecure-options=image --stage1-path=$RKT_STAGE1 \
    $IMAGE \
    --exec /usr/bin/ngrokd -- --help
  echo $output
  [ "$status" -eq 2 ]
}

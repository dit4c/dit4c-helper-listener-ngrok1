#!/usr/bin/env bats

IMAGE="$BATS_TEST_DIRNAME/../dist/dit4c-helper-listener-ngrok1.linux.amd64.aci"
RKT_DIR="$BATS_TMPDIR/rkt-env"
RKT_STAGE1="$BATS_TEST_DIRNAME/../build/rkt/stage1-coreos.aci"
RKT="$BATS_TEST_DIRNAME/../build/rkt/rkt --dir=$RKT_DIR"

teardown() {
  sudo $RKT gc --grace-period=0s
}

@test "curl supports HTTPS" {
  run sudo $RKT run --insecure-options=image --stage1-path=$RKT_STAGE1 \
    $IMAGE \
    --exec /usr/bin/curl -- -V
  echo $output
  [ "$status" -eq 0 ]
  [ $(expr "${output}" : ".*Protocols: .*https.*") -ne 0 ]
}

@test "ngrok binary runs" {
  run sudo $RKT run --insecure-options=image --stage1-path=$RKT_STAGE1 \
    $IMAGE \
    --exec /usr/bin/ngrok -- --help
  echo $output
  [ "$status" -eq 2 ]
}

@test "Runs as \"listener\"" {
  run sudo $RKT run --insecure-options=image --stage1-path=$RKT_STAGE1 \
    $IMAGE \
    --exec /bin/sh -- -c "id -nu"
  echo $output
  [ $(expr "${output}" : ".*listener") -ne 0 ]
}

@test "Home (~/) is writable" {
  run sudo $RKT run --insecure-options=image --stage1-path=$RKT_STAGE1 \
    $IMAGE \
    --exec /bin/sh -- -c "ls -la ~/ && touch ~/test"
  echo $output
  [ "$status" -eq 0 ]
}

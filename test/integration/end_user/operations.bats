load "${BATS_HELPER_DIR}/bats-support/load.bash"
load "${BATS_HELPER_DIR}/bats-assert/load.bash"

@test "running under the expected cpu architecture" {
  run /bin/bash -c "dojo -c Dojofile.to_be_tested \"uname -m\""
  echo "output: $output"
  assert_line --partial "x86_64"
  assert_equal "$status" 0
}
@test "/usr/bin/entrypoint.sh returns 0" {
  run /bin/bash -c "dojo -c Dojofile.to_be_tested \"pwd && whoami\""
  # this is printed on test failure
  echo "output: $output"
  assert_line --partial "dojo init finished"
  assert_line --partial "/dojo/work"
  assert_line --partial "spin-dojo-image-base"
  refute_output --partial "IMAGE_VERSION"
  refute_output --partial "root"
  assert_equal "$status" 0
}
@test "correct terraform version is installed" {
  run /bin/bash -c "dojo -c Dojofile.to_be_tested \"terraform --version\""
  echo "output: $output"
  assert_line --partial "Terraform v1.2.4"
  assert_equal "$status" 0
}
@test "any dot version is installed (graphviz)" {
  run /bin/bash -c "dojo -c Dojofile.to_be_tested \"dot -V\""
  echo "output: $output"
  assert_line --partial "dot - graphviz version"
  assert_equal "$status" 0
}
@test "dot can generate png file without error" {
  run /bin/bash -c "dojo -c Dojofile.to_be_tested \"dot -Tpng graph1.gv -o graph1.png\""
  echo "output: $output"
  assert_equal "$status" 0
}
@test "ssh client is installed" {
  run /bin/bash -c "dojo -c Dojofile.to_be_tested \"ssh\""
  echo "output: $output"
  assert_line --partial "usage: ssh"
  assert_equal "$status" 255
}
@test "curl is installed" {
  run /bin/bash -c "dojo -c Dojofile.to_be_tested \"curl --version\""
  echo "output: $output"
  assert_line --partial "curl"
  assert_equal "$status" 0
}
@test "git is installed" {
  run /bin/bash -c "dojo -c Dojofile.to_be_tested \"git --version\""
  echo "output: $output"
  assert_output --partial "git version"
  assert_equal "$status" 0
}
@test "make is installed" {
  run /bin/bash -c "dojo -c Dojofile.to_be_tested \"make --version\""
  echo "output: $output"
  assert_output --partial "GNU Make"
  assert_equal "$status" 0
}
@test "jq is installed" {
  run /bin/bash -c "dojo -c Dojofile.to_be_tested \"jq --version\""
  echo "output: $output"
  assert_output --partial "jq-"
  assert_equal "$status" 0
}
@test "aws config directory is copied from identity directory" {
  run /bin/bash -c "dojo -c Dojofile.to_be_tested \"cat /home/dojo/.aws/config\""
  echo "output: $output"
  assert_output --partial "region"
  assert_equal "$status" 0
}
@test "correct AWS CLI version is installed" {
  run /bin/bash -c "dojo -c Dojofile.to_be_tested \"aws --version\""
  echo "output: $output"
  # assert_line --partial "aws-cli/2.7.11"
  assert_equal "$status" 0
}
@test "correct bats-core version is installed" {
  run /bin/bash -c "bats --version"
  echo "output: $output"
  assert_output --partial "Bats 1.7.0"
  assert_equal "$status" 0
}
@test "bats-support is installed" {
  run /bin/bash -c "dojo -c Dojofile.to_be_tested \"[ -f /opt/bats-support/load.bash ]\""
}
@test "bats-assert is installed" {
  run /bin/bash -c "dojo -c Dojofile.to_be_tested \"[ -f /opt/bats-assert/load.bash ]\""
}
@test "localstack is installed" {
  run /bin/bash -c "dojo -c Dojofile.to_be_tested \"localstack --help\""
  echo "output: $output"
  assert_equal "$status" 0
}

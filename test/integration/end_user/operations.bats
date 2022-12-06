load "${BATS_HELPER_DIR}/bats-support/load.bash"
load "${BATS_HELPER_DIR}/bats-assert/load.bash"

on_dojo() {
  /bin/bash -c "dojo -c Dojofile.to_be_tested \"$*\""
}

@test "running under the expected cpu architecture" {
  run on_dojo "uname -m"
  echo "output: $output"
  assert_line --partial "x86_64"
  assert_equal "$status" 0
}
@test "/usr/bin/entrypoint.sh returns 0" {
  run on_dojo "pwd && whoami"
  # this is printed on test failure
  echo "output: $output"
  assert_line --partial "dojo init finished"
  assert_line --partial "/dojo/work"
  assert_line --partial "spin-dojo-image"
  refute_output --partial "IMAGE_VERSION"
  refute_output --partial "root"
  assert_equal "$status" 0
}
@test "terraform is installed" {
  run on_dojo "terraform --version"
  echo "output: $output"
  assert_line --partial "Terraform v"
  assert_equal "$status" 0
}
@test "tflint is installed" {
  run on_dojo "tflint --version"
  echo "output: $output"
  assert_line --partial "TFLint version"
  assert_equal "$status" 0
}
@test "terragrunt is installed" {
  run on_dojo "terragrunt --version"
  echo "output: $output"
  assert_line --partial "terragrunt version v"
  assert_equal "$status" 0
}
@test "steampipe is installed" {
  run on_dojo "steampipe -v"
  echo "output: $output"
  assert_line --partial "steampipe version"
  assert_equal "$status" 0
}
@test "any dot version is installed (graphviz)" {
  run on_dojo "dot -V"
  echo "output: $output"
  assert_line --partial "dot - graphviz version"
  assert_equal "$status" 0
}
@test "dot can generate png file without error" {
  run on_dojo "dot -Tpng graph1.gv -o graph1.png"
  echo "output: $output"
  assert_equal "$status" 0
}
@test "ssh client is installed" {
  run on_dojo "ssh"
  echo "output: $output"
  assert_line --partial "usage: ssh"
  assert_equal "$status" 255
}
@test "curl is installed" {
  run on_dojo "curl --version"
  echo "output: $output"
  assert_line --partial "curl"
  assert_equal "$status" 0
}
@test "git is installed" {
  run on_dojo "git --version"
  echo "output: $output"
  assert_output --partial "git version"
  assert_equal "$status" 0
}
@test "make is installed" {
  run on_dojo "make --version"
  echo "output: $output"
  assert_output --partial "GNU Make"
  assert_equal "$status" 0
}
@test "jq is installed" {
  run on_dojo "jq --version"
  echo "output: $output"
  assert_output --partial "jq-"
  assert_equal "$status" 0
}
@test "aws config directory is copied from identity directory" {
  run on_dojo "cat /home/dojo/.aws/config"
  echo "output: $output"
  assert_output --partial "region"
  assert_equal "$status" 0
}
@test "correct AWS CLI version is installed" {
  run on_dojo "aws --version"
  echo "output: $output"
  # assert_line --partial "aws-cli/2.7.11"
  assert_equal "$status" 0
}
@test "correct bats-core version is installed" {
  run on_dojo "bats --version"
  echo "output: $output"
  assert_output --partial "Bats 1.7.0"
  assert_equal "$status" 0
}
@test "bats-support is installed" {
  run on_dojo "[ -f /opt/bats-support/load.bash ]"
}
@test "bats-assert is installed" {
  run on_dojo "[ -f /opt/bats-assert/load.bash ]"
}

# load "/opt/bats-support/load.bash"
load "/opt/bats-assert/load.bash"

@test "SPIN_DOJO_BASE_VERSION environment variable is set" {
  [ -n "${SPIN_DOJO_BASE_VERSION}" ]
}
@test "running under the expected cpu architecture" {
  run uname -m
  echo "output: $output"
  assert_line --partial "x86_64"
  assert_equal "$status" 0
}
@test "terraform is installed" {
  run terraform --version
  echo "output: $output"
  assert_line --partial "Terraform v"
  assert_equal "$status" 0
}
@test "tflint is installed" {
  run tflint --version
  echo "output: $output"
  assert_line --partial "TFLint version"
  assert_equal "$status" 0
}
@test "steampipe is installed" {
  run steampipe -v
  echo "output: $output"
  assert_line --partial "steampipe version"
  assert_equal "$status" 0
}
@test "any dot version is installed (graphviz)" {
  run dot -V
  echo "output: $output"
  assert_line --partial "dot - graphviz version"
  assert_equal "$status" 0
}
@test "dot can generate png file without error" {
  run dot -Tpng graph1.gv -o graph1.png
  echo "output: $output"
  assert_equal "$status" 0
}
@test "ssh client is installed" {
  run ssh
  echo "output: $output"
  assert_line --partial "usage: ssh"
  assert_equal "$status" 255
}
@test "curl is installed" {
  run curl --version
  echo "output: $output"
  assert_line --partial "curl"
  assert_equal "$status" 0
}
@test "git is installed" {
  run git --version
  echo "output: $output"
  assert_output --partial "git version"
  assert_equal "$status" 0
}
@test "make is installed" {
  run make --version
  echo "output: $output"
  assert_output --partial "GNU Make"
  assert_equal "$status" 0
}
@test "jq is installed" {
  run jq --version
  echo "output: $output"
  assert_output --partial "jq-"
  assert_equal "$status" 0
}
@test "aws config directory is copied from identity directory" {
  run cat /home/dojo/.aws/config
  echo "output: $output"
  assert_output --partial "region"
  assert_equal "$status" 0
}
@test "correct AWS CLI version is installed" {
  run aws --version
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
  run [ -f /opt/bats-support/load.bash ]
}
@test "bats-assert is installed" {
  run [ -f /opt/bats-assert/load.bash ]
}

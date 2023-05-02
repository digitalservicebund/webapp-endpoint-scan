#!/usr/bin/env sh

check_tool_ok='OK'
check_param_ok='OK'

ssh_headers_test_suite='dsbund_secure_headers_test_suite.yml'
# ssh_headers_test_suite='owasp_secure_headers_test_suite.yml'

check_tool() {
  tool_command="${1}"

  printf '* %s : ' "${tool_command}"

  if type "${tool_command}" > /dev/null
  then
    printf 'OK\n'
  else
    check_tool_ok='NOK'
    printf 'NOK - please install %s\n' "${tool_command}"
  fi
}

check_parameters() {
  param_hostname="${1}"

  if test "#${param_hostname}#" = "##"
  then
    printf 'Parameter <hostname> is missing!\n'  
    check_param_ok='NOK'
  fi
}

main() {
  printf '# Checking if tools are available ...\n'
  check_tool 'docker'
  check_tool 'sslyze'

  param_hostname="${1}"
  check_parameters "${param_hostname}"

  if test "#${check_tool_ok}#" = "#OK#" -a "#${check_param_ok}#" = "#OK#"
  then
    run_checks "${param_hostname}"
  
  elif test "#${check_param_ok}#" = "#NOK#"
  then
    printf 'Usage: run.sh <hostname>\n'
  
  elif test "#${check_tool_ok}#" = "#NOK#"
  then
    printf 'Scan tools missing in path! Please see README.md, install and retry.\n'
  
  else
    printf 'Unexpected error. Usage: run.sh <hostname>\n'
  fi
}

run_checks() {
  param_hostname="${1}"

  printf '# Running TLS settings check ...\n'
  mkdir -p ./results/${param_hostname}
  sslyze --json_out ./results/${param_hostname}/sslyze-test-result.json "${param_hostname}"

  printf '# Running HTTP secure headers check ...\n'
  docker run \
    --mount type=bind,source=$(pwd)/tests,target=/workdir/tests \
    --mount type=bind,source=$(pwd)/results,target=/workdir/results \
    -u $(id -u):$(id -g) \
    -e "VENOM_VAR_target_site=https://${param_hostname}" \
    -e "VENOM_OUTPUT_DIR=/workdir/results/${param_hostname}" \
    ovhcom/venom:latest \
    run "/workdir/tests/${ssh_headers_test_suite}"
}

main $@

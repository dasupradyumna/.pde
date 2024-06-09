###################################### SILENCE AUTOCD OPERATION ####################################
# Reference: https://gist.github.com/sebastiancarlos/efe3fede207232315c5a895f1be19712

__silence_autocd() { exec {BASH_XTRACEFD}>/dev/null; }

__unsilence_autocd() { exec {BASH_XTRACEFD}>/dev/stdout; }

set() {
  if [[ $# -eq 1 && "$1" == "-x" ]]; then
    command set -x;
    __unsilence_autocd;
  elif [[ $# -eq 1 && "$1" == "+x" ]]; then
    __silence_autocd;
    command set +x;
  else
    command set "$@";
  fi;
}

__silence_autocd

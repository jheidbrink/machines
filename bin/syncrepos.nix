{ pkgs, ... }:
# The problem with writePython3Bin is that it does quite strict linting and then fails to build
pkgs.writers.writePython3Bin "syncrepos" { flakeIgnore = [ "E265" "E501" ]; } (builtins.readFile ./syncrepos.py)
#pkgs.writers.writePython3Bin "syncrepos" {} "print('hello')\n"

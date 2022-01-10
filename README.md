# `agent-in-arion` (experimental)

These files show how to run hercules-ci-agent in a slightly privileged podman container with [arion](https://docs.hercules-ci.com/arion/).

It is somewhat of a template, rather than a complete example. For instance, there's more than one way to handle secrets and the method chosen here is clunky but sufficient.

`arion-pkgs.nix` needs to call the Nixpkgs you want to use, as arion does not have _integrated_ flake support at the time of writing.


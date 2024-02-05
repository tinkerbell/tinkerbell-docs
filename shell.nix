let _pkgs = import <nixpkgs> { };
in { pkgs ? import (_pkgs.fetchFromGitHub {
  owner = "NixOS";
  repo = "nixpkgs";
  #branch@date: 23.11@2023-11-29
  rev = "23.11";
  sha256 = "1ndiv385w1qyb3b18vw13991fzb9wg4cl21wglk89grsfsnra41k";
}) { } }:

with pkgs;

mkShell {
  buildInputs = [ nodePackages.prettier pkgs.poetry pkgs.python38];
}

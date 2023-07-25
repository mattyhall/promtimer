{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
          deps = with pkgs; [
	    (python312.withPackages (ps: with ps; [ dateutil ]))
	    grafana
	    prometheus
	  ];
      in {
	devShells.default = pkgs.mkShell { buildInputs = deps; };

	packages.default = pkgs.writeScriptBin "run" ''
	  echo "Args are $@"
	  export PATH=$PATH:${pkgs.lib.makeBinPath deps}
	  ${self}/bin/promtimer -g ${pkgs.grafana}/share/grafana --prometheus ${pkgs.prometheus}/bin/prometheus "$@"
	'';

	app.default = {
	  type = "app";
	  program = "${self.packages.${system}.default}/bin/run";
	};
      });
}

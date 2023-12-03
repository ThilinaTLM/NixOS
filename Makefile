# Define the default target
.PHONY: build
build:
	@echo "Building NixOS from flake..."
	sudo nixos-rebuild switch --flake .#TLM-NixOS --impure

update:
	@echo "Updating NixOS from flake..."
	sudo nix flake update

trace:
	@echo "Building NixOS from flake..."
	sudo nixos-rebuild switch --flake .#TLM-NixOS --impure --show-trace
# Define the default target
.PHONY: build
build:
	@echo "Building NixOS from flake..."
	sudo nixos-rebuild switch --flake .#TLM-NixOS --impure

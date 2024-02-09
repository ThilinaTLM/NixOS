{ config, lib, pkgs, ... }: {
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    withPython3 = true;
    plugins = with pkgs.vimPlugins; [
      plenary-nvim
      nvim-web-devicons
      nui-nvim
      nvim-treesitter.withAllGrammars
      gruvbox-material
      copilot-lua
      telescope-nvim
      telescope-file-browser-nvim
      neo-tree-nvim
      bufferline-nvim
    ];
    extraConfig = let
      vimFiles = lib.filterAttrs (name: type: lib.hasSuffix ".vim" name) (builtins.readDir ./.);
      vimFileNames = lib.attrNames vimFiles;
      vimConfigs = builtins.map builtins.readFile (map (path: builtins.path { name = path; path = ./. + "/${path}"; }) vimFileNames);
    in
    lib.concatStringsSep "\n" (vimConfigs ++ [
      "colorscheme gruvbox-material"
    ]);
    extraLuaConfig = let
      luaFiles = lib.filterAttrs (name: type: lib.hasSuffix ".lua" name) (builtins.readDir ./.);
      luaFileNames = lib.attrNames luaFiles;
      luaConfigs = builtins.map builtins.readFile (map (path: builtins.path { name = path; path = ./. + "/${path}"; }) luaFileNames);
    in
    lib.concatStringsSep "\n" (luaConfigs);
  };
}

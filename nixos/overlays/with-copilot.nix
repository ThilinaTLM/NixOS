self: super:
let 
    pluginUrl = "https://plugins.jetbrains.com/files/17718/440843/github-copilot-intellij-1.4.2.3864.zip?updateId=440843&pluginId=17718&family=INTELLIJ";
    plugin = super.fetchurl {
      url = pluginUrl;
      sha256 = "sha256-A9IJ5QYuWczjQXdovvqJO3Tv5sU7FITAjzidDSjPfh0=";
    };
    libPath = super.lib.makeLibraryPath [super.glibc super.gcc-unwrapped];
    modifyIDE = idePkg: idePkg.overrideAttrs (oldAttrs: {
      postInstall = let 
        ideName =  idePkg.pname;
      in 
        ''
          unzip ${plugin} -d $out/${ideName}/plugins
          agent="$out/${ideName}/plugins/github-copilot-intellij/copilot-agent/bin/copilot-agent-linux"
          orig_size=$(stat --printf=%s $agent)
          patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $agent
          patchelf --set-rpath ${libPath} $agent
          chmod +x $agent
          new_size=$(stat --printf=%s $agent)
          var_skip=20
          var_select=22
          shift_by=$(expr $new_size - $orig_size)
          function fix_offset {
            # $1 = name of variable to adjust
            location=$(grep -obUam1 "$1" $agent | cut -d: -f1)
            location=$(expr $location + $var_skip)
            value=$(dd if=$agent iflag=count_bytes,skip_bytes skip=$location \
              bs=1 count=$var_select status=none)
            value=$(expr $shift_by + $value)
            echo -n $value | dd of=$agent bs=1 seek=$location conv=notrunc
          }
          fix_offset PAYLOAD_POSITION
          fix_offset PRELUDE_POSITION
        '';
    });
in {
  with-copilot = idePkg: modifyIDE idePkg;
}
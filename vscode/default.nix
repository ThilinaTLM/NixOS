{
  userSettings = {
    "workbench.colorTheme" = "Default Dark Modern";
    "workbench.iconTheme" = "material-icon-theme";
    "editor.inlineSuggest.enabled" = true;
    "files.autoSave" = "afterDelay";
    "editor.fontFamily" =
      "'IosevkaTerm Nerd Font', 'Droid Sans Mono', 'monospace', monospace";
  };
  keybindings = [
    {
      key = "ctrl+j";
      command = "-workbench.action.togglePanel";
    }
    {
      key = "ctrl+j";
      command = "editor.action.inlineSuggest.commit";
      when = "inlineSuggestionHasIndentationLessThanTabSize && inlineSuggestionVisible && !editorHoverFocused && !editorTabMovesFocus && !suggestWidgetVisible";
    }
    {
      key = "tab";
      command = "-editor.action.inlineSuggest.commit";
      when = "inlineSuggestionHasIndentationLessThanTabSize && inlineSuggestionVisible && !editorHoverFocused && !editorTabMovesFocus && !suggestWidgetVisible";
    }
  ];
}

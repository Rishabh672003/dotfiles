local status_ok, catppuccin = pcall(require, "catppuccin")
if not status_ok then
  return
end


catppuccin.setup({
  styles = { "italic", "bold" },
  integrations = {
    telescope = true,
  },
  custom_highlights = {
    WhichKeyGroup = { fg = "#FAB387" },
    WhichKeySeparator = { fg = "#cdd6f4" },
  },
})

lvim.colorscheme = "catppuccin"

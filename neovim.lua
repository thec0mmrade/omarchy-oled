return {
  {
    "scottmckendry/cyberdream.nvim",
    priority = 1000,
    opts = {
      transparent = true,
      theme = {
        overrides = function(colors)
          return {
            Normal = { bg = "#000000" },
            NormalFloat = { bg = "#000000" },
          }
        end,
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "cyberdream",
    },
  },
}

return {
  {
    "scottmckendry/cyberdream.nvim",
    priority = 1000,
    opts = {
      transparent = true,
      theme = {
        overrides = function(colors)
          return {
            Normal = { bg = "#FFFFFF" },
            NormalFloat = { bg = "#FFFFFF" },
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

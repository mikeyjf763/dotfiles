-- lua/plugins/colorizer.lua
-- Highlights colour literals (#rrggbb, rgb(), hsl(), named CSS colours, etc.)
-- directly in the buffer using the actual colour as the highlight background.
return {
  "NvChad/nvim-colorizer.lua",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("colorizer").setup({
      -- Default options applied to every file type.
      user_default_options = {
        RGB = true,        -- #RGB hex codes
        RRGGBB = true,     -- #RRGGBB hex codes
        names = false,     -- named colours like "Red" (can be noisy; flip to true if you want)
        RRGGBBAA = true,   -- #RRGGBBAA hex codes
        rgb_fn = true,     -- CSS rgb() and rgba() functions
        hsl_fn = true,     -- CSS hsl() and hsla() functions
        css = false,       -- enable all CSS features at once (overrides above flags)
        mode = "background", -- "background" | "foreground" | "virtualtext"
        tailwind = false,  -- highlight Tailwind class names (set true if you use Tailwind)
      },
      -- Override options per file type if needed, e.g.:
      -- filetypes = { "css", html = { names = true } },
      filetypes = { "*" }, -- enable for every file type
    })
  end,
}

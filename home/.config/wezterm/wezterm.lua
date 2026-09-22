local wezterm = require("wezterm")

local config = wezterm.config_builder()

local appearance = wezterm.gui.get_appearance()
config.color_scheme = appearance:find("Dark")
  and "Rosé Pine Moon (Gogh)"
  or "One Light (Gogh)"
config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 15.0
config.window_background_opacity = 0.8
config.macos_window_background_blur = 50
-- The native/fancy tab bar follows macOS chrome instead of color_scheme.
-- Render tabs with the selected light/dark scheme so they match the panes.
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

-- Herdr 0.9.1 follows the xterm color-scheme report, which this older
-- WezTerm build does not emit. Send the standard report whenever WezTerm
-- reloads its config (including after a macOS appearance change).
wezterm.on("window-config-reloaded", function(window, pane)
  local appearance = window:get_appearance()
  local scheme = appearance:find("Dark") and "1" or "2"
  window:perform_action(wezterm.action.SendString("\x1b[?997;" .. scheme .. "n"), pane)
end)

-- Dim unfocused windows so the focused one is obvious at a glance.
local UNFOCUSED_FOREGROUND_TEXT_HSB = { hue = 1.0, saturation = 0.25, brightness = 0.45 }
local UNFOCUSED_WINDOW_BACKGROUND_OPACITY = 0.62

-- get_config_overrides() hands back a copy, so the current value is never the
-- same table we last stored; compare the fields instead of the identity.
local function same_text_hsb(actual, expected)
  if actual == nil or expected == nil then
    return actual == expected
  end
  return actual.hue == expected.hue
    and actual.saturation == expected.saturation
    and actual.brightness == expected.brightness
end

wezterm.on("window-focus-changed", function(window)
  local overrides = window:get_config_overrides() or {}
  local text_hsb, opacity
  if not window:is_focused() then
    text_hsb = UNFOCUSED_FOREGROUND_TEXT_HSB
    opacity = UNFOCUSED_WINDOW_BACKGROUND_OPACITY
  end

  -- Only write when one of the two values we own actually changes; a redundant
  -- set_config_overrides() call would trigger another config reload.
  if same_text_hsb(overrides.foreground_text_hsb, text_hsb) and overrides.window_background_opacity == opacity then
    return
  end

  overrides.foreground_text_hsb = text_hsb
  overrides.window_background_opacity = opacity
  window:set_config_overrides(overrides)
end)

return config

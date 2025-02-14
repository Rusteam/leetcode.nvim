local Page = require("leetcode-ui.group.page")
local Title = require("leetcode-ui.lines.title")
local Buttons = require("leetcode-ui.group.buttons.menu")
local Header = require("leetcode-ui.lines.menu-header")
local Footer = require("leetcode-ui.lines.footer")

local Button = require("leetcode-ui.lines.button.menu")
local ExitButton = require("leetcode-ui.lines.button.menu.exit")

local cmd = require("leetcode.command")
local config = require("leetcode.config")

local page = Page()

page:insert(Header())

page:insert(Title({}, "Sign in"))

local problems = Button("Sign in (By Cookie)", {
    icon = "󱛖",
    sc = "s",
    on_press = cmd.cookie_prompt,
})

local exit = ExitButton()

page:insert(Buttons({
    problems,
    exit,
}))

local footer = Footer()
footer:append("leetcode." .. config.domain)
page:insert(footer)

return page

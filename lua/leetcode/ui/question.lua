local path = require("plenary.path")
local config = require("leetcode.config")
local log = require("leetcode.logger")
local Description = require("leetcode.ui.description")
local api_question = require("leetcode.api.question")
local Console = require("leetcode.ui.console")
local spinner = require("leetcode.logger.spinner")

---@class lc.Question
---@field file Path
---@field q question_response
---@field description lc.Description
---@field bufnr integer
---@field console lc.Console
local question = {}
question.__index = question

---@type table<integer, lc.Question>
QUESTIONS = {}

---@type integer
CURR_QUESTION = 0

---@type integer, integer
QUEST_WINID = nil
DESC_WINID = nil
TABPAGE = nil

---@private
function question:create_file()
    local snippets = self.q.code_snippets

    local snippet = {}

    for _, snip in pairs(snippets ~= vim.NIL and snippets or {}) do
        if snip.lang_slug == config.user.lang or snip.lang_slug == config.user.sql then
            snippet.code = snip.code
            snippet.lang = snip.lang_slug
            break
        end
    end

    if not snippet then return log.error("failed to fetch code snippet") end

    self.file:write(snippet.code, "w")
end

function question:mount()
    if not self.file:exists() then self:create_file() end

    vim.api.nvim_set_current_dir(self.file:parent().filename)
    vim.cmd("$tabe " .. self.file:absolute())
    TABPAGE = vim.api.nvim_get_current_tabpage()

    self.bufnr = vim.api.nvim_get_current_buf()
    CURR_QUESTION = self.bufnr
    QUESTIONS[CURR_QUESTION] = self

    self.description = Description:init(self)
    self.console = Console:init(self)

    self:autocmds()
    return self
end

function question:autocmds()
    local group_id = vim.api.nvim_create_augroup("leetcode_question", { clear = true })

    vim.api.nvim_create_autocmd("BufWinEnter", {
        group = group_id,
        buffer = self.bufnr,
        callback = function() self.description.split:show() end,
    })

    vim.api.nvim_create_autocmd("BufWinLeave", {
        group = group_id,
        buffer = self.bufnr,
        callback = function() self.description.split:hide() end,
    })
end

---@param problem lc.Problem
function question:init(problem)
    -- local noti = spinner:init()
    local q = api_question.by_title_slug(problem.title_slug)
    -- noti:stop(nil, true)

    local dir = config.directory
    local fn = string.format("%s.%s.%s", q.frontend_id, q.title_slug, config.lang)

    local obj = setmetatable({
        file = path:new(dir .. fn),
        q = q,
    }, self)

    return obj:mount()
end

return question

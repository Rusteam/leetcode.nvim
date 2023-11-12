local log = require("leetcode.logger")

local utils = require("leetcode.api.utils")
local config = require("leetcode.config")
local spinner = require("leetcode.logger.spinner")

---@class lc.Interpreter
local interpreter = {}

local check_state = {
    ["PENDING"] = "Pending…",
    ["STARTED"] = "Judging…",
    ["SUCCESS"] = "Finished",
    ["FAILURE"] = "Failed", -- CODE: 16
}

---@param id string
---@param callback function
function interpreter.listener(id, callback)
    local noti = spinner:init(check_state["PENDING"], "points")

    local function listen()
        interpreter.check(id, function(item)
            if item.status_code then
                noti:stop(item.status_msg, false)
                callback(item)
                return
            end

            noti:update(check_state[item.state])

            if item.state == "PENDING" then
                noti:change("points")
            elseif item.state == "STARTED" then
                noti:change("dot")
            end

            vim.defer_fn(listen, 500)
        end)
    end

    listen()
end

---@class lc.Interpret.body
---@field question lc.question_res
---@field typed_code string
---@field data_input string

---@param title_slug string
---@param body lc.Interpret.body
---@param callback function
function interpreter.interpret_solution(title_slug, body, callback)
    local url = (config.domain .. "/problems/%s/interpret_solution/"):format(title_slug)
    local res = interpreter.fetch(url, body)

    if res then interpreter.listener(res.interpret_id, callback) end
end

function interpreter.submit(title_slug, body, callback)
    local url = (config.domain .. "/problems/%s/submit/"):format(title_slug)
    local res = interpreter.fetch(url, body)

    if res then interpreter.listener(res.submission_id, callback) end
end

---@param id string
---@param cb function
---
---@return lc.Interpreter.Response
function interpreter.check(id, cb)
    local url = (config.domain .. "/submissions/detail/%s/check/"):format(id)
    utils.get(url, cb)
end

function interpreter.fetch(url, body)
    local res, err = utils.post(url, body)

    if err then
        if err.status == 429 then log.warn("You have attempted to run code too soon") end
        return
    end

    return res
end

return interpreter

local options = {
	delay = 25,
	message = "该休息了",
	snooze = 5,
}

local timer_running = false

local win_id = nil
local check_time
local target_time

local timer = vim.loop.new_timer()

local function start_timer(minutes)
	-- os.time()返回当前时间的时间戳，单位为秒,从1970年1月1日00:00:00到现在的秒数
	timer:stop()
	target_time = os.time() + minutes * 60
	-- vim.defer_fn(check_time, minutes * 1000 * 60)
	timer:start(minutes * 60 * 1000, 0, vim.schedule_wrap(check_time))
end

local function close_window()
	if win_id and vim.api.nvim_win_is_valid(win_id) then
		local buf_id = vim.api.nvim_win_get_buf(win_id)
		vim.api.nvim_win_close(win_id, true)
		win_id = nil
		vim.api.nvim_buf_delete(buf_id, { force = true })
	end
end

local function open_window()
	vim.api.nvim_set_hl(0, "RealTimeAlert", { fg = "#f5f5f5", bg = "#dc2626", bold = true })
	if win_id and vim.api.nvim_win_is_valid(win_id) then
		return
	end

	if vim.fn.mode() == "c" then
		return
	end

	-- Default to regular delay if closed unexpectedly
	local next_duration = options.delay

	-- false表示非列表缓冲区，true表示不可修改缓冲区
	local buf = vim.api.nvim_create_buf(false, true)
	local text = {
		"╔════════════════════════╗",
		"║      休息时间到！      ║",
		"║  该放松一下眼睛和身体  ║",
		"╚════════════════════════╝",
		"在normal模式下按q退出",
		"再工作五分钟请按下s",
	}
	-- 第一个参数buf是缓冲区ID，第二个参数是起始行，第三个参数是结束行，第四个参数表示是否严格按字节数插入，第五个参数是要插入的文本行的表
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, text)

	local width = 30
	local height = 10
	local row = math.floor((vim.o.lines - height) / 2) -- vim.o.lines获取当前窗口的行数
	local col = math.floor((vim.o.columns - width) / 2) -- vim.o.columns获取当前窗口的列数

	local win_opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	}
	-- 第一个参数buf是缓冲区ID，第二个参数是布尔值表示是否进入窗口，第三个参数是窗口选项
	win_id = vim.api.nvim_open_win(buf, true, win_opts)
	vim.api.nvim_set_option_value("winhighlight", "Normal:RealTimeAlert,FloatBorder:RealTimeAlert", { win = win_id })

	vim.api.nvim_create_autocmd("WinClosed", {
		pattern = tostring(win_id),
		callback = function()
			win_id = nil
			-- Cleanup buffer if it still exists (e.g. if closed via :q)
			if vim.api.nvim_buf_is_valid(buf) then
				vim.schedule(function()
					pcall(vim.api.nvim_buf_delete, buf, { force = true })
				end)
			end

			-- Only restart timer if Rest time is still enabled
			if timer_running then
				start_timer(next_duration)
			end
		end,
		once = true,
	})

	vim.keymap.set("n", "q", function()
		next_duration = options.delay
		close_window()
	end, { buffer = buf, nowait = true, silent = true }) -- nowait表示不等待其他按键，silent表示不显示命令行信息
	vim.keymap.set("n", "s", function()
		next_duration = options.snooze
		close_window()
	end, { buffer = buf, nowait = true, silent = true })
end

function check_time()
	if not timer_running then
		return
	end
	-- vim.notify(options.message, vim.log.levels.WARN)
	open_window()
end

local M = {}

function M.setup(opts)
	opts = opts or {}
	options = vim.tbl_deep_extend("force", options, opts)
	vim.api.nvim_create_user_command("RestEnable", M.start, { desc = "启动休息提醒" })
	vim.api.nvim_create_user_command("RestStop", function()
		M.stop()
		vim.notify("Rest time已关闭", vim.log.levels.INFO)
	end, { desc = "停止休息提醒" })
	vim.api.nvim_create_user_command("RestStatus", M.status, { desc = "查看休息提醒状态" })
	M.start()
end

function M.start()
	M.stop()
	timer_running = true
	vim.notify("Rest time已经启动", vim.log.levels.INFO)
	if type(options.delay) ~= "number" then
		vim.notify("间隔时间必须是数字", vim.log.levels.ERROR)
	else
		start_timer(options.delay)
	end
end

function M.stop()
	timer_running = false
	close_window()
end

function M.status()
	if not timer_running then
		vim.notify("Rest time未启动", vim.log.levels.INFO)
	else
		local remaining = target_time - os.time()
		if remaining >= 0 then
			local minutes = math.floor(remaining / 60)
			local seconds = remaining % 60
			vim.notify(
				string.format("Rest time已启动，距离下次休息还有 %d 分 %d 秒", minutes, seconds),
				vim.log.levels.INFO
			)
		else
			local overdue = math.abs(remaining)
			local minutes = math.floor(overdue / 60)
			local seconds = overdue % 60
			vim.notify(
				string.format("Rest time已启动，休息时间已过 %d 分 %d 秒！请尽快休息。", minutes, seconds),
				vim.log.levels.WARN
			)
		end
	end
end

return M

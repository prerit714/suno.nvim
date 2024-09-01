local M = {}

-- Most used constant in this file
M.__SUNO = "Suno"

-- A table for supported filetypes
M.__supported_filetypes = {
	"c",
	"cpp",
	"java",
	"go",
	"rs",
	"lua",
}

---Checks if suno supports the given filetype
---@param ext string
M.__is_a_supported_filetype = function(ext)
	for _, filetype in ipairs(M.__supported_filetypes) do
		if filetype == ext then
			return true
		end
	end
	return false
end

-- Perform operations if cpp filetype is identified
M.__handle_cpp = function()
	local build_and_run_cpp = function()
		local current_time = vim.fn.reltimefloat(vim.fn.reltime())
		print("[Suno] I am running: " .. current_time)
	end

	vim.api.nvim_create_autocmd("BufWritePost", {
		group = M.__SUNO,
		pattern = "*.cpp",
		callback = build_and_run_cpp,
	})
end

-- Internal main function
M.__main = function()
	-- Get the filetype on which the :Suno command was spawned
	local current_filetype = vim.bo.filetype
	-- Check if it is supported currently
	local is_current_filetype_supported = M.__is_a_supported_filetype(current_filetype)

	-- Now to perform some nil guards
	if current_filetype == "" then
		print("[Suno] Can't suno an unknown filetype :(")
		return
	end

	if not is_current_filetype_supported then
		print("[Suno] I currently don't support " .. current_filetype .. ", Make sure to check later on :)")
		return
	end

	print("[Suno] I am ready :)")

	if current_filetype == "cpp" then
		M.__handle_cpp()
	else
		-- TODO: Handle other filetypes
		error("[Suno] Implementation for " .. current_filetype .. " is still in progress :)")
		return
	end
end

---Setup function as per the requirement of lazy.nvim
---@param opts any
M.setup = function(opts)
	-- Perform some assert checks
	if type(opts) ~= "table" then
		error("[Suno] opts can only be a lua table ...")
		return
	end

	-- Make a neovim function to launch suno's main
	vim.api.nvim_create_user_command(M.__SUNO, M.__main, {
		desc = "[Suno] Suno your current filetype!",
	})

	-- Create an autocommand group for Suno
	vim.api.nvim_create_augroup(M.__SUNO, {
		clear = true,
	})
end

return M

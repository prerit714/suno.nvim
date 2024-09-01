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

---Returns true if the file at given path exist, else false
---@param filepath string
M.__does_file_exist = function(filepath)
	local file = io.open(filepath, "r")
	if file then
		file:close()
		return true
	end
	return false
end

---Creates the file if it does not exist
---@param filepath string
M.__create_file_if_it_does_not_exist = function(filepath)
	if not M.__does_file_exist(filepath) then
		local file = io.open(filepath, "w")
		if file then
			file:close()
		else
			print("[Suno] I not able to create " .. filepath)
		end
	end
end

---Returns the file size if file is found, else returns zero
---@param filepath string
---@return integer
M.__get_file_size = function(filepath)
	local file = io.open(filepath, "r")
	if file then
		local size = file:seek("end")
		file:close()
		return size
	end
	return 0
end

-- Perform operations if cpp filetype is identified
M.__handle_cpp = function()
	local debounce_time = 500 -- In milliseconds
	local last_save_time = 0
	local temp_dir = "suno_temp"
	local temp_exec = temp_dir .. "/temp_exec"
	local input_file = "input.txt"
	local output_file = "output.txt"
	local max_output_size = 1024 * 1024 * 5 -- Max output file size in bytes (e.g., 5 MB)

	local build_and_run_cpp = function()
		-- Full path to the current file
		local current_file = vim.fn.expand("%:p")

		-- Debounce logic
		local current_time = vim.fn.reltimefloat(vim.fn.reltime())

		if current_time - last_save_time < debounce_time / 1000 then
			-- Do not do the save and run task
			return
		end

		last_save_time = current_time -- update the last save time in memory
		print("[Suno] Compiling and running your c++ file ... :)")

		-- Check if the g++ executable exists
		if vim.fn.executable("g++") == 0 then
			print("[Suno] g++ executable was not found! ensure its installation :|")
			return
		end

		-- if the temp directory does not exist, create one
		if vim.fn.isdirectory(temp_dir) == 0 then
			vim.fn.mkdir(temp_dir, "p")
		end

		-- Create input.txt and output.txt if they do not already exist
		M.__create_file_if_it_does_not_exist(input_file)
		M.__create_file_if_it_does_not_exist(output_file)

		-- Define the command to build and run the c++ file
		local build_command = string.format("g++ -std=c++17 -g %s -o %s", current_file, temp_exec)
		local run_command = string.format("./%s < %s > %s 2>&1", temp_exec, input_file, output_file)

		-- Execute the build and run command
		vim.fn.system(build_command)

		-- Start running the program and monitor the output size
		local job_id = nil

		job_id = vim.fn.jobstart(run_command, {
			on_stdout = function(_, data, _)
				if data then
					local size = M.__get_file_size(output_file)
					if size > max_output_size and job_id then
						vim.fn.jobstop(job_id)
						print("[Suno] Memory overflow!, looks like your program is in an infite loop printing stuff :|")
					end
				end
			end,
			on_stderr = function(_, data, _)
				if data then
					-- TODO: Do something in case of std_error
					return
				end
			end,
			on_exit = function(_, exit_code, _)
				if exit_code == 124 then
					print("[Suno] Execution timeout! Check if your code has any infinite loop :|")
				elseif exit_code == 137 then
					print("[Suno] I have killed the watch process due to excessive output.")
				end
			end,
		})

		-- Print the final message
		print("[Suno] Done. OK :)")
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
		print(
			"[Suno] Implementation for "
				.. current_filetype
				.. " is still in progress it should be there in the later versions :P"
		)
		return
	end
end

---Setup function as per the requirement of lazy.nvim
M.setup = function()
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

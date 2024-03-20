-- Pretty prints a Lua object.
---@param object any
---@return any
function P(object)
	print(vim.inspect(object))
	return object
end

---@return string|osdate date Today's date in "yyyy Jan dd" format
function Date()
	return os.date('%Y %b %d')
end

-- Deletes starting and ending blank lines in the current buffer. For example,
-- for the following buffer,
-- ```
--1
--2 A line containing non-space characters.
--3
--4 Another line.
--5
--6
--7
-- ```
-- Trim_peripheral_blank_lines() will delete four lines: one at the start (line
-- 1) and three at the end (lines 5, 6, and 7).
function Trim_peripheral_blank_lines()
	local curbuf = vim.fn.bufnr()
	local total_lines = vim.fn.line('$')

	local n_starting_blank_lines = 0
	for i = 1, total_lines do
		if string.match(vim.fn.getline(i), '%S') then
			break
		end
		n_starting_blank_lines = n_starting_blank_lines + 1
	end

	local n_ending_blank_lines = 0
	if n_starting_blank_lines ~= total_lines then
		for i = total_lines, 1, -1 do
			if string.match(vim.fn.getline(i), '%S') then
				break
			end
			n_ending_blank_lines = n_ending_blank_lines + 1
		end
	end

	-- Delete ending lines first; doing the reverse messes the line count
	-- for the ending lines.
	vim.fn.deletebufline(curbuf, total_lines - n_ending_blank_lines + 1, total_lines)
	vim.fn.deletebufline(curbuf, 1, n_starting_blank_lines)

	local n_lines_deleted = n_starting_blank_lines + n_ending_blank_lines

	if n_lines_deleted == total_lines then
		vim.cmd.echomsg '"--No lines in buffer--"'
	elseif n_lines_deleted > vim.o.report then
		vim.cmd.echomsg((n_lines_deleted == 1)
			and n_lines_deleted .. ' "line less"'
			or n_lines_deleted .. ' "fewer lines"')
	end
end

-- Deletes trailing whitespace in the current buffer.
function Trim_trailing_whitespace()
	local save_view = vim.fn.winsaveview()
	local save_search = vim.fn.getreg('/')
	vim.cmd([[%substitute/\v\s+$//e]])
	vim.fn.winrestview(save_view)
	vim.fn.setreg('/', save_search)
end

-- Sets the values for the "ifndef" guard in the current file based on the
-- file's name and current date (yyyymmdd).
function Set_header_macros()
	local macro_name = string.gsub(string.upper(vim.fn.expand('%:t')),
					'%.', '_' .. os.date('%Y%m%d') .. '_')
	vim.fn.setline(1, vim.fn.getline(1) .. macro_name)
	vim.fn.setline(2, vim.fn.getline(2) .. macro_name)
	vim.fn.setline(vim.fn.line('$'), vim.fn.getline('$') .. ' //' .. macro_name)
end

-- Updates the date found after the first occurrence of the string
-- "Last change:" in the first 20 lines of the current file. The format of the
-- new date may be specified (see strftime() for valid formats). If no format
-- is given, the date returned by Date() is used.
---@param format? string Format of the new date
function Update_last_change(format)
	local pat = 'Last [Cc]hange:'
	local limit = 20
	if vim.fn.line('$') < limit then
		limit = vim.fn.line('$')
	end
	for i = 1, limit do
		local line = vim.fn.getline(i)
		if string.match(line, pat) then
			local c = ''
			if not string.match(line, pat .. '%s') then
				c = '\t'
			end
			local updated_line = string.gsub(line, '(' .. pat .. ')%s*.*$',
				'%1' .. c .. (format and os.date(format) or Date()))
			vim.fn.setline(i, updated_line)
			break
		end
	end
end

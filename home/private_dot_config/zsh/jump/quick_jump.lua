local jump, home = {}, os.getenv('HOME')
local cache_home = os.getenv('XDG_CACHE_HOME') or (home .. '/.cache')
local file_path = cache_home .. '/zsh/quick_jump_list'

local function ensure_parent_dir(path)
  local dir = path:match('(.+)/[^/]+$')
  if dir then
    os.execute('mkdir -p "' .. dir .. '"')
  end
end

local function read_jump_list()
  local file = io.open(file_path, 'r')
  if not file then
    return
  end

  for line in file:lines() do
    local st, ed = string.find(line, ':')
    local keyword = string.sub(line, 1, st - 1)
    local dir = string.sub(line, ed + 1)
    jump[keyword] = dir
  end

  io.close(file)
end

local function add_jump_list(keyword, dir)
  ensure_parent_dir(file_path)
  local file = io.open(file_path, 'a')
  if not file then
    return
  end

  file:write(keyword .. ':' .. dir .. '\n')
  io.close(file)
end

read_jump_list()

local opt = arg[1]
if opt == nil then
  print('~')
elseif opt == '-l' then
  for v, _ in pairs(jump) do
    print(v)
  end
elseif opt == '-a' then
  -----@diagnostic disable-next-line: param-type-mismatch
  arg[3] = string.gsub(arg[3], home, '~', 1)
  add_jump_list(arg[2], arg[3])
elseif jump[opt] == nil then
  print(opt)
else
  print(jump[opt])
end

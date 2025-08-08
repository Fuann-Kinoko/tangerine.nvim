local env = require("tangerine.utils.env")
local p = {}
local win32_3f = (_G.jit.os == "Windows")
p.match = function(path, pattern)
  _G.assert((nil ~= pattern), "Missing argument pattern on fnl/tangerine/utils/path.fnl:18")
  _G.assert((nil ~= path), "Missing argument path on fnl/tangerine/utils/path.fnl:18")
  local _1_
  if win32_3f then
    _1_ = path:gsub("\\", "/")
  else
    _1_ = path
  end
  return _1_:match(pattern)
end
p.gsub = function(path, pattern, repl)
  _G.assert((nil ~= repl), "Missing argument repl on fnl/tangerine/utils/path.fnl:22")
  _G.assert((nil ~= pattern), "Missing argument pattern on fnl/tangerine/utils/path.fnl:22")
  _G.assert((nil ~= path), "Missing argument path on fnl/tangerine/utils/path.fnl:22")
  local _3_
  if win32_3f then
    _3_ = path:gsub("\\", "/")
  else
    _3_ = path
  end
  return _3_:gsub(pattern, repl)
end
p.shortname = function(path)
  _G.assert((nil ~= path), "Missing argument path on fnl/tangerine/utils/path.fnl:26")
  return (p.match(path, ".+/fnl/(.+)") or p.match(path, ".+/lua/(.+)") or p.match(path, ".+/(.+/.+)"))
end
p.resolve = function(path)
  _G.assert((nil ~= path), "Missing argument path on fnl/tangerine/utils/path.fnl:32")
  return vim.fn.resolve(vim.fn.expand(path))
end
local vimrc_out = (env.get("target") .. "tangerine_vimrc.lua")
local function esc_regex(str)
  _G.assert((nil ~= str), "Missing argument str on fnl/tangerine/utils/path.fnl:42")
  return str:gsub("[%%%^%$%(%)%[%]%{%}%.%*%+%-%?]", "%%%1")
end
p["transform-path"] = function(path, _5_, _7_)
  local _arg_6_ = _5_
  local key1 = _arg_6_[1]
  local ext1 = _arg_6_[2]
  local _arg_8_ = _7_
  local key2 = _arg_8_[1]
  local ext2 = _arg_8_[2]
  _G.assert((nil ~= ext2), "Missing argument ext2 on fnl/tangerine/utils/path.fnl:46")
  _G.assert((nil ~= key2), "Missing argument key2 on fnl/tangerine/utils/path.fnl:46")
  _G.assert((nil ~= ext1), "Missing argument ext1 on fnl/tangerine/utils/path.fnl:46")
  _G.assert((nil ~= key1), "Missing argument key1 on fnl/tangerine/utils/path.fnl:46")
  _G.assert((nil ~= path), "Missing argument path on fnl/tangerine/utils/path.fnl:46")
  local from
  if win32_3f then
    from = (("^" .. esc_regex(env.get(key1)))):gsub("\\", "/")
  else
    from = ("^" .. esc_regex(env.get(key1)))
  end
  local to
  if win32_3f then
    to = esc_regex(env.get(key2)):gsub("\\", "/")
  else
    to = esc_regex(env.get(key2))
  end
  local path0
  if win32_3f then
    path0 = path:gsub(("%." .. ext1 .. "$"), ("." .. ext2)):gsub("\\", "/")
  else
    path0 = path:gsub(("%." .. ext1 .. "$"), ("." .. ext2))
  end
  if path0:find(from) then
    return path0:gsub(from, to)
  else
    return p.gsub(path0, ("/" .. ext1 .. "/"), ("/" .. ext2 .. "/"))
  end
end
p.target = function(path)
  _G.assert((nil ~= path), "Missing argument path on fnl/tangerine/utils/path.fnl:55")
  local vimrc = env.get("vimrc")
  if (path == vimrc) then
    return vimrc_out
  else
    return p["transform-path"](path, {"source", "fnl"}, {"target", "lua"})
  end
end
p.source = function(path)
  _G.assert((nil ~= path), "Missing argument path on fnl/tangerine/utils/path.fnl:62")
  local vimrc = env.get("vimrc")
  if (path == vimrc_out) then
    return vimrc
  else
    return p["transform-path"](path, {"target", "lua"}, {"source", "fnl"})
  end
end
p["goto-output"] = function()
  local source = vim.fn.expand("%:p")
  local target = p.target(source)
  if ((1 == vim.fn.filereadable(target)) and (source ~= target)) then
    return vim.cmd(("edit" .. target))
  elseif "else" then
    return print("[tangerine]: error in goto-output, target not readable.")
  else
    return nil
  end
end
p.wildcard = function(dir, pat)
  _G.assert((nil ~= pat), "Missing argument pat on fnl/tangerine/utils/path.fnl:87")
  _G.assert((nil ~= dir), "Missing argument dir on fnl/tangerine/utils/path.fnl:87")
  return vim.fn.glob((dir .. pat), 0, 1)
end
return p

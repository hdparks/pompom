# pompom
Task Tracker 


# config
Recommended config:

```lua
vim.api.nvim_create_user_command("PomPomList",function(opts) require('pompom').use_list(opts.fargs[1]) end,{nargs=1})
```

return {
  -- Theme
  {
    "catppuccin/nvim",
    opts = {
      auto_integrations = true,
      flavor = "mocha",
      transparent_background = true,
    },
  },

  -- LazyVim colorscheme
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "catppuccin" },
  },

  -- Dashboard (snacks.nvim)
  {
    "folke/snacks.nvim",
    opts = (function()
      local M = {}

      -- Centralized, tweakable defaults
      local opts = {
        width = 60,
        pane_gap = 4,
        image_path = vim.fn.expand("~/.config/nvim/resources/misato.jpg"),
        chafa = {
          format = "symbols",
          symbols = "vhalf",
          size = "60x17",
          stretch = true,
        },
        preset_keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      }

      -- Helpers
      local function file_sha(path)
        if vim.fn.executable("sha1sum") == 1 then
          local out = vim.fn.systemlist({ "sha1sum", path })[1] or ""
          return out:match("^([a-fA-F0-9]+)")
        elseif vim.fn.executable("shasum") == 1 then
          local out = vim.fn.systemlist({ "shasum", path })[1] or ""
          return out:match("^([a-fA-F0-9]+)")
        end
        local stat = vim.loop.fs_stat(path)
        return stat and ("mtime_" .. tostring(stat.mtime.sec or stat.mtime.nsec or 0)) or "nohash"
      end

      local function cache_dir()
        local dir = vim.fn.stdpath("cache") .. "/snacks_dashboard"
        if vim.fn.isdirectory(dir) == 0 then
          vim.fn.mkdir(dir, "p")
        end
        return dir
      end

      local function build_chafa_cmd(image_path, cfg)
        if vim.fn.executable("chafa") ~= 1 or vim.fn.filereadable(image_path) == 0 then
          local msg = (vim.fn.executable("chafa") ~= 1) and "chafa not found. Install chafa for image preview."
            or ("Image not found: " .. image_path)
          return string.format([[printf "%s\n"]], vim.fn.escape(msg, [["\]]))
        end

        local stretch_flag = cfg.stretch and "--stretch" or ""
        local size = cfg.size or "60x17"

        local key = table.concat({
          file_sha(image_path),
          cfg.format or "symbols",
          cfg.symbols or "all", -- default to "all"
          size,
          stretch_flag,
        }, "_")

        local dir = cache_dir()
        local cache_file = string.format("%s/%s.ansi", dir, key)

        if vim.fn.filereadable(cache_file) == 1 then
          return string.format("cat %s", vim.fn.shellescape(cache_file))
        end

        local cmd = string.format(
          "chafa %s --format %s --symbols %s --size %s %s > %s && cat %s",
          vim.fn.shellescape(image_path),
          cfg.format,
          cfg.symbols,
          size,
          stretch_flag,
          vim.fn.shellescape(cache_file),
          vim.fn.shellescape(cache_file)
        )
        return cmd
      end

      local function height_from_size(sz)
        local h = tonumber((sz or "60x17"):match("x(%d+)$"))
        return h or 17
      end

      M.dashboard = {
        width = opts.width,
        pane_gap = opts.pane_gap,

        sections = (function()
          local image = vim.g.snacks_dashboard_image_path or opts.image_path
          local cfg = {
            format = vim.g.snacks_dashboard_chafa_format or opts.chafa.format,
            symbols = vim.g.snacks_dashboard_chafa_symbols or opts.chafa.symbols, -- "all"
            size = vim.g.snacks_dashboard_chafa_size or opts.chafa.size,
            stretch = (vim.g.snacks_dashboard_chafa_stretch == nil) and opts.chafa.stretch
              or vim.g.snacks_dashboard_chafa_stretch,
          }

          local cmd = build_chafa_cmd(image, cfg)

          return {
            {
              section = "terminal",
              cmd = cmd,
              height = height_from_size(cfg.size),
              padding = 1,
            },
            {
              pane = 2,
              { section = "keys", gap = 1, padding = 1 },
              { section = "startup" },
            },
          }
        end)(),

        preset = { keys = opts.preset_keys },

        formats = {
          icon = function(item)
            if (item.file and item.icon == "file") or item.icon == "directory" then
              return Snacks.dashboard.icon(item.file, item.icon)
            end
            return { item.icon, width = 2, hl = "icon" }
          end,
          footer = { "%s", align = "center" },
          header = { "%s", align = "center" },
          file = function(item, ctx)
            local fname = vim.fn.fnamemodify(item.file, ":~")
            fname = ctx.width and #fname > ctx.width and vim.fn.pathshorten(fname) or fname
            if #fname > ctx.width then
              local dir = vim.fn.fnamemodify(fname, ":h")
              local file = vim.fn.fnamemodify(fname, ":t")
              if dir and file then
                file = file:sub(-(ctx.width - #dir - 2))
                fname = dir .. "/…" .. file
              end
            end
            local dir, file = fname:match("^(.*)/(.+)$")
            return dir and { { dir .. "/", hl = "dir" }, { file, hl = "file" } } or { { fname, hl = "file" } }
          end,
        },
      }

      return { dashboard = M.dashboard }
    end)(),
  },
}

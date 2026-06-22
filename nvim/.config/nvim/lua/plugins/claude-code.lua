local toggle_key = "<C-M-,>"  -- Alt/Meta + comma

return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = {
    git_repo_cwd = true,
    terminal_cmd = "~/.local/bin/claude", -- Point to local installation
    terminal = {
        snacks_win_opts = {
          position = "float",
          width = 0.8,
          height = 0.8,
          border = "rounded",
          keys = {
            claude_hide = { toggle_key, function(self) self:hide() end, mode = "t", desc = "Hide" },
          },
        },
      },
  },
  diff_opts = {
    layout = "vertical", -- "vertical" or "horizontal" diff layout
    open_in_new_tab = true, -- Open diff in a new tab (false = use current tab)
    keep_terminal_focus = false, -- Keep focus in terminal after opening diff
    hide_terminal_in_new_tab = true, -- Hide Claude terminal in the new diff tab for more review space
  },
  config = true,
  keys = {
    { toggle_key, "<cmd>ClaudeCodeFocus<cr>", desc = "Claude Code", mode = { "n", "x" } },
    { "<leader>a", nil, desc = "AI/Claude Code" },
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
    },
    -- Diff management
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
}

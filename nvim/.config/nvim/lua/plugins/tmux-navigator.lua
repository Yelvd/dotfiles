return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Go to left split/pane" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Go to lower split/pane" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Go to upper split/pane" },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Go to right split/pane" },
  },
}

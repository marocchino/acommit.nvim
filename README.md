# acommit.nvim

[acommit](https://github.com/marocchino/acommit)'s nvim plugin. It generates commit message with chatgpt api.

## Installation

Install using your preferred package manager.

Example with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
  {
    "marocchino/acommit.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "tpope/vim-fugitive",
    },
    keys = {
      { "<leader>gc", "<cmd>Gacommit<CR>", silent = true },
    },
  },
```

## Configuration

acommit.nvim comes with the following defaults:

```lua
{
  prompt =
  "You are to act as the author of a commit message in git. Your mission is to create clean and comprehensive commit messages in the gitmoji convention with emoji and explain why a change was done. I'll send you an output of 'git diff --staged' command, and you convert it into a commit message. Add a short description of WHY the changes are done after the commit message. Don't start it with 'This commit', just describe the changes. Use the present tense. Commit title must not be longer than 74 characters.",
  token = os.getenv("OPENAI_API_KEY")
}
```

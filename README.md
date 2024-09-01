# Suno.nvim (In hindi सुनो means "to listen")

**Suno.nvim** is a lightweight Neovim plugin designed to streamline the
process of compiling and running files for supported languages. Currently,
it's optimized for C++ development with plans for future language support.

## Features ✨

- **Automatic Compilation & Execution:** Automatically compiles and runs
  your C++ files every time you save.
- **Debounce Logic:** Avoids unnecessary recompilation by implementing a
  debounce mechanism.
- **Custom Temporary Directory:** Uses a temporary directory `suno_temp` to
  store compiled executables.
- **Output Management:** Manages output through `input.txt` and `output.txt`,
  handling potential overflow with memory checks.

## Competitive Programming 💡

If you are a competitive programmer using C++, this plugin can be especially
useful. It automates the compilation and execution process, allowing you to
focus on solving problems without manually handling build and run commands.

## Installation 🚀

You can install **Suno.nvim** using your favorite plugin manager. Here's how
to do it with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "prerit714/suno.nvim",
  name = "suno",
  lazy = false,
  config = function()
    require("suno").setup()
  end
}
```

## Note 📝

Please pardon any code issues or bugs you might encounter. This project is 
maintained in my spare time, and I may not always have the bandwidth to
address all problems promptly. Additionally, I might not be following all
best Neovim coding practices at the moment, so please pardon that as well.
Contributions are always welcome to help improve the plugin! 😊

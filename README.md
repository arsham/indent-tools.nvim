# Indent Tools

![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/arsham/indent-tools.nvim)
![License](https://img.shields.io/github/license/arsham/indent-tools.nvim)

This Neovim plugin provides mappings and textobj for indentations.

1. [Demo](#demo)
2. [Requirements](#requirements)
3. [Installation](#installation)
   - [Config](#config)
   - [Lazy Loading](#lazy-loading)
4. [License](#license)

## Demo

Jumping along the indents (`[i`, `]i`):

![jumping](https://user-images.githubusercontent.com/428611/148661970-0aad20f2-61ce-4347-8971-6147556a1603.gif)

Text object (`dii`, `yii`, `vii`, etc.):

![textobj](https://user-images.githubusercontent.com/428611/148661973-2d3cccad-715f-4f1e-a277-feb2e85396a9.gif)

## Requirements

This library supports [Neovim
0.7.0](https://github.com/neovim/neovim/releases/tag/v0.7.0) or newer.

This plugin depends are the following libraries. Please make sure to add them
as dependencies in your package manager:

- [arshlib.nvim](https://github.com/arsham/arshlib.nvim)

## Installation

Use your favourite package manager to install this library. Packer example:

```lua
use({
  "arsham/indent-tools.nvim",
  requires = { "arsham/arshlib.nvim" },
  config = function() require("indent-tools").config({}) end,
})
```

### Config

By default this pluging adds all necessary mappings. However you can change or
disable them to your liking.

To disable set them to `false`. For example:

```lua
require("indent-tools").config({
  textobj = false,
})
```

Here is the default settings:

```lua
{
  normal = {
    up   = "[i",
    down = "]i",
  },
  textobj = "ii",
}
```

### Lazy Loading

You can let your package manager to load this plugin when a key-mapping
event is fired. Packer example:

```lua
use({
  "arsham/indent-tools.nvim",
  requires = { "arsham/arshlib.nvim" },
  config = function() require("indent-tools").config({}) end,
  keys = { "]i", "[i", { "v", "ii" }, { "o", "ii" } },
})
```

## License

Licensed under the MIT License. Check the [LICENSE](./LICENSE) file for details.

<!--
vim: foldlevel=1
-->

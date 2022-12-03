# Tokeize

## What is tokeize

While running [tokei](https://github.com/XAMPPRocky/tokei) on my projets I feel like something missing, like a global web interface to explore all the data, to look at them globally, and with some colors.

Tokeize is my own solution to do that.

Basically, tokeize do something simple: it looks at the parent directory, typically the root directory where you put every code project of you, then it lists all the entries, filters them to keep only the directories and the ones you tell it to ignore, and run tokei on every single directory of the remaning list. After that, tokeize builds a nice and self containing webpage called `tokeize_{datetime}.html` in the parent directory, and voilà!

## Installation

To use tokeize you need this:

- node + npm
- [tokei](https://github.com/XAMPPRocky/tokei)
- CoffeeScript install globally (to use cake) (`npm i -g coffeescript`)

After that, you can clone this repository and run `npm i` to install pug, sass, and coffeescript (yes, again, but for the compilation this time).

Note: `npm i` also install sharp, which is used to generate the small colored squares in this doc.

## Usage

To use tokeize just run `cake run` in the project's directory. This will scan the parent directory to list and run tokei on each directories in it. Then it will generate the `tokei_{datetime].html` in the parent directory.

## Configuration

A little bit of configuration is permitted. To do so, you can create a file named `config.coffee` at the project's root. This file is already ignored by git. It looks like this:

```CoffeeScript
exports.config =
  ignore: ['project1', 'project2', 'project3']
  colors:
    'CoffeeScript': 'chocolate'
    'Java': 'olive'
```

The `ignore` entry is a list of every project you want to exclude from the tokei parsing.

The `colors` let you choose a specific color for each language. Right now the default configuration set the color for several languages:

- ![CSS color](./imgs/col_CSS.png) CSS: red
- ![CoffeeScript color](./imgs/col_CoffeeScript.png) CoffeeScript: #a00
- ![JavaScript color](./imgs/col_JavaScript.png) JavaScript: orange
- ![HTML color](./imgs/col_HTML.png) HTML: lime
- ![Markdown color](./imgs/col_Markdown.png) Markdown: #026
- ![Plain Text color](./imgs/col_Plain Text.png) Plain Text: olive
- ![Pug color](./imgs/col_Pug.png) Pug: #fc6
- ![Rust color](./imgs/col_Rust.png) Rust: #544
- ![Sass color](./imgs/col_Sass.png) Sass: #f0e
- ![Scss color](./imgs/col_Scss.png) Scss: #d0c
- ![TOML color](./imgs/col_TOML.png) TOML: #fe3

You can also add a `selected` entry, like that:

```CoffeeScript
exports.config =
  selected: ['../path/to/project1', '../../project2', '../project3']
```

By using the `selected` mode the `ignore` list is, well, ignored, and instead of reading the parent directory each element of the `selected`'s list will be used as a path to a project's directory where you want to run tokei.


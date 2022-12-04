# Tokeize

## What is tokeize

While running [tokei](https://github.com/XAMPPRocky/tokei) on my projets I feel like something missing, like a global web interface to explore all the data, to look at them globally, and with some colors.

Tokeize is my own solution to do that.

Basically, tokeize do something simple: it looks at the parent directory, typically the root directory where you put every code project of you, then it lists all the entries, filters them to keep only the directories and the ones you tell it to ignore, and run tokei on every single directory of the remaning list. After that, tokeize builds a nice and self containing webpage called `tokeize_{datetime}.html` in the parent directory, and voilà!

## Installation

To use tokeize you need this:

- node + npm
- [tokei](https://github.com/XAMPPRocky/tokei)
- [CoffeeScript](https://coffeescript.org/) install globally (to use cake) (`npm i -g coffeescript`)

After that, you can clone this repository and run `npm i` to install [pug](https://pugjs.org/api/getting-started.html), [sass](https://sass-lang.com/), and [coffeescript](https://coffeescript.org/) (yes, again, but for the compilation this time).

Note: `npm i` also install [sharp](https://www.npmjs.com/package/sharp), which is used to generate the small colored squares in this doc.

## Usage

To use tokeize just run `cake run` in the project's directory. This will scan the parent directory to list and run tokei on each directories in it. Then it will generate the `tokei_{datetime].html` in the parent directory.

## Configuration

A little bit of configuration is permitted. To do so, you can create a file named `config.coffee` at the project's root. This file is already ignored by git. It looks like this:

```CoffeeScript
exports.config =
  datetime: false
  out: '../../home/me'
  ignore: ['project1', 'project2', 'project3']
  colors:
    'CoffeeScript': 'chocolate'
    'Java': 'olive'
```

The `colors` let you choose a specific color for each language. Right now the default configuration set the color for several languages:

- ![CSS color](./imgs/col_CSS.png) CSS: tomato
- ![CoffeeScript color](./imgs/col_CoffeeScript.png) CoffeeScript: #a00
- ![JavaScript color](./imgs/col_JavaScript.png) JavaScript: orange
- ![JSON color](./imgs/col_JSON.png) JSON: blueviolet
- ![HTML color](./imgs/col_HTML.png) HTML: lime
- ![Markdown color](./imgs/col_Markdown.png) Markdown: #026
- ![Plain Text color](./imgs/col_Plain_Text.png) Plain Text: olive
- ![Pug color](./imgs/col_Pug.png) Pug: #fc6
- ![Rust color](./imgs/col_Rust.png) Rust: cadetblue
- ![Sass color](./imgs/col_Sass.png) Sass: #f0e
- ![SVG color](./imgs/col_SVG.png) SVG: dogderblue
- ![TOML color](./imgs/col_TOML.png) TOML: #fe3

The `datetime` entry is a boolean to choose between two format for the output name:

- `true` (default): the output file is named `tokeize_{datetime}.html` where `datetime` is replaced by the current date and time like this: `YY-MM-DD_HH-mm-SS`
- `false`: the output file will be named `tokeize.html`, perfect to rewrite the same file again and again

The `ignore` entry is a list of every project you want to exclude from the tokei parsing.

You can also add a `selected` entry, like that:

```CoffeeScript
exports.config =
  selected: ['../path/to/project1', '../../project2', '../project3']
```

By using the `selected` mode the `ignore` list is, well, ignored, and instead of reading the parent directory each element of the `selected`'s list will be used as a path to a project's directory where you want to run tokei.

Finally, the `out` entry let you choose a specific location to save the output file. Note that it doesn't change the name of the file, only where you save it, so be sure it's a directory.



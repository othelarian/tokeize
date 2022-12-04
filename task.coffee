coffee = require 'coffeescript'
fs = require 'fs'
cp = require 'child_process'
nd_path = require 'path'
pug = require 'pug'
sass = require 'sass'
sharp = require 'sharp'

# CONFIG ##############################

blk = ['lines', 'code', 'comments', 'blanks', 'files']

config =
  colors:
    'CSS': 'tomato'
    'CoffeeScript': '#a00'
    'JavaScript': 'orange'
    'JSON': 'blueviolet'
    'HTML': 'lime'
    'Markdown': '#026'
    'Plain Text': 'olive'
    'Pug': '#fc6'
    'Rust': 'cadetblue'
    'Sass': '#f0e'
    'SVG': 'dodgerblue'
    'TOML': '#fe3'
  datetime: true
  ignore: []
  out: '../'

user_config = './config.coffee'

# HELPERS #############################

addColor = (lg, col) ->
  ".rep-#{lg}{background-color:#{col} !important;}.txt-#{lg}{color:#{col};font-weight:bold;}"

genDate = ->
  az = (nb) -> if nb < 10 then "0#{nb}" else nb
  dt = new Date()
  tm = "#{az dt.getHours()}#{az dt.getMinutes()}#{az dt.getSeconds()}"
  "#{dt.getYear()-100}-#{az(dt.getMonth()+1)}-#{az dt.getDate()}_#{tm}"

getConfig = ->
  try
    fs.accessSync user_config
    cfg = require(user_config).config
    if cfg.hasOwnProperty 'colors' then config.colors[key] = val for key, val of cfg.colors
    if cfg.hasOwnProperty 'datetime' then config.datetime = cfg.datetime
    if cfg.hasOwnProperty 'out' then config.out = cfg.out
    if cfg.hasOwnProperty 'selected' then config.selected = cfg.selected
    else if cfg.hasOwnProperty 'ignore' then config.ignore = cfg.ignore

projetAdd = (acc, curr) =>
  (acc[i] += curr[1][i]) for i in [0..4]
  acc

rndP = (v) -> Math.round(v * 10000) / 100

# TASKS ###############################

exports.colorsFn = ->
  st = '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="20px" height="15px">'
  st += '<rect width="30px" height="30px" '
  toImg = (key, val) ->
    name = key.replace ' ', '_'
    sharp(Buffer.from st + "fill='#{val}'/></svg>").toFile "./imgs/col_#{name}.png"
  getConfig()
  toImg key, val for key, val of config.colors

exports.runFn = ->
  # vars declarations
  data = {colors: '', global: {}, projets: [], totals: [0, 0, 0, 0, 0, 0]}
  # helpers
  addPercentGlobal = (key) ->
    toP = (e, i) -> [e, rndP e / data.totals[i]]
    data.global[key].nb = (toP e, i for e, i in data.global[key].nb)
  addPercentProject = (p, pi) ->
    upFileStats = (lg, file, l, i) ->
      n = file.stats[l]
      file.stats[l] = [
        n
        if p[1][lg][l][0] > 0 then rndP(n / p[1][lg][l][0]) else 0
        if p[1].stats[l][0] > 0 then rndP(n / p[1].stats[l][0]) else 0
      ]
      [n, if data.totals[i] > 0 then rndP(n / data.totals[i]) else 0]
    upFile = (lg, file) ->
      file.stats.lines = file.stats.blanks + file.stats.comments + file.stats.code
      nf = {name: file.name, stats: {}}
      (nf.stats[l] = upFileStats lg, file, l, i) for l, i in blk[0..3]
      data.global[lg].projets[p[0]].files.push nf
    upLangBlk = (lg, l, i) ->
      n = p[1][lg][l]
      p[1][lg][l] = [n, rndP(n / p[1].stats[l][0]), rndP(n / data.totals[i])]
    upLang = (lg) ->
      upLangBlk lg, l, i for l, i in blk
      pstats = {}
      pstats[l] = [p[1][lg][l][0], p[1][lg][l][2]] for l in blk
      data.global[lg].projets[p[0]] = {stats: pstats, files: []}
      upFile lg, file for file in p[1][lg].reports
    (p[1].stats[e] = [p[1].stats[e], rndP p[1].stats[e] / data.totals[i]]) for e, i in blk
    upLang lg for lg in p[1].langs
  globalAdd = (lg, value) ->
    n = [0, value.code, value.comments, value.blanks, value.reports.length]
    n[0] = n[1] + n[2] + n[3]
    if data.global.hasOwnProperty lg
      (data.global[lg].nb[i] += n[i]) for i in [0..4]
    else
      data.global[lg] = {nb: n, projets: {}}
    (data.totals[i] += n[i]) for i in [0..4]
    [lg, n]
  processEntry = (e) ->
    [ok, name, path] =
      if config.hasOwnProperty 'selected' then [true, (nd_path.parse e).name, e]
      else
        if e.isDirectory() and not config.ignore.includes e.name then [true, e.name, "../#{e.name}"]
        else [false, '', '']
    if ok
      console.log "processing '#{name}'..."
      lgs = (e) ->
        tok[e[0]].lines = e[1][0]
        tok[e[0]].files = e[1][4]
        e[0]
      tok_opts = {cwd: "#{path}", encoding: 'utf-8'}
      tok = cp.execSync "tokei --output json", tok_opts
      tok = JSON.parse tok
      tot = (globalAdd(k, v) for k, v of tok when k isnt 'Total')
      acc = tot.reduce projetAdd, [0, 0, 0, 0, 0]
      tok.langs = (lgs e for e in tot)
      tok.stats = {}
      (tok.stats[e] = acc[i]) for e, i in blk
      data.projets.push [name, tok]
      data.totals[5] += 1
  # handle config
  getConfig()
  (data.colors += addColor (lg.replace ' ', '_'), col) for lg, col of config.colors
  # processing
  lst =
    if config.hasOwnProperty 'selected' then config.selected
    else fs.readdirSync '..', {withFileTypes: true}
  processEntry entry for entry in lst
  addPercentGlobal k for k in Object.keys data.global
  addPercentProject p, i for p, i in data.projets
  console.log 'generating file...'
  data.js = coffee.compile (fs.readFileSync 'app.coffee', {encoding: 'utf-8'})
  data.css = (sass.compile 'style.sass', {style: 'compressed'}).css
  rendered = pug.renderFile 'index.pug', data
  save_name = if config.datetime then "tokeize_#{genDate()}.html" else 'tokeize.html'
  fs.writeFileSync (nd_path.join config.out, save_name), rendered
  console.log 'DONE'


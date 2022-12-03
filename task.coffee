coffee = require 'coffeescript'
fs = require 'fs'
cp = require 'child_process'
nd_path = require 'path'
pug = require 'pug'
sass = require 'sass'
sharp = require 'sharp'

# CONFIG ##############################

config =
  ignore: []
  colors:
    'CSS': 'red'
    'CoffeeScript': '#a00'
    'JavaScript': 'orange'
    'HTML': 'lime'
    'Markdown': '#026'
    'Plain Text': 'olive'
    'Pug': '#fc6'
    'Rust': '#544'
    'Sass': '#f0e'
    'Scss': '#d0c'
    'TOML': '#fe3'

user_config = './config.coffee'

# HELPERS #############################

genDate = ->
  az = (nb) -> if nb < 10 then "0#{nb}" else nb
  dt = new Date()
  tm = "#{az dt.getHours()}#{az dt.getMinutes()}#{az dt.getSeconds()}"
  "#{dt.getYear()-100}-#{az(dt.getMonth()+1)}-#{az dt.getDate()}_#{tm}"

getConfig = ->
  try
    fs.accessSync user_config
    cfg = require(user_config).config
    if cfg.hasOwnProperty 'selected' then config.selected = cfg.selected
    else if cfg.hasOwnProperty 'ignore' then config.ignore = cfg.ignore
    if cfg.hasOwnProperty 'colors' then config.colors[key] = val for key, val of cfg.colors

projetAdd = (acc, curr) =>
  (acc[i] += curr[1][i]) for i in [0..4]
  acc

rndP = (v) -> Math.round(v * 10000) / 100

# TASKS ###############################

exports.colorsFn = ->
  st = '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="20px" height="15px">'
  st += '<rect width="30px" height="30px" '
  toImg = (key, val) ->
    sharp(Buffer.from st + "fill='#{val}'/></svg>").toFile "./imgs/col_#{key}.png"
  getConfig()
  toImg key, val for key, val of config.colors

exports.runFn = ->
  # vars declarations
  data = {colors: '', global: {}, projets: [], totals: [0, 0, 0, 0, 0, 0]}
  # helpers
  addColor = (lg, col) ->
    ".rep-#{lg}{background-color:#{col} !important;}.txt-#{lg}{color:#{col};font-weight:bold;}"
  addPercentGlobal = (key) ->
    toP = (e, i) -> [e, rndP e / data.totals[i]]
    data.global[key] = (toP e, i for e, i in data.global[key])
  addPercentProject = (p) ->
    #
    # TODO
    #
    console.log 'add percent per project'
    #
    #
    #
  globalAdd = (key, value) ->
    n = [0, value.code, value.comments, value.blanks, value.reports.length]
    n[0] = n[1] + n[2] + n[3]
    if data.global.hasOwnProperty key
      (data.global[key][i] += n[i]) for i in [0..4]
    else
      data.global[key] = n
    (data.totals[i] += n[i]) for i in [0..4]
    [key, n]
  processEntry = (e) ->
    [ok, name, path] =
      if config.hasOwnProperty 'selected' then [true, (nd_path.parse e).name, e]
      else
        if e.isDirectory() and not config.ignore.includes e.name then [true, e.name, "../#{e.name}"]
        else [false, '', '']
    if ok
      console.log "processing '#{name}'..."
      rep = (t) ->
        tok[t[0]].percent = rndP t[1][0] / acc[0]
        t[0]
      tok_opts = {cwd: "#{path}", encoding: 'utf-8'}
      tok = cp.execSync "tokei --exclude package.json --output json", tok_opts
      tok = JSON.parse tok
      tot = (globalAdd(k, v) for k, v of tok when k isnt 'Total')
      acc = tot.reduce projetAdd, [0, 0, 0, 0, 0]
      tok.stats = {lines: acc[0], code: acc[1], comments: acc[2], blanks: acc[3], files: acc[4]}
      tok.langs = (rep t for t in tot)
      data.projets.push [name, tok]
      data.totals[5] += 1
  # handle config
  getConfig()
  (data.colors += addColor (lg.replace ' ', '_'), col) for lg, col of config.colors
  # processing
  #
  # TODO: ajout du select
  #
  lst =
    if config.hasOwnProperty 'selected' then config.selected
    else fs.readdirSync '..', {withFileTypes: true}
  #processEntry entry for entry in [(fs.readdirSync '..', {withFileTypes: true})[4]]
  processEntry entry for entry in lst
  #
  # TODO: zone de vérif
  #
  console.log data.projets
  #console.log data.projets[0][1]
  #
  addPercentGlobal k for k in Object.keys data.global
  addPercentProject p for p in data.projets
  console.log 'generating file...'
  data.js = coffee.compile (fs.readFileSync 'app.coffee', {encoding: 'utf-8'})
  data.css = (sass.compile 'style.sass', {style: 'compressed'}).css
  rendered = pug.renderFile 'index.pug', data
  #fs.writeFileSync "../tokeize_#{genDate()}.html", rendered
  fs.writeFileSync "../tokeize.html", rendered
  console.log 'DONE'


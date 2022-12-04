getId = (id) -> document.getElementById id

selecting = (query, id) ->
  selec = (nd, i) ->
    if i is id then nd.classList.add 'selected' else nd.classList.remove 'selected'
  selec nd, i for nd, i in document.querySelectorAll query

setDisplay = (id, chx) ->
  elt = getId id
  elt.style.display = chx

turnSel = (id, sel) ->
  cl = getId(id).classList
  if sel then cl.add 'selected' else cl.remove 'selected'

App =
  glb: (lg, key) ->
    cl = document.querySelectorAll("#glb-#{lg} .dtl")[key].classList
    if cl.contains 'show' then cl.remove 'show' else cl.add 'show'
  gotomain: ->
    setDisplay 'solo', 'none'
    setDisplay 'main', 'block'
  init: ->
    App.show 'projets'
    setDisplay 'main', 'block'
  lang: (key) -> selecting "#global-data > div", key
  panel: (key, pan) ->
    selecting "#solo-#{key} .panel > div", pan
    selecting "#solo-#{key} .data > div", pan
  reach: (key) ->
    handleSolo = (sl) ->
      sl.style.display = if sl.id is "solo-#{key}" then 'block' else 'none'
    handleSolo sl for sl in document.querySelectorAll '.solo'
    setDisplay 'main', 'none'
    setDisplay 'solo', 'block'
  show: (sel) ->
    setDisplay 'main-projets', if sel is 'projets' then 'flex' else 'none'
    setDisplay 'main-global', if sel is 'global' then 'block' else 'none'
    turnSel 'main-btn-projets', sel is 'projets'
    turnSel 'main-btn-global', sel is 'global'

window.App = App

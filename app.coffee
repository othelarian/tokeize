getId = (id) -> document.getElementById id

setDisplay = (id, chx) ->
  elt = getId id
  elt.style.display = chx

turnSel = (id, sel) ->
  cl = getId(id).classList
  if sel then cl.add 'selected' else cl.remove 'selected'

App =
  gotomain: ->
    setDisplay 'solo', 'none'
    setDisplay 'main', 'block'
  init: ->
    App.show 'projets'
    setDisplay 'main', 'block'
  panel: (key, pan) ->
    selec = (nd, i) ->
      if pan is i then nd.classList.add 'selected'
      else nd.classList.remove 'selected'
    selec nd, i for nd, i in document.querySelectorAll "#solo-#{key} .panel > div"
    selec nd, i for nd, i in document.querySelectorAll "#solo-#{key} .data > div"
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

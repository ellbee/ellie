import initCodeMirror from '../../Ellie/Ui/CodeEditor/CodeMirror'
import IconLoader from '../../Ellie/Ui/Icon/Loader'

IconLoader.load()

initCodeMirror()
  .then(() => {
    const Elm = require('./Main.elm')
    Elm.Pages.Embed.Main.fullscreen()
  })

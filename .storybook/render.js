import { onReady } from '../src/interop'

export const render = (Main) => (args) => {
  let node = document.createElement('div')
  node.setAttribute('id', 'elm_root')
  window.requestAnimationFrame(() => {
    let app = Main.init({ node, flags: args })
    app.ports.logMsg.subscribe(args.onElmMsg)
    app.ports.logUrl.subscribe(args.onElmUrl)
    onReady({ app, env: {} })
  })
  return node
}
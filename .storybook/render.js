import * as Interop from '../src/interop'

export const render = (Main) => (args) => {
  let node = document.createElement('div')
  node.setAttribute('id', 'elm_root')
  window.requestAnimationFrame(async () => {
    let flags = await Interop.flags({ env: {} })
    let app = Main.init({ node, flags: { ...flags, ...args } })
    if (app.ports && app.ports.logMsg && app.ports.logUrl) {
      app.ports.logMsg.subscribe(args.onElmMsg)
      app.ports.logUrl.subscribe(args.onElmUrl)
    }
    Interop.onReady({ app, env: {} })
  })
  return node
}
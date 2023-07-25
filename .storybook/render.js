export const render = (Main) => (args) => {
  let node = document.createElement('div')
  window.requestAnimationFrame(() => {
    let app = Main.init({ node, flags: args })
    app.ports.log.subscribe(args.onElmMsg)
  })
  return node
}
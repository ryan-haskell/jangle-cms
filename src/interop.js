import * as ErrorReporting from './interop/error-reporting.js'

// Helper for working with localStorage and JSON values
const Storage = {
  save: ({ key, value }) => localStorage.setItem(key, JSON.stringify(value)),
  load: (key) => JSON.parse(localStorage.getItem(key) || null)
}

// 
// This returns the flags passed into your Elm application
// 
export const flags = async ({ env }) => {
  ErrorReporting.init({ env })

  return {
    env,
    baseUrl: window.location.origin,
    oAuthResponse: Storage.load('oAuthResponse')
  }
}

// 
// This function is called once your Elm app is running
// 
export const onReady = ({ app, env }) => {

  // PORTS
  if (app.ports && app.ports.outgoing) {
    app.ports.outgoing.subscribe(({ tag, data }) => {
      switch (tag) {
        case 'SAVE':
          Storage.save(data)
          break
        case 'SHOW_DIALOG':
          let dialog = document.getElementById(data.id)
          if (dialog && dialog.showModal) {
            dialog.showModal()
          }
          break
      }
    })
  }

}

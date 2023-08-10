import * as ErrorReporting from './interop/error-reporting.js'
import * as BoundingClientRect from './interop/bounding-client-rect.js'

// Helper for working with localStorage and JSON values
const Storage = {
  save: ({ key, value }) => localStorage.setItem(key, JSON.stringify(value)),
  load: (key) => JSON.parse(localStorage.getItem(key) || null)
}

// 
// This returns the flags passed into your Elm application
// 
export const flags = async ({ env }) => {
  BoundingClientRect.init()
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
          var dialog = document.getElementById(data.id)
          if (dialog && dialog.showModal) {
            dialog.showModal()
          }
          return
        case 'HIDE_DIALOG':
          var dialog = document.getElementById(data.id)
          if (dialog && dialog.close) {
            dialog.close()
          }
          return
        case 'HIDE_POPOVER':
          var popover = document.getElementById(data.id)
          if (popover && popover.hidePopover) {
            popover.hidePopover()
          }
          return
        case 'SENTRY_REPORT_HTTP_ERROR':
          return ErrorReporting.sendHttpError(data)
        case 'SENTRY_REPORT_JSON_ERROR':
          return ErrorReporting.sendJsonDecodeError(data)
        case 'SENTRY_REPORT_CUSTOM_ERROR':
          return ErrorReporting.sendCustomError(data)
      }
    })
  }

}

import * as ErrorReporting from './interop/error-reporting.js'

// This returns the flags passed into your Elm application
export const flags = async ({ env }) => {
  console.log({ env })
  ErrorReporting.init({ env })
  return { env }
}

// This function is called once your Elm app is running
export const onReady = ({ app, env }) => {

}

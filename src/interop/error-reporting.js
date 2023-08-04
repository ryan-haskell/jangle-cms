import * as Sentry from "@sentry/browser"

// Set up Sentry to handle runtime exceptions thrown from JavaScript
export const init = ({ env }) => {
  if (!env.SENTRY_DSN) {
    console.warn(`For error reporting, please provide a SENTRY_DSN environment variable`)
    return
  }
  Sentry.init({
    dsn: env.SENTRY_DSN,
    integrations: [new Sentry.BrowserTracing()],
    tracesSampleRate: 1.0,
    environment:
      (env.SENTRY_ENV === 'production')
        ? 'production'
        : 'development'
  });
}

export const sendHttpError = (event) => {
  if (event.user) Sentry.setUser(event.user)
  Sentry.withScope((scope) => {
    if (event.response) {
      scope.addAttachment({
        filename: event.url,
        data: event.response
      })
    }
    Sentry.captureEvent({
      message: `${event.method} ${event.url} – ${event.error}`,
      tags: {
        'kind': 'Http.Error',
        'elm.http.method': event.method,
        'elm.http.url': event.url,
      }
    })
  })
}

export const sendJsonDecodeError = (event) => {
  if (event.user) Sentry.setUser(event.user)
  Sentry.withScope((scope) => {
    scope.addAttachment({
      filename:
        (event.url.endsWith('.json'))
          ? event.url
          : `${event.url}.json`,
      data: event.response
    })
    Sentry.captureEvent({
      message: `${event.method} ${event.url} – ${event.title}`,
      tags: {
        'kind': 'Json.Decode.Error',
        'elm.http.method': event.method,
        'elm.http.url': event.url,
      },
      extra: {
        "Json.Decode.Error": event.error
      }
    })
  })
}

export const sendCustomError = (event) => {
  if (event.user) Sentry.setUser(event.user)
  Sentry.captureEvent({
    tags: { 'kind': 'Elm Error' },
    message: event.message,
    extra: event.details
  })

}
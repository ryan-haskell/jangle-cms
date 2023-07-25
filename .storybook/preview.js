export const parameters = {
  actions: { argTypesRegex: "^on[A-Z].*" },
  controls: {
    hideNoControlsWarning: true,
    matchers: {
      color: /(background|color)$/i,
      date: /Date$/,
    },
  },
}
export const argTypes = {
  onElmMsg: {
    action: 'Elm',
    table: { disable: true }
  },
}

export const init = () => {
  // Makes `getBoundingClientRect` data available to Elm, as a JSON property
  if ('___getBoundingClientRect' in Element.prototype) return
  Object.defineProperty(Element.prototype, '___getBoundingClientRect', {
    get() {
      return this.getBoundingClientRect();
    }
  })
}
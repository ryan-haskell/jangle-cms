import { Sortable } from "@shopify/draggable"

export const init = () => {
  const name = 'drag-n-drop'

  const existing = window.customElements.get(name)
  if (existing) return

  window.customElements.define(name, class extends HTMLElement {
    connectedCallback() {
      console.log(`Hello, from ${name}`)
      let sortable = new Sortable(
        this.parentNode.querySelectorAll('*[draggable-parent]'),
        {
          draggable: '*[draggable-item]',
          handle: '*[draggable-handle]',
          mirror: {
            constrainDimensions: true
          }
        }
      )
      sortable.on('sortable:stop', event => {
        let detail = { oldIndex: event.data.oldIndex, newIndex: event.data.newIndex }
        this.dispatchEvent(new CustomEvent('sort', { detail }))
      })
    }
  })
}
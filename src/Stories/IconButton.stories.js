import { Elm } from './IconButton.elm'
import { render } from '../../.storybook/render'
import { icons } from './icons'

// More on how to set up stories at: https://storybook.js.org/docs/7.0/html/writing-stories/introduction
export default {
  title: 'Components/IconButton',
  render: render(Elm.Stories.IconButton),
  parameters: {
    layout: 'centered'
  },
  argTypes: {
    icon: {
      control: 'select',
      options: icons
    },
  },
}

// More on writing stories with args: https://storybook.js.org/docs/7.0/html/writing-stories/args
export const Edit = {
  args: { icon: 'Edit' },
}
export const Close = {
  args: { icon: 'Close' },
}
export const Menu = {
  args: { icon: 'Menu' },
}
import { Elm } from './Layout.elm'
import { render } from '../../.storybook/render'

// More on how to set up stories at: https://storybook.js.org/docs/7.0/html/writing-stories/introduction
export default {
  title: 'Components/Layout',
  render: render(Elm.Stories.Layout),
  parameters: {
    layout: 'fullscreen'
  },
  argTypes: {
    sidebar: { control: 'boolean' },
    header: { control: 'boolean' },
  },
}

// More on writing stories with args: https://storybook.js.org/docs/7.0/html/writing-stories/args
export const Blank = {
  args: {
    header: false,
    sidebar: false
  },
}

export const Header = {
  args: {
    header: true,
    sidebar: false
  },
}

export const Sidebar = {
  args: {
    header: true,
    sidebar: true
  },
}
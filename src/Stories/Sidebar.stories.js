import { Elm } from './Sidebar.elm'
import { render } from '../../.storybook/render'

// More on how to set up stories at: https://storybook.js.org/docs/7.0/html/writing-stories/introduction
export default {
  title: 'Components/Sidebar',
  render: render(Elm.Stories.Sidebar),
  parameters: {
    layout: 'fullscreen'
  },
  argTypes: {},
}

// More on writing stories with args: https://storybook.js.org/docs/7.0/html/writing-stories/args
export const Sidebar = {
  args: {},
}
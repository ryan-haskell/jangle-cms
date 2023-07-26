import { Elm } from './SidebarLinkGroup.elm'
import { render } from '../../.storybook/render'
import icons from './icons'

// More on how to set up stories at: https://storybook.js.org/docs/7.0/html/writing-stories/introduction
export default {
  title: 'Components/SidebarLinkGroup',
  render: render(Elm.Stories.SidebarLinkGroup),
  parameters: {
    layout: 'centered'
  },
  argTypes: {
    label: { control: 'text' },
  },
}

// More on writing stories with args: https://storybook.js.org/docs/7.0/html/writing-stories/args
export const SidebarLinkGroup = {
  args: {
    label: 'Content'
  },
}
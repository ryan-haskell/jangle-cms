import { Elm } from './SidebarLink.elm'
import { render } from '../../.storybook/render'
import { icons } from './icons'

// More on how to set up stories at: https://storybook.js.org/docs/7.0/html/writing-stories/introduction
export default {
  title: 'Components/SidebarLink',
  render: render(Elm.Stories.SidebarLink),
  parameters: {
    layout: 'centered'
  },
  argTypes: {
    label: { control: 'text' },
    icon: { control: 'select', options: icons },
    state: { control: 'select', options: ['Default', 'Selected'] },
  },
}

// More on writing stories with args: https://storybook.js.org/docs/7.0/html/writing-stories/args
export const Default = {
  args: {
    state: 'Default',
    icon: 'Home',
    label: 'Dashboard'
  },
}

export const Selected = {
  args: {
    state: 'Selected',
    icon: 'Home',
    label: 'Dashboard'
  },
}
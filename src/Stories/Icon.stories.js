import { Elm } from './Icon.elm'
import { render } from '../../.storybook/render'
import { icons } from './icons'

// More on how to set up stories at: https://storybook.js.org/docs/7.0/html/writing-stories/introduction
export default {
  title: 'Components/Icon',
  render: render(Elm.Stories.Icon),
  parameters: {
    layout: 'centered'
  },
  argTypes: {
    icon: {
      control: 'select',
      options: icons
    },
    size: {
      control: 'select',
      options: ['16px', '24px']
    },
  },
}

// More on writing stories with args: https://storybook.js.org/docs/7.0/html/writing-stories/args
export const GitHub = {
  name: 'GitHub',
  args: { icon: 'GitHub', size: '24px' },
}
export const Google = {
  args: { icon: 'Google', size: '24px' },
}
export const Menu = {
  args: { icon: 'Menu', size: '24px' },
}
export const Home = {
  args: { icon: 'Home', size: '24px' },
}
export const Edit = {
  args: { icon: 'Edit', size: '24px' },
}
export const Page = {
  args: { icon: 'Page', size: '24px' },
}
export const Down = {
  args: { icon: 'Down', size: '24px' },
}
export const Right = {
  args: { icon: 'Right', size: '24px' },
}
export const Close = {
  args: { icon: 'Close', size: '24px' },
}
export const Search = {
  args: { icon: 'Search', size: '24px' },
}
export const SignOut = {
  args: { icon: 'SignOut', size: '24px' },
}
export const Switch = {
  args: { icon: 'Switch', size: '24px' },
}
export const Handle = {
  args: { icon: 'Handle', size: '24px' },
}
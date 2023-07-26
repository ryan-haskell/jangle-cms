import { Elm } from './Header.elm'
import { render } from '../../.storybook/render'

// More on how to set up stories at: https://storybook.js.org/docs/7.0/html/writing-stories/introduction
export default {
  title: 'Components/Header',
  render: render(Elm.Stories.Header),
  parameters: {
    layout: 'fullscreen'
  },
  argTypes: {
    title: { control: 'text' },
  },
}

// More on writing stories with args: https://storybook.js.org/docs/7.0/html/writing-stories/args
export const Header = {
  args: {
    title: 'Dashboard',
  },
}
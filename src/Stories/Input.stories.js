import { Elm } from './Input.elm'
import { render } from '../../.storybook/render'

// More on how to set up stories at: https://storybook.js.org/docs/7.0/html/writing-stories/introduction
export default {
  title: 'Components/Input',
  render: render(Elm.Stories.Input),
  parameters: {
    layout: 'centered'
  },
  argTypes: {
    style: {
      control: 'select',
      options: ['Text', 'Search', 'Multiline']
    },
    error: { control: 'boolean' }
  },
}

// More on writing stories with args: https://storybook.js.org/docs/7.0/html/writing-stories/args
export const Text = {
  args: { style: 'Text', error: false }
}
export const Search = {
  args: { style: 'Search', error: false }
}
export const Multiline = {
  args: { style: 'Multiline', error: false }
}
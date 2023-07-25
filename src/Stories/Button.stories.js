import { Elm } from './Button.elm'
import { render } from '../../.storybook/render'

// More on how to set up stories at: https://storybook.js.org/docs/7.0/html/writing-stories/introduction
export default {
  title: 'Components/Button',
  render: render(Elm.Stories.Button),
  parameters: {
    layout: 'centered'
  },
  argTypes: {
    label: { control: 'text' },
    primary: { control: 'boolean' },
  },
}

// More on writing stories with args: https://storybook.js.org/docs/7.0/html/writing-stories/args
export const Primary = {
  args: {
    primary: true,
    label: 'Create post',
  },
}

export const Secondary = {
  args: {
    label: 'Cancel',
  },
}
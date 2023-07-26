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
    icon: { control: 'boolean' },
  },
}

// More on writing stories with args: https://storybook.js.org/docs/7.0/html/writing-stories/args
export const Primary = {
  args: {
    icon: false,
    primary: true,
    label: 'New project',
  },
}

export const Secondary = {
  args: {
    icon: false,
    primary: false,
    label: 'Cancel',
  },
}

export const WithIcon = {
  args: {
    icon: true,
    primary: false,
    label: 'Sign in with GitHub'
  }
}
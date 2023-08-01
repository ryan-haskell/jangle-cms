import { Elm } from './UserControls.elm'
import { render } from '../../.storybook/render'

// More on how to set up stories at: https://storybook.js.org/docs/7.0/html/writing-stories/introduction
export default {
  title: 'Components/UserControls',
  render: render(Elm.Stories.UserControls),
  parameters: {
    layout: 'centered'
  },
  argTypes: {
    name: { control: 'text' },
    email: { control: 'text' },
    image: { control: 'boolean' },
  },
}

// More on writing stories with args: https://storybook.js.org/docs/7.0/html/writing-stories/args
export const WithImage = {
  args: {
    image: true,
    name: 'Ryan Haskell-Glatz',
    email: 'ryan@jangle.io',
  },
}

export const WithoutImage = {
  args: {
    image: false,
    name: 'Ryan Haskell-Glatz',
    email: 'ryan@jangle.io',
  },
}
import { Elm } from './JangleLogo.elm'
import { render } from '../../.storybook/render'

// More on how to set up stories at: https://storybook.js.org/docs/7.0/html/writing-stories/introduction
export default {
  title: 'Components/JangleLogo',
  render: render(Elm.Stories.JangleLogo),
  parameters: {
    layout: 'centered'
  },
  argTypes: {
    size: { control: 'radio', options: ['Small', 'Large'] },
  },
}

// More on writing stories with args: https://storybook.js.org/docs/7.0/html/writing-stories/args
export const Small = {
  args: {
    size: 'Small',
  },
}

export const Large = {
  args: {
    size: 'Large',
  },
}
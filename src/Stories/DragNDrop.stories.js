import { Elm } from './DragNDrop.elm'
import { render } from '../../.storybook/render'

// More on how to set up stories at: https://storybook.js.org/docs/7.0/html/writing-stories/introduction
export default {
  title: 'Components/DragNDrop',
  render: render(Elm.Stories.DragNDrop),
  parameters: {
    layout: 'centered'
  },
  argTypes: {},
}

// More on writing stories with args: https://storybook.js.org/docs/7.0/html/writing-stories/args
export const DragNDrop = {
  args: {}
}
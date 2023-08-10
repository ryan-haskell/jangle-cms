import { Elm } from './Select.elm'
import { render } from '../../.storybook/render'

// More on how to set up stories at: https://storybook.js.org/docs/7.0/html/writing-stories/introduction
export default {
  title: 'Components/Select',
  render: render(Elm.Stories.Select),
  parameters: {
    layout: 'centered'
  },
  argTypes: {},
}

// More on writing stories with args: https://storybook.js.org/docs/7.0/html/writing-stories/args
export const Select = {
  args: {}
}
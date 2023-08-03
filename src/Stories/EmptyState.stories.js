import { Elm } from './EmptyState.elm'
import { render } from '../../.storybook/render'

// More on how to set up stories at: https://storybook.js.org/docs/7.0/html/writing-stories/introduction
export default {
  title: 'Components/EmptyState',
  render: render(Elm.Stories.EmptyState),
  parameters: {
    layout: 'centered'
  },
  argTypes: {
    variant: {
      control: 'select',
      options: ['CreateYourFirstProject', 'Loading', 'HttpError', 'NoResultsFound']
    },
  },
}

// More on writing stories with args: https://storybook.js.org/docs/7.0/html/writing-stories/args
export const CreateYourFirstProject = {
  args: { variant: 'CreateYourFirstProject' }
}
export const Loading = {
  args: { variant: 'Loading' }
}
export const HttpError = {
  args: { variant: 'HttpError' }
}
export const NoResultsFound = {
  args: { variant: 'NoResultsFound' }
}
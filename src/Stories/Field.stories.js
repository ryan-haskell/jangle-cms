import { Elm } from './Field.elm'
import { render } from '../../.storybook/render'

// More on how to set up stories at: https://storybook.js.org/docs/7.0/html/writing-stories/introduction
export default {
  title: 'Components/Field',
  render: render(Elm.Stories.Field),
  parameters: {
    layout: 'centered'
  },
  argTypes: {
    style: {
      control: 'select',
      options: ['Text', 'Search', 'Multiline']
    },
    labels: {
      control: 'select',
      options: ['None', 'Label', 'LabelAndSublabel']
    },
    error: { control: 'text' },
    label: { control: 'text' },
    sublabel: { control: 'text' },
    isWidthFill: { control: 'boolean' },
  },
}

// More on writing stories with args: https://storybook.js.org/docs/7.0/html/writing-stories/args
export const Text = {
  args: {
    style: 'Text',
    labels: 'LabelAndSublabel',
    label: 'Project name',
    sublabel: 'What should we call this project?',
    error: '',
    isWidthFill: false
  }
}
export const Search = {
  args: {
    style: 'Search',
    labels: 'Label',
    label: 'Find a repository',
    sublabel: 'Search GitHub repositories by name',
    error: '',
    isWidthFill: false
  }
}
export const Multiline = {
  args: {
    style: 'Multiline',
    labels: 'LabelAndSublabel',
    label: 'Bio',
    sublabel: 'Tell us a bit about yourself',
    error: 'Bio cannot be blank',
    isWidthFill: false
  }
}
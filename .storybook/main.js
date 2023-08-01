import ElmVitePlugin from './plugins/vite-plugin-elm'

export default {
  stories: [
    "../src/Stories/**/*.stories.js"
  ],
  framework: {
    name: "@storybook/html-vite",
    options: {}
  },
  addons: [
    "@storybook/addon-controls",
    "@storybook/addon-a11y",
    "@storybook/addon-actions",
    "@storybook/addon-viewport",
  ],
  async viteFinal(config) {
    return {
      ...config,
      plugins: [
        ...config.plugins,
        ElmVitePlugin({ debug: false, optimize: false })
      ],
      define: (config.build)
        ? config.define
        : { ...config.define, global: "window" }
    }
  }
};
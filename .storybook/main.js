import ElmVitePlugin from 'vite-plugin-elm'

export default {
  stories: [
    "../src/Stories/**/*.stories.js"
  ],
  framework: {
    name: "@storybook/html-vite",
    options: {}
  },
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
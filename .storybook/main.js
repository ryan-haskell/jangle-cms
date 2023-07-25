import ElmVitePlugin from 'vite-plugin-elm'

export default {
  "stories": [
    "../src/Stories/**/*.stories.@(js|jsx|ts|tsx)"
  ],
  "addons": [
    "@storybook/addon-essentials"
  ],
  "framework": {
    "name": "@storybook/html-vite",
    "options": {}
  },
  async viteFinal(config) {
    return {
      ...config,
      plugins: [
        ...config.plugins,
        ElmVitePlugin({ debug: false, optimize: false })
      ],
      define: {
        ...config.define,
        // Prevents "global is not defined" error
        global: "window",
      },
    };
  }
};
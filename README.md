# Jangle CMS
> An example web app made with Elm

## Introduction

In August 2023, I took a gap year and started to build a CMS using [Elm Land](https://elm.land). I got pretty far
with the design system and made a lot of Elm components, so I thought it would be fun to share the source
code for the design system at [https://design.jangle.io](https://design.jangle.io):

![image](https://github.com/user-attachments/assets/21d68678-320b-428c-9254-6c7f1fdc082d)

Feel free to take whatever you want from this project, I hope it helps you or your business make cool things
with Elm! :heart:

## Local development

```sh
npm start
```

### Scripts

The `package.json` contains all the scripts used for local development and production builds.

Here are some of the most common commands:
- `npm start` - Runs `npm install` and `npm run dev`
- `npm run dev` - Spins up the app, test suite, Storybook, and CSS codegen
- `npm run build` - Runs CSS codegen and `elm-land build`
- `npm run test` - Runs test suite once

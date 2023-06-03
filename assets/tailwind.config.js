// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const colors = require("tailwindcss/colors")
const fs = require("fs")
const path = require("path")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/*_web.ex",
    "../lib/*_web/**/*.*ex"
  ],
  darkMode: ['class', '[data-mode="dark"]'],
  theme: {
    extend: {
      typography: {
        gruvbox: {
          css: {
            '--tw-prose-body': 'rgb(var(--color-foreground))',
            '--tw-prose-links': 'rgb(var(--color-foreground))',
            '--tw-prose-headings': 'rgb(var(--color-foreground))',
            '--tw-prose-bold': 'rgb(var(--color-foreground))',
            '--tw-prose-quotes': 'rgb(var(--color-foreground))',
            '--tw-prose-bullets': 'rgb(var(--color-primary))',
            '--tw-prose-code': 'rgb(var(--color-base))',
            '--tw-prose-pre-bg': 'rgb(var(--color-background1))',
            '--tw-prose-quote-borders': 'rgb(var(--color-primary))',
            '--tw-prose-invert-body': 'rgb(var(--color-foreground))',
            '--tw-prose-invert-links': 'rgb(var(--color-foreground))',
            '--tw-prose-invert-headings': 'rgb(var(--color-foreground))',
            '--tw-prose-invert-bold': 'rgb(var(--color-foreground))',
            '--tw-prose-invert-quotes': 'rgb(var(--color-foreground))',
            '--tw-prose-invert-bullets': 'rgb(var(--color-primary))',
            '--tw-prose-invert-quote-borders': 'rgb(var(--color-primary))',
            '--tw-prose-invert-code': 'rgb(var(--color-base))',
            '--tw-prose-invert-pre-bg': 'rgb(var(--color-background1))'
          }
        }
      },
      colors: {
        code: colors.emerald,
        gray: colors.zinc,
        theme: {
          background: 'rgb(var(--color-background) / <alpha-value>)',
          background1: 'rgb(var(--color-background1) / <alpha-value>)',
          base: 'rgb(var(--color-foreground) / <alpha-value>)',
          base1: 'rgb(var(--color-foreground1) / <alpha-value>)',
          primary: 'rgb(var(--color-primary) / <alpha-value>)',
          primary1: 'rgb(var(--color-primary1) / <alpha-value>)',
          secondary: 'rgb(var(--color-secondary) / <alpha-value>)',
          secondary1: 'rgb(var(--color-secondary1) / <alpha-value>)',
          tertiary: 'rgb(var(--color-blue) / <alpha-value>)',
          quaternary: 'rgb(var(--color-purple) / <alpha-value>)',
          quinary: 'rgb(var(--color-yellow) / <alpha-value>)',
          heading: 'rgb(var(--color-heading) / <alpha-value>)'
        } 
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/typography"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({addVariant}) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Hero Icons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function({matchComponents, theme}) {
      let iconsDir = path.join(__dirname, "../priv/hero_icons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).map(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = {name, fullPath: path.join(iconsDir, dir, file)}
        })
      })
      matchComponents({
        "hero": ({name, fullPath}) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": theme("spacing.5"),
            "height": theme("spacing.5")
          }
        }
      }, {values})
    })
  ]
}

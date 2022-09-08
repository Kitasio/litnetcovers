// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

let plugin = require('tailwindcss/plugin')

module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex'
  ],
  theme: {
    extend: {
      animation: {
        'bounce-x': 'bounce-x 1s infinite'
      },
      keyframes: {
        'bounce-x': {
          '0%, 100%': { transform: 'translateX(-25%)', 'animation-timing-function': 'cubic-bezier(0.8, 0, 1, 1)' },
          '50%': { transform: 'translateX(0)', 'animation-timing-function': 'cubic-bezier(0, 0, 0.2, 1)' },
        }
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    plugin(({addVariant}) => addVariant('phx-no-feedback', ['&.phx-no-feedback', '.phx-no-feedback &'])),
    plugin(({addVariant}) => addVariant('phx-click-loading', ['&.phx-click-loading', '.phx-click-loading &'])),
    plugin(({addVariant}) => addVariant('phx-submit-loading', ['&.phx-submit-loading', '.phx-submit-loading &'])),
    plugin(({addVariant}) => addVariant('phx-change-loading', ['&.phx-change-loading', '.phx-change-loading &'])),
    plugin(function ({ addUtilities }) {
      addUtilities({
        '.bg-overlay': {
          'background': 'linear-gradient(var(--overlay-angle, 0deg), var(--overlay-colors)), var(--overlay-image)',
          'background-position': 'center',
          'background-size': 'cover',
        },
      });
    }),
  ]
}

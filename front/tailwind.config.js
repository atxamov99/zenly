/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        zenly: {
          electric: '#4C8DFF',
          pink: '#FF43A4',
          gray: '#AEB8D0',
          night: '#071120',
          ink: '#DCE7FF',
          cyan: '#7FE7FF',
          mint: '#3DFFAE',
          danger: '#FF4D6D',
        },
      },
      boxShadow: {
        float: '0 20px 60px rgba(0, 0, 0, 0.28)',
        glow: '0 0 0 6px rgba(255,255,255,0.12)',
      },
      borderRadius: {
        '4xl': '2rem',
      },
      backdropBlur: {
        xs: '2px',
      },
      keyframes: {
        bob: {
          '0%, 100%': { transform: 'translateY(0px)' },
          '50%': { transform: 'translateY(-4px)' },
        },
        pulseSoft: {
          '0%, 100%': { opacity: '0.55', transform: 'scale(1)' },
          '50%': { opacity: '0.95', transform: 'scale(1.08)' },
        },
        rise: {
          '0%': { opacity: '0', transform: 'translateY(16px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
      },
      animation: {
        bob: 'bob 3.2s ease-in-out infinite',
        'pulse-soft': 'pulseSoft 2.4s ease-in-out infinite',
        rise: 'rise 0.5s ease-out',
      },
    },
  },
  plugins: [],
}

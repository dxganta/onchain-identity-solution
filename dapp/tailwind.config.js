module.exports = {
  purge: ['./pages/**/*.{js,ts,jsx,tsx}', './components/**/*.{js,ts,jsx,tsx}'],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      colors: {
        tinty: '#4EC2B3',
      },
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
};

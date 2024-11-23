module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
  ],
  parserOptions: {
    ecmaVersion: 2020,
  },
  rules: {
    "linebreak-style": 0,
    quotes: ["error", "double"],
    "max-len": ["error", { "code": 100 }],
  },
};

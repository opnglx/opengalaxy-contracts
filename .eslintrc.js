module.exports = {
  root: true,
  env: {
    mocha: true,
    node: true,
  },
  extends: [
    "standard",
    "prettier",
    "plugin:prettier/recommended",
    "plugin:node/recommended",
  ],
  parserOptions: {
    ecmaVersion: 12,
  },
  overrides: [
    {
      files: ["hardhat.config.js"],
      globals: { task: true },
    },
  ],
}

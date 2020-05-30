const { environment } = require('@rails/webpacker')
const coffee =  require('./loaders/coffee')

// Jquery setup.
const webpack = require('webpack')
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    Rails: '@rails/ujs'
  })
)
const config = environment.toWebpackConfig()
config.resolve.alias = {
  jquery: "jquery/src/jquery"
}

environment.loaders.prepend('coffee', coffee)
module.exports = environment

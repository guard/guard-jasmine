coffeescript_options = {
  input: 'lib/guard/jasmine/phantomjs/src',
  output: 'lib/guard/jasmine/phantomjs',
  patterns: [%r{^lib/guard/jasmine/phantomjs/src/(.+\.(?:coffee|coffee\.md|litcoffee))$}]
}

guard 'coffeescript', coffeescript_options do
  coffeescript_options[:patterns].each { |pattern| watch(pattern) }
end

mocha_cmd = 'mocha --compilers coffee:coffee-script/register --ui bdd --growl'
guard :shell do
  watch(%r{(lib/guard/jasmine/phantomjs/test/.+_spec\.coffee)}) { |m| `#{mocha_cmd} #{ m[1]}` }
  watch(%r{lib/guard/jasmine/phantomjs/src/(.+)\.coffee}) { |m| `#{mocha_cmd} lib/guard/jasmine/phantomjs/test/#{ m[1] }_spec.coffee` }
end

guard :rspec, cmd: 'rspec' do
  watch('spec/spec_helper.rb') { 'spec' }
  watch(%r{spec/.+_spec.rb})
  watch(%r{lib/(.+).rb}) { |m| "spec/#{m[1]}_spec.rb" }
end

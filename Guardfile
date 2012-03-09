guard :coffeescript, :input => 'lib/guard/jasmine/phantomjs/src', :output => 'lib/guard/jasmine/phantomjs/lib'

guard :shell do
  watch(%r{(lib/guard/jasmine/phantomjs/test/.+_spec\.coffee)}) { |m| `mocha --ui bdd --growl #{ m[1]}` }
  watch(%r{lib/guard/jasmine/phantomjs/src/(.+)\.coffee}) { |m| `mocha --ui bdd --growl lib/guard/jasmine/phantomjs/test/#{ m[1] }_spec.coffee` }
end

guard :rspec, :rvm => ['1.8.7', '1.9.3'] do
  watch('spec/spec_helper.rb') { 'spec' }
  watch(%r{spec/.+_spec.rb})
  watch(%r{lib/(.+).rb})       { |m| "spec/#{ m[1] }_spec.rb" }
end

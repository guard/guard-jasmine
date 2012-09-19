guard :jasmine do
  watch(%r{spec/javascripts/spec\.(js\.coffee|js|coffee)$}) { 'spec/javascripts' }
  watch(%r{spec/javascripts/.+_spec\.(js\.coffee|js|coffee)$})
  watch(%r{app/assets/javascripts/(.+?)\.(js\.coffee|js|coffee)(?:\.\w+)*$}) { |m| "spec/javascripts/#{ m[1] }_spec.#{ m[2] }" }
end

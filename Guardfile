guard :minitest, env: { GUARD: true } do
  # with Minitest::Unit
  watch(%r{^test/(.*)\/?test_(.*)\.rb$})
  watch(%r{^lib/(.*/)?([^/]+)\.rb$})     { |m| "test/#{m[1]}test_#{m[2]}.rb" }
  watch(%r{^test/test_helper\.rb$})      { 'test' }
end

guard :bundler do
  watch('Gemfile')
  watch(/^.+\.gemspec/)
end

# guard :rubocop do
#   watch(%r{^lib/(.*)\/.+\.rb$})
#   watch(%r{^bin/(.*)\/.+\.rb$})
#   watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
# end

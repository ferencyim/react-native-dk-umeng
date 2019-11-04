require 'json'
pjson = JSON.parse(File.read('package.json'))

Pod::Spec.new do |s|

  s.name            = "RNUMCommon"
  s.version         = pjson["version"]
  s.homepage        = pjson["homepage"]
  s.summary         = pjson["description"]
  s.license         = pjson["license"]
  s.author          = pjson["author"]
  
  s.ios.deployment_target = '9.0'

  s.source             = { :git => "https://github.com/mokai/react-native-dk-umeng.git", :tag => "#{s.version}" }
  s.source_files       = 'ios/RNUMCommon/*.{h,m}', 'ios/RNUMCommon/**/*.{h,m}'
  s.preserve_paths     = "**/*.js"
  s.vendored_libraries = "ios/**/*.a"
 	
  s.dependency 'React'
end

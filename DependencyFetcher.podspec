Pod::Spec.new do |s|
  s.name             = 'DependencyFetcher'
  s.version          = '1.0.0'
  s.summary          = 'World\'s simplest dependency injection framework for Swift.'
  s.homepage         = 'https://github.com/broadwaylamb/DependencyFetcher'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'Sergej Jaskiewicz' => 'jaskiewiczs@icloud.com' }
  s.source           = { :git => 'https://github.com/broadwaylamb/DependencyFetcher.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/broadway_lamb'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.swift_version = '4.2'

  s.source_files = 'Sources/DependencyFetcher/Fetcher.swift'
end
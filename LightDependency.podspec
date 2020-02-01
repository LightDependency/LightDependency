Pod::Spec.new do |s|
  s.name             = 'LightDependency'
  s.version          = '1.0.1'
  s.summary          = 'DI Container for Swift.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  s.homepage         = 'https://github.com/LightDependency/LightDependency'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Gotyanov' => 'Aleksey.Gotyanov@gmail.com' }
  s.source           = { :git => 'https://github.com/LightDependency/LightDependency.git', :tag => s.version.to_s }

  s.requires_arc          = true

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'

  s.source_files = 'Sources/LightDependency/**/*.swift'
  s.swift_version = '4.2'
end

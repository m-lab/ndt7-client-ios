Pod::Spec.new do |s|
  s.name = 'NDT7'
  s.version = '0.0.4'
  s.license = 'Apache License, Version 2.0'
  s.summary = 'Measure the Internet, save the data, and make it universally accessible and useful.'
  s.homepage = 'https://github.com/m-lab/ndt7-client-ios'
  s.authors = { 'Miguel Nieto' => 'miguelangelnet@gmail.com' }
  s.source = { :git => 'https://github.com/m-lab/ndt7-client-ios.git', :tag => s.version }

  s.swift_version = '5.0'

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.tvos.deployment_target = '10.0'
  s.watchos.deployment_target = '3.0'

  s.source_files = 'Sources/*.swift'
end

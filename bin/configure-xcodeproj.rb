require 'xcodeproj'

project = Xcodeproj::Project.open('KulloChatServer.xcodeproj')
project.build_settings('Debug')['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
project.build_settings('Debug')['OTHER_SWIFT_FLAGS'] += ['-Onone']
project.save

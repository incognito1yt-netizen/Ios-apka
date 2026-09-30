#!/usr/bin/env ruby
# Generuje DiscordiOSApp.xcodeproj na runnerze macOS (nie trzeba commitowac pbxproj z Windows)
require 'xcodeproj'

project = Xcodeproj::Project.new('DiscordiOSApp.xcodeproj')
target = project.new_target(:application, 'DiscordiOSApp', :ios, '17.0')
target.product_name = 'DiscordiOSApp'

group = project.main_group.find_subpath('DiscordiOSApp', true)
files = [
  'DiscordiOSApp/DiscordiOSAppApp.swift',
  'DiscordiOSApp/ContentView.swift',
  'DiscordiOSApp/Models/DiscordModels.swift',
  'DiscordiOSApp/Services/DiscordConfig.swift',
  'DiscordiOSApp/Services/DiscordAuthManager.swift',
  'DiscordiOSApp/Services/DiscordAPIService.swift',
  'DiscordiOSApp/Views/LoginView.swift',
  'DiscordiOSApp/Views/GuildListView.swift',
  'DiscordiOSApp/Views/ChannelListView.swift',
  'DiscordiOSApp/Views/ChatView.swift'
]
files.each do |f|
  ref = group.new_file(f)
  target.add_file_references([ref])
end

target.build_configurations.each do |c|
  c.build_settings['SWIFT_VERSION'] = '5.0'
  c.build_settings['GENERATE_INFOPLIST_FILE'] = 'NO'
  c.build_settings['INFOPLIST_FILE'] = 'DiscordiOSApp/Info.plist'
  c.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.twojafirma.discordiosapp'
  c.build_settings['CODE_SIGN_STYLE'] = 'Manual'
  c.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
  c.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
  c.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  c.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
end

project.save
puts 'Project generated OK'

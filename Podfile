source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!
platform :ios, '9.0'

target 'Tempo' do

    pod 'HanekeSwift', :git => 'https://github.com/Haneke/HanekeSwift.git', :branch => 'feature/swift-3'
    pod 'Bolts'
    pod 'Alamofire'
	pod 'FBSDKCoreKit'
	pod 'FBSDKLoginKit'
	pod 'FBSDKShareKit'
	pod 'MarqueeLabel/Swift'
	pod 'Onboard'
	pod 'SwiftyJSON'
	pod 'SWRevealViewController'
	pod 'Tweaks'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end

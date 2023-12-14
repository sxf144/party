# Uncomment the next line to define a global platform for your project
# source 'https://github.com/CocoaPods/Specs.git

platform :ios, '13.0'

target 'Platform' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for PadSole
  #   pod 'SDCycleScrollView'
  #  pod 'SwiftyFitsize'  #siwft 适配
  
  # *********************************************** Swift ***********************************************
  pod 'SwiftyAttributes'  # attributed strings 扩展,swift 富文本
  pod 'Alamofire'
  pod 'SnapKit'
  pod 'Kingfisher'
  pod 'SwiftyJSON'
  pod 'RxSwift'
  pod 'RxTheme'
  pod 'SwifterSwift'
  pod 'IQKeyboardManagerSwift'
  pod 'MJRefresh', '~> 3.1.15.3'
#  pod 'TencentOpenAPI-Unofficial'
#  pod 'SwiftyStoreKit'   #内购
  pod 'AliyunOSSiOS'  #阿里云
  pod 'ZLPhotoBrowser'
  pod 'JXSegmentedView'
#  pod 'WechatOpenSDK'
#  pod 'AMap3DMap-NO-IDFA'
  pod 'AMapSearch-NO-IDFA'
  pod 'AMapLocation-NO-IDFA'
  pod 'AMapNavi-NO-IDFA' #内包含 AMap3DMap-NO-IDFA，无需再引用 AMap3DMap-NO-IDFA
  pod 'TXIMSDK_Plus_Swift_iOS'
  pod 'WechatOpenSDK-XCFramework'
  pod 'swiftScan'   #iOS qrCode、barCode Swift Version
  pod 'Pinyin4Swift'
  # *********************************************** Objective-C ***********************************************

end

#post_install do |installer|
#    installer.generated_projects.each do |project|
#          project.targets.each do |target|
#              target.build_configurations.each do |config|
#                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
#               end
#          end
#   end
#end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end


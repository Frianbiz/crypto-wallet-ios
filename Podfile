platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

def shared_pods
    # pod à installer ici
    pod 'web3swift', :git => 'https://github.com/MercuryProtocol/web3.swift.git', :branch => 'master'
    pod 'Alamofire', '4.5'
end

target 'crypto-wallet' do
    shared_pods
end

target 'pay' do
    shared_pods
end

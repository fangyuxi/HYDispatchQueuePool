

Pod::Spec.new do |s|
  s.name             = 'HYDispatchQueuePool'
  s.version          = '0.0.1'
  s.summary          = 'GCD QUEUE POOL'
  s.description      = 'A GCD QUEUE POOL'

  s.homepage         = 'https://github.com/fangyuxi/HYDispatchQueuePool'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fangyuxi' => 'fangyuxi@58.com' }
  s.source           = { :git => 'https://github.com/fangyuxi/HYDispatchQueuePool.git', :tag => s.version.to_s }

  s.ios.deployment_target = '6.0'

  s.source_files = 'HYDispatchQueuePool/Classes/**/*'
end

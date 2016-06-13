

Pod::Spec.new do |s|
  s.name             = 'HYDispatchQueuePool'
  s.version          = '0.0.1'
  s.summary          = 'GCD QUEUE POOL'
  s.description      = <'GCD QUEUE 池，根据CPU核心数量，创建合适的串行队列，替代系统的并发队列'

  s.homepage         = 'https://github.com/fangyuxi/HYDispatchQueuePool'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fangyuxi' => 'fangyuxi@58.com' }
  s.source           = { :git => 'https://github.com/fangyuxi/HYDispatchQueuePool.git', :tag => s.version.to_s }

  s.ios.deployment_target = '6.0'

  s.source_files = 'HYDispatchQueuePool/Classes/**/*'
end

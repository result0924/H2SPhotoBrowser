Pod::Spec.new do |s|
    s.name          =  "H2SPhotoBrowser"
    s.summary       =  "H2 photo browser"
    s.version       =  "1.0.0"
    s.homepage      =  "https://github.com/result0924/H2SPhotoBrowser"
    s.license       =  { :type => 'MIT' }
    s.author        =  { "H2" => "service@health2sync.com" }
    s.source        =  { :git => "git@github.com:result0924/H2SPhotoBrowser.git" }
    s.platform      =  :ios, '14.0'
    s.source_files  =  'H2SPhotoBrowser/*'
    s.dependency 'SDWebImage', '~> 3.7.1'
    s.requires_arc  =  true
    end
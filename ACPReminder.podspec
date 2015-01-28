Pod::Spec.new do |s|
  s.name         = 'ACPReminder'
  s.version      = '1.0.2'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage     = 'https://github.com/antoniocasero/ACPReminder'
  s.authors      =  {'Antonio Casero' => 'anto.casero@gmail.com'}
  s.summary      = 'ACPReminder provides automatic local notificacions, in order to marketing your app or explaining use cases to user.'
  s.screenshots      = ["http://antoniocasero.github.io/ACPReminder/screenshots/acpreminder.png"]
# Source Info
  s.platform     =  :ios, '5.1'
  s.source       =  {:git => 'https://github.com/antoniocasero/ACPReminder.git', :tag => s.version.to_s}
  s.source_files = 'ACPReminder/ACPReminder.{h,m}'


  s.requires_arc = true
  
# Pod Dependencies

end
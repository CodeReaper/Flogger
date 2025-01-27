
Pod::Spec.new do |s|
    s.name             = 'Flogger'
    s.version          = '1.0.4'
    s.summary          = 'Flogger is a deadsimple logging engine.'

    s.description      = <<-DESC
Flogger is a deadsimple logging engine. Flogger supports logging to console, files and Humio.
                        DESC

    s.homepage         = 'https://github.com/CodeReaper/Flogger'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Jakob Jensen' => 'jakobj@jakobj.dk' }
    s.source           = { :git => 'https://github.com/CodeReaper/Flogger.git', :tag => s.version.to_s }

    s.ios.deployment_target = '14.0'
    s.source_files = 'Sources/**'

end

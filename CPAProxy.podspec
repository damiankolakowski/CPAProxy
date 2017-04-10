Pod::Spec.new do |s|
  s.name            = "CPAProxy"
  s.version         = "1.1.0"
  s.summary         = "CPAProxy is a thin Objective-C wrapper around Tor."
  s.author          = "Claudiu-Vlad Ursache <claudiu.vlad.ursache@gmail.com>"

  s.homepage        = "https://github.com/ursachec/CPAProxy"
  s.license         = { :type => 'MIT', :file => 'LICENSE.md' }
  s.source          = { :git => "https://github.com/chrisballinger/CPAProxy.git", :branch => "podspec"}

  # Command for building static libraries dependencies (open ssl, libevent, lib tor) for CPAProxy.
  # For macosx we keep the binary artifacts in the repository (see CPAProxyDependencies directory).
  # // TODO validate artifacts md5 to make sure they are from known source.
  # s.prepare_command = <<-CMD
  #   bash ./scripts/build-all-osx.sh
  # CMD

  s.dependency 'CocoaAsyncSocket'

  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.12'

  s.source_files = "CPAProxy/*.{h,m}", "CPAProxyDependencies/tor_cpaproxy.h"
  s.private_header_files = 'CPAProxyDependencies/tor_cpaproxy.h'
  s.vendored_libraries  = "CPAProxyDependencies/*.a"
  s.resource_bundles = {"CPAProxy" => ["CPAProxyDependencies/geoip", "CPAProxyDependencies/geoip6", "CPAProxyDependencies/torrc"]}
  s.libraries   = 'crypto', 'curve25519_donna', 'event_core', 'event_extra', 'event_openssl',
                  'event_pthreads', 'event', 'or-crypto', 'or-event', 'or', 'ssl', 'tor', 'z',
                  'or-trunnel', 'ed25519_donna', 'ed25519_ref10', 'or-ctime'
  s.requires_arc = true
end
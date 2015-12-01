#
# Be sure to run `pod lib lint OLCOrm.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "OLCOrm"
  s.version          = "1.0.1"
  s.summary          = "OLCOrm is an Object Relational Mapping library for iOS, which uses FMDB Sqlite database library."
  s.description      = <<-DESC
                       We all know the working with Core Data is major pain in the neck. Yet it is in a way bit easy you work with, if you get an hold of how it actually work, working with only model classes to update the database structure on the fly.
                       And for those who hate to use Core Data, FMDB is you best choice. But still it lack the capability of mapping objects to models. So you  have to manually create the database and queries, ah.
                       So I develop this Library as an wrapper library to FMDB, that handle the database, table & all other CRUD function that we use daily. To make you life easier.
                       This library is still at it early stages (not even Alpha) so you are always welcome to teak things here and there to make this better :)
                       
                       Happy Coding.

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/LakithaRav/OLCOrm"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Lakitha Samarasinghe" => "lakitharav@gmail.com" }
  s.source           = { :git => "https://github.com/LakithaRav/OLCOrm.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  #s.resources = 'Pod/Assets/*.png'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'FMDB'
end
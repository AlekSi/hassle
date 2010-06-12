require 'rubygems'
require 'spec'
require 'rack/test'

require File.dirname(__FILE__) + '/../lib/hassle'

SASS_OPTIONS = Sass::Plugin.options.dup

SASS_DATA = %[
$blue: #3bbfce
.col
  color: $blue
]

SCSS_DATA = %[
$blue: #3bbfce;
.col {
  color: $blue;
}
]

def write_data(location, css_file, format)
  FileUtils.mkdir_p(location)
  sass_path = File.join(location, "#{css_file}.#{format}")
  File.open(sass_path, "w") do |f|
    f.write(format == :sass ? SASS_DATA : SCSS_DATA)
  end

  File.join(@hassle.css_location(location), "#{css_file}.css") if @hassle
end

def write_sass(location, css_file = "screen")
  write_data(location, css_file, :sass)
end

def write_scss(location, css_file = "screen")
  write_data(location, css_file, :scss)
end

def be_compiled
  simple_matcher("exist") { |given| File.exists?(given) }
  simple_matcher("contain compiled sass") { |given| File.read(given) == ".col {\n  color: #3bbfce; }\n" }
end

def have_tmp_dir_removed(*stylesheets)
  simple_matcher("remove tmp dir") do |given|
    given == stylesheets.map { |css| css.gsub(File.join(Dir.pwd, "tmp", "hassle"), "") }
  end
end

def have_served_sass
  simple_matcher("return success") { |given| given.status == 200 }
  simple_matcher("compiled sass") { |given| given.body.should == ".col {\n  color: #3bbfce; }\n" }
end

def reset
  Sass::Plugin.options.clear
  Sass::Plugin.options = SASS_OPTIONS
  FileUtils.rm_rf([File.join(Dir.pwd, "public"), File.join(Dir.pwd, "tmp")])
end

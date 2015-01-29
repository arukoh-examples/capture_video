require 'rubygems'
require 'headless'
require 'selenium-webdriver'

options = {}
options[:dimensions]            = ENV['DISPLAY_DIMENSIONS'] || Headless::DEFAULT_DISPLAY_DIMENSIONS
options[:video]                 = {}
options[:video][:log_file_path] = ENV['VIDEO_CAPTURE_LOG_FILE_PATH'] || "/dev/null"
options[:video][:codec]         = ENV['VIDEO_CAPTURE_CODEC']      if ENV['VIDEO_CAPTURE_CODEC']
options[:video][:frame_rate]    = ENV['VIDEO_CAPTURE_FRAME_RATE'] if ENV['VIDEO_CAPTURE_FRAME_RATE']

headless = Headless.new(options)
headless.start
headless.video.start_capture

driver = Selenium::WebDriver.for :firefox
driver.navigate.to 'http://google.com'
puts driver.title

headless.video.stop_and_save(ENV['VIDEO_CAPTURE_OUTPUT_PATH'] || "captured.mov")
headless.destroy

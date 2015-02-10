require 'rubygems'
require 'headless'
require 'selenium-webdriver'

# monkey patch until close https://github.com/leonid-shevtsov/headless/pull/53
class Headless
  class VideoRecorder
    def start_capture
      CliUtil.fork_process("#{CliUtil.path_to('ffmpeg')} -y -r #{@frame_rate} -s #{@dimensions} -f x11grab -i :#{@display} -g 600 -vcodec #{@codec} #{@tmp_file_path}", @pid_file_path, @log_file_path)
      at_exit do
        exit_status = $!.status if $!.is_a?(SystemExit)
        stop_and_discard
        exit exit_status if exit_status
      end
    end
  end
end

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

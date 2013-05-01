require 'pry'

class ImageSetsProcessor
  attr_reader :set_path, :ignore_file, :full_path

  def initialize(set_path, ignore_file)
    @set_path = File.expand_path set_path
    @ignore_file = ignore_file
  end

  def process
    Dir.foreach set_path do |entry|
      @full_path = File.join(set_path, entry)
      if valid_album?(entry)
        puts "processing #{entry}"
        processor = ImageProcessor.new(full_path)
        processor.process_images
      end
    end
  end

  def valid_album?(name)
    return false unless File.directory?(full_path)
    return false if name =~ /\A\./
    return is_ignored?(name)
  end

  def is_ignored?(name)
    ignores.each do |ignore|
      return false if name == ignore.strip
    end
    true
  end

  def ignores
    @ignores ||= load_ignores
  end

  def load_ignores
    ignore_path = File.join(set_path, ignore_file)
    if File.exists? ignore_path
      IO.readlines(ignore_path)
    else
      []
    end
  end
end

require "RMagick"

class ImageProcessor
  def initialize(directory)
    directory = File.expand_path(directory)
    raise "### You must specify a directory containing images to process" unless File.directory?(directory)
    @directory = directory
    @image_names = get_images(directory)
    @web_dir = File.join(directory, 'web')
    @thumbs_dir = File.join(directory, 'thumbs')
    exisiting_web_images = get_images(File.join(directory, 'web'))
    exisiting_thumbnail_images = get_images(File.join(directory, 'web'))
    processed_images = exisiting_web_images & exisiting_thumbnail_images
    @images_to_process = @image_names - processed_images
  end

  def process_images
    guard_dir @web_dir
    guard_dir @thumbs_dir
    each_image do |image, basename|
      auto_orient_image!(image)
      create_thumbnail_image(image, basename)
      create_web_image(image, basename)
    end
  end

  def auto_orient_images!
    each_image do |image, filename|
      auto_orient_image!(image)
    end
  end

  def create_web_images
    guard_dir @web_dir
    each_image do |image, basename|
      create_web_image(image, basename)
    end
  end

  def create_thumbnail_images
    guard_dir @thumbs_dir
    each_image do |image, basename|
      create_thumbnail_image(image)
    end
  end

  def auto_orient_image!(image)
    if image.auto_orient!
      puts "rotating #{image.filename}"
      image.write image.filename
    end
  end

  def create_thumbnail_image(image, basename)
    thumb = image.resize_to_fill(75, 75)
    thumb.write(File.join(@thumbs_dir, basename))
  end

  def create_web_image(image, basename)
    web = image.resize_to_fit(1024, 1024)
    web.write(File.join(@web_dir, basename))
  end

  def each_image
    @images_to_process.each do |filename|
      image = Magick::ImageList.new(File.join(@directory, filename))
      yield image, filename
    end
  end

  def guard_dir(name)
    if Dir.exists?(name)
      abort("rake aborted!") if ask("The '#{name}' directory already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
    else
      Dir.mkdir(name)
    end
  end

  def get_images(directory)
    Dir.entries(directory).select { |f| f =~ /\.jpg|png\Z/i }
  end
end

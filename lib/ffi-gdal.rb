require 'ffi'

module GDAL
  GDAL_BASE = File.join File.dirname(__FILE__), 'ffi-ogr'

  module FFIGDAL
    def self.search_paths
      @search_paths ||= begin
        if ENV['GDAL_LIBRARY_PATH']
        elsif FFI::Platform.windows?
          ENV['PATH'].split(File::PATH_SEPARATOR)
        else
          ['/usr/local/{lib64,lib}', '/opt/local/{lib64,lib}', '/usr/{lib64,lib}']
          ['/usr/local/{lib64,lib}', '/opt/local/{lib64,lib}', '/usr/{lib64,lib}', '/usr/lib/{x86_64,i386}-linux-gnu']
        end
      end
    end

    def self.find_lib(lib)
      if ENV['GDAL_LIBRARY_PATH'] && File.file?(ENV['GDAL_LIBRARY_PATH'])
        ENV['GDAL_LIBRARY_PATH']
      else
        Dir.glob(search_paths.map { |path|
          File.expand_path(File.join(path, "#{lib}.#{FFI::Platform::LIBSUFFIX}"))
        })
      end
    end

    def self.gdal_library_path
      @gdal_library_path ||= begin
        find_lib('{lib,}gdal{,-?}')
      end
    end

    extend ::FFI::Library

    enum :gdal_data_type, [
      :unknown, 0,
      :byte, 1,
      :uint16, 2,
      :int16, 3,
      :uint32, 4,
      :int32, 5,
      :float32, 6,
      :float64, 7,
      :cint16, 8,
      :cint32, 9,
      :cfloat32, 10,
      :cfloat64, 11,
      :type_count, 12
    ]

    enum :gdal_async_status_type, [
      :pending, 0,
      :update, 1,
      :error, 2,
      :complete, 3,
      :type_count, 4
    ]

    enum :gdal_access, [
      :read_only, 0,
      :update, 1
    ]

    enum :gdal_rw_flag, [
      :read, 0,
      :write, 1
    ]

    enum :gdal_color_interp, [
      :undefined, 0,
      :gray_index, 1,
      :palette_index, 2,
      :red_band, 3,
      :green_band, 4,
      :blue_band, 5,
      :alpha_band, 6,
      :hue_band, 7,
      :saturation_band, 8,
      :lightness_band, 9,
      :cyan_band, 10,
      :magenta_band, 11,
      :yellow_band, 12,
      :black_band, 13,
      :y_cb_cr_y_band, 14,
      :y_cb_cr_cb_band, 15,
      :y_cb_cr_cr_band, 16,
      :max, 16
    ]

    enum :gdal_palette_interp, [
      :gray, 0,
      :rgb, 1,
      :cmyk, 2,
      :hls, 3
    ]

    enum :gdal_rat_field_type, [
      :integer,
      :real,
      :string
    ]

    enum :gdal_rat_field_usage, [
      :generic, 0,
      :pixel_count, 1,
      :name, 2,
      :min, 3,
      :max, 4,
      :min_max, 5,
      :red, 6,
      :green, 7,
      :blue, 8,
      :alpha, 9,
      :red_min, 10,
      :green_min, 11,
      :blue_min, 12,
      :alpha_min, 13,
      :red_max, 14,
      :green_max, 15,
      :blue_max, 16,
      :alpha_max, 17,
      :max_count
    ]

    GDAL_FUNCTIONS = {
      :GDALAllRegister => [[], :void],
      :GDALGetDriverCount => [[], :int],
      :GDALGetDriver => [[:int], :pointer],
      :GDALGetDriverByName => [[:string], :pointer],
      :GDALDestroyDriver => [[:pointer], :void],
      :GDALRegisterDriver => [[:pointer], :void],
      :GDALDeregisterDriver => [[:pointer], :void],
      :GDALDestroyDriverManager => [[], :void],
      :GDALGetDriverShortName => [[:pointer], :string],
      :GDALGetDriverLongName => [[:pointer], :string],

      :GDALCreate => [[:pointer, :string, :int, :int, :int, :pointer, :pointer], :pointer],
      
      :GDALVersionInfo => [[:string], :string]
    }

    begin
      ffi_lib gdal_library_path

      GDAL_FUNCTIONS.each do |func, params|
        attach_function func, params.first, params.last
      end

      # register all available GDAL drivers
      # also verifies library is loaded
      GDALAllRegister()
    rescue LoadError, NoMethodError
      raise LoadError.new('Could not load GDAL library')
    end
  end

  class << self
    def gdal_version
      FFIGDAL.GDALVersionInfo('RELEASE_NAME')
    end

    def get_available_drivers
      [].tap do |drivers|
        for i in 0...FFIGDAL.GDALGetDriverCount
          drivers << FFIGDAL.GDALGetDriverLongName(FFIGDAL.GDALGetDriver(i))
        end
      end
    end
    alias_method :drivers, :get_available_drivers
  end
end


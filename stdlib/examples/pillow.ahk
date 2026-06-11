#Requires AutoHotkey v2.0
#ErrorStdOut "UTF-8"
#Warn All, StdOut
#Warn LocalSameAsGlobal, Off

#Include <stdlib\io>
#Include <stdlib\pillow>

pillow_example_output_dir := A_Temp "\ahk-stdlib-pillow-example"
if !DirExist(pillow_example_output_dir)
    DirCreate pillow_example_output_dir

pillow_example_path := pillow_example_output_dir "\pillow_core.png"
pillow_example_color_rgb := stdlib.pillow.ImageColor.getrgb("rebeccapurple")
pillow_example_color_luma := stdlib.pillow.ImageColor.getcolor("navy", "L")
pillow_example_rgb_bands := stdlib.pillow.Image.getmodebands("RGB")
pillow_example_rgba_bandnames := stdlib.pillow.Image.getmodebandnames("RGBA")
pillow_example_rgba_base := stdlib.pillow.Image.getmodebase("RGBA")
pillow_example_float_type := stdlib.pillow.Image.getmodetype("F")
pillow_example_i32le := stdlib.pillow.Image.i32le([0x78, 0x56, 0x34, 0x12])
pillow_example_i32le_offset := stdlib.pillow.Image.i32le([120, 120, 0x78, 0x56, 0x34, 0x12], 2)
pillow_example_o32le := stdlib.pillow.Image.o32le(0x12345678)
pillow_example_o32be := stdlib.pillow.Image.o32be(0x12345678)
pillow_example_preinit := stdlib.pillow.Image.preinit()
pillow_example_init := stdlib.pillow.Image.init()
pillow_example_init_again := stdlib.pillow.Image.init()
pillow_example_image_is_path_string := stdlib.pillow.Image.is_path(pillow_example_path)
pillow_example_image_is_path_stream := stdlib.pillow.Image.is_path(stdlib.io.BytesIO([120]))
pillow_example_max_image_pixels := stdlib.pillow.Image.MAX_IMAGE_PIXELS
pillow_example_warn_possible_formats := stdlib.pillow.Image.WARN_POSSIBLE_FORMATS
pillow_example_default_strategy := stdlib.pillow.Image.DEFAULT_STRATEGY
pillow_example_filtered_strategy := stdlib.pillow.Image.FILTERED
pillow_example_huffman_strategy := stdlib.pillow.Image.HUFFMAN_ONLY
pillow_example_rle_strategy := stdlib.pillow.Image.RLE
pillow_example_fixed_strategy := stdlib.pillow.Image.FIXED
pillow_example_web_strategy := stdlib.pillow.Image.WEB
pillow_example_nearest_alias := stdlib.pillow.Image.NEAREST
pillow_example_bicubic_alias := stdlib.pillow.Image.BICUBIC
pillow_example_affine_alias := stdlib.pillow.Image.AFFINE
pillow_example_flip_left_right_alias := stdlib.pillow.Image.FLIP_LEFT_RIGHT
pillow_example_floydsteinberg_alias := stdlib.pillow.Image.FLOYDSTEINBERG
pillow_example_mediancut_alias := stdlib.pillow.Image.MEDIANCUT
try {
    stdlib.pillow.Image.ImagePointHandler()
} catch as pillow_example_image_point_handler_error {
    pillow_example_image_point_handler_error_message := pillow_example_image_point_handler_error.Message
}
try {
    stdlib.pillow.Image.ImageTransformHandler()
} catch as pillow_example_image_transform_handler_error {
    pillow_example_image_transform_handler_error_message := pillow_example_image_transform_handler_error.Message
}
pillow_example_unidentified_error_message := stdlib.pillow.Image.UnidentifiedImageError("cannot identify").Message
pillow_example_decompression_warning_message := stdlib.pillow.Image.DecompressionBombWarning("large image").Message
pillow_example_decompression_error_message := stdlib.pillow.Image.DecompressionBombError("too large").Message
pillow_example_deferred_error_source := RuntimeError("image deferred", -1)
pillow_example_deferred_error := stdlib.pillow.Image.DeferredError.new(pillow_example_deferred_error_source)
try {
    pillow_example_deferred_error.anything
} catch as pillow_example_deferred_error_caught {
    pillow_example_deferred_error_message := pillow_example_deferred_error_caught.Message
}
pillow_example_exif := stdlib.pillow.Image.Exif()
pillow_example_exif_empty_bytes := pillow_example_exif.tobytes()
pillow_example_exif_empty_prefix := [pillow_example_exif_empty_bytes[1], pillow_example_exif_empty_bytes[2], pillow_example_exif_empty_bytes[3], pillow_example_exif_empty_bytes[4]]
pillow_example_exif[274] := 6
pillow_example_exif[305] := "AHK"
pillow_example_exif_orientation := pillow_example_exif.get(274)
pillow_example_exif_keys := pillow_example_exif.keys()
pillow_example_exif_items := pillow_example_exif.items()
pillow_example_exif_ifd0_count := pillow_example_exif.get_ifd(0).Count
pillow_example_exiftags_orientation := stdlib.pillow.ExifTags.TAGS[274]
pillow_example_exiftags_gps_latitude := stdlib.pillow.ExifTags.GPSTAGS[2]
pillow_example_exiftags_base_orientation := stdlib.pillow.ExifTags.Base.Orientation
pillow_example_exiftags_gps_datestamp := stdlib.pillow.ExifTags.GPS.GPSDateStamp
pillow_example_exiftags_ifd_exif := stdlib.pillow.ExifTags.IFD.Exif
pillow_example_exiftags_light_flash := stdlib.pillow.ExifTags.LightSource.Flash
pillow_example_tifftags_long := stdlib.pillow.TiffTags.LONG
pillow_example_tifftags_width := stdlib.pillow.TiffTags.TAGS[256]
pillow_example_tifftags_lzw := stdlib.pillow.TiffTags.TAGS["(259, 5)"]
pillow_example_tifftags_orientation := stdlib.pillow.TiffTags.lookup(274)
pillow_example_tifftags_orientation_name := pillow_example_tifftags_orientation.name
pillow_example_tifftags_orientation_type := pillow_example_tifftags_orientation.type
pillow_example_tifftags_compression_lzw := stdlib.pillow.TiffTags.TAGS_V2[259].enum["LZW"]
pillow_example_tifftags_gps_latitude_type := stdlib.pillow.TiffTags.lookup(2, 34853).type
pillow_example_tifftags_core_has_width := stdlib.pillow.TiffTags.LIBTIFF_CORE.Has(256)
pillow_example_features_modules := stdlib.pillow.features.get_supported_modules()
pillow_example_features_codecs := stdlib.pillow.features.get_supported_codecs()
pillow_example_features_supported := stdlib.pillow.features.get_supported()
pillow_example_features_pil := stdlib.pillow.features.check("pil")
pillow_example_features_jpg_version := stdlib.pillow.features.version_codec("jpg")
pillow_example_features_raqm := stdlib.pillow.features.check_feature("raqm")
pillow_example_features_xcb := stdlib.pillow.features.check_feature("xcb")
pillow_example_features_unknown_records := stdlib.warnings.catch_warnings(true).Call((records) => stdlib.pillow.features.check("unknown_feature"))
pillow_example_features_unknown_message := pillow_example_features_unknown_records[1].message
pillow_example_features_info := stdlib.io.StringIO()
pillow_example_features_pilinfo := stdlib.pillow.features.pilinfo(pillow_example_features_info, false)
pillow_example_features_info_prefix := SubStr(pillow_example_features_info.getvalue(), 1, 20)
pillow_example_report_info := stdlib.io.StringIO()
pillow_example_report_pilinfo := stdlib.pillow.report.pilinfo(pillow_example_report_info, false)
pillow_example_report_has_tkinter := InStr(pillow_example_report_info.getvalue(), "--- TKINTER support ok") > 0
pillow_example_report_formats := stdlib.io.StringIO()
pillow_example_report_formats_result := stdlib.pillow.report.pilinfo(pillow_example_report_formats, true)
pillow_example_report_has_jpeg := InStr(pillow_example_report_formats.getvalue(), "JPEG image/jpeg") > 0
pillow_example_jpegpresets := stdlib.pillow.JpegPresets.presets
pillow_example_jpegpresets_web_high_subsampling := pillow_example_jpegpresets["web_high"]["subsampling"]
pillow_example_jpegpresets_web_high_luma_prefix := PillowExampleArraySlice(pillow_example_jpegpresets["web_high"]["quantization"][1], 1, 8)
pillow_example_jpegpresets_web_low_chroma_tail := PillowExampleArraySlice(pillow_example_jpegpresets["web_low"]["quantization"][2], 57, 64)
pillow_example_jpegpresets_maximum_luma_sum := PillowExampleArraySum(pillow_example_jpegpresets["maximum"]["quantization"][1])
pillow_example_jpeg_bytes := PillowExampleJpegHeaderBytes()
pillow_example_jpeg_accept := stdlib.pillow.JpegImagePlugin._accept(PillowExampleArraySlice(pillow_example_jpeg_bytes, 1, 16))
pillow_example_jpeg_file_format := stdlib.pillow.JpegImagePlugin.JpegImageFile.format
pillow_example_jpeg_file_description := stdlib.pillow.JpegImagePlugin.JpegImageFile.format_description
pillow_example_jpeg_registered_jpg := stdlib.pillow.Image.registered_extensions()[".jpg"]
pillow_example_jpeg_mime := stdlib.pillow.Image.MIME["JPEG"]
pillow_example_jpeg_direct := stdlib.pillow.JpegImagePlugin.JpegImageFile(stdlib.io.BytesIO(pillow_example_jpeg_bytes))
pillow_example_jpeg_sampling := stdlib.pillow.JpegImagePlugin.get_sampling(pillow_example_jpeg_direct)
pillow_example_jpeg_jfif_density := pillow_example_jpeg_direct.info["jfif_density"]
pillow_example_jpeg_dpi := pillow_example_jpeg_direct.info["dpi"]
pillow_example_jpeg_quantization_prefix := PillowExampleArraySlice(pillow_example_jpeg_direct.quantization[0], 1, 8)
pillow_example_jpeg_getmp := pillow_example_jpeg_direct._getmp()
pillow_example_jpeg_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_jpeg_bytes), "r", ["JPEG"])
pillow_example_jpeg_opened_size := pillow_example_jpeg_opened.size
pillow_example_jpeg_opened_mode := pillow_example_jpeg_opened.mode
pillow_example_jpeg_opened.close()
pillow_example_jpeg_direct.close()
pillow_example_fontfile_width := stdlib.pillow.FontFile.WIDTH
pillow_example_fontfile_buffer := stdlib.io.BytesIO()
pillow_example_fontfile_puti16 := stdlib.pillow.FontFile.puti16(pillow_example_fontfile_buffer, [1, -1, 0x1234, -2, 0, 32767, -32768, 255, 256, -255])
pillow_example_fontfile_bytes := pillow_example_fontfile_buffer.getvalue()
pillow_example_bdf_bytes := PillowExampleBdfFontBytes()
pillow_example_bdf_first := stdlib.pillow.BdfFontFile.bdf_char(stdlib.io.BytesIO(pillow_example_bdf_bytes))
pillow_example_bdf_first_id := pillow_example_bdf_first[1]
pillow_example_bdf_first_encoding := pillow_example_bdf_first[2]
pillow_example_bdf_first_bbox := pillow_example_bdf_first[3]
pillow_example_bdf_first_image_bbox := pillow_example_bdf_first[4].getbbox()
pillow_example_bdf_font := stdlib.pillow.BdfFontFile.BdfFontFile(stdlib.io.BytesIO(pillow_example_bdf_bytes))
pillow_example_bdf_glyph_a := PillowExampleFontGlyphMetrics(pillow_example_bdf_font[65])
pillow_example_bdf_compile := pillow_example_bdf_font.compile()
pillow_example_bdf_bitmap_size := pillow_example_bdf_font.bitmap.size
pillow_example_bdf_metric_a := pillow_example_bdf_font.metrics[66]
pillow_example_bdf_save_path := pillow_example_output_dir "\bdf-example.pil"
pillow_example_bdf_save := pillow_example_bdf_font.save(pillow_example_bdf_save_path)
pillow_example_bdf_saved_pil_prefix := PillowExampleArraySlice(PillowExampleReadBytes(pillow_example_bdf_save_path), 1, 8)
pillow_example_bdf_saved_png_prefix := PillowExampleArraySlice(PillowExampleReadBytes(pillow_example_output_dir "\bdf-example.pbm"), 1, 8)
pillow_example_bdf_loaded_font := stdlib.pillow.ImageFont.load(pillow_example_bdf_save_path)
pillow_example_bdf_loaded_bbox := pillow_example_bdf_loaded_font.getbbox("A")
pillow_example_bdf_loaded_length := pillow_example_bdf_loaded_font.getlength("A")
pillow_example_bdf_first[4].close()
pillow_example_bdf_font.bitmap.close()
pillow_example_pcf_module := stdlib.pillow.PcfFontFile
pillow_example_pcf_magic := pillow_example_pcf_module.PCF_MAGIC
pillow_example_pcf_bytes_per_row := [
    pillow_example_pcf_module.BYTES_PER_ROW[1](9),
    pillow_example_pcf_module.BYTES_PER_ROW[2](9),
    pillow_example_pcf_module.BYTES_PER_ROW[3](9),
    pillow_example_pcf_module.BYTES_PER_ROW[4](9),
]
pillow_example_pcf_sz := pillow_example_pcf_module.sz([97, 98, 99, 0, 100, 101, 102, 0], 4)
pillow_example_pcf_bytes := PillowExamplePcfBytes()
pillow_example_pcf_font := pillow_example_pcf_module.PcfFontFile(stdlib.io.BytesIO(pillow_example_pcf_bytes))
pillow_example_pcf_charset := pillow_example_pcf_font.charset_encoding
pillow_example_pcf_info_font := PillowExampleAsciiFromBytes(pillow_example_pcf_font.info["FONT"])
pillow_example_pcf_info_point_size := pillow_example_pcf_font.info["POINT_SIZE"]
pillow_example_pcf_glyph_a := PillowExampleFontGlyphMetrics(pillow_example_pcf_font.glyph[66])
pillow_example_pcf_glyph_a_pixels := PillowExamplePixelRows(pillow_example_pcf_font.glyph[66][4])
pillow_example_pcf_compile := pillow_example_pcf_font.compile()
pillow_example_pcf_bitmap_size := pillow_example_pcf_font.bitmap.size
pillow_example_pcf_metric_b := pillow_example_pcf_font.metrics[67]
pillow_example_pcf_font.glyph[66][4].close()
pillow_example_pcf_font.glyph[67][4].close()
pillow_example_pcf_font.bitmap.close()
pillow_example_container_source := stdlib.io.BytesIO([48, 49, 50, 10, 51, 52, 53, 10, 54, 55, 56, 57])
pillow_example_container_source.mode := "rb"
pillow_example_container := stdlib.pillow.ContainerIO.ContainerIO(pillow_example_container_source, 2, 7)
pillow_example_container_first := pillow_example_container.read(2)
pillow_example_container_seek_end := pillow_example_container.seek(-2, stdlib.io.SEEK_END)
pillow_example_container_zero_read := pillow_example_container.read(0)
pillow_example_container_line_source := stdlib.io.BytesIO([97, 10, 98, 98, 10, 99, 99, 99])
pillow_example_container_line_source.mode := "rb"
pillow_example_container_line_reader := stdlib.pillow.ContainerIO.ContainerIO(pillow_example_container_line_source, 0, 8)
pillow_example_container_first_line := pillow_example_container_line_reader.readline()
pillow_example_container_remaining_line := pillow_example_container_line_reader.readlines(1)
pillow_example_container_text_source := stdlib.io.StringIO("xy`nz")
pillow_example_container_text_source.mode := "r"
pillow_example_container_text_reader := stdlib.pillow.ContainerIO.ContainerIO(pillow_example_container_text_source, 1, 3)
pillow_example_container_text_line := pillow_example_container_text_reader.readline()
pillow_example_container_text_rest := pillow_example_container_text_reader.read()
pillow_example_bmp_plugin_save := stdlib.pillow.BmpImagePlugin.SAVE["RGB"]
pillow_example_bmp_plugin_bit2mode := stdlib.pillow.BmpImagePlugin.BIT2MODE[24]
pillow_example_bmp_plugin_accept := stdlib.pillow.BmpImagePlugin._accept([66, 77, 0, 0])
pillow_example_bmp_plugin_dib_accept := stdlib.pillow.BmpImagePlugin._dib_accept(stdlib.pillow.BmpImagePlugin.o32(40))
pillow_example_bmp_plugin_helper := stdlib.pillow.BmpImagePlugin.i32(stdlib.pillow.BmpImagePlugin.o32(0x12345678))
pillow_example_bmp_plugin_source := stdlib.pillow.Image.new("RGB", [3, 2], [10, 20, 30])
pillow_example_bmp_plugin_source.putpixel([1, 0], [200, 10, 5])
pillow_example_bmp_plugin_buffer := stdlib.io.BytesIO()
pillow_example_bmp_plugin_source.save(pillow_example_bmp_plugin_buffer, "BMP")
pillow_example_bmp_plugin_bytes := pillow_example_bmp_plugin_buffer.getvalue()
pillow_example_bmp_plugin_image := stdlib.pillow.BmpImagePlugin.BmpImageFile(stdlib.io.BytesIO(pillow_example_bmp_plugin_bytes))
pillow_example_bmp_plugin_pixel := pillow_example_bmp_plugin_image.getpixel([1, 0])
pillow_example_bmp_plugin_dib_bytes := PillowExampleArraySlice(pillow_example_bmp_plugin_bytes, 15, pillow_example_bmp_plugin_bytes.Length)
pillow_example_bmp_plugin_dib_image := stdlib.pillow.BmpImagePlugin.DibImageFile(stdlib.io.BytesIO(pillow_example_bmp_plugin_dib_bytes))
pillow_example_bmp_plugin_dib_format := pillow_example_bmp_plugin_dib_image.format
pillow_example_bmp_plugin_dib_pixel := pillow_example_bmp_plugin_dib_image.getpixel([1, 0])
pillow_example_bmp_plugin_dib_image.close()
pillow_example_bmp_plugin_image.close()
pillow_example_bmp_plugin_source.close()
pillow_example_avif_supported := stdlib.pillow.AvifImagePlugin.SUPPORTED
pillow_example_avif_codec_aom := stdlib.pillow.AvifImagePlugin.get_codec_version("aom")
pillow_example_avif_codec_unknown := stdlib.pillow.AvifImagePlugin.get_codec_version("unknown")
pillow_example_avif_threads := stdlib.pillow.AvifImagePlugin._get_default_max_threads()
pillow_example_avif_accept := stdlib.pillow.AvifImagePlugin._accept(PillowExampleAvifFtyp("avif"))
pillow_example_avif_reject := stdlib.pillow.AvifImagePlugin._accept(PillowExampleAvifFtyp("heic"))
pillow_example_avif_file_format := stdlib.pillow.AvifImagePlugin.AvifImageFile.format
pillow_example_avif_file_description := stdlib.pillow.AvifImagePlugin.AvifImageFile.format_description
pillow_example_avif_mime := stdlib.pillow.Image.MIME["AVIF"]
pillow_example_avif_save_error_image := stdlib.pillow.Image.new("RGB", [1, 1], [10, 20, 30])
try {
    pillow_example_avif_save_error_image.save(stdlib.io.BytesIO(), "AVIF", { quality: 101 })
} catch as pillow_example_avif_save_error {
    pillow_example_avif_save_error_message := pillow_example_avif_save_error.Message
} finally {
    pillow_example_avif_save_error_image.close()
}
pillow_example_bufr_accept := stdlib.pillow.BufrStubImagePlugin._accept(PillowExampleAsciiBytes("BUFRdemo"))
pillow_example_bufr_zczc_accept := stdlib.pillow.BufrStubImagePlugin._accept(PillowExampleAsciiBytes("ZCZCdemo"))
pillow_example_bufr_file_format := stdlib.pillow.BufrStubImagePlugin.BufrStubImageFile.format
pillow_example_bufr_registered_extension := stdlib.pillow.Image.registered_extensions()[".bufr"]
pillow_example_bufr_handler := PillowExampleBufrHandler()
pillow_example_bufr_register := stdlib.pillow.BufrStubImagePlugin.register_handler(pillow_example_bufr_handler)
pillow_example_bufr_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(PillowExampleAsciiBytes("BUFRpayload")), "r", ["BUFR"])
pillow_example_bufr_opened_mode := pillow_example_bufr_opened.mode
pillow_example_bufr_opened_size := pillow_example_bufr_opened.size
pillow_example_bufr_saved_source := stdlib.pillow.Image.new("RGB", [1, 1], [10, 20, 30])
pillow_example_bufr_output := stdlib.io.BytesIO()
pillow_example_bufr_save := pillow_example_bufr_saved_source.save(pillow_example_bufr_output, "BUFR")
pillow_example_bufr_saved_bytes := pillow_example_bufr_output.getvalue()
stdlib.pillow.BufrStubImagePlugin.register_handler(stdlib.None)
pillow_example_bufr_saved_source.close()
pillow_example_bufr_opened.close()
pillow_example_grib_bytes := PillowExampleAsciiBytes("GRIBxxx")
pillow_example_grib_bytes.Push(1)
for byte in PillowExampleAsciiBytes("payload")
    pillow_example_grib_bytes.Push(byte)
pillow_example_grib_wrong_marker := PillowExampleAsciiBytes("GRIBxxx")
pillow_example_grib_wrong_marker.Push(2)
pillow_example_grib_accept := stdlib.pillow.GribStubImagePlugin._accept(pillow_example_grib_bytes)
pillow_example_grib_reject := stdlib.pillow.GribStubImagePlugin._accept(pillow_example_grib_wrong_marker)
pillow_example_grib_file_format := stdlib.pillow.GribStubImagePlugin.GribStubImageFile.format
pillow_example_grib_registered_extension := stdlib.pillow.Image.registered_extensions()[".grib"]
pillow_example_grib_handler := PillowExampleBufrHandler()
pillow_example_grib_register := stdlib.pillow.GribStubImagePlugin.register_handler(pillow_example_grib_handler)
pillow_example_grib_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_grib_bytes), "r", ["GRIB"])
pillow_example_grib_opened_mode := pillow_example_grib_opened.mode
pillow_example_grib_opened_size := pillow_example_grib_opened.size
pillow_example_grib_saved_source := stdlib.pillow.Image.new("RGB", [1, 1], [10, 20, 30])
pillow_example_grib_output := stdlib.io.BytesIO()
pillow_example_grib_save := pillow_example_grib_saved_source.save(pillow_example_grib_output, "GRIB")
pillow_example_grib_saved_bytes := pillow_example_grib_output.getvalue()
stdlib.pillow.GribStubImagePlugin.register_handler(stdlib.None)
pillow_example_grib_saved_source.close()
pillow_example_grib_opened.close()
pillow_example_hdf5_bytes := [0x89, 0x48, 0x44, 0x46, 0x0D, 0x0A, 0x1A, 0x0A]
for byte in PillowExampleAsciiBytes("payload")
    pillow_example_hdf5_bytes.Push(byte)
pillow_example_hdf5_bad_bytes := [0x89, 0x48, 0x44, 0x46, 0x0D, 0x0A, 0x1A, 0x00]
pillow_example_hdf5_accept := stdlib.pillow.Hdf5StubImagePlugin._accept(pillow_example_hdf5_bytes)
pillow_example_hdf5_reject := stdlib.pillow.Hdf5StubImagePlugin._accept(pillow_example_hdf5_bad_bytes)
pillow_example_hdf5_file_format := stdlib.pillow.Hdf5StubImagePlugin.HDF5StubImageFile.format
pillow_example_hdf5_registered_h5 := stdlib.pillow.Image.registered_extensions()[".h5"]
pillow_example_hdf5_registered_hdf := stdlib.pillow.Image.registered_extensions()[".hdf"]
pillow_example_hdf5_handler := PillowExampleBufrHandler()
pillow_example_hdf5_register := stdlib.pillow.Hdf5StubImagePlugin.register_handler(pillow_example_hdf5_handler)
pillow_example_hdf5_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_hdf5_bytes), "r", ["HDF5"])
pillow_example_hdf5_opened_mode := pillow_example_hdf5_opened.mode
pillow_example_hdf5_opened_size := pillow_example_hdf5_opened.size
pillow_example_hdf5_saved_source := stdlib.pillow.Image.new("RGB", [1, 1], [10, 20, 30])
pillow_example_hdf5_output := stdlib.io.BytesIO()
pillow_example_hdf5_save := pillow_example_hdf5_saved_source.save(pillow_example_hdf5_output, "HDF5")
pillow_example_hdf5_saved_bytes := pillow_example_hdf5_output.getvalue()
stdlib.pillow.Hdf5StubImagePlugin.register_handler(stdlib.None)
pillow_example_hdf5_saved_source.close()
pillow_example_hdf5_opened.close()
pillow_example_icns_accept := stdlib.pillow.IcnsImagePlugin._accept(PillowExampleAsciiBytes("icnsdemo"))
pillow_example_icns_file_format := stdlib.pillow.IcnsImagePlugin.IcnsImageFile.format
pillow_example_icns_registered_extension := stdlib.pillow.Image.registered_extensions()[".icns"]
pillow_example_icns_registered_mime := stdlib.pillow.Image.MIME["ICNS"]
pillow_example_icns_png_bytes := PillowExampleIcnsPngBytes([16, 16])
pillow_example_icns_bytes := PillowExampleIcnsBytes([
    ["icp4", pillow_example_icns_png_bytes],
    ["ic11", pillow_example_icns_png_bytes],
])
pillow_example_icns_file := stdlib.pillow.IcnsImagePlugin.IcnsFile(stdlib.io.BytesIO(pillow_example_icns_bytes))
pillow_example_icns_sizes := pillow_example_icns_file.itersizes()
pillow_example_icns_best_size := pillow_example_icns_file.bestsize()
pillow_example_icns_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_icns_bytes), "r", ["ICNS"])
pillow_example_icns_initial_size := pillow_example_icns_opened.size
pillow_example_icns_info_sizes := pillow_example_icns_opened.info["sizes"]
pillow_example_icns_load := pillow_example_icns_opened.load()
pillow_example_icns_loaded_size := pillow_example_icns_opened.size
pillow_example_icns_pixel := pillow_example_icns_opened.getpixel([1, 0])
pillow_example_icns_saved_source := stdlib.pillow.Image.new("RGBA", [16, 16], [1, 2, 3, 4])
pillow_example_icns_output := stdlib.io.BytesIO()
pillow_example_icns_save := pillow_example_icns_saved_source.save(pillow_example_icns_output, "ICNS")
pillow_example_icns_saved_bytes := pillow_example_icns_output.getvalue()
pillow_example_icns_saved_prefix := PillowExampleArraySlice(pillow_example_icns_saved_bytes, 1, 12)
pillow_example_icns_saved_png_count := PillowExampleCountPngSignatures(pillow_example_icns_saved_bytes)
pillow_example_icns_saved_source.close()
pillow_example_icns_opened.close()
pillow_example_ico_accept := stdlib.pillow.IcoImagePlugin._accept([0, 0, 1, 0, 114, 101, 115, 116])
pillow_example_ico_file_format := stdlib.pillow.IcoImagePlugin.IcoImageFile.format
pillow_example_ico_header_fields := stdlib.pillow.IcoImagePlugin.IconHeader._fields
pillow_example_ico_registered_extension := stdlib.pillow.Image.registered_extensions()[".ico"]
pillow_example_ico_registered_mime := stdlib.pillow.Image.MIME["ICO"]
pillow_example_ico_source := stdlib.pillow.Image.new("RGBA", [32, 32], [10, 20, 30, 40])
pillow_example_ico_source.putpixel([1, 0], [200, 10, 5, 255])
pillow_example_ico_output := stdlib.io.BytesIO()
pillow_example_ico_save := pillow_example_ico_source.save(pillow_example_ico_output, "ICO", { sizes: [[16, 16], [32, 32]] })
pillow_example_ico_bytes := pillow_example_ico_output.getvalue()
pillow_example_ico_entries := PillowExampleIcoDirectoryEntries(pillow_example_ico_bytes)
pillow_example_ico_png_count := PillowExampleCountPngSignatures(pillow_example_ico_bytes)
pillow_example_ico_file := stdlib.pillow.IcoImagePlugin.IcoFile(stdlib.io.BytesIO(pillow_example_ico_bytes))
pillow_example_ico_sizes := pillow_example_ico_file.sizes()
pillow_example_ico_entry_size := pillow_example_ico_file.entry[1].dim
pillow_example_ico_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_ico_bytes), "r", ["ICO"])
pillow_example_ico_opened_size := pillow_example_ico_opened.size
pillow_example_ico_opened_pixel := pillow_example_ico_opened.getpixel([1, 0])
pillow_example_ico_size_switch := pillow_example_ico_opened.size := [16, 16]
pillow_example_ico_load := pillow_example_ico_opened.load()
pillow_example_ico_loaded_size := pillow_example_ico_opened.size
pillow_example_ico_bmp_output := stdlib.io.BytesIO()
pillow_example_ico_bmp_save := pillow_example_ico_source.save(pillow_example_ico_bmp_output, "ICO", { sizes: [[16, 16]], bitmap_format: "bmp" })
pillow_example_ico_bmp_entries := PillowExampleIcoDirectoryEntries(pillow_example_ico_bmp_output.getvalue())
pillow_example_ico_opened.close()
pillow_example_ico_source.close()
pillow_example_im_number := stdlib.pillow.ImImagePlugin.number("3.25")
pillow_example_im_file_format := stdlib.pillow.ImImagePlugin.ImImageFile.format
pillow_example_im_registered_extension := stdlib.pillow.Image.registered_extensions()[".im"]
pillow_example_im_l_bytes := PillowExampleImBytes([
    "Comment: first",
    "Comment: second",
    "Image type: Greyscale image",
    "Image size (x*y): 2*2",
    "File size (no of images): 2",
    "Scale (x,y): 1.5,2",
    "Name: demo",
], [1, 2, 3, 4, 5, 6, 7, 8])
pillow_example_im_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_im_l_bytes), "r", ["IM"])
pillow_example_im_mode := pillow_example_im_opened.mode
pillow_example_im_comments := pillow_example_im_opened.info["Comment"]
pillow_example_im_first_pixel := pillow_example_im_opened.getpixel([1, 0])
pillow_example_im_seek := pillow_example_im_opened.seek(1)
pillow_example_im_second_pixel := pillow_example_im_opened.getpixel([1, 0])
pillow_example_im_palette := []
loop 256
    pillow_example_im_palette.Push(A_Index - 1)
loop 256
    pillow_example_im_palette.Push(256 - A_Index)
loop 256
    pillow_example_im_palette.Push(Mod((A_Index - 1) * 2, 256))
pillow_example_im_p_bytes := PillowExampleImBytes([
    "Image type: Greyscale image",
    "Image size (x*y): 2*2",
    "Lut: 1",
], [0, 1, 2, 3], pillow_example_im_palette)
pillow_example_im_p_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_im_p_bytes), "r", ["IM"])
pillow_example_im_p_palette_prefix := PillowExampleArraySlice(pillow_example_im_p_opened.getpalette(), 1, 12)
pillow_example_im_p_pixels := pillow_example_im_p_opened.getdata()
pillow_example_im_save_source := stdlib.pillow.Image.new("P", [2, 2])
pillow_example_im_save_source.putdata([0, 1, 2, 3])
pillow_example_im_save_source.putpalette([0, 0, 0, 10, 20, 30, 40, 50, 60, 70, 80, 90])
pillow_example_im_output := stdlib.io.BytesIO()
pillow_example_im_save := pillow_example_im_save_source.save(pillow_example_im_output, "IM")
pillow_example_im_saved_bytes := pillow_example_im_output.getvalue()
pillow_example_im_saved_has_lut := PillowExampleBytesContainsAscii(pillow_example_im_saved_bytes, "Lut: 1`r`n")
pillow_example_im_roundtrip := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_im_saved_bytes), "r", ["IM"])
pillow_example_im_roundtrip_palette := PillowExampleArraySlice(pillow_example_im_roundtrip.getpalette(), 1, 12)
pillow_example_im_roundtrip_pixels := pillow_example_im_roundtrip.getdata()
pillow_example_im_roundtrip.close()
pillow_example_im_save_source.close()
pillow_example_im_p_opened.close()
pillow_example_im_opened.close()
pillow_example_imt_bytes := PillowExampleAsciiBytes("* comment ignored`nwidth 3`nheight 2`npixel n8`n")
for byte in [0x0C, 1, 2, 3, 4, 5, 6]
    pillow_example_imt_bytes.Push(byte)
pillow_example_imt_field_pattern := stdlib.pillow.ImtImagePlugin.field.pattern
pillow_example_imt_file_format := stdlib.pillow.ImtImagePlugin.ImtImageFile.format
pillow_example_imt_registered_id := PillowExampleArrayContains(stdlib.pillow.Image.ID, "IMT")
pillow_example_imt_registered_extension := stdlib.pillow.Image.registered_extensions().Has(".imt")
pillow_example_imt_direct := stdlib.pillow.ImtImagePlugin.ImtImageFile(stdlib.io.BytesIO(pillow_example_imt_bytes))
pillow_example_imt_tile := pillow_example_imt_direct.tile[1]
pillow_example_imt_pixels := pillow_example_imt_direct.getdata()
pillow_example_imt_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_imt_bytes), "r", ["IMT"])
pillow_example_imt_opened_format := pillow_example_imt_opened.format
pillow_example_imt_opened_pixels := pillow_example_imt_opened.getdata()
pillow_example_imt_opened.close()
pillow_example_imt_direct.close()
pillow_example_iptc_bytes := PillowExampleIptcBytes([
    [[2, 5], PillowExampleAsciiBytes("headline-one")],
    [[2, 5], PillowExampleAsciiBytes("headline-two")],
    [[3, 20], PillowExampleBe16(3)],
    [[3, 30], PillowExampleBe16(2)],
    [[3, 60], [1, 0]],
    [[3, 120], PillowExampleBe16(1)],
    [[8, 10], [1, 2, 3, 4, 5, 6]],
])
pillow_example_iptc_compression_raw := stdlib.pillow.IptcImagePlugin.COMPRESSION[1]
pillow_example_iptc_i32 := stdlib.pillow.IptcImagePlugin.i32([1, 2, 3, 4])
pillow_example_iptc_file_format := stdlib.pillow.IptcImagePlugin.IptcImageFile.format
pillow_example_iptc_registered_extension := stdlib.pillow.Image.registered_extensions()[".iim"]
pillow_example_iptc_direct := stdlib.pillow.IptcImagePlugin.IptcImageFile(stdlib.io.BytesIO(pillow_example_iptc_bytes))
pillow_example_iptc_tile := pillow_example_iptc_direct.tile[1]
pillow_example_iptc_headline_count := pillow_example_iptc_direct.info["2,5"].Length
pillow_example_iptc_pixels := pillow_example_iptc_direct.getdata()
pillow_example_iptc_info := stdlib.pillow.IptcImagePlugin.getiptcinfo(pillow_example_iptc_direct)
pillow_example_iptc_info_headlines := pillow_example_iptc_info["2,5"].Length
pillow_example_iptc_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_iptc_bytes), "r", ["IPTC"])
pillow_example_iptc_opened_format := pillow_example_iptc_opened.format
pillow_example_iptc_opened_pixels := pillow_example_iptc_opened.getdata()
pillow_example_iptc_opened.close()
pillow_example_iptc_direct.close()
pillow_example_jpeg2k_jp2_bytes := PillowExampleJp2Bytes(3, 2, 3, 7, "jp2 ", true)
pillow_example_jpeg2k_jpx_bytes := PillowExampleJp2Bytes(4, 1, 3, 7, "jpx ")
pillow_example_jpeg2k_j2k_bytes := PillowExampleJ2kBytes(2, 2, 1, 15, "ahk")
pillow_example_jpeg2k_accept_jp2 := stdlib.pillow.Jpeg2KImagePlugin._accept(PillowExampleArraySlice(pillow_example_jpeg2k_jp2_bytes, 1, 16))
pillow_example_jpeg2k_accept_j2k := stdlib.pillow.Jpeg2KImagePlugin._accept(PillowExampleArraySlice(pillow_example_jpeg2k_j2k_bytes, 1, 16))
pillow_example_jpeg2k_file_format := stdlib.pillow.Jpeg2KImagePlugin.Jpeg2KImageFile.format
pillow_example_jpeg2k_file_description := stdlib.pillow.Jpeg2KImagePlugin.Jpeg2KImageFile.format_description
pillow_example_jpeg2k_registered_jp2 := stdlib.pillow.Image.registered_extensions()[".jp2"]
pillow_example_jpeg2k_registered_j2k := stdlib.pillow.Image.registered_extensions()[".j2k"]
pillow_example_jpeg2k_mime := stdlib.pillow.Image.MIME["JPEG2000"]
pillow_example_jpeg2k_direct := stdlib.pillow.Jpeg2KImagePlugin.Jpeg2KImageFile(stdlib.io.BytesIO(pillow_example_jpeg2k_jp2_bytes))
pillow_example_jpeg2k_direct_tile := pillow_example_jpeg2k_direct.tile[1]
pillow_example_jpeg2k_jp2_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_jpeg2k_jp2_bytes), "r", ["JPEG2000"])
pillow_example_jpeg2k_jp2_mode := pillow_example_jpeg2k_jp2_opened.mode
pillow_example_jpeg2k_jp2_size := pillow_example_jpeg2k_jp2_opened.size
pillow_example_jpeg2k_jp2_dpi := pillow_example_jpeg2k_jp2_opened.info["dpi"]
pillow_example_jpeg2k_jp2_tile := pillow_example_jpeg2k_jp2_opened.tile[1]
pillow_example_jpeg2k_jpx_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_jpeg2k_jpx_bytes), "r", ["JPEG2000"])
pillow_example_jpeg2k_jpx_mimetype := pillow_example_jpeg2k_jpx_opened.custom_mimetype
pillow_example_jpeg2k_j2k_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_jpeg2k_j2k_bytes), "r", ["JPEG2000"])
pillow_example_jpeg2k_j2k_mode := pillow_example_jpeg2k_j2k_opened.mode
pillow_example_jpeg2k_j2k_comment := pillow_example_jpeg2k_j2k_opened.info["comment"]
pillow_example_jpeg2k_j2k_tile := pillow_example_jpeg2k_j2k_opened.tile[1]
pillow_example_jpeg2k_j2k_opened.close()
pillow_example_jpeg2k_jpx_opened.close()
pillow_example_jpeg2k_jp2_opened.close()
pillow_example_jpeg2k_direct.close()
pillow_example_mcidas_bytes := PillowExampleMcIdasAreaBytes(3, 2, 1)
pillow_example_mcidas_16_bytes := PillowExampleMcIdasAreaBytes(3, 2, 2)
pillow_example_mcidas_accept := stdlib.pillow.McIdasImagePlugin._accept(PillowExampleArraySlice(pillow_example_mcidas_bytes, 1, 16))
pillow_example_mcidas_file_format := stdlib.pillow.McIdasImagePlugin.McIdasImageFile.format
pillow_example_mcidas_file_description := stdlib.pillow.McIdasImagePlugin.McIdasImageFile.format_description
pillow_example_mcidas_registered_open := stdlib.pillow.Image.OPEN.Has("MCIDAS")
pillow_example_mcidas_registered_id := PillowExampleArrayContains(stdlib.pillow.Image.ID, "MCIDAS")
pillow_example_mcidas_mic_is_mcidas := stdlib.pillow.Image.EXTENSION.Has(".mic") ? stdlib.pillow.Image.EXTENSION[".mic"] = "MCIDAS" : false
pillow_example_mcidas_direct := stdlib.pillow.McIdasImagePlugin.McIdasImageFile(stdlib.io.BytesIO(pillow_example_mcidas_bytes))
pillow_example_mcidas_pixels := pillow_example_mcidas_direct.getdata()
pillow_example_mcidas_tile := pillow_example_mcidas_direct.tile[1]
pillow_example_mcidas_descriptor_prefix := PillowExampleArraySlice(pillow_example_mcidas_direct.area_descriptor, 1, 16)
pillow_example_mcidas_16_direct := stdlib.pillow.McIdasImagePlugin.McIdasImageFile(stdlib.io.BytesIO(pillow_example_mcidas_16_bytes))
pillow_example_mcidas_16_mode := pillow_example_mcidas_16_direct.mode
pillow_example_mcidas_16_tile := pillow_example_mcidas_16_direct.tile[1]
pillow_example_mcidas_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_mcidas_bytes), "r", ["MCIDAS"])
pillow_example_mcidas_opened_size := pillow_example_mcidas_opened.size
pillow_example_mcidas_opened_pixels := pillow_example_mcidas_opened.getdata()
pillow_example_mcidas_opened.close()
pillow_example_mcidas_16_direct.close()
pillow_example_mcidas_direct.close()
pillow_example_mic_magic := [208, 207, 17, 224, 161, 177, 26, 225]
pillow_example_mic_tiff_bytes := PillowExampleTiffBytes("L", [1, 2, 3, 4])
pillow_example_mic_accept := stdlib.pillow.MicImagePlugin._accept(pillow_example_mic_magic)
pillow_example_mic_file_format := stdlib.pillow.MicImagePlugin.MicImageFile.format
pillow_example_mic_file_description := stdlib.pillow.MicImagePlugin.MicImageFile.format_description
pillow_example_mic_registered_open := stdlib.pillow.Image.OPEN.Has("MIC")
pillow_example_mic_registered_extension := stdlib.pillow.Image.registered_extensions()[".mic"]
pillow_example_mic_old_olefile := stdlib.pillow.MicImagePlugin.olefile
try {
    pillow_example_mic_fake_olefile := PillowExampleMicFakeOleModule([[["Layer1.ACI", "Image"], pillow_example_mic_tiff_bytes]])
    stdlib.pillow.MicImagePlugin.olefile := pillow_example_mic_fake_olefile
    pillow_example_mic_direct := stdlib.pillow.MicImagePlugin.MicImageFile(stdlib.io.BytesIO(pillow_example_mic_magic.Clone()))
    pillow_example_mic_mode := pillow_example_mic_direct.mode
    pillow_example_mic_size := pillow_example_mic_direct.size
    pillow_example_mic_pixel := pillow_example_mic_direct.getpixel([1, 0])
    pillow_example_mic_images := pillow_example_mic_direct.images
    pillow_example_mic_tell := pillow_example_mic_direct.tell()
    pillow_example_mic_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_mic_magic.Clone()), "r", ["MIC"])
    pillow_example_mic_opened_pixel := pillow_example_mic_opened.getpixel([1, 0])
    pillow_example_mic_opened.close()
    pillow_example_mic_direct.close()
    pillow_example_mic_closed_count := pillow_example_mic_fake_olefile.ClosedCount
} finally {
    stdlib.pillow.MicImagePlugin.olefile := pillow_example_mic_old_olefile
}
pillow_example_mpeg_bytes := PillowExampleMpegBytes(320, 240, [1, 2, 3])
pillow_example_mpeg_stream := stdlib.pillow.MpegImagePlugin.BitStream(stdlib.io.BytesIO([172, 112, 255]))
pillow_example_mpeg_bit_peek := pillow_example_mpeg_stream.peek(3)
pillow_example_mpeg_bit_read := pillow_example_mpeg_stream.read(3)
pillow_example_mpeg_accept := stdlib.pillow.MpegImagePlugin._accept(PillowExampleArraySlice(pillow_example_mpeg_bytes, 1, 16))
pillow_example_mpeg_file_format := stdlib.pillow.MpegImagePlugin.MpegImageFile.format
pillow_example_mpeg_file_description := stdlib.pillow.MpegImagePlugin.MpegImageFile.format_description
pillow_example_mpeg_registered_mpg := stdlib.pillow.Image.registered_extensions()[".mpg"]
pillow_example_mpeg_mime := stdlib.pillow.Image.MIME["MPEG"]
pillow_example_mpeg_direct := stdlib.pillow.MpegImagePlugin.MpegImageFile(stdlib.io.BytesIO(pillow_example_mpeg_bytes))
pillow_example_mpeg_size := pillow_example_mpeg_direct.size
pillow_example_mpeg_mode := pillow_example_mpeg_direct.mode
pillow_example_mpeg_tile := pillow_example_mpeg_direct.tile
pillow_example_mpeg_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_mpeg_bytes), "r", ["MPEG"])
pillow_example_mpeg_opened_size := pillow_example_mpeg_opened.size
pillow_example_mpeg_opened.close()
pillow_example_mpeg_direct.close()
pillow_example_mpo_fixture := PillowExampleMpoBytes()
pillow_example_mpo_bytes := pillow_example_mpo_fixture["bytes"]
pillow_example_mpo_file_format := stdlib.pillow.MpoImagePlugin.MpoImageFile.format
pillow_example_mpo_file_description := stdlib.pillow.MpoImagePlugin.MpoImageFile.format_description
pillow_example_mpo_registered_extension := stdlib.pillow.Image.registered_extensions()[".mpo"]
pillow_example_mpo_mime := stdlib.pillow.Image.MIME["MPO"]
pillow_example_mpo_save_registered := stdlib.pillow.Image.SAVE.Has("MPO")
pillow_example_mpo_save_all_registered := stdlib.pillow.Image.SAVE_ALL.Has("MPO")
pillow_example_mpo_direct := stdlib.pillow.MpoImagePlugin.MpoImageFile(stdlib.io.BytesIO(pillow_example_mpo_bytes))
pillow_example_mpo_direct_frames := pillow_example_mpo_direct.n_frames
pillow_example_mpo_direct_mpversion := pillow_example_mpo_direct.mpinfo[0xB000]
pillow_example_mpo_direct_second_offset := pillow_example_mpo_direct.mpinfo[0xB002][2]["DataOffset"]
pillow_example_mpo_direct.seek(1)
pillow_example_mpo_direct_tell := pillow_example_mpo_direct.tell()
pillow_example_mpo_direct_load_seek_before := pillow_example_mpo_direct.fp.tell()
pillow_example_mpo_direct_load_seek_result := pillow_example_mpo_direct.load_seek(5)
pillow_example_mpo_direct_load_seek_after := pillow_example_mpo_direct.fp.tell()
pillow_example_mpo_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_mpo_bytes), "r", ["JPEG"])
pillow_example_mpo_opened_format := pillow_example_mpo_opened.format
pillow_example_mpo_opened_info_has_mp := pillow_example_mpo_opened.info.Has("mp")
pillow_example_mpo_getmp := pillow_example_mpo_opened._getmp()
pillow_example_mpo_getmp_is_copy := ObjPtr(pillow_example_mpo_getmp) != ObjPtr(pillow_example_mpo_opened.mpinfo)
pillow_example_mpo_getmp_entries := pillow_example_mpo_getmp[0xB001]
pillow_example_mpo_getmp_second_offset := pillow_example_mpo_getmp[0xB002][2]["DataOffset"]
pillow_example_mpo_attribute_fixture := PillowExampleMpoBytes([0xF8020003, 0x010002, 0x00ABCD])
pillow_example_mpo_attribute_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_mpo_attribute_fixture["bytes"]), "r", ["JPEG"])
pillow_example_mpo_attribute_first := pillow_example_mpo_attribute_opened.mpinfo[0xB002][1]["Attribute"]
pillow_example_mpo_attribute_flags := [
    pillow_example_mpo_attribute_first["DependentParentImageFlag"],
    pillow_example_mpo_attribute_first["DependentChildImageFlag"],
    pillow_example_mpo_attribute_first["RepresentativeImageFlag"],
    pillow_example_mpo_attribute_first["Reserved"]
]
pillow_example_mpo_attribute_types := [
    pillow_example_mpo_attribute_opened.mpinfo[0xB002][1]["Attribute"]["MPType"],
    pillow_example_mpo_attribute_opened.mpinfo[0xB002][2]["Attribute"]["MPType"],
    pillow_example_mpo_attribute_opened.mpinfo[0xB002][3]["Attribute"]["MPType"]
]
pillow_example_mpo_unsupported_holder := Map()
pillow_example_mpo_unsupported_records := stdlib.warnings.catch_warnings(true).Call((records) => pillow_example_mpo_unsupported_holder["image"] := stdlib.pillow.Image.open(stdlib.io.BytesIO(PillowExampleMpoBytes([0x01030000, 0])["bytes"]), "r", ["JPEG"]))
pillow_example_mpo_unsupported_opened := pillow_example_mpo_unsupported_holder["image"]
pillow_example_mpo_unsupported_warning := pillow_example_mpo_unsupported_records[1].message
pillow_example_mpo_unsupported_format := pillow_example_mpo_unsupported_opened.format
pillow_example_mpo_unsupported_opened.close()
pillow_example_mpo_attribute_opened.close()
pillow_example_mpo_ultrahdr_bytes := PillowExampleMpoBytesWithApp1(PillowExampleAsciiBytes('urn:iso:std:iso:ts:21496:-1 hdrgm:Version="1.0" demo'))
pillow_example_mpo_ultrahdr_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_mpo_ultrahdr_bytes), "r", ["JPEG"])
pillow_example_mpo_ultrahdr_format := pillow_example_mpo_ultrahdr_opened.format
pillow_example_mpo_ultrahdr_info_has_mp := pillow_example_mpo_ultrahdr_opened.info.Has("mp")
pillow_example_mpo_ultrahdr_direct := stdlib.pillow.MpoImagePlugin.MpoImageFile(stdlib.io.BytesIO(pillow_example_mpo_ultrahdr_bytes))
pillow_example_mpo_ultrahdr_direct_format := pillow_example_mpo_ultrahdr_direct.format
pillow_example_mpo_ultrahdr_direct_frames := pillow_example_mpo_ultrahdr_direct.n_frames
pillow_example_mpo_ultrahdr_direct.close()
pillow_example_mpo_ultrahdr_opened.close()
pillow_example_mpo_opened.seek(1)
pillow_example_mpo_opened_tell := pillow_example_mpo_opened.tell()
pillow_example_mpo_opened_load_seek_result := pillow_example_mpo_opened.load_seek(9)
pillow_example_mpo_opened_load_seek_after := pillow_example_mpo_opened.fp.tell()
pillow_example_mpo_seek_string_error := ""
try {
    pillow_example_mpo_opened.seek("1")
} catch Error as err {
    pillow_example_mpo_seek_string_error := err.Message
}
pillow_example_mpo_seek_float_error := ""
try {
    pillow_example_mpo_opened.seek(1.2)
} catch Error as err {
    pillow_example_mpo_seek_float_error := err.Message
}
pillow_example_mpo_single_source := stdlib.pillow.Image.new("RGB", [3, 2], [10, 20, 30])
pillow_example_mpo_single_fp := stdlib.io.BytesIO()
pillow_example_mpo_single_source.save(pillow_example_mpo_single_fp, "MPO")
pillow_example_mpo_single_bytes := pillow_example_mpo_single_fp.getvalue()
pillow_example_mpo_single_is_jpeg := PillowExampleArraySlice(pillow_example_mpo_single_bytes, 1, 3) = [0xFF, 0xD8, 0xFF]
pillow_example_mpo_multi_append := stdlib.pillow.Image.new("RGB", [3, 2], [1, 2, 3])
pillow_example_mpo_multi_fp := stdlib.io.BytesIO()
pillow_example_mpo_single_source.save(pillow_example_mpo_multi_fp, "MPO", { save_all: true, append_images: [pillow_example_mpo_multi_append] })
pillow_example_mpo_multi_bytes := pillow_example_mpo_multi_fp.getvalue()
pillow_example_mpo_multi_has_mpf := PillowExampleBytesContainsAscii(pillow_example_mpo_multi_bytes, "MPF")
pillow_example_mpo_saved_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_mpo_multi_bytes), "r", ["JPEG"])
pillow_example_mpo_saved_frames := pillow_example_mpo_saved_opened.n_frames
pillow_example_mpo_resave_fp := stdlib.io.BytesIO()
pillow_example_mpo_saved_opened.save(pillow_example_mpo_resave_fp, "MPO", { save_all: true })
pillow_example_mpo_resave_bytes := pillow_example_mpo_resave_fp.getvalue()
pillow_example_mpo_resave_has_mpf := PillowExampleBytesContainsAscii(pillow_example_mpo_resave_bytes, "MPF")
pillow_example_mpo_resave_source_tell := pillow_example_mpo_saved_opened.tell()
pillow_example_mpo_resaved_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_mpo_resave_bytes), "r", ["JPEG"])
pillow_example_mpo_resaved_frames := pillow_example_mpo_resaved_opened.n_frames
pillow_example_mpo_resaved_opened.seek(1)
pillow_example_mpo_resaved_tell := pillow_example_mpo_resaved_opened.tell()
pillow_example_mpo_resaved_opened.close()
pillow_example_mpo_saved_opened.close()
pillow_example_mpo_multi_append.close()
pillow_example_mpo_single_source.close()
pillow_example_mpo_opened.close()
pillow_example_mpo_direct.close()
pillow_example_msp_bytes := PillowExampleMspDanMBytes()
pillow_example_msp_lins_bytes := PillowExampleMspLinSBytes()
pillow_example_msp_accept_danm := stdlib.pillow.MspImagePlugin._accept(PillowExampleArraySlice(pillow_example_msp_bytes, 1, 8))
pillow_example_msp_accept_lins := stdlib.pillow.MspImagePlugin._accept(PillowExampleArraySlice(pillow_example_msp_lins_bytes, 1, 8))
pillow_example_msp_file_format := stdlib.pillow.MspImagePlugin.MspImageFile.format
pillow_example_msp_file_description := stdlib.pillow.MspImagePlugin.MspImageFile.format_description
pillow_example_msp_decoder := stdlib.pillow.MspImagePlugin.MspDecoder("1")
pillow_example_msp_decoder_pulls_fd := pillow_example_msp_decoder._pulls_fd
pillow_example_msp_registered_open := stdlib.pillow.Image.OPEN.Has("MSP")
pillow_example_msp_registered_save := stdlib.pillow.Image.SAVE.Has("MSP")
pillow_example_msp_registered_decoder := stdlib.pillow.Image.DECODERS.Has("MSP")
pillow_example_msp_registered_extension := stdlib.pillow.Image.registered_extensions()[".msp"]
pillow_example_msp_direct := stdlib.pillow.MspImagePlugin.MspImageFile(stdlib.io.BytesIO(pillow_example_msp_bytes))
pillow_example_msp_direct_size := pillow_example_msp_direct.size
pillow_example_msp_direct_tile := pillow_example_msp_direct.tile
pillow_example_msp_direct_pixels := pillow_example_msp_direct.getdata()
pillow_example_msp_lins := stdlib.pillow.MspImagePlugin.MspImageFile(stdlib.io.BytesIO(pillow_example_msp_lins_bytes))
pillow_example_msp_lins_tile := pillow_example_msp_lins.tile
pillow_example_msp_lins_pixels := pillow_example_msp_lins.getdata()
pillow_example_msp_source := stdlib.pillow.Image.new("1", [9, 2], 1)
for pillow_example_msp_xy in [[0, 0], [3, 0], [8, 0], [1, 1], [7, 1]]
    pillow_example_msp_source.putpixel(pillow_example_msp_xy, 0)
pillow_example_msp_output := stdlib.io.BytesIO()
pillow_example_msp_source.save(pillow_example_msp_output, "MSP")
pillow_example_msp_saved_bytes := pillow_example_msp_output.getvalue()
pillow_example_msp_saved_magic := PillowExampleArraySlice(pillow_example_msp_saved_bytes, 1, 4)
pillow_example_msp_saved_checksum := PillowExampleMspChecksum(PillowExampleArraySlice(pillow_example_msp_saved_bytes, 1, 32))
pillow_example_msp_saved_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_msp_saved_bytes), "r", ["MSP"])
pillow_example_msp_saved_pixels := pillow_example_msp_saved_opened.getdata()
pillow_example_msp_saved_opened.close()
pillow_example_msp_source.close()
pillow_example_msp_lins.close()
pillow_example_msp_direct.close()
pillow_example_psdraw_module := stdlib.pillow.PSDraw
pillow_example_psdraw_constants := [
    pillow_example_psdraw_module.EDROFF_PS.Length,
    pillow_example_psdraw_module.VDI_PS.Length,
    pillow_example_psdraw_module.ERROR_PS.Length,
]
pillow_example_psdraw_output := stdlib.io.BytesIO()
pillow_example_psdraw := pillow_example_psdraw_module.PSDraw(pillow_example_psdraw_output)
pillow_example_psdraw.begin_document("demo")
pillow_example_psdraw.setfont("Helvetica", 12)
pillow_example_psdraw.line([1, 2], [3, 4])
pillow_example_psdraw.rectangle([5, 6, 7, 8])
pillow_example_psdraw.text([9, 10], "a(b)c")
pillow_example_psdraw_image := stdlib.pillow.Image.new("RGB", [2, 1], [1, 2, 3])
pillow_example_psdraw.image([0, 0, 144, 72], pillow_example_psdraw_image)
pillow_example_psdraw.end_document()
pillow_example_psdraw_bytes := pillow_example_psdraw_output.getvalue()
pillow_example_psdraw_prefix := PillowExampleArraySlice(pillow_example_psdraw_bytes, 1, 16)
pillow_example_psdraw_has_text := PillowExampleBytesContainsAscii(pillow_example_psdraw_bytes, "9 10 M (a\(b\)c) S`n")
pillow_example_psdraw_has_eps := PillowExampleBytesContainsAscii(pillow_example_psdraw_bytes, "false 3 colorimage`n010203010203`n")
pillow_example_psdraw_image.close()
pillow_example_tario_path := pillow_example_output_dir "\pillow-tario-example.tar"
pillow_example_tario_bytes := PillowExampleTarBytes([
    ["first.txt", PillowExampleAsciiBytes("first")],
    ["dir/second.bin", PillowExampleAsciiBytes("012`n345`n6789")],
])
PillowExampleWriteBytes(pillow_example_tario_path, pillow_example_tario_bytes)
pillow_example_tario := stdlib.pillow.TarIO.TarIO(pillow_example_tario_path, "dir/second.bin")
pillow_example_tario_offset := pillow_example_tario.offset
pillow_example_tario_read_prefix := pillow_example_tario.read(4)
pillow_example_tario_line := pillow_example_tario.readline()
pillow_example_tario_tail_seek := pillow_example_tario.seek(-2, stdlib.io.SEEK_END)
pillow_example_tario_tail := pillow_example_tario.read()
pillow_example_tario_flags := [pillow_example_tario.readable(), pillow_example_tario.writable(), pillow_example_tario.seekable(), pillow_example_tario.isatty()]
pillow_example_tario.close()
pillow_example_tario_closed := pillow_example_tario.fh.closed
pillow_example_pdfparser_module := stdlib.pillow.PdfParser
pillow_example_pdfparser_encoded := pillow_example_pdfparser_module.encode_text("Hi")
pillow_example_pdfparser_decoded := pillow_example_pdfparser_module.decode_text(pillow_example_pdfparser_encoded)
pillow_example_pdfparser_name_bytes := pillow_example_pdfparser_module.PdfName([65, 32, 66, 47, 35, 120]).__bytes()
pillow_example_pdfparser_array_bytes := pillow_example_pdfparser_module.PdfArray([pillow_example_pdfparser_module.PdfName("Name"), 3, stdlib.True, stdlib.None, [97, 40, 98, 41, 92, 99]]).__bytes()
pillow_example_pdfparser_dict := pillow_example_pdfparser_module.PdfDict(Map(
    [84, 105, 116, 108, 101], pillow_example_pdfparser_encoded,
    [67, 114, 101, 97, 116, 105, 111, 110, 68, 97, 116, 101], PillowExampleAsciiBytes("D:20200102030405+02'30'")
))
pillow_example_pdfparser_dict.setattr("Author", PillowExampleAsciiBytes("Me"))
pillow_example_pdfparser_title := pillow_example_pdfparser_dict.getattr("Title")
pillow_example_pdfparser_date := pillow_example_pdfparser_dict.getattr("CreationDate")
pillow_example_pdfparser_xref := pillow_example_pdfparser_module.XrefTable()
pillow_example_pdfparser_xref.set(1, [10, 0])
pillow_example_pdfparser_xref.delete(1)
pillow_example_pdfparser_xref_output := stdlib.io.BytesIO()
pillow_example_pdfparser_xref_start := pillow_example_pdfparser_xref.write(pillow_example_pdfparser_xref_output)
pillow_example_pdfparser_xref_has_deleted := PillowExampleBytesContainsAscii(pillow_example_pdfparser_xref_output.getvalue(), "0000000000 00001 f")
pillow_example_pdfparser_writer_output := stdlib.io.BytesIO()
pillow_example_pdfparser_writer := pillow_example_pdfparser_module.PdfParser(, pillow_example_pdfparser_writer_output)
pillow_example_pdfparser_writer.start_writing()
pillow_example_pdfparser_writer.write_header()
pillow_example_pdfparser_writer.write_comment("demo")
pillow_example_pdfparser_written_ref := pillow_example_pdfparser_writer.write_obj(stdlib.None, pillow_example_pdfparser_module.PdfDict(Map([65], 1)), { stream: [97, 98, 99] })
pillow_example_pdfparser_writer_bytes := pillow_example_pdfparser_writer_output.getvalue()
pillow_example_pdfparser_writer_ref := pillow_example_pdfparser_written_ref.ToString()
pillow_example_pdfparser_writer_has_length := PillowExampleBytesContainsAscii(pillow_example_pdfparser_writer_bytes, "/Length 3")
pillow_example_pdfparser_writer_has_int := PillowExampleBytesContainsAscii(pillow_example_pdfparser_writer_bytes, "/A 1")
pillow_example_palettefile_bytes := PillowExampleAsciiBytes(
    "# comment`n"
    "0 10 20 30`n"
    "1 7`n"
    "2 1 2 3`n"
    "256 9 9 9`n"
    "-1 8 8 8`n"
    "255 4 5 6`n"
)
pillow_example_palettefile := stdlib.pillow.PaletteFile.PaletteFile(stdlib.io.BytesIO(pillow_example_palettefile_bytes))
pillow_example_palettefile_mode := pillow_example_palettefile.getpalette()[2]
pillow_example_palettefile_prefix := PillowExampleArraySlice(pillow_example_palettefile.palette, 1, 18)
pillow_example_palettefile_tail := PillowExampleArraySlice(pillow_example_palettefile.palette, 766, 768)
pillow_example_palettefile_empty := stdlib.pillow.PaletteFile.PaletteFile(stdlib.io.BytesIO([]))
pillow_example_palettefile_empty_prefix := PillowExampleArraySlice(pillow_example_palettefile_empty.palette, 1, 18)
pillow_example_palettefile_wrapped := stdlib.pillow.PaletteFile.PaletteFile(stdlib.io.BytesIO(PillowExampleAsciiBytes("5 -1 0 0`n")))
pillow_example_palettefile_wrapped_slot := PillowExampleArraySlice(pillow_example_palettefile_wrapped.palette, 16, 18)
pillow_example_palm_colormap_len := stdlib.pillow.PalmImagePlugin._Palm8BitColormapValues.Length
pillow_example_palm_colormap_first := stdlib.pillow.PalmImagePlugin._Palm8BitColormapValues[1]
pillow_example_palm_flags_custom := stdlib.pillow.PalmImagePlugin._FLAGS["custom-colormap"]
pillow_example_palm_compression_none := stdlib.pillow.PalmImagePlugin._COMPRESSION_TYPES["none"]
pillow_example_palm_prototype := stdlib.pillow.PalmImagePlugin.build_prototype_image()
pillow_example_palm_prototype_size := pillow_example_palm_prototype.size
pillow_example_palm_prototype_palette_head := PillowExampleArraySlice(pillow_example_palm_prototype.getpalette(), 1, 18)
pillow_example_palm_registered_save := stdlib.pillow.Image.SAVE.Has("PALM")
pillow_example_palm_registered_extension := stdlib.pillow.Image.registered_extensions()[".palm"]
pillow_example_palm_mime := stdlib.pillow.Image.MIME["PALM"]
pillow_example_palm_one := stdlib.pillow.Image.new("1", [9, 2], 1)
for pillow_example_palm_xy in [[0, 0], [3, 0], [8, 0], [1, 1], [7, 1]]
    pillow_example_palm_one.putpixel(pillow_example_palm_xy, 0)
pillow_example_palm_one_output := stdlib.io.BytesIO()
pillow_example_palm_one.save(pillow_example_palm_one_output, "Palm")
pillow_example_palm_one_bytes := pillow_example_palm_one_output.getvalue()
pillow_example_palm_one_header := PillowExampleArraySlice(pillow_example_palm_one_bytes, 1, 16)
pillow_example_palm_palette := stdlib.pillow.Image.new("P", [2, 2])
pillow_example_palm_palette.putdata([0, 1, 2, 3])
pillow_example_palm_palette.putpalette([255, 0, 0, 0, 255, 0, 0, 0, 255, 1, 2, 3])
pillow_example_palm_palette_output := stdlib.io.BytesIO()
pillow_example_palm_palette.save(pillow_example_palm_palette_output, "Palm")
pillow_example_palm_palette_bytes := pillow_example_palm_palette_output.getvalue()
pillow_example_palm_palette_colormap_count := PillowExampleArraySlice(pillow_example_palm_palette_bytes, 17, 18)
pillow_example_palm_error_message := ""
try {
    stdlib.pillow.Image.new("RGB", [1, 1]).save(stdlib.io.BytesIO(), "Palm")
} catch Error as pillow_example_palm_error {
    pillow_example_palm_error_message := pillow_example_palm_error.Message
}
pillow_example_palm_palette.close()
pillow_example_palm_one.close()
pillow_example_palm_prototype.close()
pillow_example_pcd_bytes := PillowExamplePcdBytes()
pillow_example_pcd_file_format := stdlib.pillow.PcdImagePlugin.PcdImageFile.format
pillow_example_pcd_file_description := stdlib.pillow.PcdImagePlugin.PcdImageFile.format_description
pillow_example_pcd_registered_open := stdlib.pillow.Image.OPEN.Has("PCD")
pillow_example_pcd_registered_accept := stdlib.pillow.Image.OPEN["PCD"][2]
pillow_example_pcd_registered_extension := stdlib.pillow.Image.registered_extensions()[".pcd"]
pillow_example_pcd_direct := stdlib.pillow.PcdImagePlugin.PcdImageFile(stdlib.io.BytesIO(pillow_example_pcd_bytes))
pillow_example_pcd_direct_size := pillow_example_pcd_direct.size
pillow_example_pcd_direct_tile := pillow_example_pcd_direct.tile[1]
pillow_example_pcd_load_error_message := ""
try {
    pillow_example_pcd_direct.load()
} catch Error as pillow_example_pcd_load_error {
    pillow_example_pcd_load_error_message := pillow_example_pcd_load_error.Message
}
pillow_example_pcd_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_pcd_bytes), "r", ["PCD"])
pillow_example_pcd_opened_mode := pillow_example_pcd_opened.mode
pillow_example_pcd_rotated := stdlib.pillow.Image.open(stdlib.io.BytesIO(PillowExamplePcdBytes(1)), "r", ["PCD"])
pillow_example_pcd_rotated_post_rotate := pillow_example_pcd_rotated.tile_post_rotate
pillow_example_pcd_rotated_load_end_message := ""
try {
    pillow_example_pcd_rotated.load_end()
} catch Error as pillow_example_pcd_rotated_load_end_error {
    pillow_example_pcd_rotated_load_end_message := pillow_example_pcd_rotated_load_end_error.Message
}
pillow_example_pcd_rotated.close()
pillow_example_pcd_opened.close()
pillow_example_pcd_direct.close()
pillow_example_pcx_accept := stdlib.pillow.PcxImagePlugin._accept([10, 5])
pillow_example_pcx_file_format := stdlib.pillow.PcxImagePlugin.PcxImageFile.format
pillow_example_pcx_file_description := stdlib.pillow.PcxImagePlugin.PcxImageFile.format_description
pillow_example_pcx_save_rgb := stdlib.pillow.PcxImagePlugin.SAVE["RGB"]
pillow_example_pcx_i16 := stdlib.pillow.PcxImagePlugin.i16([0x34, 0x12], 0)
pillow_example_pcx_registered_extension := stdlib.pillow.Image.registered_extensions()[".pcx"]
pillow_example_pcx_mime := stdlib.pillow.Image.MIME["PCX"]
pillow_example_pcx_rgb_bytes := PillowExamplePcxRgbBytes(2, 2, [10, 20, 30], [1, 0, [200, 10, 5]])
pillow_example_pcx_rgb_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_pcx_rgb_bytes), "r", ["PCX"])
pillow_example_pcx_rgb_tile := pillow_example_pcx_rgb_opened.tile[1]
pillow_example_pcx_rgb_pixel := pillow_example_pcx_rgb_opened.getpixel([1, 0])
pillow_example_pcx_l_source := stdlib.pillow.Image.new("L", [2, 2])
pillow_example_pcx_l_source.putdata([0, 63, 127, 255])
pillow_example_pcx_l_output := stdlib.io.BytesIO()
stdlib.pillow.PcxImagePlugin._save(pillow_example_pcx_l_source, pillow_example_pcx_l_output, "")
pillow_example_pcx_l_saved_bytes := pillow_example_pcx_l_output.getvalue()
pillow_example_pcx_l_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_pcx_l_saved_bytes), "r", ["PCX"])
pillow_example_pcx_l_pixels := pillow_example_pcx_l_opened.getdata()
pillow_example_pcx_p_source := stdlib.pillow.Image.new("P", [2, 2])
pillow_example_pcx_p_source.putdata([0, 1, 2, 3])
pillow_example_pcx_p_source.putpalette([255, 0, 0, 0, 255, 0, 0, 0, 255, 1, 2, 3])
pillow_example_pcx_p_output := stdlib.io.BytesIO()
pillow_example_pcx_p_source.save(pillow_example_pcx_p_output, "PCX")
pillow_example_pcx_p_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_pcx_p_output.getvalue()), "r", ["PCX"])
pillow_example_pcx_p_palette_prefix := PillowExampleArraySlice(pillow_example_pcx_p_opened.getpalette(), 1, 12)
pillow_example_pcx_p_opened.close()
pillow_example_pcx_p_source.close()
pillow_example_pcx_l_opened.close()
pillow_example_pcx_l_source.close()
pillow_example_pcx_rgb_opened.close()
pillow_example_pdf_plugin_has_save := HasProp(stdlib.pillow.PdfImagePlugin, "_save")
pillow_example_pdf_registered_save := stdlib.pillow.Image.SAVE.Has("PDF")
pillow_example_pdf_registered_save_all := stdlib.pillow.Image.SAVE_ALL.Has("PDF")
pillow_example_pdf_registered_extension := stdlib.pillow.Image.registered_extensions()[".pdf"]
pillow_example_pdf_mime := stdlib.pillow.Image.MIME["PDF"]
pillow_example_pdf_rgb := stdlib.pillow.Image.new("RGB", [2, 2])
pillow_example_pdf_rgb.putdata([[10, 20, 30], [200, 10, 5], [40, 50, 60], [1, 2, 3]])
pillow_example_pdf_rgb_output := stdlib.io.BytesIO()
pillow_example_pdf_rgb.save(pillow_example_pdf_rgb_output, "PDF", { title: "Demo", author: "Me" })
pillow_example_pdf_rgb_bytes := pillow_example_pdf_rgb_output.getvalue()
pillow_example_pdf_header := PillowExampleArraySlice(pillow_example_pdf_rgb_bytes, 1, 8)
pillow_example_pdf_has_title := PillowExampleBytesContainsAscii(pillow_example_pdf_rgb_bytes, "/Title (Demo)")
pillow_example_pdf_has_author := PillowExampleBytesContainsAscii(pillow_example_pdf_rgb_bytes, "/Author (Me)")
pillow_example_pdf_has_rgb_dct := PillowExampleBytesContainsAscii(pillow_example_pdf_rgb_bytes, "/Filter /DCTDecode")
pillow_example_pdf_l := stdlib.pillow.Image.new("L", [2, 2])
pillow_example_pdf_l.putdata([0, 63, 127, 255])
pillow_example_pdf_l_output := stdlib.io.BytesIO()
pillow_example_pdf_l.save(pillow_example_pdf_l_output, "PDF", { resolution: 144.0 })
pillow_example_pdf_l_has_gray := PillowExampleBytesContainsAscii(pillow_example_pdf_l_output.getvalue(), "/ColorSpace /DeviceGray")
pillow_example_pdf_p := stdlib.pillow.Image.new("P", [2, 2])
pillow_example_pdf_p.putdata([0, 1, 2, 3])
pillow_example_pdf_p.putpalette([255, 0, 0, 0, 255, 0, 0, 0, 255, 1, 2, 3])
pillow_example_pdf_p_output := stdlib.io.BytesIO()
stdlib.pillow.PdfImagePlugin._save(pillow_example_pdf_p, pillow_example_pdf_p_output, "")
pillow_example_pdf_p_has_indexed := PillowExampleBytesContainsAscii(pillow_example_pdf_p_output.getvalue(), "/ColorSpace [ /Indexed /DeviceRGB 3 <FF000000FF000000FF010203> ]")
pillow_example_pdf_one := stdlib.pillow.Image.new("1", [9, 2], 1)
for pillow_example_pdf_xy in [[0, 0], [3, 0], [8, 0], [1, 1], [7, 1]]
    pillow_example_pdf_one.putpixel(pillow_example_pdf_xy, 0)
pillow_example_pdf_one_output := stdlib.io.BytesIO()
pillow_example_pdf_one.save(pillow_example_pdf_one_output, "PDF")
pillow_example_pdf_one_has_ccitt := PillowExampleBytesContainsAscii(pillow_example_pdf_one_output.getvalue(), "/Filter [ /CCITTFaxDecode ]")
pillow_example_pdf_append := stdlib.pillow.Image.new("RGB", [2, 2])
pillow_example_pdf_append.putdata([[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12]])
pillow_example_pdf_all_output := stdlib.io.BytesIO()
pillow_example_pdf_rgb.save(pillow_example_pdf_all_output, "PDF", { save_all: true, append_images: [pillow_example_pdf_append], dpi: [144, 72] })
pillow_example_pdf_all_has_count := PillowExampleBytesContainsAscii(pillow_example_pdf_all_output.getvalue(), "/Count 2")
pillow_example_pdf_append.close()
pillow_example_pdf_one.close()
pillow_example_pdf_p.close()
pillow_example_pdf_l.close()
pillow_example_pdf_rgb.close()
pillow_example_pixar_bytes := PillowExamplePixarBytes()
pillow_example_pixar_accept := stdlib.pillow.PixarImagePlugin._accept(PillowExampleArraySlice(pillow_example_pixar_bytes, 1, 16))
pillow_example_pixar_short_accept := stdlib.pillow.PixarImagePlugin._accept(PillowExampleArraySlice(pillow_example_pixar_bytes, 1, 3))
pillow_example_pixar_file_format := stdlib.pillow.PixarImagePlugin.PixarImageFile.format
pillow_example_pixar_file_description := stdlib.pillow.PixarImagePlugin.PixarImageFile.format_description
pillow_example_pixar_registered_open := stdlib.pillow.Image.OPEN.Has("PIXAR")
pillow_example_pixar_registered_extension := stdlib.pillow.Image.registered_extensions()[".pxr"]
pillow_example_pixar_has_mime := stdlib.pillow.Image.MIME.Has("PIXAR")
pillow_example_pixar_i16_width := stdlib.pillow.PixarImagePlugin.i16(pillow_example_pixar_bytes, 418)
pillow_example_pixar_direct := stdlib.pillow.PixarImagePlugin.PixarImageFile(stdlib.io.BytesIO(pillow_example_pixar_bytes))
pillow_example_pixar_direct_tile := pillow_example_pixar_direct.tile[1]
pillow_example_pixar_direct_pixels := pillow_example_pixar_direct.getdata()
pillow_example_pixar_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_pixar_bytes), "r", ["PIXAR"])
pillow_example_pixar_opened_pixels := pillow_example_pixar_opened.getdata()
pillow_example_pixar_unknown_mode_message := ""
try {
    stdlib.pillow.PixarImagePlugin.PixarImageFile(stdlib.io.BytesIO(PillowExamplePixarBytes(2, 2, 1, 1)))
} catch Error as pillow_example_pixar_unknown_mode {
    pillow_example_pixar_unknown_mode_message := pillow_example_pixar_unknown_mode.Message
}
pillow_example_pixar_opened.close()
pillow_example_pixar_direct.close()
pillow_example_png_plugin_magic := stdlib.pillow.PngImagePlugin._MAGIC
pillow_example_png_plugin_accept := stdlib.pillow.PngImagePlugin._accept(pillow_example_png_plugin_magic)
pillow_example_png_plugin_crc := stdlib.pillow.PngImagePlugin._crc32(PillowExampleAsciiBytes("tEXt"))
pillow_example_png_plugin_chunk_fp := stdlib.io.BytesIO()
stdlib.pillow.PngImagePlugin.putchunk(pillow_example_png_plugin_chunk_fp, PillowExampleAsciiBytes("tEXt"), PillowExampleAsciiBytes("k"), [0], PillowExampleAsciiBytes("v"))
pillow_example_png_plugin_chunk_bytes := pillow_example_png_plugin_chunk_fp.getvalue()
pillow_example_png_info := stdlib.pillow.PngImagePlugin.PngInfo()
pillow_example_png_info.add_text("Title", "Demo")
pillow_example_png_info.add_itxt("Comment", "Bonjour", "fr", "Titre")
pillow_example_png_info.add(PillowExampleAsciiBytes("vpAg"), PillowExampleAsciiBytes("private-before"))
pillow_example_png_info.add(PillowExampleAsciiBytes("vpAg"), PillowExampleAsciiBytes("private-after"), true)
pillow_example_png_source := stdlib.pillow.Image.new("RGB", [2, 2])
pillow_example_png_source.putdata([[10, 20, 30], [200, 10, 5], [40, 50, 60], [1, 2, 3]])
pillow_example_png_output := stdlib.io.BytesIO()
pillow_example_png_source.save(pillow_example_png_output, "PNG", { pnginfo: pillow_example_png_info, dpi: [72, 96] })
pillow_example_png_bytes := pillow_example_png_output.getvalue()
pillow_example_png_has_private_before := PillowExampleBytesContainsAscii(pillow_example_png_bytes, "private-before")
pillow_example_png_has_private_after := PillowExampleBytesContainsAscii(pillow_example_png_bytes, "private-after")
pillow_example_png_direct := stdlib.pillow.PngImagePlugin.PngImageFile(stdlib.io.BytesIO(pillow_example_png_bytes))
pillow_example_png_direct_title := pillow_example_png_direct.info["Title"]
pillow_example_png_direct_comment := pillow_example_png_direct.text["Comment"].text
pillow_example_png_direct_pixel := pillow_example_png_direct.getpixel([1, 0])
pillow_example_png_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_png_bytes), "r", ["PNG"])
pillow_example_png_opened_dpi := pillow_example_png_opened.info["dpi"]
pillow_example_png_chunks := stdlib.pillow.PngImagePlugin.getchunks(pillow_example_png_source, { pnginfo: pillow_example_png_info, dpi: [72, 96] })
pillow_example_png_chunks_first := pillow_example_png_chunks[1][1]
pillow_example_png_chunks_text_crc := pillow_example_png_chunks[2][3]
pillow_example_png_registered_apng := stdlib.pillow.Image.registered_extensions()[".apng"]
pillow_example_png_mime := stdlib.pillow.Image.MIME["PNG"]
pillow_example_png_opened.close()
pillow_example_png_direct.close()
pillow_example_png_source.close()
pillow_example_ppm_accept := stdlib.pillow.PpmImagePlugin._accept(PillowExampleAsciiBytes("P6 demo"))
pillow_example_ppm_mode_pf := stdlib.pillow.PpmImagePlugin.MODES["Pf"]
pillow_example_ppm_registered_pfm := stdlib.pillow.Image.registered_extensions()[".pfm"]
pillow_example_ppm_plain_bytes := PillowExampleAsciiBytes("P3`n2 1`n5`n0 5 1 2 3 4`n")
pillow_example_ppm_plain := stdlib.pillow.PpmImagePlugin.PpmImageFile(stdlib.io.BytesIO(pillow_example_ppm_plain_bytes))
pillow_example_ppm_plain_pixels := pillow_example_ppm_plain.getdata()
pillow_example_ppm_source := stdlib.pillow.Image.new("RGB", [2, 1])
pillow_example_ppm_source.putdata([[10, 20, 30], [200, 10, 5]])
pillow_example_ppm_output := stdlib.io.BytesIO()
pillow_example_ppm_source.save(pillow_example_ppm_output, "PPM")
pillow_example_ppm_bytes := pillow_example_ppm_output.getvalue()
pillow_example_ppm_saved_prefix := PillowExampleArraySlice(pillow_example_ppm_bytes, 1, 11)
pillow_example_ppm_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_ppm_bytes), "r", ["PPM"])
pillow_example_ppm_opened_pixel := pillow_example_ppm_opened.getpixel([1, 0])
pillow_example_pfm_bytes := PillowExampleConcatBytes(PillowExampleAsciiBytes("Pf`n2 2`n-1.0`n"), [0, 0, 128, 63, 0, 0, 0, 64, 0, 0, 96, 64, 0, 0, 144, 64])
pillow_example_pfm_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_pfm_bytes), "r", ["PPM"])
pillow_example_pfm_scale := pillow_example_pfm_opened.info["scale"]
pillow_example_pfm_pixels := pillow_example_pfm_opened.getdata()
pillow_example_f_source := stdlib.pillow.Image.new("F", [2, 2])
pillow_example_f_source.putdata([1.0, 2.0, 3.5, 4.5])
pillow_example_f_output := stdlib.io.BytesIO()
pillow_example_f_source.save(pillow_example_f_output, "PPM")
pillow_example_f_saved_prefix := PillowExampleArraySlice(pillow_example_f_output.getvalue(), 1, 12)
pillow_example_f_source.close()
pillow_example_pfm_opened.close()
pillow_example_ppm_opened.close()
pillow_example_ppm_source.close()
pillow_example_ppm_plain.close()
pillow_example_psd_accept := stdlib.pillow.PsdImagePlugin._accept(PillowExampleAsciiBytes("8BPSdemo"))
pillow_example_psd_mode_rgb := stdlib.pillow.PsdImagePlugin.MODES["3,8"]
pillow_example_psd_file_format := stdlib.pillow.PsdImagePlugin.PsdImageFile.format
pillow_example_psd_file_description := stdlib.pillow.PsdImagePlugin.PsdImageFile.format_description
pillow_example_psd_registered_extension := stdlib.pillow.Image.registered_extensions()[".psd"]
pillow_example_psd_mime := stdlib.pillow.Image.MIME["PSD"]
pillow_example_psd_bytes := PillowExamplePsdBytes(
    3,
    8,
    3,
    2,
    1,
    [100, 110, 120, 130, 140, 150],
    unset,
    PillowExamplePsdResourceBlock(1039, "", PillowExampleAsciiBytes("ICC!")),
    PillowExamplePsdLayerInfoBytes()
)
pillow_example_psd_direct := stdlib.pillow.PsdImagePlugin.PsdImageFile(stdlib.io.BytesIO(pillow_example_psd_bytes))
pillow_example_psd_direct_mode := pillow_example_psd_direct.mode
pillow_example_psd_direct_pixels := pillow_example_psd_direct.getdata()
pillow_example_psd_icc := pillow_example_psd_direct.info["icc_profile"]
pillow_example_psd_resources := pillow_example_psd_direct.resources
pillow_example_psd_frames := pillow_example_psd_direct.n_frames
pillow_example_psd_layer_name := pillow_example_psd_direct.layers[1][1]
pillow_example_psd_layer_tile := pillow_example_psd_direct.layers[1][4][1]
pillow_example_psd_direct.seek(2)
pillow_example_psd_seek_tell := pillow_example_psd_direct.tell()
pillow_example_psd_seek_mode := pillow_example_psd_direct.mode
pillow_example_psd_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_psd_bytes), "r", ["PSD"])
pillow_example_psd_opened_pixels := pillow_example_psd_opened.getdata()
pillow_example_psd_opened.close()
pillow_example_psd_direct.close()
pillow_example_qoi_accept := stdlib.pillow.QoiImagePlugin._accept(PillowExampleAsciiBytes("qoifdemo"))
pillow_example_qoi_file_format := stdlib.pillow.QoiImagePlugin.QoiImageFile.format
pillow_example_qoi_file_description := stdlib.pillow.QoiImagePlugin.QoiImageFile.format_description
pillow_example_qoi_decoder_pulls_fd := stdlib.pillow.QoiImagePlugin.QoiDecoder("RGB")._pulls_fd
pillow_example_qoi_encoder_pushes_fd := stdlib.pillow.QoiImagePlugin.QoiEncoder("RGB")._pushes_fd
pillow_example_qoi_registered_extension := stdlib.pillow.Image.registered_extensions()[".qoi"]
pillow_example_qoi_registered_save := stdlib.pillow.Image.SAVE.Has("QOI")
pillow_example_qoi_bytes := PillowExampleQoiBytes(5, 1, 3, [0xFE, 10, 20, 30, 0x7A, 0xA5, 0xC3, 0xC0, 0x09])
pillow_example_qoi_direct := stdlib.pillow.QoiImagePlugin.QoiImageFile(stdlib.io.BytesIO(pillow_example_qoi_bytes))
pillow_example_qoi_direct_pixels := pillow_example_qoi_direct.getdata()
pillow_example_qoi_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_qoi_bytes), "r", ["QOI"])
pillow_example_qoi_opened_tile := pillow_example_qoi_opened.tile[1]
pillow_example_qoi_source := stdlib.pillow.Image.new("RGB", [5, 1])
pillow_example_qoi_source.putdata(pillow_example_qoi_direct_pixels)
pillow_example_qoi_output := stdlib.io.BytesIO()
pillow_example_qoi_source.save(pillow_example_qoi_output, "QOI", { colorspace: "sRGB" })
pillow_example_qoi_saved_header := PillowExampleArraySlice(pillow_example_qoi_output.getvalue(), 1, 14)
pillow_example_qoi_source.close()
pillow_example_qoi_opened.close()
pillow_example_qoi_direct.close()
pillow_example_sgi_accept := stdlib.pillow.SgiImagePlugin._accept([0x01, 0xDA])
pillow_example_sgi_mode_rgb := stdlib.pillow.SgiImagePlugin.MODES["1,3,3"]
pillow_example_sgi_file_format := stdlib.pillow.SgiImagePlugin.SgiImageFile.format
pillow_example_sgi_file_description := stdlib.pillow.SgiImagePlugin.SgiImageFile.format_description
pillow_example_sgi_decoder_pulls_fd := stdlib.pillow.SgiImagePlugin.SGI16Decoder("L")._pulls_fd
pillow_example_sgi_registered_extension := stdlib.pillow.Image.registered_extensions()[".sgi"]
pillow_example_sgi_mime := stdlib.pillow.Image.MIME["SGI"]
pillow_example_sgi_bytes := PillowExampleSgiRawBytes(2, 2, 3, [[40, 1, 10, 200], [50, 2, 20, 10], [60, 3, 30, 5]])
pillow_example_sgi_direct := stdlib.pillow.SgiImagePlugin.SgiImageFile(stdlib.io.BytesIO(pillow_example_sgi_bytes))
pillow_example_sgi_direct_pixels := pillow_example_sgi_direct.getdata()
pillow_example_sgi_direct_tile := pillow_example_sgi_direct.tile[1]
pillow_example_sgi_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_sgi_bytes), "r", ["SGI"])
pillow_example_sgi_opened_pixels := pillow_example_sgi_opened.getdata()
pillow_example_sgi_rle_bytes := PillowExampleSgiRleBytes(2, 2, 1, [[255, 1], [0, 127]], 1, 2)
pillow_example_sgi_rle := stdlib.pillow.SgiImagePlugin.SgiImageFile(stdlib.io.BytesIO(pillow_example_sgi_rle_bytes))
pillow_example_sgi_rle_pixels := pillow_example_sgi_rle.getdata()
pillow_example_sgi_source := stdlib.pillow.Image.new("RGBA", [1, 2])
pillow_example_sgi_source.putdata([[1, 2, 3, 4], [9, 8, 7, 6]])
pillow_example_sgi_output := stdlib.io.BytesIO()
pillow_example_sgi_source.save(pillow_example_sgi_output, "SGI")
pillow_example_sgi_saved_payload := PillowExampleArraySlice(pillow_example_sgi_output.getvalue(), 513, 520)
pillow_example_sgi_source.close()
pillow_example_sgi_rle.close()
pillow_example_sgi_opened.close()
pillow_example_sgi_direct.close()
pillow_example_spider_file_format := stdlib.pillow.SpiderImagePlugin.SpiderImageFile.format
pillow_example_spider_file_description := stdlib.pillow.SpiderImagePlugin.SpiderImageFile.format_description
pillow_example_spider_iforms := stdlib.pillow.SpiderImagePlugin.iforms
pillow_example_spider_is_int := stdlib.pillow.SpiderImagePlugin.isInt(1.0)
pillow_example_spider_header_len := stdlib.pillow.SpiderImagePlugin.isSpiderHeader(PillowExampleSpiderHeaderValues())
pillow_example_spider_registered_save := stdlib.pillow.Image.SAVE.Has("SPIDER")
pillow_example_spider_bytes := PillowExampleSpiderImageBytes()
pillow_example_spider_direct := stdlib.pillow.SpiderImagePlugin.SpiderImageFile(stdlib.io.BytesIO(pillow_example_spider_bytes))
pillow_example_spider_direct_pixels := pillow_example_spider_direct.getdata()
pillow_example_spider_direct_extrema := pillow_example_spider_direct.getextrema()
pillow_example_spider_byte := pillow_example_spider_direct.convert2byte(200)
pillow_example_spider_byte_pixels := pillow_example_spider_byte.getdata()
pillow_example_spider_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_spider_bytes), "r", ["SPIDER"])
pillow_example_spider_opened_rawmode := pillow_example_spider_opened.rawmode
pillow_example_spider_stack := stdlib.pillow.SpiderImagePlugin.SpiderImageFile(stdlib.io.BytesIO(PillowExampleSpiderStackBytes()))
pillow_example_spider_stack_first := pillow_example_spider_stack.getdata()
pillow_example_spider_stack.seek(1)
pillow_example_spider_stack_second := pillow_example_spider_stack.getdata()
pillow_example_spider_stack_tell := pillow_example_spider_stack.tell()
pillow_example_spider_source := stdlib.pillow.Image.new("F", [2, 2])
pillow_example_spider_source.putdata([0.0, 1.0, 2.5, 5.0])
pillow_example_spider_output := stdlib.io.BytesIO()
pillow_example_spider_source.save(pillow_example_spider_output, "SPIDER")
pillow_example_spider_saved_size := pillow_example_spider_output.getvalue().Length
pillow_example_spider_path := pillow_example_output_dir "\spider-example.spi"
pillow_example_spider_source.save(pillow_example_spider_path, "SPIDER")
pillow_example_spider_registered_spi := stdlib.pillow.Image.registered_extensions()[".spi"]
pillow_example_spider_path_header := stdlib.pillow.SpiderImagePlugin.isSpiderImage(pillow_example_spider_path)
pillow_example_spider_source.close()
pillow_example_spider_stack.close()
pillow_example_spider_opened.close()
pillow_example_spider_byte.close()
pillow_example_spider_direct.close()
pillow_example_sun_file_format := stdlib.pillow.SunImagePlugin.SunImageFile.format
pillow_example_sun_file_description := stdlib.pillow.SunImagePlugin.SunImageFile.format_description
pillow_example_sun_accept := stdlib.pillow.SunImagePlugin._accept([0x59, 0xA6, 0x6A, 0x95])
pillow_example_sun_registered_extension := stdlib.pillow.Image.registered_extensions()[".ras"]
pillow_example_sun_has_save := stdlib.pillow.Image.SAVE.Has("SUN")
pillow_example_sun_bytes := PillowExampleSunBytes(2, 1, 24, [30, 20, 10, 5, 10, 200, 0, 0])
pillow_example_sun_direct := stdlib.pillow.SunImagePlugin.SunImageFile(stdlib.io.BytesIO(pillow_example_sun_bytes))
pillow_example_sun_pixels := pillow_example_sun_direct.getdata()
pillow_example_sun_tile := pillow_example_sun_direct.tile[1]
pillow_example_sun_palette_bytes := PillowExampleSunBytes(2, 1, 8, [0, 1], 1, 1, [10, 200, 20, 210, 30, 220])
pillow_example_sun_palette := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_sun_palette_bytes), "r", ["SUN"])
pillow_example_sun_palette_prefix := PillowExampleArraySlice(pillow_example_sun_palette.getpalette(), 1, 6)
pillow_example_sun_rle := stdlib.pillow.SunImagePlugin.SunImageFile(stdlib.io.BytesIO(PillowExampleSunBytes(3, 1, 8, [7, 0x80, 1, 8], 2)))
pillow_example_sun_rle_pixels := pillow_example_sun_rle.getdata()
pillow_example_sun_rle.close()
pillow_example_sun_palette.close()
pillow_example_sun_direct.close()
pillow_example_tga_file_format := stdlib.pillow.TgaImagePlugin.TgaImageFile.format
pillow_example_tga_file_description := stdlib.pillow.TgaImagePlugin.TgaImageFile.format_description
pillow_example_tga_mode_rgb := stdlib.pillow.TgaImagePlugin.MODES["2,24"]
pillow_example_tga_save_rgb := stdlib.pillow.TgaImagePlugin.SAVE["RGB"]
pillow_example_tga_registered_extension := stdlib.pillow.Image.registered_extensions()[".tga"]
pillow_example_tga_mime := stdlib.pillow.Image.MIME["TGA"]
pillow_example_tga_bytes := PillowExampleTgaBytes(2, 1, 24, [30, 20, 10, 5, 10, 200], 2)
pillow_example_tga_direct := stdlib.pillow.TgaImagePlugin.TgaImageFile(stdlib.io.BytesIO(pillow_example_tga_bytes))
pillow_example_tga_pixels := pillow_example_tga_direct.getdata()
pillow_example_tga_tile := pillow_example_tga_direct.tile[1]
pillow_example_tga_rle := stdlib.pillow.Image.open(stdlib.io.BytesIO(PillowExampleTgaBytes(3, 1, 8, [0x82, 7], 11)), "r", ["TGA"])
pillow_example_tga_rle_pixels := pillow_example_tga_rle.getdata()
pillow_example_tga_source := stdlib.pillow.Image.new("RGB", [2, 1])
pillow_example_tga_source.putdata([[10, 20, 30], [200, 10, 5]])
pillow_example_tga_output := stdlib.io.BytesIO()
pillow_example_tga_source.save(pillow_example_tga_output, "TGA", { orientation: 1, id_section: PillowExampleAsciiBytes("xy") })
pillow_example_tga_saved_header := PillowExampleArraySlice(pillow_example_tga_output.getvalue(), 1, 18)
pillow_example_tga_saved_payload := PillowExampleArraySlice(pillow_example_tga_output.getvalue(), 19, 26)
pillow_example_tga_source.close()
pillow_example_tga_rle.close()
pillow_example_tga_direct.close()
pillow_example_tiff_file_format := stdlib.pillow.TiffImagePlugin.TiffImageFile.format
pillow_example_tiff_file_description := stdlib.pillow.TiffImagePlugin.TiffImageFile.format_description
pillow_example_tiff_ii := stdlib.pillow.TiffImagePlugin.II
pillow_example_tiff_accept := stdlib.pillow.TiffImagePlugin._accept([73, 73, 42, 0])
pillow_example_tiff_compression_raw := stdlib.pillow.TiffImagePlugin.COMPRESSION_INFO[1]
pillow_example_tiff_open_info_l := stdlib.pillow.TiffImagePlugin.OPEN_INFO["II,1,1,1,8,"]
pillow_example_tiff_save_info_rgb := stdlib.pillow.TiffImagePlugin.SAVE_INFO["RGB"]
pillow_example_tiff_registered_extension := stdlib.pillow.Image.registered_extensions()[".tiff"]
pillow_example_tiff_mime := stdlib.pillow.Image.MIME["TIFF"]
pillow_example_tiff_bytes := PillowExampleTiffBytes("L", [7, 8, 0, 0])
pillow_example_tiff_direct := stdlib.pillow.TiffImagePlugin.TiffImageFile(stdlib.io.BytesIO(pillow_example_tiff_bytes))
pillow_example_tiff_pixels := pillow_example_tiff_direct.getdata()
pillow_example_tiff_compression := pillow_example_tiff_direct.info["compression"]
pillow_example_tiff_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_tiff_bytes), "r", ["TIFF"])
pillow_example_tiff_opened_pixels := pillow_example_tiff_opened.getdata()
pillow_example_tiff_output := stdlib.io.BytesIO()
pillow_example_tiff_direct.save(pillow_example_tiff_output, "TIFF")
pillow_example_tiff_saved_prefix := PillowExampleArraySlice(pillow_example_tiff_output.getvalue(), 1, 8)
pillow_example_tiff_reopened := stdlib.pillow.TiffImagePlugin.TiffImageFile(stdlib.io.BytesIO(pillow_example_tiff_output.getvalue()))
pillow_example_tiff_reopened_pixels := pillow_example_tiff_reopened.getdata()
pillow_example_tiff_reopened.close()
pillow_example_tiff_opened.close()
pillow_example_tiff_direct.close()
pillow_example_wal_file_format := stdlib.pillow.WalImageFile.WalImageFile.format
pillow_example_wal_file_description := stdlib.pillow.WalImageFile.WalImageFile.format_description
pillow_example_wal_i32 := stdlib.pillow.WalImageFile.i32([0x78, 0x56, 0x34, 0x12])
pillow_example_wal_palette_prefix := PillowExampleArraySlice(stdlib.pillow.WalImageFile.quake2palette, 1, 12)
pillow_example_wal_is_registered := stdlib.pillow.Image.OPEN.Has("WAL")
pillow_example_wal_bytes := PillowExampleWalBytes(3, 2, [0, 1, 2, 3, 4, 5], "demo/wall", "demo/next")
pillow_example_wal_direct := stdlib.pillow.WalImageFile.WalImageFile(stdlib.io.BytesIO(pillow_example_wal_bytes))
pillow_example_wal_pixels := pillow_example_wal_direct.getdata()
pillow_example_wal_name := pillow_example_wal_direct.info["name"]
pillow_example_wal_next_name := pillow_example_wal_direct.info["next_name"]
pillow_example_wal_direct_palette_prefix := PillowExampleArraySlice(pillow_example_wal_direct.getpalette(), 1, 12)
pillow_example_wal_opened := stdlib.pillow.WalImageFile.open(stdlib.io.BytesIO(PillowExampleWalBytes(2, 1, [7, 8], "solo", "")))
pillow_example_wal_opened_pixels := pillow_example_wal_opened.getdata()
pillow_example_wal_opened_has_next := pillow_example_wal_opened.info.Has("next_name")
pillow_example_wal_opened.close()
pillow_example_wal_direct.close()
pillow_example_webp_file_format := stdlib.pillow.WebPImagePlugin.WebPImageFile.format
pillow_example_webp_file_description := stdlib.pillow.WebPImagePlugin.WebPImageFile.format_description
pillow_example_webp_supported := stdlib.pillow.WebPImagePlugin.SUPPORTED
pillow_example_webp_vp8x_mode := stdlib.pillow.WebPImagePlugin._VP8_MODES_BY_IDENTIFIER["VP8X"]
pillow_example_webp_accept := stdlib.pillow.WebPImagePlugin._accept([82, 73, 70, 70, 0, 0, 0, 0, 87, 69, 66, 80, 86, 80, 56, 76])
pillow_example_webp_registered_extension := stdlib.pillow.Image.registered_extensions()[".webp"]
pillow_example_webp_mime := stdlib.pillow.Image.MIME["WEBP"]
pillow_example_webp_bytes := [82, 73, 70, 70, 44, 0, 0, 0, 87, 69, 66, 80, 86, 80, 56, 76, 31, 0, 0, 0, 47, 1, 0, 0, 16, 15, 112, 1, 137, 77, 32, 200, 182, 13, 109, 59, 198, 201, 6, 40, 10, 255, 63, 108, 9, 182, 127, 100, 68, 255, 3, 0]
pillow_example_webp_direct := stdlib.pillow.WebPImagePlugin.WebPImageFile(stdlib.io.BytesIO(pillow_example_webp_bytes))
pillow_example_webp_direct_pixels := pillow_example_webp_direct.getdata()
pillow_example_webp_frame_count := pillow_example_webp_direct.n_frames
pillow_example_webp_is_animated := pillow_example_webp_direct.is_animated
pillow_example_webp_loop := pillow_example_webp_direct.info["loop"]
pillow_example_webp_background := pillow_example_webp_direct.info["background"]
pillow_example_webp_direct.seek(0)
pillow_example_webp_tell := pillow_example_webp_direct.tell()
pillow_example_webp_direct.load_seek(0)
pillow_example_webp_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_webp_bytes), "r", ["WEBP"])
pillow_example_webp_opened_pixels := pillow_example_webp_opened.getdata()
pillow_example_webp_l_source := stdlib.pillow.Image.new("L", [1, 1])
pillow_example_webp_converted := stdlib.pillow.WebPImagePlugin._convert_frame(pillow_example_webp_l_source)
pillow_example_webp_converted_mode := pillow_example_webp_converted.mode
pillow_example_webp_converted.close()
pillow_example_webp_l_source.close()
pillow_example_webp_opened.close()
pillow_example_webp_direct.close()
pillow_example_webp_animated_bytes := [82, 73, 70, 70, 142, 0, 0, 0, 87, 69, 66, 80, 86, 80, 56, 88, 10, 0, 0, 0, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 65, 78, 73, 77, 6, 0, 0, 0, 7, 8, 9, 6, 3, 0, 65, 78, 77, 70, 44, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11, 0, 0, 2, 86, 80, 56, 76, 20, 0, 0, 0, 47, 0, 0, 0, 0, 7, 80, 129, 84, 8, 32, 0, 10, 154, 254, 199, 136, 136, 254, 7, 65, 78, 77, 70, 46, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 22, 0, 0, 2, 86, 80, 56, 76, 21, 0, 0, 0, 47, 0, 0, 0, 16, 7, 208, 2, 2, 73, 91, 188, 237, 175, 65, 1, 227, 136, 136, 254, 7, 0]
pillow_example_webp_animated := stdlib.pillow.WebPImagePlugin.WebPImageFile(stdlib.io.BytesIO(pillow_example_webp_animated_bytes))
pillow_example_webp_animated_frame_count := pillow_example_webp_animated.n_frames
pillow_example_webp_animated_is_animated := pillow_example_webp_animated.is_animated
pillow_example_webp_animated_loop := pillow_example_webp_animated.info["loop"]
pillow_example_webp_animated_background := pillow_example_webp_animated.info["background"]
pillow_example_webp_animated_first_pixel := pillow_example_webp_animated.getpixel([0, 0])
pillow_example_webp_animated_first_duration := pillow_example_webp_animated.info["duration"]
pillow_example_webp_animated.seek(1)
pillow_example_webp_animated_second_tell := pillow_example_webp_animated.tell()
pillow_example_webp_animated_second_pixel := pillow_example_webp_animated.getpixel([0, 0])
pillow_example_webp_animated_second_timestamp := pillow_example_webp_animated.info["timestamp"]
pillow_example_webp_animated.close()
pillow_example_wmf_file_format := stdlib.pillow.WmfImagePlugin.WmfStubImageFile.format
pillow_example_wmf_file_description := stdlib.pillow.WmfImagePlugin.WmfStubImageFile.format_description
pillow_example_wmf_accept := stdlib.pillow.WmfImagePlugin._accept([0xD7, 0xCD, 0xC6, 0x9A, 0, 0, 1])
pillow_example_wmf_word := stdlib.pillow.WmfImagePlugin.word([0x34, 0x12], 0)
pillow_example_wmf_registered_extension := stdlib.pillow.Image.registered_extensions()[".wmf"]
pillow_example_wmf_is_saved := stdlib.pillow.Image.SAVE.Has("WMF")
pillow_example_wmf_bytes := PillowExampleWmfBytes()
pillow_example_wmf_direct := stdlib.pillow.WmfImagePlugin.WmfStubImageFile(stdlib.io.BytesIO(pillow_example_wmf_bytes))
pillow_example_wmf_size := pillow_example_wmf_direct.size
pillow_example_wmf_bbox := pillow_example_wmf_direct.info["wmf_bbox"]
pillow_example_wmf_emf := stdlib.pillow.WmfImagePlugin.WmfStubImageFile(stdlib.io.BytesIO(PillowExampleEmfBytes()))
pillow_example_wmf_emf_dpi := pillow_example_wmf_emf.info["dpi"]
pillow_example_wmf_handler := PillowExampleWmfHandler()
pillow_example_wmf_previous_handler := stdlib.pillow.WmfImagePlugin._handler
try {
    stdlib.pillow.WmfImagePlugin.register_handler(pillow_example_wmf_handler)
    pillow_example_wmf_handled := stdlib.pillow.WmfImagePlugin.WmfStubImageFile(stdlib.io.BytesIO(pillow_example_wmf_bytes))
    pillow_example_wmf_handled.load(144)
    pillow_example_wmf_loaded_size := pillow_example_wmf_handled.size
    pillow_example_wmf_loaded_pixel := pillow_example_wmf_handled.getpixel([0, 0])
    pillow_example_wmf_source := stdlib.pillow.Image.new("RGB", [2, 1])
    pillow_example_wmf_output := stdlib.io.BytesIO()
    pillow_example_wmf_source.save(pillow_example_wmf_output, "WMF")
    pillow_example_wmf_saved_bytes := pillow_example_wmf_output.getvalue()
    pillow_example_wmf_source.close()
    pillow_example_wmf_handled.close()
} finally {
    stdlib.pillow.WmfImagePlugin.register_handler(pillow_example_wmf_previous_handler)
}
pillow_example_wmf_emf.close()
pillow_example_wmf_direct.close()
pillow_example_xbm_file_format := stdlib.pillow.XbmImagePlugin.XbmImageFile.format
pillow_example_xbm_file_description := stdlib.pillow.XbmImagePlugin.XbmImageFile.format_description
pillow_example_xbm_accept := stdlib.pillow.XbmImagePlugin._accept(PillowExampleAsciiBytes(" `t`r`n#define im_width 1`n"))
pillow_example_xbm_registered_extension := stdlib.pillow.Image.registered_extensions()[".xbm"]
pillow_example_xbm_mime := stdlib.pillow.Image.MIME["XBM"]
pillow_example_xbm_has_save := stdlib.pillow.Image.SAVE.Has("XBM")
pillow_example_xbm_bytes := PillowExampleXbmBytes(false)
pillow_example_xbm_direct := stdlib.pillow.XbmImagePlugin.XbmImageFile(stdlib.io.BytesIO(pillow_example_xbm_bytes))
pillow_example_xbm_direct_mode := pillow_example_xbm_direct.mode
pillow_example_xbm_direct_size := pillow_example_xbm_direct.size
pillow_example_xbm_direct_pixels := pillow_example_xbm_direct.getdata()
pillow_example_xbm_direct_tile := pillow_example_xbm_direct.tile[1]
pillow_example_xbm_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_xbm_bytes), "r", ["XBM"])
pillow_example_xbm_opened_pixels := pillow_example_xbm_opened.getdata()
pillow_example_xbm_hotspot := stdlib.pillow.XbmImagePlugin.XbmImageFile(stdlib.io.BytesIO(PillowExampleXbmBytes(true)))
pillow_example_xbm_hotspot_info := pillow_example_xbm_hotspot.info["hotspot"]
pillow_example_xbm_source := stdlib.pillow.Image.new("1", [5, 2], 0)
for xy in [[0, 0], [2, 0], [4, 0], [1, 1], [3, 1]]
    pillow_example_xbm_source.putpixel(xy, 255)
pillow_example_xbm_output := stdlib.io.BytesIO()
pillow_example_xbm_source.save(pillow_example_xbm_output, "XBM", { hotspot: [3, 1] })
pillow_example_xbm_saved_text := PillowExampleAsciiFromBytes(pillow_example_xbm_output.getvalue())
pillow_example_xbm_saved_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_xbm_output.getvalue()), "r", ["XBM"])
pillow_example_xbm_saved_pixels := pillow_example_xbm_saved_opened.getdata()
pillow_example_xbm_saved_hotspot := pillow_example_xbm_saved_opened.info["hotspot"]
pillow_example_xbm_saved_opened.close()
pillow_example_xbm_source.close()
pillow_example_xbm_hotspot.close()
pillow_example_xbm_opened.close()
pillow_example_xbm_direct.close()
pillow_example_xpm_file_format := stdlib.pillow.XpmImagePlugin.XpmImageFile.format
pillow_example_xpm_file_description := stdlib.pillow.XpmImagePlugin.XpmImageFile.format_description
pillow_example_xpm_decoder_pulls_fd := stdlib.pillow.XpmImagePlugin.XpmDecoder("P")._pulls_fd
pillow_example_xpm_accept := stdlib.pillow.XpmImagePlugin._accept(PillowExampleAsciiBytes("/* XPM */`n"))
pillow_example_xpm_registered_extension := stdlib.pillow.Image.registered_extensions()[".xpm"]
pillow_example_xpm_mime := stdlib.pillow.Image.MIME["XPM"]
pillow_example_xpm_has_decoder := stdlib.pillow.Image.DECODERS.Has("xpm")
pillow_example_xpm_has_save := stdlib.pillow.Image.SAVE.Has("XPM")
pillow_example_xpm_bytes := PillowExampleXpmPBytes()
pillow_example_xpm_direct := stdlib.pillow.XpmImagePlugin.XpmImageFile(stdlib.io.BytesIO(pillow_example_xpm_bytes))
pillow_example_xpm_direct_mode := pillow_example_xpm_direct.mode
pillow_example_xpm_direct_size := pillow_example_xpm_direct.size
pillow_example_xpm_transparency := pillow_example_xpm_direct.info["transparency"]
pillow_example_xpm_palette := pillow_example_xpm_direct.getpalette()
pillow_example_xpm_pixels := pillow_example_xpm_direct.getdata()
pillow_example_xpm_tile := pillow_example_xpm_direct.tile[1]
pillow_example_xpm_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_xpm_bytes), "r", ["XPM"])
pillow_example_xpm_opened_pixels := pillow_example_xpm_opened.getdata()
pillow_example_xpm_rgb := stdlib.pillow.XpmImagePlugin.XpmImageFile(stdlib.io.BytesIO(PillowExampleXpmRgbBytes()))
pillow_example_xpm_rgb_mode := pillow_example_xpm_rgb.mode
pillow_example_xpm_rgb_size := pillow_example_xpm_rgb.size
pillow_example_xpm_rgb_pixels := pillow_example_xpm_rgb.getdata()
pillow_example_xpm_rgb_tile := pillow_example_xpm_rgb.tile[1]
pillow_example_xpm_rgb.close()
pillow_example_xpm_opened.close()
pillow_example_xpm_direct.close()
pillow_example_xvthumb_magic := stdlib.pillow.XVThumbImagePlugin._MAGIC
pillow_example_xvthumb_palette_prefix := PillowExampleArraySlice(stdlib.pillow.XVThumbImagePlugin.PALETTE, 1, 18)
pillow_example_xvthumb_palette_suffix := PillowExampleArraySlice(stdlib.pillow.XVThumbImagePlugin.PALETTE, stdlib.pillow.XVThumbImagePlugin.PALETTE.Length - 11, stdlib.pillow.XVThumbImagePlugin.PALETTE.Length)
pillow_example_xvthumb_file_format := stdlib.pillow.XVThumbImagePlugin.XVThumbImageFile.format
pillow_example_xvthumb_file_description := stdlib.pillow.XVThumbImagePlugin.XVThumbImageFile.format_description
pillow_example_xvthumb_accept := stdlib.pillow.XVThumbImagePlugin._accept(PillowExampleAsciiBytes("P7 332`n"))
pillow_example_xvthumb_registered_open := stdlib.pillow.Image.OPEN.Has("XVTHUMB")
pillow_example_xvthumb_has_save := stdlib.pillow.Image.SAVE.Has("XVTHUMB")
pillow_example_xvthumb_has_extension := stdlib.pillow.Image.registered_extensions().Has(".xv")
pillow_example_xvthumb_bytes := PillowExampleXVThumbBytes(3, 2, [0, 1, 2, 3, 4, 5], ["#IMGINFO:demo", "#THUMBONLY"])
pillow_example_xvthumb_direct := stdlib.pillow.XVThumbImagePlugin.XVThumbImageFile(stdlib.io.BytesIO(pillow_example_xvthumb_bytes))
pillow_example_xvthumb_direct_mode := pillow_example_xvthumb_direct.mode
pillow_example_xvthumb_direct_size := pillow_example_xvthumb_direct.size
pillow_example_xvthumb_direct_pixels := pillow_example_xvthumb_direct.getdata()
pillow_example_xvthumb_direct_palette_prefix := PillowExampleArraySlice(pillow_example_xvthumb_direct.getpalette(), 1, 18)
pillow_example_xvthumb_direct_tile := pillow_example_xvthumb_direct.tile[1]
pillow_example_xvthumb_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_xvthumb_bytes), "r", ["XVThumb"])
pillow_example_xvthumb_opened_pixels := pillow_example_xvthumb_opened.getdata()
pillow_example_xvthumb_space_bytes := PillowExampleAsciiBytes("P7 332 extra text ignored`n#comment`n2`t1`n")
pillow_example_xvthumb_space_bytes.Push(7)
pillow_example_xvthumb_space_bytes.Push(8)
pillow_example_xvthumb_space := stdlib.pillow.XVThumbImagePlugin.XVThumbImageFile(stdlib.io.BytesIO(pillow_example_xvthumb_space_bytes))
pillow_example_xvthumb_space_size := pillow_example_xvthumb_space.size
pillow_example_xvthumb_space_pixels := pillow_example_xvthumb_space.getdata()
pillow_example_xvthumb_space.close()
pillow_example_xvthumb_opened.close()
pillow_example_xvthumb_direct.close()
pillow_example_cms_srgb := stdlib.pillow.ImageCms.createProfile("sRGB")
pillow_example_cms_lab := stdlib.pillow.ImageCms.createProfile("LAB", 6500)
pillow_example_cms_xyz := stdlib.pillow.ImageCms.createProfile("XYZ")
pillow_example_cms_profile := stdlib.pillow.ImageCms.getOpenProfile(pillow_example_cms_srgb)
pillow_example_cms_profile_name := stdlib.pillow.ImageCms.getProfileName(pillow_example_cms_profile)
pillow_example_cms_profile_info := stdlib.pillow.ImageCms.getProfileInfo(pillow_example_cms_profile)
pillow_example_cms_profile_bytes := pillow_example_cms_profile.tobytes()
pillow_example_cms_profile_prefix := PillowExampleArraySlice(pillow_example_cms_profile_bytes, 1, 4)
pillow_example_cms_profile_from_bytes := stdlib.pillow.ImageCms.getOpenProfile(stdlib.io.BytesIO(pillow_example_cms_profile_bytes))
pillow_example_cms_profile_from_bytes_name := stdlib.pillow.ImageCms.getProfileName(pillow_example_cms_profile_from_bytes)
pillow_example_cms_versions_records := stdlib.warnings.catch_warnings(true).Call((records) => stdlib.pillow.ImageCms.versions())
pillow_example_cms_versions_message := pillow_example_cms_versions_records[1].message
pillow_example_cms_intent_string := String(stdlib.pillow.ImageCms.Intent.RELATIVE_COLORIMETRIC)
pillow_example_cms_direction_string := String(stdlib.pillow.ImageCms.Direction.OUTPUT)
pillow_example_cms_softproof_repr := stdlib.pillow.ImageCms.Flags.SOFTPROOFING.__Repr()
pillow_example_cms_gridpoints := stdlib.pillow.ImageCms.FLAGS["GRIDPOINTS"].Call(7)
pillow_example_cms_source := stdlib.pillow.Image.new("RGB", [2, 1])
pillow_example_cms_source.putdata([[1, 2, 3], [200, 150, 100]])
pillow_example_cms_transform := stdlib.pillow.ImageCms.buildTransform(pillow_example_cms_profile, pillow_example_cms_profile, "RGB", "RGB")
pillow_example_cms_applied := stdlib.pillow.ImageCms.applyTransform(pillow_example_cms_source, pillow_example_cms_transform)
pillow_example_cms_applied_pixels := pillow_example_cms_applied.getdata()
pillow_example_cms_applied_icc_prefix := PillowExampleArraySlice(pillow_example_cms_applied.info["icc_profile"], 1, 4)
pillow_example_cms_profiled := stdlib.pillow.ImageCms.profileToProfile(pillow_example_cms_source, pillow_example_cms_profile, pillow_example_cms_profile, stdlib.pillow.ImageCms.Intent.PERCEPTUAL, "RGB")
pillow_example_cms_profiled_pixels := pillow_example_cms_profiled.getdata()
pillow_example_cms_profiled.close()
pillow_example_cms_applied.close()
pillow_example_cms_source.close()
pillow_example_grab := stdlib.pillow.ImageGrab.grab([0, 0, 1, 1])
pillow_example_grab_mode := pillow_example_grab.mode
pillow_example_grab_size := pillow_example_grab.size
pillow_example_grab_pixel := pillow_example_grab.getpixel([0, 0])
pillow_example_grab_keyword := stdlib.pillow.ImageGrab.grab({
    bbox: [0, 0, 1, 1],
    include_layered_windows: false,
    all_screens: false,
    xdisplay: stdlib.None,
    window: stdlib.None,
})
pillow_example_grab_keyword_size := pillow_example_grab_keyword.size
pillow_example_grab_clipboard := stdlib.pillow.ImageGrab.grabclipboard()
if AhkStdlibIsNone(pillow_example_grab_clipboard) {
    pillow_example_grab_clipboard_kind := "none"
} else if pillow_example_grab_clipboard is Array {
    pillow_example_grab_clipboard_kind := "files"
    pillow_example_grab_clipboard_count := pillow_example_grab_clipboard.Length
} else {
    pillow_example_grab_clipboard_kind := "image"
    pillow_example_grab_clipboard_size := pillow_example_grab_clipboard.size
    pillow_example_grab_clipboard.close()
}
pillow_example_grab_keyword.close()
pillow_example_grab.close()
pillow_example_qt_rgb := stdlib.pillow.ImageQt.rgb(1, 2, 3, 4)
pillow_example_qt_aligned := stdlib.pillow.ImageQt.align8to32([1, 2, 3, 4, 5, 6], 3, "L")
pillow_example_qt_source := stdlib.pillow.Image.new("RGBA", [2, 1])
pillow_example_qt_source.putdata([[1, 2, 3, 4], [5, 6, 7, 8]])
pillow_example_qt_image := stdlib.pillow.ImageQt.toqimage(pillow_example_qt_source)
pillow_example_qt_image_format := pillow_example_qt_image.format().name
pillow_example_qt_image_pixels := pillow_example_qt_image.pixels()
pillow_example_qt_roundtrip := stdlib.pillow.ImageQt.fromqimage(pillow_example_qt_image)
pillow_example_qt_roundtrip_pixels := pillow_example_qt_roundtrip.getdata()
pillow_example_qt_rgb_source := pillow_example_qt_source.convert("RGB")
pillow_example_qt_pixmap := stdlib.pillow.ImageQt.toqpixmap(pillow_example_qt_rgb_source)
pillow_example_qt_pixmap_size := [pillow_example_qt_pixmap.width(), pillow_example_qt_pixmap.height()]
pillow_example_qt_pixmap_roundtrip := stdlib.pillow.ImageQt.fromqpixmap(pillow_example_qt_pixmap)
pillow_example_qt_pixmap_roundtrip_mode := pillow_example_qt_pixmap_roundtrip.mode
pillow_example_qt_instance_qimage := pillow_example_qt_rgb_source.toqimage()
pillow_example_qt_instance_qimage_pixels := pillow_example_qt_instance_qimage.pixels()
pillow_example_qt_instance_qpixmap := pillow_example_qt_rgb_source.toqpixmap()
pillow_example_qt_instance_qpixmap_size := [pillow_example_qt_instance_qpixmap.width(), pillow_example_qt_instance_qpixmap.height()]
pillow_example_qt_pixmap_roundtrip.close()
pillow_example_qt_roundtrip.close()
pillow_example_qt_rgb_source.close()
pillow_example_qt_source.close()
pillow_example_tk_source := stdlib.pillow.Image.new("RGB", [2, 1], [1, 2, 3])
pillow_example_tk_source.putpixel([1, 0], [4, 5, 6])
pillow_example_tk_photo := stdlib.pillow.ImageTk.PhotoImage(pillow_example_tk_source)
pillow_example_tk_photo_size := [pillow_example_tk_photo.width(), pillow_example_tk_photo.height()]
pillow_example_tk_photo_name := pillow_example_tk_photo.ToString()
pillow_example_tk_roundtrip := stdlib.pillow.ImageTk.getimage(pillow_example_tk_photo)
pillow_example_tk_roundtrip_pixels := pillow_example_tk_roundtrip.getdata()
pillow_example_tk_patch := stdlib.pillow.Image.new("RGB", [2, 1], [7, 8, 9])
pillow_example_tk_patch.putpixel([1, 0], [20, 30, 40])
pillow_example_tk_paste_result := pillow_example_tk_photo.paste(pillow_example_tk_patch)
pillow_example_tk_after_paste_pixels := stdlib.pillow.ImageTk.getimage(pillow_example_tk_photo).getdata()
pillow_example_tk_mode_photo := stdlib.pillow.ImageTk.PhotoImage("RGB", [3, 2])
pillow_example_tk_mode_photo_size := [pillow_example_tk_mode_photo.width(), pillow_example_tk_mode_photo.height()]
pillow_example_tk_path := pillow_example_output_dir "\imagetk-source.png"
pillow_example_tk_source.save(pillow_example_tk_path)
pillow_example_tk_file_kw := Map("file", pillow_example_tk_path, "sentinel", 7)
pillow_example_tk_file_opened := stdlib.pillow.ImageTk._get_image_from_kw(pillow_example_tk_file_kw)
pillow_example_tk_file_kw_remaining := pillow_example_tk_file_kw
pillow_example_tk_file_pixels := pillow_example_tk_file_opened.getdata()
pillow_example_tk_bytes := PillowExampleReadBytes(pillow_example_tk_path)
pillow_example_tk_data_photo := stdlib.pillow.ImageTk.PhotoImage({ data: pillow_example_tk_bytes })
pillow_example_tk_data_photo_size := [pillow_example_tk_data_photo.width(), pillow_example_tk_data_photo.height()]
pillow_example_tk_bits := stdlib.pillow.Image.new("1", [8, 1], 255)
pillow_example_tk_bits.putpixel([3, 0], 0)
pillow_example_tk_bitmap := stdlib.pillow.ImageTk.BitmapImage(pillow_example_tk_bits, { foreground: "white" })
pillow_example_tk_bitmap_name := pillow_example_tk_bitmap.ToString()
pillow_example_tk_bitmap_size := [pillow_example_tk_bitmap.width(), pillow_example_tk_bitmap.height()]
pillow_example_tk_file_opened.close()
pillow_example_tk_roundtrip.close()
pillow_example_tk_bits.close()
pillow_example_tk_patch.close()
pillow_example_tk_source.close()
pillow_example_win_hdc := stdlib.pillow.ImageWin.HDC(12345)
pillow_example_win_hwnd := stdlib.pillow.ImageWin.HWND(67890)
pillow_example_win_hdc_value := pillow_example_win_hdc.ToInteger()
pillow_example_win_hwnd_value := pillow_example_win_hwnd.ToInteger()
pillow_example_win_source := stdlib.pillow.Image.new("RGB", [2, 1], [1, 2, 3])
pillow_example_win_source.putpixel([1, 0], [4, 5, 6])
pillow_example_win_dib := stdlib.pillow.ImageWin.Dib(pillow_example_win_source)
pillow_example_win_dib_mode := pillow_example_win_dib.mode
pillow_example_win_dib_size := pillow_example_win_dib.size
pillow_example_win_dib_bytes := pillow_example_win_dib.tobytes()
pillow_example_win_mode_dib := stdlib.pillow.ImageWin.Dib("RGB", [2, 1])
pillow_example_win_frombytes_result := pillow_example_win_mode_dib.frombytes(pillow_example_win_dib_bytes)
pillow_example_win_patch := stdlib.pillow.Image.new("RGB", [1, 1], [20, 30, 40])
pillow_example_win_paste_result := pillow_example_win_mode_dib.paste(pillow_example_win_patch, [1, 0, 2, 1])
pillow_example_win_after_paste_bytes := pillow_example_win_mode_dib.tobytes()
pillow_example_win_query_palette := pillow_example_win_dib.query_palette(0)
pillow_example_win_window := stdlib.pillow.ImageWin.Window("example", 2, 1)
pillow_example_win_window_size := [pillow_example_win_window.width, pillow_example_win_window.height]
pillow_example_win_image_window := stdlib.pillow.ImageWin.ImageWindow(pillow_example_win_source, "example")
pillow_example_win_image_window_size := pillow_example_win_image_window.image.size
pillow_example_win_patch.close()
pillow_example_win_source.close()
pillow_example_show_viewers_before := stdlib.pillow.ImageShow.viewer_names()
pillow_example_show_saved_viewers := stdlib.pillow.ImageShow._viewers.Clone()
pillow_example_show_source := stdlib.pillow.Image.new("RGB", [2, 1], [1, 2, 3])
pillow_example_show_command_path := pillow_example_output_dir "\imageshow-command.png"
try {
    stdlib.pillow.ImageShow.clear_viewers()
    pillow_example_show_empty := stdlib.pillow.ImageShow.show(pillow_example_show_source)
    pillow_example_show_first := PillowExampleShowViewer(0)
    pillow_example_show_second := PillowExampleShowViewer(1)
    stdlib.pillow.ImageShow.register(pillow_example_show_first)
    stdlib.pillow.ImageShow.register(pillow_example_show_second)
    pillow_example_show_result := stdlib.pillow.ImageShow.show(pillow_example_show_source, "example", { custom: 7 })
    pillow_example_show_first_calls := pillow_example_show_first.Calls
    pillow_example_show_second_calls := pillow_example_show_second.Calls
    pillow_example_show_instance_return := pillow_example_show_source.show("instance")
    pillow_example_show_instance_calls := pillow_example_show_second.Calls
    pillow_example_show_prepend := PillowExampleShowViewer(1)
    stdlib.pillow.ImageShow.register(pillow_example_show_prepend, 0)
    pillow_example_show_prepend_is_first := stdlib.pillow.ImageShow._viewers[1] == pillow_example_show_prepend
    pillow_example_show_windows := stdlib.pillow.ImageShow.WindowsViewer()
    PillowExampleWriteBytes(pillow_example_show_command_path, [120])
    pillow_example_show_windows_format := pillow_example_show_windows.format
    pillow_example_show_windows_command := pillow_example_show_windows.get_command(pillow_example_show_command_path)
    pillow_example_show_display_command := stdlib.pillow.ImageShow.DisplayViewer().get_command("a b.png", { title: "My Title" })
} finally {
    stdlib.pillow.ImageShow.restore_viewers(pillow_example_show_saved_viewers)
    pillow_example_show_source.close()
}
pillow_example_morph_source := stdlib.pillow.Image.new("L", [5, 5], 0)
pillow_example_morph_source.putpixel([2, 1], 255)
pillow_example_morph_source.putpixel([1, 2], 255)
pillow_example_morph_source.putpixel([2, 2], 255)
pillow_example_morph_source.putpixel([3, 2], 255)
pillow_example_morph_source.putpixel([2, 3], 255)
pillow_example_morph_builder := stdlib.pillow.ImageMorph.LutBuilder({ op_name: "dilation4" })
pillow_example_morph_lut := pillow_example_morph_builder.build_lut()
pillow_example_morph_lut_prefix := PillowExampleArraySlice(pillow_example_morph_lut, 1, 16)
pillow_example_morph_op := stdlib.pillow.ImageMorph.MorphOp({ lut: pillow_example_morph_lut })
pillow_example_morph_result := pillow_example_morph_op.apply(pillow_example_morph_source)
pillow_example_morph_changed := pillow_example_morph_result[1]
pillow_example_morph_rows := PillowExamplePixelRows(pillow_example_morph_result[2])
pillow_example_morph_matches := pillow_example_morph_op.match(pillow_example_morph_source)
pillow_example_morph_lut_path := pillow_example_output_dir "\dilation4.mrl"
pillow_example_morph_op.save_lut(pillow_example_morph_lut_path)
pillow_example_morph_lut_saved_prefix := PillowExampleArraySlice(PillowExampleReadBytes(pillow_example_morph_lut_path), 1, 16)
pillow_example_morph_loaded_op := stdlib.pillow.ImageMorph.MorphOp()
pillow_example_morph_loaded_op.load_lut(pillow_example_morph_lut_path)
pillow_example_morph_loaded_match := pillow_example_morph_loaded_op.match(pillow_example_morph_source)
pillow_example_morph_result[2].close()
pillow_example_morph_source.close()
pillow_example_cur_accept := stdlib.pillow.CurImagePlugin._accept([0, 0, 2, 0, 114, 101, 115, 116])
pillow_example_cur_file_format := stdlib.pillow.CurImagePlugin.CurImageFile.format
pillow_example_cur_registered_extension := stdlib.pillow.Image.registered_extensions()[".cur"]
pillow_example_cur_dib := PillowExampleCurDibBytes(2, 4, [10, 20, 30], [1, 0, [200, 10, 5]])
pillow_example_cur_bytes := PillowExampleCurBytes([[2, 2, 24, pillow_example_cur_dib]])
pillow_example_cur_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_cur_bytes), "r", ["CUR"])
pillow_example_cur_opened_mode := pillow_example_cur_opened.mode
pillow_example_cur_opened_size := pillow_example_cur_opened.size
pillow_example_cur_opened_pixel := pillow_example_cur_opened.getpixel([1, 0])
pillow_example_cur_opened.close()
pillow_example_dcx_frame_one := PillowExamplePcxRgbBytes(2, 2, [10, 20, 30], [1, 0, [200, 10, 5]])
pillow_example_dcx_frame_two := PillowExamplePcxRgbBytes(2, 2, [40, 50, 60], [1, 0, [1, 2, 3]])
pillow_example_dcx_single_bytes := PillowExampleDcxBytes([pillow_example_dcx_frame_one])
pillow_example_dcx_multi_bytes := PillowExampleDcxBytes([pillow_example_dcx_frame_one, pillow_example_dcx_frame_two])
pillow_example_dcx_accept := stdlib.pillow.DcxImagePlugin._accept(PillowExampleArraySlice(pillow_example_dcx_single_bytes, 1, 8))
pillow_example_dcx_file_format := stdlib.pillow.DcxImagePlugin.DcxImageFile.format
pillow_example_dcx_registered_extension := stdlib.pillow.Image.registered_extensions()[".dcx"]
pillow_example_dcx_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_dcx_multi_bytes), "r", ["DCX"])
pillow_example_dcx_frame_count := pillow_example_dcx_opened.n_frames
pillow_example_dcx_first_pixel := pillow_example_dcx_opened.getpixel([1, 0])
pillow_example_dcx_seek := pillow_example_dcx_opened.seek(1)
pillow_example_dcx_tell := pillow_example_dcx_opened.tell()
pillow_example_dcx_second_pixel := pillow_example_dcx_opened.getpixel([1, 0])
pillow_example_dcx_opened.close()
pillow_example_dds_accept := stdlib.pillow.DdsImagePlugin._accept(PillowExampleAsciiBytes("DDS demo"))
pillow_example_dds_file_format := stdlib.pillow.DdsImagePlugin.DdsImageFile.format
pillow_example_dds_magic := stdlib.pillow.DdsImagePlugin.DDS_MAGIC
pillow_example_dds_flags := stdlib.pillow.DdsImagePlugin.DDSD.combine(
    stdlib.pillow.DdsImagePlugin.DDSD.CAPS,
    stdlib.pillow.DdsImagePlugin.DDSD.HEIGHT,
    stdlib.pillow.DdsImagePlugin.DDSD.WIDTH,
    stdlib.pillow.DdsImagePlugin.DDSD.PIXELFORMAT
)
pillow_example_dds_flags_text := String(pillow_example_dds_flags)
pillow_example_dds_bc7_value := stdlib.pillow.DdsImagePlugin.DXGI_FORMAT.BC7_UNORM.value
pillow_example_dds_registered_extension := stdlib.pillow.Image.registered_extensions()[".dds"]
pillow_example_dds_rgb_source := stdlib.pillow.Image.new("RGB", [2, 2], [10, 20, 30])
pillow_example_dds_rgb_source.putpixel([1, 0], [200, 10, 5])
pillow_example_dds_rgb_buffer := stdlib.io.BytesIO()
pillow_example_dds_rgb_save := pillow_example_dds_rgb_source.save(pillow_example_dds_rgb_buffer, "DDS")
pillow_example_dds_rgb_bytes := pillow_example_dds_rgb_buffer.getvalue()
pillow_example_dds_rgb_prefix := PillowExampleArraySlice(pillow_example_dds_rgb_bytes, 1, 8)
pillow_example_dds_rgb_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_dds_rgb_bytes), "r", ["DDS"])
pillow_example_dds_rgb_mode := pillow_example_dds_rgb_opened.mode
pillow_example_dds_rgb_pixel := pillow_example_dds_rgb_opened.getpixel([1, 0])
pillow_example_dds_la_source := stdlib.pillow.Image.new("LA", [2, 2], [10, 40])
pillow_example_dds_la_source.putpixel([1, 0], [200, 128])
pillow_example_dds_la_buffer := stdlib.io.BytesIO()
pillow_example_dds_la_save := pillow_example_dds_la_source.save(pillow_example_dds_la_buffer, "DDS")
pillow_example_dds_la_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_dds_la_buffer.getvalue()), "r", ["DDS"])
pillow_example_dds_la_mode := pillow_example_dds_la_opened.mode
pillow_example_dds_la_pixel := pillow_example_dds_la_opened.getpixel([1, 0])
pillow_example_dds_la_opened.close()
pillow_example_dds_la_source.close()
pillow_example_dds_rgb_opened.close()
pillow_example_dds_rgb_source.close()
pillow_example_eps_accept := stdlib.pillow.EpsImagePlugin._accept(PillowExampleAsciiBytes("%!PS-Adobe-3.0 EPSF-3.0`n"))
pillow_example_eps_mac_accept := stdlib.pillow.EpsImagePlugin._accept([0xC5, 0xD0, 0xD3, 0xC6, 114, 101, 115, 116])
pillow_example_eps_file_format := stdlib.pillow.EpsImagePlugin.EpsImageFile.format
pillow_example_eps_has_ghostscript := stdlib.pillow.EpsImagePlugin.has_ghostscript()
pillow_example_eps_registered_extension := stdlib.pillow.Image.registered_extensions()[".eps"]
pillow_example_eps_source := stdlib.pillow.Image.new("RGB", [2, 1], [10, 20, 30])
pillow_example_eps_source.putpixel([1, 0], [200, 10, 5])
pillow_example_eps_buffer := stdlib.io.BytesIO()
pillow_example_eps_save := pillow_example_eps_source.save(pillow_example_eps_buffer, "EPS")
pillow_example_eps_bytes := pillow_example_eps_buffer.getvalue()
pillow_example_eps_prefix := PillowExampleArraySlice(pillow_example_eps_bytes, 1, 24)
pillow_example_eps_has_bbox := PillowExampleBytesContainsAscii(pillow_example_eps_bytes, "%%BoundingBox: 0 0 2 1`n")
pillow_example_eps_has_rgb_hex := PillowExampleBytesContainsAscii(pillow_example_eps_bytes, "0a141ec80a05")
pillow_example_eps_opened := stdlib.pillow.EpsImagePlugin.EpsImageFile(stdlib.io.BytesIO(PillowExampleBasicEpsBytes()))
pillow_example_eps_opened_size := pillow_example_eps_opened.size
pillow_example_eps_opened_bbox := pillow_example_eps_opened.info["BoundingBox"]
pillow_example_eps_opened.close()
pillow_example_eps_source.close()
pillow_example_fits_accept := stdlib.pillow.FitsImagePlugin._accept(PillowExampleAsciiBytes("SIMPLE  = T"))
pillow_example_fits_file_format := stdlib.pillow.FitsImagePlugin.FitsImageFile.format
pillow_example_fits_registered_extension := stdlib.pillow.Image.registered_extensions()[".fits"]
pillow_example_fits_bytes := PillowExampleFitsSimpleBytes(16, 2, [3, 2])
pillow_example_fits_opened := stdlib.pillow.FitsImagePlugin.FitsImageFile(stdlib.io.BytesIO(pillow_example_fits_bytes))
pillow_example_fits_opened_mode := pillow_example_fits_opened.mode
pillow_example_fits_opened_size := pillow_example_fits_opened.size
pillow_example_fits_opened_tile := pillow_example_fits_opened.tile[1]
pillow_example_fits_opened.close()
pillow_example_fits_image_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(PillowExampleFitsSimpleBytes(8, 1, [5])), "r", ["FITS"])
pillow_example_fits_image_opened_size := pillow_example_fits_image_opened.size
pillow_example_fits_image_opened.close()
pillow_example_fli_accept := stdlib.pillow.FliImagePlugin._accept(PillowExampleArraySlice(PillowExampleFliBytes(), 1, 16))
pillow_example_fli_file_format := stdlib.pillow.FliImagePlugin.FliImageFile.format
pillow_example_fli_registered_extension := stdlib.pillow.Image.registered_extensions()[".fli"]
pillow_example_fli_bytes := PillowExampleFliBytes(0xAF11, 2, 70)
pillow_example_fli_opened := stdlib.pillow.FliImagePlugin.FliImageFile(stdlib.io.BytesIO(pillow_example_fli_bytes))
pillow_example_fli_duration := pillow_example_fli_opened.info["duration"]
pillow_example_fli_frames := pillow_example_fli_opened.n_frames
pillow_example_fli_tile := pillow_example_fli_opened.tile[1]
pillow_example_fli_palette_prefix := PillowExampleArraySlice(pillow_example_fli_opened.palette.palette, 1, 12)
pillow_example_fli_image_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(PillowExampleFliBytes()), "r", ["FLI"])
pillow_example_fli_image_opened_size := pillow_example_fli_image_opened.size
pillow_example_fli_image_opened.close()
pillow_example_fli_opened.close()
pillow_example_fpx_accept := stdlib.pillow.FpxImagePlugin._accept(PillowExampleFpxMagicBytes([114, 101, 115, 116]))
pillow_example_fpx_file_format := stdlib.pillow.FpxImagePlugin.FpxImageFile.format
pillow_example_fpx_file_description := stdlib.pillow.FpxImagePlugin.FpxImageFile.format_description
pillow_example_fpx_registered_extension := stdlib.pillow.Image.registered_extensions()[".fpx"]
pillow_example_fpx_old_olefile := stdlib.pillow.FpxImagePlugin.olefile
try {
    pillow_example_fpx_fake_olefile := PillowExampleFpxFakeOleModule()
    stdlib.pillow.FpxImagePlugin.olefile := pillow_example_fpx_fake_olefile
    pillow_example_fpx_opened := stdlib.pillow.FpxImagePlugin.FpxImageFile(stdlib.io.BytesIO(PillowExampleFpxMagicBytes()))
    pillow_example_fpx_mode := pillow_example_fpx_opened.mode
    pillow_example_fpx_size := pillow_example_fpx_opened.size
    pillow_example_fpx_tile := pillow_example_fpx_opened.tile[1]
    pillow_example_fpx_image_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(PillowExampleFpxMagicBytes()), "r", ["FPX"])
    pillow_example_fpx_image_opened_size := pillow_example_fpx_image_opened.size
    pillow_example_fpx_image_opened.close()
    pillow_example_fpx_opened.close()
} finally {
    stdlib.pillow.FpxImagePlugin.olefile := pillow_example_fpx_old_olefile
}
pillow_example_ftex_accept := stdlib.pillow.FtexImagePlugin._accept(PillowExampleAsciiBytes("FTEXrest"))
pillow_example_ftex_format_dxt1 := stdlib.pillow.FtexImagePlugin.Format.DXT1.value
pillow_example_ftex_format_uncompressed := String(stdlib.pillow.FtexImagePlugin.Format.UNCOMPRESSED)
pillow_example_ftex_file_format := stdlib.pillow.FtexImagePlugin.FtexImageFile.format
pillow_example_ftex_registered_extension := stdlib.pillow.Image.registered_extensions()[".ftc"]
pillow_example_ftex_rgb_bytes := PillowExampleFtexBytes(2, 2, stdlib.pillow.FtexImagePlugin.Format.UNCOMPRESSED.value, [
    10, 20, 30,
    40, 50, 60,
    70, 80, 90,
    100, 110, 120,
])
pillow_example_ftex_rgb_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_ftex_rgb_bytes), "r", ["FTEX"])
pillow_example_ftex_rgb_mode := pillow_example_ftex_rgb_opened.mode
pillow_example_ftex_rgb_tile := pillow_example_ftex_rgb_opened.tile[1]
pillow_example_ftex_rgb_pixel := pillow_example_ftex_rgb_opened.getpixel([1, 0])
pillow_example_ftex_rgb_opened.close()
pillow_example_ftex_dxt_bytes := PillowExampleFtexBytes(4, 4, stdlib.pillow.FtexImagePlugin.Format.DXT1.value, [0, 248, 224, 7, 0, 0, 0, 0])
pillow_example_ftex_dxt_opened := stdlib.pillow.FtexImagePlugin.FtexImageFile(stdlib.io.BytesIO(pillow_example_ftex_dxt_bytes))
pillow_example_ftex_dxt_mode := pillow_example_ftex_dxt_opened.mode
pillow_example_ftex_dxt_tile := pillow_example_ftex_dxt_opened.tile[1]
pillow_example_ftex_dxt_opened.close()
pillow_example_gbr_accept := stdlib.pillow.GbrImagePlugin._accept(PillowExampleArraySlice(PillowExampleGbrBytes(2, 2, 1, [1, 2, 3, 4], 2, "gray", 9), 1, 8))
pillow_example_gbr_file_format := stdlib.pillow.GbrImagePlugin.GbrImageFile.format
pillow_example_gbr_registered_extension := stdlib.pillow.Image.registered_extensions()[".gbr"]
pillow_example_gbr_gray_bytes := PillowExampleGbrBytes(2, 2, 1, [1, 2, 3, 4], 2, "gray", 9)
pillow_example_gbr_gray_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_gbr_gray_bytes), "r", ["GBR"])
pillow_example_gbr_gray_mode := pillow_example_gbr_gray_opened.mode
pillow_example_gbr_gray_spacing := pillow_example_gbr_gray_opened.info["spacing"]
pillow_example_gbr_gray_comment := pillow_example_gbr_gray_opened.info["comment"]
pillow_example_gbr_gray_pixel := pillow_example_gbr_gray_opened.getpixel([1, 1])
pillow_example_gbr_gray_opened.close()
pillow_example_gbr_rgba_bytes := PillowExampleGbrBytes(2, 1, 4, [10, 20, 30, 40, 50, 60, 70, 80], 1, "rgba")
pillow_example_gbr_rgba_opened := stdlib.pillow.GbrImagePlugin.GbrImageFile(stdlib.io.BytesIO(pillow_example_gbr_rgba_bytes))
pillow_example_gbr_rgba_mode := pillow_example_gbr_rgba_opened.mode
pillow_example_gbr_rgba_pixel := pillow_example_gbr_rgba_opened.getpixel([1, 0])
pillow_example_gbr_rgba_opened.close()
pillow_example_gd_file_format := stdlib.pillow.GdImageFile.GdImageFile.format
pillow_example_gd_open_registered := stdlib.pillow.Image.OPEN.Has("GD")
pillow_example_gd_registered_extension := stdlib.pillow.Image.registered_extensions().Has(".gd")
pillow_example_gd_bytes := PillowExampleGdBytes(3, 2, 0, 2, [0, 1, 2, 3, 4, 5])
pillow_example_gd_opened := stdlib.pillow.GdImageFile.open(stdlib.io.BytesIO(pillow_example_gd_bytes))
pillow_example_gd_mode := pillow_example_gd_opened.mode
pillow_example_gd_tile := pillow_example_gd_opened.tile[1]
pillow_example_gd_transparency := pillow_example_gd_opened.info["transparency"]
pillow_example_gd_palette_prefix := PillowExampleArraySlice(pillow_example_gd_opened.getpalette(), 1, 12)
pillow_example_gd_pixel := pillow_example_gd_opened.getpixel([2, 1])
pillow_example_gd_opened.close()
pillow_example_gif_accept := stdlib.pillow.GifImagePlugin._accept(PillowExampleAsciiBytes("GIF89a123"))
pillow_example_gif_strategy := String(stdlib.pillow.GifImagePlugin.LOADING_STRATEGY)
pillow_example_gif_rawmode := stdlib.pillow.GifImagePlugin.RAWMODE["P"]
pillow_example_gif_file_format := stdlib.pillow.GifImagePlugin.GifImageFile.format
pillow_example_gif_registered_extension := stdlib.pillow.Image.registered_extensions()[".gif"]
pillow_example_gif_registered_mime := stdlib.pillow.Image.MIME["GIF"]
pillow_example_gif_bytes := PillowExampleGifBytes()
pillow_example_gif_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_gif_bytes), "r", ["GIF"])
pillow_example_gif_mode := pillow_example_gif_opened.mode
pillow_example_gif_tile := pillow_example_gif_opened.tile[1]
pillow_example_gif_comment := pillow_example_gif_opened.info["comment"]
pillow_example_gif_loop := pillow_example_gif_opened.info["loop"]
pillow_example_gif_transparency := pillow_example_gif_opened.info["transparency"]
pillow_example_gif_palette_prefix := PillowExampleArraySlice(pillow_example_gif_opened.getpalette(), 1, 12)
pillow_example_gif_pixel := pillow_example_gif_opened.getpixel([1, 1])
pillow_example_gif_opened.close()
pillow_example_gif_source := stdlib.pillow.Image.new("P", [2, 2])
pillow_example_gif_source.putpalette([
    0, 0, 0,
    255, 0, 0,
    0, 255, 0,
    0, 0, 255,
])
pillow_example_gif_source.putdata([0, 1, 2, 3])
pillow_example_gif_buffer := stdlib.io.BytesIO()
pillow_example_gif_save := pillow_example_gif_source.save(pillow_example_gif_buffer, "GIF", { transparency: 0, loop: 3, duration: 40, comment: PillowExampleAsciiBytes("ok") })
pillow_example_gif_saved_bytes := pillow_example_gif_buffer.getvalue()
pillow_example_gif_saved_prefix := PillowExampleArraySlice(pillow_example_gif_saved_bytes, 1, 6)
pillow_example_gif_saved_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_gif_saved_bytes), "r", ["GIF"])
pillow_example_gif_saved_pixel := pillow_example_gif_saved_opened.getpixel([1, 1])
pillow_example_gif_saved_opened.close()
pillow_example_gif_append := stdlib.pillow.Image.new("P", [2, 2])
pillow_example_gif_append.putpalette([
    0, 0, 0,
    255, 0, 0,
    0, 255, 0,
    0, 0, 255,
])
pillow_example_gif_append.putdata([3, 2, 1, 0])
pillow_example_gif_multi_buffer := stdlib.io.BytesIO()
pillow_example_gif_multi_save := pillow_example_gif_source.save(pillow_example_gif_multi_buffer, "GIF", { save_all: true, append_images: [pillow_example_gif_append], loop: 2, duration: [40, 70] })
pillow_example_gif_multi_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_gif_multi_buffer.getvalue()), "r", ["GIF"])
pillow_example_gif_multi_frames := pillow_example_gif_multi_opened.n_frames
pillow_example_gif_multi_loop := pillow_example_gif_multi_opened.info["loop"]
pillow_example_gif_multi_opened.seek(1)
pillow_example_gif_multi_second_mode := pillow_example_gif_multi_opened.mode
pillow_example_gif_multi_second_pixel := pillow_example_gif_multi_opened.getpixel([0, 0])
pillow_example_gif_multi_opened.close()
pillow_example_gif_append.close()
pillow_example_gif_source.close()
pillow_example_gimp_gradient_segments := stdlib.pillow.GimpGradientFile.SEGMENTS
pillow_example_gimp_gradient_linear := stdlib.pillow.GimpGradientFile.linear(0.5, 0.25)
pillow_example_gimp_gradient_sine := stdlib.pillow.GimpGradientFile.sine(0.5, 0.75)
pillow_example_gimp_gradient_bytes := PillowExampleAsciiBytes(
    "GIMP Gradient`n"
    "Name: demo`n"
    "1`n"
    "0.0 0.5 1.0 0 0 0 1 1 0 0 1 0 0`n"
)
pillow_example_gimp_gradient := stdlib.pillow.GimpGradientFile.GimpGradientFile(stdlib.io.BytesIO(pillow_example_gimp_gradient_bytes))
pillow_example_gimp_gradient_entry := pillow_example_gimp_gradient.gradient[1]
pillow_example_gimp_gradient_palette := pillow_example_gimp_gradient.getpalette(5)
pillow_example_gimp_gradient_palette_mode := pillow_example_gimp_gradient_palette[2]
pillow_example_gimp_gradient_palette_prefix := PillowExampleArraySlice(pillow_example_gimp_gradient_palette[1], 1, 12)
pillow_example_gimp_gradient_no_name := stdlib.pillow.GimpGradientFile.GimpGradientFile(stdlib.io.BytesIO(PillowExampleAsciiBytes(
    "GIMP Gradient`n"
    "1`n"
    "0.0 0.5 1.0 0 0 1 1 0 1 0 0.5 0 0`n"
)))
pillow_example_gimp_gradient_no_name_palette := pillow_example_gimp_gradient_no_name.getpalette(3)[1]
pillow_example_gimp_palette_bytes := PillowExampleAsciiBytes(
    "GIMP Palette`n"
    "Name: demo`n"
    "Columns: 2`n"
    "# comment`n"
    "0 0 0 black`n"
    "255 0 0 red`n"
    "1 2 3`n"
)
pillow_example_gimp_palette := stdlib.pillow.GimpPaletteFile.GimpPaletteFile(stdlib.io.BytesIO(pillow_example_gimp_palette_bytes))
pillow_example_gimp_palette_data := pillow_example_gimp_palette.getpalette()
pillow_example_gimp_palette_mode := pillow_example_gimp_palette_data[2]
pillow_example_gimp_palette_prefix := PillowExampleArraySlice(pillow_example_gimp_palette_data[1], 1, 9)
pillow_example_gimp_palette_frombytes := stdlib.pillow.GimpPaletteFile.frombytes(pillow_example_gimp_palette_bytes)
pillow_example_gimp_palette_frombytes_len := pillow_example_gimp_palette_frombytes.palette.Length
pillow_example_gimp_palette_many_bytes := PillowExampleAsciiBytes("GIMP Palette`n")
loop 300 {
    pillow_example_gimp_palette_value := Mod(A_Index - 1, 256)
    for byte in PillowExampleAsciiBytes(pillow_example_gimp_palette_value " " pillow_example_gimp_palette_value " " pillow_example_gimp_palette_value "`n")
        pillow_example_gimp_palette_many_bytes.Push(byte)
}
pillow_example_gimp_palette_limited := stdlib.pillow.GimpPaletteFile.GimpPaletteFile(stdlib.io.BytesIO(pillow_example_gimp_palette_many_bytes))
pillow_example_gimp_palette_unlimited := stdlib.pillow.GimpPaletteFile.frombytes(pillow_example_gimp_palette_many_bytes)
pillow_example_gimp_palette_limited_tail := PillowExampleArraySlice(pillow_example_gimp_palette_limited.palette, 763, 768)
pillow_example_gimp_palette_unlimited_tail := PillowExampleArraySlice(pillow_example_gimp_palette_unlimited.palette, 895, 900)
pillow_example_blp_accept := stdlib.pillow.BlpImagePlugin._accept(PillowExampleAsciiBytes("BLP2demo"))
pillow_example_blp_format_value := stdlib.pillow.BlpImagePlugin.Format.JPEG.value
pillow_example_blp_encoding_name := stdlib.pillow.BlpImagePlugin.Encoding.UNCOMPRESSED.name
pillow_example_blp_alpha_encoding_text := String(stdlib.pillow.BlpImagePlugin.AlphaEncoding.DXT5)
pillow_example_blp_unpack_red := stdlib.pillow.BlpImagePlugin.unpack_565(0xF800)
pillow_example_blp_file_format := stdlib.pillow.BlpImagePlugin.BlpImageFile.format
pillow_example_blp_registered_extension := stdlib.pillow.Image.registered_extensions()[".blp"]
pillow_example_blp_has_save := stdlib.pillow.Image.SAVE.Has("BLP")
pillow_example_blp_source := PillowExampleBlpPaletteImage("RGBA")
pillow_example_blp_buffer := stdlib.io.BytesIO()
pillow_example_blp_save := pillow_example_blp_source.save(pillow_example_blp_buffer, "BLP")
pillow_example_blp_bytes := pillow_example_blp_buffer.getvalue()
pillow_example_blp_prefix := PillowExampleArraySlice(pillow_example_blp_bytes, 1, 12)
pillow_example_blp_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_blp_bytes), "r", ["BLP"])
pillow_example_blp_opened_mode := pillow_example_blp_opened.mode
pillow_example_blp_opened_pixel := pillow_example_blp_opened.getpixel([1, 0])
pillow_example_blp1_buffer := stdlib.io.BytesIO()
pillow_example_blp1_save := pillow_example_blp_source.save(pillow_example_blp1_buffer, "BLP", { blp_version: "BLP1" })
pillow_example_blp1_prefix := PillowExampleArraySlice(pillow_example_blp1_buffer.getvalue(), 1, 4)
pillow_example_blp1_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_blp1_buffer.getvalue()), "r", ["BLP"])
pillow_example_blp1_opened_pixel := pillow_example_blp1_opened.getpixel([0, 1])
pillow_example_mode_descriptor := stdlib.pillow.ImageMode.getmode("RGBA")
pillow_example_mode_descriptor_bands := pillow_example_mode_descriptor.bands
pillow_example_mode_descriptor_base := pillow_example_mode_descriptor.basemode
pillow_example_mode_descriptor_repr := pillow_example_mode_descriptor.__Repr()
pillow_example_custom_mode_descriptor := stdlib.pillow.ImageMode.ModeDescriptor("X", ["A"], "X", "X", "|u1")
pillow_example_custom_mode_descriptor_text := String(pillow_example_custom_mode_descriptor)
pillow_example_image_palette := stdlib.pillow.ImagePalette.ImagePalette("RGB", [1, 2, 3, 4, 5, 6])
pillow_example_image_palette_data := pillow_example_image_palette.getdata()
pillow_example_image_palette_bytes := pillow_example_image_palette.tobytes()
pillow_example_image_palette_copy := pillow_example_image_palette.copy()
pillow_example_image_palette_copy.palette[1] := 99
pillow_example_image_palette_copy_color := pillow_example_image_palette_copy.colors["99,2,3"]
pillow_example_allocated_palette := stdlib.pillow.ImagePalette.ImagePalette("RGBA")
pillow_example_allocated_palette_first := pillow_example_allocated_palette.getcolor([1, 2, 3])
pillow_example_allocated_palette_second := pillow_example_allocated_palette.getcolor([1, 2, 3, 4])
pillow_example_allocated_palette_bytes := pillow_example_allocated_palette.tobytes()
pillow_example_raw_palette := stdlib.pillow.ImagePalette.raw("RGB", [1, 2, 3])
pillow_example_raw_palette_data := pillow_example_raw_palette.getdata()
pillow_example_wedge_palette := stdlib.pillow.ImagePalette.wedge("L")
pillow_example_wedge_palette_prefix := [pillow_example_wedge_palette.palette[1], pillow_example_wedge_palette.palette[2], pillow_example_wedge_palette.palette[3]]
pillow_example_sepia_palette := stdlib.pillow.ImagePalette.sepia()
pillow_example_sepia_palette_tail := [pillow_example_sepia_palette.palette[766], pillow_example_sepia_palette.palette[767], pillow_example_sepia_palette.palette[768]]
pillow_example_palette_linear_lut := stdlib.pillow.ImagePalette.make_linear_lut(0, 20)
pillow_example_palette_gamma_lut := stdlib.pillow.ImagePalette.make_gamma_lut(2.0)
pillow_example_palette_lut_tail := [pillow_example_palette_linear_lut[256], pillow_example_palette_gamma_lut[256]]
pillow_example_registry_before := stdlib.pillow.Image.registered_extensions()
pillow_example_registry_png := pillow_example_registry_before[".png"]
pillow_example_register_open := stdlib.pillow.Image.register_open("AHKSTDLIB_EXAMPLE", PillowExampleRegistryFactory, PillowExampleRegistryAccept)
pillow_example_register_save := stdlib.pillow.Image.register_save("AHKSTDLIB_EXAMPLE", PillowExampleRegistrySave)
pillow_example_register_save_all := stdlib.pillow.Image.register_save_all("AHKSTDLIB_EXAMPLE", PillowExampleRegistrySave)
pillow_example_register_decoder := stdlib.pillow.Image.register_decoder("ahkstdlib_example", PillowExampleRegistryDecoder)
pillow_example_register_encoder := stdlib.pillow.Image.register_encoder("ahkstdlib_example", PillowExampleRegistryEncoder)
pillow_example_register_extension := stdlib.pillow.Image.register_extension("AHKSTDLIB_EXAMPLE", ".ahkstdlib-example")
pillow_example_register_extensions := stdlib.pillow.Image.register_extensions("AHKSTDLIB_EXAMPLE", [".ahkstdlib-example-2"])
pillow_example_register_mime := stdlib.pillow.Image.register_mime("AHKSTDLIB_EXAMPLE", "image/x-ahkstdlib-example")
pillow_example_registry_after := stdlib.pillow.Image.registered_extensions()
pillow_example_registry_custom := pillow_example_registry_after[".ahkstdlib-example"]
pillow_example_registry_extension_same := stdlib.pillow.Image.EXTENSION == pillow_example_registry_after
pillow_example_registry_open_factory := stdlib.pillow.Image.OPEN["AHKSTDLIB_EXAMPLE"][1] == PillowExampleRegistryFactory
pillow_example_registry_open_accept := stdlib.pillow.Image.OPEN["AHKSTDLIB_EXAMPLE"][2] == PillowExampleRegistryAccept
pillow_example_registry_save_driver := stdlib.pillow.Image.SAVE["AHKSTDLIB_EXAMPLE"] == PillowExampleRegistrySave
pillow_example_registry_save_all_driver := stdlib.pillow.Image.SAVE_ALL["AHKSTDLIB_EXAMPLE"] == PillowExampleRegistrySave
pillow_example_registry_decoder := stdlib.pillow.Image.DECODERS["ahkstdlib_example"] == PillowExampleRegistryDecoder
pillow_example_registry_encoder := stdlib.pillow.Image.ENCODERS["ahkstdlib_example"] == PillowExampleRegistryEncoder
pillow_example_registry_mime := stdlib.pillow.Image.MIME["AHKSTDLIB_EXAMPLE"]
pillow_example_registry_id_tail := stdlib.pillow.Image.ID[stdlib.pillow.Image.ID.Length]
pillow_example_registry_modes_prefix := [
    stdlib.pillow.Image.MODES[1],
    stdlib.pillow.Image.MODES[2],
    stdlib.pillow.Image.MODES[3],
]
pillow_example_codec_image := stdlib.pillow.Image.frombytes("L", [3, 1], [4, 5, 6], "ahkstdlib_example")
pillow_example_codec_pixels := pillow_example_codec_image.getdata()
pillow_example_codec_bytes := pillow_example_codec_image.tobytes("ahkstdlib_example")
pillow_example_custom_save_path := pillow_example_output_dir "\custom.ahkstdlib-example"
pillow_example_custom_save_all_path := pillow_example_output_dir "\custom-all.ahkstdlib-example"
pillow_example_custom_save := pillow_example_codec_image.save(pillow_example_custom_save_path, "AHKSTDLIB_EXAMPLE", { quality: 77 })
pillow_example_custom_save_bytes := PillowExampleReadBytes(pillow_example_custom_save_path)
pillow_example_custom_save_all := pillow_example_codec_image.save(pillow_example_custom_save_all_path, "AHKSTDLIB_EXAMPLE", { save_all: true })
pillow_example_custom_save_all_bytes := PillowExampleReadBytes(pillow_example_custom_save_all_path)
pillow_example_custom_memory_save := stdlib.io.BytesIO()
pillow_example_custom_memory_save_result := pillow_example_codec_image.save(pillow_example_custom_memory_save, "AHKSTDLIB_EXAMPLE", { quality: 33 })
pillow_example_custom_memory_save_bytes := pillow_example_custom_memory_save.getvalue()
pillow_example_custom_memory_save_pos := pillow_example_custom_memory_save.tell()
pillow_example_custom_memory_save_closed := pillow_example_custom_memory_save.closed
pillow_example_custom_open_path := pillow_example_output_dir "\custom-open.ahkstdlib-example"
PillowExampleWriteBytes(pillow_example_custom_open_path, [65, 72, 75, 79, 80, 69, 78, 48, 49, 50, 51, 52, 53, 54, 55, 56, 109, 111, 114, 101])
pillow_example_custom_open := stdlib.pillow.Image.open(pillow_example_custom_open_path, "r", ["AHKSTDLIB_EXAMPLE"])
pillow_example_custom_open_mode := pillow_example_custom_open.mode
pillow_example_custom_open_size := pillow_example_custom_open.size
pillow_example_custom_open_format := pillow_example_custom_open.format
pillow_example_custom_open_prefix := PillowExampleRegistryFactory.Prefix
pillow_example_linear_gradient := stdlib.pillow.Image.linear_gradient("L")
pillow_example_linear_gradient_pixel := pillow_example_linear_gradient.getpixel([0, 128])
pillow_example_radial_gradient := stdlib.pillow.Image.radial_gradient("L")
pillow_example_radial_gradient_pixel := pillow_example_radial_gradient.getpixel([127, 127])
pillow_example_mandelbrot := stdlib.pillow.Image.effect_mandelbrot([4, 3], [-2.0, -1.0, 1.0, 1.0], 10)
pillow_example_mandelbrot_pixel := pillow_example_mandelbrot.getpixel([0, 0])
pillow_example_noise := stdlib.pillow.Image.effect_noise([3, 2], 0)
pillow_example_noise_size := pillow_example_noise.size
pillow_example_noise_pixel := pillow_example_noise.getpixel([0, 0])
pillow_example_noise_random := stdlib.pillow.Image.effect_noise([2, 2], 10)
pillow_example_noise_random_pixel := pillow_example_noise_random.getpixel([0, 0])
pillow_example_image := stdlib.pillow.Image.new("RGB", [4, 3], [24, 40, 72])
pillow_example_is_image := stdlib.pillow.Image.isImageType(pillow_example_image)
pillow_example_image_exif := pillow_example_image.getexif()
pillow_example_image_exif[274] := 3
pillow_example_image_exif_same := pillow_example_image.getexif() == pillow_example_image_exif
pillow_example_image_exif_orientation := pillow_example_image.getexif()[274]
pillow_example_image.putpixel([1, 1], [230, 80, 40])
pillow_example_image.putpixel([2, 1], [255, 210, 80])
pillow_example_pixel := pillow_example_image.getpixel([1, 1])
pillow_example_bands := pillow_example_image.getbands()
pillow_example_bbox := pillow_example_image.getbbox()
pillow_example_extrema := pillow_example_image.getextrema()
pillow_example_colors := pillow_example_image.getcolors()
pillow_example_histogram := pillow_example_image.histogram()
pillow_example_histogram_prefix := [pillow_example_histogram[1], pillow_example_histogram[2], pillow_example_histogram[3]]
pillow_example_stat := stdlib.pillow.ImageStat.Stat(pillow_example_image)
pillow_example_stat_count := pillow_example_stat.count
pillow_example_stat_mean := pillow_example_stat.mean
pillow_example_stat_extrema := pillow_example_stat.extrema
pillow_example_sequence_iterator := stdlib.pillow.ImageSequence.Iterator(pillow_example_image)
pillow_example_sequence_first := pillow_example_sequence_iterator.next()
pillow_example_sequence_first_pixel := pillow_example_sequence_first.getpixel([0, 0])
pillow_example_sequence_frames := stdlib.pillow.ImageSequence.all_frames(pillow_example_image)
pillow_example_sequence_frame_count := pillow_example_sequence_frames.Length
pillow_example_sequence_frame_pixel := pillow_example_sequence_frames[1].getpixel([0, 0])
pillow_example_sequence_gray_frames := stdlib.pillow.ImageSequence.all_frames(pillow_example_image, (frame) => frame.convert("L"))
pillow_example_sequence_gray_pixel := pillow_example_sequence_gray_frames[1].getpixel([0, 0])
pillow_example_entropy := pillow_example_image.entropy()
pillow_example_projection := pillow_example_image.getprojection()
pillow_example_data := pillow_example_image.getdata()
pillow_example_red_band := pillow_example_image.getdata(0)
pillow_example_bytes := pillow_example_image.tobytes()
pillow_example_readonly := pillow_example_image.readonly
pillow_example_format_description := pillow_example_image.format_description
pillow_example_draft := pillow_example_image.draft("L", [1, 1])
pillow_example_child_images := pillow_example_image.get_child_images()
pillow_example_xmp := pillow_example_image.getxmp()
pillow_example_capsule_repr := pillow_example_image.getim().__Repr()
pillow_example_core_repr := pillow_example_image.im.__Repr()
pillow_example_frombytes := stdlib.pillow.Image.new("RGB", [2, 1])
pillow_example_frombytes.frombytes([1, 2, 3, 4, 5, 6])
pillow_example_frombytes_data := pillow_example_frombytes.getdata()
pillow_example_module_frombytes := stdlib.pillow.Image.frombytes("RGB", [2, 1], [1, 2, 3, 4, 5, 6], "raw", "BGR")
pillow_example_module_frombytes_data := pillow_example_module_frombytes.getdata()
pillow_example_module_frombuffer := stdlib.pillow.Image.frombuffer("L", [3, 1], [10, 20, 30], "raw", "L", 0, 1)
pillow_example_module_frombuffer_readonly := pillow_example_module_frombuffer.readonly
pillow_example_module_frombuffer_data := pillow_example_module_frombuffer.getdata()
pillow_example_bitmap := stdlib.pillow.Image.new("1", [8, 1], 1)
pillow_example_bitmap.putpixel([3, 0], 0)
pillow_example_bitmap_xbm := pillow_example_bitmap.tobitmap("mask")
pillow_example_putdata := stdlib.pillow.Image.new("L", [3, 1], 0)
pillow_example_putdata.putdata([1, 2, 3], 10, 5)
pillow_example_putdata_data := pillow_example_putdata.getdata()
pillow_example_palette := stdlib.pillow.Image.new("P", [3, 1], 0)
pillow_example_palette.putdata([0, 1, 2])
pillow_example_palette.putpalette([0, 0, 0, 10, 20, 30, 200, 210, 220])
pillow_example_palette_rgb := pillow_example_palette.getpalette("RGB")
pillow_example_palette_rgba := pillow_example_palette.getpalette("RGBA")
pillow_example_palette.info["transparency"] := 1
pillow_example_palette_has_transparency_before := pillow_example_palette.has_transparency_data
pillow_example_palette.apply_transparency()
pillow_example_palette_has_transparency_after := pillow_example_palette.has_transparency_data
pillow_example_palette_transparent_rgba := pillow_example_palette.getpalette("RGBA")
pillow_example_remapped_palette := pillow_example_palette.remap_palette([2, 0])
pillow_example_remapped_palette_data := pillow_example_remapped_palette.getdata()
pillow_example_remapped_palette_rgb := pillow_example_remapped_palette.getpalette("RGB")
pillow_example_string_color_image := stdlib.pillow.Image.new("RGBA", [2, 1], "#11223344")
pillow_example_string_color_pixel := pillow_example_string_color_image.getpixel([0, 0])
pillow_example_copy := pillow_example_image.copy()
pillow_example_copy.putpixel([0, 0], [255, 255, 255])
pillow_example_copy_source_pixel := pillow_example_image.getpixel([0, 0])
pillow_example_copy_pixel := pillow_example_copy.getpixel([0, 0])
pillow_example_crop := pillow_example_image.crop([1, 0, 4, 3])
pillow_example_crop_size := pillow_example_crop.size
pillow_example_resize := pillow_example_image.resize([8, 6])
pillow_example_resize_size := pillow_example_resize.size
pillow_example_transform := pillow_example_image.transform([2, 2], stdlib.pillow.Image.Transform.EXTENT, [1, 0, 4, 3])
pillow_example_transform_size := pillow_example_transform.size
pillow_example_transform_pixel := pillow_example_transform.getpixel([0, 0])
pillow_example_transform_descriptor := stdlib.pillow.ImageTransform.ExtentTransform([1, 0, 4, 3])
pillow_example_transform_descriptor_data := pillow_example_transform_descriptor.getdata()
pillow_example_transform_descriptor_image := pillow_example_transform_descriptor.transform([2, 2], pillow_example_image)
pillow_example_transform_descriptor_pixel := pillow_example_transform_descriptor_image.getpixel([0, 0])
pillow_example_transform_mesh := stdlib.pillow.ImageTransform.MeshTransform([
    [[0, 0, 2, 2], [2, 0, 2, 2, 4, 3, 4, 0]]
])
pillow_example_transform_mesh_image := pillow_example_transform_mesh.transform([2, 2], pillow_example_image)
pillow_example_transform_mesh_pixel := pillow_example_transform_mesh_image.getpixel([0, 0])
pillow_example_image_path := stdlib.pillow.ImagePath.Path([0, 1, 2, 3, 4, 5])
pillow_example_image_path_pairs := pillow_example_image_path.tolist()
pillow_example_image_path_flat := pillow_example_image_path.tolist(true)
pillow_example_image_path_bbox := pillow_example_image_path.getbbox()
pillow_example_image_path_compact := pillow_example_image_path.compact(3)
pillow_example_image_path.transform([1, 0, 1, 0, 1, 1])
pillow_example_image_path_transformed := pillow_example_image_path.tolist()
pillow_example_image_path_mapped := stdlib.pillow.ImagePath.Path([0, 1, 2, 3, 4, 5])
pillow_example_image_path_map_result := pillow_example_image_path_mapped.map((x, y) => [x * 2, y * 3])
pillow_example_image_path_mapped_pairs := pillow_example_image_path_mapped.tolist()
pillow_example_math_a := stdlib.pillow.Image.new("L", [3, 1])
pillow_example_math_a.putdata([10, 100, 250])
pillow_example_math_b := stdlib.pillow.Image.new("L", [3, 1])
pillow_example_math_b.putdata([20, 160, 30])
pillow_example_math_context := Map("A", pillow_example_math_a, "B", pillow_example_math_b)
pillow_example_math_sum := stdlib.pillow.ImageMath.unsafe_eval("A+B", pillow_example_math_context)
pillow_example_math_sum_mode := pillow_example_math_sum.mode
pillow_example_math_sum_pixels := pillow_example_math_sum.getdata()
pillow_example_math_compare := stdlib.pillow.ImageMath.unsafe_eval("notequal(A,B)", pillow_example_math_context)
pillow_example_math_compare_pixels := pillow_example_math_compare.getdata()
pillow_example_math_lambda := stdlib.pillow.ImageMath.lambda_eval((args) => 1 + args["x"], Map("x", 2))
pillow_example_math_eval := stdlib.pillow.ImageMath.eval("max(A, 60)", pillow_example_math_context)
pillow_example_math_eval_pixels := pillow_example_math_eval.getdata()
pillow_example_font := stdlib.pillow.ImageFont.load_default()
pillow_example_font_bbox := pillow_example_font.getbbox("Hello")
pillow_example_font_length := pillow_example_font.getlength("Hello")
pillow_example_font_mask := pillow_example_font.getmask("Hello")
pillow_example_font_mask_size := pillow_example_font_mask.size
pillow_example_font_mask_bbox := pillow_example_font_mask.getbbox()
pillow_example_base_font := stdlib.pillow.ImageFont.ImageFont()
pillow_example_base_font_type := pillow_example_base_font.AhkStdlibTypeName
pillow_example_base_font_has_font := HasProp(pillow_example_base_font, "font")
pillow_example_base_font_error_message := ""
try {
    pillow_example_base_font_bbox := pillow_example_base_font.getbbox("A")
} catch as pillow_example_base_font_error {
    pillow_example_base_font_error_message := pillow_example_base_font_error.Message
}
pillow_example_bitmap_font := stdlib.pillow.ImageFont.load_default_imagefont()
pillow_example_bitmap_font_bbox := pillow_example_bitmap_font.getbbox("Hello")
pillow_example_bitmap_font_length := pillow_example_bitmap_font.getlength("Hello")
pillow_example_bitmap_font_mask := pillow_example_bitmap_font.getmask("Hello")
pillow_example_bitmap_font_mask_size := pillow_example_bitmap_font_mask.size
pillow_example_bitmap_font_mask_bbox := pillow_example_bitmap_font_mask.getbbox()
pillow_example_loaded_font_root := pillow_example_output_dir "\mini-font"
PillowExampleWriteMiniPilFont(pillow_example_loaded_font_root)
pillow_example_loaded_font := stdlib.pillow.ImageFont.load(pillow_example_loaded_font_root ".pil")
pillow_example_loaded_font_bbox := pillow_example_loaded_font.getbbox("AB")
pillow_example_loaded_font_length := pillow_example_loaded_font.getlength("AB")
pillow_example_loaded_font_mask := pillow_example_loaded_font.getmask("AB")
pillow_example_loaded_font_mask_size := pillow_example_loaded_font_mask.size
pillow_example_loaded_font_mask_bbox := pillow_example_loaded_font_mask.getbbox()
pillow_example_loaded_path_font := stdlib.pillow.ImageFont.load_path(pillow_example_loaded_font_root ".pil")
pillow_example_loaded_path_font_bbox := pillow_example_loaded_path_font.getbbox("A")
pillow_example_loaded_path_font_length := pillow_example_loaded_path_font.getlength("A")
pillow_example_font_is_path_string := stdlib.pillow.ImageFont.is_path("example.pil")
pillow_example_font_is_path_stream := stdlib.pillow.ImageFont.is_path(stdlib.io.BytesIO([120]))
pillow_example_font_deferred_source := RuntimeError("deferred boom", -1)
pillow_example_font_deferred := stdlib.pillow.ImageFont.DeferredError.new(pillow_example_font_deferred_source)
pillow_example_font_deferred_error_type := ""
pillow_example_font_deferred_error_message := ""
try {
    pillow_example_font_deferred_value := pillow_example_font_deferred.anything
} catch as pillow_example_font_deferred_error {
    pillow_example_font_deferred_error_type := Type(pillow_example_font_deferred_error)
    pillow_example_font_deferred_error_message := pillow_example_font_deferred_error.Message
}
pillow_example_transposed_font := stdlib.pillow.ImageFont.TransposedFont(pillow_example_font, stdlib.pillow.Image.Transpose.FLIP_LEFT_RIGHT)
pillow_example_transposed_font_bbox := pillow_example_transposed_font.getbbox("Hello")
pillow_example_transposed_font_length := pillow_example_transposed_font.getlength("Hello")
pillow_example_rotated_font := stdlib.pillow.ImageFont.TransposedFont(pillow_example_font, stdlib.pillow.Image.Transpose.ROTATE_90)
pillow_example_rotated_font_bbox := pillow_example_rotated_font.getbbox("Hello")
pillow_example_rotated_font_mask_size := pillow_example_rotated_font.getmask("Hello").size
pillow_example_truetype_font_path := A_WinDir "\Fonts\arial.ttf"
pillow_example_truetype_font_name := stdlib.None
pillow_example_truetype_font_metrics := stdlib.None
pillow_example_direct_freetype_bbox := stdlib.None
pillow_example_direct_freetype_length := stdlib.None
pillow_example_truetype_variant_metrics := stdlib.None
pillow_example_truetype_variant_bbox := stdlib.None
pillow_example_truetype_transposed_bbox := stdlib.None
if FileExist(pillow_example_truetype_font_path) {
    pillow_example_truetype_font := stdlib.pillow.ImageFont.truetype(pillow_example_truetype_font_path, 12)
    pillow_example_truetype_font_name := pillow_example_truetype_font.getname()
    pillow_example_truetype_font_metrics := pillow_example_truetype_font.getmetrics()
    pillow_example_direct_freetype := stdlib.pillow.ImageFont.FreeTypeFont(pillow_example_truetype_font_path)
    pillow_example_direct_freetype_bbox := pillow_example_direct_freetype.getbbox("Hi")
    pillow_example_direct_freetype_length := pillow_example_direct_freetype.getlength("Hi")
    pillow_example_truetype_variant := pillow_example_truetype_font.font_variant(stdlib.None, 18)
    pillow_example_truetype_variant_metrics := pillow_example_truetype_variant.getmetrics()
    pillow_example_truetype_variant_bbox := pillow_example_truetype_variant.getbbox("Hi")
    pillow_example_truetype_transposed := stdlib.pillow.ImageFont.TransposedFont(pillow_example_truetype_font, stdlib.pillow.Image.Transpose.ROTATE_90)
    pillow_example_truetype_transposed_bbox := pillow_example_truetype_transposed.getbbox("Hi")
}
pillow_example_quantized := pillow_example_image.quantize(2, stdlib.pillow.Image.Quantize.MEDIANCUT, 0, unset, stdlib.pillow.Image.Dither.NONE)
pillow_example_quantized_mode := pillow_example_quantized.mode
pillow_example_quantized_data := pillow_example_quantized.getdata()
pillow_example_quantized_palette := pillow_example_quantized.getpalette("RGB")
pillow_example_reduce := pillow_example_image.reduce(2)
pillow_example_reduce_size := pillow_example_reduce.size
pillow_example_reduce_pixel := pillow_example_reduce.getpixel([0, 0])
pillow_example_thumbnail := pillow_example_image.copy()
pillow_example_thumbnail.thumbnail([2, 2])
pillow_example_thumbnail_size := pillow_example_thumbnail.size
pillow_example_thumbnail_pixel := pillow_example_thumbnail.getpixel([0, 0])
pillow_example_spread := pillow_example_image.effect_spread(2)
pillow_example_spread_size := pillow_example_spread.size
pillow_example_spread_pixel := pillow_example_spread.getpixel([1, 1])
pillow_example_save := pillow_example_image.save(pillow_example_path)
pillow_example_opened := stdlib.pillow.Image.open(pillow_example_path)
pillow_example_opened_format := pillow_example_opened.format
pillow_example_opened_mode := pillow_example_opened.mode
pillow_example_opened_size := pillow_example_opened.size
pillow_example_opened_pixel := pillow_example_opened.getpixel([1, 1])
pillow_example_opened_readonly := pillow_example_opened.readonly
pillow_example_opened_format_description := pillow_example_opened.format_description
pillow_example_opened_frame := pillow_example_opened.tell()
pillow_example_opened_seek := pillow_example_opened.seek(0)
pillow_example_opened_verify := pillow_example_opened.verify()

pillow_example_gray := stdlib.pillow.Image.new("L", [2, 1], 12)
pillow_example_gray.putpixel([1, 0], 240)
pillow_example_gray_pixels := [pillow_example_gray.getpixel([0, 0]), pillow_example_gray.getpixel([1, 0])]
pillow_example_gray_tiff_path := pillow_example_output_dir "\pillow_gray.tif"
pillow_example_gray_tiff_save := pillow_example_gray.save(pillow_example_gray_tiff_path)
pillow_example_gray_tiff_opened := stdlib.pillow.Image.open(pillow_example_gray_tiff_path)
pillow_example_gray_tiff_format := pillow_example_gray_tiff_opened.format
pillow_example_gray_tiff_description := pillow_example_gray_tiff_opened.format_description
pillow_example_gray_tiff_mode := pillow_example_gray_tiff_opened.mode
pillow_example_gray_tiff_pixels := pillow_example_gray_tiff_opened.getdata()
pillow_example_gray_tiff_close := pillow_example_gray_tiff_opened.close()
pillow_example_gray_tiff_memory := stdlib.io.BytesIO()
pillow_example_gray_tiff_memory_save := pillow_example_gray.save(pillow_example_gray_tiff_memory, "TIFF")
pillow_example_gray_tiff_memory_bytes := pillow_example_gray_tiff_memory.getvalue()
pillow_example_gray_tiff_memory_prefix := [pillow_example_gray_tiff_memory_bytes[1], pillow_example_gray_tiff_memory_bytes[2], pillow_example_gray_tiff_memory_bytes[3], pillow_example_gray_tiff_memory_bytes[4]]
pillow_example_gray_tiff_memory_opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pillow_example_gray_tiff_memory_bytes), "r", ["TIFF"])
pillow_example_gray_tiff_memory_mode := pillow_example_gray_tiff_memory_opened.mode
pillow_example_gray_tiff_memory_pixels := pillow_example_gray_tiff_memory_opened.getdata()
pillow_example_gray_tiff_memory_close := pillow_example_gray_tiff_memory_opened.close()
pillow_example_rgba := stdlib.pillow.Image.new("RGBA", [2, 1], [1, 2, 3, 4])
pillow_example_rgba.putpixel([1, 0], [250, 20, 30, 128])
pillow_example_rgba_pixels := [pillow_example_rgba.getpixel([0, 0]), pillow_example_rgba.getpixel([1, 0])]
pillow_example_rgba_png_path := pillow_example_output_dir "\pillow_rgba.png"
pillow_example_rgba.save(pillow_example_rgba_png_path)
pillow_example_opened_rgba := stdlib.pillow.Image.open(pillow_example_rgba_png_path)
pillow_example_opened_rgba_mode := pillow_example_opened_rgba.mode
pillow_example_opened_rgba_pixel := pillow_example_opened_rgba.getpixel([1, 0])
pillow_example_bmp_path := pillow_example_output_dir "\pillow_core.bmp"
pillow_example_jpeg_path := pillow_example_output_dir "\pillow_core.jpg"
pillow_example_save_bmp := pillow_example_image.save(pillow_example_bmp_path)
pillow_example_save_jpeg := pillow_example_image.save(pillow_example_jpeg_path)
pillow_example_builtin_memory_png := stdlib.io.BytesIO()
pillow_example_builtin_memory_png_result := pillow_example_image.save(pillow_example_builtin_memory_png, "PNG")
pillow_example_builtin_memory_png_bytes := pillow_example_builtin_memory_png.getvalue()
pillow_example_builtin_memory_png_prefix := [pillow_example_builtin_memory_png_bytes[1], pillow_example_builtin_memory_png_bytes[2], pillow_example_builtin_memory_png_bytes[3], pillow_example_builtin_memory_png_bytes[4]]
pillow_example_builtin_memory_png_closed := pillow_example_builtin_memory_png.closed
pillow_example_builtin_memory_png_reader := stdlib.io.BytesIO(pillow_example_builtin_memory_png_bytes)
pillow_example_builtin_memory_png_opened := stdlib.pillow.Image.open(pillow_example_builtin_memory_png_reader, "r", ["PNG"])
pillow_example_builtin_memory_png_opened_format := pillow_example_builtin_memory_png_opened.format
pillow_example_builtin_memory_png_opened_pixel := pillow_example_builtin_memory_png_opened.getpixel([1, 1])
pillow_example_builtin_memory_png_reader_closed := pillow_example_builtin_memory_png_reader.closed
pillow_example_parser := stdlib.pillow.ImageFile.Parser()
pillow_example_parser.feed(PillowExampleArraySlice(pillow_example_builtin_memory_png_bytes, 1, 8))
pillow_example_parser.feed(PillowExampleArraySlice(pillow_example_builtin_memory_png_bytes, 9, pillow_example_builtin_memory_png_bytes.Length))
pillow_example_parser_image := pillow_example_parser.close()
pillow_example_parser_format := pillow_example_parser_image.format
pillow_example_parser_pixel := pillow_example_parser_image.getpixel([1, 1])
pillow_example_opened_bmp := stdlib.pillow.Image.open(pillow_example_bmp_path)
pillow_example_opened_jpeg := stdlib.pillow.Image.open(pillow_example_jpeg_path)
pillow_example_opened_bmp_format := pillow_example_opened_bmp.format
pillow_example_opened_jpeg_format := pillow_example_opened_jpeg.format
pillow_example_luma := pillow_example_image.convert("L")
pillow_example_luma_pixel := pillow_example_luma.getpixel([1, 1])
pillow_example_alpha := pillow_example_image.convert("RGBA")
pillow_example_alpha_pixel := pillow_example_alpha.getpixel([1, 1])
pillow_example_flipped := pillow_example_image.transpose(stdlib.pillow.Image.Transpose.FLIP_LEFT_RIGHT)
pillow_example_flipped_pixel := pillow_example_flipped.getpixel([0, 1])
pillow_example_rotated := pillow_example_image.rotate(90, { expand: true })
pillow_example_rotated_size := pillow_example_rotated.size
pillow_example_rotated_pixel := pillow_example_rotated.getpixel([1, 0])
pillow_example_blend_target := stdlib.pillow.Image.new("RGB", [4, 3], [210, 220, 230])
pillow_example_blended := stdlib.pillow.Image.blend(pillow_example_image, pillow_example_blend_target, 0.25)
pillow_example_blended_pixel := pillow_example_blended.getpixel([1, 1])
pillow_example_mask := stdlib.pillow.Image.new("L", [4, 3], 0)
pillow_example_mask.putpixel([1, 1], 128)
pillow_example_mask.putpixel([2, 1], 255)
pillow_example_masked_entropy := pillow_example_image.entropy(pillow_example_mask)
pillow_example_composite := stdlib.pillow.Image.composite(pillow_example_image, pillow_example_blend_target, pillow_example_mask)
pillow_example_composite_pixels := [
    pillow_example_composite.getpixel([0, 1]),
    pillow_example_composite.getpixel([1, 1]),
    pillow_example_composite.getpixel([2, 1])
]
pillow_example_alpha_base := stdlib.pillow.Image.new("RGBA", [2, 1], [10, 20, 30, 40])
pillow_example_alpha_overlay := stdlib.pillow.Image.new("RGBA", [2, 1], [210, 220, 230, 240])
pillow_example_alpha_overlay.putpixel([1, 0], [0, 10, 20, 30])
pillow_example_alpha_composite := stdlib.pillow.Image.alpha_composite(pillow_example_alpha_base, pillow_example_alpha_overlay)
pillow_example_alpha_composite_pixels := [
    pillow_example_alpha_composite.getpixel([0, 0]),
    pillow_example_alpha_composite.getpixel([1, 0])
]
pillow_example_alpha_instance_base := stdlib.pillow.Image.new("RGBA", [3, 2], [0, 0, 0, 0])
pillow_example_alpha_instance_overlay := stdlib.pillow.Image.new("RGBA", [2, 2], [0, 0, 0, 0])
pillow_example_alpha_instance_overlay.putpixel([1, 0], [200, 10, 20, 128])
pillow_example_alpha_instance_overlay.putpixel([1, 1], [0, 200, 20, 255])
pillow_example_alpha_instance_result := pillow_example_alpha_instance_base.alpha_composite(pillow_example_alpha_instance_overlay, [0, 0], [1, 0])
pillow_example_alpha_instance_pixels := [
    pillow_example_alpha_instance_base.getpixel([0, 0]),
    pillow_example_alpha_instance_base.getpixel([0, 1])
]
pillow_example_paste_target := stdlib.pillow.Image.new("RGB", [4, 3], [10, 20, 30])
pillow_example_paste_target.paste([200, 100, 50], [1, 1, 3, 3])
pillow_example_paste_patch := stdlib.pillow.Image.new("RGB", [2, 1], [0, 10, 20])
pillow_example_paste_mask := stdlib.pillow.Image.new("L", [2, 1], 128)
pillow_example_paste_target.paste(pillow_example_paste_patch, [1, 0], pillow_example_paste_mask)
pillow_example_paste_pixels := [
    pillow_example_paste_target.getpixel([1, 0]),
    pillow_example_paste_target.getpixel([1, 1])
]
pillow_example_green_channel := pillow_example_image.getchannel("G")
pillow_example_green_pixels := [
    pillow_example_green_channel.getpixel([1, 1]),
    pillow_example_green_channel.getpixel([2, 1])
]
pillow_example_putalpha_image := pillow_example_image.copy()
pillow_example_putalpha_image.putalpha(160)
pillow_example_putalpha_mode := pillow_example_putalpha_image.mode
pillow_example_putalpha_pixel := pillow_example_putalpha_image.getpixel([1, 1])
pillow_example_split_bands := pillow_example_image.split()
pillow_example_split_green_pixel := pillow_example_split_bands[2].getpixel([1, 1])
pillow_example_merged := stdlib.pillow.Image.merge("RGB", pillow_example_split_bands)
pillow_example_merged_pixel := pillow_example_merged.getpixel([1, 1])
pillow_example_point_table := []
loop 256
    pillow_example_point_table.Push(A_Index - 1)
pillow_example_point_table[81] := 12
pillow_example_point_table[211] := 240
pillow_example_point := pillow_example_luma.point(pillow_example_point_table)
pillow_example_point_pixel := pillow_example_point.getpixel([1, 1])
pillow_example_eval := stdlib.pillow.Image.eval(pillow_example_luma, (value) => 255 - value)
pillow_example_eval_pixel := pillow_example_eval.getpixel([1, 1])
pillow_example_rgb_point := pillow_example_image.point((value) => value + 5)
pillow_example_rgb_point_pixel := pillow_example_rgb_point.getpixel([1, 1])
pillow_example_sharpened := pillow_example_image.filter(stdlib.pillow.ImageFilter.SHARPEN)
pillow_example_sharpened_pixel := pillow_example_sharpened.getpixel([1, 1])
pillow_example_kernel := stdlib.pillow.ImageFilter.Kernel([3, 3], [0, 0, 0, 0, 1, 0, 0, 0, 0])
pillow_example_kernel_image := pillow_example_luma.filter(pillow_example_kernel)
pillow_example_kernel_pixel := pillow_example_kernel_image.getpixel([1, 1])
pillow_example_boxblur := pillow_example_luma.filter(stdlib.pillow.ImageFilter.BoxBlur(1))
pillow_example_boxblur_pixel := pillow_example_boxblur.getpixel([1, 1])
pillow_example_boxblur_horizontal := pillow_example_luma.filter(stdlib.pillow.ImageFilter.BoxBlur([1, 0]))
pillow_example_boxblur_horizontal_pixel := pillow_example_boxblur_horizontal.getpixel([1, 1])
pillow_example_gaussianblur := pillow_example_luma.filter(stdlib.pillow.ImageFilter.GaussianBlur(1))
pillow_example_gaussianblur_pixel := pillow_example_gaussianblur.getpixel([1, 1])
pillow_example_unsharpmask := pillow_example_luma.filter(stdlib.pillow.ImageFilter.UnsharpMask(1, 150, 0))
pillow_example_unsharpmask_pixel := pillow_example_unsharpmask.getpixel([1, 1])
pillow_example_lut := stdlib.pillow.ImageFilter.Color3DLUT.generate(2, (r, g, b) => [1 - r, g, b])
pillow_example_lut_image := pillow_example_image.filter(pillow_example_lut)
pillow_example_lut_pixel := pillow_example_lut_image.getpixel([1, 1])
pillow_example_rank_min := pillow_example_luma.filter(stdlib.pillow.ImageFilter.MinFilter(3))
pillow_example_rank_min_pixel := pillow_example_rank_min.getpixel([1, 1])
pillow_example_rank_max := pillow_example_luma.filter(stdlib.pillow.ImageFilter.MaxFilter(3))
pillow_example_rank_max_pixel := pillow_example_rank_max.getpixel([1, 1])
pillow_example_rank_median := pillow_example_luma.filter(stdlib.pillow.ImageFilter.MedianFilter(3))
pillow_example_rank_median_pixel := pillow_example_rank_median.getpixel([1, 1])
pillow_example_rank_custom := pillow_example_luma.filter(stdlib.pillow.ImageFilter.RankFilter(3, 4))
pillow_example_rank_custom_pixel := pillow_example_rank_custom.getpixel([1, 1])
pillow_example_rank_mode := pillow_example_luma.filter(stdlib.pillow.ImageFilter.ModeFilter(3))
pillow_example_rank_mode_pixel := pillow_example_rank_mode.getpixel([1, 1])
pillow_example_chops_add := stdlib.pillow.ImageChops.add(pillow_example_image, pillow_example_blend_target)
pillow_example_chops_add_pixel := pillow_example_chops_add.getpixel([1, 1])
pillow_example_chops_multiply := stdlib.pillow.ImageChops.multiply(pillow_example_image, pillow_example_blend_target)
pillow_example_chops_multiply_pixel := pillow_example_chops_multiply.getpixel([1, 1])
pillow_example_chops_offset := stdlib.pillow.ImageChops.offset(pillow_example_image, 1, -1)
pillow_example_chops_offset_pixel := pillow_example_chops_offset.getpixel([0, 0])
pillow_example_chops_constant := stdlib.pillow.ImageChops.constant(pillow_example_luma, 77)
pillow_example_chops_constant_pixel := pillow_example_chops_constant.getpixel([0, 0])
pillow_example_chops_blend := stdlib.pillow.ImageChops.blend(pillow_example_image, pillow_example_blend_target, 0.4)
pillow_example_chops_blend_pixel := pillow_example_chops_blend.getpixel([1, 1])
pillow_example_chops_composite := stdlib.pillow.ImageChops.composite(pillow_example_image, pillow_example_blend_target, pillow_example_mask)
pillow_example_chops_composite_pixel := pillow_example_chops_composite.getpixel([1, 1])
pillow_example_chops_overlay := stdlib.pillow.ImageChops.overlay(pillow_example_image, pillow_example_blend_target)
pillow_example_chops_overlay_pixel := pillow_example_chops_overlay.getpixel([1, 1])
pillow_example_chops_hard_light := stdlib.pillow.ImageChops.hard_light(pillow_example_image, pillow_example_blend_target)
pillow_example_chops_hard_light_pixel := pillow_example_chops_hard_light.getpixel([1, 1])
pillow_example_chops_soft_light := stdlib.pillow.ImageChops.soft_light(pillow_example_image, pillow_example_blend_target)
pillow_example_chops_soft_light_pixel := pillow_example_chops_soft_light.getpixel([1, 1])
pillow_example_chops_bits_a := stdlib.pillow.Image.new("1", [2, 1], 0)
pillow_example_chops_bits_a.putpixel([0, 0], 1)
pillow_example_chops_bits_a.putpixel([1, 0], 255)
pillow_example_chops_bits_b := stdlib.pillow.Image.new("1", [2, 1], 0)
pillow_example_chops_bits_b.putpixel([1, 0], 255)
pillow_example_chops_and := stdlib.pillow.ImageChops.logical_and(pillow_example_chops_bits_a, pillow_example_chops_bits_b)
pillow_example_chops_or := stdlib.pillow.ImageChops.logical_or(pillow_example_chops_bits_a, pillow_example_chops_bits_b)
pillow_example_chops_xor := stdlib.pillow.ImageChops.logical_xor(pillow_example_chops_bits_a, pillow_example_chops_bits_b)
pillow_example_chops_logical_pixels := [
    pillow_example_chops_and.getpixel([0, 0]),
    pillow_example_chops_or.getpixel([0, 0]),
    pillow_example_chops_xor.getpixel([0, 0])
]
pillow_example_ops_invert := stdlib.pillow.ImageOps.invert(pillow_example_luma)
pillow_example_ops_invert_pixel := pillow_example_ops_invert.getpixel([1, 1])
pillow_example_ops_mirror := stdlib.pillow.ImageOps.mirror(pillow_example_image)
pillow_example_ops_mirror_pixel := pillow_example_ops_mirror.getpixel([0, 1])
pillow_example_ops_grayscale := stdlib.pillow.ImageOps.grayscale(pillow_example_alpha)
pillow_example_ops_grayscale_pixel := pillow_example_ops_grayscale.getpixel([1, 1])
pillow_example_ops_expand := stdlib.pillow.ImageOps.expand(pillow_example_image, 1, [4, 5, 6])
pillow_example_ops_expand_size := pillow_example_ops_expand.size
pillow_example_ops_crop := stdlib.pillow.ImageOps.crop(pillow_example_image, [1, 0, 1, 1])
pillow_example_ops_crop_size := pillow_example_ops_crop.size
pillow_example_ops_contain := stdlib.pillow.ImageOps.contain(pillow_example_image, [2, 2])
pillow_example_ops_contain_size := pillow_example_ops_contain.size
pillow_example_ops_cover := stdlib.pillow.ImageOps.cover(pillow_example_image, [2, 2])
pillow_example_ops_cover_size := pillow_example_ops_cover.size
pillow_example_ops_scale := stdlib.pillow.ImageOps.scale(pillow_example_image, 0.5)
pillow_example_ops_scale_size := pillow_example_ops_scale.size
pillow_example_ops_pad := stdlib.pillow.ImageOps.pad(pillow_example_image, [6, 4], unset, [1, 2, 3])
pillow_example_ops_pad_size := pillow_example_ops_pad.size
pillow_example_ops_fit := stdlib.pillow.ImageOps.fit(pillow_example_image, [2, 2])
pillow_example_ops_fit_size := pillow_example_ops_fit.size
pillow_example_ops_autocontrast := stdlib.pillow.ImageOps.autocontrast(pillow_example_luma)
pillow_example_ops_autocontrast_pixel := pillow_example_ops_autocontrast.getpixel([1, 1])
pillow_example_ops_equalize := stdlib.pillow.ImageOps.equalize(pillow_example_luma)
pillow_example_ops_equalize_pixel := pillow_example_ops_equalize.getpixel([1, 1])
pillow_example_ops_colorize := stdlib.pillow.ImageOps.colorize(pillow_example_luma, "black", "gold")
pillow_example_ops_colorize_pixel := pillow_example_ops_colorize.getpixel([1, 1])
pillow_example_ops_deform := stdlib.pillow.ImageOps.deform(pillow_example_image, PillowExampleShiftMeshDeformer())
pillow_example_ops_deform_pixel := pillow_example_ops_deform.getpixel([0, 1])
pillow_example_exif_source := pillow_example_image.copy()
pillow_example_exif_source.getexif()[274] := 6
pillow_example_ops_exif_transpose := stdlib.pillow.ImageOps.exif_transpose(pillow_example_exif_source)
pillow_example_ops_exif_transpose_size := pillow_example_ops_exif_transpose.size
pillow_example_ops_exif_transpose_pixel := pillow_example_ops_exif_transpose.getpixel([0, 0])
pillow_example_enhance_brightness := stdlib.pillow.ImageEnhance.Brightness(pillow_example_image).enhance(1.25)
pillow_example_enhance_brightness_pixel := pillow_example_enhance_brightness.getpixel([1, 1])
pillow_example_enhance_color := stdlib.pillow.ImageEnhance.Color(pillow_example_image).enhance(0.4)
pillow_example_enhance_color_pixel := pillow_example_enhance_color.getpixel([1, 1])
pillow_example_enhance_contrast := stdlib.pillow.ImageEnhance.Contrast(pillow_example_image).enhance(1.4)
pillow_example_enhance_contrast_pixel := pillow_example_enhance_contrast.getpixel([1, 1])
pillow_example_enhance_sharpness := stdlib.pillow.ImageEnhance.Sharpness(pillow_example_image).enhance(1.2)
pillow_example_enhance_sharpness_pixel := pillow_example_enhance_sharpness.getpixel([1, 1])
pillow_example_draw_image := stdlib.pillow.Image.new("RGB", [4, 3], "black")
pillow_example_draw := stdlib.pillow.ImageDraw.Draw(pillow_example_draw_image)
pillow_example_draw.point([[0, 0], [1, 1]], "red")
pillow_example_draw.line([[0, 2], [3, 2]], "white", 1)
pillow_example_draw.rectangle([1, 0, 3, 1], unset, "green")
pillow_example_draw.polygon([[2, 0], [3, 1], [2, 1]], "blue")
pillow_example_draw.polygon([[0, 0], [3, 0], [1, 2]], unset, "yellow", 2)
pillow_example_draw.regular_polygon([[2, 1], 1], 3, 0, "#204060", "white", 1)
pillow_example_bitmap_mask := stdlib.pillow.Image.new("L", [2, 2], 0)
pillow_example_bitmap_mask.putpixel([0, 0], 255)
pillow_example_bitmap_mask.putpixel([1, 1], 128)
pillow_example_draw.bitmap([1, 0], pillow_example_bitmap_mask, "#804020")
pillow_example_draw.ellipse([0, 0, 3, 2], unset, "yellow", 1)
pillow_example_draw.arc([0, 0, 3, 2], 0, 180, "white", 1)
pillow_example_draw.chord([0, 0, 3, 2], 180, 360, "purple")
pillow_example_draw.pieslice([0, 0, 3, 2], 90, 270, unset, "orange", 1)
pillow_example_draw.circle([1, 1], 1, unset, "lime", 1)
pillow_example_draw.rounded_rectangle([0, 0, 3, 2], 1, "#102030", "silver", 1)
stdlib.pillow.ImageDraw.floodfill(pillow_example_draw_image, [0, 0], [24, 48, 96])
pillow_example_draw_pixel := pillow_example_draw_image.getpixel([2, 1])
pillow_example_draw_ellipse_pixel := pillow_example_draw_image.getpixel([2, 0])
pillow_example_draw_pieslice_pixel := pillow_example_draw_image.getpixel([1, 1])
pillow_example_draw_rounded_pixel := pillow_example_draw_image.getpixel([1, 0])
pillow_example_draw_text_image := stdlib.pillow.Image.new("RGB", [24, 28], "black")
pillow_example_draw_text := stdlib.pillow.ImageDraw.Draw(pillow_example_draw_text_image)
pillow_example_draw_text_font := pillow_example_draw_text.getfont()
pillow_example_draw_text_bbox := pillow_example_draw_text.textbbox([1, 1], "Hi")
pillow_example_draw_text_length := pillow_example_draw_text.textlength("Hi")
pillow_example_draw_text_result := pillow_example_draw_text.text([1, 1], "Hi", "white")
pillow_example_draw_multiline_bbox := pillow_example_draw_text.multiline_textbbox([1, 1], "Hi`nA")
pillow_example_draw_multiline_result := pillow_example_draw_text.multiline_text([1, 1], "Hi`nA", "white")
pillow_example_draw_text_pixel := pillow_example_draw_text_image.getpixel([2, 3])
pillow_example_draw2_image := stdlib.pillow.Image.new("RGB", [5, 5], "black")
pillow_example_draw2_pen := stdlib.pillow.ImageDraw2.Pen("red")
pillow_example_draw2_wide_pen := stdlib.pillow.ImageDraw2.Pen("blue", 2)
pillow_example_draw2_brush := stdlib.pillow.ImageDraw2.Brush("green")
pillow_example_draw2 := stdlib.pillow.ImageDraw2.Draw(pillow_example_draw2_image)
pillow_example_draw2.line([0, 0, 4, 3], pillow_example_draw2_pen)
pillow_example_draw2.rectangle([1, 1, 3, 2], pillow_example_draw2_pen, pillow_example_draw2_brush)
pillow_example_draw2.ellipse([1, 1, 3, 3], pillow_example_draw2_wide_pen, pillow_example_draw2_brush)
pillow_example_draw2.polygon([1, 1, 3, 1, 2, 3], pillow_example_draw2_pen, pillow_example_draw2_brush)
pillow_example_draw2.arc([1, 1, 3, 3], pillow_example_draw2_pen, 0, 180)
pillow_example_draw2.chord([1, 1, 3, 3], pillow_example_draw2_pen, 0, 180, pillow_example_draw2_brush)
pillow_example_draw2.pieslice([1, 1, 3, 3], pillow_example_draw2_pen, 90, 270, pillow_example_draw2_brush)
pillow_example_draw2_transform_result := pillow_example_draw2.settransform([1, 1])
pillow_example_draw2_transform_matrix := pillow_example_draw2.transform
pillow_example_draw2_render_line := pillow_example_draw2.render("line", [0, 0, 2, 0], pillow_example_draw2_wide_pen)
pillow_example_draw2_render_rectangle := pillow_example_draw2.render("rectangle", [0, 0, 1, 1], pillow_example_draw2_pen, pillow_example_draw2_brush)
pillow_example_draw2_flushed := pillow_example_draw2.flush()
pillow_example_draw2_flushed_size := pillow_example_draw2_flushed.size
pillow_example_draw2_pixel := pillow_example_draw2_image.getpixel([2, 2])
pillow_example_draw2_text_image := stdlib.pillow.Image.new("RGB", [36, 18], "black")
pillow_example_draw2_font_path := A_WinDir "\Fonts\arial.ttf"
pillow_example_draw2_text_bbox := stdlib.None
pillow_example_draw2_text_length := stdlib.None
pillow_example_draw2_text_result := stdlib.None
pillow_example_draw2_text_pixel := pillow_example_draw2_text_image.getpixel([2, 3])
if FileExist(pillow_example_draw2_font_path) {
    pillow_example_draw2_font := stdlib.pillow.ImageDraw2.Font("red", pillow_example_draw2_font_path, 12)
    pillow_example_draw2_text_draw := stdlib.pillow.ImageDraw2.Draw(pillow_example_draw2_text_image)
    pillow_example_draw2_text_bbox := pillow_example_draw2_text_draw.textbbox([1, 1], "Hi", pillow_example_draw2_font)
    pillow_example_draw2_text_length := pillow_example_draw2_text_draw.textlength("Hi", pillow_example_draw2_font)
    pillow_example_draw2_text_result := pillow_example_draw2_text_draw.text([1, 1], "Hi", pillow_example_draw2_font)
    pillow_example_draw2_text_pixel := pillow_example_draw2_text_image.getpixel([2, 3])
}

pillow_example_draw2_text_image.close()
pillow_example_draw2_image.close()
pillow_example_draw_text_image.close()
pillow_example_bitmap_mask.close()
pillow_example_draw_image.close()
pillow_example_enhance_sharpness.close()
pillow_example_enhance_contrast.close()
pillow_example_enhance_color.close()
pillow_example_enhance_brightness.close()
pillow_example_ops_exif_transpose.close()
pillow_example_exif_source.close()
pillow_example_ops_deform.close()
pillow_example_ops_colorize.close()
pillow_example_ops_equalize.close()
pillow_example_ops_autocontrast.close()
pillow_example_ops_fit.close()
pillow_example_ops_pad.close()
pillow_example_ops_scale.close()
pillow_example_ops_cover.close()
pillow_example_ops_contain.close()
pillow_example_ops_crop.close()
pillow_example_ops_expand.close()
pillow_example_ops_grayscale.close()
pillow_example_ops_mirror.close()
pillow_example_ops_invert.close()
pillow_example_chops_xor.close()
pillow_example_chops_or.close()
pillow_example_chops_and.close()
pillow_example_chops_bits_b.close()
pillow_example_chops_bits_a.close()
pillow_example_chops_soft_light.close()
pillow_example_chops_hard_light.close()
pillow_example_chops_overlay.close()
pillow_example_chops_composite.close()
pillow_example_chops_blend.close()
pillow_example_chops_constant.close()
pillow_example_chops_offset.close()
pillow_example_chops_multiply.close()
pillow_example_chops_add.close()
pillow_example_rank_mode.close()
pillow_example_rank_custom.close()
pillow_example_rank_median.close()
pillow_example_rank_max.close()
pillow_example_rank_min.close()
pillow_example_lut_image.close()
pillow_example_unsharpmask.close()
pillow_example_gaussianblur.close()
pillow_example_boxblur_horizontal.close()
pillow_example_boxblur.close()
pillow_example_kernel_image.close()
pillow_example_sharpened.close()
pillow_example_rgb_point.close()
pillow_example_eval.close()
pillow_example_point.close()
pillow_example_merged.close()
for pillow_example_band in pillow_example_split_bands
    pillow_example_band.close()
pillow_example_putalpha_image.close()
pillow_example_green_channel.close()
pillow_example_paste_mask.close()
pillow_example_paste_patch.close()
pillow_example_paste_target.close()
pillow_example_alpha_composite.close()
pillow_example_alpha_instance_overlay.close()
pillow_example_alpha_instance_base.close()
pillow_example_alpha_overlay.close()
pillow_example_alpha_base.close()
pillow_example_composite.close()
pillow_example_mask.close()
pillow_example_blended.close()
pillow_example_blend_target.close()
pillow_example_rotated.close()
pillow_example_flipped.close()
pillow_example_alpha.close()
pillow_example_luma.close()
pillow_example_opened_jpeg.close()
pillow_example_opened_bmp.close()
pillow_example_parser_image.close()
pillow_example_builtin_memory_png_opened.close()
pillow_example_opened_rgba.close()
pillow_example_rgba.close()
pillow_example_gray.close()
pillow_example_opened.close()
pillow_example_resize.close()
pillow_example_transform.close()
pillow_example_transform_mesh_image.close()
pillow_example_transform_descriptor_image.close()
pillow_example_math_eval.close()
pillow_example_math_compare.close()
pillow_example_math_sum.close()
pillow_example_math_b.close()
pillow_example_math_a.close()
pillow_example_quantized.close()
pillow_example_reduce.close()
pillow_example_thumbnail.close()
pillow_example_spread.close()
pillow_example_crop.close()
pillow_example_copy.close()
pillow_example_string_color_image.close()
pillow_example_putdata.close()
pillow_example_bitmap.close()
pillow_example_module_frombuffer.close()
pillow_example_module_frombytes.close()
pillow_example_frombytes.close()
pillow_example_codec_image.close()
pillow_example_custom_open.close()
pillow_example_remapped_palette.close()
pillow_example_sequence_gray_frames[1].close()
pillow_example_sequence_frames[1].close()
pillow_example_palette.close()
pillow_example_noise_random.close()
pillow_example_noise.close()
pillow_example_mandelbrot.close()
pillow_example_radial_gradient.close()
pillow_example_linear_gradient.close()
pillow_example_image.close()

class PillowExampleShiftMeshDeformer
{
    getmesh(image)
    {
        return [
            [[0, 0, 2, image.height], [2, 0, 2, image.height, image.width, image.height, image.width, 0]],
            [[2, 0, image.width, image.height], [0, 0, 0, image.height, 2, image.height, 2, 0]],
        ]
    }
}

class PillowExampleRegistryFactory
{
    static Prefix := []

    static Call(fp, filename)
    {
        PillowExampleRegistryFactory.Prefix := fp.read(7)
        return stdlib.pillow.Image.new("L", [2, 1], 9)
    }
}

class PillowExampleRegistryAccept
{
    static Call(prefix)
    {
        return prefix.Length >= 7
            && prefix[1] = 65
            && prefix[2] = 72
            && prefix[3] = 75
            && prefix[4] = 79
            && prefix[5] = 80
            && prefix[6] = 69
            && prefix[7] = 78
    }
}

class PillowExampleRegistrySave
{
    static Call(image, fp, filename)
    {
        if image.HasOwnProp("encoderinfo") && image.encoderinfo.Has("save_all")
            fp.write([65, 72, 75, 83, 65, 86, 69, 45, 85, 78, 69, 88, 80, 69, 67, 84, 69, 68])
        else if image.HasOwnProp("encoderinfo") && image.encoderinfo.Has("quality")
            fp.write([65, 72, 75, 83, 65, 86, 69, 58, 82, 69, 71])
        else
            fp.write([65, 72, 75, 83, 65, 86, 69, 65, 76, 76])
        return stdlib.None
    }
}

class PillowExampleRegistryDecoder
{
    static Call(mode, args*)
    {
        return PillowExampleRegistryDecoderInstance()
    }
}

class PillowExampleRegistryDecoderInstance
{
    setimage(image)
    {
        this.image := image
        return stdlib.None
    }

    decode(data)
    {
        return [-1, 0, data.Clone()]
    }
}

class PillowExampleRegistryEncoder
{
    static Call(mode, args*)
    {
        return PillowExampleRegistryEncoderInstance()
    }
}

class PillowExampleRegistryEncoderInstance
{
    setimage(image)
    {
        this.image := image
        return stdlib.None
    }

    encode(bufsize)
    {
        return [1, 1, [65]]
    }
}

class PillowExampleBufrHandler
{
    __New()
    {
        this.Events := []
    }

    open(image)
    {
        this.Events.Push(["open", image.format, image.mode, image.size, image.fp.tell()])
        return stdlib.None
    }

    save(image, fp, filename)
    {
        this.Events.Push(["save", image.mode, image.size, filename])
        fp.write(PillowExampleAsciiBytes("saved:" image.mode))
        return stdlib.None
    }
}

PillowExampleReadBytes(path)
{
    file := FileOpen(path, "r", "UTF-8-RAW")
    file.Pos := 0
    try {
        bytesBuffer := Buffer(file.Length, 0)
        file.RawRead(bytesBuffer, bytesBuffer.Size)
    } finally {
        file.Close()
    }
    bytes := []
    loop bytesBuffer.Size
        bytes.Push(NumGet(bytesBuffer, A_Index - 1, "UChar"))
    return bytes
}

PillowExampleWriteBytes(path, bytes)
{
    file := FileOpen(path, "w", "UTF-8-RAW")
    try {
        bytesBuffer := Buffer(bytes.Length, 0)
        for index, byte in bytes
            NumPut("UChar", byte, bytesBuffer, index - 1)
        file.RawWrite(bytesBuffer, bytesBuffer.Size)
    } finally {
        file.Close()
    }
    return stdlib.None
}

PillowExampleWriteMiniPilFont(root)
{
    lines := [
        "PILfont`n",
        ";;;;;;5;`n",
        "DATA`n",
    ]
    bytes := []
    for line in lines
        for char in StrSplit(line)
            bytes.Push(Ord(char))

    loop 256 {
        code := A_Index - 1
        if code = 65
            metrics := [3, 0, 0, 0, 3, 5, 0, 0, 3, 5]
        else if code = 66
            metrics := [2, 0, 0, 0, 2, 4, 3, 0, 5, 4]
        else
            metrics := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        for value in metrics {
            if value < 0
                value += 65536
            bytes.Push((value >> 8) & 0xFF)
            bytes.Push(value & 0xFF)
        }
    }
    PillowExampleWriteBytes(root ".pil", bytes)
    PillowExampleWriteBytes(root ".pbm", PillowExampleMiniPbmBytes())
    return stdlib.None
}

PillowExampleMiniPbmBytes()
{
    bytes := []
    for char in StrSplit("P4`n5 5`n")
        bytes.Push(Ord(char))
    for byte in [248, 248, 248, 248, 248]
        bytes.Push(byte)
    return bytes
}

PillowExampleBdfFontBytes()
{
    return PillowExampleAsciiBytes(
        "STARTFONT 2.1`n"
        . "FONT -AHK-Stdlib-Medium-R-Normal--8-80-75-75-C-50-ISO10646-1`n"
        . "SIZE 8 75 75`n"
        . "FONTBOUNDINGBOX 8 8 0 -2`n"
        . "STARTPROPERTIES 2`n"
        . "FONT_ASCENT 7`n"
        . "FONT_DESCENT 2`n"
        . "ENDPROPERTIES`n"
        . "CHARS 1`n"
        . "STARTCHAR A`n"
        . "ENCODING 65`n"
        . "SWIDTH 500 0`n"
        . "DWIDTH 7 0`n"
        . "BBX 5 7 1 -1`n"
        . "BITMAP`n"
        . "70`n"
        . "88`n"
        . "88`n"
        . "F8`n"
        . "88`n"
        . "88`n"
        . "88`n"
        . "ENDCHAR`n"
        . "ENDFONT`n"
    )
}

PillowExamplePcfBytes()
{
    metricPayload := PillowExampleConcatBytes(
        PillowExampleLe16(2),
        [128, 131, 132, 130, 129],
        [127, 130, 133, 131, 129]
    )
    encodingOffsets := []
    loop 67
        encodingOffsets.Push(0xFFFF)
    encodingOffsets[66] := 0
    encodingOffsets[67] := 1

    stringData := PillowExampleConcatBytes(
        PillowExampleAsciiBytes("FONT"),
        [0],
        PillowExampleAsciiBytes("demo-pcf"),
        [0],
        PillowExampleAsciiBytes("POINT_SIZE"),
        [0]
    )
    propsPayload := PillowExampleConcatBytes(
        PillowExampleLe32(2),
        PillowExampleLe32(0), [1], PillowExampleLe32(5),
        PillowExampleLe32(14), [0], PillowExampleLe32(120),
        [0, 0],
        PillowExampleLe32(stringData.Length),
        stringData
    )
    bitmapData := [0x05, 0x02, 0x07, 0x03, 0x04, 0x07, 0x01]
    bitmapsPayload := PillowExampleConcatBytes(
        PillowExampleLe32(2),
        PillowExampleLe32(0),
        PillowExampleLe32(3),
        PillowExampleLe32(bitmapData.Length),
        PillowExampleLe32(bitmapData.Length),
        PillowExampleLe32(bitmapData.Length),
        PillowExampleLe32(bitmapData.Length),
        bitmapData
    )
    encodingBytes := []
    for value in encodingOffsets
        for byte in PillowExampleLe16(value)
            encodingBytes.Push(byte)
    encodingPayload := PillowExampleConcatBytes(
        PillowExampleLe16(0),
        PillowExampleLe16(66),
        PillowExampleLe16(0),
        PillowExampleLe16(0),
        PillowExampleLe16(0xFFFF),
        encodingBytes
    )

    return PillowExamplePcfContainer([
        [1, 0, PillowExamplePcfTable(0, propsPayload)],
        [4, 0x100, PillowExamplePcfTable(0x100, metricPayload)],
        [8, 0, PillowExamplePcfTable(0, bitmapsPayload)],
        [32, 0, PillowExamplePcfTable(0, encodingPayload)],
    ])
}

PillowExamplePcfTable(formatValue, payload)
{
    return PillowExampleConcatBytes(PillowExampleLe32(formatValue), payload)
}

PillowExamplePcfContainer(tables)
{
    count := tables.Length
    offset := 8 + count * 16
    toc := []
    chunks := []
    for table in tables {
        data := table[3]
        for byte in PillowExampleLe32(table[1])
            toc.Push(byte)
        for byte in PillowExampleLe32(table[2])
            toc.Push(byte)
        for byte in PillowExampleLe32(data.Length)
            toc.Push(byte)
        for byte in PillowExampleLe32(offset)
            toc.Push(byte)
        chunks.Push(data)
        offset += data.Length
    }
    return PillowExampleConcatBytes(PillowExampleLe32(0x70636601), PillowExampleLe32(count), toc, chunks*)
}

PillowExampleAsciiBytes(text)
{
    bytes := []
    loop parse text
        bytes.Push(Ord(A_LoopField))
    return bytes
}

PillowExampleAsciiFromBytes(bytes)
{
    text := ""
    for byte in bytes
        text .= Chr(byte)
    return text
}

PillowExampleBytesContainsAscii(bytes, text)
{
    needle := PillowExampleAsciiBytes(text)
    if needle.Length = 0
        return true
    if bytes.Length < needle.Length
        return false
    stop := bytes.Length - needle.Length + 1
    loop stop {
        start := A_Index
        matched := true
        loop needle.Length {
            if bytes[start + A_Index - 1] != needle[A_Index] {
                matched := false
                break
            }
        }
        if matched
            return true
    }
    return false
}

PillowExampleBasicEpsBytes()
{
    return PillowExampleAsciiBytes(
        "%!PS-Adobe-3.0 EPSF-3.0`n"
        . "%%Creator: example`n"
        . "%%BoundingBox: 1 2 5 8`n"
        . "%%Pages: 1`n"
        . "%%EndComments`n"
        . "showpage`n"
        . "%%EOF`n"
    )
}

PillowExampleFitsCard(keyword, value := unset)
{
    key := String(keyword)
    while StrLen(key) < 8
        key .= " "
    if StrLen(key) > 8
        key := SubStr(key, 1, 8)
    text := IsSet(value) ? key "= " value : key
    bytes := PillowExampleAsciiBytes(text)
    while bytes.Length < 80
        bytes.Push(32)
    while bytes.Length > 80
        bytes.Pop()
    return bytes
}

PillowExampleFitsHeader(cards)
{
    bytes := []
    for cardBytes in cards {
        for byte in cardBytes
            bytes.Push(byte)
    }
    for byte in PillowExampleFitsCard("END")
        bytes.Push(byte)
    while Mod(bytes.Length, 2880) != 0
        bytes.Push(32)
    return bytes
}

PillowExampleFitsSimpleBytes(bitpix := 8, naxis := 2, dims := unset)
{
    if !IsSet(dims)
        dims := [3, 2]
    cards := [
        PillowExampleFitsCard("SIMPLE", "T"),
        PillowExampleFitsCard("BITPIX", String(bitpix)),
        PillowExampleFitsCard("NAXIS", String(naxis)),
    ]
    for index, dim in dims
        cards.Push(PillowExampleFitsCard("NAXIS" index, String(dim)))
    bytes := PillowExampleFitsHeader(cards)
    loop 80
        bytes.Push(0)
    return bytes
}

PillowExampleFliHeader(magic := 0xAF12, frames := 1, width := 3, height := 2, duration := 70, flags := 0)
{
    bytes := []
    for byte in stdlib.pillow.BmpImagePlugin.o32(144)
        bytes.Push(byte)
    for byte in stdlib.pillow.BmpImagePlugin.o16(magic)
        bytes.Push(byte)
    for byte in stdlib.pillow.BmpImagePlugin.o16(frames)
        bytes.Push(byte)
    for byte in stdlib.pillow.BmpImagePlugin.o16(width)
        bytes.Push(byte)
    for byte in stdlib.pillow.BmpImagePlugin.o16(height)
        bytes.Push(byte)
    for byte in stdlib.pillow.BmpImagePlugin.o16(0)
        bytes.Push(byte)
    for byte in stdlib.pillow.BmpImagePlugin.o16(flags)
        bytes.Push(byte)
    for byte in stdlib.pillow.BmpImagePlugin.o32(duration)
        bytes.Push(byte)
    for byte in stdlib.pillow.BmpImagePlugin.o16(0)
        bytes.Push(byte)
    while bytes.Length < 128
        bytes.Push(0)
    return bytes
}

PillowExampleFliFrameChunk()
{
    bytes := []
    for byte in stdlib.pillow.BmpImagePlugin.o32(16)
        bytes.Push(byte)
    for byte in stdlib.pillow.BmpImagePlugin.o16(0xF1FA)
        bytes.Push(byte)
    while bytes.Length < 16
        bytes.Push(0)
    return bytes
}

PillowExampleFliBytes(magic := 0xAF12, frames := 1, duration := 70)
{
    bytes := PillowExampleFliHeader(magic, frames, 3, 2, duration)
    for byte in PillowExampleFliFrameChunk()
        bytes.Push(byte)
    return bytes
}

PillowExampleFpxMagicBytes(tail := unset)
{
    bytes := [208, 207, 17, 224, 161, 177, 26, 225]
    if IsSet(tail) {
        for byte in tail
            bytes.Push(byte)
    }
    return bytes
}

PillowExampleFpxModeBlob(colors)
{
    bytes := []
    loop 4
        bytes.Push(0)
    for byte in stdlib.pillow.BmpImagePlugin.o32(colors.Length)
        bytes.Push(byte)
    for color in colors {
        for byte in stdlib.pillow.BmpImagePlugin.o32(color)
            bytes.Push(byte)
    }
    return bytes
}

PillowExampleFpxDescriptor(offset, compression, extra := unset, length := 16)
{
    if !IsSet(extra)
        extra := [0, 0, 0, 0]
    bytes := []
    for byte in stdlib.pillow.BmpImagePlugin.o32(offset)
        bytes.Push(byte)
    loop 4
        bytes.Push(0)
    for byte in stdlib.pillow.BmpImagePlugin.o32(compression)
        bytes.Push(byte)
    loop 4
        bytes.Push(A_Index <= extra.Length ? extra[A_Index] : 0)
    while bytes.Length < length
        bytes.Push(0)
    return bytes
}

PillowExampleFpxHeaderStream()
{
    bytes := []
    loop 28
        bytes.Push(0)
    header := []
    loop 4
        header.Push(0)
    for byte in stdlib.pillow.BmpImagePlugin.o32(128)
        header.Push(byte)
    for byte in stdlib.pillow.BmpImagePlugin.o32(64)
        header.Push(byte)
    for byte in stdlib.pillow.BmpImagePlugin.o32(2)
        header.Push(byte)
    for byte in stdlib.pillow.BmpImagePlugin.o32(64)
        header.Push(byte)
    for byte in stdlib.pillow.BmpImagePlugin.o32(64)
        header.Push(byte)
    for byte in stdlib.pillow.BmpImagePlugin.o32(3)
        header.Push(byte)
    for byte in stdlib.pillow.BmpImagePlugin.o32(64)
        header.Push(byte)
    for byte in stdlib.pillow.BmpImagePlugin.o32(16)
        header.Push(byte)
    for byte in header
        bytes.Push(byte)
    loop 28
        bytes.Push(0)
    for descriptorBytes in [PillowExampleFpxDescriptor(100, 0), PillowExampleFpxDescriptor(200, 0)] {
        for byte in descriptorBytes
            bytes.Push(byte)
    }
    return bytes
}

PillowExampleFpxScenario()
{
    scenario := Map()
    scenario["clsid"] := "56616700-C154-11CE-8553-00AA00A1F95B"
    scenario["size"] := [128, 64]
    scenario["maxid"] := 1
    scenario["colors"] := [0x00030000, 0x00030001, 0x00030002]
    scenario["header_stream"] := PillowExampleFpxHeaderStream()
    return scenario
}

class PillowExampleFpxFakeOleModule
{
    __New()
    {
        this.MAGIC := PillowExampleFpxMagicBytes()
        this.Scenario := PillowExampleFpxScenario()
    }

    OleFileIO(fp)
    {
        return PillowExampleFpxFakeOle(this, fp)
    }
}

class PillowExampleFpxFakeOle
{
    __New(module, fp)
    {
        this.Module := module
        this.fp := fp
        this.root := { clsid: module.Scenario["clsid"] }
    }

    getproperties(path)
    {
        scenario := this.Module.Scenario
        size := scenario["size"]
        maxid := scenario["maxid"]
        prop := Map()
        prop[0x1000002] := size[1]
        prop[0x1000003] := size[2]
        prop[0x2000002 | (maxid << 16)] := PillowExampleFpxModeBlob(scenario["colors"])
        return prop
    }

    openstream(stream)
    {
        if stream[stream.Length] = "Subimage 0000 Header"
            return stdlib.io.BytesIO(this.Module.Scenario["header_stream"])
        return stdlib.io.BytesIO(PillowExampleAsciiBytes("pixel-data"))
    }

    close()
    {
        return stdlib.None
    }
}

PillowExampleTiffBytes(mode, pixels)
{
    image := unset
    output := stdlib.io.BytesIO()
    try {
        fill := mode = "RGB" ? [0, 0, 0] : 0
        image := stdlib.pillow.Image.new(mode, [2, 2], fill)
        image.putdata(pixels)
        image.save(output, "TIFF")
        return output.getvalue()
    } finally {
        if IsSet(image) && IsObject(image) && HasMethod(image, "close")
            image.close()
    }
}

PillowExampleWalBytes(width, height, pixels, name := "demo/wall", nextName := "demo/next")
{
    bytes := []
    loop 100
        bytes.Push(0)
    nameBytes := PillowExampleAsciiBytes(name)
    loop Min(nameBytes.Length, 31)
        bytes[A_Index] := nameBytes[A_Index]
    sizeBytes := PillowExampleLe32(width)
    loop 4
        bytes[32 + A_Index] := sizeBytes[A_Index]
    sizeBytes := PillowExampleLe32(height)
    loop 4
        bytes[36 + A_Index] := sizeBytes[A_Index]
    offsetBytes := PillowExampleLe32(100)
    loop 4
        bytes[40 + A_Index] := offsetBytes[A_Index]
    nextBytes := PillowExampleAsciiBytes(nextName)
    loop Min(nextBytes.Length, 31)
        bytes[56 + A_Index] := nextBytes[A_Index]
    for pixel in pixels
        bytes.Push(pixel)
    return bytes
}

PillowExampleMpegBytes(width := 320, height := 240, tail := unset)
{
    packed := (width << 12) | height
    bytes := [
        0,
        0,
        1,
        0xB3,
        (packed >> 16) & 0xFF,
        (packed >> 8) & 0xFF,
        packed & 0xFF,
    ]
    if IsSet(tail) {
        for byte in tail
            bytes.Push(byte)
    }
    return bytes
}

PillowExampleMpoBytes(attributes := unset)
{
    entryAttributes := IsSet(attributes) ? attributes.Clone() : [0x030000, 0]
    while entryAttributes.Length < 2
        entryAttributes.Push(0)

    frames := []
    loop entryAttributes.Length
        frames.Push(PillowExampleJpegHeaderBytes())

    first := frames[1]
    app0End := 20
    mpOffset := 28
    app2PayloadLength := 54 + 16 * frames.Length
    app2TotalLength := app2PayloadLength + 4
    firstSize := first.Length + app2TotalLength

    sizes := [firstSize]
    loop frames.Length - 1
        sizes.Push(frames[A_Index + 1].Length)

    mpEntries := []
    dataOffsets := []
    dataOffset := 0
    loop frames.Length {
        index := A_Index
        dataOffsets.Push(dataOffset)
        for byte in PillowExampleLe32(entryAttributes[index])
            mpEntries.Push(byte)
        for byte in PillowExampleLe32(sizes[index])
            mpEntries.Push(byte)
        for byte in PillowExampleLe32(dataOffset)
            mpEntries.Push(byte)
        for byte in PillowExampleLe16(0)
            mpEntries.Push(byte)
        for byte in PillowExampleLe16(0)
            mpEntries.Push(byte)
        if index = 1
            dataOffset -= mpOffset
        dataOffset += sizes[index]
    }
    ifd := PillowExampleConcatBytes(
        PillowExampleLe16(3),
        PillowExampleMpoIfdEntry(0xB000, 7, 4, PillowExampleAsciiBytes("0100")),
        PillowExampleMpoIfdEntry(0xB001, 4, 1, PillowExampleLe32(frames.Length)),
        PillowExampleMpoIfdEntry(0xB002, 7, mpEntries.Length, PillowExampleLe32(50)),
        PillowExampleLe32(0),
        mpEntries
    )
    payload := PillowExampleConcatBytes(
        PillowExampleAsciiBytes("MPF"),
        [0],
        PillowExampleAsciiBytes("II"),
        PillowExampleLe16(42),
        PillowExampleLe32(8),
        ifd
    )
    app2 := PillowExampleConcatBytes([0xFF, 0xE2], PillowExampleBe16(payload.Length + 2), payload)
    bytes := PillowExampleConcatBytes(
        PillowExampleArraySlice(first, 1, app0End),
        app2,
        PillowExampleArraySlice(first, app0End + 1, first.Length)
    )
    loop frames.Length - 1 {
        for byte in frames[A_Index + 1]
            bytes.Push(byte)
    }
    return Map(
        "bytes", bytes,
        "first_size", firstSize,
        "second_size", sizes.Length >= 2 ? sizes[2] : 0,
        "second_data_offset", dataOffsets.Length >= 2 ? dataOffsets[2] : 0,
        "entry_sizes", sizes,
        "data_offsets", dataOffsets
    )
}

PillowExampleMpoBytesWithApp1(payload, attributes := unset)
{
    fixture := PillowExampleMpoBytes(attributes?)
    app1 := PillowExampleConcatBytes([0xFF, 0xE1], PillowExampleBe16(payload.Length + 2), payload)
    return PillowExampleConcatBytes(
        PillowExampleArraySlice(fixture["bytes"], 1, 20),
        app1,
        PillowExampleArraySlice(fixture["bytes"], 21, fixture["bytes"].Length)
    )
}

PillowExampleMpoIfdEntry(tag, type, count, valueBytes)
{
    bytes := PillowExampleConcatBytes(PillowExampleLe16(tag), PillowExampleLe16(type), PillowExampleLe32(count))
    padded := valueBytes.Clone()
    while padded.Length < 4
        padded.Push(0)
    for byte in PillowExampleArraySlice(padded, 1, 4)
        bytes.Push(byte)
    return bytes
}

PillowExampleMspDanMBytes()
{
    return PillowExampleConcatBytes(PillowExampleMspHeader("DanM", 9, 2), [111, 0, 190, 128])
}

PillowExampleMspLinSBytes()
{
    return PillowExampleConcatBytes(
        PillowExampleMspHeader("LinS", 9, 2),
        PillowExampleLe16(3),
        PillowExampleLe16(3),
        [2, 111, 0],
        [2, 190, 128]
    )
}

PillowExampleMspHeader(magic, width, height)
{
    header := PillowExampleConcatBytes(
        PillowExampleAsciiBytes(magic),
        PillowExampleLe16(width),
        PillowExampleLe16(height),
        PillowExampleLe16(1),
        PillowExampleLe16(1),
        PillowExampleLe16(1),
        PillowExampleLe16(1),
        PillowExampleLe16(width),
        PillowExampleLe16(height),
        PillowExampleLe16(0),
        PillowExampleLe16(0),
        PillowExampleLe16(0),
        PillowExampleLe16(0),
        PillowExampleLe16(0),
        PillowExampleLe16(0)
    )
    checksum := PillowExampleMspChecksum(header)
    header[25] := checksum & 0xFF
    header[26] := (checksum >> 8) & 0xFF
    return header
}

PillowExampleMspChecksum(bytes)
{
    checksum := 0
    index := 1
    while index + 1 <= bytes.Length {
        checksum := checksum ^ (bytes[index] | (bytes[index + 1] << 8))
        index += 2
    }
    return checksum
}

PillowExamplePcdBytes(orientation := 0, marker := "PCD_")
{
    bytes := []
    loop 2048
        bytes.Push(0)
    sector := []
    loop 2048
        sector.Push(0)
    markerBytes := PillowExampleAsciiBytes(marker)
    for byte in markerBytes
        sector[A_Index] := byte
    sector[1539] := orientation
    for byte in sector
        bytes.Push(byte)
    return bytes
}

PillowExamplePsdBytes(modeCode, bits, channels, width, height, channelData, colorData := unset, resources := unset, layerInfo := unset, compression := 0, version := 1, magic := "8BPS")
{
    if !IsSet(colorData)
        colorData := []
    if !IsSet(resources)
        resources := []
    if !IsSet(layerInfo)
        layerInfo := []

    header := PillowExampleConcatBytes(
        PillowExampleAsciiBytes(magic),
        PillowExampleBe16(version),
        [0, 0, 0, 0, 0, 0],
        PillowExampleBe16(channels),
        PillowExampleBe32(height),
        PillowExampleBe32(width),
        PillowExampleBe16(bits),
        PillowExampleBe16(modeCode)
    )
    layerSection := []
    if layerInfo.Length
        layerSection := PillowExampleConcatBytes(PillowExampleBe32(layerInfo.Length), layerInfo)
    return PillowExampleConcatBytes(
        header,
        PillowExampleBe32(colorData.Length),
        colorData,
        PillowExampleBe32(resources.Length),
        resources,
        PillowExampleBe32(layerSection.Length),
        layerSection,
        PillowExampleBe16(compression),
        channelData
    )
}

PillowExamplePsdResourceBlock(resourceId, name, data)
{
    nameBytes := PillowExampleAsciiBytes(name)
    pascal := [nameBytes.Length]
    for byte in nameBytes
        pascal.Push(byte)
    if Mod(nameBytes.Length, 2) = 0
        pascal.Push(0)

    bytes := PillowExampleConcatBytes(
        PillowExampleAsciiBytes("8BIM"),
        PillowExampleBe16(resourceId),
        pascal,
        PillowExampleBe32(data.Length),
        data
    )
    if Mod(data.Length, 2)
        bytes.Push(0)
    return bytes
}

PillowExamplePsdLayerInfoBytes()
{
    layers := [
        Map("name", "Base", "bbox", [0, 0, 2, 1], "channels", [[0, [1, 2]], [1, [3, 4]], [2, [5, 6]]]),
        Map("name", "Top", "bbox", [0, 0, 1, 1], "channels", [[0, [10]], [1, [20]], [2, [30]], [65535, [40]]]),
    ]
    records := []
    payload := []
    for layer in layers {
        bbox := layer["bbox"]
        channels := layer["channels"]
        for byte in PillowExamplePsdS32(bbox[2])
            records.Push(byte)
        for byte in PillowExamplePsdS32(bbox[1])
            records.Push(byte)
        for byte in PillowExamplePsdS32(bbox[4])
            records.Push(byte)
        for byte in PillowExamplePsdS32(bbox[3])
            records.Push(byte)
        for byte in PillowExampleBe16(channels.Length)
            records.Push(byte)
        for channel in channels {
            for byte in PillowExampleBe16(channel[1])
                records.Push(byte)
            for byte in PillowExampleBe32(2 + channel[2].Length)
                records.Push(byte)
        }
        for byte in PillowExampleAsciiBytes("8BIMnorm")
            records.Push(byte)
        for byte in [255, 0, 0, 0]
            records.Push(byte)
        extra := PillowExampleConcatBytes(PillowExampleBe32(0), PillowExampleBe32(0), PillowExamplePsdPascalName(layer["name"]))
        for byte in PillowExampleBe32(extra.Length)
            records.Push(byte)
        for byte in extra
            records.Push(byte)
        for channel in channels {
            for byte in PillowExampleBe16(0)
                payload.Push(byte)
            for byte in channel[2]
                payload.Push(byte)
            if Mod(payload.Length, 2)
                payload.Push(0)
        }
    }
    return PillowExampleConcatBytes(PillowExamplePsdS16(layers.Length), records, payload)
}

PillowExamplePsdPascalName(name)
{
    nameBytes := PillowExampleAsciiBytes(name)
    bytes := [nameBytes.Length]
    for byte in nameBytes
        bytes.Push(byte)
    while Mod(bytes.Length, 4)
        bytes.Push(0)
    return bytes
}

PillowExamplePsdS16(value)
{
    value := Integer(value)
    if value < 0
        value += 0x10000
    return PillowExampleBe16(value)
}

PillowExamplePsdS32(value)
{
    value := Integer(value)
    if value < 0
        value += 0x100000000
    return PillowExampleBe32(value)
}

PillowExampleQoiBytes(width, height, channels, payload, colorspace := 1)
{
    return PillowExampleConcatBytes(
        PillowExampleAsciiBytes("qoif"),
        PillowExampleBe32(width),
        PillowExampleBe32(height),
        [channels, colorspace],
        payload,
        [0, 0, 0, 0, 0, 0, 0, 1]
    )
}

PillowExampleSgiHeader(width, height, zsize, bpc := 1, dimension := 3, compression := 0)
{
    name := []
    loop 80
        name.Push(0)
    padding := []
    loop 404
        padding.Push(0)
    return PillowExampleConcatBytes(
        PillowExampleBe16(474),
        [compression, bpc],
        PillowExampleBe16(dimension),
        PillowExampleBe16(width),
        PillowExampleBe16(height),
        PillowExampleBe16(zsize),
        PillowExampleBe32(0),
        PillowExampleBe32(255),
        [0, 0, 0, 0],
        name,
        PillowExampleBe32(0),
        padding
    )
}

PillowExampleSgiRawBytes(width, height, zsize, planes, bpc := 1, dimension := 3)
{
    parts := [PillowExampleSgiHeader(width, height, zsize, bpc, dimension, 0)]
    for plane in planes
        parts.Push(plane)
    return PillowExampleConcatBytes(parts*)
}

PillowExampleSgiRleBytes(width, height, zsize, rowsByChannel, bpc := 1, dimension := 3)
{
    count := height * zsize
    dataStart := 512 + count * 8
    offsets := []
    lengths := []
    payloads := []
    offset := dataStart
    for row in rowsByChannel {
        encoded := [0x80 | row.Length]
        for byte in row
            encoded.Push(byte)
        encoded.Push(0)
        offsets.Push(offset)
        lengths.Push(encoded.Length)
        payloads.Push(encoded)
        offset += encoded.Length
    }
    parts := [PillowExampleSgiHeader(width, height, zsize, bpc, dimension, 1)]
    for value in offsets
        parts.Push(PillowExampleBe32(value))
    for value in lengths
        parts.Push(PillowExampleBe32(value))
    for payload in payloads
        parts.Push(payload)
    return PillowExampleConcatBytes(parts*)
}

PillowExampleSpiderHeaderValues(width := 2, height := 2, iform := 1, istack := 0, nimages := 1, imgnumber := 0)
{
    lenbyt := width * 4
    labrec := 1024 // lenbyt
    if Mod(1024, lenbyt) != 0
        labrec += 1
    labbyt := labrec * lenbyt
    nvalues := labbyt // 4
    values := []
    loop nvalues
        values.Push(0.0)
    values[1] := 1.0
    values[2] := height + 0.0
    values[3] := height + 0.0
    values[5] := iform + 0.0
    values[12] := width + 0.0
    values[13] := labrec + 0.0
    values[22] := labbyt + 0.0
    values[23] := lenbyt + 0.0
    values[24] := istack + 0.0
    values[26] := nimages + 0.0
    values[27] := imgnumber + 0.0
    return values
}

PillowExampleSpiderHeader(width := 2, height := 2, little := true, iform := 1, istack := 0, nimages := 1, imgnumber := 0)
{
    bytes := []
    for value in PillowExampleSpiderHeaderValues(width, height, iform, istack, nimages, imgnumber)
        for byte in PillowExampleFloat32(value, little)
            bytes.Push(byte)
    return bytes
}

PillowExampleSpiderImageBytes(width := 2, height := 2, pixels := unset, little := true, iform := 1, istack := 0, nimages := 1, imgnumber := 0)
{
    if !IsSet(pixels)
        pixels := [0.0, 1.0, 2.5, 5.0]
    payload := []
    for value in pixels
        for byte in PillowExampleFloat32(value, little)
            payload.Push(byte)
    return PillowExampleConcatBytes(PillowExampleSpiderHeader(width, height, little, iform, istack, nimages, imgnumber), payload)
}

PillowExampleSpiderStackBytes()
{
    frame1 := []
    for value in [1.0, 2.0, 3.0, 4.0]
        for byte in PillowExampleFloat32(value, true)
            frame1.Push(byte)
    frame2 := []
    for value in [10.0, 20.0, 30.0, 40.0]
        for byte in PillowExampleFloat32(value, true)
            frame2.Push(byte)
    return PillowExampleConcatBytes(
        PillowExampleSpiderHeader(2, 2, true, 1, 1, 2, 0),
        PillowExampleSpiderHeader(2, 2, true, 1, 0, 0, 1),
        frame1,
        PillowExampleSpiderHeader(2, 2, true, 1, 0, 0, 2),
        frame2
    )
}

PillowExampleSunBytes(width, height, depth, payload, fileType := 1, paletteType := 0, palette := unset, magic := 0x59A66A95)
{
    if !IsSet(palette)
        palette := []
    return PillowExampleConcatBytes(
        PillowExampleBe32(magic),
        PillowExampleBe32(width),
        PillowExampleBe32(height),
        PillowExampleBe32(depth),
        PillowExampleBe32(payload.Length),
        PillowExampleBe32(fileType),
        PillowExampleBe32(paletteType),
        PillowExampleBe32(palette.Length),
        palette,
        payload
    )
}

PillowExampleTgaBytes(width, height, depth, payload, imageType, flags := 0x20, idSection := unset, palette := unset, paletteEntry := 0, paletteFirst := 0)
{
    if !IsSet(idSection)
        idSection := []
    if !IsSet(palette)
        palette := []
    paletteBytesPerEntry := paletteEntry ? paletteEntry // 8 : 0
    paletteLength := paletteBytesPerEntry ? palette.Length // paletteBytesPerEntry : 0
    return PillowExampleConcatBytes(
        [idSection.Length, palette.Length ? 1 : 0, imageType],
        PillowExampleLe16(paletteFirst),
        PillowExampleLe16(paletteLength),
        [paletteEntry],
        PillowExampleLe16(0),
        PillowExampleLe16(0),
        PillowExampleLe16(width),
        PillowExampleLe16(height),
        [depth, flags],
        idSection,
        palette,
        payload
    )
}

PillowExampleFloat32(value, little := true)
{
    bytes := Buffer(4, 0)
    NumPut("Float", value + 0.0, bytes, 0)
    if little
        return [NumGet(bytes, 0, "UChar"), NumGet(bytes, 1, "UChar"), NumGet(bytes, 2, "UChar"), NumGet(bytes, 3, "UChar")]
    return [NumGet(bytes, 3, "UChar"), NumGet(bytes, 2, "UChar"), NumGet(bytes, 1, "UChar"), NumGet(bytes, 0, "UChar")]
}

PillowExamplePixarBytes(width := 2, height := 2, channelDesc := 14, depthDesc := 2, pixels := unset)
{
    if !IsSet(pixels)
        pixels := [[10, 20, 30], [200, 10, 5], [40, 50, 60], [1, 2, 3]]
    bytes := []
    loop 1024
        bytes.Push(0)
    bytes[1] := 0x80
    bytes[2] := 0xE8
    for index, byte in stdlib.pillow.BmpImagePlugin.o16(height)
        bytes[416 + index] := byte
    for index, byte in stdlib.pillow.BmpImagePlugin.o16(width)
        bytes[418 + index] := byte
    for index, byte in stdlib.pillow.BmpImagePlugin.o16(channelDesc)
        bytes[424 + index] := byte
    for index, byte in stdlib.pillow.BmpImagePlugin.o16(depthDesc)
        bytes[426 + index] := byte
    for pixel in pixels {
        for byte in pixel
            bytes.Push(byte)
    }
    return bytes
}

class PillowExampleMicFakeOleModule
{
    __New(entries)
    {
        this.MAGIC := [208, 207, 17, 224, 161, 177, 26, 225]
        this.Entries := entries
        this.ClosedCount := 0
    }

    OleFileIO(fp)
    {
        return PillowExampleMicFakeOle(this, fp)
    }
}

class PillowExampleMicFakeOle
{
    __New(module, fp)
    {
        this.Module := module
        this.fp := fp
    }

    listdir()
    {
        paths := []
        for entry in this.Module.Entries
            paths.Push(entry[1])
        return paths
    }

    openstream(filename)
    {
        for entry in this.Module.Entries {
            if PillowExampleMicPathEquals(entry[1], filename)
                return stdlib.io.BytesIO(entry[2])
        }
        throw OSError("missing stream", -1)
    }

    close()
    {
        this.Module.ClosedCount += 1
        return stdlib.None
    }
}

PillowExampleMicPathEquals(left, right)
{
    if left.Length != right.Length
        return false
    loop left.Length {
        if left[A_Index] != right[A_Index]
            return false
    }
    return true
}

PillowExampleFtexBytes(width, height, format, payload, version := 1, mipmapCount := 1, formatCount := 1, where := 32)
{
    bytes := PillowExampleAsciiBytes("FTEX")
    for byte in stdlib.pillow.BmpImagePlugin.o32(version)
        bytes.Push(byte)
    for byte in stdlib.pillow.BmpImagePlugin.o32(width)
        bytes.Push(byte)
    for byte in stdlib.pillow.BmpImagePlugin.o32(height)
        bytes.Push(byte)
    for byte in stdlib.pillow.BmpImagePlugin.o32(mipmapCount)
        bytes.Push(byte)
    for byte in stdlib.pillow.BmpImagePlugin.o32(formatCount)
        bytes.Push(byte)
    for byte in stdlib.pillow.BmpImagePlugin.o32(format)
        bytes.Push(byte)
    for byte in stdlib.pillow.BmpImagePlugin.o32(where)
        bytes.Push(byte)
    while bytes.Length < where
        bytes.Push(0xEE)
    for byte in stdlib.pillow.BmpImagePlugin.o32(payload.Length)
        bytes.Push(byte)
    for byte in payload
        bytes.Push(byte)
    return bytes
}

PillowExampleGbrBytes(width, height, colorDepth, payload, version := 2, comment := "brush", spacing := 7, magic := "GIMP")
{
    commentBytes := PillowExampleAsciiBytes(comment)
    commentBytes.Push(0)
    headerSize := (version = 1 ? 20 : 28) + commentBytes.Length
    bytes := []
    for byte in PillowExampleBe32(headerSize)
        bytes.Push(byte)
    for byte in PillowExampleBe32(version)
        bytes.Push(byte)
    for byte in PillowExampleBe32(width)
        bytes.Push(byte)
    for byte in PillowExampleBe32(height)
        bytes.Push(byte)
    for byte in PillowExampleBe32(colorDepth)
        bytes.Push(byte)
    if version != 1 {
        for byte in PillowExampleAsciiBytes(magic)
            bytes.Push(byte)
        for byte in PillowExampleBe32(spacing)
            bytes.Push(byte)
    }
    for byte in commentBytes
        bytes.Push(byte)
    for byte in payload
        bytes.Push(byte)
    return bytes
}

PillowExampleGdBytes(width, height, trueColor, transparency, pixels, magic := 65534)
{
    bytes := []
    for byte in PillowExampleBe16(magic)
        bytes.Push(byte)
    for byte in PillowExampleBe16(width)
        bytes.Push(byte)
    for byte in PillowExampleBe16(height)
        bytes.Push(byte)
    bytes.Push(trueColor)
    if trueColor {
        bytes.Push(88)
        bytes.Push(89)
    }
    for byte in PillowExampleBe32(transparency)
        bytes.Push(byte)
    bytes.Push(117)
    bytes.Push(118)
    loop 256 {
        index := A_Index - 1
        bytes.Push(Mod(index * 3, 256))
        bytes.Push(Mod(index * 5, 256))
        bytes.Push(Mod(index * 7, 256))
        bytes.Push(99)
    }
    for byte in pixels
        bytes.Push(byte)
    return bytes
}

PillowExampleGifBytes(version := "GIF89a", transparent := true, comment := true, loopExtension := true)
{
    bytes := PillowExampleAsciiBytes(version)
    for byte in PillowExampleLe16(2)
        bytes.Push(byte)
    for byte in PillowExampleLe16(2)
        bytes.Push(byte)
    bytes.Push(0x81)
    bytes.Push(1)
    bytes.Push(0)
    for byte in [
        0, 0, 0,
        255, 0, 0,
        0, 255, 0,
        0, 0, 255,
    ]
        bytes.Push(byte)
    if comment {
        bytes.Push(0x21)
        bytes.Push(0xFE)
        bytes.Push(5)
        for byte in PillowExampleAsciiBytes("hello")
            bytes.Push(byte)
        bytes.Push(0)
    }
    if loopExtension {
        bytes.Push(0x21)
        bytes.Push(0xFF)
        bytes.Push(11)
        for byte in PillowExampleAsciiBytes("NETSCAPE2.0")
            bytes.Push(byte)
        bytes.Push(3)
        bytes.Push(1)
        for byte in PillowExampleLe16(7)
            bytes.Push(byte)
        bytes.Push(0)
    }
    if transparent {
        bytes.Push(0x21)
        bytes.Push(0xF9)
        bytes.Push(4)
        bytes.Push(1)
        for byte in PillowExampleLe16(5)
            bytes.Push(byte)
        bytes.Push(2)
        bytes.Push(0)
    }
    bytes.Push(0x2C)
    for byte in PillowExampleLe16(0)
        bytes.Push(byte)
    for byte in PillowExampleLe16(0)
        bytes.Push(byte)
    for byte in PillowExampleLe16(2)
        bytes.Push(byte)
    for byte in PillowExampleLe16(2)
        bytes.Push(byte)
    bytes.Push(0)
    bytes.Push(2)
    bytes.Push(3)
    bytes.Push(68)
    bytes.Push(52)
    bytes.Push(5)
    bytes.Push(0)
    bytes.Push(0x3B)
    return bytes
}

PillowExampleLe16(value)
{
    value := Integer(value)
    return [value & 0xFF, (value >> 8) & 0xFF]
}

PillowExampleLe32(value)
{
    value := Integer(value)
    return [value & 0xFF, (value >> 8) & 0xFF, (value >> 16) & 0xFF, (value >> 24) & 0xFF]
}

PillowExampleBe16(value)
{
    value := Integer(value)
    return [(value >> 8) & 0xFF, value & 0xFF]
}

PillowExampleBe32(value)
{
    value := Integer(value)
    return [(value >> 24) & 0xFF, (value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF]
}

PillowExampleIcnsPngBytes(size := unset)
{
    if !IsSet(size)
        size := [16, 16]
    image := unset
    try {
        image := stdlib.pillow.Image.new("RGBA", size, [10, 20, 30, 40])
        image.putpixel([1, 0], [200, 10, 5, 255])
        buffer := stdlib.io.BytesIO()
        image.save(buffer, "PNG")
        return buffer.getvalue()
    } finally {
        if IsSet(image)
            image.close()
    }
}

PillowExampleIcnsBytes(entries)
{
    payload := []
    for entry in entries {
        for byte in PillowExampleAsciiBytes(entry[1])
            payload.Push(byte)
        for byte in PillowExampleBe32(8 + entry[2].Length)
            payload.Push(byte)
        for byte in entry[2]
            payload.Push(byte)
    }

    bytes := PillowExampleAsciiBytes("icns")
    for byte in PillowExampleBe32(8 + payload.Length)
        bytes.Push(byte)
    for byte in payload
        bytes.Push(byte)
    return bytes
}

PillowExampleCountPngSignatures(bytes)
{
    count := 0
    signature := [137, 80, 78, 71, 13, 10, 26, 10]
    index := 1
    while index <= bytes.Length - signature.Length + 1 {
        matched := true
        loop signature.Length {
            if bytes[index + A_Index - 1] != signature[A_Index] {
                matched := false
                break
            }
        }
        if matched {
            count += 1
            index += signature.Length
        } else {
            index += 1
        }
    }
    return count
}

PillowExampleIcoLe16(bytes, offset)
{
    return bytes[offset] | (bytes[offset + 1] << 8)
}

PillowExampleIcoLe32(bytes, offset)
{
    return bytes[offset] | (bytes[offset + 1] << 8) | (bytes[offset + 2] << 16) | (bytes[offset + 3] << 24)
}

PillowExampleIcoDirectoryEntries(bytes)
{
    count := PillowExampleIcoLe16(bytes, 5)
    entries := []
    loop count {
        entryOffset := 7 + (A_Index - 1) * 16
        payloadOffset := PillowExampleIcoLe32(bytes, entryOffset + 12)
        entries.Push(Map(
            "width", bytes[entryOffset] ? bytes[entryOffset] : 256,
            "height", bytes[entryOffset + 1] ? bytes[entryOffset + 1] : 256,
            "bpp", PillowExampleIcoLe16(bytes, entryOffset + 6),
            "size", PillowExampleIcoLe32(bytes, entryOffset + 8),
            "offset", payloadOffset,
            "payload_prefix", PillowExampleArraySlice(bytes, payloadOffset + 1, payloadOffset + 8)
        ))
    }
    return entries
}

PillowExampleImBytes(lines, payload, palette := unset)
{
    bytes := []
    for line in lines {
        for byte in PillowExampleAsciiBytes(line "`r`n")
            bytes.Push(byte)
    }
    padding := 511 - bytes.Length
    loop padding
        bytes.Push(0)
    bytes.Push(0x1A)
    if IsSet(palette) {
        for byte in palette
            bytes.Push(byte)
    }
    for byte in payload
        bytes.Push(byte)
    return bytes
}

PillowExampleIptcBytes(fields)
{
    bytes := []
    for field in fields {
        tag := field[1]
        payload := field[2]
        bytes.Push(0x1C)
        bytes.Push(tag[1])
        bytes.Push(tag[2])
        bytes.Push((payload.Length >> 8) & 0xFF)
        bytes.Push(payload.Length & 0xFF)
        for byte in payload
            bytes.Push(byte)
    }
    return bytes
}

PillowExampleConcatBytes(parts*)
{
    bytes := []
    for part in parts {
        for byte in part
            bytes.Push(byte)
    }
    return bytes
}

PillowExampleTarBytes(entries)
{
    bytes := []
    for entry in entries {
        payload := entry[2]
        for byte in PillowExampleTarHeaderBytes(entry[1], payload.Length)
            bytes.Push(byte)
        for byte in payload
            bytes.Push(byte)
        padding := Mod(payload.Length, 512)
        if padding
            loop 512 - padding
                bytes.Push(0)
    }
    loop 1024
        bytes.Push(0)
    return bytes
}

PillowExampleTarHeaderBytes(name, size)
{
    bytes := PillowExampleZeroBytes(512)
    nameBytes := PillowExampleAsciiBytes(name)
    for index, byte in nameBytes {
        if index > 100
            break
        bytes[index] := byte
    }
    sizeBytes := PillowExampleAsciiBytes(PillowExampleOctalText(size, 11))
    for index, byte in sizeBytes
        bytes[124 + index] := byte
    return bytes
}

PillowExampleOctalText(value, width)
{
    value := Integer(value)
    digits := ""
    loop {
        digits := Mod(value, 8) digits
        value := value // 8
    } until value = 0
    while StrLen(digits) < width
        digits := "0" digits
    return SubStr(digits, -width + 1)
}

PillowExampleZeroBytes(count)
{
    bytes := []
    loop count
        bytes.Push(0)
    return bytes
}

PillowExampleJpegHeaderBytes()
{
    bytes := [0xFF, 0xD8]
    for byte in [0xFF, 0xE0, 0, 16]
        bytes.Push(byte)
    for byte in PillowExampleAsciiBytes("JFIF")
        bytes.Push(byte)
    for byte in [0, 1, 1, 1, 0, 72, 0, 96, 0, 0]
        bytes.Push(byte)

    for byte in [0xFF, 0xDB, 0, 67, 0]
        bytes.Push(byte)
    loop 64
        bytes.Push(A_Index - 1)

    for byte in [0xFF, 0xC0, 0, 17, 8]
        bytes.Push(byte)
    for byte in PillowExampleBe16(2)
        bytes.Push(byte)
    for byte in PillowExampleBe16(3)
        bytes.Push(byte)
    for byte in [3, 1, 0x22, 0, 2, 0x11, 0, 3, 0x11, 0]
        bytes.Push(byte)

    for byte in [0xFF, 0xDA, 0, 12, 3, 1, 0, 2, 0, 3, 0, 0, 63, 0, 0xFF, 0xD9]
        bytes.Push(byte)
    return bytes
}

PillowExampleMcIdasAreaBytes(width := 3, height := 2, bytesPerPixel := 1, bands := 1, prefix := 0, offset := 256, payload := unset)
{
    directory := []
    loop 64
        directory.Push(0)
    directory[1] := 0
    directory[2] := 4
    directory[9] := height
    directory[10] := width
    directory[11] := bytesPerPixel
    directory[14] := bands
    directory[15] := prefix
    directory[34] := offset - prefix

    bytes := []
    for value in directory
        for byte in PillowExampleBe32(value)
            bytes.Push(byte)
    if !IsSet(payload) {
        payload := []
        loop width * height * bytesPerPixel * bands
            payload.Push(A_Index - 1)
    }
    for byte in payload
        bytes.Push(byte)
    return bytes
}

PillowExampleJp2Box(type, payload)
{
    bytes := PillowExampleBe32(payload.Length + 8)
    for byte in PillowExampleAsciiBytes(type)
        bytes.Push(byte)
    for byte in payload
        bytes.Push(byte)
    return bytes
}

PillowExampleJp2Bytes(width, height, components, bpc, brand := "jp2 ", dpi := false)
{
    signature := [0, 0, 0, 12]
    for byte in PillowExampleAsciiBytes("jP  ")
        signature.Push(byte)
    for byte in [13, 10, 135, 10]
        signature.Push(byte)

    ftypPayload := PillowExampleAsciiBytes(brand)
    for byte in [0, 0, 0, 0]
        ftypPayload.Push(byte)
    for byte in PillowExampleAsciiBytes(brand)
        ftypPayload.Push(byte)

    ihdrPayload := []
    for byte in PillowExampleBe32(height)
        ihdrPayload.Push(byte)
    for byte in PillowExampleBe32(width)
        ihdrPayload.Push(byte)
    for byte in PillowExampleBe16(components)
        ihdrPayload.Push(byte)
    for byte in [bpc, 0, 0, 0]
        ihdrPayload.Push(byte)

    headerPayload := PillowExampleJp2Box("ihdr", ihdrPayload)
    if dpi {
        rescPayload := []
        for value in [300, 254, 600, 254]
            for byte in PillowExampleBe16(value)
                rescPayload.Push(byte)
        for byte in [2, 2]
            rescPayload.Push(byte)
        resPayload := PillowExampleJp2Box("resc", rescPayload)
        for byte in PillowExampleJp2Box("res ", resPayload)
            headerPayload.Push(byte)
    }

    return PillowExampleConcatBytes(
        signature,
        PillowExampleJp2Box("ftyp", ftypPayload),
        PillowExampleJp2Box("jp2h", headerPayload)
    )
}

PillowExampleJ2kBytes(width, height, components, ssiz, comment)
{
    bytes := [0xFF, 0x4F, 0xFF, 0x51]
    for byte in PillowExampleBe16(38 + components * 3)
        bytes.Push(byte)
    for byte in PillowExampleBe16(0)
        bytes.Push(byte)
    for value in [width, height, 0, 0, width, height, 0, 0]
        for byte in PillowExampleBe32(value)
            bytes.Push(byte)
    for byte in PillowExampleBe16(components)
        bytes.Push(byte)
    loop components {
        bytes.Push(ssiz)
        bytes.Push(1)
        bytes.Push(1)
    }
    commentBytes := PillowExampleAsciiBytes(comment)
    bytes.Push(0xFF)
    bytes.Push(0x64)
    for byte in PillowExampleBe16(4 + commentBytes.Length)
        bytes.Push(byte)
    bytes.Push(0)
    bytes.Push(0)
    for byte in commentBytes
        bytes.Push(byte)
    bytes.Push(0xFF)
    bytes.Push(0x90)
    return bytes
}

PillowExampleCurDibBytes(width, height, fill, point := unset)
{
    image := unset
    try {
        image := stdlib.pillow.Image.new("RGB", [width, height], fill)
        if IsSet(point)
            image.putpixel([point[1], point[2]], point[3])
        buffer := stdlib.io.BytesIO()
        image.save(buffer, "BMP")
        bytes := buffer.getvalue()
        return PillowExampleArraySlice(bytes, 15, bytes.Length)
    } finally {
        if IsSet(image)
            image.close()
    }
}

PillowExampleCurBytes(entries)
{
    bytes := [0, 0, 2, 0]
    for byte in stdlib.pillow.BmpImagePlugin.o16(entries.Length)
        bytes.Push(byte)
    offset := 6 + entries.Length * 16
    payloads := []
    for entry in entries {
        width := entry[1]
        height := entry[2]
        bits := entry[3]
        dib := entry[4]
        bytes.Push(width)
        bytes.Push(height)
        bytes.Push(0)
        bytes.Push(0)
        for byte in stdlib.pillow.BmpImagePlugin.o16(0)
            bytes.Push(byte)
        for byte in stdlib.pillow.BmpImagePlugin.o16(bits)
            bytes.Push(byte)
        for byte in stdlib.pillow.BmpImagePlugin.o32(dib.Length)
            bytes.Push(byte)
        for byte in stdlib.pillow.BmpImagePlugin.o32(offset)
            bytes.Push(byte)
        payloads.Push(dib)
        offset += dib.Length
    }
    for payload in payloads {
        for byte in payload
            bytes.Push(byte)
    }
    return bytes
}

PillowExamplePcxRgbBytes(width, height, fill, point := unset)
{
    stride := width + Mod(width, 2)
    rows := []
    loop height {
        y := A_Index - 1
        row := []
        loop width {
            x := A_Index - 1
            pixel := fill
            if IsSet(point) && x = point[1] && y = point[2]
                pixel := point[3]
            row.Push(pixel)
        }
        rows.Push(row)
    }

    bytes := [
        10, 5, 1, 8,
        0, 0, 0, 0,
        (width - 1) & 0xFF, ((width - 1) >> 8) & 0xFF,
        (height - 1) & 0xFF, ((height - 1) >> 8) & 0xFF,
        100, 0, 100, 0,
    ]
    loop 48
        bytes.Push(0)
    bytes.Push(0)
    bytes.Push(3)
    for byte in stdlib.pillow.BmpImagePlugin.o16(stride)
        bytes.Push(byte)
    for byte in stdlib.pillow.BmpImagePlugin.o16(1)
        bytes.Push(byte)
    loop 58
        bytes.Push(0)

    loop height {
        y := A_Index
        loop 3 {
            channel := A_Index
            plane := []
            for pixel in rows[y]
                plane.Push(pixel[channel])
            while plane.Length < stride
                plane.Push(0)
            for byte in PillowExamplePcxEncodeRle(plane)
                bytes.Push(byte)
        }
    }
    return bytes
}

PillowExamplePcxEncodeRle(values)
{
    encoded := []
    index := 1
    while index <= values.Length {
        value := values[index]
        count := 1
        while index + count <= values.Length && values[index + count] = value && count < 63
            count += 1
        if count > 1 || value >= 192 {
            encoded.Push(192 | count)
            encoded.Push(value)
        } else {
            encoded.Push(value)
        }
        index += count
    }
    return encoded
}

PillowExampleDcxBytes(frames)
{
    bytes := stdlib.pillow.BmpImagePlugin.o32(987654321)
    offset := 4 + 1024 * 4
    for frame in frames {
        for byte in stdlib.pillow.BmpImagePlugin.o32(offset)
            bytes.Push(byte)
        offset += frame.Length
    }
    loop 1024 - frames.Length {
        for byte in stdlib.pillow.BmpImagePlugin.o32(0)
            bytes.Push(byte)
    }
    for frame in frames {
        for byte in frame
            bytes.Push(byte)
    }
    return bytes
}

PillowExampleFontGlyphMetrics(glyph)
{
    return [glyph[1], glyph[2], glyph[3]]
}

PillowExampleArraySlice(values, startIndex, endIndex)
{
    sliced := []
    index := startIndex
    while index <= endIndex && index <= values.Length {
        sliced.Push(values[index])
        index += 1
    }
    return sliced
}

PillowExampleArraySum(values)
{
    total := 0
    for value in values
        total += value
    return total
}

PillowExampleArrayContains(values, needle)
{
    for value in values {
        if value = needle
            return true
    }
    return false
}

PillowExamplePixelRows(image)
{
    rows := []
    loop image.height {
        y := A_Index - 1
        row := []
        loop image.width {
            x := A_Index - 1
            row.Push(image.getpixel([x, y]))
        }
        rows.Push(row)
    }
    return rows
}

PillowExampleAvifFtyp(brand)
{
    bytes := [0, 0, 0, 24, 102, 116, 121, 112]
    for char in StrSplit(brand)
        bytes.Push(Ord(char))
    for byte in [0, 0, 0, 0]
        bytes.Push(byte)
    for char in StrSplit(brand)
        bytes.Push(Ord(char))
    return bytes
}

PillowExampleBlpPaletteImage(paletteMode)
{
    image := stdlib.pillow.Image.new("P", [2, 2])
    image.putdata([0, 1, 2, 3])
    if paletteMode = "RGBA" {
        colors := [
            10, 20, 30, 255,
            40, 50, 60, 128,
            70, 80, 90, 64,
            100, 110, 120, 0,
        ]
        loop 252 {
            colors.Push(0)
            colors.Push(0)
            colors.Push(0)
            colors.Push(0)
        }
        image.putpalette(colors, "RGBA")
    } else {
        colors := [
            10, 20, 30,
            40, 50, 60,
            70, 80, 90,
            100, 110, 120,
        ]
        loop 252 {
            colors.Push(0)
            colors.Push(0)
            colors.Push(0)
        }
        image.putpalette(colors, "RGB")
    }
    return image
}

PillowExampleWmfBytes(x0 := 0, y0 := 0, x1 := 1440, y1 := 720, inch := 1440, standard := true)
{
    bytes := []
    loop 44
        bytes.Push(0)
    bytes[1] := 0xD7
    bytes[2] := 0xCD
    bytes[3] := 0xC6
    bytes[4] := 0x9A
    PillowExamplePutLe16(bytes, 7, x0)
    PillowExamplePutLe16(bytes, 9, y0)
    PillowExamplePutLe16(bytes, 11, x1)
    PillowExamplePutLe16(bytes, 13, y1)
    PillowExamplePutLe16(bytes, 15, inch)
    if standard {
        bytes[23] := 1
        bytes[24] := 0
        bytes[25] := 9
        bytes[26] := 0
    }
    return bytes
}

PillowExampleEmfBytes(x0 := 0, y0 := 0, x1 := 96, y1 := 48, frame := unset)
{
    if !IsSet(frame)
        frame := [0, 0, 2540, 1270]
    bytes := []
    loop 44
        bytes.Push(0)
    bytes[1] := 1
    PillowExamplePutLe32(bytes, 9, x0)
    PillowExamplePutLe32(bytes, 13, y0)
    PillowExamplePutLe32(bytes, 17, x1)
    PillowExamplePutLe32(bytes, 21, y1)
    loop 4
        PillowExamplePutLe32(bytes, 25 + (A_Index - 1) * 4, frame[A_Index])
    bytes[41] := 32
    bytes[42] := Ord("E")
    bytes[43] := Ord("M")
    bytes[44] := Ord("F")
    return bytes
}

PillowExampleXbmBytes(hotspot := false)
{
    if hotspot
        return PillowExampleAsciiBytes(" `t#define demo_width 5`r`n#define demo_height 2`r`n#define demo_x_hot 1`r`n#define demo_y_hot 0`r`nstatic unsigned char demo_bits[] = {`r`n0x15,0x0a};`r`n")
    return PillowExampleAsciiBytes("#define im_width 5`n#define im_height 2`nstatic char im_bits[] = {`n0x15, 0x0a};`n")
}

PillowExampleXpmPBytes()
{
    return PillowExampleAsciiBytes(
        "/* XPM */`n"
        "/* comment before header */`n"
        "`"4 2 3 1`",`n"
        "`"a c #ff0000`",`n"
        "`"b c #00ff00`",`n"
        "`"c c None`",`n"
        "/* pixels */`n"
        "`"abba`",`n"
        "`"baab`"`n"
        "};`n"
    )
}

PillowExampleXpmRgbBytes()
{
    charCodes := PillowExampleXpmColorKeyCodes()
    keys := []
    for firstCode in charCodes {
        for secondCode in charCodes {
            keys.Push(Chr(firstCode) Chr(secondCode))
            if keys.Length = 257
                break
        }
        if keys.Length = 257
            break
    }

    bytes := PillowExampleAsciiBytes("/* XPM */`n`"2 1 257 2`",`n")
    for index, key in keys {
        zeroIndex := index - 1
        r := zeroIndex & 0xFF
        g := (255 - zeroIndex) & 0xFF
        b := (zeroIndex * 3) & 0xFF
        for byte in PillowExampleAsciiBytes("`"" key " c #" Format("{:02x}{:02x}{:02x}", r, g, b) "`",`n")
            bytes.Push(byte)
    }
    for byte in PillowExampleAsciiBytes("`"" keys[1] keys[257] "`"`n};`n")
        bytes.Push(byte)
    return bytes
}

PillowExampleXpmColorKeyCodes()
{
    codes := []
    code := Ord("A")
    while code <= Ord("Z") {
        codes.Push(code)
        code += 1
    }
    code := Ord("a")
    while code <= Ord("z") {
        codes.Push(code)
        code += 1
    }
    code := Ord("0")
    while code <= Ord("9") {
        codes.Push(code)
        code += 1
    }
    for code in [33, 36, 37, 38, 40, 41, 42, 43, 45, 46, 47, 58, 59, 60, 61, 62, 63, 64, 91, 93, 94, 95, 96, 123, 124, 125, 126]
        codes.Push(code)
    return codes
}

PillowExampleXVThumbBytes(width := 3, height := 2, pixels := unset, comments := unset)
{
    if !IsSet(pixels)
        pixels := [0, 1, 2, 3, 4, 5]
    if !IsSet(comments)
        comments := ["#IMGINFO:demo", "#THUMBONLY"]

    bytes := PillowExampleAsciiBytes("P7 332`n")
    for comment in comments {
        for byte in PillowExampleAsciiBytes(comment "`n")
            bytes.Push(byte)
    }
    for byte in PillowExampleAsciiBytes(width " " height "`n")
        bytes.Push(byte)
    for byte in pixels
        bytes.Push(byte)
    return bytes
}

PillowExamplePutLe16(bytes, offset, value)
{
    bytes[offset] := value & 0xFF
    bytes[offset + 1] := (value >> 8) & 0xFF
    return stdlib.None
}

PillowExamplePutLe32(bytes, offset, value)
{
    bytes[offset] := value & 0xFF
    bytes[offset + 1] := (value >> 8) & 0xFF
    bytes[offset + 2] := (value >> 16) & 0xFF
    bytes[offset + 3] := (value >> 24) & 0xFF
    return stdlib.None
}

class PillowExampleWmfHandler
{
    open(image)
    {
        image.AhkStdlibMode := "RGB"
        return stdlib.None
    }

    load(image)
    {
        return stdlib.pillow.Image.new("RGB", image.size, [1, 2, 3])
    }

    save(image, fp, filename)
    {
        fp.write(PillowExampleAsciiBytes("saved:[" image.size[1] ", " image.size[2] "]"))
        return stdlib.None
    }
}

class PillowExampleShowViewer
{
    __New(result := 1)
    {
        this.Result := result
        this.Calls := []
    }

    show(image, options*)
    {
        normalized := options.Length >= 1 && IsObject(options[1]) ? options[1] : Map()
        this.Calls.Push([image.mode, image.size, normalized])
        return this.Result
    }
}

#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\assert>
#Include <stdlib\io>
#Include <stdlib\pathlib>
#Include <stdlib\pillow>

class StdlibPillowTest
{
    static TestImageCoreMatchesLocalPillow113()
    {
        path := StdlibPillowTest.TempPath("core.png")
        image := unset
        copied := unset
        cropped := unset
        resized := unset
        opened := unset
        try {
            image := stdlib.pillow.Image.new("RGB", [3, 2], [10, 20, 30])
            AhkTest.AssertEqual("RGB", image.mode)
            AhkTest.AssertEqual([3, 2], image.size)
            AhkTest.AssertEqual(3, image.width)
            AhkTest.AssertEqual(2, image.height)
            AhkTest.AssertRegex(image.__Repr(), "^<PIL\.Image\.Image image mode=RGB size=3x2 at 0x[0-9A-F]+>$")

            AhkTest.AssertSame(stdlib.None, image.putpixel([1, 0], [200, 10, 5]))
            AhkTest.AssertEqual([200, 10, 5], image.getpixel([1, 0]))

            copied := image.copy()
            copied.putpixel([0, 0], [1, 2, 3])
            AhkTest.AssertEqual([10, 20, 30], image.getpixel([0, 0]))
            AhkTest.AssertEqual([1, 2, 3], copied.getpixel([0, 0]))

            cropped := image.crop([1, 0, 3, 2])
            AhkTest.AssertEqual("RGB", cropped.mode)
            AhkTest.AssertEqual([2, 2], cropped.size)
            AhkTest.AssertEqual([200, 10, 5], cropped.getpixel([0, 0]))
            AhkTest.AssertEqual([10, 20, 30], cropped.getpixel([1, 1]))

            resized := image.resize([6, 4])
            AhkTest.AssertEqual("RGB", resized.mode)
            AhkTest.AssertEqual([6, 4], resized.size)

            AhkTest.AssertSame(stdlib.None, image.save(path))
            opened := stdlib.pillow.Image.open(path)
            AhkTest.AssertEqual("PNG", opened.format)
            AhkTest.AssertEqual("RGB", opened.mode)
            AhkTest.AssertEqual([3, 2], opened.size)
            AhkTest.AssertEqual([200, 10, 5], opened.getpixel([1, 0]))

            AhkTest.RaisesMatch(ValueError, "^unrecognized image mode$", (*) => stdlib.pillow.Image.new("BAD", [1, 1]))
            AhkTest.RaisesMatch(ValueError, "^Size must be a sequence of length 2$", (*) => stdlib.pillow.Image.new("RGB", [1]))
            AhkTest.RaisesMatch(IndexError, "^image index out of range$", (*) => image.getpixel([9, 9]))
            AhkTest.RaisesMatch(IndexError, "^image index out of range$", (*) => image.putpixel([9, 9], [1, 2, 3]))
        } finally {
            if IsSet(opened) && IsObject(opened) && HasMethod(opened, "close")
                opened.close()
            if IsSet(resized) && IsObject(resized) && HasMethod(resized, "close")
                resized.close()
            if IsSet(cropped) && IsObject(cropped) && HasMethod(cropped, "close")
                cropped.close()
            if IsSet(copied) && IsObject(copied) && HasMethod(copied, "close")
                copied.close()
            if IsSet(image) && IsObject(image) && HasMethod(image, "close")
                image.close()
            if FileExist(path)
                FileDelete path
        }
    }

    static TestImageFrameMethodsMatchLocalPillow113()
    {
        image := unset
        copied := unset
        try {
            image := stdlib.pillow.Image.new("RGB", [2, 1], [1, 2, 3])
            copied := image.copy()

            AhkTest.AssertEqual(0, image.tell())
            AhkTest.AssertEqual(0, copied.tell())
            AhkTest.AssertSame(stdlib.None, image.seek(0))
            AhkTest.AssertEqual(0, image.tell())
            AhkTest.AssertSame(stdlib.None, image.seek(0.0))
            AhkTest.AssertSame(stdlib.None, image.verify())
            AhkTest.AssertEqual([1, 2, 3], image.getpixel([0, 0]))

            AhkTest.RaisesMatch(EOFError, "^no more images in file$", (*) => image.seek(1))
            AhkTest.RaisesMatch(EOFError, "^no more images in file$", (*) => image.seek(-1))
            AhkTest.RaisesMatch(EOFError, "^no more images in file$", (*) => image.seek("0"))
            AhkTest.RaisesMatch(TypeError, "^Image.seek\(\) missing 1 required positional argument: 'frame'$", (*) => image.seek())
            AhkTest.RaisesMatch(TypeError, "^Image.seek\(\) takes 2 positional arguments but 3 were given$", (*) => image.seek(0, 1))
            AhkTest.RaisesMatch(TypeError, "^Image.tell\(\) takes 1 positional argument but 2 were given$", (*) => image.tell(1))
            AhkTest.RaisesMatch(TypeError, "^Image.verify\(\) takes 1 positional argument but 2 were given$", (*) => image.verify(1))
        } finally {
            if IsSet(copied)
                StdlibPillowTest.CloseImage(copied)
            if IsSet(image)
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestImageInstanceSurfaceMatchesLocalPillow113()
    {
        path := StdlibPillowTest.TempPath("instance-surface.png")
        image := unset
        opened := unset
        bits := unset
        try {
            image := stdlib.pillow.Image.new("RGB", [2, 1], [1, 2, 3])
            AhkTest.AssertEqual(0, image.readonly)
            AhkTest.AssertSame(stdlib.None, image.format)
            AhkTest.AssertSame(stdlib.None, image.format_description)
            AhkTest.AssertSame(stdlib.None, image.draft("L", [1, 1]))
            AhkTest.AssertEqual([], image.get_child_images())
            AhkTest.AssertEqual(0, image.getxmp().Count)
            AhkTest.AssertRegex(image.getim().__Repr(), '^<capsule object "Pillow Imaging" at 0x[0-9A-F]+>$')
            AhkTest.AssertRegex(image.im.__Repr(), "^<ImagingCore object at 0x[0-9A-F]+>$")

            AhkTest.AssertSame(stdlib.None, image.save(path))
            opened := stdlib.pillow.Image.open(path)
            AhkTest.AssertEqual(1, opened.readonly)
            AhkTest.AssertEqual("PNG", opened.format)
            AhkTest.AssertEqual("Portable network graphics", opened.format_description)
            AhkTest.AssertSame(stdlib.None, opened.draft("L", [1, 1]))
            AhkTest.AssertEqual(1, opened.readonly)
            AhkTest.AssertEqual([], opened.get_child_images())
            AhkTest.AssertEqual(0, opened.getxmp().Count)
            AhkTest.AssertRegex(opened.getim().__Repr(), '^<capsule object "Pillow Imaging" at 0x[0-9A-F]+>$')

            bits := stdlib.pillow.Image.new("1", [8, 1], 1)
            bits.putpixel([3, 0], 0)
            AhkTest.AssertEqual([
                35, 100, 101, 102, 105, 110, 101, 32, 120, 95, 119, 105, 100, 116, 104, 32, 56, 10,
                35, 100, 101, 102, 105, 110, 101, 32, 120, 95, 104, 101, 105, 103, 104, 116, 32, 49, 10,
                115, 116, 97, 116, 105, 99, 32, 99, 104, 97, 114, 32, 120, 95, 98, 105, 116, 115, 91, 93, 32, 61, 32, 123, 10,
                48, 120, 102, 55, 10, 125, 59,
            ], bits.tobitmap("x"))
            AhkTest.AssertEqual([
                35, 100, 101, 102, 105, 110, 101, 32, 105, 109, 97, 103, 101, 95, 119, 105, 100, 116, 104, 32, 56, 10,
                35, 100, 101, 102, 105, 110, 101, 32, 105, 109, 97, 103, 101, 95, 104, 101, 105, 103, 104, 116, 32, 49, 10,
                115, 116, 97, 116, 105, 99, 32, 99, 104, 97, 114, 32, 105, 109, 97, 103, 101, 95, 98, 105, 116, 115, 91, 93, 32, 61, 32, 123, 10,
                48, 120, 102, 55, 10, 125, 59,
            ], bits.tobitmap())
            AhkTest.RaisesMatch(ValueError, "^not a bitmap$", (*) => image.tobitmap("rgb"))

            AhkTest.RaisesMatch(TypeError, "^Image\.draft\(\) missing 2 required positional arguments: 'mode' and 'size'$", (*) => image.draft())
            AhkTest.RaisesMatch(TypeError, "^Image\.draft\(\) takes 3 positional arguments but 4 were given$", (*) => image.draft("L", [1, 1], 2))
            AhkTest.RaisesMatch(TypeError, "^Image\.get_child_images\(\) takes 1 positional argument but 2 were given$", (*) => image.get_child_images(1))
            AhkTest.RaisesMatch(TypeError, "^Image\.getxmp\(\) takes 1 positional argument but 2 were given$", (*) => image.getxmp(1))
            AhkTest.RaisesMatch(TypeError, "^Image\.getim\(\) takes 1 positional argument but 2 were given$", (*) => image.getim(1))
        } finally {
            if IsSet(bits)
                StdlibPillowTest.CloseImage(bits)
            if IsSet(opened)
                StdlibPillowTest.CloseImage(opened)
            if IsSet(image)
                StdlibPillowTest.CloseImage(image)
            if FileExist(path)
                FileDelete path
        }
    }

    static TestImageInstanceShowAndQtBridgeMethodsMatchLocalPillow113()
    {
        imageShow := stdlib.pillow.ImageShow
        savedViewers := imageShow._viewers.Clone()
        image := unset
        qimage := unset
        qpixmap := unset
        try {
            image := stdlib.pillow.Image.new("RGB", [2, 1])
            image.putdata([[1, 2, 3], [4, 5, 6]])

            imageShow.clear_viewers()
            viewer := StdlibPillowRecordingViewer(1)
            imageShow.register(viewer)
            AhkTest.AssertSame(stdlib.None, image.show("demo title"))
            AhkTest.AssertEqual([["RGB", [2, 1], Map("title", "demo title")]], viewer.Calls)

            imageShow.clear_viewers()
            AhkTest.AssertSame(stdlib.None, image.show())
            AhkTest.RaisesMatch(TypeError, "^Image\.show\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => image.show("a", "b"))

            qimage := image.toqimage()
            AhkTest.AssertEqual("ImageQt", Type(qimage))
            AhkTest.AssertEqual(2, qimage.width())
            AhkTest.AssertEqual(1, qimage.height())
            AhkTest.AssertEqual("Format_RGB32", qimage.format().name)
            AhkTest.AssertEqual([4278256131, 4278453510], qimage.pixels())

            qpixmap := image.toqpixmap()
            AhkTest.AssertTrue(HasMethod(qpixmap, "toImage"))
            AhkTest.AssertEqual(2, qpixmap.width())
            AhkTest.AssertEqual(1, qpixmap.height())
            AhkTest.AssertFalse(qpixmap.isNull())
            AhkTest.AssertEqual([4278256131, 4278453510], qpixmap.toImage().pixels())

            AhkTest.RaisesMatch(TypeError, "^Image\.toqimage\(\) takes 1 positional argument but 2 were given$", (*) => image.toqimage(1))
            AhkTest.RaisesMatch(TypeError, "^Image\.toqpixmap\(\) takes 1 positional argument but 2 were given$", (*) => image.toqpixmap(1))
        } finally {
            imageShow.restore_viewers(savedViewers)
            if IsSet(image)
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestImageFrombytesAndFrombufferMatchLocalPillow113()
    {
        rgb := unset
        gray := unset
        rgba := unset
        bits := unset
        bgr := unset
        bufferRgb := unset
        bufferGray := unset
        try {
            rgb := stdlib.pillow.Image.frombytes("RGB", [2, 1], [1, 2, 3, 4, 5, 6])
            AhkTest.AssertEqual("RGB", rgb.mode)
            AhkTest.AssertEqual([2, 1], rgb.size)
            AhkTest.AssertEqual(0, rgb.readonly)
            AhkTest.AssertEqual([[1, 2, 3], [4, 5, 6]], rgb.getdata())

            gray := stdlib.pillow.Image.frombytes("L", [3, 1], [7, 8, 9])
            AhkTest.AssertEqual("L", gray.mode)
            AhkTest.AssertEqual([3, 1], gray.size)
            AhkTest.AssertEqual(0, gray.readonly)
            AhkTest.AssertEqual([7, 8, 9], gray.getdata())

            rgba := stdlib.pillow.Image.frombytes("RGBA", [2, 1], [1, 2, 3, 4, 5, 6, 7, 8])
            AhkTest.AssertEqual("RGBA", rgba.mode)
            AhkTest.AssertEqual([[1, 2, 3, 4], [5, 6, 7, 8]], rgba.getdata())

            bits := stdlib.pillow.Image.frombytes("1", [8, 1], [0x60])
            AhkTest.AssertEqual("1", bits.mode)
            AhkTest.AssertEqual([0, 255, 255, 0, 0, 0, 0, 0], bits.getdata())
            AhkTest.AssertEqual([96], bits.tobytes())

            bgr := stdlib.pillow.Image.frombytes("RGB", [2, 1], [1, 2, 3, 4, 5, 6], "raw", "BGR")
            AhkTest.AssertEqual([[3, 2, 1], [6, 5, 4]], bgr.getdata())

            bufferRgb := stdlib.pillow.Image.frombuffer("RGB", [2, 1], [9, 8, 7, 6, 5, 4])
            AhkTest.AssertEqual("RGB", bufferRgb.mode)
            AhkTest.AssertEqual([2, 1], bufferRgb.size)
            AhkTest.AssertEqual(0, bufferRgb.readonly)
            AhkTest.AssertEqual([[9, 8, 7], [6, 5, 4]], bufferRgb.getdata())

            bufferGray := stdlib.pillow.Image.frombuffer("L", [3, 1], [10, 20, 30], "raw", "L", 0, 1)
            AhkTest.AssertEqual("L", bufferGray.mode)
            AhkTest.AssertEqual(1, bufferGray.readonly)
            AhkTest.AssertEqual([10, 20, 30], bufferGray.getdata())

            AhkTest.RaisesMatch(ValueError, "^unrecognized image mode$", (*) => stdlib.pillow.Image.frombytes("BAD", [1, 1], [0]))
            AhkTest.RaisesMatch(ValueError, "^not enough image data$", (*) => stdlib.pillow.Image.frombytes("RGB", [2, 1], [1, 2, 3]))
            AhkTest.RaisesMatch(OSError, "^decoder bad not available$", (*) => stdlib.pillow.Image.frombytes("RGB", [1, 1], [0, 0, 0], "bad"))
            AhkTest.RaisesMatch(ValueError, "^unrecognized image mode$", (*) => stdlib.pillow.Image.frombuffer("BAD", [1, 1], [0]))
            AhkTest.RaisesMatch(ValueError, "^not enough image data$", (*) => stdlib.pillow.Image.frombuffer("RGB", [2, 1], [1, 2, 3]))
            AhkTest.RaisesMatch(OSError, "^decoder bad not available$", (*) => stdlib.pillow.Image.frombuffer("RGB", [1, 1], [0, 0, 0], "bad"))
        } finally {
            if IsSet(bufferGray)
                StdlibPillowTest.CloseImage(bufferGray)
            if IsSet(bufferRgb)
                StdlibPillowTest.CloseImage(bufferRgb)
            if IsSet(bgr)
                StdlibPillowTest.CloseImage(bgr)
            if IsSet(bits)
                StdlibPillowTest.CloseImage(bits)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
        }
    }

    static TestImageModesAndSystemFormatsMatchLocalPillow113()
    {
        pngPath := StdlibPillowTest.TempPath("formats.png")
        bmpPath := StdlibPillowTest.TempPath("formats.bmp")
        jpgPath := StdlibPillowTest.TempPath("formats.jpg")
        gray := unset
        rgba := unset
        rgb := unset
        png := unset
        bmp := unset
        jpg := unset
        try {
            gray := stdlib.pillow.Image.new("L", [2, 1], 12)
            AhkTest.AssertEqual("L", gray.mode)
            AhkTest.AssertEqual([2, 1], gray.size)
            AhkTest.AssertEqual(12, gray.getpixel([0, 0]))
            AhkTest.AssertSame(stdlib.None, gray.putpixel([1, 0], 240))
            AhkTest.AssertEqual(240, gray.getpixel([1, 0]))

            rgba := stdlib.pillow.Image.new("RGBA", [2, 1], [1, 2, 3, 4])
            AhkTest.AssertEqual("RGBA", rgba.mode)
            AhkTest.AssertEqual([2, 1], rgba.size)
            AhkTest.AssertEqual([1, 2, 3, 4], rgba.getpixel([0, 0]))
            AhkTest.AssertSame(stdlib.None, rgba.putpixel([1, 0], [250, 20, 30, 128]))
            AhkTest.AssertEqual([250, 20, 30, 128], rgba.getpixel([1, 0]))

            rgb := stdlib.pillow.Image.new("RGB", [2, 1], [10, 20, 30])
            rgb.putpixel([1, 0], [200, 100, 50])
            AhkTest.AssertSame(stdlib.None, rgb.save(pngPath))
            AhkTest.AssertSame(stdlib.None, rgb.save(bmpPath))
            AhkTest.AssertSame(stdlib.None, rgb.save(jpgPath))

            png := stdlib.pillow.Image.open(pngPath)
            bmp := stdlib.pillow.Image.open(bmpPath)
            jpg := stdlib.pillow.Image.open(jpgPath)
            AhkTest.AssertEqual("PNG", png.format)
            AhkTest.AssertEqual("RGB", png.mode)
            AhkTest.AssertEqual([2, 1], png.size)
            AhkTest.AssertEqual([10, 20, 30], png.getpixel([0, 0]))
            AhkTest.AssertEqual("BMP", bmp.format)
            AhkTest.AssertEqual("RGB", bmp.mode)
            AhkTest.AssertEqual([2, 1], bmp.size)
            AhkTest.AssertEqual([10, 20, 30], bmp.getpixel([0, 0]))
            AhkTest.AssertEqual("JPEG", jpg.format)
            AhkTest.AssertEqual("RGB", jpg.mode)
            AhkTest.AssertEqual([2, 1], jpg.size)
        } finally {
            if IsSet(jpg)
                StdlibPillowTest.CloseImage(jpg)
            if IsSet(bmp)
                StdlibPillowTest.CloseImage(bmp)
            if IsSet(png)
                StdlibPillowTest.CloseImage(png)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
            for path in [pngPath, bmpPath, jpgPath] {
                if FileExist(path)
                    FileDelete path
            }
        }
    }

    static TestImageOpenSaveTiffBuiltinMatchesLocalPillow113()
    {
        tiffPath := StdlibPillowTest.TempPath("formats.tif")
        rgb := unset
        gray := unset
        rgba := unset
        openedPath := unset
        openedAllowed := unset
        openedStream := unset
        openedGray := unset
        openedRgba := unset
        try {
            rgb := stdlib.pillow.Image.new("RGB", [2, 2])
            rgb.putdata([[10, 20, 30], [200, 40, 50], [5, 180, 90], [255, 250, 245]])
            AhkTest.AssertSame(stdlib.None, rgb.save(tiffPath))
            tiffBytes := StdlibPillowTest.ReadBytes(tiffPath)
            AhkTest.AssertEqual([73, 73, 42, 0], StdlibPillowTest.ArraySlice(tiffBytes, 1, 4))

            openedPath := stdlib.pillow.Image.open(tiffPath)
            AhkTest.AssertEqual("TIFF", openedPath.format)
            AhkTest.AssertEqual("Adobe TIFF", openedPath.format_description)
            AhkTest.AssertEqual("RGB", openedPath.mode)
            AhkTest.AssertEqual([2, 2], openedPath.size)
            AhkTest.AssertEqual([[10, 20, 30], [200, 40, 50], [5, 180, 90], [255, 250, 245]], openedPath.getdata())

            openedAllowed := stdlib.pillow.Image.open(tiffPath, "r", ["TIFF"])
            AhkTest.AssertEqual("TIFF", openedAllowed.format)
            AhkTest.AssertEqual([200, 40, 50], openedAllowed.getpixel([1, 0]))

            tiffFp := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, rgb.save(tiffFp, "TIFF"))
            AhkTest.AssertEqual([73, 73, 42, 0], StdlibPillowTest.ArraySlice(tiffFp.getvalue(), 1, 4))
            openedStream := stdlib.pillow.Image.open(stdlib.io.BytesIO(tiffFp.getvalue()), "r", ["TIFF"])
            AhkTest.AssertEqual("TIFF", openedStream.format)
            AhkTest.AssertEqual("Adobe TIFF", openedStream.format_description)
            AhkTest.AssertEqual([[10, 20, 30], [200, 40, 50], [5, 180, 90], [255, 250, 245]], openedStream.getdata())
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(tiffFp.getvalue()), "r", ["PNG"]))

            gray := stdlib.pillow.Image.new("L", [3, 1])
            gray.putdata([0, 127, 255])
            grayFp := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, gray.save(grayFp, "TIFF"))
            openedGray := stdlib.pillow.Image.open(stdlib.io.BytesIO(grayFp.getvalue()), "r", ["TIFF"])
            AhkTest.AssertEqual("TIFF", openedGray.format)
            AhkTest.AssertEqual("L", openedGray.mode)
            AhkTest.AssertEqual([0, 127, 255], openedGray.getdata())

            rgba := stdlib.pillow.Image.new("RGBA", [2, 1], [1, 2, 3, 4])
            rgba.putpixel([1, 0], [250, 20, 30, 128])
            rgbaFp := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, rgba.save(rgbaFp, "TIFF"))
            openedRgba := stdlib.pillow.Image.open(stdlib.io.BytesIO(rgbaFp.getvalue()), "r", ["TIFF"])
            AhkTest.AssertEqual("TIFF", openedRgba.format)
            AhkTest.AssertEqual("RGBA", openedRgba.mode)
            AhkTest.AssertEqual([[1, 2, 3, 4], [250, 20, 30, 128]], openedRgba.getdata())
        } finally {
            if IsSet(openedRgba)
                StdlibPillowTest.CloseImage(openedRgba)
            if IsSet(openedGray)
                StdlibPillowTest.CloseImage(openedGray)
            if IsSet(openedStream)
                StdlibPillowTest.CloseImage(openedStream)
            if IsSet(openedAllowed)
                StdlibPillowTest.CloseImage(openedAllowed)
            if IsSet(openedPath)
                StdlibPillowTest.CloseImage(openedPath)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
            if FileExist(tiffPath)
                FileDelete tiffPath
        }
    }

    static TestImageSaveBuiltinFileLikeMatchesLocalPillow113()
    {
        rgba := unset
        rgb := unset
        try {
            rgba := stdlib.pillow.Image.new("RGBA", [2, 1], [1, 2, 3, 4])
            rgba.putpixel([1, 0], [250, 20, 30, 128])
            rgb := stdlib.pillow.Image.new("RGB", [2, 1], [10, 20, 30])
            rgb.putpixel([1, 0], [250, 20, 30])

            pngFp := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, rgba.save(pngFp, "PNG"))
            AhkTest.AssertEqual([137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82], StdlibPillowTest.ArraySlice(pngFp.getvalue(), 1, 16))
            AhkTest.AssertTrue(pngFp.getvalue().Length > 16)
            AhkTest.AssertEqual(pngFp.getvalue().Length, pngFp.tell())
            AhkTest.AssertFalse(pngFp.closed)

            bmpFp := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, rgb.save(bmpFp, "BMP"))
            AhkTest.AssertEqual([66, 77], StdlibPillowTest.ArraySlice(bmpFp.getvalue(), 1, 2))
            AhkTest.AssertTrue(bmpFp.getvalue().Length > 16)
            AhkTest.AssertEqual(bmpFp.getvalue().Length, bmpFp.tell())
            AhkTest.AssertFalse(bmpFp.closed)

            jpegFp := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, rgb.save(jpegFp, "JPEG"))
            AhkTest.AssertEqual([255, 216, 255], StdlibPillowTest.ArraySlice(jpegFp.getvalue(), 1, 3))
            AhkTest.AssertTrue(jpegFp.getvalue().Length > 16)
            AhkTest.AssertEqual(jpegFp.getvalue().Length, jpegFp.tell())
            AhkTest.AssertFalse(jpegFp.closed)

            noFormatFp := stdlib.io.BytesIO()
            AhkTest.RaisesMatch(ValueError, "^unknown file extension: $", (*) => rgb.save(noFormatFp))
            AhkTest.AssertEqual([], noFormatFp.getvalue())
            AhkTest.AssertEqual(0, noFormatFp.tell())
            AhkTest.AssertFalse(noFormatFp.closed)
        } finally {
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
        }
    }

    static TestImageOpenBuiltinFileLikeMatchesLocalPillow113()
    {
        rgba := unset
        rgb := unset
        png := unset
        bmp := unset
        jpeg := unset
        try {
            rgba := stdlib.pillow.Image.new("RGBA", [2, 1], [1, 2, 3, 4])
            rgba.putpixel([1, 0], [250, 20, 30, 128])
            rgb := stdlib.pillow.Image.new("RGB", [2, 1], [10, 20, 30])
            rgb.putpixel([1, 0], [200, 100, 50])

            pngFp := stdlib.io.BytesIO()
            bmpFp := stdlib.io.BytesIO()
            jpegFp := stdlib.io.BytesIO()
            rgba.save(pngFp, "PNG")
            rgb.save(bmpFp, "BMP")
            rgb.save(jpegFp, "JPEG")

            pngStream := stdlib.io.BytesIO(pngFp.getvalue())
            png := stdlib.pillow.Image.open(pngStream)
            AhkTest.AssertEqual("PNG", png.format)
            AhkTest.AssertEqual("RGBA", png.mode)
            AhkTest.AssertEqual([2, 1], png.size)
            AhkTest.AssertEqual([250, 20, 30, 128], png.getpixel([1, 0]))
            AhkTest.AssertFalse(pngStream.closed)

            bmpStream := stdlib.io.BytesIO(bmpFp.getvalue())
            bmp := stdlib.pillow.Image.open(bmpStream)
            AhkTest.AssertEqual("BMP", bmp.format)
            AhkTest.AssertEqual("RGB", bmp.mode)
            AhkTest.AssertEqual([2, 1], bmp.size)
            AhkTest.AssertEqual([200, 100, 50], bmp.getpixel([1, 0]))
            AhkTest.AssertFalse(bmpStream.closed)

            jpegStream := stdlib.io.BytesIO(jpegFp.getvalue())
            jpeg := stdlib.pillow.Image.open(jpegStream)
            AhkTest.AssertEqual("JPEG", jpeg.format)
            AhkTest.AssertEqual("RGB", jpeg.mode)
            AhkTest.AssertEqual([2, 1], jpeg.size)
            AhkTest.AssertFalse(jpegStream.closed)

            invalidStream := stdlib.io.BytesIO([110, 111, 116, 32, 97, 110, 32, 105, 109, 97, 103, 101])
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(invalidStream))
            AhkTest.AssertFalse(invalidStream.closed)
        } finally {
            if IsSet(jpeg)
                StdlibPillowTest.CloseImage(jpeg)
            if IsSet(bmp)
                StdlibPillowTest.CloseImage(bmp)
            if IsSet(png)
                StdlibPillowTest.CloseImage(png)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
        }
    }

    static TestImageOpenBuiltinFormatsFilterMatchesLocalPillow113()
    {
        pngPath := StdlibPillowTest.TempPath("formats-filter.png")
        image := unset
        pathPng := unset
        pathLower := unset
        streamPng := unset
        streamLower := unset
        streamWithUnrelatedOpen := unset
        try {
            image := stdlib.pillow.Image.new("RGB", [2, 1], [10, 20, 30])
            image.putpixel([1, 0], [200, 100, 50])
            image.save(pngPath)

            pngBytes := StdlibPillowTest.ReadBytes(pngPath)
            pathPng := stdlib.pillow.Image.open(pngPath, "r", ["PNG"])
            AhkTest.AssertEqual("PNG", pathPng.format)
            AhkTest.AssertEqual("RGB", pathPng.mode)
            AhkTest.AssertEqual([2, 1], pathPng.size)
            AhkTest.AssertEqual([200, 100, 50], pathPng.getpixel([1, 0]))

            pathLower := stdlib.pillow.Image.open(pngPath, "r", ["png"])
            AhkTest.AssertEqual("PNG", pathLower.format)

            streamPng := stdlib.pillow.Image.open(stdlib.io.BytesIO(pngBytes), "r", ["PNG"])
            AhkTest.AssertEqual("PNG", streamPng.format)
            AhkTest.AssertEqual([200, 100, 50], streamPng.getpixel([1, 0]))

            streamLower := stdlib.pillow.Image.open(stdlib.io.BytesIO(pngBytes), "r", ["png"])
            AhkTest.AssertEqual("PNG", streamLower.format)

            StdlibPillowOpenFactory.Events := []
            AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_open("AHKSTDLIB_UNRELATED_OPEN", StdlibPillowOpenFactory, StdlibPillowOpenAccept))
            streamWithUnrelatedOpen := stdlib.pillow.Image.open(stdlib.io.BytesIO(pngBytes), "r", ["PNG"])
            AhkTest.AssertEqual("PNG", streamWithUnrelatedOpen.format)
            AhkTest.AssertEqual([200, 100, 50], streamWithUnrelatedOpen.getpixel([1, 0]))

            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(pngPath, "r", ["JPEG"]))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(pngBytes), "r", ["JPEG"]))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(pngPath, "r", []))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(pngBytes), "r", []))
            AhkTest.RaisesMatch(TypeError, "^formats must be a list or tuple$", (*) => stdlib.pillow.Image.open(pngPath, "r", "PNG"))
        } finally {
            if IsSet(streamWithUnrelatedOpen)
                StdlibPillowTest.CloseImage(streamWithUnrelatedOpen)
            if IsSet(streamLower)
                StdlibPillowTest.CloseImage(streamLower)
            if IsSet(streamPng)
                StdlibPillowTest.CloseImage(streamPng)
            if IsSet(pathLower)
                StdlibPillowTest.CloseImage(pathLower)
            if IsSet(pathPng)
                StdlibPillowTest.CloseImage(pathPng)
            if IsSet(image)
                StdlibPillowTest.CloseImage(image)
            if FileExist(pngPath)
                FileDelete pngPath
        }
    }

    static TestImageEffectMandelbrotMatchesLocalPillow113()
    {
        first := unset
        square := unset
        flat := unset
        try {
            first := stdlib.pillow.Image.effect_mandelbrot([4, 3], [-2.0, -1.0, 1.0, 1.0], 10)
            AhkTest.AssertEqual("L", first.mode)
            AhkTest.AssertEqual([4, 3], first.size)
            AhkTest.AssertEqual(0, first.readonly)
            AhkTest.AssertEqual([
                [76, 102, 0, 102],
                [0, 0, 0, 102],
                [76, 102, 0, 102],
            ], StdlibPillowTest.PixelRows(first))
            firstHistogram := first.histogram()
            AhkTest.AssertEqual([5, 0, 0, 0, 0, 0, 0, 0], [firstHistogram[1], firstHistogram[2], firstHistogram[3], firstHistogram[4], firstHistogram[5], firstHistogram[6], firstHistogram[7], firstHistogram[8]])

            square := stdlib.pillow.Image.effect_mandelbrot([3, 3], [-1.0, -1.0, 1.0, 1.0], 20)
            AhkTest.AssertEqual([
                [51, 0, 51],
                [0, 0, 51],
                [51, 0, 51],
            ], StdlibPillowTest.PixelRows(square))

            flat := stdlib.pillow.Image.effect_mandelbrot([2, 2], [0.0, 0.0, 0.0, 0.0], 5)
            AhkTest.AssertEqual([
                [0, 0],
                [0, 0],
            ], StdlibPillowTest.PixelRows(flat))

            AhkTest.RaisesMatch(TypeError, "^argument 1 must be sequence of length 2, not 1$", (*) => stdlib.pillow.Image.effect_mandelbrot([1], [-2.0, -1.0, 1.0, 1.0], 10))
            AhkTest.RaisesMatch(TypeError, "^argument 2 must be sequence of length 4, not 3$", (*) => stdlib.pillow.Image.effect_mandelbrot([2, 2], [0.0, 0.0, 1.0], 10))
            AhkTest.RaisesMatch(TypeError, "^'str' object cannot be interpreted as an integer$", (*) => stdlib.pillow.Image.effect_mandelbrot([2, 2], [-1.0, -1.0, 1.0, 1.0], "x"))
        } finally {
            if IsSet(flat)
                StdlibPillowTest.CloseImage(flat)
            if IsSet(square)
                StdlibPillowTest.CloseImage(square)
            if IsSet(first)
                StdlibPillowTest.CloseImage(first)
        }
    }

    static TestImageEffectNoiseMatchesLocalPillow113()
    {
        zero := unset
        nonzero := unset
        empty := unset
        try {
            AhkTest.AssertTrue(HasMethod(stdlib.pillow.Image, "effect_noise"))

            zero := stdlib.pillow.Image.effect_noise([3, 2], 0)
            AhkTest.AssertEqual("L", zero.mode)
            AhkTest.AssertEqual([3, 2], zero.size)
            AhkTest.AssertEqual(0, zero.readonly)
            AhkTest.AssertEqual([
                [128, 128, 128],
                [128, 128, 128],
            ], StdlibPillowTest.PixelRows(zero))

            nonzero := stdlib.pillow.Image.effect_noise([4, 3], 10)
            AhkTest.AssertEqual("L", nonzero.mode)
            AhkTest.AssertEqual([4, 3], nonzero.size)
            for row in StdlibPillowTest.PixelRows(nonzero) {
                for pixel in row {
                    AhkTest.AssertTrue(pixel is Integer)
                    AhkTest.AssertTrue(pixel >= 0 && pixel <= 255)
                }
            }

            empty := stdlib.pillow.Image.effect_noise([0, 0], 10)
            AhkTest.AssertEqual("L", empty.mode)
            AhkTest.AssertEqual([0, 0], empty.size)
            AhkTest.AssertEqual([], empty.getdata())

            AhkTest.RaisesMatch(TypeError, "^effect_noise\(\) missing 1 required positional argument: 'sigma'$", (*) => stdlib.pillow.Image.effect_noise([2, 2]))
            AhkTest.RaisesMatch(TypeError, "^effect_noise\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.pillow.Image.effect_noise([2, 2], 10, 1))
            AhkTest.RaisesMatch(TypeError, "^argument 1 must be sequence of length 2, not 1$", (*) => stdlib.pillow.Image.effect_noise([1], 10))
            AhkTest.RaisesMatch(ValueError, "^bad image size$", (*) => stdlib.pillow.Image.effect_noise([-1, 2], 10))
            AhkTest.RaisesMatch(TypeError, "^must be real number, not str$", (*) => stdlib.pillow.Image.effect_noise([2, 2], "x"))
        } finally {
            if IsSet(empty)
                StdlibPillowTest.CloseImage(empty)
            if IsSet(nonzero)
                StdlibPillowTest.CloseImage(nonzero)
            if IsSet(zero)
                StdlibPillowTest.CloseImage(zero)
        }
    }

    static TestImageIsPathMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasMethod(stdlib.pillow.Image, "is_path"))

        AhkTest.AssertTrue(stdlib.pillow.Image.is_path("x.png"))
        AhkTest.AssertTrue(stdlib.pillow.Image.is_path(stdlib.pathlib.Path("x.png")))
        AhkTest.AssertTrue(stdlib.pillow.Image.is_path(StdlibPillowPathLike()))
        AhkTest.AssertFalse(stdlib.pillow.Image.is_path(stdlib.io.BytesIO([120])))
        AhkTest.AssertFalse(stdlib.pillow.Image.is_path(stdlib.None))
        AhkTest.AssertFalse(stdlib.pillow.Image.is_path(1))
        AhkTest.AssertFalse(stdlib.pillow.Image.is_path({}))
        AhkTest.AssertFalse(stdlib.pillow.Image.is_path([120]))
        AhkTest.AssertFalse(stdlib.pillow.Image.is_path(Buffer(1, 0)))

        AhkTest.RaisesMatch(TypeError, "^is_path\(\) missing 1 required positional argument: 'f'$", (*) => stdlib.pillow.Image.is_path())
        AhkTest.RaisesMatch(TypeError, "^is_path\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.pillow.Image.is_path("x.png", "y.png"))
    }

    static TestImagePublicErrorsAndConstantsMatchLocalPillow113()
    {
        AhkTest.AssertEqual(89478485, stdlib.pillow.Image.MAX_IMAGE_PIXELS)
        AhkTest.AssertFalse(stdlib.pillow.Image.WARN_POSSIBLE_FORMATS)

        unidentifiedClass := stdlib.pillow.Image.UnidentifiedImageError
        warningClass := stdlib.pillow.Image.DecompressionBombWarning
        bombErrorClass := stdlib.pillow.Image.DecompressionBombError

        AhkTest.AssertEqual("AhkStdlibPillowUnidentifiedImageError", unidentifiedClass.Prototype.__Class)
        AhkTest.AssertEqual("AhkStdlibPillowDecompressionBombWarning", warningClass.Prototype.__Class)
        AhkTest.AssertEqual("AhkStdlibPillowDecompressionBombError", bombErrorClass.Prototype.__Class)

        unidentified := stdlib.pillow.Image.UnidentifiedImageError("boom")
        warning := stdlib.pillow.Image.DecompressionBombWarning("boom")
        bombError := stdlib.pillow.Image.DecompressionBombError("boom")
        unidentifiedEmpty := stdlib.pillow.Image.UnidentifiedImageError()
        warningEmpty := stdlib.pillow.Image.DecompressionBombWarning()
        bombErrorEmpty := stdlib.pillow.Image.DecompressionBombError()

        AhkTest.AssertEqual("AhkStdlibPillowUnidentifiedImageError", Type(unidentified))
        AhkTest.AssertEqual("boom", unidentified.Message)
        AhkTest.AssertEqual("", unidentifiedEmpty.Message)
        AhkTest.AssertTrue(unidentified is OSError)
        AhkTest.AssertTrue(warning is Error)
        AhkTest.AssertTrue(bombError is Error)
        AhkTest.AssertEqual("AhkStdlibPillowDecompressionBombWarning", Type(warning))
        AhkTest.AssertEqual("boom", warning.Message)
        AhkTest.AssertEqual("", warningEmpty.Message)
        AhkTest.AssertEqual("AhkStdlibPillowDecompressionBombError", Type(bombError))
        AhkTest.AssertEqual("boom", bombError.Message)
        AhkTest.AssertEqual("", bombErrorEmpty.Message)

        AhkTest.RaisesMatch(stdlib.pillow.Image.UnidentifiedImageError, "^boom$", (*) => StdlibPillowTestThrow(unidentified))
        AhkTest.RaisesMatch(stdlib.pillow.Image.DecompressionBombWarning, "^boom$", (*) => StdlibPillowTestThrow(warning))
        AhkTest.RaisesMatch(stdlib.pillow.Image.DecompressionBombError, "^boom$", (*) => StdlibPillowTestThrow(bombError))
    }

    static TestImageLegacyAliasesAndHandlersMatchLocalPillow113()
    {
        AhkTest.AssertEqual(0, stdlib.pillow.Image.NEAREST)
        AhkTest.AssertEqual(1, stdlib.pillow.Image.LANCZOS)
        AhkTest.AssertEqual(2, stdlib.pillow.Image.BILINEAR)
        AhkTest.AssertEqual(3, stdlib.pillow.Image.BICUBIC)
        AhkTest.AssertEqual(4, stdlib.pillow.Image.BOX)
        AhkTest.AssertEqual(5, stdlib.pillow.Image.HAMMING)

        AhkTest.AssertEqual(0, stdlib.pillow.Image.AFFINE)
        AhkTest.AssertEqual(1, stdlib.pillow.Image.EXTENT)
        AhkTest.AssertEqual(2, stdlib.pillow.Image.PERSPECTIVE)
        AhkTest.AssertEqual(3, stdlib.pillow.Image.QUAD)
        AhkTest.AssertEqual(4, stdlib.pillow.Image.MESH)

        AhkTest.AssertEqual(0, stdlib.pillow.Image.FLIP_LEFT_RIGHT)
        AhkTest.AssertEqual(1, stdlib.pillow.Image.FLIP_TOP_BOTTOM)
        AhkTest.AssertEqual(2, stdlib.pillow.Image.ROTATE_90)
        AhkTest.AssertEqual(3, stdlib.pillow.Image.ROTATE_180)
        AhkTest.AssertEqual(4, stdlib.pillow.Image.ROTATE_270)
        AhkTest.AssertEqual(6, stdlib.pillow.Image.TRANSVERSE)
        AhkTest.AssertSame(stdlib.pillow.Image.Transpose, stdlib.pillow.Image.TRANSPOSE)

        AhkTest.AssertEqual(0, stdlib.pillow.Image.NONE)
        AhkTest.AssertEqual(1, stdlib.pillow.Image.ORDERED)
        AhkTest.AssertEqual(2, stdlib.pillow.Image.RASTERIZE)
        AhkTest.AssertEqual(3, stdlib.pillow.Image.FLOYDSTEINBERG)

        AhkTest.AssertEqual(0, stdlib.pillow.Image.WEB)
        AhkTest.AssertEqual(1, stdlib.pillow.Image.ADAPTIVE)
        AhkTest.AssertEqual(0, stdlib.pillow.Image.MEDIANCUT)
        AhkTest.AssertEqual(1, stdlib.pillow.Image.MAXCOVERAGE)
        AhkTest.AssertEqual(2, stdlib.pillow.Image.FASTOCTREE)
        AhkTest.AssertEqual(3, stdlib.pillow.Image.LIBIMAGEQUANT)

        AhkTest.AssertEqual("AhkStdlibPillowImagePointHandler", stdlib.pillow.Image.ImagePointHandler.Prototype.__Class)
        AhkTest.AssertEqual("AhkStdlibPillowImageTransformHandler", stdlib.pillow.Image.ImageTransformHandler.Prototype.__Class)
        AhkTest.RaisesMatch(TypeError, "^Can't instantiate abstract class ImagePointHandler with abstract method point$", (*) => stdlib.pillow.Image.ImagePointHandler())
        AhkTest.RaisesMatch(TypeError, "^Can't instantiate abstract class ImageTransformHandler with abstract method transform$", (*) => stdlib.pillow.Image.ImageTransformHandler())
    }

    static TestImageCmsMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "ImageCms"))
        cms := stdlib.pillow.ImageCms

        AhkTest.AssertEqual("pyCMS", StrSplit(cms.DESCRIPTION, "`n")[2])
        AhkTest.AssertEqual("1.0.0 pil", cms.VERSION)
        AhkTest.AssertEqual("AhkStdlibPillowPyCMSError", cms.PyCMSError.Prototype.__Class)
        AhkTest.AssertEqual(0, cms.Intent.PERCEPTUAL.value)
        AhkTest.AssertEqual("Intent.RELATIVE_COLORIMETRIC", String(cms.Intent.RELATIVE_COLORIMETRIC))
        AhkTest.AssertEqual("<Intent.SATURATION: 2>", cms.Intent.SATURATION.__Repr())
        AhkTest.AssertEqual(2, cms.Direction.PROOF.value)
        AhkTest.AssertEqual("Direction.OUTPUT", String(cms.Direction.OUTPUT))
        AhkTest.AssertEqual(0, cms.Flags.NONE.value)
        AhkTest.AssertEqual(64, cms.Flags.NOCACHE.value)
        AhkTest.AssertEqual(8192, cms.Flags.BLACKPOINTCOMPENSATION.value)
        AhkTest.AssertEqual(67108864, cms.Flags.COPY_ALPHA.value)
        AhkTest.AssertEqual("<Flags.SOFTPROOFING: 16384>", cms.Flags.SOFTPROOFING.__Repr())
        AhkTest.AssertEqual(1, cms.FLAGS["MATRIXINPUT"])
        AhkTest.AssertEqual(2, cms.FLAGS["MATRIXOUTPUT"])
        AhkTest.AssertEqual(3, cms.FLAGS["MATRIXONLY"])
        AhkTest.AssertEqual(8192, cms.FLAGS["BLACKPOINTCOMPENSATION"])
        AhkTest.AssertEqual(16384, cms.FLAGS["SOFTPROOFING"])
        AhkTest.AssertEqual(458752, cms.FLAGS["GRIDPOINTS"].Call(7))

        records := stdlib.warnings.catch_warnings(true).Call((records) => cms.versions())
        AhkTest.AssertEqual(1, records.Length)
        AhkTest.AssertSame(stdlib.warnings.DeprecationWarning, records[1].category)
        AhkTest.AssertEqual('PIL.ImageCms.versions() is deprecated and will be removed in Pillow 12 (2025-10-15). Use (PIL.features.version("littlecms2"), sys.version, PIL.__version__) instead.', records[1].message)
        AhkTest.AssertEqual(["1.0.0 pil", "2.17", "3.10.11", "11.3.0"], cms.versions())

        srgbCore := cms.createProfile("sRGB")
        labCore := cms.createProfile("LAB", 6500)
        xyzCore := cms.createProfile("XYZ")
        AhkTest.AssertEqual("CmsProfile", srgbCore.AhkStdlibCmsType)
        AhkTest.AssertEqual("sRGB", srgbCore.colorSpace)
        AhkTest.AssertEqual("LAB", labCore.colorSpace)
        AhkTest.AssertEqual("XYZ", xyzCore.colorSpace)

        srgbProfile := cms.getOpenProfile(srgbCore)
        AhkTest.AssertEqual("AhkStdlibPillowImageCmsProfile", Type(srgbProfile))
        AhkTest.AssertSame(stdlib.None, srgbProfile.filename)
        AhkTest.AssertSame(stdlib.None, srgbProfile.product_name)
        AhkTest.AssertSame(stdlib.None, srgbProfile.product_info)
        AhkTest.AssertEqual("sRGB built-in`n", cms.getProfileName(srgbProfile))
        AhkTest.AssertEqual("sRGB built-in`n", cms.getProfileDescription(srgbProfile))
        AhkTest.AssertEqual("sRGB built-in`r`n`r`nNo copyright, use freely`r`n`r`n", cms.getProfileInfo(srgbProfile))
        AhkTest.AssertEqual("No copyright, use freely`n", cms.getProfileCopyright(srgbProfile))
        AhkTest.AssertEqual("`n", cms.getProfileManufacturer(srgbProfile))
        AhkTest.AssertEqual("`n", cms.getProfileModel(srgbProfile))
        AhkTest.AssertEqual(0, cms.getDefaultIntent(srgbProfile))

        srgbBytes := srgbProfile.tobytes()
        AhkTest.AssertEqual(588, srgbBytes.Length)
        AhkTest.AssertEqual([0, 0, 2, 76, 108, 99, 109, 115, 4, 64, 0, 0], StdlibPillowTest.ArraySlice(srgbBytes, 1, 12))
        AhkTest.AssertEqual([0, 0, 38, 102, 0, 0, 15, 92], StdlibPillowTest.ArraySlice(srgbBytes, srgbBytes.Length - 7, srgbBytes.Length))
        fromBytes := cms.getOpenProfile(stdlib.io.BytesIO(srgbBytes))
        AhkTest.AssertEqual("sRGB built-in`n", cms.getProfileName(fromBytes))

        for intent in [cms.Intent.PERCEPTUAL, cms.Intent.RELATIVE_COLORIMETRIC, cms.Intent.SATURATION, cms.Intent.ABSOLUTE_COLORIMETRIC] {
            for direction in [cms.Direction.INPUT, cms.Direction.OUTPUT, cms.Direction.PROOF]
                AhkTest.AssertEqual(1, cms.isIntentSupported(srgbProfile, intent, direction))
        }

        image := stdlib.pillow.Image.new("RGB", [2, 1])
        image.putdata([[1, 2, 3], [200, 150, 100]])
        transform := cms.buildTransform(srgbProfile, srgbProfile, "RGB", "RGB")
        AhkTest.AssertEqual("AhkStdlibPillowImageCmsTransform", Type(transform))
        AhkTest.AssertEqual("RGB", transform.input_mode)
        AhkTest.AssertEqual("RGB", transform.inputMode)
        AhkTest.AssertEqual("RGB", transform.output_mode)
        AhkTest.AssertEqual("RGB", transform.outputMode)
        AhkTest.AssertEqual(588, transform.output_profile.tobytes().Length)

        applied := cms.applyTransform(image, transform)
        AhkTest.AssertEqual("RGB", applied.mode)
        AhkTest.AssertEqual([2, 1], applied.size)
        AhkTest.AssertEqual([[1, 2, 3], [200, 150, 100]], applied.getdata())
        AhkTest.AssertEqual(588, applied.info["icc_profile"].Length)
        AhkTest.AssertEqual([0, 0, 2, 76], StdlibPillowTest.ArraySlice(applied.info["icc_profile"], 1, 4))

        inPlace := image.copy()
        AhkTest.AssertSame(stdlib.None, cms.applyTransform(inPlace, transform, true))
        AhkTest.AssertEqual([[1, 2, 3], [200, 150, 100]], inPlace.getdata())
        AhkTest.AssertEqual(588, inPlace.info["icc_profile"].Length)

        profiled := cms.profileToProfile(image, srgbProfile, srgbProfile, cms.Intent.PERCEPTUAL, "RGB")
        AhkTest.AssertEqual("RGB", profiled.mode)
        AhkTest.AssertEqual([[1, 2, 3], [200, 150, 100]], profiled.getdata())
        AhkTest.AssertEqual(588, profiled.info["icc_profile"].Length)

        profiledInPlace := image.copy()
        AhkTest.AssertSame(stdlib.None, cms.profileToProfile(profiledInPlace, srgbProfile, srgbProfile, cms.Intent.PERCEPTUAL, stdlib.None, true))
        AhkTest.AssertEqual([[1, 2, 3], [200, 150, 100]], profiledInPlace.getdata())
        AhkTest.AssertEqual(588, profiledInPlace.info["icc_profile"].Length)

        AhkTest.RaisesMatch(cms.PyCMSError, "^Color space not supported for on-the-fly profile creation \(BAD\)$", (*) => cms.createProfile("BAD"))
        AhkTest.RaisesMatch(cms.PyCMSError, '^Color temperature must be numeric, "warm" not valid$', (*) => cms.createProfile("LAB", "warm"))
        AhkTest.RaisesMatch(cms.PyCMSError, "^Invalid type for Profile$", (*) => cms.getOpenProfile(123))
        AhkTest.RaisesMatch(TypeError, "^Invalid type for Profile$", (*) => cms.ImageCmsProfile(123))
        AhkTest.RaisesMatch(cms.PyCMSError, "^renderingIntent must be an integer between 0 and 3$", (*) => cms.buildTransform(srgbProfile, srgbProfile, "RGB", "RGB", 9))
        AhkTest.RaisesMatch(cms.PyCMSError, "^flags must be an integer between 0 and 100663295$", (*) => cms.buildTransform(srgbProfile, srgbProfile, "RGB", "RGB", 0, -1))
    }

    static TestImageGrabMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "ImageGrab"))
        grab := stdlib.pillow.ImageGrab
        AhkTest.AssertTrue(HasMethod(grab, "grab"))
        AhkTest.AssertTrue(HasMethod(grab, "grabclipboard"))

        image := grab.grab([0, 0, 1, 1])
        try {
            AhkTest.AssertEqual("RGB", image.mode)
            AhkTest.AssertEqual([1, 1], image.size)
            AhkTest.AssertSame(stdlib.None, image.format)
            AhkTest.AssertEqual(0, image.readonly)
            pixel := image.getpixel([0, 0])
            AhkTest.AssertEqual(3, pixel.Length)
            for channel in pixel {
                AhkTest.AssertTrue(channel is Integer)
                AhkTest.AssertTrue(channel >= 0)
                AhkTest.AssertTrue(channel <= 255)
            }
        } finally {
            StdlibPillowTest.CloseImage(image)
        }

        keywordImage := grab.grab({
            bbox: [0, 0, 1, 1],
            include_layered_windows: false,
            all_screens: false,
            xdisplay: stdlib.None,
            window: stdlib.None,
        })
        try {
            AhkTest.AssertEqual("RGB", keywordImage.mode)
            AhkTest.AssertEqual([1, 1], keywordImage.size)
        } finally {
            StdlibPillowTest.CloseImage(keywordImage)
        }

        clipboard := grab.grabclipboard()
        AhkTest.AssertTrue(AhkStdlibIsNone(clipboard) || clipboard is Array || (IsObject(clipboard) && HasMethod(clipboard, "getpixel")))

        AhkTest.RaisesMatch(ValueError, "^not enough values to unpack \(expected 4, got 3\)$", (*) => grab.grab([0, 0, 1]))
        AhkTest.RaisesMatch(OSError, "^Pillow was built without XCB support$", (*) => grab.grab({ xdisplay: ":0" }))
        AhkTest.RaisesMatch(TypeError, "^grab\(\) takes from 0 to 5 positional arguments but 6 were given$", (*) => grab.grab(stdlib.None, false, false, stdlib.None, stdlib.None, 1))
        AhkTest.RaisesMatch(TypeError, "^grabclipboard\(\) takes 0 positional arguments but 1 was given$", (*) => grab.grabclipboard(1))
    }

    static TestImageQtMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "ImageQt"))
        imageQt := stdlib.pillow.ImageQt
        AhkTest.AssertTrue(imageQt.qt_is_installed)
        AhkTest.AssertEqual("PySide6", imageQt.qt_module)
        AhkTest.AssertEqual("side6", imageQt.qt_version)
        AhkTest.AssertEqual([["6", "PyQt6"], ["side6", "PySide6"]], imageQt.qt_versions)
        AhkTest.AssertEqual(4278256131, imageQt.rgb(1, 2, 3))
        AhkTest.AssertEqual(67174915, imageQt.rgb(1, 2, 3, 4))
        AhkTest.AssertEqual(0, imageQt.rgb(0, 0, 0, 0))
        AhkTest.AssertEqual(4294967295, imageQt.rgb(255, 255, 255, 255))

        AhkTest.AssertEqual([128, 0, 0, 0], imageQt.align8to32([0x80], 1, "1"))
        AhkTest.AssertEqual([128, 64, 0, 0], imageQt.align8to32([0x80, 0x40], 9, "1"))
        AhkTest.AssertEqual([1, 2, 3, 0, 4, 5, 6, 0], imageQt.align8to32([1, 2, 3, 4, 5, 6], 3, "L"))
        AhkTest.AssertEqual([1, 2, 3, 4, 5, 6, 7, 8], imageQt.align8to32([1, 2, 3, 4, 5, 6, 7, 8], 4, "L"))
        AhkTest.AssertEqual([7, 8, 0, 0, 9, 10, 0, 0], imageQt.align8to32([7, 8, 9, 10], 2, "P"))
        AhkTest.AssertEqual([1, 2, 0, 0, 3, 4, 0, 0], imageQt.align8to32([1, 2, 3, 4], 1, "I;16"))

        rgb := stdlib.pillow.Image.new("RGB", [2, 1])
        rgba := stdlib.pillow.Image.new("RGBA", [2, 1])
        gray := stdlib.pillow.Image.new("L", [3, 1])
        pal := stdlib.pillow.Image.new("P", [3, 1])
        one := stdlib.pillow.Image.new("1", [9, 1])
        i16 := StdlibPillowImageQtFakeImage("I;16", [2, 1], [1, 257])
        cmyk := StdlibPillowImageQtFakeImage("CMYK", [1, 1], [[1, 2, 3, 4]])
        rgbRoundtrip := stdlib.None
        rgbaRoundtrip := stdlib.None
        palRoundtrip := stdlib.None
        i16Roundtrip := stdlib.None
        pixmapRoundtrip := stdlib.None
        path := StdlibPillowTest.TempPath("imageqt-rgb.png")
        try {
            rgb.putdata([[1, 2, 3], [4, 5, 6]])
            rgba.putdata([[1, 2, 3, 4], [5, 6, 7, 8]])
            gray.putdata([1, 128, 255])
            pal.putdata([0, 1, 2])
            imageQtPalette := [10, 20, 30, 40, 50, 60, 70, 80, 90]
            loop 253 {
                imageQtPalette.Push(0)
                imageQtPalette.Push(0)
                imageQtPalette.Push(0)
            }
            pal.putpalette(imageQtPalette)
            one.putdata([0, 255, 0, 255, 255, 0, 0, 255, 0])

            rgbHelper := imageQt._toqclass_helper(rgb)
            AhkTest.AssertEqual([3, 2, 1, 255, 6, 5, 4, 255], rgbHelper["data"])
            AhkTest.AssertEqual([2, 1], rgbHelper["size"])
            AhkTest.AssertEqual("Format_RGB32", rgbHelper["format"].name)
            AhkTest.AssertEqual(4, rgbHelper["format"].value)
            AhkTest.AssertSame(stdlib.None, rgbHelper["colortable"])

            rgbaHelper := imageQt._toqclass_helper(rgba)
            AhkTest.AssertEqual([3, 2, 1, 4, 7, 6, 5, 8], rgbaHelper["data"])
            AhkTest.AssertEqual("Format_ARGB32", rgbaHelper["format"].name)
            AhkTest.AssertEqual(5, rgbaHelper["format"].value)

            grayHelper := imageQt._toqclass_helper(gray)
            AhkTest.AssertEqual([1, 128, 255, 0], grayHelper["data"])
            AhkTest.AssertEqual("Format_Indexed8", grayHelper["format"].name)
            AhkTest.AssertEqual(256, grayHelper["colortable"].Length)
            AhkTest.AssertEqual([4278190080, 4278255873, 4278321666, 4278387459, 4278453252], StdlibPillowTest.ArraySlice(grayHelper["colortable"], 1, 5))

            palHelper := imageQt._toqclass_helper(pal)
            AhkTest.AssertEqual([0, 1, 2, 0], palHelper["data"])
            AhkTest.AssertEqual([4278850590, 4280824380, 4282798170, 4278190080, 4278190080], StdlibPillowTest.ArraySlice(palHelper["colortable"], 1, 5))

            oneHelper := imageQt._toqclass_helper(one)
            AhkTest.AssertEqual([89, 0, 0, 0], oneHelper["data"])
            AhkTest.AssertEqual("Format_Mono", oneHelper["format"].name)
            AhkTest.AssertEqual(1, oneHelper["format"].value)

            i16Helper := imageQt._toqclass_helper(i16)
            AhkTest.AssertEqual([0, 1, 0, 1], i16Helper["data"])
            AhkTest.AssertEqual("Format_Grayscale16", i16Helper["format"].name)
            AhkTest.AssertEqual(28, i16Helper["format"].value)

            rgbaQImage := imageQt.toqimage(rgba)
            AhkTest.AssertEqual("ImageQt", Type(rgbaQImage))
            AhkTest.AssertEqual(2, rgbaQImage.width())
            AhkTest.AssertEqual(1, rgbaQImage.height())
            AhkTest.AssertEqual([2, 1], rgbaQImage.size())
            AhkTest.AssertTrue(rgbaQImage.hasAlphaChannel())
            AhkTest.AssertEqual("Format_ARGB32", rgbaQImage.format().name)
            AhkTest.AssertEqual(5, rgbaQImage.format().value)
            AhkTest.AssertEqual(32, rgbaQImage.depth())
            AhkTest.AssertEqual(8, rgbaQImage.bytesPerLine())
            AhkTest.AssertEqual(0, rgbaQImage.colorCount())
            AhkTest.AssertEqual([67174915, 134546951], rgbaQImage.pixels())

            palQImage := imageQt.toqimage(pal)
            AhkTest.AssertEqual(256, palQImage.colorCount())
            AhkTest.AssertEqual([4278850590, 4280824380, 4282798170, 4278190080, 4278190080], StdlibPillowTest.ArraySlice(palQImage.colorTable(), 1, 5))

            rgbRoundtrip := imageQt.fromqimage(imageQt.toqimage(rgb))
            rgbaRoundtrip := imageQt.fromqimage(rgbaQImage)
            palRoundtrip := imageQt.fromqimage(palQImage)
            i16Roundtrip := imageQt.fromqimage(imageQt.toqimage(i16))
            AhkTest.AssertEqual("RGB", rgbRoundtrip.mode)
            AhkTest.AssertEqual("PPM", rgbRoundtrip.format)
            AhkTest.AssertEqual([[1, 2, 3], [4, 5, 6]], rgbRoundtrip.getdata())
            AhkTest.AssertEqual("RGBA", rgbaRoundtrip.mode)
            AhkTest.AssertEqual("PNG", rgbaRoundtrip.format)
            AhkTest.AssertEqual([[1, 2, 3, 4], [5, 6, 7, 8]], rgbaRoundtrip.getdata())
            AhkTest.AssertEqual("RGB", palRoundtrip.mode)
            AhkTest.AssertEqual([[10, 20, 30], [40, 50, 60], [70, 80, 90]], palRoundtrip.getdata())
            AhkTest.AssertEqual([[1, 1, 1], [1, 1, 1]], i16Roundtrip.convert("RGB").getdata())

            pixmap := imageQt.toqpixmap(rgb)
            AhkTest.AssertTrue(HasMethod(pixmap, "toImage"))
            AhkTest.AssertEqual(2, pixmap.width())
            AhkTest.AssertEqual(1, pixmap.height())
            AhkTest.AssertFalse(pixmap.isNull())
            pixmapRoundtrip := imageQt.fromqpixmap(pixmap)
            AhkTest.AssertEqual("RGB", pixmapRoundtrip.mode)
            AhkTest.AssertEqual("PPM", pixmapRoundtrip.format)
            AhkTest.AssertEqual([[1, 2, 3], [4, 5, 6]], pixmapRoundtrip.getdata())

            rgb.save(path)
            pathQImage := imageQt.toqimage(path)
            AhkTest.AssertEqual("ImageQt", Type(pathQImage))
            AhkTest.AssertEqual(2, pathQImage.width())
            AhkTest.AssertEqual(1, pathQImage.height())
            AhkTest.AssertEqual("Format_RGB32", pathQImage.format().name)

            AhkTest.RaisesMatch(KeyError, "^'RGB'$", (*) => imageQt.align8to32([1, 2, 3], 1, "RGB"))
            AhkTest.RaisesMatch(ValueError, "^unsupported image mode 'CMYK'$", (*) => imageQt.toqimage(cmyk))
            AhkTest.RaisesMatch(AssertionError, "^$", (*) => imageQt.toqimage(123))
            AhkTest.RaisesMatch(AttributeError, "^'Image' object has no attribute 'hasAlphaChannel'$", (*) => imageQt.fromqimage(rgb))
            AhkTest.RaisesMatch(TypeError, "^rgb\(\) missing 1 required positional argument: 'b'$", (*) => imageQt.rgb(1, 2))
            AhkTest.RaisesMatch(TypeError, "^toqimage\(\) missing 1 required positional argument: 'im'$", (*) => imageQt.toqimage())
        } finally {
            for image in [rgb, rgba, gray, pal, one] {
                if IsSet(image)
                    StdlibPillowTest.CloseImage(image)
            }
            for image in [rgbRoundtrip, rgbaRoundtrip, palRoundtrip, i16Roundtrip, pixmapRoundtrip] {
                if IsSet(image)
                    StdlibPillowTest.CloseImage(image)
            }
            if FileExist(path)
                FileDelete path
        }
    }

    static TestImageTkMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "ImageTk"))
        imageTk := stdlib.pillow.ImageTk
        AhkTest.AssertTrue(HasProp(imageTk, "PhotoImage"))
        AhkTest.AssertTrue(HasProp(imageTk, "BitmapImage"))
        AhkTest.AssertTrue(HasMethod(imageTk, "getimage"))
        AhkTest.AssertTrue(HasMethod(imageTk, "_get_image_from_kw"))
        AhkTest.AssertTrue(HasMethod(imageTk, "_pyimagingtkcall"))

        rgb := stdlib.pillow.Image.new("RGB", [2, 1], [1, 2, 3])
        rgba := stdlib.pillow.Image.new("RGBA", [2, 1], [10, 20, 30, 40])
        replacement := stdlib.pillow.Image.new("RGB", [2, 1], [7, 8, 9])
        modePhoto := stdlib.None
        filePhoto := stdlib.None
        dataPhoto := stdlib.None
        fileOpened := stdlib.None
        dataOpened := stdlib.None
        bitmap := stdlib.None
        path := StdlibPillowTest.TempPath("imagetk-source.png")
        try {
            rgb.putpixel([1, 0], [4, 5, 6])
            rgba.putpixel([1, 0], [200, 10, 5, 255])
            replacement.putpixel([1, 0], [20, 30, 40])

            photo := imageTk.PhotoImage(rgb)
            AhkTest.AssertEqual(2, photo.width())
            AhkTest.AssertEqual(1, photo.height())
            AhkTest.AssertRegex(photo.ToString(), "^pyimage\d+$")
            AhkTest.AssertEqual("RGBA", imageTk.getimage(photo).mode)
            AhkTest.AssertEqual([[1, 2, 3, 255], [4, 5, 6, 255]], imageTk.getimage(photo).getdata())

            photoRgba := imageTk.PhotoImage(rgba)
            AhkTest.AssertEqual([[10, 20, 30, 40], [200, 10, 5, 255]], imageTk.getimage(photoRgba).getdata())

            AhkTest.AssertSame(stdlib.None, photo.paste(replacement))
            AhkTest.AssertEqual([[7, 8, 9, 255], [20, 30, 40, 255]], imageTk.getimage(photo).getdata())

            modePhoto := imageTk.PhotoImage("RGB", [3, 2])
            AhkTest.AssertEqual(3, modePhoto.width())
            AhkTest.AssertEqual(2, modePhoto.height())

            rgb.save(path)
            bytes := StdlibPillowTest.ReadBytes(path)
            fileKw := Map("file", path, "sentinel", 7)
            fileOpened := imageTk._get_image_from_kw(fileKw)
            AhkTest.AssertEqual(Map("sentinel", 7), fileKw)
            AhkTest.AssertEqual("RGB", fileOpened.mode)
            AhkTest.AssertEqual([[1, 2, 3], [4, 5, 6]], fileOpened.getdata())

            dataKw := Map("data", bytes, "sentinel", 8)
            dataOpened := imageTk._get_image_from_kw(dataKw)
            AhkTest.AssertEqual(Map("sentinel", 8), dataKw)
            AhkTest.AssertEqual([[1, 2, 3], [4, 5, 6]], dataOpened.getdata())

            emptyKw := Map("sentinel", 9)
            AhkTest.AssertSame(stdlib.None, imageTk._get_image_from_kw(emptyKw))
            AhkTest.AssertEqual(Map("sentinel", 9), emptyKw)

            filePhoto := imageTk.PhotoImage({ file: path })
            AhkTest.AssertEqual([2, 1], [filePhoto.width(), filePhoto.height()])
            AhkTest.AssertEqual([[1, 2, 3, 255], [4, 5, 6, 255]], imageTk.getimage(filePhoto).getdata())

            dataPhoto := imageTk.PhotoImage({ data: bytes })
            AhkTest.AssertEqual([2, 1], [dataPhoto.width(), dataPhoto.height()])
            AhkTest.AssertEqual([[1, 2, 3, 255], [4, 5, 6, 255]], imageTk.getimage(dataPhoto).getdata())

            bits := stdlib.pillow.Image.new("1", [8, 1], 255)
            bits.putpixel([3, 0], 0)
            bitmap := imageTk.BitmapImage(bits, { foreground: "white" })
            AhkTest.AssertEqual(8, bitmap.width())
            AhkTest.AssertEqual(1, bitmap.height())
            AhkTest.AssertRegex(bitmap.ToString(), "^pyimage\d+$")

            AhkTest.RaisesMatch(ValueError, "^Image is required$", (*) => imageTk.PhotoImage())
            AhkTest.RaisesMatch(ValueError, "^If first argument is mode, size is required$", (*) => imageTk.PhotoImage("RGB"))
            AhkTest.RaisesMatch(ValueError, "^Image is required$", (*) => imageTk.BitmapImage())
            AhkTest.RaisesMatch(ValueError, "^not a bitmap$", (*) => imageTk.BitmapImage(rgb))
            AhkTest.RaisesMatch(TypeError, "^'int' object is not callable$", (*) => imageTk.getimage(rgb))
        } finally {
            for image in [rgb, rgba, replacement, fileOpened, dataOpened] {
                if !AhkStdlibIsNone(image)
                    StdlibPillowTest.CloseImage(image)
            }
            if FileExist(path)
                FileDelete path
        }
    }

    static TestImageWinMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "ImageWin"))
        imageWin := stdlib.pillow.ImageWin
        AhkTest.AssertTrue(HasProp(imageWin, "HDC"))
        AhkTest.AssertTrue(HasProp(imageWin, "HWND"))
        AhkTest.AssertTrue(HasProp(imageWin, "Dib"))
        AhkTest.AssertTrue(HasProp(imageWin, "Window"))
        AhkTest.AssertTrue(HasProp(imageWin, "ImageWindow"))

        hdc := imageWin.HDC(12345)
        hwnd := imageWin.HWND(67890)
        AhkTest.AssertEqual(12345, hdc.dc)
        AhkTest.AssertEqual(12345, hdc.ToInteger())
        AhkTest.AssertEqual(67890, hwnd.wnd)
        AhkTest.AssertEqual(67890, hwnd.ToInteger())

        rgb := stdlib.pillow.Image.new("RGB", [2, 1], [1, 2, 3])
        rgba := stdlib.pillow.Image.new("RGBA", [2, 1], [10, 20, 30, 40])
        gray := stdlib.pillow.Image.new("L", [3, 1], 9)
        bits := stdlib.pillow.Image.new("1", [8, 1], 255)
        modeDib := stdlib.None
        pasteFull := stdlib.None
        pastePatch := stdlib.None
        try {
            rgb.putpixel([1, 0], [4, 5, 6])
            rgba.putpixel([1, 0], [200, 10, 5, 255])
            gray.putpixel([1, 0], 20)
            bits.putpixel([3, 0], 0)

            rgbDib := imageWin.Dib(rgb)
            AhkTest.AssertEqual("RGB", rgbDib.mode)
            AhkTest.AssertEqual([2, 1], rgbDib.size)
            AhkTest.AssertEqual([3, 2, 1, 6, 5, 4, 0, 0], rgbDib.tobytes())

            rgbaDib := imageWin.Dib(rgba)
            AhkTest.AssertEqual("RGB", rgbaDib.mode)
            AhkTest.AssertEqual([30, 20, 10, 5, 10, 200, 0, 0], rgbaDib.tobytes())

            grayDib := imageWin.Dib(gray)
            AhkTest.AssertEqual("L", grayDib.mode)
            AhkTest.AssertEqual([3, 1], grayDib.size)
            AhkTest.AssertEqual([9, 20, 9, 0], grayDib.tobytes())

            bitsDib := imageWin.Dib(bits)
            AhkTest.AssertEqual("1", bitsDib.mode)
            AhkTest.AssertEqual([8, 1], bitsDib.size)
            AhkTest.AssertEqual([255, 255, 255, 0, 255, 255, 255, 255], bitsDib.tobytes())

            modeDib := imageWin.Dib("RGB", [2, 1])
            AhkTest.AssertEqual("RGB", modeDib.mode)
            AhkTest.AssertEqual([2, 1], modeDib.size)
            AhkTest.AssertEqual([0, 0, 0, 0, 0, 0, 0, 0], modeDib.tobytes())
            AhkTest.AssertSame(stdlib.None, modeDib.frombytes(rgbDib.tobytes()))
            AhkTest.AssertEqual([3, 2, 1, 6, 5, 4, 0, 0], modeDib.tobytes())
            pasteFull := stdlib.pillow.Image.new("RGB", [2, 1], [7, 8, 9])
            AhkTest.AssertSame(stdlib.None, modeDib.paste(pasteFull))
            AhkTest.AssertEqual([9, 8, 7, 9, 8, 7, 0, 0], modeDib.tobytes())
            pastePatch := stdlib.pillow.Image.new("RGB", [1, 1], [20, 30, 40])
            AhkTest.AssertSame(stdlib.None, modeDib.paste(pastePatch, [1, 0, 2, 1]))
            AhkTest.AssertEqual([9, 8, 7, 40, 30, 20, 0, 0], modeDib.tobytes())

            AhkTest.AssertSame(stdlib.None, rgbDib.draw(0, [0, 0, 2, 1]))
            AhkTest.AssertSame(stdlib.None, rgbDib.expose(0))
            AhkTest.AssertEqual(0, rgbDib.query_palette(0))
            AhkTest.AssertSame(stdlib.None, imageWin.Window("probe", 1, 1).mainloop())
            AhkTest.AssertEqual([2, 1], imageWin.ImageWindow(rgb, "probe").image.size)

            AhkTest.RaisesMatch(ValueError, "^If first argument is mode, size is required$", (*) => imageWin.Dib("RGB"))
            AhkTest.RaisesMatch(ValueError, "^image has wrong mode$", (*) => imageWin.Dib("P", [2, 1]))
            AhkTest.RaisesMatch(KeyError, "^'BAD'$", (*) => imageWin.Dib("BAD", [1, 1]))
            AhkTest.RaisesMatch(ValueError, "^wrong size$", (*) => imageWin.Dib("RGB", [2, 1]).frombytes([1, 2, 3]))
            AhkTest.RaisesMatch(ValueError, "^invalid literal for int\(\) with base 10: 'bad'$", (*) => rgbDib.draw("bad", [0, 0, 2, 1]))
            AhkTest.RaisesMatch(ValueError, "^invalid literal for int\(\) with base 10: 'bad'$", (*) => rgbDib.expose("bad"))
            AhkTest.RaisesMatch(ValueError, "^invalid literal for int\(\) with base 10: 'bad'$", (*) => rgbDib.query_palette("bad"))
        } finally {
            for image in [pasteFull, pastePatch] {
                if !AhkStdlibIsNone(image)
                    StdlibPillowTest.CloseImage(image)
            }
            for image in [rgb, rgba, gray, bits] {
                if IsSet(image)
                    StdlibPillowTest.CloseImage(image)
            }
        }
    }

    static TestImageShowMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "ImageShow"))
        imageShow := stdlib.pillow.ImageShow
        AhkTest.AssertTrue(HasProp(imageShow, "Viewer"))
        AhkTest.AssertTrue(HasProp(imageShow, "WindowsViewer"))
        AhkTest.AssertTrue(HasProp(imageShow, "XDGViewer"))
        AhkTest.AssertTrue(HasProp(imageShow, "DisplayViewer"))
        AhkTest.AssertTrue(HasProp(imageShow, "GmDisplayViewer"))
        AhkTest.AssertTrue(HasProp(imageShow, "EogViewer"))
        AhkTest.AssertTrue(HasProp(imageShow, "XVViewer"))
        AhkTest.AssertTrue(HasProp(imageShow, "IPythonViewer"))
        AhkTest.AssertEqual(["WindowsViewer", "IPythonViewer"], imageShow.viewer_names())

        savedViewers := imageShow._viewers.Clone()
        missingPath := StdlibPillowTest.TempPath("missing-imageshow-file.png")
        commandPath := StdlibPillowTest.TempPath("imageshow-command.png")
        rgb := stdlib.None
        cmyk := stdlib.None
        la := stdlib.None
        try {
            imageShow.clear_viewers()
            rgb := stdlib.pillow.Image.new("RGB", [2, 1], [1, 2, 3])
            AhkTest.AssertFalse(imageShow.show(rgb))

            first := StdlibPillowRecordingViewer(0)
            second := StdlibPillowRecordingViewer(1)
            AhkTest.AssertSame(stdlib.None, imageShow.register(first))
            AhkTest.AssertSame(stdlib.None, imageShow.register(second))
            AhkTest.AssertEqual(["StdlibPillowRecordingViewer", "StdlibPillowRecordingViewer"], imageShow.viewer_names())
            AhkTest.AssertTrue(imageShow.show(rgb, "sample", { custom: 7 }))
            AhkTest.AssertEqual([["RGB", [2, 1], Map("title", "sample", "custom", 7)]], first.Calls)
            AhkTest.AssertEqual([["RGB", [2, 1], Map("title", "sample", "custom", 7)]], second.Calls)

            prepended := StdlibPillowRecordingViewer(1)
            imageShow.register(prepended, 0)
            AhkTest.AssertSame(prepended, imageShow._viewers[1])

            imageShow.register(StdlibPillowRecordingViewer)
            AhkTest.AssertEqual("StdlibPillowRecordingViewer", Type(imageShow._viewers[imageShow._viewers.Length]))

            viewer := imageShow.Viewer()
            AhkTest.AssertSame(stdlib.None, viewer.format)
            AhkTest.AssertEqual(0, viewer.options.Count)
            AhkTest.AssertSame(stdlib.None, viewer.get_format(rgb))
            AhkTest.RaisesMatch(NotImplementedError, "^unavailable in base viewer$", (*) => viewer.get_command("x.png"))
            AhkTest.RaisesMatch(OSError, "^$", (*) => viewer.show_file(missingPath))

            cmyk := StdlibPillowImageShowFakeImage("CMYK", [1, 1])
            cmykViewer := imageShow.RecordingViewer(1)
            cmykViewer.format := "JPEG"
            AhkTest.AssertEqual(1, cmykViewer.show(cmyk, { title: "cmyk" }))
            AhkTest.AssertEqual([["RGB", [1, 1], Map("title", "cmyk")]], cmykViewer.Calls)

            la := StdlibPillowImageShowFakeImage("LA", [1, 1])
            pngViewer := imageShow.RecordingViewer(1)
            pngViewer.format := "PNG"
            AhkTest.AssertEqual(1, pngViewer.show(la))
            AhkTest.AssertEqual([["LA", [1, 1], Map()]], pngViewer.Calls)

            windows := imageShow.WindowsViewer()
            AhkTest.AssertEqual("PNG", windows.format)
            AhkTest.AssertEqual(Map("compress_level", 1, "save_all", true), windows.options)
            StdlibPillowTest.WriteBytes(commandPath, [120])
            AhkTest.AssertEqual('start "Pillow" /WAIT "' commandPath '" && ping -n 4 127.0.0.1 >NUL && del /f "' commandPath '"', windows.get_command(commandPath))
            AhkTest.RaisesMatch(OSError, "^$", (*) => windows.show_file(missingPath))

            xdg := imageShow.XDGViewer()
            AhkTest.AssertEqual(["xdg-open", "xdg-open"], xdg.get_command_ex("a b.png"))
            AhkTest.AssertEqual("xdg-open 'a b.png'", xdg.get_command("a b.png"))

            display := imageShow.DisplayViewer()
            AhkTest.AssertEqual(["display -title 'My Title'", "display"], display.get_command_ex("a b.png", { title: "My Title" }))
            AhkTest.AssertEqual("display -title 'My Title' 'a b.png'", display.get_command("a b.png", { title: "My Title" }))

            gm := imageShow.GmDisplayViewer()
            AhkTest.AssertEqual(["gm display", "gm"], gm.get_command_ex("a b.png"))

            eog := imageShow.EogViewer()
            AhkTest.AssertEqual(["eog -n", "eog"], eog.get_command_ex("a b.png"))

            xv := imageShow.XVViewer()
            AhkTest.AssertEqual(["xv -name 'My Title'", "xv"], xv.get_command_ex("a b.png", { title: "My Title" }))
            AhkTest.AssertEqual("xv -name 'My Title' 'a b.png'", xv.get_command("a b.png", { title: "My Title" }))

            ipy := imageShow.IPythonViewer()
            AhkTest.AssertSame(stdlib.None, ipy.format)
            AhkTest.RaisesMatch(TypeError, "^register\(\) missing 1 required positional argument: 'viewer'$", (*) => imageShow.register())
            AhkTest.RaisesMatch(TypeError, "^show\(\) missing 1 required positional argument: 'image'$", (*) => imageShow.show())
            AhkTest.RaisesMatch(TypeError, "^Viewer\.show\(\) missing 1 required positional argument: 'image'$", (*) => viewer.show())
        } finally {
            imageShow.restore_viewers(savedViewers)
            for image in [rgb, cmyk, la] {
                if !AhkStdlibIsNone(image) && IsObject(image) && HasMethod(image, "close")
                    image.close()
            }
            if FileExist(commandPath)
                FileDelete commandPath
        }
    }

    static TestImageMorphMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "ImageMorph"))
        morph := stdlib.pillow.ImageMorph
        AhkTest.AssertEqual(512, morph.LUT_SIZE)
        AhkTest.AssertEqual([6, 3, 0, 7, 4, 1, 8, 5, 2], morph.ROTATION_MATRIX)
        AhkTest.AssertEqual([2, 1, 0, 5, 4, 3, 8, 7, 6], morph.MIRROR_MATRIX)
        AhkTest.AssertTrue(HasProp(morph, "LutBuilder"))
        AhkTest.AssertTrue(HasProp(morph, "MorphOp"))

        builder := morph.LutBuilder()
        AhkTest.AssertSame(stdlib.None, builder.lut)
        AhkTest.AssertSame(stdlib.None, builder.build_default_lut())
        defaultLut := builder.get_lut()
        AhkTest.AssertEqual(512, defaultLut.Length)
        AhkTest.AssertEqual([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], StdlibPillowTest.ArraySlice(defaultLut, 1, 16))
        AhkTest.AssertEqual(0, defaultLut[1])
        AhkTest.AssertEqual(1, defaultLut[(1 << 4) + 1])

        patternBuilder := morph.LutBuilder({ patterns: ["1:(... .1. ...)->0"] })
        patternLut := patternBuilder.build_lut()
        AhkTest.AssertEqual(512, patternLut.Length)
        AhkTest.AssertEqual(0, patternLut[(1 << 4) + 1])
        AhkTest.AssertEqual(0, patternLut[(1 << 0) | (1 << 4) + 1])
        AhkTest.AssertSame(patternLut, patternBuilder.get_lut())
        AhkTest.AssertSame(stdlib.None, patternBuilder.add_patterns(["1:(... .0. ...)->1"]))
        AhkTest.AssertEqual(2, patternBuilder.patterns.Length)
        AhkTest.AssertEqual("210543876", patternBuilder._string_permute("012345678", morph.MIRROR_MATRIX))
        AhkTest.AssertEqual([
            ["00.01....", 1],
            [".00.10...", 1],
            ["....10.00", 1],
            ["...01.00.", 1],
            ["00.01....", 1],
            [".00.10...", 1],
        ], StdlibPillowTest.ArraySlice(patternBuilder._pattern_permute("00.01....", "4M", 1), 1, 6))

        source := stdlib.pillow.Image.new("L", [5, 5], 0)
        source.putpixel([2, 1], 255)
        source.putpixel([1, 2], 255)
        source.putpixel([2, 2], 255)
        source.putpixel([3, 2], 255)
        source.putpixel([2, 3], 255)
        binary := stdlib.pillow.Image.new("L", [3, 3], 0)
        binary.putpixel([1, 1], 255)
        rgb := stdlib.pillow.Image.new("RGB", [1, 1], [1, 2, 3])
        lutPath := StdlibPillowTest.TempPath("imagemorph-op.mrl")
        badPath := StdlibPillowTest.TempPath("imagemorph-bad.mrl")
        try {
            dilation4 := morph.MorphOp({ op_name: "dilation4" })
            AhkTest.AssertEqual(512, dilation4.lut.Length)
            AhkTest.AssertEqual([0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], StdlibPillowTest.ArraySlice(dilation4.lut, 1, 16))
            dilation4Result := dilation4.apply(source)
            AhkTest.AssertEqual(4, dilation4Result[1])
            AhkTest.AssertEqual([
                [0, 0, 0, 0, 0],
                [0, 255, 255, 255, 0],
                [0, 255, 255, 255, 0],
                [0, 255, 255, 255, 0],
                [0, 0, 0, 0, 0],
            ], StdlibPillowTest.PixelRows(dilation4Result[2]))
            AhkTest.AssertEqual([[1, 1], [2, 1], [3, 1], [1, 2], [2, 2], [3, 2], [1, 3], [2, 3], [3, 3]], dilation4.match(source))

            erosion4 := morph.MorphOp({ op_name: "erosion4" })
            erosion4Result := erosion4.apply(source)
            AhkTest.AssertEqual(4, erosion4Result[1])
            AhkTest.AssertEqual([
                [0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0],
                [0, 0, 255, 0, 0],
                [0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0],
            ], StdlibPillowTest.PixelRows(erosion4Result[2]))
            AhkTest.AssertEqual([[2, 2]], erosion4.match(source))

            edge := morph.MorphOp({ op_name: "edge" })
            edgeResult := edge.apply(source)
            AhkTest.AssertEqual(0, edgeResult[1])
            AhkTest.AssertEqual(StdlibPillowTest.PixelRows(source), StdlibPillowTest.PixelRows(edgeResult[2]))
            AhkTest.AssertEqual([[2, 1], [1, 2], [2, 2], [3, 2], [2, 3]], edge.match(source))

            rawLut := []
            loop 512
                rawLut.Push(0)
            rawLut[(1 << 4) + 1] := 1
            rawOp := morph.MorphOp({ lut: rawLut })
            rawResult := rawOp.apply(binary)
            AhkTest.AssertSame(rawLut, rawOp.lut)
            AhkTest.AssertEqual(0, rawResult[1])
            AhkTest.AssertEqual([[0, 0, 0], [0, 255, 0], [0, 0, 0]], StdlibPillowTest.PixelRows(rawResult[2]))
            AhkTest.AssertEqual([[1, 1]], rawOp.match(binary))
            AhkTest.AssertEqual([[1, 1]], rawOp.get_on_pixels(binary))
            AhkTest.AssertSame(stdlib.None, rawOp.set_lut(stdlib.None))
            AhkTest.AssertSame(stdlib.None, rawOp.lut)

            AhkTest.AssertSame(stdlib.None, dilation4.save_lut(lutPath))
            savedBytes := StdlibPillowTest.ReadBytes(lutPath)
            AhkTest.AssertEqual(512, savedBytes.Length)
            AhkTest.AssertEqual([0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], StdlibPillowTest.ArraySlice(savedBytes, 1, 16))
            loaded := morph.MorphOp()
            AhkTest.AssertSame(stdlib.None, loaded.load_lut(lutPath))
            AhkTest.AssertEqual(savedBytes, loaded.lut)

            StdlibPillowTest.WriteBytes(badPath, [98, 97, 100])
            AhkTest.RaisesMatch(Error, "^Unknown pattern bad!$", (*) => morph.LutBuilder({ op_name: "bad" }))
            AhkTest.RaisesMatch(Error, '^Syntax error in pattern "bad"$', (*) => morph.LutBuilder({ patterns: ["bad"] }).build_lut())
            AhkTest.RaisesMatch(Error, "^No operator loaded$", (*) => morph.MorphOp().apply(source))
            AhkTest.RaisesMatch(Error, "^No operator loaded$", (*) => morph.MorphOp().match(source))
            AhkTest.RaisesMatch(Error, "^No operator loaded$", (*) => morph.MorphOp().save_lut(lutPath))
            AhkTest.RaisesMatch(Error, "^Wrong size operator file!$", (*) => morph.MorphOp().load_lut(badPath))
            AhkTest.RaisesMatch(ValueError, "^Image mode must be L$", (*) => dilation4.apply(rgb))
            AhkTest.RaisesMatch(ValueError, "^Image mode must be L$", (*) => dilation4.match(rgb))
            AhkTest.RaisesMatch(ValueError, "^Image mode must be L$", (*) => morph.MorphOp().get_on_pixels(rgb))
        } finally {
            for image in [source, binary, rgb] {
                if IsSet(image)
                    StdlibPillowTest.CloseImage(image)
            }
            if FileExist(lutPath)
                FileDelete lutPath
            if FileExist(badPath)
                FileDelete badPath
        }
    }

    static TestFeaturesModuleMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "features"))

        AhkTest.AssertEqual(["pil", "tkinter", "freetype2", "littlecms2", "webp", "avif"], stdlib.pillow.features.get_supported_modules())
        AhkTest.AssertEqual(["jpg", "jpg_2000", "zlib", "libtiff"], stdlib.pillow.features.get_supported_codecs())
        AhkTest.AssertEqual(["webp_anim", "webp_mux", "transp_webp", "raqm", "fribidi", "harfbuzz", "libjpeg_turbo", "zlib_ng"], stdlib.pillow.features.get_supported_features())
        AhkTest.AssertEqual([
            "pil", "tkinter", "freetype2", "littlecms2", "webp", "avif",
            "webp_anim", "webp_mux", "transp_webp", "raqm", "fribidi", "harfbuzz", "libjpeg_turbo", "zlib_ng",
            "jpg", "jpg_2000", "zlib", "libtiff",
        ], stdlib.pillow.features.get_supported())

        AhkTest.AssertEqual("PIL._imaging", stdlib.pillow.features.modules["pil"][1])
        AhkTest.AssertEqual("PILLOW_VERSION", stdlib.pillow.features.modules["pil"][2])
        AhkTest.AssertEqual("jpeg", stdlib.pillow.features.codecs["jpg"][1])
        AhkTest.AssertEqual("PIL._imagingft", stdlib.pillow.features.features["raqm"][1])
        AhkTest.AssertEqual("HAVE_RAQM", stdlib.pillow.features.features["raqm"][2])

        AhkTest.AssertTrue(stdlib.pillow.features.check("pil"))
        AhkTest.AssertTrue(stdlib.pillow.features.check_module("tkinter"))
        AhkTest.AssertTrue(stdlib.pillow.features.check_codec("jpg"))
        AhkTest.AssertTrue(stdlib.pillow.features.check_feature("raqm"))
        AhkTest.AssertFalse(stdlib.pillow.features.check_feature("xcb"))

        AhkTest.AssertEqual("11.3.0", stdlib.pillow.features.version("pil"))
        AhkTest.AssertEqual("8.6", stdlib.pillow.features.version_module("tkinter"))
        AhkTest.AssertEqual("8.0", stdlib.pillow.features.version_codec("jpg"))
        AhkTest.AssertEqual("3.1.1", stdlib.pillow.features.version_feature("libjpeg_turbo"))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.features.version_feature("xcb"))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.features.version("unknown_feature"))

        records := stdlib.warnings.catch_warnings(true).Call((records) => stdlib.pillow.features.check("unknown_feature"))
        AhkTest.AssertEqual(1, records.Length)
        AhkTest.AssertSame(stdlib.warnings.UserWarning, records[1].category)
        AhkTest.AssertEqual("Unknown feature 'unknown_feature'.", records[1].message)

        deprecationRecords := stdlib.warnings.catch_warnings(true).Call((records) => stdlib.pillow.features.check("webp_anim"))
        AhkTest.AssertEqual(1, deprecationRecords.Length)
        AhkTest.AssertSame(stdlib.warnings.DeprecationWarning, deprecationRecords[1].category)
        AhkTest.AssertEqual('check_feature("webp_anim") is deprecated and will be removed in Pillow 12 (2025-10-15)', deprecationRecords[1].message)

        buffer := stdlib.io.StringIO()
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.features.pilinfo(buffer, false))
        AhkTest.AssertContains("Pillow 11.3.0", buffer.getvalue())

        AhkTest.RaisesMatch(TypeError, "^check\(\) missing 1 required positional argument: 'feature'$", (*) => stdlib.pillow.features.check())
        AhkTest.RaisesMatch(TypeError, "^check\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.pillow.features.check("pil", "extra"))
        AhkTest.RaisesMatch(TypeError, "^get_supported\(\) takes 0 positional arguments but 1 was given$", (*) => stdlib.pillow.features.get_supported("extra"))
        AhkTest.RaisesMatch(ValueError, "^Unknown module jpg$", (*) => stdlib.pillow.features.check_module("jpg"))
        AhkTest.RaisesMatch(ValueError, "^Unknown codec webp$", (*) => stdlib.pillow.features.check_codec("webp"))
        AhkTest.RaisesMatch(ValueError, "^Unknown feature zlib$", (*) => stdlib.pillow.features.check_feature("zlib"))
        AhkTest.RaisesMatch(ValueError, "^Unknown module raqm$", (*) => stdlib.pillow.features.version_module("raqm"))
        AhkTest.RaisesMatch(ValueError, "^Unknown codec pil$", (*) => stdlib.pillow.features.version_codec("pil"))
        AhkTest.RaisesMatch(ValueError, "^Unknown feature unknown_feature$", (*) => stdlib.pillow.features.version_feature("unknown_feature"))
    }

    static TestReportModuleMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "report"))
        report := stdlib.pillow.report

        AhkTest.AssertTrue(HasProp(report, "pilinfo"))

        falseBuffer := stdlib.io.StringIO()
        AhkTest.AssertSame(stdlib.None, report.pilinfo(falseBuffer, false))
        AhkTest.AssertContains("Pillow 11.3.0", falseBuffer.getvalue())
        AhkTest.AssertContains("--- TKINTER support ok", falseBuffer.getvalue())
        AhkTest.AssertNotContains("JPEG image/jpeg", falseBuffer.getvalue())

        trueBuffer := stdlib.io.StringIO()
        AhkTest.AssertSame(stdlib.None, report.pilinfo(trueBuffer, true))
        AhkTest.AssertContains("Pillow 11.3.0", trueBuffer.getvalue())
        AhkTest.AssertContains("JPEG image/jpeg", trueBuffer.getvalue())
        AhkTest.AssertContains("Features: open, save", trueBuffer.getvalue())

        AhkTest.RaisesMatch(TypeError, "^pilinfo\(\) takes from 0 to 2 positional arguments but 3 were given$", (*) => report.pilinfo(stdlib.io.StringIO(), false, "extra"))
    }

    static TestJpegPresetsMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "JpegPresets"))
        AhkTest.AssertFalse(HasProp(stdlib.pillow.JpegPresets, "samplings"))

        presets := stdlib.pillow.JpegPresets.presets
        AhkTest.AssertEqual(9, presets.Count)
        for name in ["web_low", "web_medium", "web_high", "web_very_high", "web_maximum", "low", "medium", "high", "maximum"]
            AhkTest.AssertTrue(presets.Has(name))

        AhkTest.AssertEqual(2, presets["web_low"]["subsampling"])
        AhkTest.AssertEqual(2, presets["web_medium"]["subsampling"])
        AhkTest.AssertEqual(0, presets["web_high"]["subsampling"])
        AhkTest.AssertEqual(0, presets["web_very_high"]["subsampling"])
        AhkTest.AssertEqual(0, presets["web_maximum"]["subsampling"])
        AhkTest.AssertEqual(2, presets["low"]["subsampling"])
        AhkTest.AssertEqual(2, presets["medium"]["subsampling"])
        AhkTest.AssertEqual(0, presets["high"]["subsampling"])
        AhkTest.AssertEqual(0, presets["maximum"]["subsampling"])

        for name, preset in presets {
            AhkTest.AssertEqual(2, preset["quantization"].Length)
            AhkTest.AssertEqual(64, preset["quantization"][1].Length)
            AhkTest.AssertEqual(64, preset["quantization"][2].Length)
        }

        AhkTest.AssertEqual([6, 4, 4, 6, 9, 11, 12, 16], StdlibPillowTest.ArraySlice(presets["web_high"]["quantization"][1], 1, 8))
        AhkTest.AssertEqual([68, 68, 68, 68, 68, 68, 68, 68], StdlibPillowTest.ArraySlice(presets["web_low"]["quantization"][2], 57, 64))
        AhkTest.AssertEqual(406, StdlibPillowTest.ArraySum(presets["maximum"]["quantization"][1]))
        AhkTest.AssertEqual([13, 11, 13, 16, 20, 20, 17, 17], StdlibPillowTest.ArraySlice(presets["medium"]["quantization"][2], 1, 8))

        presets["ahk_temp"] := Map("subsampling", 9, "quantization", [[1], [1]])
        AhkTest.AssertTrue(stdlib.pillow.JpegPresets.presets.Has("ahk_temp"))
        presets.Delete("ahk_temp")
    }

    static TestContainerIOMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "ContainerIO"))
        AhkTest.AssertTrue(HasProp(stdlib.pillow.ContainerIO, "ContainerIO"))

        binarySource := stdlib.io.BytesIO([48, 49, 50, 10, 51, 52, 53, 10, 54, 55, 56, 57])
        binarySource.mode := "rb"
        binary := stdlib.pillow.ContainerIO.ContainerIO(binarySource, 2, 7)
        AhkTest.AssertEqual(0, binary.tell())
        AhkTest.AssertEqual(2, binarySource.tell())
        AhkTest.AssertFalse(binary.isatty())
        AhkTest.AssertTrue(binary.readable())
        AhkTest.AssertFalse(binary.writable())
        AhkTest.AssertTrue(binary.seekable())
        AhkTest.AssertEqual([50, 10], binary.read(2))
        AhkTest.AssertEqual(2, binary.tell())
        AhkTest.AssertEqual([51, 52, 53, 10, 54], binary.read())
        AhkTest.AssertEqual(7, binary.tell())
        AhkTest.AssertEqual([], binary.read())

        seekSource := stdlib.io.BytesIO([48, 49, 50, 10, 51, 52, 53, 10, 54, 55, 56, 57])
        seekSource.mode := "rb"
        seek := stdlib.pillow.ContainerIO.ContainerIO(seekSource, 2, 7)
        AhkTest.AssertEqual(0, seek.seek(-99))
        AhkTest.AssertEqual(0, seek.tell())
        AhkTest.AssertEqual(2, seekSource.tell())
        AhkTest.AssertEqual(7, seek.seek(99))
        AhkTest.AssertEqual(7, seek.tell())
        AhkTest.AssertEqual(9, seekSource.tell())
        AhkTest.AssertEqual(5, seek.seek(-2, stdlib.io.SEEK_END))
        AhkTest.AssertEqual(6, seek.seek(1, stdlib.io.SEEK_CUR))
        AhkTest.AssertEqual(0, seek.seek(-99, stdlib.io.SEEK_CUR))
        AhkTest.AssertEqual(3, seek.seek(3, 99))
        AhkTest.AssertEqual([52, 53, 10, 54], seek.read(0))
        AhkTest.AssertEqual(7, seek.tell())

        lineSource := stdlib.io.BytesIO([97, 10, 98, 98, 10, 99, 99, 99])
        lineSource.mode := "rb"
        line := stdlib.pillow.ContainerIO.ContainerIO(lineSource, 0, 7)
        AhkTest.AssertEqual([97, 10], line.readline())
        AhkTest.AssertEqual([98], line.readline(1))
        AhkTest.AssertEqual([98, 10], line.readline(0))
        AhkTest.AssertEqual([[99, 99]], line.readlines())

        lineLimitSource := stdlib.io.BytesIO([97, 10, 98, 98, 10, 99, 99, 99])
        lineLimitSource.mode := "rb"
        lineLimit := stdlib.pillow.ContainerIO.ContainerIO(lineLimitSource, 0, 8)
        AhkTest.AssertEqual([[97, 10]], lineLimit.readlines(1))
        AhkTest.AssertEqual(2, lineLimit.tell())

        textSource := stdlib.io.StringIO("xy`nz")
        textSource.mode := "r"
        text := stdlib.pillow.ContainerIO.ContainerIO(textSource, 1, 3)
        AhkTest.AssertEqual("y`n", text.readline())
        AhkTest.AssertEqual("z", text.read())
        AhkTest.AssertEqual("", text.read())

        iterSource := stdlib.io.BytesIO([97, 10, 98, 98])
        iterSource.mode := "rb"
        iterator := stdlib.pillow.ContainerIO.ContainerIO(iterSource, 0, 4)
        iterLines := []
        for lineBytes in iterator
            iterLines.Push(lineBytes)
        AhkTest.AssertEqual([[97, 10], [98, 98]], iterLines)
        AhkTest.RaisesMatch(StopIteration, "^end of region$", (*) => iterator.__Next())

        methodSource := stdlib.io.BytesIO([97, 98, 99, 100, 101, 102])
        methodSource.mode := "rb"
        method := stdlib.pillow.ContainerIO.ContainerIO(methodSource, 1, 3)
        AhkTest.RaisesMatch(NotImplementedError, "^$", (*) => method.write([120]))
        AhkTest.RaisesMatch(NotImplementedError, "^$", (*) => method.writelines([[120]]))
        AhkTest.RaisesMatch(NotImplementedError, "^$", (*) => method.truncate())
        AhkTest.RaisesMatch(stdlib.io.UnsupportedOperation, "^fileno$", (*) => method.fileno())
        AhkTest.AssertSame(stdlib.None, method.flush())
        AhkTest.AssertSame(stdlib.None, method.close())
        AhkTest.AssertTrue(methodSource.closed)

        contextSource := stdlib.io.BytesIO([99, 111, 110, 116, 101, 120, 116])
        contextSource.mode := "rb"
        context := stdlib.pillow.ContainerIO.ContainerIO(contextSource, 1, 4)
        AhkTest.AssertSame(context, context.__Enter())
        AhkTest.AssertEqual([111, 110], context.read(2))
        AhkTest.AssertSame(stdlib.None, context.__Exit(stdlib.None, stdlib.None, stdlib.None))
        AhkTest.AssertTrue(contextSource.closed)

        AhkTest.RaisesMatch(TypeError, "^ContainerIO\.__init__\(\) missing 3 required positional arguments: 'file', 'offset', and 'length'$", (*) => stdlib.pillow.ContainerIO.ContainerIO())
        AhkTest.RaisesMatch(TypeError, "^ContainerIO\.__init__\(\) missing 1 required positional argument: 'length'$", (*) => stdlib.pillow.ContainerIO.ContainerIO(stdlib.io.BytesIO([120]), 0))
        AhkTest.RaisesMatch(TypeError, "^ContainerIO\.__init__\(\) takes 4 positional arguments but 5 were given$", (*) => stdlib.pillow.ContainerIO.ContainerIO(stdlib.io.BytesIO([120]), 0, 1, 2))
    }

    static TestTarIOMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "TarIO"))
        module := stdlib.pillow.TarIO
        AhkTest.AssertTrue(HasProp(module, "TarIO"))

        tarPath := StdlibPillowTest.TempPath("sample.tar")
        truncatedPath := StdlibPillowTest.TempPath("truncated.tar")
        emptyHeaderPath := StdlibPillowTest.TempPath("empty-header.tar")
        tarBytes := StdlibPillowTest.TarBytes([
            ["first.txt", StdlibPillowTest.AsciiBytes("first")],
            ["dir/second.bin", StdlibPillowTest.AsciiBytes("012`n345`n6789")],
            ["empty.dat", []],
        ])
        StdlibPillowTest.WriteBytes(tarPath, tarBytes)
        StdlibPillowTest.WriteBytes(truncatedPath, StdlibPillowTest.ArraySlice(tarBytes, 1, 511))
        StdlibPillowTest.WriteBytes(emptyHeaderPath, StdlibPillowTest.ZeroBytes(512))

        second := unset
        first := unset
        empty := unset
        try {
            second := module.TarIO(tarPath, "dir/second.bin")
            AhkTest.AssertEqual("TarIO", second.AhkStdlibTypeName)
            AhkTest.AssertEqual(0, second.tell())
            AhkTest.AssertEqual(1536, second.fh.tell())
            AhkTest.AssertEqual([48, 49, 50, 10], second.read(4))
            AhkTest.AssertEqual(4, second.tell())
            AhkTest.AssertEqual(1540, second.fh.tell())
            AhkTest.AssertEqual([51, 52, 53, 10], second.readline())
            AhkTest.AssertEqual(8, second.tell())
            AhkTest.AssertEqual(10, second.seek(-2, stdlib.io.SEEK_END))
            AhkTest.AssertEqual([56, 57], second.read())
            AhkTest.AssertEqual([], second.read())
            AhkTest.AssertEqual(3, second.seek(3, 99))
            AhkTest.AssertEqual([10, 51, 52, 53, 10, 54, 55, 56, 57], second.read(0))
            AhkTest.AssertTrue(second.readable())
            AhkTest.AssertFalse(second.writable())
            AhkTest.AssertTrue(second.seekable())
            AhkTest.AssertFalse(second.isatty())
            AhkTest.AssertSame(stdlib.None, second.close())
            AhkTest.AssertTrue(second.fh.closed)

            first := module.TarIO(tarPath, "first.txt")
            AhkTest.AssertEqual(512, first.offset)
            AhkTest.AssertEqual(5, first.length)
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("first"), first.read())

            empty := module.TarIO(tarPath, "empty.dat")
            AhkTest.AssertEqual(0, empty.length)
            AhkTest.AssertEqual([], empty.read())

            AhkTest.RaisesMatch(OSError, "^cannot find subfile$", (*) => module.TarIO(tarPath, "missing.txt"))
            AhkTest.RaisesMatch(OSError, "^unexpected end of tar file$", (*) => module.TarIO(truncatedPath, "anything"))
            AhkTest.RaisesMatch(OSError, "^cannot find subfile$", (*) => module.TarIO(emptyHeaderPath, "anything"))
            AhkTest.RaisesMatch(OSError, "^No such file or directory: '.*missing\.tar'$", (*) => module.TarIO(StdlibPillowTest.TempPath("missing.tar"), "x"))
            AhkTest.RaisesMatch(TypeError, "^TarIO\.__init__\(\) missing 2 required positional arguments: 'tarfile' and 'file'$", (*) => module.TarIO())
            AhkTest.RaisesMatch(TypeError, "^TarIO\.__init__\(\) missing 1 required positional argument: 'file'$", (*) => module.TarIO(tarPath))
            AhkTest.RaisesMatch(TypeError, "^TarIO\.__init__\(\) takes 3 positional arguments but 4 were given$", (*) => module.TarIO(tarPath, "first.txt", "extra"))
        } finally {
            if IsSet(empty) && IsObject(empty) && HasMethod(empty, "close")
                empty.close()
            if IsSet(first) && IsObject(first) && HasMethod(first, "close")
                first.close()
            if IsSet(second) && IsObject(second) && HasMethod(second, "close") && !second.fh.closed
                second.close()
            for path in [tarPath, truncatedPath, emptyHeaderPath] {
                if FileExist(path)
                    FileDelete path
            }
        }
    }

    static TestBmpImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "BmpImagePlugin"))
        plugin := stdlib.pillow.BmpImagePlugin

        AhkTest.AssertEqual(Map(
            1, ["P", "P;1"],
            4, ["P", "P;4"],
            8, ["P", "P"],
            16, ["RGB", "BGR;15"],
            24, ["RGB", "BGR"],
            32, ["RGB", "BGRX"]
        ), plugin.BIT2MODE)
        AhkTest.AssertEqual(Map(
            "1", ["1", 1, 2],
            "L", ["L", 8, 256],
            "P", ["P", 8, 256],
            "RGB", ["BGR", 24, 0],
            "RGBA", ["BGRA", 32, 0]
        ), plugin.SAVE)
        AhkTest.AssertFalse(plugin.USE_RAW_ALPHA)

        AhkTest.AssertTrue(plugin._accept([66, 77, 100, 101, 109, 111]))
        AhkTest.AssertFalse(plugin._accept([66, 65, 100, 101, 109, 111]))
        AhkTest.AssertFalse(plugin._accept([]))
        AhkTest.AssertTrue(plugin._dib_accept(plugin.o32(12)))
        AhkTest.AssertTrue(plugin._dib_accept(plugin.o32(40)))
        AhkTest.AssertTrue(plugin._dib_accept(plugin.o32(124)))
        AhkTest.AssertFalse(plugin._dib_accept(plugin.o32(13)))

        AhkTest.AssertEqual(4660, plugin.i16([0x34, 0x12]))
        AhkTest.AssertEqual(22136, plugin.i16([0, 0x78, 0x56], 1))
        AhkTest.AssertEqual(305419896, plugin.i32([0x78, 0x56, 0x34, 0x12]))
        AhkTest.AssertEqual(305419896, plugin.i32([0, 0, 0x78, 0x56, 0x34, 0x12], 2))
        AhkTest.AssertEqual([0xAB], plugin.o8(0xAB))
        AhkTest.AssertEqual([0x34, 0x12], plugin.o16(0x1234))
        AhkTest.AssertEqual([0x78, 0x56, 0x34, 0x12], plugin.o32(0x12345678))

        source := unset
        bmpImage := unset
        dibImage := unset
        try {
            source := stdlib.pillow.Image.new("RGB", [3, 2], [10, 20, 30])
            source.putpixel([1, 0], [200, 10, 5])
            bmpBuffer := stdlib.io.BytesIO()
            source.save(bmpBuffer, "BMP")
            bmpBytes := bmpBuffer.getvalue()
            dibBytes := StdlibPillowTest.ArraySlice(bmpBytes, 15, bmpBytes.Length)

            bmpImage := plugin.BmpImageFile(stdlib.io.BytesIO(bmpBytes))
            AhkTest.AssertEqual("BMP", bmpImage.format)
            AhkTest.AssertEqual("Windows Bitmap", bmpImage.format_description)
            AhkTest.AssertEqual("RGB", bmpImage.mode)
            AhkTest.AssertEqual([3, 2], bmpImage.size)
            AhkTest.AssertEqual([200, 10, 5], bmpImage.getpixel([1, 0]))
            AhkTest.AssertEqual(0, bmpImage.info["compression"])

            dibImage := plugin.DibImageFile(stdlib.io.BytesIO(dibBytes))
            AhkTest.AssertEqual("DIB", dibImage.format)
            AhkTest.AssertEqual("Windows Bitmap", dibImage.format_description)
            AhkTest.AssertEqual("RGB", dibImage.mode)
            AhkTest.AssertEqual([3, 2], dibImage.size)
            AhkTest.AssertEqual([200, 10, 5], dibImage.getpixel([1, 0]))
            AhkTest.AssertEqual(0, dibImage.info["compression"])
        } finally {
            if IsSet(dibImage)
                StdlibPillowTest.CloseImage(dibImage)
            if IsSet(bmpImage)
                StdlibPillowTest.CloseImage(bmpImage)
            if IsSet(source)
                StdlibPillowTest.CloseImage(source)
        }

        AhkTest.RaisesMatch(Error, "^Not a BMP file$", (*) => plugin.BmpImageFile(stdlib.io.BytesIO([78, 79])))
        AhkTest.RaisesMatch(OSError, "^Unsupported BMP header type \(13\)$", (*) => plugin.DibImageFile(stdlib.io.BytesIO(plugin.o32(13))))
        AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.BmpImageFile())
        AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.BmpImageFile(stdlib.io.BytesIO([66, 77]), stdlib.None, "extra"))
    }

    static TestAvifImagePluginHelpersMatchLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "AvifImagePlugin"))
        plugin := stdlib.pillow.AvifImagePlugin

        AhkTest.AssertTrue(plugin.SUPPORTED)
        AhkTest.AssertEqual("auto", plugin.DECODE_CODEC_CHOICE)
        AhkTest.AssertEqual(0, plugin.DEFAULT_MAX_THREADS)
        AhkTest.AssertEqual(20, plugin._get_default_max_threads())
        AhkTest.AssertEqual("v3.12.1", plugin.get_codec_version("aom"))
        AhkTest.AssertEqual("1.5.1-0-g42b2b24", plugin.get_codec_version("dav1d"))
        AhkTest.AssertSame(stdlib.None, plugin.get_codec_version("libavif"))
        AhkTest.AssertSame(stdlib.None, plugin.get_codec_version("unknown"))

        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AvifFtyp("avif")))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AvifFtyp("avis")))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AvifFtyp("mif1")))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AvifFtyp("msf1")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AvifFtyp("heic")))
        AhkTest.AssertFalse(plugin._accept([]))
        AhkTest.AssertFalse(plugin._accept([0, 0, 0, 24, 120, 120, 120, 120, 97, 118, 105, 102]))
        plugin.SUPPORTED := false
        try {
            AhkTest.AssertEqual("image file could not be identified because AVIF support not installed", plugin._accept(StdlibPillowTest.AvifFtyp("avif")))
        } finally {
            plugin.SUPPORTED := true
        }

        AhkTest.AssertEqual("AVIF", plugin.AvifImageFile.format)
        AhkTest.AssertEqual("AVIF image", plugin.AvifImageFile.format_description)
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("AVIF"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE_ALL.Has("AVIF"))
        AhkTest.AssertEqual("AVIF", stdlib.pillow.Image.registered_extensions()[".avif"])
        AhkTest.AssertEqual("AVIF", stdlib.pillow.Image.registered_extensions()[".avifs"])
        AhkTest.AssertEqual("image/avif", stdlib.pillow.Image.MIME["AVIF"])

        image := unset
        try {
            image := stdlib.pillow.Image.new("RGB", [1, 1], [10, 20, 30])
            AhkTest.RaisesMatch(ValueError, "^Invalid quality setting$", (*) => image.save(stdlib.io.BytesIO(), "AVIF", { quality: 101 }))
            AhkTest.RaisesMatch(ValueError, "^advanced codec options must be a dict of key-value string pairs or a series of key-value two-tuples$", (*) => image.save(stdlib.io.BytesIO(), "AVIF", { advanced: ["bad"] }))
        } finally {
            if IsSet(image)
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestBlpImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "BlpImagePlugin"))
        plugin := stdlib.pillow.BlpImagePlugin

        AhkTest.AssertEqual(0, plugin.Format.JPEG.value)
        AhkTest.AssertEqual("JPEG", plugin.Format.JPEG.name)
        AhkTest.AssertEqual("Format.JPEG", String(plugin.Format.JPEG))
        AhkTest.AssertEqual("<Format.JPEG: 0>", plugin.Format.JPEG.__Repr())
        AhkTest.AssertEqual(1, plugin.Encoding.UNCOMPRESSED.value)
        AhkTest.AssertEqual(2, plugin.Encoding.DXT.value)
        AhkTest.AssertEqual(3, plugin.Encoding.UNCOMPRESSED_RAW_BGRA.value)
        AhkTest.AssertEqual("UNCOMPRESSED_RAW_BGRA", plugin.Encoding.UNCOMPRESSED_RAW_BGRA.name)
        AhkTest.AssertEqual(0, plugin.AlphaEncoding.DXT1.value)
        AhkTest.AssertEqual(1, plugin.AlphaEncoding.DXT3.value)
        AhkTest.AssertEqual(7, plugin.AlphaEncoding.DXT5.value)
        AhkTest.AssertEqual("AlphaEncoding.DXT5", String(plugin.AlphaEncoding.DXT5))

        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("BLP1demo")))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("BLP2demo")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("BLPXdemo")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("BL")))

        AhkTest.AssertEqual("BLP", plugin.BlpImageFile.format)
        AhkTest.AssertEqual("Blizzard Mipmap Format", plugin.BlpImageFile.format_description)
        blpError := plugin.BLPFormatError("bad blp")
        AhkTest.AssertTrue(blpError is NotImplementedError)
        AhkTest.AssertTrue(blpError is Error)
        AhkTest.AssertEqual("bad blp", blpError.Message)

        AhkTest.AssertEqual([248, 0, 0], plugin.unpack_565(0xF800))
        AhkTest.AssertEqual([0, 252, 0], plugin.unpack_565(0x07E0))
        AhkTest.AssertEqual([0, 0, 248], plugin.unpack_565(0x001F))
        AhkTest.AssertEqual([16, 68, 160], plugin.unpack_565(0x1234))

        AhkTest.AssertEqual([
            [248, 0, 0, 0, 252, 0, 165, 84, 0, 82, 168, 0],
            [248, 0, 0, 0, 252, 0, 165, 84, 0, 82, 168, 0],
            [248, 0, 0, 0, 252, 0, 165, 84, 0, 82, 168, 0],
            [248, 0, 0, 0, 252, 0, 165, 84, 0, 82, 168, 0],
        ], plugin.decode_dxt1(StdlibPillowTest.BlpDxt1Block()))
        AhkTest.AssertEqual([
            [248, 0, 0, 255, 0, 252, 0, 255, 165, 84, 0, 255, 82, 168, 0, 255],
            [248, 0, 0, 255, 0, 252, 0, 255, 165, 84, 0, 255, 82, 168, 0, 255],
            [248, 0, 0, 255, 0, 252, 0, 255, 165, 84, 0, 255, 82, 168, 0, 255],
            [248, 0, 0, 255, 0, 252, 0, 255, 165, 84, 0, 255, 82, 168, 0, 255],
        ], plugin.decode_dxt1(StdlibPillowTest.BlpDxt1Block(), true))
        AhkTest.AssertEqual([
            [0, 0, 248, 255, 248, 252, 248, 255, 124, 126, 248, 255, 0, 0, 0, 0],
            [0, 0, 248, 255, 248, 252, 248, 255, 124, 126, 248, 255, 0, 0, 0, 0],
            [0, 0, 248, 255, 248, 252, 248, 255, 124, 126, 248, 255, 0, 0, 0, 0],
            [0, 0, 248, 255, 248, 252, 248, 255, 124, 126, 248, 255, 0, 0, 0, 0],
        ], plugin.decode_dxt1(StdlibPillowTest.BlpDxt1TransparentBlock(), true))
        AhkTest.AssertEqual([
            [248, 0, 0, 0, 0, 252, 0, 17, 165, 84, 0, 34, 82, 168, 0, 51],
            [248, 0, 0, 68, 0, 252, 0, 85, 165, 84, 0, 102, 82, 168, 0, 119],
            [248, 0, 0, 136, 0, 252, 0, 153, 165, 84, 0, 170, 82, 168, 0, 187],
            [248, 0, 0, 204, 0, 252, 0, 221, 165, 84, 0, 238, 82, 168, 0, 255],
        ], plugin.decode_dxt3(StdlibPillowTest.BlpDxt3Block()))
        AhkTest.AssertEqual([
            [248, 0, 0, 200, 0, 252, 0, 20, 165, 84, 0, 174, 82, 168, 0, 148],
            [248, 0, 0, 122, 0, 252, 0, 97, 165, 84, 0, 71, 82, 168, 0, 45],
            [248, 0, 0, 200, 0, 252, 0, 20, 165, 84, 0, 174, 82, 168, 0, 148],
            [248, 0, 0, 122, 0, 252, 0, 97, 165, 84, 0, 71, 82, 168, 0, 45],
        ], plugin.decode_dxt5(StdlibPillowTest.BlpDxt5Block()))

        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("BLP"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("BLP"))
        AhkTest.AssertTrue(stdlib.pillow.Image.DECODERS.Has("BLP1"))
        AhkTest.AssertTrue(stdlib.pillow.Image.DECODERS.Has("BLP2"))
        AhkTest.AssertTrue(stdlib.pillow.Image.ENCODERS.Has("BLP"))
        AhkTest.AssertEqual("BLP", stdlib.pillow.Image.registered_extensions()[".blp"])

        rgba := unset
        rgb := unset
        openedBlp2Rgba := unset
        openedBlp1Rgba := unset
        openedBlp2Rgb := unset
        try {
            rgba := StdlibPillowTest.BlpPaletteImage("RGBA")
            blp2Rgba := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, rgba.save(blp2Rgba, "BLP"))
            blp2RgbaBytes := blp2Rgba.getvalue()
            AhkTest.AssertEqual([66, 76, 80, 50], StdlibPillowTest.ArraySlice(blp2RgbaBytes, 1, 4))
            AhkTest.AssertEqual([66, 76, 80, 50, 1, 0, 0, 0, 1, 1, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 148, 4, 0, 0], StdlibPillowTest.ArraySlice(blp2RgbaBytes, 1, 24))
            AhkTest.AssertEqual(1176, blp2RgbaBytes.Length)
            openedBlp2Rgba := stdlib.pillow.Image.open(stdlib.io.BytesIO(blp2RgbaBytes), "r", ["BLP"])
            AhkTest.AssertEqual("BLP", openedBlp2Rgba.format)
            AhkTest.AssertEqual("Blizzard Mipmap Format", openedBlp2Rgba.format_description)
            AhkTest.AssertEqual("RGBA", openedBlp2Rgba.mode)
            AhkTest.AssertEqual([2, 2], openedBlp2Rgba.size)
            AhkTest.AssertEqual([
                [[10, 20, 30, 255], [40, 50, 60, 128]],
                [[70, 80, 90, 64], [100, 110, 120, 0]],
            ], StdlibPillowTest.PixelRows(openedBlp2Rgba))

            blp1Rgba := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, rgba.save(blp1Rgba, "BLP", { blp_version: "BLP1" }))
            blp1RgbaBytes := blp1Rgba.getvalue()
            AhkTest.AssertEqual([66, 76, 80, 49], StdlibPillowTest.ArraySlice(blp1RgbaBytes, 1, 4))
            AhkTest.AssertEqual([66, 76, 80, 49, 1, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 148, 4, 0, 0], StdlibPillowTest.ArraySlice(blp1RgbaBytes, 1, 32))
            AhkTest.AssertEqual(1184, blp1RgbaBytes.Length)
            openedBlp1Rgba := stdlib.pillow.Image.open(stdlib.io.BytesIO(blp1RgbaBytes), "r", ["BLP"])
            AhkTest.AssertEqual("BLP", openedBlp1Rgba.format)
            AhkTest.AssertEqual("RGBA", openedBlp1Rgba.mode)
            AhkTest.AssertEqual(StdlibPillowTest.PixelRows(openedBlp2Rgba), StdlibPillowTest.PixelRows(openedBlp1Rgba))

            rgb := StdlibPillowTest.BlpPaletteImage("RGB")
            blp2Rgb := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, rgb.save(blp2Rgb, "BLP"))
            blp2RgbBytes := blp2Rgb.getvalue()
            AhkTest.AssertEqual([66, 76, 80, 50, 1, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0], StdlibPillowTest.ArraySlice(blp2RgbBytes, 1, 20))
            openedBlp2Rgb := stdlib.pillow.Image.open(stdlib.io.BytesIO(blp2RgbBytes), "r", ["BLP"])
            AhkTest.AssertEqual("RGB", openedBlp2Rgb.mode)
            AhkTest.AssertEqual([
                [[10, 20, 30], [40, 50, 60]],
                [[70, 80, 90], [100, 110, 120]],
            ], StdlibPillowTest.PixelRows(openedBlp2Rgb))

            AhkTest.RaisesMatch(ValueError, "^Unsupported BLP image mode$", (*) => stdlib.pillow.Image.new("RGB", [1, 1]).save(stdlib.io.BytesIO(), "BLP"))
            AhkTest.RaisesMatch(TypeError, "^decode_dxt1\(\) missing 1 required positional argument: 'data'$", (*) => plugin.decode_dxt1())
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD!") ), "r", ["BLP"]))
        } finally {
            if IsSet(openedBlp2Rgb)
                StdlibPillowTest.CloseImage(openedBlp2Rgb)
            if IsSet(openedBlp1Rgba)
                StdlibPillowTest.CloseImage(openedBlp1Rgba)
            if IsSet(openedBlp2Rgba)
                StdlibPillowTest.CloseImage(openedBlp2Rgba)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
        }
    }

    static TestBufrStubImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "BufrStubImagePlugin"))
        plugin := stdlib.pillow.BufrStubImagePlugin

        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("BUFRdemo")))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("ZCZCdemo")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("BAD!demo")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("BUF")))
        AhkTest.AssertEqual("BUFR", plugin.BufrStubImageFile.format)
        AhkTest.AssertEqual("BUFR", plugin.BufrStubImageFile.format_description)

        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("BUFR"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("BUFR"))
        AhkTest.AssertEqual("BUFR", stdlib.pillow.Image.registered_extensions()[".bufr"])

        plugin.register_handler(stdlib.None)
        image := unset
        openedBufr := unset
        openedZczc := unset
        try {
            image := stdlib.pillow.Image.new("RGB", [1, 1], [10, 20, 30])
            AhkTest.RaisesMatch(OSError, "^BUFR save handler not installed$", (*) => image.save(stdlib.io.BytesIO(), "BUFR"))

            handler := StdlibPillowBufrHandler()
            AhkTest.AssertSame(stdlib.None, plugin.register_handler(handler))
            openedBufr := stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BUFRpayload")))
            openedZczc := stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("ZCZCpayload")))
            AhkTest.AssertEqual("BUFR", openedBufr.format)
            AhkTest.AssertEqual("BUFR", openedBufr.format_description)
            AhkTest.AssertEqual("F", openedBufr.mode)
            AhkTest.AssertEqual([1, 1], openedBufr.size)
            AhkTest.AssertEqual("BUFR", openedZczc.format)
            AhkTest.AssertEqual("F", openedZczc.mode)
            AhkTest.AssertEqual([1, 1], openedZczc.size)

            out := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, image.save(out, "BUFR"))
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("saved:RGB"), out.getvalue())
            AhkTest.AssertEqual([
                ["open", "BUFR", "BUFR", "F", [1, 1], 0],
                ["open", "BUFR", "BUFR", "F", [1, 1], 0],
                ["save", "RGB", [1, 1], ""],
            ], handler.Events)

            AhkTest.RaisesMatch(SyntaxError, "^Not a BUFR file$", (*) => plugin.BufrStubImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD!"))))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.BufrStubImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.BufrStubImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BUFR")), stdlib.None, "extra"))
        } finally {
            plugin.register_handler(stdlib.None)
            if IsSet(openedZczc)
                StdlibPillowTest.CloseImage(openedZczc)
            if IsSet(openedBufr)
                StdlibPillowTest.CloseImage(openedBufr)
            if IsSet(image)
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestGribStubImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "GribStubImagePlugin"))
        plugin := stdlib.pillow.GribStubImagePlugin

        validBytes := StdlibPillowTest.AsciiBytes("GRIBxxx")
        validBytes.Push(1)
        for byte in StdlibPillowTest.AsciiBytes("payload")
            validBytes.Push(byte)
        wrongMarkerBytes := StdlibPillowTest.AsciiBytes("GRIBxxx")
        wrongMarkerBytes.Push(2)
        for byte in StdlibPillowTest.AsciiBytes("payload")
            wrongMarkerBytes.Push(byte)
        badMagicBytes := StdlibPillowTest.AsciiBytes("BAD!xxx")
        badMagicBytes.Push(1)

        AhkTest.AssertTrue(plugin._accept(validBytes))
        AhkTest.AssertFalse(plugin._accept(wrongMarkerBytes))
        AhkTest.AssertFalse(plugin._accept(badMagicBytes))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("GRI")))
        AhkTest.RaisesMatch(IndexError, "^index out of range$", (*) => plugin._accept(StdlibPillowTest.AsciiBytes("GRIB")))
        AhkTest.AssertEqual("GRIB", plugin.GribStubImageFile.format)
        AhkTest.AssertEqual("GRIB", plugin.GribStubImageFile.format_description)

        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("GRIB"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("GRIB"))
        AhkTest.AssertEqual("GRIB", stdlib.pillow.Image.registered_extensions()[".grib"])

        plugin.register_handler(stdlib.None)
        image := unset
        opened := unset
        try {
            image := stdlib.pillow.Image.new("RGB", [1, 1], [10, 20, 30])
            AhkTest.RaisesMatch(OSError, "^GRIB save handler not installed$", (*) => image.save(stdlib.io.BytesIO(), "GRIB"))

            handler := StdlibPillowBufrHandler()
            AhkTest.AssertSame(stdlib.None, plugin.register_handler(handler))
            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(validBytes), "r", ["GRIB"])
            AhkTest.AssertEqual("GRIB", opened.format)
            AhkTest.AssertEqual("GRIB", opened.format_description)
            AhkTest.AssertEqual("F", opened.mode)
            AhkTest.AssertEqual([1, 1], opened.size)

            out := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, image.save(out, "GRIB"))
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("saved:RGB"), out.getvalue())
            AhkTest.AssertEqual([
                ["open", "GRIB", "GRIB", "F", [1, 1], 0],
                ["save", "RGB", [1, 1], ""],
            ], handler.Events)

            AhkTest.RaisesMatch(SyntaxError, "^Not a GRIB file$", (*) => plugin.GribStubImageFile(stdlib.io.BytesIO(badMagicBytes)))
            AhkTest.RaisesMatch(SyntaxError, "^Not a GRIB file$", (*) => plugin.GribStubImageFile(stdlib.io.BytesIO(wrongMarkerBytes)))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.GribStubImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.GribStubImageFile(stdlib.io.BytesIO(validBytes), stdlib.None, "extra"))
            AhkTest.RaisesMatch(TypeError, "^register_handler\(\) missing 1 required positional argument: 'handler'$", (*) => plugin.register_handler())
            AhkTest.RaisesMatch(TypeError, "^register_handler\(\) takes 1 positional argument but 2 were given$", (*) => plugin.register_handler(stdlib.None, stdlib.None))
        } finally {
            plugin.register_handler(stdlib.None)
            if IsSet(opened)
                StdlibPillowTest.CloseImage(opened)
            if IsSet(image)
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestHdf5StubImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "Hdf5StubImagePlugin"))
        plugin := stdlib.pillow.Hdf5StubImagePlugin

        validBytes := [0x89, 0x48, 0x44, 0x46, 0x0D, 0x0A, 0x1A, 0x0A]
        for byte in StdlibPillowTest.AsciiBytes("payload")
            validBytes.Push(byte)
        badBytes := [0x89, 0x48, 0x44, 0x46, 0x0D, 0x0A, 0x1A, 0x00]
        for byte in StdlibPillowTest.AsciiBytes("payload")
            badBytes.Push(byte)

        AhkTest.AssertTrue(plugin._accept(validBytes))
        AhkTest.AssertFalse(plugin._accept(badBytes))
        AhkTest.AssertFalse(plugin._accept([0x89, 0x48, 0x44, 0x46]))
        AhkTest.AssertFalse(plugin._accept([]))
        AhkTest.AssertEqual("HDF5", plugin.HDF5StubImageFile.format)
        AhkTest.AssertEqual("HDF5", plugin.HDF5StubImageFile.format_description)

        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("HDF5"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("HDF5"))
        AhkTest.AssertEqual("HDF5", stdlib.pillow.Image.registered_extensions()[".h5"])
        AhkTest.AssertEqual("HDF5", stdlib.pillow.Image.registered_extensions()[".hdf"])

        plugin.register_handler(stdlib.None)
        image := unset
        opened := unset
        try {
            image := stdlib.pillow.Image.new("RGB", [1, 1], [10, 20, 30])
            AhkTest.RaisesMatch(OSError, "^HDF5 save handler not installed$", (*) => image.save(stdlib.io.BytesIO(), "HDF5"))

            handler := StdlibPillowBufrHandler()
            AhkTest.AssertSame(stdlib.None, plugin.register_handler(handler))
            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(validBytes), "r", ["HDF5"])
            AhkTest.AssertEqual("HDF5", opened.format)
            AhkTest.AssertEqual("HDF5", opened.format_description)
            AhkTest.AssertEqual("F", opened.mode)
            AhkTest.AssertEqual([1, 1], opened.size)

            out := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, image.save(out, "HDF5"))
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("saved:RGB"), out.getvalue())
            AhkTest.AssertEqual([
                ["open", "HDF5", "HDF5", "F", [1, 1], 0],
                ["save", "RGB", [1, 1], ""],
            ], handler.Events)

            AhkTest.RaisesMatch(SyntaxError, "^Not an HDF file$", (*) => plugin.HDF5StubImageFile(stdlib.io.BytesIO(badBytes)))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.HDF5StubImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.HDF5StubImageFile(stdlib.io.BytesIO(validBytes), stdlib.None, "extra"))
            AhkTest.RaisesMatch(TypeError, "^register_handler\(\) missing 1 required positional argument: 'handler'$", (*) => plugin.register_handler())
            AhkTest.RaisesMatch(TypeError, "^register_handler\(\) takes 1 positional argument but 2 were given$", (*) => plugin.register_handler(stdlib.None, stdlib.None))
        } finally {
            plugin.register_handler(stdlib.None)
            if IsSet(opened)
                StdlibPillowTest.CloseImage(opened)
            if IsSet(image)
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestIcnsImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "IcnsImagePlugin"))
        plugin := stdlib.pillow.IcnsImagePlugin

        AhkTest.AssertEqual([105, 99, 110, 115], plugin.MAGIC)
        AhkTest.AssertEqual(8, plugin.HEADERSIZE)
        AhkTest.AssertTrue(plugin.enable_jpeg2k)
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("icnsdemo")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("ICONdemo")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("icn")))
        AhkTest.AssertFalse(plugin._accept([]))
        AhkTest.AssertEqual("ICNS", plugin.IcnsImageFile.format)
        AhkTest.AssertEqual("Mac OS icns resource", plugin.IcnsImageFile.format_description)
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("ICNS"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("ICNS"))
        AhkTest.AssertEqual("ICNS", stdlib.pillow.Image.registered_extensions()[".icns"])
        AhkTest.AssertEqual("image/icns", stdlib.pillow.Image.MIME["ICNS"])
        AhkTest.AssertEqual([[97, 98, 99, 100], 8], plugin.nextheader(stdlib.io.BytesIO(StdlibPillowTest.ConcatBytes(StdlibPillowTest.AsciiBytes("abcd"), [0, 0, 0, 8]))))
        AhkTest.Raises(Error, (*) => plugin.nextheader(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("abc"))))

        png16Bytes := StdlibPillowTest.IcnsPngBytes([16, 16])
        icp4Bytes := StdlibPillowTest.IcnsBytes([["icp4", png16Bytes]])
        ic11Bytes := StdlibPillowTest.IcnsBytes([["ic11", png16Bytes]])
        multiBytes := StdlibPillowTest.IcnsBytes([
            ["icp4", png16Bytes],
            ["ic11", png16Bytes],
        ])

        icnsFile := plugin.IcnsFile(stdlib.io.BytesIO(icp4Bytes))
        AhkTest.AssertEqual([16, png16Bytes.Length], icnsFile.dct["icp4"])
        AhkTest.AssertEqual([[16, 16, 1]], icnsFile.itersizes())
        AhkTest.AssertEqual([16, 16, 1], icnsFile.bestsize())

        multiFile := plugin.IcnsFile(stdlib.io.BytesIO(multiBytes))
        AhkTest.AssertEqual([[16, 16, 2], [16, 16, 1]], multiFile.itersizes())
        AhkTest.AssertEqual([16, 16, 2], multiFile.bestsize())

        openedIcp4 := unset
        openedIc11 := unset
        openedMulti := unset
        direct := unset
        image := unset
        saved := unset
        try {
            openedIcp4 := stdlib.pillow.Image.open(stdlib.io.BytesIO(icp4Bytes), "r", ["ICNS"])
            AhkTest.AssertEqual("ICNS", openedIcp4.format)
            AhkTest.AssertEqual("Mac OS icns resource", openedIcp4.format_description)
            AhkTest.AssertEqual("RGBA", openedIcp4.mode)
            AhkTest.AssertEqual([16, 16], openedIcp4.size)
            AhkTest.AssertEqual([[16, 16, 1]], openedIcp4.info["sizes"])
            AhkTest.AssertEqual([16, 16, 1], openedIcp4.best_size)
            AhkTest.AssertEqual([10, 20, 30, 40], openedIcp4.getpixel([0, 0]))
            AhkTest.AssertEqual([200, 10, 5, 255], openedIcp4.getpixel([1, 0]))

            openedIc11 := stdlib.pillow.Image.open(stdlib.io.BytesIO(ic11Bytes), "r", ["ICNS"])
            AhkTest.AssertEqual([16, 16, 2], openedIc11.best_size)
            AhkTest.AssertEqual([32, 32], openedIc11.size)
            AhkTest.AssertSame(stdlib.None, openedIc11.load())
            AhkTest.AssertEqual([16, 16], openedIc11.size)

            openedMulti := stdlib.pillow.Image.open(stdlib.io.BytesIO(multiBytes), "r", ["ICNS"])
            AhkTest.AssertEqual([[16, 16, 2], [16, 16, 1]], openedMulti.info["sizes"])
            AhkTest.AssertEqual([16, 16, 2], openedMulti.best_size)
            AhkTest.AssertEqual([32, 32], openedMulti.size)
            openedMulti.size := [16, 16]
            AhkTest.AssertEqual([16, 16], openedMulti.size)
            AhkTest.AssertSame(stdlib.None, openedMulti.load(2))
            AhkTest.AssertEqual([16, 16], openedMulti.size)
            AhkTest.AssertEqual([200, 10, 5, 255], openedMulti.getpixel([1, 0]))

            direct := plugin.IcnsImageFile(stdlib.io.BytesIO(icp4Bytes))
            AhkTest.AssertEqual("ICNS", direct.format)
            AhkTest.AssertEqual("RGBA", direct.mode)
            AhkTest.AssertEqual([16, 16], direct.size)

            image := stdlib.pillow.Image.new("RGBA", [16, 16], [1, 2, 3, 4])
            saved := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, image.save(saved, "ICNS"))
            savedBytes := saved.getvalue()
            AhkTest.AssertEqual([105, 99, 110, 115], StdlibPillowTest.ArraySlice(savedBytes, 1, 4))
            AhkTest.AssertEqual(savedBytes.Length, StdlibPillowTest.IcnsReadBe32(savedBytes, 5))
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("TOC "), StdlibPillowTest.ArraySlice(savedBytes, 9, 12))
            AhkTest.AssertEqual(72, StdlibPillowTest.IcnsReadBe32(savedBytes, 13))
            AhkTest.AssertEqual(8, StdlibPillowTest.CountPngSignatures(savedBytes))

            AhkTest.RaisesMatch(SyntaxError, "^not an icns file$", (*) => plugin.IcnsFile(stdlib.io.BytesIO(StdlibPillowTest.ConcatBytes(StdlibPillowTest.AsciiBytes("ICON"), [0, 0, 0, 8]))))
            AhkTest.RaisesMatch(SyntaxError, "^invalid block header$", (*) => plugin.IcnsFile(stdlib.io.BytesIO(StdlibPillowTest.ConcatBytes(StdlibPillowTest.AsciiBytes("icns"), [0, 0, 0, 16], StdlibPillowTest.AsciiBytes("BAD!"), [0, 0, 0, 0]))))
            AhkTest.RaisesMatch(SyntaxError, "^No 32bit icon resources found$", (*) => plugin.IcnsFile(stdlib.io.BytesIO(StdlibPillowTest.ConcatBytes(StdlibPillowTest.AsciiBytes("icns"), [0, 0, 0, 8]))).bestsize())
            AhkTest.RaisesMatch(ValueError, "^Unsupported icon subimage format$", (*) => plugin.IcnsFile(stdlib.io.BytesIO(StdlibPillowTest.IcnsBytes([["icp4", StdlibPillowTest.AsciiBytes("BAD!")]]))).getimage())
            AhkTest.RaisesMatch(KeyError, "^\(99, 99, 1\)$", (*) => plugin.IcnsFile(stdlib.io.BytesIO(icp4Bytes)).dataforsize([99, 99, 1]))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD!")), "r", ["ICNS"]))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.IcnsImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.IcnsImageFile(stdlib.io.BytesIO(icp4Bytes), stdlib.None, "extra"))
        } finally {
            if IsSet(openedIcp4)
                StdlibPillowTest.CloseImage(openedIcp4)
            if IsSet(openedIc11)
                StdlibPillowTest.CloseImage(openedIc11)
            if IsSet(openedMulti)
                StdlibPillowTest.CloseImage(openedMulti)
            if IsSet(direct)
                StdlibPillowTest.CloseImage(direct)
            if IsSet(image)
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestIcoImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "IcoImagePlugin"))
        plugin := stdlib.pillow.IcoImagePlugin

        AhkTest.AssertEqual([0, 0, 1, 0], plugin._MAGIC)
        AhkTest.AssertEqual("ICO", plugin.IcoImageFile.format)
        AhkTest.AssertEqual("Windows Icon", plugin.IcoImageFile.format_description)
        AhkTest.AssertEqual(["width", "height", "nb_color", "reserved", "planes", "bpp", "size", "offset", "dim", "square", "color_depth"], plugin.IconHeader._fields)
        AhkTest.AssertTrue(plugin._accept([0, 0, 1, 0, 114, 101, 115, 116]))
        AhkTest.AssertFalse(plugin._accept([0, 0, 2, 0, 114, 101, 115, 116]))
        AhkTest.AssertFalse(plugin._accept([0, 0, 1]))
        AhkTest.AssertFalse(plugin._accept([]))

        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("ICO"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("ICO"))
        AhkTest.AssertEqual("ICO", stdlib.pillow.Image.registered_extensions()[".ico"])
        AhkTest.AssertEqual("image/x-icon", stdlib.pillow.Image.MIME["ICO"])

        source := unset
        small := unset
        big := unset
        icoFile := unset
        opened := unset
        direct := unset
        image16 := unset
        image32 := unset
        bmpOpened := unset
        appendOpened := unset
        try {
            source := stdlib.pillow.Image.new("RGBA", [32, 32], [10, 20, 30, 40])
            source.putpixel([1, 0], [200, 10, 5, 255])
            defaultFp := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, source.save(defaultFp, "ICO", { sizes: [[16, 16], [32, 32]] }))
            defaultBytes := defaultFp.getvalue()

            AhkTest.AssertEqual([0, 0, 1, 0, 2, 0, 16, 16], StdlibPillowTest.ArraySlice(defaultBytes, 1, 8))
            AhkTest.AssertEqual(2, StdlibPillowTest.IcoLe16(defaultBytes, 5))
            AhkTest.AssertEqual(2, StdlibPillowTest.CountPngSignatures(defaultBytes))
            entries := StdlibPillowTest.IcoDirectoryEntries(defaultBytes)
            AhkTest.AssertEqual(16, entries[1]["width"])
            AhkTest.AssertEqual(16, entries[1]["height"])
            AhkTest.AssertEqual(32, entries[1]["bpp"])
            AhkTest.AssertEqual([137, 80, 78, 71, 13, 10, 26, 10], entries[1]["payload_prefix"])
            AhkTest.AssertEqual(32, entries[2]["width"])
            AhkTest.AssertEqual(32, entries[2]["height"])

            icoFile := plugin.IcoFile(stdlib.io.BytesIO(defaultBytes))
            AhkTest.AssertEqual(2, icoFile.nb_items)
            AhkTest.AssertEqual([[16, 16], [32, 32]], icoFile.sizes())
            AhkTest.AssertEqual(32, icoFile.entry[1].width)
            AhkTest.AssertEqual(32, icoFile.entry[1].height)
            AhkTest.AssertEqual([32, 32], icoFile.entry[1].dim)
            AhkTest.AssertEqual(1024, icoFile.entry[1].square)
            AhkTest.AssertEqual(32, icoFile.entry[1].color_depth)
            AhkTest.AssertEqual(32, icoFile.entry[1]._asdict()["bpp"])
            AhkTest.AssertEqual(1, icoFile.getentryindex([16, 16]))
            AhkTest.AssertEqual(0, icoFile.getentryindex([32, 32]))
            AhkTest.AssertEqual(1, icoFile.getentryindex([16, 16], 32))
            AhkTest.AssertEqual(0, icoFile.getentryindex([99, 99]))

            image16 := icoFile.getimage([16, 16])
            AhkTest.AssertEqual("PNG", image16.format)
            AhkTest.AssertEqual("RGBA", image16.mode)
            AhkTest.AssertEqual([16, 16], image16.size)
            image32 := icoFile.getimage([32, 32])
            AhkTest.AssertEqual("PNG", image32.format)
            AhkTest.AssertEqual("RGBA", image32.mode)
            AhkTest.AssertEqual([32, 32], image32.size)
            AhkTest.AssertEqual([200, 10, 5, 255], image32.getpixel([1, 0]))

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(defaultBytes), "r", ["ICO"])
            AhkTest.AssertEqual("ICO", opened.format)
            AhkTest.AssertEqual("Windows Icon", opened.format_description)
            AhkTest.AssertEqual("RGBA", opened.mode)
            AhkTest.AssertEqual([32, 32], opened.size)
            AhkTest.AssertEqual([[16, 16], [32, 32]], opened.info["sizes"])
            AhkTest.AssertEqual([200, 10, 5, 255], opened.getpixel([1, 0]))
            opened.size := [16, 16]
            AhkTest.AssertEqual([16, 16], opened.size)
            AhkTest.AssertSame(stdlib.None, opened.load())
            AhkTest.AssertEqual([16, 16], opened.size)
            AhkTest.RaisesMatch(ValueError, "^This is not one of the allowed sizes of this image$", (*) => opened.size := [99, 99])

            direct := plugin.IcoImageFile(stdlib.io.BytesIO(defaultBytes))
            AhkTest.AssertEqual("ICO", direct.format)
            AhkTest.AssertEqual("RGBA", direct.mode)
            AhkTest.AssertEqual([32, 32], direct.size)

            small := stdlib.pillow.Image.new("RGBA", [16, 16], [10, 20, 30, 40])
            big := stdlib.pillow.Image.new("RGBA", [32, 32], [10, 20, 30, 40])
            big.putpixel([1, 0], [1, 2, 3, 4])
            appendFp := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, big.save(appendFp, "ICO", { sizes: [[16, 16], [32, 32]], append_images: [small] }))
            appendBytes := appendFp.getvalue()
            AhkTest.AssertEqual(2, StdlibPillowTest.IcoLe16(appendBytes, 5))
            AhkTest.AssertEqual(2, StdlibPillowTest.CountPngSignatures(appendBytes))
            appendOpened := stdlib.pillow.Image.open(stdlib.io.BytesIO(appendBytes), "r", ["ICO"])
            AhkTest.AssertEqual([32, 32], appendOpened.size)
            AhkTest.AssertEqual([1, 2, 3, 4], appendOpened.getpixel([1, 0]))

            bmpFp := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, source.save(bmpFp, "ICO", { sizes: [[16, 16]], bitmap_format: "bmp" }))
            bmpBytes := bmpFp.getvalue()
            AhkTest.AssertEqual([0, 0, 1, 0, 1, 0, 16, 16], StdlibPillowTest.ArraySlice(bmpBytes, 1, 8))
            bmpEntries := StdlibPillowTest.IcoDirectoryEntries(bmpBytes)
            AhkTest.AssertEqual([40, 0, 0, 0, 16, 0, 0, 0], bmpEntries[1]["payload_prefix"])
            bmpOpened := stdlib.pillow.Image.open(stdlib.io.BytesIO(bmpBytes), "r", ["ICO"])
            AhkTest.AssertEqual("ICO", bmpOpened.format)
            AhkTest.AssertEqual("RGBA", bmpOpened.mode)
            AhkTest.AssertEqual([16, 16], bmpOpened.size)

            AhkTest.RaisesMatch(SyntaxError, "^not an ICO file$", (*) => plugin.IcoFile(stdlib.io.BytesIO([0, 0, 2, 0, 0, 0])))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD!")), "r", ["ICO"]))
            AhkTest.RaisesMatch(TypeError, "^IcoFile\.__init__\(\) missing 1 required positional argument: 'buf'$", (*) => plugin.IcoFile())
            AhkTest.RaisesMatch(TypeError, "^IcoFile\.__init__\(\) takes 2 positional arguments but 3 were given$", (*) => plugin.IcoFile(stdlib.io.BytesIO(defaultBytes), stdlib.None))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.IcoImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.IcoImageFile(stdlib.io.BytesIO(defaultBytes), stdlib.None, "extra"))
        } finally {
            if IsSet(bmpOpened)
                StdlibPillowTest.CloseImage(bmpOpened)
            if IsSet(appendOpened)
                StdlibPillowTest.CloseImage(appendOpened)
            if IsSet(direct)
                StdlibPillowTest.CloseImage(direct)
            if IsSet(opened)
                StdlibPillowTest.CloseImage(opened)
            if IsSet(image32)
                StdlibPillowTest.CloseImage(image32)
            if IsSet(image16)
                StdlibPillowTest.CloseImage(image16)
            if IsSet(big)
                StdlibPillowTest.CloseImage(big)
            if IsSet(small)
                StdlibPillowTest.CloseImage(small)
            if IsSet(source)
                StdlibPillowTest.CloseImage(source)
        }
    }

    static TestImImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "ImImagePlugin"))
        plugin := stdlib.pillow.ImImagePlugin

        AhkTest.AssertEqual("IM", plugin.ImImageFile.format)
        AhkTest.AssertEqual("IFUNC Image Memory", plugin.ImImageFile.format_description)
        AhkTest.AssertFalse(plugin.ImImageFile._close_exclusive_fp_after_loading)
        AhkTest.AssertEqual("Comment", plugin.COMMENT)
        AhkTest.AssertEqual("Image type", plugin.MODE)
        AhkTest.AssertTrue(plugin.TAGS.Has(plugin.COMMENT))
        AhkTest.AssertTrue(plugin.TAGS.Has(plugin.SIZE))
        AhkTest.AssertEqual(["RGB", "RGB;L"], plugin.OPEN["RGB image"])
        AhkTest.AssertEqual(["I;16", "I;16"], plugin.OPEN["L 16 image"])
        AhkTest.AssertEqual(["F", "F;5"], plugin.OPEN["L*5 image"])
        AhkTest.AssertTrue(plugin.SAVE.Has("L"))
        AhkTest.AssertTrue(plugin.SAVE.Has("RGB"))
        AhkTest.AssertEqual(42, plugin.number("42"))
        AhkTest.AssertEqual(-7, plugin.number("-7"))
        AhkTest.AssertEqual(3.25, plugin.number("3.25"))
        AhkTest.RaisesMatch(ValueError, "^could not convert string to float: 'not-a-number'$", (*) => plugin.number("not-a-number"))
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("IM"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("IM"))
        AhkTest.AssertEqual("IM", stdlib.pillow.Image.registered_extensions()[".im"])

        lBytes := StdlibPillowTest.ImBytes([
            "Comment: first",
            "Comment: second",
            "Image type: Greyscale image",
            "Image size (x*y): 2*2",
            "File size (no of images): 2",
            "Scale (x,y): 1.5,2",
            "Name: demo",
        ], [1, 2, 3, 4, 5, 6, 7, 8])

        rgbBytes := StdlibPillowTest.ImBytes([
            "Image type: RGB image",
            "Image size (x*y): 2*2",
        ], [10, 20, 30, 1, 2, 3, 40, 50, 60, 4, 5, 6])

        palette := []
        loop 256
            palette.Push(A_Index - 1)
        loop 256
            palette.Push(256 - A_Index)
        loop 256
            palette.Push(Mod((A_Index - 1) * 2, 256))
        pBytes := StdlibPillowTest.ImBytes([
            "Image type: Greyscale image",
            "Image size (x*y): 2*2",
            "Lut: 1",
        ], [0, 1, 2, 3], palette)

        openedL := unset
        openedRgb := unset
        openedP := unset
        direct := unset
        sourceL := unset
        roundL := unset
        sourceP := unset
        roundP := unset
        try {
            openedL := stdlib.pillow.Image.open(stdlib.io.BytesIO(lBytes), "r", ["IM"])
            AhkTest.AssertEqual("IM", openedL.format)
            AhkTest.AssertEqual("IFUNC Image Memory", openedL.format_description)
            AhkTest.AssertEqual("L", openedL.mode)
            AhkTest.AssertEqual("L", openedL.rawmode)
            AhkTest.AssertEqual([2, 2], openedL.size)
            AhkTest.AssertEqual(2, openedL.n_frames)
            AhkTest.AssertTrue(openedL.is_animated)
            AhkTest.AssertEqual(0, openedL.tell())
            AhkTest.AssertEqual(["first", "second"], openedL.info["Comment"])
            AhkTest.AssertEqual([2, 2], openedL.info["Image size (x*y)"])
            AhkTest.AssertEqual(2, openedL.info["File size (no of images)"])
            AhkTest.AssertEqual([1.5, 2], openedL.info["Scale (x,y)"])
            AhkTest.AssertEqual("demo", openedL.info["Name"])
            AhkTest.AssertEqual(4, openedL.getpixel([1, 0]))
            AhkTest.AssertSame(stdlib.None, openedL.seek(1))
            AhkTest.AssertEqual(1, openedL.tell())
            AhkTest.AssertEqual(8, openedL.getpixel([1, 0]))
            AhkTest.RaisesMatch(EOFError, "^attempt to seek outside sequence$", (*) => openedL.seek(2))

            openedRgb := stdlib.pillow.Image.open(stdlib.io.BytesIO(rgbBytes), "r", ["IM"])
            AhkTest.AssertEqual("RGB", openedRgb.mode)
            AhkTest.AssertEqual("RGB;L", openedRgb.rawmode)
            AhkTest.AssertFalse(openedRgb.is_animated)
            AhkTest.AssertEqual(1, openedRgb.n_frames)
            AhkTest.AssertEqual([40, 60, 5], openedRgb.getpixel([0, 0]))
            AhkTest.AssertEqual([50, 4, 6], openedRgb.getpixel([1, 0]))
            AhkTest.AssertEqual([10, 30, 2], openedRgb.getpixel([0, 1]))
            AhkTest.AssertEqual([20, 1, 3], openedRgb.getpixel([1, 1]))

            openedP := stdlib.pillow.Image.open(stdlib.io.BytesIO(pBytes), "r", ["IM"])
            AhkTest.AssertEqual("P", openedP.mode)
            AhkTest.AssertEqual("P", openedP.rawmode)
            AhkTest.AssertEqual([0, 255, 0, 1, 254, 2, 2, 253, 4, 3, 252, 6], StdlibPillowTest.ArraySlice(openedP.getpalette(), 1, 12))
            AhkTest.AssertEqual([2, 3, 0, 1], openedP.getdata())

            direct := plugin.ImImageFile(stdlib.io.BytesIO(lBytes))
            AhkTest.AssertEqual("IM", direct.format)
            AhkTest.AssertEqual("L", direct.mode)
            AhkTest.AssertEqual([2, 2], direct.size)

            sourceL := stdlib.pillow.Image.new("L", [2, 2])
            sourceL.putdata([9, 8, 7, 6])
            outL := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, sourceL.save(outL, "IM", { frames: 3 }))
            savedL := outL.getvalue()
            AhkTest.AssertEqual(516, savedL.Length)
            AhkTest.AssertEqual(0x1A, savedL[512])
            AhkTest.AssertContains("Image type: Greyscale image", StdlibPillowTest.AsciiFromBytes(StdlibPillowTest.ArraySlice(savedL, 1, 80)))
            roundL := stdlib.pillow.Image.open(stdlib.io.BytesIO(savedL), "r", ["IM"])
            AhkTest.AssertEqual("L", roundL.mode)
            AhkTest.AssertEqual(3, roundL.n_frames)
            AhkTest.AssertEqual(6, roundL.getpixel([1, 1]))

            sourceP := stdlib.pillow.Image.new("P", [2, 2])
            sourceP.putdata([0, 1, 2, 3])
            sourceP.putpalette([0, 0, 0, 10, 20, 30, 40, 50, 60, 70, 80, 90])
            outP := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, sourceP.save(outP, "IM"))
            savedP := outP.getvalue()
            AhkTest.AssertEqual(1284, savedP.Length)
            AhkTest.AssertContains("Lut: 1", StdlibPillowTest.AsciiFromBytes(StdlibPillowTest.ArraySlice(savedP, 1, 120)))
            roundP := stdlib.pillow.Image.open(stdlib.io.BytesIO(savedP), "r", ["IM"])
            AhkTest.AssertEqual("P", roundP.mode)
            AhkTest.AssertEqual([0, 0, 0, 10, 20, 30, 40, 50, 60, 70, 80, 90], StdlibPillowTest.ArraySlice(roundP.getpalette(), 1, 12))
            AhkTest.AssertEqual([0, 1, 2, 3], roundP.getdata())

            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("not im")), "r", ["IM"]))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("Bad header`n")), "r", ["IM"]))
            AhkTest.RaisesMatch(ValueError, "^Cannot save HSV images as IM$", (*) => StdlibPillowTest.ImSaveBadMode(plugin))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.ImImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.ImImageFile(stdlib.io.BytesIO(lBytes), stdlib.None, "extra"))
        } finally {
            if IsSet(roundP)
                StdlibPillowTest.CloseImage(roundP)
            if IsSet(sourceP)
                StdlibPillowTest.CloseImage(sourceP)
            if IsSet(roundL)
                StdlibPillowTest.CloseImage(roundL)
            if IsSet(sourceL)
                StdlibPillowTest.CloseImage(sourceL)
            if IsSet(direct)
                StdlibPillowTest.CloseImage(direct)
            if IsSet(openedP)
                StdlibPillowTest.CloseImage(openedP)
            if IsSet(openedRgb)
                StdlibPillowTest.CloseImage(openedRgb)
            if IsSet(openedL)
                StdlibPillowTest.CloseImage(openedL)
        }
    }

    static TestImtImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "ImtImagePlugin"))
        plugin := stdlib.pillow.ImtImagePlugin

        AhkTest.AssertEqual("([a-z]*) ([^ \r\n]*)", plugin.field.pattern)
        AhkTest.AssertEqual("IMT", plugin.ImtImageFile.format)
        AhkTest.AssertEqual("IM Tools", plugin.ImtImageFile.format_description)
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("IMT"))
        AhkTest.AssertTrue(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "IMT"))
        AhkTest.AssertFalse(stdlib.pillow.Image.registered_extensions().Has(".imt"))

        imtBytes := StdlibPillowTest.ConcatBytes(
            StdlibPillowTest.AsciiBytes("* comment ignored`nwidth 3`nheight 2`npixel n8`n"),
            [0x0C, 1, 2, 3, 4, 5, 6]
        )
        noNewlineBytes := StdlibPillowTest.AsciiBytes("width 3 height 2 pixel n8")
        unsupportedPixelBytes := StdlibPillowTest.ConcatBytes(
            StdlibPillowTest.AsciiBytes("width 3`nheight 2`npixel n16`n"),
            [0x0C, 1, 2, 3, 4, 5, 6]
        )
        shortBytes := StdlibPillowTest.ConcatBytes(
            StdlibPillowTest.AsciiBytes("width 3`nheight 2`npixel n8`n"),
            [0x0C, 1, 2, 3, 4, 5]
        )

        direct := unset
        opened := unset
        try {
            direct := plugin.ImtImageFile(stdlib.io.BytesIO(imtBytes))
            AhkTest.AssertEqual("IMT", direct.format)
            AhkTest.AssertEqual("IM Tools", direct.format_description)
            AhkTest.AssertEqual("L", direct.mode)
            AhkTest.AssertEqual([3, 2], direct.size)
            AhkTest.AssertEqual(["raw", [0, 0, 3, 2], 45, "L"], direct.tile[1])
            AhkTest.AssertEqual([1, 2, 3, 4, 5, 6], direct.getdata())

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(imtBytes), "r", ["IMT"])
            AhkTest.AssertEqual("IMT", opened.format)
            AhkTest.AssertEqual("L", opened.mode)
            AhkTest.AssertEqual([3, 2], opened.size)
            AhkTest.AssertEqual([1, 2, 3, 4, 5, 6], opened.getdata())

            AhkTest.RaisesMatch(SyntaxError, "^not an IM file$", (*) => plugin.ImtImageFile(stdlib.io.BytesIO(noNewlineBytes)))
            AhkTest.RaisesMatch(SyntaxError, "^not identified by this driver$", (*) => plugin.ImtImageFile(stdlib.io.BytesIO(unsupportedPixelBytes)).load())
            AhkTest.RaisesMatch(OSError, "^image file is truncated \(1 bytes not processed\)$", (*) => plugin.ImtImageFile(stdlib.io.BytesIO(shortBytes)).load())
        } finally {
            if IsSet(opened)
                StdlibPillowTest.CloseImage(opened)
            if IsSet(direct)
                StdlibPillowTest.CloseImage(direct)
        }
    }

    static TestIptcImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "IptcImagePlugin"))
        plugin := stdlib.pillow.IptcImagePlugin

        AhkTest.AssertEqual("raw", plugin.COMPRESSION[1])
        AhkTest.AssertEqual("jpeg", plugin.COMPRESSION[5])
        AhkTest.AssertEqual(258, plugin._i([1, 2]))
        AhkTest.AssertEqual(0, plugin._i([]))
        AhkTest.AssertEqual(7, plugin._i8(7))
        AhkTest.AssertEqual(8, plugin._i8([8, 9]))
        AhkTest.AssertEqual(4660, plugin.i16([0x12, 0x34]))
        AhkTest.AssertEqual(0x01020304, plugin.i32([1, 2, 3, 4]))
        iValue := unset
        iRecords := stdlib.warnings.catch_warnings(true).Call((records) => iValue := plugin.i([1, 2]))
        AhkTest.AssertEqual(258, iValue)
        AhkTest.AssertEqual(1, iRecords.Length)
        AhkTest.AssertContains("IptcImagePlugin.i is deprecated", iRecords[1].message)
        dumpBuffer := stdlib.io.StringIO()
        dumpValue := unset
        dumpRecords := stdlib.warnings.catch_warnings(true).Call((records) => dumpValue := plugin.dump([0, [0x0F], 255], dumpBuffer))
        AhkTest.AssertSame(stdlib.None, dumpValue)
        AhkTest.AssertEqual("00 0f ff `n", dumpBuffer.getvalue())
        AhkTest.AssertContains("IptcImagePlugin.dump is deprecated", dumpRecords[1].message)
        AhkTest.AssertEqual([0, 0, 0, 0], plugin.PAD)
        AhkTest.AssertEqual("IPTC", plugin.IptcImageFile.format)
        AhkTest.AssertEqual("IPTC/NAA", plugin.IptcImageFile.format_description)
        AhkTest.AssertEqual("IPTC", stdlib.pillow.Image.registered_extensions()[".iim"])
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("IPTC"))

        iptcBytes := StdlibPillowTest.IptcBytes([
            [[2, 5], StdlibPillowTest.AsciiBytes("headline-one")],
            [[2, 5], StdlibPillowTest.AsciiBytes("headline-two")],
            [[3, 20], StdlibPillowTest.Be16(3)],
            [[3, 30], StdlibPillowTest.Be16(2)],
            [[3, 60], [1, 0]],
            [[3, 120], StdlibPillowTest.Be16(1)],
            [[8, 10], [1, 2, 3, 4, 5, 6]],
        ])
        badMagicBytes := StdlibPillowTest.ConcatBytes(StdlibPillowTest.AsciiBytes("BAD"), iptcBytes)
        badCompressionBytes := StdlibPillowTest.IptcBytes([
            [[3, 20], StdlibPillowTest.Be16(1)],
            [[3, 30], StdlibPillowTest.Be16(1)],
            [[3, 60], [1, 0]],
            [[3, 120], StdlibPillowTest.Be16(99)],
            [[8, 10], [1]],
        ])
        illegalLengthBytes := [0x1C, 3, 20, 133, 0]

        direct := unset
        opened := unset
        try {
            direct := plugin.IptcImageFile(stdlib.io.BytesIO(iptcBytes))
            AhkTest.AssertEqual("IPTC", direct.format)
            AhkTest.AssertEqual("IPTC/NAA", direct.format_description)
            AhkTest.AssertEqual("L", direct.mode)
            AhkTest.AssertEqual([3, 2], direct.size)
            AhkTest.AssertEqual(["iptc", [0, 0, 3, 2], 62, "raw"], direct.tile[1])
            AhkTest.AssertEqual(3, direct.getint([3, 20]))
            AhkTest.AssertEqual(["headline-one", "headline-two"], StdlibPillowTest.AsciiList(direct.info["2,5"]))
            AhkTest.AssertEqual([1, 2, 3, 4, 5, 6], direct.getdata())

            directInfo := plugin.getiptcinfo(direct)
            AhkTest.AssertEqual(["headline-one", "headline-two"], StdlibPillowTest.AsciiList(directInfo["2,5"]))
            AhkTest.AssertSame(stdlib.None, plugin.getiptcinfo(stdlib.pillow.Image.new("RGB", [1, 1])))

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(iptcBytes), "r", ["IPTC"])
            AhkTest.AssertEqual("IPTC", opened.format)
            AhkTest.AssertEqual("L", opened.mode)
            AhkTest.AssertEqual([3, 2], opened.size)
            AhkTest.AssertEqual([1, 2, 3, 4, 5, 6], opened.getdata())

            AhkTest.RaisesMatch(SyntaxError, "^invalid IPTC/NAA file$", (*) => plugin.IptcImageFile(stdlib.io.BytesIO(badMagicBytes)))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(badMagicBytes), "r", ["IPTC"]))
            AhkTest.RaisesMatch(OSError, "^Unknown IPTC image compression$", (*) => plugin.IptcImageFile(stdlib.io.BytesIO(badCompressionBytes)))
            AhkTest.RaisesMatch(OSError, "^illegal field length in IPTC/NAA file$", (*) => plugin.IptcImageFile(stdlib.io.BytesIO(illegalLengthBytes)))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.IptcImageFile())
        } finally {
            if IsSet(opened)
                StdlibPillowTest.CloseImage(opened)
            if IsSet(direct)
                StdlibPillowTest.CloseImage(direct)
        }
    }

    static TestJpegImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "JpegImagePlugin"))
        plugin := stdlib.pillow.JpegImagePlugin

        jpegBytes := StdlibPillowTest.JpegHeaderBytes()

        AhkTest.AssertTrue(HasProp(plugin, "JpegImageFile"))
        AhkTest.AssertTrue(HasProp(plugin, "_save"))
        AhkTest.AssertEqual("JPEG", plugin.JpegImageFile.format)
        AhkTest.AssertEqual("JPEG (ISO 10918)", plugin.JpegImageFile.format_description)
        AhkTest.AssertEqual("L", plugin.RAWMODE["1"])
        AhkTest.AssertEqual("RGB", plugin.RAWMODE["RGBX"])
        AhkTest.AssertEqual("CMYK;I", plugin.RAWMODE["CMYK"])
        AhkTest.AssertEqual(64, plugin.zigzag_index.Length)
        AhkTest.AssertEqual([0, 1, 5, 6, 14, 15, 27, 28, 2, 4], StdlibPillowTest.ArraySlice(plugin.zigzag_index, 1, 10))
        AhkTest.AssertEqual([35, 36, 48, 49, 57, 58, 62, 63], StdlibPillowTest.ArraySlice(plugin.zigzag_index, 57, 64))
        AhkTest.AssertEqual(0, plugin.samplings["1,1,1,1,1,1"])
        AhkTest.AssertEqual(1, plugin.samplings["2,1,1,1,1,1"])
        AhkTest.AssertEqual(2, plugin.samplings["2,2,1,1,1,1"])
        AhkTest.AssertEqual(4660, plugin.i16([0x12, 0x34]))
        AhkTest.AssertEqual(4660, plugin.i16([0, 0, 0x12, 0x34], 2))
        AhkTest.AssertEqual(305419896, plugin.i32([0x12, 0x34, 0x56, 0x78]))
        AhkTest.AssertEqual(305419896, plugin.i32([0, 0, 0x12, 0x34, 0x56, 0x78], 2))
        AhkTest.AssertEqual([0x23], plugin.o8(0x123))
        AhkTest.AssertEqual([0x12, 0x34], plugin.o16(0x1234))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.ArraySlice(jpegBytes, 1, 16)))
        AhkTest.AssertTrue(plugin._accept([0xFF, 0xD8, 0xFF]))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("BAD")))

        AhkTest.AssertEqual("JPEG", stdlib.pillow.Image.registered_extensions()[".jfif"])
        AhkTest.AssertEqual("JPEG", stdlib.pillow.Image.registered_extensions()[".jpe"])
        AhkTest.AssertEqual("JPEG", stdlib.pillow.Image.registered_extensions()[".jpg"])
        AhkTest.AssertEqual("JPEG", stdlib.pillow.Image.registered_extensions()[".jpeg"])
        AhkTest.AssertEqual("image/jpeg", stdlib.pillow.Image.MIME["JPEG"])
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("JPEG"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("JPEG"))

        direct := unset
        opened := unset
        nonJpeg := unset
        try {
            direct := plugin.JpegImageFile(stdlib.io.BytesIO(jpegBytes))
            AhkTest.AssertEqual("JPEG", direct.format)
            AhkTest.AssertEqual("JPEG (ISO 10918)", direct.format_description)
            AhkTest.AssertEqual("RGB", direct.mode)
            AhkTest.AssertEqual([3, 2], direct.size)
            AhkTest.AssertEqual(8, direct.bits)
            AhkTest.AssertEqual(3, direct.layers)
            AhkTest.AssertEqual([[1, 2, 2, 0], [2, 1, 1, 0], [3, 1, 1, 0]], direct.layer)
            AhkTest.AssertEqual(2, plugin.get_sampling(direct))
            AhkTest.AssertEqual(257, direct.info["jfif"])
            AhkTest.AssertEqual([1, 1], direct.info["jfif_version"])
            AhkTest.AssertEqual([72, 96], direct.info["dpi"])
            AhkTest.AssertEqual([72, 96], direct.info["jfif_density"])
            AhkTest.AssertTrue(direct.quantization.Has(0))

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(jpegBytes), "r", ["JPEG"])
            AhkTest.AssertEqual("JPEG", opened.format)
            AhkTest.AssertEqual("RGB", opened.mode)
            AhkTest.AssertEqual([3, 2], opened.size)
            AhkTest.AssertEqual(2, plugin.get_sampling(opened))

            nonJpeg := stdlib.pillow.Image.new("RGB", [1, 1])
            AhkTest.AssertEqual(-1, plugin.get_sampling(nonJpeg))

            AhkTest.RaisesMatch(SyntaxError, "^not a JPEG file$", (*) => plugin.JpegImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD"))))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD")), "r", ["JPEG"]))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.JpegImageFile())
            AhkTest.RaisesMatch(TypeError, "^get_sampling\(\) missing 1 required positional argument: 'im'$", (*) => plugin.get_sampling())
        } finally {
            if IsSet(nonJpeg)
                StdlibPillowTest.CloseImage(nonJpeg)
            if IsSet(opened)
                StdlibPillowTest.CloseImage(opened)
            if IsSet(direct)
                StdlibPillowTest.CloseImage(direct)
        }
    }

    static TestJpeg2KImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "Jpeg2KImagePlugin"))
        plugin := stdlib.pillow.Jpeg2KImagePlugin

        jp2Bytes := StdlibPillowTest.Jp2Bytes(3, 2, 3, 7, "jp2 ", true)
        jp2JpxBytes := StdlibPillowTest.Jp2Bytes(4, 5, 3, 7, "jpx ")
        jp2CmykBytes := StdlibPillowTest.Jp2Bytes(2, 1, 4, 7, "jp2 ", false, true)
        j2kLBytes := StdlibPillowTest.J2kBytes(3, 2, 1, 7, "hi")
        j2kRgbBytes := StdlibPillowTest.J2kBytes(4, 2, 3, 7, "hi")
        j2kI16Bytes := StdlibPillowTest.J2kBytes(2, 2, 1, 15, "wide")

        AhkTest.AssertTrue(HasProp(plugin, "BoxReader"))
        AhkTest.AssertTrue(HasProp(plugin, "Jpeg2KImageFile"))
        AhkTest.AssertTrue(HasProp(plugin, "_save"))
        AhkTest.AssertEqual("JPEG2000", plugin.Jpeg2KImageFile.format)
        AhkTest.AssertEqual("JPEG 2000 (ISO 15444)", plugin.Jpeg2KImageFile.format_description)
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.ArraySlice(jp2Bytes, 1, 16)))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.ArraySlice(j2kLBytes, 1, 16)))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("not jpeg2k")))
        AhkTest.AssertFalse(plugin._accept([0xFF, 0x4F]))
        AhkTest.AssertEqual(6.0, plugin._res_to_dpi(600, 254, 2))
        AhkTest.AssertSame(stdlib.None, plugin._res_to_dpi(600, 0, 2))

        AhkTest.AssertEqual("JPEG2000", stdlib.pillow.Image.registered_extensions()[".jp2"])
        AhkTest.AssertEqual("JPEG2000", stdlib.pillow.Image.registered_extensions()[".j2k"])
        AhkTest.AssertEqual("JPEG2000", stdlib.pillow.Image.registered_extensions()[".jpc"])
        AhkTest.AssertEqual("JPEG2000", stdlib.pillow.Image.registered_extensions()[".jpf"])
        AhkTest.AssertEqual("JPEG2000", stdlib.pillow.Image.registered_extensions()[".jpx"])
        AhkTest.AssertEqual("JPEG2000", stdlib.pillow.Image.registered_extensions()[".j2c"])
        AhkTest.AssertEqual("image/jp2", stdlib.pillow.Image.MIME["JPEG2000"])
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("JPEG2000"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("JPEG2000"))

        readerBytes := StdlibPillowTest.ConcatBytes(
            StdlibPillowTest.Jp2Box("abcd", StdlibPillowTest.AsciiBytes("XYZ")),
            StdlibPillowTest.Jp2Box("efgh", StdlibPillowTest.AsciiBytes("12"))
        )
        reader := plugin.BoxReader(stdlib.io.BytesIO(readerBytes), 22)
        AhkTest.AssertTrue(reader.has_length)
        AhkTest.AssertEqual(22, reader.length)
        AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("abcd"), reader.next_box_type())
        AhkTest.AssertEqual(3, reader.remaining_in_box)
        AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("XYZ"), reader.read_boxes()._read_bytes(3))
        AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("efgh"), reader.next_box_type())
        AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("12"), reader.read_fields(">2s")[1])
        AhkTest.AssertTrue(reader.has_next_box())

        direct := unset
        jp2 := unset
        jp2Jpx := unset
        jp2Cmyk := unset
        j2kL := unset
        j2kRgb := unset
        j2kI16 := unset
        try {
            direct := plugin.Jpeg2KImageFile(stdlib.io.BytesIO(jp2Bytes))
            AhkTest.AssertEqual("JPEG2000", direct.format)
            AhkTest.AssertEqual("RGB", direct.mode)
            AhkTest.AssertEqual([3, 2], direct.size)
            AhkTest.AssertEqual(["jpeg2k", [0, 0, 3, 2], 0, ["jp2", 0, 0, -1, jp2Bytes.Length]], direct.tile[1])

            jp2 := stdlib.pillow.Image.open(stdlib.io.BytesIO(jp2Bytes), "r", ["JPEG2000"])
            AhkTest.AssertEqual("jp2", jp2.codec)
            AhkTest.AssertEqual("RGB", jp2.mode)
            AhkTest.AssertEqual([3, 2], jp2.size)
            AhkTest.AssertEqual([6.0, 3.0], jp2.info["dpi"])
            AhkTest.AssertEqual(["jpeg2k", [0, 0, 3, 2], 0, ["jp2", 0, 0, -1, jp2Bytes.Length]], jp2.tile[1])

            jp2Jpx := stdlib.pillow.Image.open(stdlib.io.BytesIO(jp2JpxBytes), "r", ["JPEG2000"])
            AhkTest.AssertEqual("image/jpx", jp2Jpx.custom_mimetype)
            AhkTest.AssertEqual([4, 5], jp2Jpx.size)

            jp2Cmyk := stdlib.pillow.Image.open(stdlib.io.BytesIO(jp2CmykBytes), "r", ["JPEG2000"])
            AhkTest.AssertEqual("CMYK", jp2Cmyk.mode)
            AhkTest.AssertEqual([2, 1], jp2Cmyk.size)

            j2kL := stdlib.pillow.Image.open(stdlib.io.BytesIO(j2kLBytes), "r", ["JPEG2000"])
            AhkTest.AssertEqual("j2k", j2kL.codec)
            AhkTest.AssertEqual("L", j2kL.mode)
            AhkTest.AssertEqual([3, 2], j2kL.size)
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("hi"), j2kL.info["comment"])
            AhkTest.AssertEqual(["jpeg2k", [0, 0, 3, 2], 0, ["j2k", 0, 0, -1, j2kLBytes.Length]], j2kL.tile[1])

            j2kRgb := stdlib.pillow.Image.open(stdlib.io.BytesIO(j2kRgbBytes), "r", ["JPEG2000"])
            AhkTest.AssertEqual("RGB", j2kRgb.mode)
            AhkTest.AssertEqual([4, 2], j2kRgb.size)

            j2kI16 := stdlib.pillow.Image.open(stdlib.io.BytesIO(j2kI16Bytes), "r", ["JPEG2000"])
            AhkTest.AssertEqual("I;16", j2kI16.mode)
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("wide"), j2kI16.info["comment"])

            AhkTest.RaisesMatch(SyntaxError, "^not a JPEG 2000 file$", (*) => plugin.Jpeg2KImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD"))))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD")), "r", ["JPEG2000"]))
            AhkTest.RaisesMatch(SyntaxError, "^Invalid header length$", (*) => plugin.BoxReader(stdlib.io.BytesIO([0, 0, 0, 4, 98, 97, 100, 33])).next_box_type())
            AhkTest.RaisesMatch(OSError, "^Expected to read 2 bytes but only got 1\.$", (*) => plugin.BoxReader(stdlib.io.BytesIO([0]))._read_bytes(2))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.Jpeg2KImageFile())
        } finally {
            if IsSet(j2kI16)
                StdlibPillowTest.CloseImage(j2kI16)
            if IsSet(j2kRgb)
                StdlibPillowTest.CloseImage(j2kRgb)
            if IsSet(j2kL)
                StdlibPillowTest.CloseImage(j2kL)
            if IsSet(jp2Cmyk)
                StdlibPillowTest.CloseImage(jp2Cmyk)
            if IsSet(jp2Jpx)
                StdlibPillowTest.CloseImage(jp2Jpx)
            if IsSet(jp2)
                StdlibPillowTest.CloseImage(jp2)
            if IsSet(direct)
                StdlibPillowTest.CloseImage(direct)
        }
    }

    static TestMcIdasImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "McIdasImagePlugin"))
        plugin := stdlib.pillow.McIdasImagePlugin

        areaBytes := StdlibPillowTest.McIdasAreaBytes(3, 2, 1)
        area16Bytes := StdlibPillowTest.McIdasAreaBytes(3, 2, 2)
        area32Bytes := StdlibPillowTest.McIdasAreaBytes(3, 2, 4)

        AhkTest.AssertTrue(HasProp(plugin, "McIdasImageFile"))
        AhkTest.AssertEqual("MCIDAS", plugin.McIdasImageFile.format)
        AhkTest.AssertEqual("McIdas area file", plugin.McIdasImageFile.format_description)
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.ArraySlice(areaBytes, 1, 16)))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.ArraySlice(areaBytes, 1, 8)))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("BAD")))

        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("MCIDAS"))
        AhkTest.AssertTrue(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "MCIDAS"))
        if stdlib.pillow.Image.EXTENSION.Has(".mic")
            AhkTest.AssertNotEqual("MCIDAS", stdlib.pillow.Image.EXTENSION[".mic"])
        AhkTest.AssertFalse(stdlib.pillow.Image.MIME.Has("MCIDAS"))

        direct := unset
        direct16 := unset
        direct32 := unset
        opened := unset
        try {
            direct := plugin.McIdasImageFile(stdlib.io.BytesIO(areaBytes))
            AhkTest.AssertEqual("MCIDAS", direct.format)
            AhkTest.AssertEqual("McIdas area file", direct.format_description)
            AhkTest.AssertEqual("L", direct.mode)
            AhkTest.AssertEqual([3, 2], direct.size)
            AhkTest.AssertEqual(256, direct.area_descriptor_raw.Length)
            AhkTest.AssertEqual([0, 0, 4, 0, 0, 0, 0, 0, 0, 2, 3, 1, 0, 0, 1, 0], StdlibPillowTest.ArraySlice(direct.area_descriptor, 1, 16))
            AhkTest.AssertEqual([["raw", [0, 0, 3, 2], 256, ["L", 3, 1]]], direct.tile)
            AhkTest.AssertEqual([0, 1, 2, 3, 4, 5], direct.getdata())

            direct16 := plugin.McIdasImageFile(stdlib.io.BytesIO(area16Bytes))
            AhkTest.AssertEqual("I;16B", direct16.mode)
            AhkTest.AssertEqual([["raw", [0, 0, 3, 2], 256, ["I;16B", 6, 1]]], direct16.tile)

            direct32 := plugin.McIdasImageFile(stdlib.io.BytesIO(area32Bytes))
            AhkTest.AssertEqual("I", direct32.mode)
            AhkTest.AssertEqual([["raw", [0, 0, 3, 2], 256, ["I;32B", 12, 1]]], direct32.tile)

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(areaBytes), "r", ["MCIDAS"])
            AhkTest.AssertEqual("MCIDAS", opened.format)
            AhkTest.AssertEqual("L", opened.mode)
            AhkTest.AssertEqual([3, 2], opened.size)
            AhkTest.AssertEqual([0, 1, 2, 3, 4, 5], opened.getdata())

            AhkTest.RaisesMatch(SyntaxError, "^unsupported McIdas format$", (*) => plugin.McIdasImageFile(stdlib.io.BytesIO(StdlibPillowTest.McIdasAreaBytes(3, 2, 3))))
            AhkTest.RaisesMatch(SyntaxError, "^not an McIdas area file$", (*) => plugin.McIdasImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("bad"))))
            AhkTest.RaisesMatch(SyntaxError, "^not an McIdas area file$", (*) => plugin.McIdasImageFile(stdlib.io.BytesIO([0, 0, 0, 0, 0, 0, 0, 4])))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("bad")), "r", ["MCIDAS"]))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.McIdasImageFile())
        } finally {
            for image in [opened, direct32, direct16, direct] {
                if IsSet(image)
                    StdlibPillowTest.CloseImage(image)
            }
        }
    }

    static TestMicImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "MicImagePlugin"))
        plugin := stdlib.pillow.MicImagePlugin

        tiffL := StdlibPillowTest.TiffBytes("L", [1, 2, 3, 4])
        tiffRgb := StdlibPillowTest.TiffBytes("RGB", [[10, 20, 30], [200, 10, 5], [40, 50, 60], [1, 2, 3]])
        micMagic := [208, 207, 17, 224, 161, 177, 26, 225]

        AhkTest.AssertTrue(HasProp(plugin, "MicImageFile"))
        AhkTest.AssertEqual("MIC", plugin.MicImageFile.format)
        AhkTest.AssertEqual("Microsoft Image Composer", plugin.MicImageFile.format_description)
        AhkTest.AssertFalse(plugin.MicImageFile._close_exclusive_fp_after_loading)
        AhkTest.AssertTrue(plugin._accept(micMagic.Clone()))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.ArraySlice(micMagic, 1, 4)))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("BAD")))
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("MIC"))
        AhkTest.AssertTrue(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "MIC"))
        AhkTest.AssertEqual("MIC", stdlib.pillow.Image.registered_extensions()[".mic"])
        AhkTest.AssertFalse(stdlib.pillow.Image.MIME.Has("MIC"))

        oldOlefile := plugin.olefile
        direct := unset
        opened := unset
        try {
            fakeModule := StdlibPillowMicFakeOleModule([
                [["Layer1.ACI", "Image"], tiffL],
                [["Layer2.ACI", "Image"], tiffRgb],
            ])
            plugin.olefile := fakeModule

            direct := plugin.MicImageFile(stdlib.io.BytesIO(micMagic.Clone()))
            AhkTest.AssertEqual("MIC", direct.format)
            AhkTest.AssertEqual("Microsoft Image Composer", direct.format_description)
            AhkTest.AssertEqual("L", direct.mode)
            AhkTest.AssertEqual([2, 2], direct.size)
            AhkTest.AssertEqual(1, direct.n_frames)
            AhkTest.AssertFalse(direct.is_animated)
            AhkTest.AssertEqual(0, direct.tell())
            AhkTest.AssertEqual(2, direct.getpixel([1, 0]))
            AhkTest.AssertEqual([["Layer1.ACI", "Image"], ["Layer2.ACI", "Image"]], direct.images)
            AhkTest.AssertTrue(direct._close_exclusive_fp_after_loading)
            AhkTest.RaisesMatch(EOFError, "^attempt to seek outside sequence$", (*) => direct.seek(1))
            AhkTest.RaisesMatch(EOFError, "^attempt to seek outside sequence$", (*) => direct.seek(-1))

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(micMagic.Clone()), "r", ["MIC"])
            AhkTest.AssertEqual("MIC", opened.format)
            AhkTest.AssertEqual("L", opened.mode)
            AhkTest.AssertEqual([2, 2], opened.size)
            AhkTest.AssertEqual(2, opened.getpixel([1, 0]))

            StdlibPillowTest.CloseImage(opened)
            opened := unset
            StdlibPillowTest.CloseImage(direct)
            direct := unset
            AhkTest.AssertEqual(2, fakeModule.ClosedCount)

            plugin.olefile := StdlibPillowMicFakeOleModule([
                [["Layer1.ACI", "NotImage"], tiffL],
                [["Plain", "Image"], tiffL],
                [["Layer2.ACI"], tiffL],
            ])
            AhkTest.RaisesMatch(SyntaxError, "^not an MIC file; no image entries$", (*) => plugin.MicImageFile(stdlib.io.BytesIO(micMagic.Clone())))

            plugin.olefile := StdlibPillowMicFakeOleModule([], true)
            AhkTest.RaisesMatch(SyntaxError, "^not an MIC file; invalid OLE file$", (*) => plugin.MicImageFile(stdlib.io.BytesIO(micMagic.Clone())))

            AhkTest.RaisesMatch(TypeError, "^TiffImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.MicImageFile())
            AhkTest.RaisesMatch(TypeError, "^TiffImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.MicImageFile(stdlib.io.BytesIO(micMagic.Clone()), "x", "y"))

            plugin.olefile := oldOlefile
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("bad")), "r", ["MIC"]))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(micMagic.Clone()), "r", ["MIC"]))
        } finally {
            plugin.olefile := oldOlefile
            if IsSet(opened)
                StdlibPillowTest.CloseImage(opened)
            if IsSet(direct)
                StdlibPillowTest.CloseImage(direct)
        }
    }

    static TestMpegImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "MpegImagePlugin"))
        plugin := stdlib.pillow.MpegImagePlugin

        stream := plugin.BitStream(stdlib.io.BytesIO([172, 112, 255]))
        AhkTest.AssertEqual(5, stream.peek(3))
        AhkTest.AssertEqual(8, stream.bits)
        AhkTest.AssertEqual(5, stream.read(3))
        AhkTest.AssertEqual(5, stream.bits)
        AhkTest.AssertEqual(12, stream.peek(5))
        AhkTest.AssertEqual(12, stream.read(5))
        AhkTest.AssertEqual(112, stream.next())
        AhkTest.AssertEqual(15, stream.read(4))
        AhkTest.AssertEqual(15, stream.read(4))
        AhkTest.RaisesMatch(IndexError, "^index out of range$", (*) => plugin.BitStream(stdlib.io.BytesIO([])).next())
        AhkTest.RaisesMatch(IndexError, "^index out of range$", (*) => plugin.BitStream(stdlib.io.BytesIO([])).read(1))

        mpegBytes := StdlibPillowTest.MpegBytes(320, 240, [1, 2, 3])
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.ArraySlice(mpegBytes, 1, 16)))
        AhkTest.AssertTrue(plugin._accept([0, 0, 1, 0xB3]))
        AhkTest.AssertFalse(plugin._accept([0, 0, 1]))
        AhkTest.AssertFalse(plugin._accept([0, 0, 1, 0xBA]))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("BAD!")))
        AhkTest.AssertEqual("MPEG", plugin.MpegImageFile.format)
        AhkTest.AssertEqual("MPEG", plugin.MpegImageFile.format_description)
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("MPEG"))
        AhkTest.AssertTrue(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "MPEG"))
        AhkTest.AssertEqual("MPEG", stdlib.pillow.Image.registered_extensions()[".mpg"])
        AhkTest.AssertEqual("MPEG", stdlib.pillow.Image.registered_extensions()[".mpeg"])
        AhkTest.AssertEqual("video/mpeg", stdlib.pillow.Image.MIME["MPEG"])

        direct := unset
        tiny := unset
        maxed := unset
        opened := unset
        try {
            direct := plugin.MpegImageFile(stdlib.io.BytesIO(mpegBytes))
            AhkTest.AssertEqual("MPEG", direct.format)
            AhkTest.AssertEqual("MPEG", direct.format_description)
            AhkTest.AssertEqual("RGB", direct.mode)
            AhkTest.AssertEqual([320, 240], direct.size)
            AhkTest.AssertEqual([], direct.tile)
            AhkTest.RaisesMatch(OSError, "^cannot load this image$", (*) => direct.load())

            tiny := plugin.MpegImageFile(stdlib.io.BytesIO(StdlibPillowTest.MpegBytes(1, 1)))
            AhkTest.AssertEqual([1, 1], tiny.size)

            maxed := plugin.MpegImageFile(stdlib.io.BytesIO(StdlibPillowTest.MpegBytes(4095, 4095)))
            AhkTest.AssertEqual([4095, 4095], maxed.size)

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(mpegBytes), "r", ["MPEG"])
            AhkTest.AssertEqual("MPEG", opened.format)
            AhkTest.AssertEqual("RGB", opened.mode)
            AhkTest.AssertEqual([320, 240], opened.size)
            AhkTest.RaisesMatch(OSError, "^cannot load this image$", (*) => opened.load())

            AhkTest.RaisesMatch(SyntaxError, "^not an MPEG file$", (*) => plugin.MpegImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD!"))))
            AhkTest.RaisesMatch(SyntaxError, "^not an MPEG file$", (*) => plugin.MpegImageFile(stdlib.io.BytesIO([0, 0, 1, 0xBA, 0, 0, 0])))
            AhkTest.RaisesMatch(SyntaxError, "^index out of range$", (*) => plugin.MpegImageFile(stdlib.io.BytesIO([0, 0, 1, 0xB3])))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD!")), "r", ["MPEG"]))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.MpegImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.MpegImageFile(stdlib.io.BytesIO(mpegBytes), "x", "y"))
        } finally {
            for image in [opened, maxed, tiny, direct] {
                if IsSet(image)
                    StdlibPillowTest.CloseImage(image)
            }
        }
    }

    static TestMpoImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "MpoImagePlugin"))
        plugin := stdlib.pillow.MpoImagePlugin

        mpoFixture := StdlibPillowTest.MpoBytes()
        mpoBytes := mpoFixture["bytes"]
        jpegBytes := StdlibPillowTest.JpegHeaderBytes()

        AhkTest.AssertTrue(HasProp(plugin, "MpoImageFile"))
        AhkTest.AssertTrue(HasProp(plugin, "_save"))
        AhkTest.AssertTrue(HasProp(plugin, "_save_all"))
        AhkTest.AssertEqual("MPO", plugin.MpoImageFile.format)
        AhkTest.AssertEqual("MPO (CIPA DC-007)", plugin.MpoImageFile.format_description)
        AhkTest.AssertFalse(plugin.MpoImageFile._close_exclusive_fp_after_loading)
        AhkTest.AssertFalse(stdlib.pillow.Image.OPEN.Has("MPO"))
        AhkTest.AssertFalse(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "MPO"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("MPO"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE_ALL.Has("MPO"))
        AhkTest.AssertEqual("MPO", stdlib.pillow.Image.registered_extensions()[".mpo"])
        AhkTest.AssertEqual("image/mpo", stdlib.pillow.Image.MIME["MPO"])

        direct := unset
        opened := unset
        adopted := unset
        jpeg := unset
        source := unset
        append := unset
        singleOpened := unset
        savedOpened := unset
        try {
            source := stdlib.pillow.Image.new("RGB", [3, 2], [10, 20, 30])
            append := stdlib.pillow.Image.new("RGB", [3, 2], [1, 2, 3])
            singleFp := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, source.save(singleFp, "MPO"))
            singleBytes := singleFp.getvalue()
            AhkTest.AssertEqual([0xFF, 0xD8, 0xFF], StdlibPillowTest.ArraySlice(singleBytes, 1, 3))
            AhkTest.AssertFalse(StdlibPillowTest.BytesContainsAscii(singleBytes, "MPF"))
            singleOpened := stdlib.pillow.Image.open(stdlib.io.BytesIO(singleBytes), "r", ["JPEG"])
            AhkTest.AssertEqual("JPEG", singleOpened.format)

            multiFp := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, source.save(multiFp, "MPO", { save_all: true, append_images: [append] }))
            multiSavedBytes := multiFp.getvalue()
            AhkTest.AssertEqual([0xFF, 0xD8, 0xFF], StdlibPillowTest.ArraySlice(multiSavedBytes, 1, 3))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(multiSavedBytes, "MPF"))
            savedOpened := stdlib.pillow.Image.open(stdlib.io.BytesIO(multiSavedBytes), "r", ["JPEG"])
            AhkTest.AssertEqual("MPO", savedOpened.format)
            AhkTest.AssertEqual(2, savedOpened.n_frames)
            AhkTest.AssertSame(stdlib.None, savedOpened.seek(1))
            AhkTest.AssertEqual(1, savedOpened.tell())

            direct := plugin.MpoImageFile(stdlib.io.BytesIO(mpoBytes))
            AhkTest.AssertEqual("MPO", direct.format)
            AhkTest.AssertEqual("MPO (CIPA DC-007)", direct.format_description)
            AhkTest.AssertEqual("RGB", direct.mode)
            AhkTest.AssertEqual([3, 2], direct.size)
            AhkTest.AssertEqual(2, direct.n_frames)
            AhkTest.AssertTrue(direct.is_animated)
            AhkTest.AssertEqual(1, direct.readonly)
            AhkTest.AssertEqual(0, direct.tell())
            AhkTest.AssertFalse(direct.info.Has("mpoffset"))
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("0100"), direct.mpinfo[0xB000])
            AhkTest.AssertEqual(2, direct.mpinfo[0xB001])
            AhkTest.AssertEqual("Baseline MP Primary Image", direct.mpinfo[0xB002][1]["Attribute"]["MPType"])
            AhkTest.AssertEqual("Undefined", direct.mpinfo[0xB002][2]["Attribute"]["MPType"])
            AhkTest.AssertEqual(mpoFixture["first_size"], direct.mpinfo[0xB002][1]["Size"])
            AhkTest.AssertEqual(mpoFixture["second_size"], direct.mpinfo[0xB002][2]["Size"])
            AhkTest.AssertEqual(mpoFixture["second_data_offset"], direct.mpinfo[0xB002][2]["DataOffset"])
            AhkTest.AssertEqual(["jpeg", [0, 0, 3, 2], 0, ["RGB", ""]], direct.tile[1])
            AhkTest.AssertSame(stdlib.None, direct.seek(0))
            AhkTest.AssertEqual(0, direct.tell())
            AhkTest.AssertSame(stdlib.None, direct.seek(1))
            AhkTest.AssertEqual(1, direct.tell())
            AhkTest.AssertEqual(["jpeg", [0, 0, 3, 2], mpoFixture["first_size"], ["RGB", ""]], direct.tile[1])
            AhkTest.AssertSame(stdlib.None, direct.load_seek(0))
            AhkTest.RaisesMatch(EOFError, "^attempt to seek outside sequence$", (*) => direct.seek(2))
            AhkTest.RaisesMatch(EOFError, "^attempt to seek outside sequence$", (*) => direct.seek(-1))

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(mpoBytes), "r", ["JPEG"])
            AhkTest.AssertEqual("MPO", opened.format)
            AhkTest.AssertEqual(2, opened.n_frames)
            AhkTest.AssertTrue(opened.is_animated)
            AhkTest.AssertSame(stdlib.None, opened.seek(1))
            AhkTest.AssertEqual(1, opened.tell())

            AhkTest.RaisesMatch(KeyError, "^'MPO'$", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(mpoBytes), "r", ["MPO"]))

            jpeg := stdlib.pillow.JpegImagePlugin.JpegImageFile(stdlib.io.BytesIO(jpegBytes))
            jpeg.info["mpoffset"] := 0
            adopted := plugin.MpoImageFile.adopt(jpeg, Map(0xB001, 1, 0xB002, [Map("DataOffset", 0)]))
            AhkTest.AssertSame(jpeg, adopted)
            AhkTest.AssertEqual("MPO", adopted.format)
            AhkTest.AssertEqual(1, adopted.n_frames)
            AhkTest.AssertFalse(adopted.is_animated)
            AhkTest.AssertEqual(1, adopted.readonly)
            AhkTest.AssertFalse(adopted.info.Has("mpoffset"))
            AhkTest.AssertEqual(0, adopted.tell())

            AhkTest.RaisesMatch(ValueError, "^Image appears to be a malformed MPO file$", (*) => plugin.MpoImageFile(stdlib.io.BytesIO(jpegBytes)))
            AhkTest.RaisesMatch(ValueError, "^Image appears to be a malformed MPO file$", (*) => plugin.MpoImageFile.adopt(stdlib.pillow.JpegImagePlugin.JpegImageFile(stdlib.io.BytesIO(jpegBytes))))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.MpoImageFile())
            AhkTest.RaisesMatch(TypeError, "^MpoImageFile\.adopt\(\) missing 1 required positional argument: 'jpeg_instance'$", (*) => plugin.MpoImageFile.adopt())
            AhkTest.RaisesMatch(TypeError, "^MpoImageFile\.adopt\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => plugin.MpoImageFile.adopt(stdlib.None, stdlib.None, stdlib.None))
            AhkTest.RaisesMatch(TypeError, "^_save\(\) missing 3 required positional arguments: 'im', 'fp', and 'filename'$", (*) => plugin._save())
            AhkTest.RaisesMatch(TypeError, "^_save_all\(\) missing 3 required positional arguments: 'im', 'fp', and 'filename'$", (*) => plugin._save_all())
        } finally {
            if IsSet(savedOpened)
                StdlibPillowTest.CloseImage(savedOpened)
            if IsSet(singleOpened)
                StdlibPillowTest.CloseImage(singleOpened)
            if IsSet(append)
                StdlibPillowTest.CloseImage(append)
            if IsSet(source)
                StdlibPillowTest.CloseImage(source)
            if IsSet(adopted)
                StdlibPillowTest.CloseImage(adopted)
            if IsSet(opened)
                StdlibPillowTest.CloseImage(opened)
            if IsSet(direct)
                StdlibPillowTest.CloseImage(direct)
        }
    }

    static TestMpoImagePluginSaveAllAnimatedSequenceMatchesLocalPillow113()
    {
        plugin := stdlib.pillow.MpoImagePlugin
        AhkTest.AssertEqual("MPO", plugin.MpoImageFile.format)

        source := unset
        append := unset
        opened := unset
        reopened := unset
        try {
            source := stdlib.pillow.Image.new("RGB", [3, 2], [10, 20, 30])
            source.putpixel([1, 0], [200, 10, 5])
            append := stdlib.pillow.Image.new("RGB", [3, 2], [1, 2, 3])
            append.putpixel([2, 1], [250, 240, 230])

            originalFp := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, source.save(originalFp, "MPO", { save_all: true, append_images: [append] }))
            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(originalFp.getvalue()), "r", ["JPEG"])
            AhkTest.AssertEqual("MPO", opened.format)
            AhkTest.AssertEqual(2, opened.n_frames)
            AhkTest.AssertTrue(opened.is_animated)
            AhkTest.AssertEqual(0, opened.tell())

            resavedFp := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, opened.save(resavedFp, "MPO", { save_all: true }))
            resavedBytes := resavedFp.getvalue()
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(resavedBytes, "MPF"))
            AhkTest.AssertEqual(1, opened.tell())

            reopened := stdlib.pillow.Image.open(stdlib.io.BytesIO(resavedBytes), "r", ["JPEG"])
            AhkTest.AssertEqual("MPO", reopened.format)
            AhkTest.AssertEqual(2, reopened.n_frames)
            AhkTest.AssertTrue(reopened.is_animated)
            AhkTest.AssertEqual(0, reopened.tell())
            AhkTest.AssertSame(stdlib.None, reopened.seek(1))
            AhkTest.AssertEqual(1, reopened.tell())
            AhkTest.RaisesMatch(EOFError, "^attempt to seek outside sequence$", (*) => reopened.seek(2))
        } finally {
            if IsSet(reopened)
                StdlibPillowTest.CloseImage(reopened)
            if IsSet(opened)
                StdlibPillowTest.CloseImage(opened)
            if IsSet(append)
                StdlibPillowTest.CloseImage(append)
            if IsSet(source)
                StdlibPillowTest.CloseImage(source)
        }
    }

    static TestMpoImagePluginSeekTypeRulesMatchLocalPillow113()
    {
        plugin := stdlib.pillow.MpoImagePlugin
        AhkTest.AssertEqual("MPO", plugin.MpoImageFile.format)

        opened := unset
        try {
            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.MpoBytes()["bytes"]), "r", ["JPEG"])
            AhkTest.AssertEqual("MPO", opened.format)
            AhkTest.AssertEqual(0, opened.tell())
            AhkTest.RaisesMatch(TypeError, "^'<' not supported between instances of 'str' and 'int'$", (*) => opened.seek("1"))
            AhkTest.AssertEqual(0, opened.tell())
            AhkTest.RaisesMatch(TypeError, "^list indices must be integers or slices, not float$", (*) => opened.seek(1.2))
            AhkTest.AssertEqual(0, opened.tell())
            AhkTest.RaisesMatch(TypeError, "^'<' not supported between instances of 'NoneType' and 'int'$", (*) => opened.seek(stdlib.None))
            AhkTest.AssertEqual(0, opened.tell())
            AhkTest.RaisesMatch(TypeError, "^'<' not supported between instances of 'list' and 'int'$", (*) => opened.seek([]))
            AhkTest.AssertEqual(0, opened.tell())
            AhkTest.AssertSame(stdlib.None, opened.seek(true))
            AhkTest.AssertEqual(1, opened.tell())
            AhkTest.AssertSame(stdlib.None, opened.seek(false))
            AhkTest.AssertEqual(0, opened.tell())
        } finally {
            if IsSet(opened)
                StdlibPillowTest.CloseImage(opened)
        }
    }

    static TestMpoImagePluginGetmpMatchesLocalPillow113()
    {
        plugin := stdlib.pillow.MpoImagePlugin
        AhkTest.AssertEqual("MPO", plugin.MpoImageFile.format)

        mpoFixture := StdlibPillowTest.MpoBytes()
        opened := unset
        jpeg := unset
        try {
            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(mpoFixture["bytes"]), "r", ["JPEG"])
            AhkTest.AssertEqual("MPO", opened.format)
            AhkTest.AssertTrue(opened.info.Has("mp"))
            AhkTest.AssertTrue(HasMethod(opened, "_getmp"))
            mp := opened._getmp()
            AhkTest.AssertTrue(mp is Map)
            AhkTest.AssertTrue(ObjPtr(mp) != ObjPtr(opened.mpinfo))
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("0100"), mp[0xB000])
            AhkTest.AssertEqual(2, mp[0xB001])
            AhkTest.AssertEqual(2, mp[0xB002].Length)
            AhkTest.AssertEqual("Baseline MP Primary Image", mp[0xB002][1]["Attribute"]["MPType"])
            AhkTest.AssertEqual("Undefined", mp[0xB002][2]["Attribute"]["MPType"])
            AhkTest.AssertEqual(mpoFixture["first_size"], mp[0xB002][1]["Size"])
            AhkTest.AssertEqual(mpoFixture["second_size"], mp[0xB002][2]["Size"])
            AhkTest.AssertEqual(mpoFixture["second_data_offset"], mp[0xB002][2]["DataOffset"])
            AhkTest.RaisesMatch(TypeError, "^JpegImageFile\._getmp\(\) takes 1 positional argument but 2 were given$", (*) => opened._getmp("x"))

            jpeg := stdlib.pillow.JpegImagePlugin.JpegImageFile(stdlib.io.BytesIO(StdlibPillowTest.JpegHeaderBytes()))
            AhkTest.AssertEqual("JPEG", jpeg.format)
            AhkTest.AssertFalse(jpeg.info.Has("mp"))
            AhkTest.AssertSame(stdlib.None, jpeg._getmp())
            jpeg.info["mp"] := [73, 73, 42, 0, 8, 0, 0, 0, 0, 0]
            AhkTest.RaisesMatch(SyntaxError, "^malformed MP Index \(no number of images\)$", (*) => jpeg._getmp())
        } finally {
            if IsSet(jpeg)
                StdlibPillowTest.CloseImage(jpeg)
            if IsSet(opened)
                StdlibPillowTest.CloseImage(opened)
        }
    }

    static TestMpoImagePluginAttributeRulesMatchLocalPillow113()
    {
        plugin := stdlib.pillow.MpoImagePlugin
        AhkTest.AssertEqual("MPO", plugin.MpoImageFile.format)

        richFixture := StdlibPillowTest.MpoBytes([0xF8020003, 0x010002, 0x00ABCD])
        opened := unset
        fallback := unset
        try {
            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(richFixture["bytes"]), "r", ["JPEG"])
            AhkTest.AssertEqual("MPO", opened.format)
            AhkTest.AssertEqual(3, opened.n_frames)
            AhkTest.AssertEqual(3, opened.mpinfo[0xB002].Length)

            firstAttr := opened.mpinfo[0xB002][1]["Attribute"]
            AhkTest.AssertTrue(firstAttr["DependentParentImageFlag"])
            AhkTest.AssertTrue(firstAttr["DependentChildImageFlag"])
            AhkTest.AssertTrue(firstAttr["RepresentativeImageFlag"])
            AhkTest.AssertEqual(3, firstAttr["Reserved"])
            AhkTest.AssertEqual("JPEG", firstAttr["ImageDataFormat"])
            AhkTest.AssertEqual("Multi-Frame Image: (Multi-Angle)", firstAttr["MPType"])

            secondAttr := opened.mpinfo[0xB002][2]["Attribute"]
            AhkTest.AssertEqual("Large Thumbnail (Full HD Equivalent)", secondAttr["MPType"])
            AhkTest.AssertEqual("JPEG", secondAttr["ImageDataFormat"])

            thirdAttr := opened.mpinfo[0xB002][3]["Attribute"]
            AhkTest.AssertEqual("Unknown", thirdAttr["MPType"])
            AhkTest.AssertEqual("JPEG", thirdAttr["ImageDataFormat"])
            AhkTest.AssertEqual(richFixture["data_offsets"][3], opened.mpinfo[0xB002][3]["DataOffset"])

            unsupportedFixture := StdlibPillowTest.MpoBytes([0x01030000, 0])
            records := stdlib.warnings.catch_warnings(true).Call((records) => fallback := stdlib.pillow.Image.open(stdlib.io.BytesIO(unsupportedFixture["bytes"]), "r", ["JPEG"]))
            AhkTest.AssertEqual(1, records.Length)
            AhkTest.AssertSame(stdlib.warnings.UserWarning, records[1].category)
            AhkTest.AssertEqual("Image appears to be a malformed MPO file, it will be interpreted as a base JPEG file", records[1].message)
            AhkTest.AssertEqual("JPEG", fallback.format)
            AhkTest.AssertTrue(fallback.info.Has("mp"))
            AhkTest.AssertFalse(HasProp(fallback, "n_frames"))
        } finally {
            if IsSet(fallback)
                StdlibPillowTest.CloseImage(fallback)
            if IsSet(opened)
                StdlibPillowTest.CloseImage(opened)
        }
    }

    static TestMpoImagePluginUltraHdrJpegFactorySkipMatchesLocalPillow113()
    {
        plugin := stdlib.pillow.MpoImagePlugin
        AhkTest.AssertEqual("MPO", plugin.MpoImageFile.format)

        baseFixture := StdlibPillowTest.MpoBytes()
        ultraBytes := StdlibPillowTest.MpoBytesWithApp1(StdlibPillowTest.AsciiBytes('urn:iso:std:iso:ts:21496:-1 hdrgm:Version="1.0" demo'))
        nonHdrgmBytes := StdlibPillowTest.MpoBytesWithApp1(StdlibPillowTest.AsciiBytes("urn:iso:std:iso:ts:21496:-1 no-hdrgm demo"))
        baseOpened := unset
        ultraOpened := unset
        nonHdrgmOpened := unset
        directUltra := unset
        try {
            baseOpened := stdlib.pillow.Image.open(stdlib.io.BytesIO(baseFixture["bytes"]), "r", ["JPEG"])
            AhkTest.AssertEqual("MPO", baseOpened.format)
            AhkTest.AssertEqual(2, baseOpened.n_frames)

            nonHdrgmOpened := stdlib.pillow.Image.open(stdlib.io.BytesIO(nonHdrgmBytes), "r", ["JPEG"])
            AhkTest.AssertEqual("MPO", nonHdrgmOpened.format)
            AhkTest.AssertEqual(2, nonHdrgmOpened.n_frames)
            AhkTest.AssertEqual(["APP0", "APP1", "APP2"], StdlibPillowTest.JpegAppSegments(nonHdrgmOpened))

            ultraOpened := stdlib.pillow.Image.open(stdlib.io.BytesIO(ultraBytes), "r", ["JPEG"])
            AhkTest.AssertEqual("JPEG", ultraOpened.format)
            AhkTest.AssertFalse(HasProp(ultraOpened, "n_frames"))
            AhkTest.AssertTrue(ultraOpened.info.Has("mp"))
            AhkTest.AssertEqual(["APP0", "APP1", "APP2"], StdlibPillowTest.JpegAppSegments(ultraOpened))

            directUltra := plugin.MpoImageFile(stdlib.io.BytesIO(ultraBytes))
            AhkTest.AssertEqual("MPO", directUltra.format)
            AhkTest.AssertEqual(2, directUltra.n_frames)
        } finally {
            if IsSet(directUltra)
                StdlibPillowTest.CloseImage(directUltra)
            if IsSet(nonHdrgmOpened)
                StdlibPillowTest.CloseImage(nonHdrgmOpened)
            if IsSet(ultraOpened)
                StdlibPillowTest.CloseImage(ultraOpened)
            if IsSet(baseOpened)
                StdlibPillowTest.CloseImage(baseOpened)
        }
    }

    static TestMpoImagePluginLoadSeekMatchesLocalPillow113()
    {
        plugin := stdlib.pillow.MpoImagePlugin
        AhkTest.AssertEqual("MPO", plugin.MpoImageFile.format)

        mpoFixture := StdlibPillowTest.MpoBytes()
        direct := unset
        opened := unset
        try {
            direct := plugin.MpoImageFile(stdlib.io.BytesIO(mpoFixture["bytes"]))
            AhkTest.AssertEqual("MPO", direct.format)
            AhkTest.AssertEqual(0, direct.fp.tell())
            AhkTest.AssertSame(stdlib.None, direct.load_seek(5))
            AhkTest.AssertEqual(5, direct.fp.tell())
            AhkTest.AssertSame(stdlib.None, direct.seek(1))
            AhkTest.AssertEqual(mpoFixture["first_size"], direct.fp.tell())
            AhkTest.AssertSame(stdlib.None, direct.load_seek(7))
            AhkTest.AssertEqual(7, direct.fp.tell())
            AhkTest.RaisesMatch(ValueError, "^negative seek value -1$", (*) => direct.load_seek(-1))
            AhkTest.RaisesMatch(TypeError, "^MpoImageFile\.load_seek\(\) missing 1 required positional argument: 'pos'$", (*) => direct.load_seek())

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(mpoFixture["bytes"]), "r", ["JPEG"])
            AhkTest.AssertEqual("MPO", opened.format)
            AhkTest.AssertEqual(0, opened.fp.tell())
            AhkTest.AssertSame(stdlib.None, opened.load_seek(9))
            AhkTest.AssertEqual(9, opened.fp.tell())
        } finally {
            if IsSet(opened)
                StdlibPillowTest.CloseImage(opened)
            if IsSet(direct)
                StdlibPillowTest.CloseImage(direct)
        }
    }

    static TestMspImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "MspImagePlugin"))
        plugin := stdlib.pillow.MspImagePlugin

        danmBytes := StdlibPillowTest.MspDanMBytes()
        linsBytes := StdlibPillowTest.MspLinSBytes()
        zeroRowBytes := StdlibPillowTest.MspLinSZeroRowBytes()
        expectedData := [0, 255, 255, 0, 255, 255, 255, 255, 0, 255, 0, 255, 255, 255, 255, 255, 0, 255]
        expectedPacked := [111, 0, 190, 128]

        AhkTest.AssertTrue(HasProp(plugin, "MspImageFile"))
        AhkTest.AssertTrue(HasProp(plugin, "MspDecoder"))
        AhkTest.AssertTrue(HasProp(plugin, "_accept"))
        AhkTest.AssertTrue(HasProp(plugin, "_save"))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("DanMxxxx")))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("LinSxxxx")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("Dan")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("BAD!")))
        AhkTest.AssertEqual("MSP", plugin.MspImageFile.format)
        AhkTest.AssertEqual("Windows Paint", plugin.MspImageFile.format_description)

        decoder := plugin.MspDecoder("1")
        AhkTest.AssertTrue(decoder._pulls_fd)
        AhkTest.AssertEqual("1", decoder.mode)
        AhkTest.RaisesMatch(TypeError, "^PyCodec\.__init__\(\) missing 1 required positional argument: 'mode'$", (*) => plugin.MspDecoder())

        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("MSP"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("MSP"))
        AhkTest.AssertTrue(stdlib.pillow.Image.DECODERS.Has("MSP"))
        AhkTest.AssertTrue(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "MSP"))
        AhkTest.AssertEqual("MSP", stdlib.pillow.Image.registered_extensions()[".msp"])
        AhkTest.AssertFalse(stdlib.pillow.Image.MIME.Has("MSP"))

        direct := unset
        opened := unset
        lins := unset
        zeroRow := unset
        source := unset
        savedOpened := unset
        try {
            AhkTest.AssertEqual(36, danmBytes.Length)
            AhkTest.AssertEqual(0, StdlibPillowTest.MspChecksum(StdlibPillowTest.ArraySlice(danmBytes, 1, 32)))
            AhkTest.AssertEqual(expectedPacked, StdlibPillowTest.ArraySlice(danmBytes, 33, 36))

            direct := plugin.MspImageFile(stdlib.io.BytesIO(danmBytes))
            AhkTest.AssertEqual("MSP", direct.format)
            AhkTest.AssertEqual("Windows Paint", direct.format_description)
            AhkTest.AssertEqual("1", direct.mode)
            AhkTest.AssertEqual([9, 2], direct.size)
            AhkTest.AssertEqual(["raw", [0, 0, 9, 2], 32, "1"], direct.tile[1])
            AhkTest.AssertEqual(expectedData, direct.getdata())
            AhkTest.AssertEqual(expectedPacked, direct.tobytes())

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(danmBytes), "r", ["MSP"])
            AhkTest.AssertEqual("MSP", opened.format)
            AhkTest.AssertEqual(expectedData, opened.getdata())

            lins := plugin.MspImageFile(stdlib.io.BytesIO(linsBytes))
            AhkTest.AssertEqual("MSP", lins.format)
            AhkTest.AssertEqual("1", lins.mode)
            AhkTest.AssertEqual(["MSP", [0, 0, 9, 2], 32, stdlib.None], lins.tile[1])
            AhkTest.AssertEqual(expectedData, lins.getdata())
            AhkTest.AssertEqual(expectedPacked, lins.tobytes())

            zeroRow := plugin.MspImageFile(stdlib.io.BytesIO(zeroRowBytes))
            AhkTest.AssertEqual([255, 128, 190, 128], zeroRow.tobytes())

            source := stdlib.pillow.Image.new("1", [9, 2], 1)
            for xy in [[0, 0], [3, 0], [8, 0], [1, 1], [7, 1]]
                source.putpixel(xy, 0)
            out := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, source.save(out, "MSP"))
            savedBytes := out.getvalue()
            AhkTest.AssertEqual(36, savedBytes.Length)
            AhkTest.AssertEqual(StdlibPillowTest.ArraySlice(danmBytes, 1, 32), StdlibPillowTest.ArraySlice(savedBytes, 1, 32))
            AhkTest.AssertEqual(expectedPacked, StdlibPillowTest.ArraySlice(savedBytes, 33, 36))
            savedOpened := stdlib.pillow.Image.open(stdlib.io.BytesIO(savedBytes), "r", ["MSP"])
            AhkTest.AssertEqual(expectedData, savedOpened.getdata())

            badChecksum := danmBytes.Clone()
            badChecksum[5] := 5
            AhkTest.RaisesMatch(SyntaxError, "^not an MSP file$", (*) => plugin.MspImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD!"))))
            AhkTest.RaisesMatch(SyntaxError, "^bad MSP checksum$", (*) => plugin.MspImageFile(stdlib.io.BytesIO(badChecksum)))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD!")), "r", ["MSP"]))
            AhkTest.RaisesMatch(OSError, "^cannot write mode L as MSP$", (*) => stdlib.pillow.Image.new("L", [1, 1]).save(stdlib.io.BytesIO(), "MSP"))
            AhkTest.RaisesMatch(OSError, "^Truncated MSP file in row map$", (*) => plugin.MspImageFile(stdlib.io.BytesIO(StdlibPillowTest.MspLinSTruncatedRowMapBytes())))
            AhkTest.RaisesMatch(OSError, "^Truncated MSP file, expected 3 bytes on row 0$", (*) => plugin.MspImageFile(stdlib.io.BytesIO(StdlibPillowTest.MspLinSTruncatedRowBytes())))
            AhkTest.RaisesMatch(OSError, "^Corrupted MSP file in row 0$", (*) => plugin.MspImageFile(stdlib.io.BytesIO(StdlibPillowTest.MspLinSCorruptedRowBytes())))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.MspImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.MspImageFile(stdlib.io.BytesIO(danmBytes), "x", "y"))
            AhkTest.RaisesMatch(TypeError, "^_save\(\) missing 3 required positional arguments: 'im', 'fp', and 'filename'$", (*) => plugin._save())
        } finally {
            if IsSet(savedOpened)
                StdlibPillowTest.CloseImage(savedOpened)
            if IsSet(source)
                StdlibPillowTest.CloseImage(source)
            if IsSet(zeroRow)
                StdlibPillowTest.CloseImage(zeroRow)
            if IsSet(lins)
                StdlibPillowTest.CloseImage(lins)
            if IsSet(opened)
                StdlibPillowTest.CloseImage(opened)
            if IsSet(direct)
                StdlibPillowTest.CloseImage(direct)
        }
    }

    static TestPSDrawMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "PSDraw"))
        module := stdlib.pillow.PSDraw

        AhkTest.AssertTrue(HasProp(module, "EDROFF_PS"))
        AhkTest.AssertTrue(HasProp(module, "VDI_PS"))
        AhkTest.AssertTrue(HasProp(module, "ERROR_PS"))
        AhkTest.AssertTrue(HasProp(module, "PSDraw"))
        AhkTest.AssertEqual(471, module.EDROFF_PS.Length)
        AhkTest.AssertEqual(479, module.VDI_PS.Length)
        AhkTest.AssertEqual(995, module.ERROR_PS.Length)
        AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("/S { show } bind def"), StdlibPillowTest.ArraySlice(module.EDROFF_PS, 1, 20))
        AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("/Vm { moveto } bind "), StdlibPillowTest.ArraySlice(module.VDI_PS, 1, 20))
        AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("/landscape false def"), StdlibPillowTest.ArraySlice(module.ERROR_PS, 1, 20))

        fp := stdlib.io.BytesIO()
        draw := module.PSDraw(fp)
        AhkTest.AssertEqual("PSDraw", draw.AhkStdlibTypeName)
        AhkTest.AssertSame(fp, draw.fp)

        AhkTest.AssertSame(stdlib.None, draw.begin_document("ignored-id"))
        beginBytes := fp.getvalue()
        AhkTest.AssertEqual(1030, beginBytes.Length)
        AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("%!PS-Adobe-3.0`nsave`n/showpage { } def`n%%EndComments`n%%BeginDocum"), StdlibPillowTest.ArraySlice(beginBytes, 1, 64))
        AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(beginBytes, "%%EndProlog`n"))
        AhkTest.AssertTrue(draw.HasOwnProp("isofont"))
        AhkTest.AssertEqual(0, draw.isofont.Count)

        AhkTest.AssertSame(stdlib.None, draw.setfont("Helvetica", 12))
        AhkTest.AssertSame(stdlib.None, draw.setfont("Helvetica", 14))
        fontBytes := fp.getvalue()
        AhkTest.AssertEqual(1, StdlibPillowTest.CountAscii(fontBytes, "ISOLatin1Encoding /Helvetica E"))
        AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(fontBytes, "/F0 12 /PSDraw-Helvetica F`n"))
        AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(fontBytes, "/F0 14 /PSDraw-Helvetica F`n"))
        AhkTest.AssertTrue(draw.isofont.Has("Helvetica"))

        AhkTest.AssertSame(stdlib.None, draw.line([1, 2], [3, 4]))
        AhkTest.AssertSame(stdlib.None, draw.rectangle([5, 6, 7, 8]))
        AhkTest.AssertSame(stdlib.None, draw.text([9, 10], "a(b)c"))
        drawnBytes := fp.getvalue()
        AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(drawnBytes, "1 2 3 4 Vl`n"))
        AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(drawnBytes, "5 6 M 0 7 8 Vr`n"))
        AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(drawnBytes, "9 10 M (a\(b\)c) S`n"))

        image := stdlib.pillow.Image.new("RGB", [2, 1], [1, 2, 3])
        try {
            AhkTest.AssertSame(stdlib.None, draw.image([0, 0, 144, 72], image))
            imageBytes := fp.getvalue()
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(imageBytes, "gsave`n"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(imageBytes, "false 3 colorimage`n010203010203`n"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(imageBytes, "%%%%EndBinary`ngrestore end`n`ngrestore`n"))
        } finally {
            StdlibPillowTest.CloseImage(image)
        }

        AhkTest.AssertSame(stdlib.None, draw.end_document())
        finalBytes := fp.getvalue()
        AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("%%EndDocument`nrestore showpage`n%%End`n"), StdlibPillowTest.ArraySlice(finalBytes, finalBytes.Length - 36, finalBytes.Length))

        freshDraw := module.PSDraw(stdlib.io.BytesIO())
        AhkTest.RaisesMatch(AttributeError, "^'PSDraw' object has no attribute 'isofont'$", (*) => freshDraw.setfont("Helvetica", 12))
        AhkTest.RaisesMatch(TypeError, "^PSDraw\.line\(\) missing 1 required positional argument: 'xy1'$", (*) => freshDraw.line([1, 2]))
        AhkTest.RaisesMatch(TypeError, "^not enough arguments for format string$", (*) => freshDraw.rectangle([1, 2, 3]))
        AhkTest.RaisesMatch(TypeError, "^encoding without a string argument$", (*) => freshDraw.text([1, 2], [97, 98, 99]))
        AhkTest.RaisesMatch(AttributeError, "^'object' object has no attribute 'mode'$", (*) => freshDraw.image([0, 0, 10, 10], {}))
    }

    static TestPaletteFileMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "PaletteFile"))
        module := stdlib.pillow.PaletteFile

        simpleBytes := StdlibPillowTest.AsciiBytes(
            "# comment`n"
            "0 10 20 30`n"
            "1 7`n"
            "2 1 2 3`n"
            "256 9 9 9`n"
            "-1 8 8 8`n"
            "255 4 5 6`n"
        )
        whitespaceBytes := StdlibPillowTest.AsciiBytes(" 3`t11`t12`t13  `r`n# ignored`r`n4 99`r`n")

        palette := module.PaletteFile(stdlib.io.BytesIO(simpleBytes))
        AhkTest.AssertEqual("PaletteFile", palette.AhkStdlibTypeName)
        AhkTest.AssertEqual("RGB", palette.rawmode)
        AhkTest.AssertEqual(768, palette.palette.Length)
        AhkTest.AssertEqual([10, 20, 30, 7, 7, 7, 1, 2, 3, 3, 3, 3, 4, 4, 4, 5, 5, 5], StdlibPillowTest.ArraySlice(palette.palette, 1, 18))
        AhkTest.AssertEqual([4, 5, 6], StdlibPillowTest.ArraySlice(palette.palette, 766, 768))
        AhkTest.AssertEqual([palette.palette, "RGB"], palette.getpalette())

        whitespace := module.PaletteFile(stdlib.io.BytesIO(whitespaceBytes))
        AhkTest.AssertEqual([0, 0, 0, 1, 1, 1, 2, 2, 2, 11, 12, 13, 99, 99, 99, 5, 5, 5], StdlibPillowTest.ArraySlice(whitespace.palette, 1, 18))

        empty := module.PaletteFile(stdlib.io.BytesIO([]))
        AhkTest.AssertEqual([0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5], StdlibPillowTest.ArraySlice(empty.palette, 1, 18))
        AhkTest.AssertEqual([255, 255, 255], StdlibPillowTest.ArraySlice(empty.palette, 766, 768))

        wrappedHigh := module.PaletteFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("5 256 0 0`n")))
        wrappedLow := module.PaletteFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("5 -1 0 0`n")))
        AhkTest.AssertEqual([0, 0, 0], StdlibPillowTest.ArraySlice(wrappedHigh.palette, 16, 18))
        AhkTest.AssertEqual([255, 0, 0], StdlibPillowTest.ArraySlice(wrappedLow.palette, 16, 18))

        longLine := StdlibPillowTest.AsciiBytes("0 " StrReplace(Format("{:101}", ""), " ", "1") "`n")
        AhkTest.RaisesMatch(SyntaxError, "^bad palette file$", (*) => module.PaletteFile(stdlib.io.BytesIO(longLine)))
        AhkTest.RaisesMatch(ValueError, "^not enough values to unpack \(expected 2, got 0\)$", (*) => module.PaletteFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("# comment`n`n0 1 2 3`n"))))
        AhkTest.RaisesMatch(ValueError, "^invalid literal for int\(\) with base 10: b'x'$", (*) => module.PaletteFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("x 1 2 3`n"))))
        AhkTest.RaisesMatch(ValueError, "^too many values to unpack \(expected 2\)$", (*) => module.PaletteFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("1 2 3`n"))))
        AhkTest.RaisesMatch(ValueError, "^too many values to unpack \(expected 2\)$", (*) => module.PaletteFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("1 2 3 4 5`n"))))
        AhkTest.RaisesMatch(TypeError, "^PaletteFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => module.PaletteFile())
        AhkTest.RaisesMatch(TypeError, "^PaletteFile\.__init__\(\) takes 2 positional arguments but 3 were given$", (*) => module.PaletteFile(stdlib.io.BytesIO(simpleBytes), stdlib.None))
        AhkTest.RaisesMatch(TypeError, "^PaletteFile\.getpalette\(\) takes 1 positional argument but 2 were given$", (*) => palette.getpalette(stdlib.None))
    }

    static TestPalmImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "PalmImagePlugin"))
        plugin := stdlib.pillow.PalmImagePlugin

        AhkTest.AssertTrue(HasProp(plugin, "_Palm8BitColormapValues"))
        AhkTest.AssertTrue(HasProp(plugin, "build_prototype_image"))
        AhkTest.AssertTrue(HasProp(plugin, "Palm8BitColormapImage"))
        AhkTest.AssertTrue(HasProp(plugin, "_FLAGS"))
        AhkTest.AssertTrue(HasProp(plugin, "_COMPRESSION_TYPES"))
        AhkTest.AssertTrue(HasProp(plugin, "_save"))
        AhkTest.AssertEqual(256, plugin._Palm8BitColormapValues.Length)
        AhkTest.AssertEqual([255, 255, 255], plugin._Palm8BitColormapValues[1])
        AhkTest.AssertEqual([255, 204, 255], plugin._Palm8BitColormapValues[2])
        AhkTest.AssertEqual([17, 17, 17], plugin._Palm8BitColormapValues[216])
        AhkTest.AssertEqual([0, 128, 128], plugin._Palm8BitColormapValues[230])
        AhkTest.AssertEqual([0, 0, 0], plugin._Palm8BitColormapValues[256])
        AhkTest.AssertEqual(0x4000, plugin._FLAGS["custom-colormap"])
        AhkTest.AssertEqual(0x8000, plugin._FLAGS["is-compressed"])
        AhkTest.AssertEqual(0x2000, plugin._FLAGS["has-transparent"])
        AhkTest.AssertEqual(0xFF, plugin._COMPRESSION_TYPES["none"])
        AhkTest.AssertEqual(0x01, plugin._COMPRESSION_TYPES["rle"])
        AhkTest.AssertEqual(0x00, plugin._COMPRESSION_TYPES["scanline"])
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("PALM"))
        AhkTest.AssertFalse(stdlib.pillow.Image.SAVE.Has("Palm"))
        AhkTest.AssertEqual("PALM", stdlib.pillow.Image.registered_extensions()[".palm"])
        AhkTest.AssertEqual("image/palm", stdlib.pillow.Image.MIME["PALM"])
        AhkTest.AssertFalse(stdlib.pillow.Image.OPEN.Has("PALM"))
        AhkTest.AssertFalse(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "PALM"))

        proto := unset
        moduleProto := unset
        one := unset
        p := unset
        pNoPalette := unset
        l := unset
        rgb := unset
        try {
            proto := plugin.build_prototype_image()
            AhkTest.AssertEqual("P", proto.mode)
            AhkTest.AssertEqual([1, 256], proto.size)
            AhkTest.AssertEqual([0, 1, 2, 3, 4, 5, 6, 7], StdlibPillowTest.ArraySlice(proto.getdata(), 1, 8))
            AhkTest.AssertEqual([255, 255, 255, 255, 204, 255, 255, 153, 255, 255, 102, 255, 255, 51, 255, 255, 0, 255], StdlibPillowTest.ArraySlice(proto.getpalette(), 1, 18))
            AhkTest.AssertEqual(768, proto.getpalette().Length)
            moduleProto := plugin.Palm8BitColormapImage
            AhkTest.AssertEqual("P", moduleProto.mode)
            AhkTest.AssertEqual([1, 256], moduleProto.size)

            one := stdlib.pillow.Image.new("1", [9, 2], 1)
            for xy in [[0, 0], [3, 0], [8, 0], [1, 1], [7, 1]]
                one.putpixel(xy, 0)
            oneOutput := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, one.save(oneOutput, "Palm"))
            AhkTest.AssertEqual(StdlibPillowTest.PalmOneBytes(), oneOutput.getvalue())
            directOneOutput := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, plugin._save(one, directOneOutput, ""))
            AhkTest.AssertEqual(StdlibPillowTest.PalmOneBytes(), directOneOutput.getvalue())

            p := stdlib.pillow.Image.new("P", [2, 2])
            p.putdata([0, 1, 2, 3])
            p.putpalette([255, 0, 0, 0, 255, 0, 0, 0, 255, 1, 2, 3])
            pOutput := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, p.save(pOutput, "Palm"))
            AhkTest.AssertEqual(StdlibPillowTest.PalmPBytes(), pOutput.getvalue())

            pNoPalette := stdlib.pillow.Image.new("P", [1, 1])
            pNoPaletteOutput := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, pNoPalette.save(pNoPaletteOutput, "Palm"))
            AhkTest.AssertEqual(StdlibPillowTest.PalmPNoPaletteBytes(), pNoPaletteOutput.getvalue())

            l := stdlib.pillow.Image.new("L", [4, 2])
            l.putdata([0, 63, 127, 255, 255, 127, 63, 0])
            AhkTest.RaisesMatch(OSError, "^cannot write mode L as Palm$", (*) => l.save(stdlib.io.BytesIO(), "Palm"))
            AhkTest.RaisesMatch(ValueError, "^image has no palette$", (*) => l.save(stdlib.io.BytesIO(), "Palm", { bpp: 1 }))
            AhkTest.RaisesMatch(ValueError, "^image has no palette$", (*) => l.save(stdlib.io.BytesIO(), "Palm", { bpp: 2 }))
            AhkTest.RaisesMatch(ValueError, "^image has no palette$", (*) => l.save(stdlib.io.BytesIO(), "Palm", { bpp: 4 }))
            AhkTest.RaisesMatch(OSError, "^cannot write mode L as Palm$", (*) => l.save(stdlib.io.BytesIO(), "Palm", { bpp: 3 }))
            l.info["bpp"] := 2
            AhkTest.RaisesMatch(ValueError, "^image has no palette$", (*) => l.save(stdlib.io.BytesIO(), "Palm"))

            rgb := stdlib.pillow.Image.new("RGB", [1, 1])
            AhkTest.RaisesMatch(OSError, "^cannot write mode RGB as Palm$", (*) => rgb.save(stdlib.io.BytesIO(), "Palm"))
            AhkTest.RaisesMatch(TypeError, "^_save\(\) missing 3 required positional arguments: 'im', 'fp', and 'filename'$", (*) => plugin._save())
        } finally {
            for image in [rgb, l, pNoPalette, p, one, moduleProto, proto] {
                if IsSet(image)
                    StdlibPillowTest.CloseImage(image)
            }
        }
    }

    static TestPcdImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "PcdImagePlugin"))
        plugin := stdlib.pillow.PcdImagePlugin

        AhkTest.AssertTrue(HasProp(plugin, "PcdImageFile"))
        AhkTest.AssertFalse(HasProp(plugin, "_accept"))
        AhkTest.AssertEqual("PCD", plugin.PcdImageFile.format)
        AhkTest.AssertEqual("Kodak PhotoCD", plugin.PcdImageFile.format_description)
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("PCD"))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.OPEN["PCD"][2])
        AhkTest.AssertEqual("PCD", stdlib.pillow.Image.registered_extensions()[".pcd"])
        AhkTest.AssertTrue(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "PCD"))
        AhkTest.AssertFalse(stdlib.pillow.Image.SAVE.Has("PCD"))
        AhkTest.AssertFalse(stdlib.pillow.Image.MIME.Has("PCD"))

        pcdBytes := StdlibPillowTest.PcdBytes()
        direct := unset
        opened := unset
        rotated := unset
        negative := unset
        try {
            direct := plugin.PcdImageFile(stdlib.io.BytesIO(pcdBytes))
            AhkTest.AssertEqual("PCD", direct.format)
            AhkTest.AssertEqual("Kodak PhotoCD", direct.format_description)
            AhkTest.AssertEqual("RGB", direct.mode)
            AhkTest.AssertEqual([768, 512], direct.size)
            AhkTest.AssertSame(stdlib.None, direct.tile_post_rotate)
            AhkTest.AssertEqual(["pcd", [0, 0, 768, 512], 196608, stdlib.None], direct.tile[1])
            AhkTest.AssertSame(stdlib.None, direct.load_end())
            AhkTest.RaisesMatch(OSError, "^image file is truncated \(0 bytes not processed\)$", (*) => direct.load())

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pcdBytes), "r", ["PCD"])
            AhkTest.AssertEqual("PCD", opened.format)
            AhkTest.AssertEqual("RGB", opened.mode)
            AhkTest.AssertEqual([768, 512], opened.size)
            AhkTest.AssertEqual(["pcd", [0, 0, 768, 512], 196608, stdlib.None], opened.tile[1])

            rotated := stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.PcdBytes(1)), "r", ["PCD"])
            AhkTest.AssertEqual(90, rotated.tile_post_rotate)
            AhkTest.Raises(AssertionError, (*) => rotated.load_end())

            negative := plugin.PcdImageFile(stdlib.io.BytesIO(StdlibPillowTest.PcdBytes(3)))
            AhkTest.AssertEqual(-90, negative.tile_post_rotate)

            AhkTest.RaisesMatch(SyntaxError, "^not a PCD file$", (*) => plugin.PcdImageFile(stdlib.io.BytesIO(StdlibPillowTest.PcdBytes(0, "BAD_"))))
            AhkTest.RaisesMatch(SyntaxError, "^not a PCD file$", (*) => plugin.PcdImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("PCD_"))))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.PcdBytes(0, "BAD_")), "r", ["PCD"]))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.PcdImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.PcdImageFile(stdlib.io.BytesIO(pcdBytes), "x", "y"))
            AhkTest.RaisesMatch(TypeError, "^formats must be a list or tuple$", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(pcdBytes), "r", "PCD"))
        } finally {
            if IsSet(negative)
                StdlibPillowTest.CloseImage(negative)
            if IsSet(rotated)
                StdlibPillowTest.CloseImage(rotated)
            if IsSet(opened)
                StdlibPillowTest.CloseImage(opened)
            if IsSet(direct)
                StdlibPillowTest.CloseImage(direct)
        }
    }

    static TestPcxImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "PcxImagePlugin"))
        plugin := stdlib.pillow.PcxImagePlugin

        AhkTest.AssertTrue(HasProp(plugin, "PcxImageFile"))
        AhkTest.AssertTrue(HasProp(plugin, "SAVE"))
        AhkTest.AssertTrue(HasProp(plugin, "_accept"))
        AhkTest.AssertTrue(HasProp(plugin, "_save"))
        AhkTest.AssertTrue(plugin._accept([10, 5]))
        AhkTest.AssertTrue(plugin._accept([10, 0]))
        AhkTest.AssertFalse(plugin._accept([9, 5]))
        AhkTest.AssertFalse(plugin._accept([10, 1]))
        AhkTest.RaisesMatch(IndexError, "^index out of range$", (*) => plugin._accept([10]))
        AhkTest.AssertEqual("PCX", plugin.PcxImageFile.format)
        AhkTest.AssertEqual("Paintbrush", plugin.PcxImageFile.format_description)
        AhkTest.AssertEqual([2, 1, 1, "1"], plugin.SAVE["1"])
        AhkTest.AssertEqual([5, 8, 1, "L"], plugin.SAVE["L"])
        AhkTest.AssertEqual([5, 8, 1, "P"], plugin.SAVE["P"])
        AhkTest.AssertEqual([5, 8, 3, "RGB;L"], plugin.SAVE["RGB"])
        AhkTest.AssertEqual(0x1234, plugin.i16([0x34, 0x12], 0))
        AhkTest.AssertEqual(0x5678, plugin.i16([0, 0x78, 0x56], 1))
        AhkTest.AssertEqual([2], plugin.o8(258))
        AhkTest.AssertEqual([255], plugin.o8(-1))
        AhkTest.AssertEqual([0x34, 0x12], plugin.o16(0x1234))
        AhkTest.RaisesMatch(Error, "^ushort format requires 0 <= number <= 0xffff$", (*) => plugin.o16(-1))
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("PCX"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("PCX"))
        AhkTest.AssertEqual("PCX", stdlib.pillow.Image.registered_extensions()[".pcx"])
        AhkTest.AssertEqual("image/x-pcx", stdlib.pillow.Image.MIME["PCX"])
        AhkTest.AssertTrue(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "PCX"))

        rgbBytes := StdlibPillowTest.PcxBytes("RGB", [2, 2], [[10, 20, 30], [200, 10, 5], [40, 50, 60], [1, 2, 3]])
        lBytes := StdlibPillowTest.PcxBytes("L", [2, 2], [0, 63, 127, 255])
        pPalette := [255, 0, 0, 0, 255, 0, 0, 0, 255, 1, 2, 3]
        pBytes := StdlibPillowTest.PcxBytes("P", [2, 2], [0, 1, 2, 3], pPalette)
        oneData := [0, 255, 255, 0, 255, 255, 255, 255, 0, 255, 0, 255, 255, 255, 255, 255, 0, 255]
        oneBytes := StdlibPillowTest.PcxBytes("1", [9, 2], oneData)

        images := []
        try {
            rgb := plugin.PcxImageFile(stdlib.io.BytesIO(rgbBytes))
            images.Push(rgb)
            AhkTest.AssertEqual("PCX", rgb.format)
            AhkTest.AssertEqual("Paintbrush", rgb.format_description)
            AhkTest.AssertEqual("RGB", rgb.mode)
            AhkTest.AssertEqual([2, 2], rgb.size)
            AhkTest.AssertEqual([100, 100], rgb.info["dpi"])
            AhkTest.AssertEqual(["pcx", [0, 0, 2, 2], 128, ["RGB;L", 6]], rgb.tile[1])
            AhkTest.AssertEqual([[10, 20, 30], [200, 10, 5], [40, 50, 60], [1, 2, 3]], rgb.getdata())

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(rgbBytes), "r", ["PCX"])
            images.Push(opened)
            AhkTest.AssertEqual("PCX", opened.format)
            AhkTest.AssertEqual([[10, 20, 30], [200, 10, 5], [40, 50, 60], [1, 2, 3]], opened.getdata())

            l := plugin.PcxImageFile(stdlib.io.BytesIO(lBytes))
            images.Push(l)
            AhkTest.AssertEqual("L", l.mode)
            AhkTest.AssertEqual(["pcx", [0, 0, 2, 2], 128, ["L", 2]], l.tile[1])
            AhkTest.AssertEqual([0, 63, 127, 255], l.getdata())

            p := plugin.PcxImageFile(stdlib.io.BytesIO(pBytes))
            images.Push(p)
            AhkTest.AssertEqual("P", p.mode)
            AhkTest.AssertEqual(["pcx", [0, 0, 2, 2], 128, ["P", 2]], p.tile[1])
            AhkTest.AssertEqual([0, 1, 2, 3], p.getdata())
            AhkTest.AssertEqual(pPalette, StdlibPillowTest.ArraySlice(p.getpalette(), 1, 12))

            one := plugin.PcxImageFile(stdlib.io.BytesIO(oneBytes))
            images.Push(one)
            AhkTest.AssertEqual("1", one.mode)
            AhkTest.AssertEqual(["pcx", [0, 0, 9, 2], 128, ["1", 2]], one.tile[1])
            AhkTest.AssertEqual(oneData, one.getdata())

            rgbSource := stdlib.pillow.Image.new("RGB", [2, 2])
            images.Push(rgbSource)
            rgbSource.putdata([[10, 20, 30], [200, 10, 5], [40, 50, 60], [1, 2, 3]])
            rgbOut := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, rgbSource.save(rgbOut, "PCX"))
            AhkTest.AssertEqual(rgbBytes, rgbOut.getvalue())

            lSource := stdlib.pillow.Image.new("L", [2, 2])
            images.Push(lSource)
            lSource.putdata([0, 63, 127, 255])
            lOut := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, plugin._save(lSource, lOut, ""))
            AhkTest.AssertEqual(lBytes, lOut.getvalue())

            pSource := stdlib.pillow.Image.new("P", [2, 2])
            images.Push(pSource)
            pSource.putdata([0, 1, 2, 3])
            pSource.putpalette(pPalette)
            pOut := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, pSource.save(pOut, "PCX"))
            AhkTest.AssertEqual(pBytes, pOut.getvalue())

            oneSource := stdlib.pillow.Image.new("1", [9, 2])
            images.Push(oneSource)
            oneSource.putdata(oneData)
            oneOut := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, oneSource.save(oneOut, "PCX"))
            AhkTest.AssertEqual(oneBytes, oneOut.getvalue())

            badSize := rgbBytes.Clone()
            badSize[5] := 2
            badSize[9] := 1
            badMode := rgbBytes.Clone()
            badMode[4] := 2
            AhkTest.RaisesMatch(SyntaxError, "^not a PCX file$", (*) => plugin.PcxImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD!"))))
            AhkTest.RaisesMatch(SyntaxError, "^bad PCX image size$", (*) => plugin.PcxImageFile(stdlib.io.BytesIO(badSize)))
            AhkTest.RaisesMatch(OSError, "^unknown PCX mode$", (*) => plugin.PcxImageFile(stdlib.io.BytesIO(badMode)))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD!")), "r", ["PCX"]))
            AhkTest.RaisesMatch(ValueError, "^Cannot save CMYK images as PCX$", (*) => plugin._save({ mode: "CMYK", size: [1, 1] }, stdlib.io.BytesIO(), ""))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.PcxImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.PcxImageFile(stdlib.io.BytesIO(rgbBytes), "x", "y"))
            AhkTest.RaisesMatch(TypeError, "^_save\(\) missing 3 required positional arguments: 'im', 'fp', and 'filename'$", (*) => plugin._save())
        } finally {
            for image in images
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestPdfImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "PdfImagePlugin"))
        plugin := stdlib.pillow.PdfImagePlugin

        AhkTest.AssertTrue(HasProp(plugin, "_save"))
        AhkTest.AssertTrue(HasProp(plugin, "_save_all"))
        AhkTest.AssertTrue(HasProp(plugin, "_write_image"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("PDF"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE_ALL.Has("PDF"))
        AhkTest.AssertEqual("PDF", stdlib.pillow.Image.registered_extensions()[".pdf"])
        AhkTest.AssertEqual("application/pdf", stdlib.pillow.Image.MIME["PDF"])
        AhkTest.AssertFalse(stdlib.pillow.Image.OPEN.Has("PDF"))
        AhkTest.AssertFalse(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "PDF"))

        images := []
        try {
            rgb := stdlib.pillow.Image.new("RGB", [2, 2])
            images.Push(rgb)
            rgb.putdata([[10, 20, 30], [200, 10, 5], [40, 50, 60], [1, 2, 3]])
            rgbOut := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, rgb.save(rgbOut, "PDF", { title: "Demo", author: "Me" }))
            rgbBytes := rgbOut.getvalue()
            AhkTest.AssertEqual([37, 80, 68, 70, 45, 49, 46, 52], StdlibPillowTest.ArraySlice(rgbBytes, 1, 8))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(rgbBytes, "% created by Pillow 11.3.0 PDF driver"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(rgbBytes, "/Filter /DCTDecode"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(rgbBytes, "/ColorSpace /DeviceRGB"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(rgbBytes, "/ProcSet [ /PDF /ImageC ]"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(rgbBytes, "/MediaBox [ 0 0 2.0 2.0 ]"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(rgbBytes, "/Title (Demo)"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(rgbBytes, "/Author (Me)"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(rgbBytes, "xref"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(rgbBytes, "trailer"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(rgbBytes, "%%EOF"))
            AhkTest.AssertEqual(1, StdlibPillowTest.CountAscii(rgbBytes, "/Subtype /Image"))

            l := stdlib.pillow.Image.new("L", [2, 2])
            images.Push(l)
            l.putdata([0, 63, 127, 255])
            lOut := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, l.save(lOut, "PDF", { resolution: 144.0 }))
            lBytes := lOut.getvalue()
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(lBytes, "/Filter /DCTDecode"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(lBytes, "/ColorSpace /DeviceGray"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(lBytes, "/ProcSet [ /PDF /ImageB ]"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(lBytes, "/MediaBox [ 0 0 1.0 1.0 ]"))

            p := stdlib.pillow.Image.new("P", [2, 2])
            images.Push(p)
            p.putdata([0, 1, 2, 3])
            p.putpalette([255, 0, 0, 0, 255, 0, 0, 0, 255, 1, 2, 3])
            pOut := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, p.save(pOut, "PDF"))
            pBytes := pOut.getvalue()
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(pBytes, "/Filter /ASCIIHexDecode"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(pBytes, "/ColorSpace [ /Indexed /DeviceRGB 3 <FF000000FF000000FF010203> ]"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(pBytes, "00010203"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(pBytes, "/ProcSet [ /PDF /ImageI ]"))

            one := stdlib.pillow.Image.new("1", [9, 2])
            images.Push(one)
            one.putdata([0, 255, 255, 0, 255, 255, 255, 255, 0, 255, 0, 255, 255, 255, 255, 255, 0, 255])
            oneOut := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, one.save(oneOut, "PDF"))
            oneBytes := oneOut.getvalue()
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(oneBytes, "/Filter [ /CCITTFaxDecode ]"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(oneBytes, "/BitsPerComponent 1"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(oneBytes, "/BlackIs1 true"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(oneBytes, "/Columns 9"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(oneBytes, "/Rows 2"))

            append := stdlib.pillow.Image.new("RGB", [2, 2])
            images.Push(append)
            append.putdata([[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12]])
            allOut := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, rgb.save(allOut, "PDF", { save_all: true, append_images: [append], dpi: [144, 72] }))
            allBytes := allOut.getvalue()
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(allBytes, "/Count 2"))
            AhkTest.AssertEqual(2, StdlibPillowTest.CountAscii(allBytes, "/Subtype /Image"))
            AhkTest.AssertEqual(2, StdlibPillowTest.CountAscii(allBytes, "/MediaBox [ 0 0 1.0 2.0 ]"))

            directOut := stdlib.io.BytesIO()
            rgb.encoderinfo := Map("title", "Direct")
            AhkTest.AssertSame(stdlib.None, plugin._save(rgb, directOut, "direct.pdf"))
            directBytes := directOut.getvalue()
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(directBytes, "/Title (Direct)"))

            AhkTest.RaisesMatch(ValueError, "^cannot save mode F$", (*) => stdlib.pillow.Image.new("F", [1, 1]).save(stdlib.io.BytesIO(), "PDF"))
            AhkTest.RaisesMatch(TypeError, "^_save\(\) missing 3 required positional arguments: 'im', 'fp', and 'filename'$", (*) => plugin._save())
            AhkTest.RaisesMatch(TypeError, "^_save_all\(\) missing 3 required positional arguments: 'im', 'fp', and 'filename'$", (*) => plugin._save_all())
            AhkTest.RaisesMatch(TypeError, "^_write_image\(\) missing 4 required positional arguments: 'im', 'filename', 'existing_pdf', and 'image_refs'$", (*) => plugin._write_image())
        } finally {
            for image in images
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestPdfParserBasicsMatchLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "PdfParser"))
        module := stdlib.pillow.PdfParser

        for name in ["IndirectObjectDef", "IndirectReference", "IndirectReferenceTuple", "PDFDocEncoding", "PdfArray", "PdfBinary", "PdfDict", "PdfFormatError", "PdfName", "PdfParser", "PdfStream", "XrefTable", "check_format_condition", "decode_text", "encode_text", "pdf_repr"]
            AhkTest.AssertTrue(HasProp(module, name), name)

        AhkTest.AssertEqual([254, 255, 0, 65, 0, 122, 0, 69, 0, 85, 0, 82], module.encode_text("AzEUR"))
        AhkTest.AssertEqual("A" Chr(0x2022) Chr(0x20AC) Chr(0xFF), module.decode_text([65, 0x80, 0xA0, 0xFF]))
        AhkTest.AssertEqual("Hi", module.decode_text(module.encode_text("Hi")))
        AhkTest.AssertSame(stdlib.None, module.check_format_condition(true, "bad"))
        AhkTest.RaisesMatch(module.PdfFormatError, "^bad$", (*) => module.check_format_condition(false, "bad"))

        ref := module.IndirectReference(12, 3)
        AhkTest.AssertEqual("IndirectReference", ref.AhkStdlibTypeName)
        AhkTest.AssertEqual(12, ref.object_id)
        AhkTest.AssertEqual(3, ref.generation)
        AhkTest.AssertEqual([12, 3], ref.as_tuple())
        AhkTest.AssertEqual("12 3 R", ref.ToString())
        AhkTest.AssertEqual([49, 50, 32, 51, 32, 82], ref.__bytes())
        AhkTest.AssertTrue(ref.equals(module.IndirectReference(12, 3)))
        AhkTest.AssertFalse(ref.equals([12, 3]))
        AhkTest.AssertTrue(ref.not_equals(module.IndirectReference(12, 4)))
        AhkTest.AssertEqual("IndirectReference(object_id=12, generation=3)", ref.__Repr())

        objdef := module.IndirectObjectDef(5, 0)
        AhkTest.AssertEqual("5 0 obj", objdef.ToString())
        AhkTest.AssertEqual([53, 32, 48, 32, 111, 98, 106], objdef.__bytes())
        AhkTest.AssertFalse(objdef.equals(module.IndirectReference(5, 0)))
        AhkTest.AssertTrue(objdef.equals(module.IndirectObjectDef(5, 0)))

        name := module.PdfName([65, 32, 66, 47, 35, 120])
        AhkTest.AssertEqual("PdfName", name.AhkStdlibTypeName)
        AhkTest.AssertEqual([65, 32, 66, 47, 35, 120], name.name)
        AhkTest.AssertEqual("A B/#x", name.name_as_str())
        AhkTest.AssertEqual([47, 65, 35, 50, 48, 66, 35, 50, 70, 35, 50, 51, 120], name.__bytes())
        AhkTest.AssertEqual("PdfName(b'A B/#x')", name.__Repr())
        AhkTest.AssertTrue(name.equals([65, 32, 66, 47, 35, 120]))
        AhkTest.AssertTrue(name.equals(module.PdfName("A B/#x")))
        AhkTest.AssertEqual("A B/C", module.PdfName.from_pdf_stream([65, 35, 50, 48, 66, 35, 50, 102, 67]).name_as_str())

        array := module.PdfArray([module.PdfName("Name"), 3, stdlib.True, stdlib.None, [97, 40, 98, 41, 92, 99]])
        AhkTest.AssertEqual([91, 32, 47, 78, 97, 109, 101, 32, 51, 32, 116, 114, 117, 101, 32, 110, 117, 108, 108, 32, 40, 97, 92, 40, 98, 92, 41, 92, 92, 99, 41, 32, 93], array.__bytes())

        dict := module.PdfDict(Map(
            [84, 121, 112, 101], module.PdfName("Catalog"),
            [67, 111, 117, 110, 116], 2,
            [83, 107, 105, 112], stdlib.None,
            [84, 105, 116, 108, 101], module.encode_text("Hi"),
            [67, 114, 101, 97, 116, 105, 111, 110, 68, 97, 116, 101], [68, 58, 50, 48, 50, 48, 48, 49, 48, 50, 48, 51, 48, 52, 48, 53, 43, 48, 50, 39, 51, 48, 39]
        ))
        dict.setattr("Author", [77, 101])
        AhkTest.AssertEqual("Hi", dict.getattr("Title"))
        AhkTest.AssertEqual("Me", dict.getattr("Author"))
        AhkTest.AssertEqual([2020, 1, 2, 0, 34, 5, 3, 2, 0], dict.getattr("CreationDate"))
        AhkTest.RaisesMatch(AttributeError, "^Missing$", (*) => dict.getattr("Missing"))
        AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(dict.__bytes(), "/Type /Catalog"))
        AhkTest.AssertFalse(StdlibPillowTest.BytesContainsAscii(dict.__bytes(), "/Skip"))

        AhkTest.AssertEqual([60, 48, 48, 48, 70, 49, 48, 70, 70, 62], module.PdfBinary([0, 15, 16, 255]).__bytes())
        AhkTest.AssertEqual([97, 98, 99], module.PdfStream(module.PdfDict(), [97, 98, 99]).decode())
        AhkTest.AssertEqual([104, 101, 108, 108, 111, 32, 104, 101, 108, 108, 111], module.PdfStream(module.PdfDict(Map([70, 105, 108, 116, 101, 114], [70, 108, 97, 116, 101, 68, 101, 99, 111, 100, 101], [76, 101, 110, 103, 116, 104], 19, [68, 76], 11)), [120, 156, 203, 72, 205, 201, 201, 87, 200, 64, 144, 0, 26, 11, 4, 93]).decode())
        AhkTest.RaisesMatch(NotImplementedError, "^stream filter b'Bad' unknown/unsupported$", (*) => module.PdfStream(module.PdfDict(Map([70, 105, 108, 116, 101, 114], [66, 97, 100], [76, 101, 110, 103, 116, 104], 3)), [97, 98, 99]).decode())

        AhkTest.AssertEqual([116, 114, 117, 101], module.pdf_repr(stdlib.True))
        AhkTest.AssertEqual([102, 97, 108, 115, 101], module.pdf_repr(stdlib.False))
        AhkTest.AssertEqual([110, 117, 108, 108], module.pdf_repr(stdlib.None))
        AhkTest.AssertEqual([47, 78], module.pdf_repr(module.PdfName("N")))
        AhkTest.AssertEqual([40, 254, 255, 0, 72, 0, 105, 41], module.pdf_repr("Hi"))
        AhkTest.AssertEqual([40, 97, 92, 40, 98, 92, 41, 92, 92, 99, 41], module.pdf_repr([97, 40, 98, 41, 92, 99]))
        AhkTest.AssertEqual([49, 50, 32, 51, 32, 82], module.pdf_repr(ref))

        xref := module.XrefTable()
        AhkTest.AssertEqual(1, xref.len())
        AhkTest.AssertEqual([], xref.keys())
        AhkTest.AssertFalse(xref.contains(0))
        xref.set(1, [10, 0])
        xref.set(3, [30, 2])
        AhkTest.AssertEqual([1, 3], xref.keys())
        AhkTest.AssertEqual([10, 0], xref.get(1))
        xref.delete(1)
        AhkTest.AssertEqual([3], xref.keys())
        AhkTest.AssertTrue(xref.contains(1))
        AhkTest.RaisesMatch(IndexError, "^object ID 9 cannot be deleted because it doesn't exist$", (*) => xref.delete(9))
        xrefOut := stdlib.io.BytesIO()
        AhkTest.AssertEqual(0, xref.write(xrefOut))
        AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("xref`n0 2`n0000000001 65536 f `n0000000000 00001 f `n"), xrefOut.getvalue())

        parser := module.PdfParser()
        AhkTest.AssertEqual(0, parser.file_size_total)
        AhkTest.AssertEqual([], parser.pages)
        AhkTest.AssertTrue(parser.xref_table.reading_finished)
        AhkTest.AssertEqual("1 0 R", parser.next_object_id().ToString())
        AhkTest.AssertEqual("1 0 R", parser.next_object_id(42).ToString())
        AhkTest.AssertEqual([1], parser.xref_table.keys())

        writerOut := stdlib.io.BytesIO()
        writer := module.PdfParser(, writerOut)
        AhkTest.AssertSame(stdlib.None, writer.start_writing())
        AhkTest.AssertSame(stdlib.None, writer.write_header())
        AhkTest.AssertSame(stdlib.None, writer.write_comment("demo"))
        writtenRef := writer.write_obj(stdlib.None, module.PdfDict(Map([65], 1)), { stream: [97, 98, 99] })
        AhkTest.AssertEqual("1 0 R", writtenRef.ToString())
        AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(writerOut.getvalue(), "%PDF-1.4`n% demo`n1 0 obj<<`n/Length 3`n>><<`n/A 1`n>>stream`nabc`nendstream`nendobj`n"))
    }

    static TestPixarImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "PixarImagePlugin"))
        plugin := stdlib.pillow.PixarImagePlugin

        pixarBytes := StdlibPillowTest.PixarBytes()
        badMagic := pixarBytes.Clone()
        for index, byte in StdlibPillowTest.AsciiBytes("BAD!")
            badMagic[index] := byte
        unknownMode := StdlibPillowTest.PixarBytes(2, 2, 1, 1)

        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.ArraySlice(pixarBytes, 1, 16)))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.ArraySlice(pixarBytes, 1, 3)))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.ArraySlice(badMagic, 1, 16)))
        AhkTest.AssertEqual(2, plugin.i16(pixarBytes, 418))
        AhkTest.AssertEqual(2, plugin.i16(pixarBytes, 416))
        AhkTest.AssertEqual(14, plugin.i16(pixarBytes, 424))
        AhkTest.AssertEqual(2, plugin.i16(pixarBytes, 426))
        AhkTest.AssertEqual("PIXAR", plugin.PixarImageFile.format)
        AhkTest.AssertEqual("PIXAR raster image", plugin.PixarImageFile.format_description)
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("PIXAR"))
        AhkTest.AssertEqual("PIXAR", stdlib.pillow.Image.registered_extensions()[".pxr"])
        AhkTest.AssertFalse(stdlib.pillow.Image.SAVE.Has("PIXAR"))
        AhkTest.AssertFalse(stdlib.pillow.Image.SAVE_ALL.Has("PIXAR"))
        AhkTest.AssertFalse(stdlib.pillow.Image.MIME.Has("PIXAR"))
        AhkTest.AssertTrue(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "PIXAR"))

        images := []
        try {
            direct := plugin.PixarImageFile(stdlib.io.BytesIO(pixarBytes))
            images.Push(direct)
            AhkTest.AssertEqual("PIXAR", direct.format)
            AhkTest.AssertEqual("PIXAR raster image", direct.format_description)
            AhkTest.AssertEqual("RGB", direct.mode)
            AhkTest.AssertEqual([2, 2], direct.size)
            AhkTest.AssertEqual(["raw", [0, 0, 2, 2], 1024, "RGB"], direct.tile[1])
            AhkTest.AssertEqual([[10, 20, 30], [200, 10, 5], [40, 50, 60], [1, 2, 3]], direct.getdata())

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(pixarBytes), "r", ["PIXAR"])
            images.Push(opened)
            AhkTest.AssertEqual("PIXAR", opened.format)
            AhkTest.AssertEqual("RGB", opened.mode)
            AhkTest.AssertEqual([2, 2], opened.size)
            AhkTest.AssertEqual([[10, 20, 30], [200, 10, 5], [40, 50, 60], [1, 2, 3]], opened.getdata())

            AhkTest.RaisesMatch(SyntaxError, "^not a PIXAR file$", (*) => plugin.PixarImageFile(stdlib.io.BytesIO(badMagic)))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(badMagic), "r", ["PIXAR"]))
            AhkTest.RaisesMatch(SyntaxError, "^not identified by this driver$", (*) => plugin.PixarImageFile(stdlib.io.BytesIO(unknownMode)))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.PixarImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.PixarImageFile(stdlib.io.BytesIO(pixarBytes), "x", "y"))
        } finally {
            for image in images
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestPngImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "PngImagePlugin"))
        plugin := stdlib.pillow.PngImagePlugin
        magic := [137, 80, 78, 71, 13, 10, 26, 10]

        AhkTest.AssertEqual("PNG", plugin.PngImageFile.format)
        AhkTest.AssertEqual("Portable network graphics", plugin.PngImageFile.format_description)
        AhkTest.AssertEqual(magic, plugin._MAGIC)
        AhkTest.AssertTrue(plugin._accept(magic))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.ArraySlice(magic, 1, 7)))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("BAD!`r`n")))
        AhkTest.AssertEqual(0x1234, plugin.i16([0x12, 0x34], 0))
        AhkTest.AssertEqual(0x5678, plugin.i16([0, 0x56, 0x78], 1))
        AhkTest.AssertEqual(0x12345678, plugin.i32([0x12, 0x34, 0x56, 0x78], 0))
        AhkTest.AssertEqual([255], plugin.o8(255))
        AhkTest.AssertEqual([2], plugin.o8(258))
        AhkTest.AssertEqual([0x12, 0x34], plugin.o16(0x1234))
        AhkTest.AssertEqual([0x12, 0x34, 0x56, 0x78], plugin.o32(0x12345678))
        AhkTest.AssertEqual(2520958341, plugin._crc32(StdlibPillowTest.AsciiBytes("tEXt")))
        AhkTest.AssertEqual(3406099344, plugin._crc32(StdlibPillowTest.ConcatBytes(StdlibPillowTest.AsciiBytes("k"), [0], StdlibPillowTest.AsciiBytes("v")), plugin._crc32(StdlibPillowTest.AsciiBytes("tEXt"))))
        AhkTest.AssertTrue(plugin.is_cid(StdlibPillowTest.AsciiBytes("tEXt")))
        AhkTest.AssertTrue(plugin.is_cid(StdlibPillowTest.AsciiBytes("vpAg")))
        AhkTest.AssertFalse(plugin.is_cid(StdlibPillowTest.AsciiBytes("bad")))

        info := plugin.PngInfo()
        AhkTest.AssertEqual(0, info.chunks.Length)
        AhkTest.AssertSame(stdlib.None, info.add(StdlibPillowTest.AsciiBytes("vpAg"), StdlibPillowTest.AsciiBytes("private-before")))
        AhkTest.AssertSame(stdlib.None, info.add(StdlibPillowTest.AsciiBytes("vpAg"), StdlibPillowTest.AsciiBytes("private-after"), true))
        AhkTest.AssertSame(stdlib.None, info.add_text("Title", "Demo"))
        AhkTest.AssertSame(stdlib.None, info.add_text("Unicode", "Snowman " Chr(0x2603)))
        AhkTest.AssertSame(stdlib.None, info.add_itxt("Comment", "Bonjour", "fr", "Titre"))
        AhkTest.AssertEqual(5, info.chunks.Length)
        AhkTest.AssertEqual([StdlibPillowTest.AsciiBytes("vpAg"), StdlibPillowTest.AsciiBytes("private-before"), false], info.chunks[1])
        AhkTest.AssertEqual([StdlibPillowTest.AsciiBytes("vpAg"), StdlibPillowTest.AsciiBytes("private-after"), true], info.chunks[2])
        AhkTest.AssertEqual([StdlibPillowTest.AsciiBytes("tEXt"), StdlibPillowTest.ConcatBytes(StdlibPillowTest.AsciiBytes("Title"), [0], StdlibPillowTest.AsciiBytes("Demo")), false], info.chunks[3])
        AhkTest.AssertEqual([StdlibPillowTest.AsciiBytes("iTXt"), StdlibPillowTest.ConcatBytes(StdlibPillowTest.AsciiBytes("Unicode"), [0, 0, 0, 0, 0], StdlibPillowTest.AsciiBytes("Snowman "), [226, 152, 131]), false], info.chunks[4])
        AhkTest.AssertEqual([StdlibPillowTest.AsciiBytes("iTXt"), StdlibPillowTest.ConcatBytes(StdlibPillowTest.AsciiBytes("Comment"), [0, 0, 0], StdlibPillowTest.AsciiBytes("fr"), [0], StdlibPillowTest.AsciiBytes("Titre"), [0], StdlibPillowTest.AsciiBytes("Bonjour")), false], info.chunks[5])

        wrapped := plugin.PngInfo()
        itxt := plugin.iTXt("Salut", "fr", "Titre")
        AhkTest.AssertEqual("Salut", itxt.text)
        AhkTest.AssertEqual("fr", itxt.lang)
        AhkTest.AssertEqual("Titre", itxt.tkey)
        AhkTest.AssertSame(stdlib.None, wrapped.add_text("Wrapped", itxt))
        AhkTest.AssertEqual([StdlibPillowTest.AsciiBytes("iTXt"), StdlibPillowTest.ConcatBytes(StdlibPillowTest.AsciiBytes("Wrapped"), [0, 0, 0], StdlibPillowTest.AsciiBytes("fr"), [0], StdlibPillowTest.AsciiBytes("Titre"), [0], StdlibPillowTest.AsciiBytes("Salut")), false], wrapped.chunks[1])

        chunkFp := stdlib.io.BytesIO()
        AhkTest.AssertSame(stdlib.None, plugin.putchunk(chunkFp, StdlibPillowTest.AsciiBytes("tEXt"), StdlibPillowTest.AsciiBytes("k"), [0], StdlibPillowTest.AsciiBytes("v")))
        AhkTest.AssertEqual([0, 0, 0, 3, 116, 69, 88, 116, 107, 0, 118, 203, 4, 243, 144], chunkFp.getvalue())

        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("PNG"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("PNG"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE_ALL.Has("PNG"))
        AhkTest.AssertEqual("PNG", stdlib.pillow.Image.registered_extensions()[".png"])
        AhkTest.AssertEqual("PNG", stdlib.pillow.Image.registered_extensions()[".apng"])
        AhkTest.AssertEqual("image/png", stdlib.pillow.Image.MIME["PNG"])
        AhkTest.AssertTrue(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "PNG"))

        images := []
        try {
            source := stdlib.pillow.Image.new("RGB", [2, 2])
            images.Push(source)
            source.putdata([[10, 20, 30], [200, 10, 5], [40, 50, 60], [1, 2, 3]])
            pnginfo := plugin.PngInfo()
            pnginfo.add_text("Title", "Demo")
            pnginfo.add_itxt("Comment", "Bonjour", "fr", "Titre")
            pnginfo.add(StdlibPillowTest.AsciiBytes("vpAg"), StdlibPillowTest.AsciiBytes("private-before"))
            pnginfo.add(StdlibPillowTest.AsciiBytes("vpAg"), StdlibPillowTest.AsciiBytes("private-after"), true)

            out := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, source.save(out, "PNG", { pnginfo: pnginfo, dpi: [72, 96] }))
            saved := out.getvalue()
            AhkTest.AssertEqual([137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82], StdlibPillowTest.ArraySlice(saved, 1, 16))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(saved, "private-before"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(saved, "private-after"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(saved, "Title"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(saved, "Comment"))

            direct := plugin.PngImageFile(stdlib.io.BytesIO(saved))
            images.Push(direct)
            AhkTest.AssertEqual("PNG", direct.format)
            AhkTest.AssertEqual("Portable network graphics", direct.format_description)
            AhkTest.AssertEqual("RGB", direct.mode)
            AhkTest.AssertEqual([2, 2], direct.size)
            AhkTest.AssertEqual([200, 10, 5], direct.getpixel([1, 0]))
            AhkTest.AssertEqual("Demo", direct.info["Title"])
            AhkTest.AssertEqual("Bonjour", direct.info["Comment"].text)
            AhkTest.AssertEqual("fr", direct.info["Comment"].lang)
            AhkTest.AssertEqual("Titre", direct.info["Comment"].tkey)
            AhkTest.AssertEqual("Demo", direct.text["Title"])

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(saved), "r", ["PNG"])
            images.Push(opened)
            AhkTest.AssertEqual("PNG", opened.format)
            AhkTest.AssertEqual("RGB", opened.mode)
            AhkTest.AssertEqual([2, 2], opened.size)
            AhkTest.AssertEqual([200, 10, 5], opened.getpixel([1, 0]))
            AhkTest.AssertEqual("Demo", opened.info["Title"])
            AhkTest.AssertEqual("Bonjour", opened.text["Comment"].text)
            AhkTest.AssertTrue(opened.info.Has("dpi"))

            chunks := plugin.getchunks(source, { pnginfo: pnginfo, dpi: [72, 96] })
            AhkTest.AssertEqual(8, chunks.Length)
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("IHDR"), chunks[1][1])
            AhkTest.AssertEqual([0, 0, 0, 2, 0, 0, 0, 2, 8, 2, 0, 0, 0], chunks[1][2])
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("tEXt"), chunks[2][1])
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("iTXt"), chunks[3][1])
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("vpAg"), chunks[4][1])
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("pHYs"), chunks[5][1])
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("IDAT"), chunks[6][1])
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("vpAg"), chunks[7][1])
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("IEND"), chunks[8][1])
            AhkTest.AssertEqual([221, 104, 243, 255], chunks[2][3])

            AhkTest.RaisesMatch(SyntaxError, "^not a PNG file$", (*) => plugin.PngImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD!"))))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD!")), "r", ["PNG"]))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.PngImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.PngImageFile(stdlib.io.BytesIO(saved), stdlib.None, "extra"))
            AhkTest.RaisesMatch(TypeError, "^putchunk\(\) missing 2 required positional arguments: 'fp' and 'cid'$", (*) => plugin.putchunk())
            AhkTest.RaisesMatch(TypeError, "^getchunks\(\) missing 1 required positional argument: 'im'$", (*) => plugin.getchunks())
        } finally {
            for image in images
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestPpmImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "PpmImagePlugin"))
        plugin := stdlib.pillow.PpmImagePlugin

        AhkTest.AssertEqual([32, 9, 10, 11, 12, 13], plugin.b_whitespace)
        AhkTest.AssertEqual("1", plugin.MODES["P1"])
        AhkTest.AssertEqual("L", plugin.MODES["P2"])
        AhkTest.AssertEqual("RGB", plugin.MODES["P3"])
        AhkTest.AssertEqual("1", plugin.MODES["P4"])
        AhkTest.AssertEqual("L", plugin.MODES["P5"])
        AhkTest.AssertEqual("RGB", plugin.MODES["P6"])
        AhkTest.AssertEqual("CMYK", plugin.MODES["P0CMYK"])
        AhkTest.AssertEqual("F", plugin.MODES["Pf"])
        AhkTest.AssertEqual("P", plugin.MODES["PyP"])
        AhkTest.AssertEqual("RGBA", plugin.MODES["PyRGBA"])
        AhkTest.AssertEqual("CMYK", plugin.MODES["PyCMYK"])
        AhkTest.AssertEqual("PPM", plugin.PpmImageFile.format)
        AhkTest.AssertEqual("Pbmplus image", plugin.PpmImageFile.format_description)
        AhkTest.AssertTrue(HasProp(plugin, "PpmDecoder"))
        AhkTest.AssertTrue(HasProp(plugin, "PpmPlainDecoder"))
        AhkTest.AssertFalse(plugin._accept([]))
        AhkTest.RaisesMatch(IndexError, "^index out of range$", (*) => plugin._accept(StdlibPillowTest.AsciiBytes("P")))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("P0")))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("P1 data")))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("P6 data")))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("Pf data")))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("Py data")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("P7 data")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("Q6 data")))
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("PPM"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("PPM"))
        AhkTest.AssertFalse(stdlib.pillow.Image.SAVE_ALL.Has("PPM"))
        AhkTest.AssertTrue(stdlib.pillow.Image.DECODERS.Has("ppm"))
        AhkTest.AssertTrue(stdlib.pillow.Image.DECODERS.Has("ppm_plain"))
        AhkTest.AssertEqual("PPM", stdlib.pillow.Image.registered_extensions()[".pbm"])
        AhkTest.AssertEqual("PPM", stdlib.pillow.Image.registered_extensions()[".pgm"])
        AhkTest.AssertEqual("PPM", stdlib.pillow.Image.registered_extensions()[".ppm"])
        AhkTest.AssertEqual("PPM", stdlib.pillow.Image.registered_extensions()[".pnm"])
        AhkTest.AssertEqual("PPM", stdlib.pillow.Image.registered_extensions()[".pfm"])
        AhkTest.AssertEqual("image/x-portable-anymap", stdlib.pillow.Image.MIME["PPM"])
        AhkTest.AssertTrue(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "PPM"))

        p1Bytes := StdlibPillowTest.AsciiBytes("P1`n# comment`n3 2`n0 1 0`n1 0 1`n")
        p2Bytes := StdlibPillowTest.AsciiBytes("P2`n# gray comment`n2 2`n10`n0 5 10 1`n")
        p3Bytes := StdlibPillowTest.AsciiBytes("P3`n2 1`n5`n0 5 1 2 3 4`n")
        p4Bytes := StdlibPillowTest.ConcatBytes(StdlibPillowTest.AsciiBytes("P4`n3 2`n"), [0x40, 0xA0])
        p5Bytes := StdlibPillowTest.ConcatBytes(StdlibPillowTest.AsciiBytes("P5`n2 2`n255`n"), [0, 127, 255, 1])
        p5IBytes := StdlibPillowTest.ConcatBytes(StdlibPillowTest.AsciiBytes("P5`n2 2`n65535`n"), [0, 0, 0x80, 0, 0xFF, 0xFF, 0, 1])
        p6Bytes := StdlibPillowTest.ConcatBytes(StdlibPillowTest.AsciiBytes("P6`n2 1`n255`n"), [10, 20, 30, 200, 10, 5])
        pfBytes := StdlibPillowTest.ConcatBytes(StdlibPillowTest.AsciiBytes("Pf`n2 2`n-1.0`n"), [0, 0, 128, 63, 0, 0, 0, 64, 0, 0, 96, 64, 0, 0, 144, 64])
        pyRgbaBytes := StdlibPillowTest.ConcatBytes(StdlibPillowTest.AsciiBytes("PyRGBA`n1 1`n255`n"), [1, 2, 3, 4])
        pyPBytes := StdlibPillowTest.ConcatBytes(StdlibPillowTest.AsciiBytes("PyP`n2 1`n255`n"), [1, 2])
        p0CmykBytes := StdlibPillowTest.ConcatBytes(StdlibPillowTest.AsciiBytes("P0CMYK`n1 1`n255`n"), [1, 2, 3, 4])

        images := []
        try {
            p1 := plugin.PpmImageFile(stdlib.io.BytesIO(p1Bytes))
            images.Push(p1)
            AhkTest.AssertEqual("PPM", p1.format)
            AhkTest.AssertEqual("Pbmplus image", p1.format_description)
            AhkTest.AssertEqual("1", p1.mode)
            AhkTest.AssertEqual([3, 2], p1.size)
            AhkTest.AssertEqual("image/x-portable-bitmap", p1.custom_mimetype)
            AhkTest.AssertEqual(["ppm_plain", [0, 0, 3, 2], 17, "1;I"], p1.tile[1])
            AhkTest.AssertEqual([255, 0, 255, 0, 255, 0], p1.getdata())

            p2 := plugin.PpmImageFile(stdlib.io.BytesIO(p2Bytes))
            images.Push(p2)
            AhkTest.AssertEqual("L", p2.mode)
            AhkTest.AssertEqual("image/x-portable-graymap", p2.custom_mimetype)
            AhkTest.AssertEqual(["ppm_plain", [0, 0, 2, 2], 25, ["L", 10]], p2.tile[1])
            AhkTest.AssertEqual([0, 128, 255, 26], p2.getdata())

            p3 := plugin.PpmImageFile(stdlib.io.BytesIO(p3Bytes))
            images.Push(p3)
            AhkTest.AssertEqual("RGB", p3.mode)
            AhkTest.AssertEqual("image/x-portable-pixmap", p3.custom_mimetype)
            AhkTest.AssertEqual(["ppm_plain", [0, 0, 2, 1], 9, ["RGB", 5]], p3.tile[1])
            AhkTest.AssertEqual([[0, 255, 51], [102, 153, 204]], p3.getdata())

            p4 := plugin.PpmImageFile(stdlib.io.BytesIO(p4Bytes))
            images.Push(p4)
            AhkTest.AssertEqual("1", p4.mode)
            AhkTest.AssertEqual(["raw", [0, 0, 3, 2], 7, "1;I"], p4.tile[1])
            AhkTest.AssertEqual([255, 0, 255, 0, 255, 0], p4.getdata())

            p5 := plugin.PpmImageFile(stdlib.io.BytesIO(p5Bytes))
            images.Push(p5)
            AhkTest.AssertEqual("L", p5.mode)
            AhkTest.AssertEqual(["raw", [0, 0, 2, 2], 11, "L"], p5.tile[1])
            AhkTest.AssertEqual([0, 127, 255, 1], p5.getdata())

            p5I := plugin.PpmImageFile(stdlib.io.BytesIO(p5IBytes))
            images.Push(p5I)
            AhkTest.AssertEqual("I", p5I.mode)
            AhkTest.AssertEqual(["raw", [0, 0, 2, 2], 13, "I;16B"], p5I.tile[1])
            AhkTest.AssertEqual([0, 32768, 65535, 1], p5I.getdata())

            p6 := plugin.PpmImageFile(stdlib.io.BytesIO(p6Bytes))
            images.Push(p6)
            AhkTest.AssertEqual("RGB", p6.mode)
            AhkTest.AssertEqual(["raw", [0, 0, 2, 1], 11, "RGB"], p6.tile[1])
            AhkTest.AssertEqual([[10, 20, 30], [200, 10, 5]], p6.getdata())

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(p6Bytes), "r", ["PPM"])
            images.Push(opened)
            AhkTest.AssertEqual("PPM", opened.format)
            AhkTest.AssertEqual("RGB", opened.mode)
            AhkTest.AssertEqual([2, 1], opened.size)
            AhkTest.AssertEqual([[10, 20, 30], [200, 10, 5]], opened.getdata())

            pf := plugin.PpmImageFile(stdlib.io.BytesIO(pfBytes))
            images.Push(pf)
            AhkTest.AssertEqual("F", pf.mode)
            AhkTest.AssertEqual([2, 2], pf.size)
            AhkTest.AssertEqual(1.0, pf.info["scale"])
            AhkTest.AssertEqual(["raw", [0, 0, 2, 2], 12, ["F;32F", 0, -1]], pf.tile[1])
            pfData := pf.getdata()
            AhkTest.AssertApprox(3.5, pfData[1], { Abs: 0.000000000001, Rel: 0.0 })
            AhkTest.AssertApprox(4.5, pfData[2], { Abs: 0.000000000001, Rel: 0.0 })
            AhkTest.AssertApprox(1.0, pfData[3], { Abs: 0.000000000001, Rel: 0.0 })
            AhkTest.AssertApprox(2.0, pfData[4], { Abs: 0.000000000001, Rel: 0.0 })

            openedPf := stdlib.pillow.Image.open(stdlib.io.BytesIO(pfBytes), "r", ["PPM"])
            images.Push(openedPf)
            AhkTest.AssertEqual("PPM", openedPf.format)
            AhkTest.AssertEqual("F", openedPf.mode)
            AhkTest.AssertEqual(1.0, openedPf.info["scale"])
            AhkTest.AssertEqual([3.5, 4.5, 1.0, 2.0], openedPf.getdata())

            pyRgba := plugin.PpmImageFile(stdlib.io.BytesIO(pyRgbaBytes))
            images.Push(pyRgba)
            AhkTest.AssertEqual("RGBA", pyRgba.mode)
            AhkTest.AssertEqual([1, 2, 3, 4], pyRgba.getpixel([0, 0]))

            pyP := plugin.PpmImageFile(stdlib.io.BytesIO(pyPBytes))
            images.Push(pyP)
            AhkTest.AssertEqual("P", pyP.mode)
            AhkTest.AssertEqual([1, 2], pyP.getdata())

            p0Cmyk := plugin.PpmImageFile(stdlib.io.BytesIO(p0CmykBytes))
            images.Push(p0Cmyk)
            AhkTest.AssertEqual("CMYK", p0Cmyk.mode)
            AhkTest.AssertEqual([1, 2, 3, 4], p0Cmyk.getpixel([0, 0]))

            oneSource := stdlib.pillow.Image.new("1", [3, 2])
            images.Push(oneSource)
            oneSource.putdata([0, 255, 0, 255, 0, 255])
            oneOut := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, oneSource.save(oneOut, "PPM"))
            AhkTest.AssertEqual([80, 52, 10, 51, 32, 50, 10, 160, 64], oneOut.getvalue())

            lSource := stdlib.pillow.Image.new("L", [2, 2])
            images.Push(lSource)
            lSource.putdata([0, 127, 255, 1])
            lOut := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, plugin._save(lSource, lOut, ""))
            AhkTest.AssertEqual(p5Bytes, lOut.getvalue())

            rgbSource := stdlib.pillow.Image.new("RGB", [2, 1])
            images.Push(rgbSource)
            rgbSource.putdata([[10, 20, 30], [200, 10, 5]])
            rgbOut := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, rgbSource.save(rgbOut, "PPM"))
            AhkTest.AssertEqual(p6Bytes, rgbOut.getvalue())

            rgbaSource := stdlib.pillow.Image.new("RGBA", [1, 1])
            images.Push(rgbaSource)
            rgbaSource.putdata([[1, 2, 3, 4]])
            rgbaOut := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, rgbaSource.save(rgbaOut, "PPM"))
            AhkTest.AssertEqual(StdlibPillowTest.ConcatBytes(StdlibPillowTest.AsciiBytes("P6`n1 1`n255`n"), [1, 2, 3]), rgbaOut.getvalue())

            fSource := stdlib.pillow.Image.new("F", [2, 2])
            images.Push(fSource)
            fSource.putdata([1.0, 2.0, 3.5, 4.5])
            fOut := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, fSource.save(fOut, "PPM"))
            AhkTest.AssertEqual(StdlibPillowTest.ConcatBytes(StdlibPillowTest.AsciiBytes("Pf`n2 2`n-1.0`n"), [0, 0, 96, 64, 0, 0, 144, 64, 0, 0, 128, 63, 0, 0, 0, 64]), fOut.getvalue())

            AhkTest.RaisesMatch(SyntaxError, "^not a PPM file$", (*) => plugin.PpmImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD!`n2 2`n255`n"))))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD!`n2 2`n255`n")), "r", ["PPM"]))
            AhkTest.RaisesMatch(ValueError, "^Reached EOF while reading header$", (*) => plugin.PpmImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("P6`n2"))))
            AhkTest.RaisesMatch(ValueError, "^b'Token too long in file header: 12345678901'$", (*) => plugin.PpmImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("P6`n12345678901 1`n255`nabc"))))
            AhkTest.RaisesMatch(ValueError, "^maxval must be greater than 0 and less than 65536$", (*) => plugin.PpmImageFile(stdlib.io.BytesIO(StdlibPillowTest.ConcatBytes(StdlibPillowTest.AsciiBytes("P5`n1 1`n0`n"), [0]))))
            AhkTest.RaisesMatch(ValueError, "^Channel value is negative: -1$", (*) => plugin.PpmImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("P2`n1 1`n10`n-1`n"))).getdata())
            AhkTest.RaisesMatch(ValueError, "^Channel value too large for this mode: 11$", (*) => plugin.PpmImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("P2`n1 1`n10`n11`n"))).getdata())
            AhkTest.RaisesMatch(ValueError, "^b'Invalid token for this mode: 2'$", (*) => plugin.PpmImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("P1`n1 1`n2`n"))).getdata())
            AhkTest.RaisesMatch(OSError, "^cannot write mode P as PPM$", (*) => stdlib.pillow.Image.new("P", [1, 1]).save(stdlib.io.BytesIO(), "PPM"))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.PpmImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.PpmImageFile(stdlib.io.BytesIO(p6Bytes), "x", "y"))
            AhkTest.RaisesMatch(TypeError, "^_save\(\) missing 3 required positional arguments: 'im', 'fp', and 'filename'$", (*) => plugin._save())
        } finally {
            for image in images
            StdlibPillowTest.CloseImage(image)
        }
    }

    static TestPsdImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "PsdImagePlugin"))
        plugin := stdlib.pillow.PsdImagePlugin

        AhkTest.AssertEqual(["1", 1], plugin.MODES["0,1"])
        AhkTest.AssertEqual(["L", 1], plugin.MODES["0,8"])
        AhkTest.AssertEqual(["L", 1], plugin.MODES["1,8"])
        AhkTest.AssertEqual(["P", 1], plugin.MODES["2,8"])
        AhkTest.AssertEqual(["RGB", 3], plugin.MODES["3,8"])
        AhkTest.AssertEqual(["CMYK", 4], plugin.MODES["4,8"])
        AhkTest.AssertEqual(["L", 1], plugin.MODES["7,8"])
        AhkTest.AssertEqual(["L", 1], plugin.MODES["8,8"])
        AhkTest.AssertEqual(["LAB", 3], plugin.MODES["9,8"])
        AhkTest.AssertEqual(255, plugin.i8([255]))
        AhkTest.AssertEqual(0x1234, plugin.i16([0x12, 0x34]))
        AhkTest.AssertEqual(0x1234, plugin.i16([0, 0x12, 0x34], 1))
        AhkTest.AssertEqual(0x12345678, plugin.i32([0x12, 0x34, 0x56, 0x78]))
        AhkTest.AssertEqual(-1, plugin.si16([0xFF, 0xFF]))
        AhkTest.AssertEqual(-1, plugin.si32([0xFF, 0xFF, 0xFF, 0xFF]))
        AhkTest.AssertFalse(plugin._accept([]))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("8BP")))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("8BPS rest")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("BAD!")))
        AhkTest.AssertEqual("PSD", plugin.PsdImageFile.format)
        AhkTest.AssertEqual("Adobe Photoshop", plugin.PsdImageFile.format_description)
        AhkTest.AssertFalse(plugin.PsdImageFile._close_exclusive_fp_after_loading)
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("PSD"))
        AhkTest.AssertFalse(stdlib.pillow.Image.SAVE.Has("PSD"))
        AhkTest.AssertFalse(stdlib.pillow.Image.SAVE_ALL.Has("PSD"))
        AhkTest.AssertEqual("PSD", stdlib.pillow.Image.registered_extensions()[".psd"])
        AhkTest.AssertFalse(stdlib.pillow.Image.registered_extensions().Has(".psb"))
        AhkTest.AssertEqual("image/vnd.adobe.photoshop", stdlib.pillow.Image.MIME["PSD"])
        AhkTest.AssertTrue(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "PSD"))

        lBytes := StdlibPillowTest.PsdBytes(1, 8, 1, 2, 2, [0, 127, 255, 1])
        rgbBytes := StdlibPillowTest.PsdBytes(3, 8, 3, 2, 1, [10, 200, 20, 10, 30, 5])
        rgbaBytes := StdlibPillowTest.PsdBytes(3, 8, 4, 1, 1, [1, 2, 3, 4])
        pBytes := StdlibPillowTest.PsdBytes(2, 8, 1, 2, 1, [1, 2], StdlibPillowTest.PsdPalette())
        cmykBytes := StdlibPillowTest.PsdBytes(4, 8, 4, 1, 1, [1, 2, 3, 4])
        layeredBytes := StdlibPillowTest.PsdBytes(3, 8, 3, 2, 1, [100, 110, 120, 130, 140, 150], unset, StdlibPillowTest.PsdResourceBlock(1039, "", StdlibPillowTest.AsciiBytes("ICC!")), StdlibPillowTest.PsdLayerInfoBytes())

        images := []
        try {
            l := plugin.PsdImageFile(stdlib.io.BytesIO(lBytes))
            images.Push(l)
            AhkTest.AssertEqual("PSD", l.format)
            AhkTest.AssertEqual("Adobe Photoshop", l.format_description)
            AhkTest.AssertEqual("L", l.mode)
            AhkTest.AssertEqual([2, 2], l.size)
            AhkTest.AssertEqual([["raw", [0, 0, 2, 2], 40, "L"]], l.tile)
            AhkTest.AssertEqual([0, 127, 255, 1], l.getdata())
            AhkTest.AssertEqual(0, l.n_frames)
            AhkTest.AssertFalse(l.is_animated)
            AhkTest.AssertEqual(1, l.tell())
            AhkTest.AssertEqual(0, l.layers.Length)

            rgb := plugin.PsdImageFile(stdlib.io.BytesIO(rgbBytes))
            images.Push(rgb)
            AhkTest.AssertEqual("RGB", rgb.mode)
            AhkTest.AssertEqual([["raw", [0, 0, 2, 1], 40, "R"], ["raw", [0, 0, 2, 1], 42, "G"], ["raw", [0, 0, 2, 1], 44, "B"]], rgb.tile)
            AhkTest.AssertEqual([[10, 20, 30], [200, 10, 5]], rgb.getdata())

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(rgbBytes), "r", ["PSD"])
            images.Push(opened)
            AhkTest.AssertEqual("PSD", opened.format)
            AhkTest.AssertEqual("RGB", opened.mode)
            AhkTest.AssertEqual([[10, 20, 30], [200, 10, 5]], opened.getdata())

            rgba := plugin.PsdImageFile(stdlib.io.BytesIO(rgbaBytes))
            images.Push(rgba)
            AhkTest.AssertEqual("RGBA", rgba.mode)
            AhkTest.AssertEqual([["raw", [0, 0, 1, 1], 40, "R"], ["raw", [0, 0, 1, 1], 41, "G"], ["raw", [0, 0, 1, 1], 42, "B"], ["raw", [0, 0, 1, 1], 43, "A"]], rgba.tile)
            AhkTest.AssertEqual([[1, 2, 3, 4]], rgba.getdata())

            p := plugin.PsdImageFile(stdlib.io.BytesIO(pBytes))
            images.Push(p)
            AhkTest.AssertEqual("P", p.mode)
            AhkTest.AssertEqual([1, 2], p.getdata())
            AhkTest.AssertEqual([0, 255, 42, 1, 254, 42, 2, 253, 42, 3, 252, 42], StdlibPillowTest.ArraySlice(p.getpalette(), 1, 12))

            cmyk := plugin.PsdImageFile(stdlib.io.BytesIO(cmykBytes))
            images.Push(cmyk)
            AhkTest.AssertEqual("CMYK", cmyk.mode)
            AhkTest.AssertEqual([["raw", [0, 0, 1, 1], 40, "C;I"], ["raw", [0, 0, 1, 1], 41, "M;I"], ["raw", [0, 0, 1, 1], 42, "Y;I"], ["raw", [0, 0, 1, 1], 43, "K;I"]], cmyk.tile)
            AhkTest.AssertEqual([[254, 253, 252, 251]], cmyk.getdata())

            layered := plugin.PsdImageFile(stdlib.io.BytesIO(layeredBytes))
            images.Push(layered)
            AhkTest.AssertEqual("RGB", layered.mode)
            AhkTest.AssertEqual([2, 1], layered.size)
            AhkTest.AssertEqual([[100, 120, 140], [110, 130, 150]], layered.getdata())
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("ICC!"), layered.info["icc_profile"])
            AhkTest.AssertEqual([[1039, [], StdlibPillowTest.AsciiBytes("ICC!")]], layered.resources)
            AhkTest.AssertEqual(2, layered.n_frames)
            AhkTest.AssertTrue(layered.is_animated)
            AhkTest.AssertEqual(1, layered.tell())
            AhkTest.AssertEqual("Base", layered.layers[1][1])
            AhkTest.AssertEqual("RGB", layered.layers[1][2])
            AhkTest.AssertEqual([0, 0, 2, 1], layered.layers[1][3])
            AhkTest.AssertEqual([["raw", [0, 0, 2, 1], 142, "R"], ["raw", [0, 0, 2, 1], 146, "G"], ["raw", [0, 0, 2, 1], 150, "B"]], layered.layers[1][4])
            AhkTest.AssertEqual("Top", layered.layers[2][1])
            AhkTest.AssertEqual("RGBA", layered.layers[2][2])
            AhkTest.AssertEqual([0, 0, 1, 1], layered.layers[2][3])
            AhkTest.AssertEqual([["raw", [0, 0, 1, 1], 154, "R"], ["raw", [0, 0, 1, 1], 158, "G"], ["raw", [0, 0, 1, 1], 162, "B"], ["raw", [0, 0, 1, 1], 166, "A"]], layered.layers[2][4])
            AhkTest.AssertSame(stdlib.None, layered.seek(1))
            AhkTest.AssertEqual(1, layered.tell())
            AhkTest.AssertEqual("RGB", layered.mode)
            AhkTest.AssertEqual([["raw", [0, 0, 2, 1], 228, "R"], ["raw", [0, 0, 2, 1], 230, "G"], ["raw", [0, 0, 2, 1], 232, "B"]], layered.tile)
            AhkTest.AssertSame(stdlib.None, layered.seek(2))
            AhkTest.AssertEqual(2, layered.tell())
            AhkTest.AssertEqual("RGBA", layered.mode)
            AhkTest.AssertEqual([["raw", [0, 0, 1, 1], 154, "R"], ["raw", [0, 0, 1, 1], 158, "G"], ["raw", [0, 0, 1, 1], 162, "B"], ["raw", [0, 0, 1, 1], 166, "A"]], layered.tile)
            AhkTest.RaisesMatch(IndexError, "^list index out of range$", (*) => layered.seek(3))

            AhkTest.RaisesMatch(SyntaxError, "^not a PSD file$", (*) => plugin.PsdImageFile(stdlib.io.BytesIO(StdlibPillowTest.PsdBytes(1, 8, 1, 1, 1, [0], unset, unset, unset, 0, 1, "BAD!"))))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.PsdBytes(1, 8, 1, 1, 1, [0], unset, unset, unset, 0, 1, "BAD!")), "r", ["PSD"]))
            AhkTest.RaisesMatch(SyntaxError, "^not a PSD file$", (*) => plugin.PsdImageFile(stdlib.io.BytesIO(StdlibPillowTest.PsdBytes(1, 8, 1, 1, 1, [0], unset, unset, unset, 0, 2))))
            AhkTest.RaisesMatch(OSError, "^not enough channels$", (*) => plugin.PsdImageFile(stdlib.io.BytesIO(StdlibPillowTest.PsdBytes(3, 8, 2, 1, 1, [1, 2]))))
            AhkTest.RaisesMatch(SyntaxError, "^\(6, 8\)$", (*) => plugin.PsdImageFile(stdlib.io.BytesIO(StdlibPillowTest.PsdBytes(6, 8, 1, 1, 1, [0]))))
            shortLayer := StdlibPillowTest.PsdBytes(3, 8, 3, 1, 1, [1, 2, 3], unset, unset, StdlibPillowTest.PsdS16(2))
            AhkTest.RaisesMatch(SyntaxError, "^Layer block too short for number of layers requested$", (*) => plugin.PsdImageFile(stdlib.io.BytesIO(shortLayer)).layers)
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.PsdImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.PsdImageFile(stdlib.io.BytesIO(lBytes), "x", "y"))
        } finally {
            for image in images
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestQoiImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "QoiImagePlugin"))
        plugin := stdlib.pillow.QoiImagePlugin

        AhkTest.AssertEqual("QOI", plugin.QoiImageFile.format)
        AhkTest.AssertEqual("Quite OK Image", plugin.QoiImageFile.format_description)
        AhkTest.AssertTrue(plugin.QoiDecoder("RGB")._pulls_fd)
        AhkTest.AssertTrue(plugin.QoiEncoder("RGB")._pushes_fd)
        encoder := plugin.QoiEncoder("RGB")
        AhkTest.AssertEqual([255], encoder._write_run())
        AhkTest.AssertEqual(2, encoder._delta(1, 255))
        AhkTest.AssertFalse(plugin._accept([]))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("qoi")))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("qoif")))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("qoifrest")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("nope")))
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("QOI"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("QOI"))
        AhkTest.AssertFalse(stdlib.pillow.Image.SAVE_ALL.Has("QOI"))
        AhkTest.AssertTrue(stdlib.pillow.Image.DECODERS.Has("qoi"))
        AhkTest.AssertTrue(stdlib.pillow.Image.ENCODERS.Has("qoi"))
        AhkTest.AssertEqual("QOI", stdlib.pillow.Image.registered_extensions()[".qoi"])
        AhkTest.AssertFalse(stdlib.pillow.Image.registered_extensions().Has(".qoif"))
        AhkTest.AssertFalse(stdlib.pillow.Image.MIME.Has("QOI"))
        AhkTest.AssertTrue(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "QOI"))

        rgbBytes := StdlibPillowTest.QoiBytes(5, 1, 3, [0xFE, 10, 20, 30, 0x7A, 0xA5, 0xC3, 0xC0, 0x09])
        rgbaBytes := StdlibPillowTest.QoiBytes(3, 1, 4, [0xFF, 1, 2, 3, 4, 0xC0, 0xFE, 9, 8, 7])
        rgbPixels := [[10, 20, 30], [11, 20, 30], [20, 25, 30], [20, 25, 30], [10, 20, 30]]
        rgbaPixels := [[1, 2, 3, 4], [1, 2, 3, 4], [9, 8, 7, 4]]

        images := []
        try {
            rgb := plugin.QoiImageFile(stdlib.io.BytesIO(rgbBytes))
            images.Push(rgb)
            AhkTest.AssertEqual("QOI", rgb.format)
            AhkTest.AssertEqual("Quite OK Image", rgb.format_description)
            AhkTest.AssertEqual("RGB", rgb.mode)
            AhkTest.AssertEqual([5, 1], rgb.size)
            AhkTest.AssertEqual([["qoi", [0, 0, 5, 1], 14]], rgb.tile)
            AhkTest.AssertEqual(rgbPixels, rgb.getdata())

            openedRgb := stdlib.pillow.Image.open(stdlib.io.BytesIO(rgbBytes), "r", ["QOI"])
            images.Push(openedRgb)
            AhkTest.AssertEqual("QOI", openedRgb.format)
            AhkTest.AssertEqual(rgbPixels, openedRgb.getdata())

            rgba := plugin.QoiImageFile(stdlib.io.BytesIO(rgbaBytes))
            images.Push(rgba)
            AhkTest.AssertEqual("RGBA", rgba.mode)
            AhkTest.AssertEqual([3, 1], rgba.size)
            AhkTest.AssertEqual([["qoi", [0, 0, 3, 1], 14]], rgba.tile)
            AhkTest.AssertEqual(rgbaPixels, rgba.getdata())

            rgbSource := stdlib.pillow.Image.new("RGB", [5, 1])
            images.Push(rgbSource)
            rgbSource.putdata(rgbPixels)
            rgbOut := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, rgbSource.save(rgbOut, "QOI"))
            AhkTest.AssertEqual(rgbBytes, rgbOut.getvalue())

            srgbSource := stdlib.pillow.Image.new("RGB", [2, 1])
            images.Push(srgbSource)
            srgbSource.putdata([[1, 2, 3], [1, 2, 3]])
            srgbOut := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, srgbSource.save(srgbOut, "QOI", { colorspace: "sRGB" }))
            AhkTest.AssertEqual([113, 111, 105, 102, 0, 0, 0, 2, 0, 0, 0, 1, 3, 0], StdlibPillowTest.ArraySlice(srgbOut.getvalue(), 1, 14))

            rgbaSource := stdlib.pillow.Image.new("RGBA", [3, 1])
            images.Push(rgbaSource)
            rgbaSource.putdata(rgbaPixels)
            rgbaOut := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, rgbaSource.save(rgbaOut, "QOI"))
            AhkTest.AssertEqual(StdlibPillowTest.QoiBytes(3, 1, 4, [0xFF, 1, 2, 3, 4, 0xC0, 0xA6, 0xA6]), rgbaOut.getvalue())

            AhkTest.RaisesMatch(SyntaxError, "^not a QOI file$", (*) => plugin.QoiImageFile(stdlib.io.BytesIO(StdlibPillowTest.ConcatBytes(StdlibPillowTest.AsciiBytes("BAD!"), StdlibPillowTest.ArraySlice(rgbBytes, 5, rgbBytes.Length)))))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.ConcatBytes(StdlibPillowTest.AsciiBytes("BAD!"), StdlibPillowTest.ArraySlice(rgbBytes, 5, rgbBytes.Length))), "r", ["QOI"]))
            AhkTest.RaisesMatch(ValueError, "^Unsupported QOI image mode$", (*) => stdlib.pillow.Image.new("L", [1, 1]).save(stdlib.io.BytesIO(), "QOI"))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.QoiImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.QoiImageFile(stdlib.io.BytesIO(rgbBytes), "x", "y"))
            AhkTest.RaisesMatch(TypeError, "^_save\(\) missing 3 required positional arguments: 'im', 'fp', and 'filename'$", (*) => plugin._save())
        } finally {
            for image in images
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestSgiImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "SgiImagePlugin"))
        plugin := stdlib.pillow.SgiImagePlugin

        AhkTest.AssertEqual("L", plugin.MODES["1,1,1"])
        AhkTest.AssertEqual("L", plugin.MODES["1,2,1"])
        AhkTest.AssertEqual("L;16B", plugin.MODES["2,1,1"])
        AhkTest.AssertEqual("L;16B", plugin.MODES["2,2,1"])
        AhkTest.AssertEqual("RGB", plugin.MODES["1,3,3"])
        AhkTest.AssertEqual("RGB;16B", plugin.MODES["2,3,3"])
        AhkTest.AssertEqual("RGBA", plugin.MODES["1,3,4"])
        AhkTest.AssertEqual("RGBA;16B", plugin.MODES["2,3,4"])
        AhkTest.AssertEqual(474, plugin.i16([0x01, 0xDA]))
        AhkTest.AssertEqual(474, plugin.i16([0, 0x01, 0xDA], 1))
        AhkTest.AssertEqual([255], plugin.o8(-1))
        AhkTest.AssertFalse(plugin._accept([]))
        AhkTest.AssertFalse(plugin._accept([0x01]))
        AhkTest.AssertTrue(plugin._accept([0x01, 0xDA]))
        AhkTest.AssertFalse(plugin._accept([0, 0]))
        AhkTest.AssertEqual("SGI", plugin.SgiImageFile.format)
        AhkTest.AssertEqual("SGI Image File Format", plugin.SgiImageFile.format_description)
        AhkTest.AssertTrue(plugin.SGI16Decoder("L")._pulls_fd)
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("SGI"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("SGI"))
        AhkTest.AssertFalse(stdlib.pillow.Image.SAVE_ALL.Has("SGI"))
        AhkTest.AssertTrue(stdlib.pillow.Image.DECODERS.Has("SGI16"))
        AhkTest.AssertFalse(stdlib.pillow.Image.DECODERS.Has("sgi_rle"))
        for extension in [".bw", ".rgb", ".rgba", ".sgi"]
            AhkTest.AssertEqual("SGI", stdlib.pillow.Image.registered_extensions()[extension])
        AhkTest.AssertEqual("image/sgi", stdlib.pillow.Image.MIME["SGI"])
        AhkTest.AssertTrue(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "SGI"))

        lBytes := StdlibPillowTest.SgiRawBytes(2, 2, 1, [[255, 1, 0, 127]], 1, 2)
        rgbBytes := StdlibPillowTest.SgiRawBytes(2, 2, 3, [[40, 1, 10, 200], [50, 2, 20, 10], [60, 3, 30, 5]])
        rgbaBytes := StdlibPillowTest.SgiRawBytes(1, 2, 4, [[9, 1], [8, 2], [7, 3], [6, 4]])
        l16Bytes := StdlibPillowTest.SgiRawBytes(2, 1, 1, [[0x12, 0x34, 0xAB, 0xCD]], 2, 1)
        rgb16Bytes := StdlibPillowTest.SgiRawBytes(1, 1, 3, [[0, 1], [0, 2], [0, 3]], 2)
        rleBytes := StdlibPillowTest.SgiRleBytes(2, 2, 1, [[255, 1], [0, 127]], 1, 2)
        rgbPixels := [[10, 20, 30], [200, 10, 5], [40, 50, 60], [1, 2, 3]]
        rgbaPixels := [[1, 2, 3, 4], [9, 8, 7, 6]]

        images := []
        try {
            l := plugin.SgiImageFile(stdlib.io.BytesIO(lBytes))
            images.Push(l)
            AhkTest.AssertEqual("SGI", l.format)
            AhkTest.AssertEqual("SGI Image File Format", l.format_description)
            AhkTest.AssertEqual("L", l.mode)
            AhkTest.AssertEqual([2, 2], l.size)
            AhkTest.AssertEqual([["raw", [0, 0, 2, 2], 512, ["L", 0, -1]]], l.tile)
            AhkTest.AssertEqual([0, 127, 255, 1], l.getdata())

            rgb := plugin.SgiImageFile(stdlib.io.BytesIO(rgbBytes))
            images.Push(rgb)
            AhkTest.AssertEqual("RGB", rgb.mode)
            AhkTest.AssertEqual("image/rgb", rgb.custom_mimetype)
            AhkTest.AssertEqual([["raw", [0, 0, 2, 2], 512, ["R", 0, -1]], ["raw", [0, 0, 2, 2], 516, ["G", 0, -1]], ["raw", [0, 0, 2, 2], 520, ["B", 0, -1]]], rgb.tile)
            AhkTest.AssertEqual(rgbPixels, rgb.getdata())

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(rgbBytes), "r", ["SGI"])
            images.Push(opened)
            AhkTest.AssertEqual("SGI", opened.format)
            AhkTest.AssertEqual(rgbPixels, opened.getdata())

            rgba := plugin.SgiImageFile(stdlib.io.BytesIO(rgbaBytes))
            images.Push(rgba)
            AhkTest.AssertEqual("RGBA", rgba.mode)
            AhkTest.AssertEqual([["raw", [0, 0, 1, 2], 512, ["R", 0, -1]], ["raw", [0, 0, 1, 2], 514, ["G", 0, -1]], ["raw", [0, 0, 1, 2], 516, ["B", 0, -1]], ["raw", [0, 0, 1, 2], 518, ["A", 0, -1]]], rgba.tile)
            AhkTest.AssertEqual(rgbaPixels, rgba.getdata())

            l16 := plugin.SgiImageFile(stdlib.io.BytesIO(l16Bytes))
            images.Push(l16)
            AhkTest.AssertEqual("L", l16.mode)
            AhkTest.AssertEqual([["SGI16", [0, 0, 2, 1], 512, ["L", 0, -1]]], l16.tile)
            AhkTest.AssertEqual([0x12, 0xAB], l16.getdata())

            rgb16 := plugin.SgiImageFile(stdlib.io.BytesIO(rgb16Bytes))
            images.Push(rgb16)
            AhkTest.AssertEqual("RGB", rgb16.mode)
            AhkTest.AssertEqual([["SGI16", [0, 0, 1, 1], 512, ["RGB", 0, -1]]], rgb16.tile)
            AhkTest.AssertEqual([[0, 0, 0]], rgb16.getdata())

            rle := plugin.SgiImageFile(stdlib.io.BytesIO(rleBytes))
            images.Push(rle)
            AhkTest.AssertEqual("L", rle.mode)
            AhkTest.AssertEqual([["sgi_rle", [0, 0, 2, 2], 512, ["L", -1, 1]]], rle.tile)
            AhkTest.AssertEqual([0, 127, 255, 1], rle.getdata())

            lSource := stdlib.pillow.Image.new("L", [2, 2])
            images.Push(lSource)
            lSource.putdata([0, 127, 255, 1])
            lOut := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, lSource.save(lOut, "SGI"))
            AhkTest.AssertEqual([255, 1, 0, 127], StdlibPillowTest.ArraySlice(lOut.getvalue(), 513, 516))
            lOpened := stdlib.pillow.Image.open(stdlib.io.BytesIO(lOut.getvalue()), "r", ["SGI"])
            images.Push(lOpened)
            AhkTest.AssertEqual([0, 127, 255, 1], lOpened.getdata())

            rgbSource := stdlib.pillow.Image.new("RGB", [2, 2])
            images.Push(rgbSource)
            rgbSource.putdata(rgbPixels)
            rgbOut := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, rgbSource.save(rgbOut, "SGI"))
            AhkTest.AssertEqual([40, 1, 10, 200, 50, 2, 20, 10, 60, 3, 30, 5], StdlibPillowTest.ArraySlice(rgbOut.getvalue(), 513, 524))

            rgbaSource := stdlib.pillow.Image.new("RGBA", [1, 2])
            images.Push(rgbaSource)
            rgbaSource.putdata(rgbaPixels)
            rgbaOut := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, plugin._save(rgbaSource, rgbaOut, "demo.rgba"))
            AhkTest.AssertEqual([9, 1, 8, 2, 7, 3, 6, 4], StdlibPillowTest.ArraySlice(rgbaOut.getvalue(), 513, 520))

            l16Source := stdlib.pillow.Image.new("L", [2, 1])
            images.Push(l16Source)
            l16Source.putdata([0x12, 0xAB])
            l16Out := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, l16Source.save(l16Out, "SGI", { bpc: 2 }))
            AhkTest.AssertEqual([0x12, 0, 0xAB, 0], StdlibPillowTest.ArraySlice(l16Out.getvalue(), 513, 516))

            AhkTest.RaisesMatch(ValueError, "^Not an SGI image file$", (*) => plugin.SgiImageFile(stdlib.io.BytesIO(StdlibPillowTest.ConcatBytes([0, 0], StdlibPillowTest.ArraySlice(lBytes, 3, lBytes.Length)))))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.ConcatBytes([0, 0], StdlibPillowTest.ArraySlice(lBytes, 3, lBytes.Length))), "r", ["SGI"]))
            AhkTest.RaisesMatch(ValueError, "^Unsupported SGI image mode$", (*) => plugin.SgiImageFile(stdlib.io.BytesIO(StdlibPillowTest.SgiRawBytes(1, 1, 2, [[0], [0]], 1, 3))))
            AhkTest.RaisesMatch(ValueError, "^Unsupported SGI image mode$", (*) => stdlib.pillow.Image.new("P", [1, 1]).save(stdlib.io.BytesIO(), "SGI"))
            AhkTest.RaisesMatch(ValueError, "^Unsupported number of bytes per pixel$", (*) => stdlib.pillow.Image.new("L", [1, 1]).save(stdlib.io.BytesIO(), "SGI", { bpc: 3 }))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.SgiImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.SgiImageFile(stdlib.io.BytesIO(lBytes), "x", "y"))
            AhkTest.RaisesMatch(TypeError, "^_save\(\) missing 3 required positional arguments: 'im', 'fp', and 'filename'$", (*) => plugin._save())
        } finally {
            for image in images
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestSpiderImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "SpiderImagePlugin"))
        plugin := stdlib.pillow.SpiderImagePlugin

        AhkTest.AssertEqual("SPIDER", plugin.SpiderImageFile.format)
        AhkTest.AssertEqual("Spider 2D image", plugin.SpiderImageFile.format_description)
        AhkTest.AssertEqual([1, 3, -11, -12, -21, -22], plugin.iforms)
        AhkTest.AssertEqual(1, plugin.isInt(1.0))
        AhkTest.AssertEqual(0, plugin.isInt(1.5))
        AhkTest.AssertEqual(0, plugin.isInt("x"))
        AhkTest.AssertEqual(1024, plugin.isSpiderHeader(StdlibPillowTest.SpiderHeaderValues()))
        AhkTest.AssertEqual(0, plugin.isSpiderHeader([0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5]))
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("SPIDER"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("SPIDER"))
        AhkTest.AssertFalse(stdlib.pillow.Image.SAVE_ALL.Has("SPIDER"))
        AhkTest.AssertFalse(stdlib.pillow.Image.MIME.Has("SPIDER"))
        AhkTest.AssertFalse(stdlib.pillow.Image.registered_extensions().Has(".spi"))
        AhkTest.AssertFalse(stdlib.pillow.Image.registered_extensions().Has(".spider"))
        AhkTest.AssertTrue(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "SPIDER"))

        littleBytes := StdlibPillowTest.SpiderImageBytes()
        bigBytes := StdlibPillowTest.SpiderImageBytes(2, 2, [0.0, 1.0, 2.5, 5.0], false)
        stackBytes := StdlibPillowTest.SpiderStackBytes()
        validPath := StdlibPillowTest.TempPath("spider-valid.spi")
        invalidPath := StdlibPillowTest.TempPath("spider-invalid.spi")
        savedPath := StdlibPillowTest.TempPath("spider-saved.spi")
        StdlibPillowTest.WriteBytes(validPath, littleBytes)
        StdlibPillowTest.WriteBytes(invalidPath, [98, 97, 100])

        images := []
        try {
            little := plugin.SpiderImageFile(stdlib.io.BytesIO(littleBytes))
            images.Push(little)
            AhkTest.AssertEqual("SPIDER", little.format)
            AhkTest.AssertEqual("Spider 2D image", little.format_description)
            AhkTest.AssertEqual("F", little.mode)
            AhkTest.AssertEqual([2, 2], little.size)
            AhkTest.AssertEqual("F;32F", little.rawmode)
            AhkTest.AssertEqual(0, little.bigendian)
            AhkTest.AssertEqual(0, little.istack)
            AhkTest.AssertEqual(0, little.imgnumber)
            AhkTest.AssertEqual(1, little.n_frames)
            AhkTest.AssertFalse(little.is_animated)
            AhkTest.AssertEqual(0, little.tell())
            AhkTest.AssertEqual([0.0, 1.0, 2.5, 5.0], little.getdata())
            AhkTest.AssertEqual([0.0, 5.0], little.getextrema())

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(littleBytes), "r", ["SPIDER"])
            images.Push(opened)
            AhkTest.AssertEqual("SPIDER", opened.format)
            AhkTest.AssertEqual("F;32F", opened.rawmode)
            AhkTest.AssertEqual([0.0, 1.0, 2.5, 5.0], opened.getdata())

            big := plugin.SpiderImageFile(stdlib.io.BytesIO(bigBytes))
            images.Push(big)
            AhkTest.AssertEqual("F;32BF", big.rawmode)
            AhkTest.AssertEqual(1, big.bigendian)
            AhkTest.AssertEqual([0.0, 1.0, 2.5, 5.0], big.getdata())

            stack := plugin.SpiderImageFile(stdlib.io.BytesIO(stackBytes))
            images.Push(stack)
            AhkTest.AssertEqual(2, stack.n_frames)
            AhkTest.AssertTrue(stack.is_animated)
            AhkTest.AssertEqual(1, stack.istack)
            AhkTest.AssertEqual(1, stack.imgnumber)
            AhkTest.AssertEqual(0, stack.tell())
            AhkTest.AssertEqual([1.0, 2.0, 3.0, 4.0], stack.getdata())
            AhkTest.AssertSame(stdlib.None, stack.seek(1))
            AhkTest.AssertEqual(2, stack.istack)
            AhkTest.AssertEqual(2, stack.imgnumber)
            AhkTest.AssertEqual(1, stack.tell())
            AhkTest.AssertEqual([10.0, 20.0, 30.0, 40.0], stack.getdata())
            AhkTest.RaisesMatch(EOFError, "^attempt to seek outside sequence$", (*) => stack.seek(2))
            AhkTest.RaisesMatch(EOFError, "^attempt to seek in a non-stack file$", (*) => little.seek(1))

            byteImage := little.convert2byte(200)
            images.Push(byteImage)
            AhkTest.AssertEqual("L", byteImage.mode)
            AhkTest.AssertEqual([0, 40, 100, 200], byteImage.getdata())

            headerParts := plugin.makeSpiderHeader(little)
            AhkTest.AssertEqual(256, headerParts.Length)
            AhkTest.AssertEqual([0, 0, 128, 63], headerParts[1])
            AhkTest.AssertEqual([0, 0, 0, 64], headerParts[2])
            AhkTest.AssertEqual([0, 0, 0, 64], headerParts[3])
            AhkTest.AssertEqual([0, 0, 0, 0], headerParts[4])

            source := stdlib.pillow.Image.new("F", [2, 2])
            images.Push(source)
            source.putdata([0.0, 1.0, 2.5, 5.0])
            out := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, source.save(out, "SPIDER"))
            AhkTest.AssertEqual(1040, out.getvalue().Length)
            saved := stdlib.pillow.Image.open(stdlib.io.BytesIO(out.getvalue()), "r", ["SPIDER"])
            images.Push(saved)
            AhkTest.AssertEqual([0.0, 1.0, 2.5, 5.0], saved.getdata())

            AhkTest.AssertEqual(1024, plugin.isSpiderImage(validPath))
            source.save(savedPath, "SPIDER")
            AhkTest.AssertEqual("SPIDER", stdlib.pillow.Image.registered_extensions()[".spi"])
            AhkTest.AssertEqual(1024, plugin.isSpiderImage(savedPath))

            AhkTest.AssertSame(stdlib.None, plugin.loadImageSeries())
            AhkTest.AssertSame(stdlib.None, plugin.loadImageSeries([]))

            AhkTest.RaisesMatch(SyntaxError, "^not a valid Spider file$", (*) => plugin.SpiderImageFile(stdlib.io.BytesIO([98, 97, 100])))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO([98, 97, 100]), "r", ["SPIDER"]))
            AhkTest.RaisesMatch(SyntaxError, "^not a Spider 2D image$", (*) => plugin.SpiderImageFile(stdlib.io.BytesIO(StdlibPillowTest.SpiderImageBytes(2, 2, [0.0, 1.0, 2.5, 5.0], true, 3))))
            AhkTest.RaisesMatch(SyntaxError, "^inconsistent stack header values$", (*) => plugin.SpiderImageFile(stdlib.io.BytesIO(StdlibPillowTest.SpiderImageBytes(2, 2, [0.0, 1.0, 2.5, 5.0], true, 1, 1, 1, 1))))
            AhkTest.RaisesMatch(Error, "^unpack requires a buffer of 92 bytes$", (*) => plugin.isSpiderImage(invalidPath))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.SpiderImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.SpiderImageFile(stdlib.io.BytesIO(littleBytes), "x", "y"))
            AhkTest.RaisesMatch(TypeError, "^_save\(\) missing 3 required positional arguments: 'im', 'fp', and 'filename'$", (*) => plugin._save())
        } finally {
            for image in images
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestSunImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "SunImagePlugin"))
        plugin := stdlib.pillow.SunImagePlugin

        AhkTest.AssertTrue(plugin._accept([0x59, 0xA6, 0x6A, 0x95]))
        AhkTest.AssertFalse(plugin._accept([0x59, 0xA6, 0x6A]))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("bad!")))
        AhkTest.AssertEqual("SUN", plugin.SunImageFile.format)
        AhkTest.AssertEqual("Sun Raster File", plugin.SunImageFile.format_description)
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("SUN"))
        AhkTest.AssertEqual("SUN", stdlib.pillow.Image.registered_extensions()[".ras"])
        AhkTest.AssertFalse(stdlib.pillow.Image.SAVE.Has("SUN"))
        AhkTest.AssertFalse(stdlib.pillow.Image.MIME.Has("SUN"))
        AhkTest.AssertTrue(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "SUN"))

        oneBitBytes := StdlibPillowTest.SunBytes(2, 2, 1, [128, 0, 64, 0])
        fourBitBytes := StdlibPillowTest.SunBytes(3, 1, 4, [0x12, 0x30])
        lBytes := StdlibPillowTest.SunBytes(3, 2, 8, [1, 2, 3, 0, 4, 5, 6, 0])
        rgbBgrBytes := StdlibPillowTest.SunBytes(2, 1, 24, [30, 20, 10, 5, 10, 200, 0, 0])
        rgbRgbBytes := StdlibPillowTest.SunBytes(2, 1, 24, [10, 20, 30, 200, 10, 5, 0, 0], 3)
        rgbBgrxBytes := StdlibPillowTest.SunBytes(1, 1, 32, [30, 20, 10, 99])
        rgbRgbxBytes := StdlibPillowTest.SunBytes(1, 1, 32, [10, 20, 30, 99], 3)
        paletteBytes := StdlibPillowTest.SunBytes(2, 1, 8, [0, 1], 1, 1, [10, 200, 20, 210, 30, 220])
        rleBytes := StdlibPillowTest.SunBytes(3, 1, 8, [7, 0x80, 1, 8], 2)

        images := []
        try {
            oneBit := plugin.SunImageFile(stdlib.io.BytesIO(oneBitBytes))
            images.Push(oneBit)
            AhkTest.AssertEqual("SUN", oneBit.format)
            AhkTest.AssertEqual("Sun Raster File", oneBit.format_description)
            AhkTest.AssertEqual("1", oneBit.mode)
            AhkTest.AssertEqual([2, 2], oneBit.size)
            AhkTest.AssertEqual([["raw", [0, 0, 2, 2], 32, ["1;I", 2]]], oneBit.tile)
            AhkTest.AssertEqual([0, 255, 255, 0], oneBit.getdata())

            fourBit := plugin.SunImageFile(stdlib.io.BytesIO(fourBitBytes))
            images.Push(fourBit)
            AhkTest.AssertEqual("L", fourBit.mode)
            AhkTest.AssertEqual([["raw", [0, 0, 3, 1], 32, ["L;4", 2]]], fourBit.tile)
            AhkTest.AssertEqual([17, 34, 51], fourBit.getdata())

            gray := plugin.SunImageFile(stdlib.io.BytesIO(lBytes))
            images.Push(gray)
            AhkTest.AssertEqual("L", gray.mode)
            AhkTest.AssertEqual([3, 2], gray.size)
            AhkTest.AssertEqual([["raw", [0, 0, 3, 2], 32, ["L", 4]]], gray.tile)
            AhkTest.AssertEqual([1, 2, 3, 4, 5, 6], gray.getdata())

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(lBytes), "r", ["SUN"])
            images.Push(opened)
            AhkTest.AssertEqual("SUN", opened.format)
            AhkTest.AssertEqual([1, 2, 3, 4, 5, 6], opened.getdata())

            rgbBgr := plugin.SunImageFile(stdlib.io.BytesIO(rgbBgrBytes))
            images.Push(rgbBgr)
            AhkTest.AssertEqual("RGB", rgbBgr.mode)
            AhkTest.AssertEqual([["raw", [0, 0, 2, 1], 32, ["BGR", 6]]], rgbBgr.tile)
            AhkTest.AssertEqual([[10, 20, 30], [200, 10, 5]], rgbBgr.getdata())

            rgbRgb := plugin.SunImageFile(stdlib.io.BytesIO(rgbRgbBytes))
            images.Push(rgbRgb)
            AhkTest.AssertEqual([["raw", [0, 0, 2, 1], 32, ["RGB", 6]]], rgbRgb.tile)
            AhkTest.AssertEqual([[10, 20, 30], [200, 10, 5]], rgbRgb.getdata())

            rgbBgrx := plugin.SunImageFile(stdlib.io.BytesIO(rgbBgrxBytes))
            images.Push(rgbBgrx)
            AhkTest.AssertEqual([["raw", [0, 0, 1, 1], 32, ["BGRX", 4]]], rgbBgrx.tile)
            AhkTest.AssertEqual([[10, 20, 30]], rgbBgrx.getdata())

            rgbRgbx := plugin.SunImageFile(stdlib.io.BytesIO(rgbRgbxBytes))
            images.Push(rgbRgbx)
            AhkTest.AssertEqual([["raw", [0, 0, 1, 1], 32, ["RGBX", 4]]], rgbRgbx.tile)
            AhkTest.AssertEqual([[10, 20, 30]], rgbRgbx.getdata())

            pal := plugin.SunImageFile(stdlib.io.BytesIO(paletteBytes))
            images.Push(pal)
            AhkTest.AssertEqual("P", pal.mode)
            AhkTest.AssertEqual([["raw", [0, 0, 2, 1], 38, ["P", 2]]], pal.tile)
            AhkTest.AssertEqual([0, 1], pal.getdata())
            AhkTest.AssertEqual([10, 20, 30, 200, 210, 220], StdlibPillowTest.ArraySlice(pal.getpalette(), 1, 6))

            rle := plugin.SunImageFile(stdlib.io.BytesIO(rleBytes))
            images.Push(rle)
            AhkTest.AssertEqual("L", rle.mode)
            AhkTest.AssertEqual([["sun_rle", [0, 0, 3, 1], 32, "L"]], rle.tile)
            AhkTest.AssertEqual([7, 8, 8], rle.getdata())

            AhkTest.RaisesMatch(SyntaxError, "^not an SUN raster file$", (*) => plugin.SunImageFile(stdlib.io.BytesIO(StdlibPillowTest.SunBytes(1, 1, 8, [0, 0], 1, 0, [], 1))))
            AhkTest.RaisesMatch(SyntaxError, "^Unsupported Mode/Bit Depth$", (*) => plugin.SunImageFile(stdlib.io.BytesIO(StdlibPillowTest.SunBytes(1, 1, 2, [0, 0]))))
            AhkTest.RaisesMatch(SyntaxError, "^Unsupported Color Palette Length$", (*) => plugin.SunImageFile(stdlib.io.BytesIO(StdlibPillowTest.SunBytes(1, 1, 8, [0, 0], 1, 1, StdlibPillowTest.ZeroBytes(1025)))))
            AhkTest.RaisesMatch(SyntaxError, "^Unsupported Palette Type$", (*) => plugin.SunImageFile(stdlib.io.BytesIO(StdlibPillowTest.SunBytes(1, 1, 8, [0, 0], 1, 2, [0, 0, 0, 0, 0, 0]))))
            AhkTest.RaisesMatch(SyntaxError, "^Unsupported Sun Raster file type$", (*) => plugin.SunImageFile(stdlib.io.BytesIO(StdlibPillowTest.SunBytes(1, 1, 8, [0, 0], 9))))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.SunBytes(1, 1, 8, [0, 0], 1, 0, [], 1)), "r", ["SUN"]))
            AhkTest.RaisesMatch(KeyError, "^'SUN'$", (*) => stdlib.pillow.Image.new("L", [1, 1]).save(stdlib.io.BytesIO(), "SUN"))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.SunImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.SunImageFile(stdlib.io.BytesIO(lBytes), "x", "y"))
        } finally {
            for image in images
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestTgaImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "TgaImagePlugin"))
        plugin := stdlib.pillow.TgaImagePlugin

        AhkTest.AssertEqual("P", plugin.MODES["1,8"])
        AhkTest.AssertEqual("1", plugin.MODES["3,1"])
        AhkTest.AssertEqual("L", plugin.MODES["3,8"])
        AhkTest.AssertEqual("LA", plugin.MODES["3,16"])
        AhkTest.AssertEqual("BGRA;15Z", plugin.MODES["2,16"])
        AhkTest.AssertEqual("BGR", plugin.MODES["2,24"])
        AhkTest.AssertEqual("BGRA", plugin.MODES["2,32"])
        AhkTest.AssertEqual(["1", 1, 0, 3], plugin.SAVE["1"])
        AhkTest.AssertEqual(["L", 8, 0, 3], plugin.SAVE["L"])
        AhkTest.AssertEqual(["LA", 16, 0, 3], plugin.SAVE["LA"])
        AhkTest.AssertEqual(["P", 8, 1, 1], plugin.SAVE["P"])
        AhkTest.AssertEqual(["BGR", 24, 0, 2], plugin.SAVE["RGB"])
        AhkTest.AssertEqual(["BGRA", 32, 0, 2], plugin.SAVE["RGBA"])
        AhkTest.AssertEqual("TGA", plugin.TgaImageFile.format)
        AhkTest.AssertEqual("Targa", plugin.TgaImageFile.format_description)
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("TGA"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("TGA"))
        for extension in [".tga", ".icb", ".vda", ".vst"]
            AhkTest.AssertEqual("TGA", stdlib.pillow.Image.registered_extensions()[extension])
        AhkTest.AssertEqual("image/x-tga", stdlib.pillow.Image.MIME["TGA"])
        AhkTest.AssertTrue(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "TGA"))

        lBytes := StdlibPillowTest.TgaBytes(3, 1, 8, [1, 2, 3], 3)
        lBottomBytes := StdlibPillowTest.TgaBytes(2, 2, 8, [3, 4, 1, 2], 3, 0)
        oneBytes := StdlibPillowTest.TgaBytes(8, 1, 1, [170], 3)
        laBytes := StdlibPillowTest.TgaBytes(2, 1, 16, [7, 200, 9, 100], 3, 0x28)
        rgbBytes := StdlibPillowTest.TgaBytes(2, 1, 24, [30, 20, 10, 5, 10, 200], 2)
        rgbaBytes := StdlibPillowTest.TgaBytes(1, 1, 32, [30, 20, 10, 99], 2, 0x28)
        paletteBytes := StdlibPillowTest.TgaBytes(2, 1, 8, [0, 1], 1, 0x20, [], [30, 20, 10, 5, 10, 200], 24)
        rleLBytes := StdlibPillowTest.TgaBytes(3, 1, 8, [0x82, 7], 11)
        rleRgbBytes := StdlibPillowTest.TgaBytes(3, 1, 24, [0x81, 30, 20, 10, 0, 5, 10, 200], 10)
        idBytes := StdlibPillowTest.TgaBytes(1, 1, 8, [42], 3, 0x20, StdlibPillowTest.AsciiBytes("abc"))

        images := []
        try {
            gray := plugin.TgaImageFile(stdlib.io.BytesIO(lBytes))
            images.Push(gray)
            AhkTest.AssertEqual("TGA", gray.format)
            AhkTest.AssertEqual("Targa", gray.format_description)
            AhkTest.AssertEqual("L", gray.mode)
            AhkTest.AssertEqual([3, 1], gray.size)
            AhkTest.AssertEqual(1, gray.info["orientation"])
            AhkTest.AssertEqual([["raw", [0, 0, 3, 1], 18, ["L", 0, 1]]], gray.tile)
            AhkTest.AssertEqual([1, 2, 3], gray.getdata())

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(lBytes), "r", ["TGA"])
            images.Push(opened)
            AhkTest.AssertEqual("TGA", opened.format)
            AhkTest.AssertEqual([1, 2, 3], opened.getdata())

            bottom := plugin.TgaImageFile(stdlib.io.BytesIO(lBottomBytes))
            images.Push(bottom)
            AhkTest.AssertEqual(-1, bottom.info["orientation"])
            AhkTest.AssertEqual([["raw", [0, 0, 2, 2], 18, ["L", 0, -1]]], bottom.tile)
            AhkTest.AssertEqual([1, 2, 3, 4], bottom.getdata())

            one := plugin.TgaImageFile(stdlib.io.BytesIO(oneBytes))
            images.Push(one)
            AhkTest.AssertEqual("1", one.mode)
            AhkTest.AssertEqual([255, 0, 255, 0, 255, 0, 255, 0], one.getdata())

            la := plugin.TgaImageFile(stdlib.io.BytesIO(laBytes))
            images.Push(la)
            AhkTest.AssertEqual("LA", la.mode)
            AhkTest.AssertEqual([[7, 200], [9, 100]], la.getdata())

            rgb := plugin.TgaImageFile(stdlib.io.BytesIO(rgbBytes))
            images.Push(rgb)
            AhkTest.AssertEqual("RGB", rgb.mode)
            AhkTest.AssertEqual([["raw", [0, 0, 2, 1], 18, ["BGR", 0, 1]]], rgb.tile)
            AhkTest.AssertEqual([[10, 20, 30], [200, 10, 5]], rgb.getdata())

            rgba := plugin.TgaImageFile(stdlib.io.BytesIO(rgbaBytes))
            images.Push(rgba)
            AhkTest.AssertEqual("RGBA", rgba.mode)
            AhkTest.AssertEqual([[10, 20, 30, 99]], rgba.getdata())

            pal := plugin.TgaImageFile(stdlib.io.BytesIO(paletteBytes))
            images.Push(pal)
            AhkTest.AssertEqual("P", pal.mode)
            AhkTest.AssertEqual([["raw", [0, 0, 2, 1], 24, ["P", 0, 1]]], pal.tile)
            AhkTest.AssertEqual([0, 1], pal.getdata())
            AhkTest.AssertEqual([10, 20, 30, 200, 10, 5], StdlibPillowTest.ArraySlice(pal.getpalette(), 1, 6))

            rleL := plugin.TgaImageFile(stdlib.io.BytesIO(rleLBytes))
            images.Push(rleL)
            AhkTest.AssertEqual("tga_rle", rleL.info["compression"])
            AhkTest.AssertEqual([["tga_rle", [0, 0, 3, 1], 18, ["L", 1, 8]]], rleL.tile)
            AhkTest.AssertEqual([7, 7, 7], rleL.getdata())

            rleRgb := plugin.TgaImageFile(stdlib.io.BytesIO(rleRgbBytes))
            images.Push(rleRgb)
            AhkTest.AssertEqual([["tga_rle", [0, 0, 3, 1], 18, ["BGR", 1, 24]]], rleRgb.tile)
            AhkTest.AssertEqual([[10, 20, 30], [10, 20, 30], [200, 10, 5]], rleRgb.getdata())

            withId := plugin.TgaImageFile(stdlib.io.BytesIO(idBytes))
            images.Push(withId)
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("abc"), withId.info["id_section"])
            AhkTest.AssertEqual([["raw", [0, 0, 1, 1], 21, ["L", 0, 1]]], withId.tile)
            AhkTest.AssertEqual([42], withId.getdata())

            lSource := stdlib.pillow.Image.new("L", [2, 1])
            images.Push(lSource)
            lSource.putdata([1, 2])
            lOut := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, lSource.save(lOut, "TGA"))
            AhkTest.AssertEqual([0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 1, 0, 8, 0], StdlibPillowTest.ArraySlice(lOut.getvalue(), 1, 18))
            AhkTest.AssertEqual([1, 2], StdlibPillowTest.ArraySlice(lOut.getvalue(), 19, 20))
            AhkTest.AssertEqual(StdlibPillowTest.ConcatBytes(StdlibPillowTest.ZeroBytes(8), StdlibPillowTest.AsciiBytes("TRUEVISION-XFILE."), [0]), StdlibPillowTest.ArraySlice(lOut.getvalue(), lOut.getvalue().Length - 25, lOut.getvalue().Length))

            rgbSource := stdlib.pillow.Image.new("RGB", [2, 1])
            images.Push(rgbSource)
            rgbSource.putdata([[10, 20, 30], [200, 10, 5]])
            rgbOut := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, rgbSource.save(rgbOut, "TGA", { orientation: 1, id_section: StdlibPillowTest.AsciiBytes("xy") }))
            AhkTest.AssertEqual([2, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 1, 0, 24, 32], StdlibPillowTest.ArraySlice(rgbOut.getvalue(), 1, 18))
            AhkTest.AssertEqual([120, 121, 30, 20, 10, 5, 10, 200], StdlibPillowTest.ArraySlice(rgbOut.getvalue(), 19, 26))

            rgbaSource := stdlib.pillow.Image.new("RGBA", [2, 1])
            images.Push(rgbaSource)
            rgbaSource.putdata([[10, 20, 30, 99], [10, 20, 30, 99]])
            rgbaOut := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, rgbaSource.save(rgbaOut, "TGA", { rle: true }))
            AhkTest.AssertEqual([0, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 1, 0, 32, 8], StdlibPillowTest.ArraySlice(rgbaOut.getvalue(), 1, 18))
            AhkTest.AssertEqual([129, 30, 20, 10, 99], StdlibPillowTest.ArraySlice(rgbaOut.getvalue(), 19, 23))

            pSource := stdlib.pillow.Image.new("P", [2, 1])
            images.Push(pSource)
            pSource.putdata([0, 1])
            pOut := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, plugin._save(pSource, pOut, "demo.tga"))
            AhkTest.AssertEqual([0, 1, 1, 0, 0, 0, 0, 24, 0, 0, 0, 0, 2, 0, 1, 0, 8, 0], StdlibPillowTest.ArraySlice(pOut.getvalue(), 1, 18))
            AhkTest.AssertEqual([0, 1], StdlibPillowTest.ArraySlice(pOut.getvalue(), 19, 20))

            AhkTest.RaisesMatch(SyntaxError, "^not a TGA file$", (*) => plugin.TgaImageFile(stdlib.io.BytesIO(StdlibPillowTest.ConcatBytes([0, 0, 3], StdlibPillowTest.ZeroBytes(15)))))
            AhkTest.RaisesMatch(SyntaxError, "^not a TGA file$", (*) => plugin.TgaImageFile(stdlib.io.BytesIO(StdlibPillowTest.TgaBytes(1, 1, 2, [0], 3))))
            AhkTest.RaisesMatch(SyntaxError, "^unknown TGA mode$", (*) => plugin.TgaImageFile(stdlib.io.BytesIO(StdlibPillowTest.TgaBytes(1, 1, 8, [0], 4))))
            AhkTest.RaisesMatch(SyntaxError, "^unknown TGA map depth$", (*) => plugin.TgaImageFile(stdlib.io.BytesIO(StdlibPillowTest.TgaBytes(1, 1, 8, [0], 1, 0x20, [], [0], 8))))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.ConcatBytes([0, 0, 3], StdlibPillowTest.ZeroBytes(15))), "r", ["TGA"]))
            AhkTest.RaisesMatch(OSError, "^cannot write mode F as TGA$", (*) => stdlib.pillow.Image.new("F", [1, 1]).save(stdlib.io.BytesIO(), "TGA"))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.TgaImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.TgaImageFile(stdlib.io.BytesIO(lBytes), "x", "y"))
        } finally {
            for image in images
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestTiffImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "TiffImagePlugin"))
        plugin := stdlib.pillow.TiffImagePlugin

        AhkTest.AssertEqual([73, 73], plugin.II)
        AhkTest.AssertEqual([77, 77], plugin.MM)
        AhkTest.AssertEqual(256, plugin.IMAGEWIDTH)
        AhkTest.AssertEqual(257, plugin.IMAGELENGTH)
        AhkTest.AssertEqual(258, plugin.BITSPERSAMPLE)
        AhkTest.AssertEqual(259, plugin.COMPRESSION)
        AhkTest.AssertEqual(262, plugin.PHOTOMETRIC_INTERPRETATION)
        AhkTest.AssertEqual(273, plugin.STRIPOFFSETS)
        AhkTest.AssertEqual(277, plugin.SAMPLESPERPIXEL)
        AhkTest.AssertEqual(278, plugin.ROWSPERSTRIP)
        AhkTest.AssertEqual(279, plugin.STRIPBYTECOUNTS)
        AhkTest.AssertEqual(282, plugin.X_RESOLUTION)
        AhkTest.AssertEqual(283, plugin.Y_RESOLUTION)
        AhkTest.AssertEqual(284, plugin.PLANAR_CONFIGURATION)
        AhkTest.AssertEqual(296, plugin.RESOLUTION_UNIT)
        AhkTest.AssertEqual(317, plugin.PREDICTOR)
        AhkTest.AssertEqual(320, plugin.COLORMAP)
        AhkTest.AssertEqual(338, plugin.EXTRASAMPLES)
        AhkTest.AssertEqual(339, plugin.SAMPLEFORMAT)
        AhkTest.AssertEqual(34675, plugin.ICCPROFILE)
        AhkTest.AssertEqual(65536, plugin.STRIP_SIZE)
        AhkTest.AssertEqual(6, plugin.MAX_SAMPLESPERPIXEL)
        AhkTest.AssertFalse(plugin.READ_LIBTIFF)
        AhkTest.AssertFalse(plugin.WRITE_LIBTIFF)

        AhkTest.AssertEqual([[77, 77, 0, 42], [73, 73, 42, 0], [77, 77, 42, 0], [73, 73, 0, 42], [77, 77, 0, 43], [73, 73, 43, 0]], plugin.PREFIXES)
        for prefix in plugin.PREFIXES
            AhkTest.AssertTrue(plugin._accept(prefix.Clone()))
        AhkTest.AssertFalse(plugin._accept([73, 73]))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("NOPE")))
        AhkTest.AssertEqual(0x1234, plugin.i16([0x12, 0x34]))
        AhkTest.AssertEqual(0x1234, plugin.i16([0, 0x12, 0x34], 1))
        AhkTest.AssertEqual(0x12345678, plugin.i32([0x12, 0x34, 0x56, 0x78]))
        AhkTest.AssertEqual(0x12345678, plugin.i32([0, 0x12, 0x34, 0x56, 0x78], 1))
        AhkTest.AssertEqual([255], plugin.o8(255))

        AhkTest.AssertEqual("raw", plugin.COMPRESSION_INFO[1])
        AhkTest.AssertEqual("tiff_lzw", plugin.COMPRESSION_INFO[5])
        AhkTest.AssertEqual("tiff_adobe_deflate", plugin.COMPRESSION_INFO[8])
        AhkTest.AssertEqual(1, plugin.COMPRESSION_INFO_REV["raw"])
        AhkTest.AssertEqual(5, plugin.COMPRESSION_INFO_REV["tiff_lzw"])
        AhkTest.AssertEqual(["L", "L"], plugin.OPEN_INFO["II,1,1,1,8,"])
        AhkTest.AssertEqual(["RGB", [73, 73], 2, 1, [8, 8, 8], stdlib.None], plugin.SAVE_INFO["RGB"])
        AhkTest.AssertEqual(["L", [73, 73], 1, 1, [8], stdlib.None], plugin.SAVE_INFO["L"])

        AhkTest.AssertEqual("TIFF", plugin.TiffImageFile.format)
        AhkTest.AssertEqual("Adobe TIFF", plugin.TiffImageFile.format_description)
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("TIFF"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("TIFF"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE_ALL.Has("TIFF"))
        AhkTest.AssertEqual("TIFF", stdlib.pillow.Image.registered_extensions()[".tif"])
        AhkTest.AssertEqual("TIFF", stdlib.pillow.Image.registered_extensions()[".tiff"])
        AhkTest.AssertEqual("image/tiff", stdlib.pillow.Image.MIME["TIFF"])
        AhkTest.AssertTrue(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "TIFF"))

        lBytes := StdlibPillowTest.TiffBytes("L", [7, 8, 0, 0])
        rgbBytes := StdlibPillowTest.TiffBytes("RGB", [[10, 20, 30], [200, 10, 5], [0, 0, 0], [0, 0, 0]])
        images := []
        try {
            directL := plugin.TiffImageFile(stdlib.io.BytesIO(lBytes))
            images.Push(directL)
            AhkTest.AssertEqual("TIFF", directL.format)
            AhkTest.AssertEqual("Adobe TIFF", directL.format_description)
            AhkTest.AssertEqual("L", directL.mode)
            AhkTest.AssertEqual([2, 2], directL.size)
            AhkTest.AssertEqual([7, 8, 0, 0], directL.getdata())
            AhkTest.AssertEqual("raw", directL.info["compression"])

            directRgb := plugin.TiffImageFile(stdlib.io.BytesIO(rgbBytes))
            images.Push(directRgb)
            AhkTest.AssertEqual("RGB", directRgb.mode)
            AhkTest.AssertEqual([2, 2], directRgb.size)
            AhkTest.AssertEqual([[10, 20, 30], [200, 10, 5], [0, 0, 0], [0, 0, 0]], directRgb.getdata())

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(lBytes), "r", ["TIFF"])
            images.Push(opened)
            AhkTest.AssertEqual("TIFF", opened.format)
            AhkTest.AssertEqual([7, 8, 0, 0], opened.getdata())

            out := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, directL.save(out, "TIFF"))
            AhkTest.AssertEqual([73, 73, 42, 0, 8, 0, 0, 0], StdlibPillowTest.ArraySlice(out.getvalue(), 1, 8))
            reopened := plugin.TiffImageFile(stdlib.io.BytesIO(out.getvalue()))
            images.Push(reopened)
            AhkTest.AssertEqual("L", reopened.mode)
            AhkTest.AssertEqual([7, 8, 0, 0], reopened.getdata())

            AhkTest.RaisesMatch(SyntaxError, "^not a TIFF file \(header b'NOPE' not valid\)$", (*) => plugin.TiffImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("NOPE"))))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("NOPE")), "r", ["TIFF"]))
            AhkTest.RaisesMatch(TypeError, "^TiffImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.TiffImageFile())
            AhkTest.RaisesMatch(TypeError, "^TiffImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.TiffImageFile(stdlib.io.BytesIO(lBytes), "x", "y"))
        } finally {
            for image in images
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestWalImageFileMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "WalImageFile"))
        plugin := stdlib.pillow.WalImageFile

        AhkTest.AssertEqual("WAL", plugin.WalImageFile.format)
        AhkTest.AssertEqual("Quake2 Texture", plugin.WalImageFile.format_description)
        AhkTest.AssertEqual(0x12345678, plugin.i32([0x78, 0x56, 0x34, 0x12]))
        AhkTest.AssertEqual(768, plugin.quake2palette.Length)
        AhkTest.AssertEqual([1, 1, 1, 11, 11, 11, 18, 18, 18, 23, 23, 23], StdlibPillowTest.ArraySlice(plugin.quake2palette, 1, 12))
        AhkTest.AssertFalse(stdlib.pillow.Image.OPEN.Has("WAL"))
        AhkTest.AssertFalse(stdlib.pillow.Image.SAVE.Has("WAL"))
        AhkTest.AssertFalse(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "WAL"))
        AhkTest.AssertFalse(stdlib.pillow.Image.registered_extensions().Has(".wal"))
        AhkTest.AssertFalse(stdlib.pillow.Image.MIME.Has("WAL"))

        walBytes := StdlibPillowTest.WalBytes(3, 2, [0, 1, 2, 3, 4, 5], "demo/wall", "demo/next")
        soloBytes := StdlibPillowTest.WalBytes(2, 1, [7, 8], "solo", "")
        direct := unset
        opened := unset
        try {
            direct := plugin.WalImageFile(stdlib.io.BytesIO(walBytes))
            AhkTest.AssertEqual("WAL", direct.format)
            AhkTest.AssertEqual("Quake2 Texture", direct.format_description)
            AhkTest.AssertEqual("P", direct.mode)
            AhkTest.AssertEqual([3, 2], direct.size)
            AhkTest.AssertEqual([0, 1, 2, 3, 4, 5], direct.getdata())
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("demo/wall"), direct.info["name"])
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("demo/next"), direct.info["next_name"])
            AhkTest.AssertEqual([1, 1, 1, 11, 11, 11, 18, 18, 18, 23, 23, 23], StdlibPillowTest.ArraySlice(direct.getpalette(), 1, 12))

            opened := plugin.open(stdlib.io.BytesIO(soloBytes))
            AhkTest.AssertEqual("WAL", opened.format)
            AhkTest.AssertEqual("P", opened.mode)
            AhkTest.AssertEqual([2, 1], opened.size)
            AhkTest.AssertEqual([7, 8], opened.getdata())
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("solo"), opened.info["name"])
            AhkTest.AssertFalse(opened.info.Has("next_name"))

            AhkTest.RaisesMatch(SyntaxError, "^unpack_from requires a buffer of at least 36 bytes", (*) => plugin.WalImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("bad"))))
            AhkTest.RaisesMatch(ValueError, "^not enough image data$", (*) => plugin.WalImageFile(stdlib.io.BytesIO(StdlibPillowTest.WalBytes(3, 2, [1, 2], "short", ""))).getdata())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.WalImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.WalImageFile(stdlib.io.BytesIO(walBytes), "x", "y"))
            AhkTest.RaisesMatch(TypeError, "^open\(\) missing 1 required positional argument: 'filename'$", (*) => plugin.open())
            AhkTest.RaisesMatch(TypeError, "^open\(\) takes 1 positional argument but 2 were given$", (*) => plugin.open(stdlib.io.BytesIO(walBytes), "x"))
        } finally {
            if IsSet(opened)
                StdlibPillowTest.CloseImage(opened)
            if IsSet(direct)
                StdlibPillowTest.CloseImage(direct)
        }
    }

    static TestWebPImagePluginSingleFrameMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "WebPImagePlugin"))
        plugin := stdlib.pillow.WebPImagePlugin

        AhkTest.AssertTrue(plugin.SUPPORTED)
        AhkTest.AssertEqual("RGB", plugin._VP8_MODES_BY_IDENTIFIER["VP8 "])
        AhkTest.AssertEqual("RGBA", plugin._VP8_MODES_BY_IDENTIFIER["VP8X"])
        AhkTest.AssertEqual("RGBA", plugin._VP8_MODES_BY_IDENTIFIER["VP8L"])
        AhkTest.AssertEqual("WEBP", plugin.WebPImageFile.format)
        AhkTest.AssertEqual("WebP image", plugin.WebPImageFile.format_description)
        AhkTest.AssertTrue(plugin._accept([82, 73, 70, 70, 0, 0, 0, 0, 87, 69, 66, 80, 86, 80, 56, 32]))
        AhkTest.AssertTrue(plugin._accept([82, 73, 70, 70, 0, 0, 0, 0, 87, 69, 66, 80, 86, 80, 56, 88]))
        AhkTest.AssertTrue(plugin._accept([82, 73, 70, 70, 0, 0, 0, 0, 87, 69, 66, 80, 86, 80, 56, 76]))
        AhkTest.AssertFalse(plugin._accept([82, 73, 70, 70, 0, 0, 0, 0, 87, 69, 66, 80, 66, 65, 68, 33]))
        AhkTest.AssertFalse(plugin._accept([82, 73, 70, 88, 0, 0, 0, 0, 87, 69, 66, 80, 86, 80, 56, 32]))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("RIFF")))

        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("WEBP"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("WEBP"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE_ALL.Has("WEBP"))
        AhkTest.AssertTrue(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "WEBP"))
        AhkTest.AssertEqual("WEBP", stdlib.pillow.Image.registered_extensions()[".webp"])
        AhkTest.AssertEqual("image/webp", stdlib.pillow.Image.MIME["WEBP"])

        rgbaBytes := [82, 73, 70, 70, 44, 0, 0, 0, 87, 69, 66, 80, 86, 80, 56, 76, 31, 0, 0, 0, 47, 1, 0, 0, 16, 15, 112, 1, 137, 77, 32, 200, 182, 13, 109, 59, 198, 201, 6, 40, 10, 255, 63, 108, 9, 182, 127, 100, 68, 255, 3, 0]
        rgbBytes := [82, 73, 70, 70, 32, 0, 0, 0, 87, 69, 66, 80, 86, 80, 56, 76, 20, 0, 0, 0, 47, 1, 0, 0, 0, 15, 112, 10, 143, 43, 120, 212, 99, 254, 131, 67, 5, 34, 250, 31]

        images := []
        try {
            direct := plugin.WebPImageFile(stdlib.io.BytesIO(rgbaBytes))
            images.Push(direct)
            AhkTest.AssertEqual("WEBP", direct.format)
            AhkTest.AssertEqual("WebP image", direct.format_description)
            AhkTest.AssertEqual("RGBA", direct.mode)
            AhkTest.AssertEqual([2, 1], direct.size)
            AhkTest.AssertEqual(1, direct.n_frames)
            AhkTest.AssertFalse(direct.is_animated)
            AhkTest.AssertEqual(0, direct.tell())
            AhkTest.AssertEqual([[10, 20, 30, 255], [1, 2, 3, 4]], direct.getdata())
            AhkTest.AssertEqual(1, direct.info["loop"])
            AhkTest.AssertEqual([255, 255, 255, 255], direct.info["background"])
            AhkTest.AssertEqual(0, direct.info["timestamp"])
            AhkTest.AssertEqual(0, direct.info["duration"])
            AhkTest.AssertSame(stdlib.None, direct.seek(0))
            AhkTest.AssertSame(stdlib.None, direct.load_seek(0))
            AhkTest.RaisesMatch(EOFError, "^attempt to seek outside sequence$", (*) => direct.seek(1))

            openedRgba := stdlib.pillow.Image.open(stdlib.io.BytesIO(rgbaBytes), "r", ["WEBP"])
            images.Push(openedRgba)
            AhkTest.AssertEqual("WEBP", openedRgba.format)
            AhkTest.AssertEqual("RGBA", openedRgba.mode)
            AhkTest.AssertEqual([[10, 20, 30, 255], [1, 2, 3, 4]], openedRgba.getdata())

            openedRgb := stdlib.pillow.Image.open(stdlib.io.BytesIO(rgbBytes), "r", ["WEBP"])
            images.Push(openedRgb)
            AhkTest.AssertEqual("WEBP", openedRgb.format)
            AhkTest.AssertEqual("RGB", openedRgb.mode)
            AhkTest.AssertEqual([[10, 20, 30], [40, 50, 60]], openedRgb.getdata())

            AhkTest.AssertEqual("RGBA", plugin._convert_frame(stdlib.pillow.Image.new("RGBA", [1, 1])).mode)
            AhkTest.AssertEqual("RGB", plugin._convert_frame(stdlib.pillow.Image.new("L", [1, 1])).mode)
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.WebPImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.WebPImageFile(stdlib.io.BytesIO(rgbaBytes), "x", "y"))
            AhkTest.RaisesMatch(OSError, "^could not create decoder object$", (*) => plugin.WebPImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("bad"))).load())
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("bad")), "r", ["WEBP"]))
        } finally {
            for image in images
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestWebPImagePluginAnimationMatchesLocalPillow113()
    {
        plugin := stdlib.pillow.WebPImagePlugin
        animatedBytes := [82, 73, 70, 70, 142, 0, 0, 0, 87, 69, 66, 80, 86, 80, 56, 88, 10, 0, 0, 0, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 65, 78, 73, 77, 6, 0, 0, 0, 7, 8, 9, 6, 3, 0, 65, 78, 77, 70, 44, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11, 0, 0, 2, 86, 80, 56, 76, 20, 0, 0, 0, 47, 0, 0, 0, 0, 7, 80, 129, 84, 8, 32, 0, 10, 154, 254, 199, 136, 136, 254, 7, 65, 78, 77, 70, 46, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 22, 0, 0, 2, 86, 80, 56, 76, 21, 0, 0, 0, 47, 0, 0, 0, 16, 7, 208, 2, 2, 73, 91, 188, 237, 175, 65, 1, 227, 136, 136, 254, 7, 0]

        animated := unset
        try {
            animated := plugin.WebPImageFile(stdlib.io.BytesIO(animatedBytes))
            AhkTest.AssertEqual("WEBP", animated.format)
            AhkTest.AssertEqual("RGBA", animated.mode)
            AhkTest.AssertEqual([1, 1], animated.size)
            AhkTest.AssertEqual(2, animated.n_frames)
            AhkTest.AssertTrue(animated.is_animated)
            AhkTest.AssertEqual(3, animated.info["loop"])
            AhkTest.AssertEqual([9, 8, 7, 6], animated.info["background"])
            AhkTest.AssertEqual(0, animated.tell())
            AhkTest.AssertEqual([1, 2, 3, 255], animated.getpixel([0, 0]))
            AhkTest.AssertEqual(0, animated.info["timestamp"])
            AhkTest.AssertEqual(11, animated.info["duration"])

            AhkTest.AssertSame(stdlib.None, animated.seek(1))
            AhkTest.AssertEqual(1, animated.tell())
            AhkTest.AssertEqual([4, 5, 6, 128], animated.getpixel([0, 0]))
            AhkTest.AssertEqual(11, animated.info["timestamp"])
            AhkTest.AssertEqual(22, animated.info["duration"])

            AhkTest.AssertSame(stdlib.None, animated.seek(0))
            AhkTest.AssertEqual([1, 2, 3, 255], animated.getpixel([0, 0]))
            AhkTest.RaisesMatch(EOFError, "^attempt to seek outside sequence$", (*) => animated.seek(2))
        } finally {
            if IsSet(animated)
                StdlibPillowTest.CloseImage(animated)
        }
    }

    static TestWmfImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "WmfImagePlugin"))
        plugin := stdlib.pillow.WmfImagePlugin

        AhkTest.AssertTrue(HasProp(plugin, "WmfHandler"))
        AhkTest.AssertEqual("WMF", plugin.WmfStubImageFile.format)
        AhkTest.AssertEqual("Windows Metafile", plugin.WmfStubImageFile.format_description)
        AhkTest.AssertEqual(0x1234, plugin.word([0x34, 0x12], 0))
        AhkTest.AssertEqual(-1, plugin.short([0xFF, 0xFF], 0))
        AhkTest.AssertEqual(-1, plugin._long([0xFF, 0xFF, 0xFF, 0xFF], 0))
        AhkTest.AssertTrue(plugin._accept([0xD7, 0xCD, 0xC6, 0x9A, 0, 0, 1]))
        AhkTest.AssertTrue(plugin._accept([1, 0, 0, 0, 0]))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("bad")))
        AhkTest.AssertFalse(plugin._accept([0xD7, 0xCD, 0xC6, 0x9A, 0]))

        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("WMF"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("WMF"))
        AhkTest.AssertFalse(stdlib.pillow.Image.SAVE_ALL.Has("WMF"))
        AhkTest.AssertTrue(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "WMF"))
        AhkTest.AssertEqual("WMF", stdlib.pillow.Image.registered_extensions()[".wmf"])
        AhkTest.AssertEqual("WMF", stdlib.pillow.Image.registered_extensions()[".emf"])
        AhkTest.AssertFalse(stdlib.pillow.Image.MIME.Has("WMF"))

        wmfBytes := StdlibPillowTestWmfBytes()
        emfBytes := StdlibPillowTestEmfBytes()
        direct := unset
        registered := unset
        emf := unset
        try {
            direct := plugin.WmfStubImageFile(stdlib.io.BytesIO(wmfBytes))
            AhkTest.AssertEqual("WMF", direct.format)
            AhkTest.AssertEqual("Windows Metafile", direct.format_description)
            AhkTest.AssertEqual("RGB", direct.mode)
            AhkTest.AssertEqual([72, 36], direct.size)
            AhkTest.AssertEqual(72, direct.info["dpi"])
            AhkTest.AssertEqual([0, 0, 1440, 720], direct.info["wmf_bbox"])
            AhkTest.AssertEqual([], direct.tile)

            registered := stdlib.pillow.Image.open(stdlib.io.BytesIO(wmfBytes), "r", ["WMF"])
            AhkTest.AssertEqual("WMF", registered.format)
            AhkTest.AssertEqual([72, 36], registered.size)

            emf := plugin.WmfStubImageFile(stdlib.io.BytesIO(emfBytes))
            AhkTest.AssertEqual("WMF", emf.format)
            AhkTest.AssertEqual("RGB", emf.mode)
            AhkTest.AssertEqual([96, 48], emf.size)
            AhkTest.AssertEqual(96.0, emf.info["dpi"])
            AhkTest.AssertEqual([0, 0, 96, 48], emf.info["wmf_bbox"])

            handler := StdlibPillowWmfRecordingHandler()
            previous := plugin._handler
            try {
                AhkTest.AssertSame(stdlib.None, plugin.register_handler(handler))
                handled := plugin.WmfStubImageFile(stdlib.io.BytesIO(wmfBytes))
                AhkTest.AssertEqual(1, handler.open_calls)
                AhkTest.AssertEqual([0, 0, 1440, 720], handler.open_bbox)
                AhkTest.AssertSame(stdlib.None, handled.load(144))
                AhkTest.AssertEqual([144, 72], handled.size)
                AhkTest.AssertEqual([1, 2, 3], handled.getpixel([0, 0]))

                tupleDpi := plugin.WmfStubImageFile(stdlib.io.BytesIO(wmfBytes))
                AhkTest.AssertSame(stdlib.None, tupleDpi.load([144, 72]))
                AhkTest.AssertEqual([144, 36], tupleDpi.size)
                StdlibPillowTest.CloseImage(tupleDpi)

                out := stdlib.io.BytesIO()
                source := stdlib.pillow.Image.new("RGB", [2, 1])
                try {
                    AhkTest.AssertSame(stdlib.None, source.save(out, "WMF"))
                    AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("saved:[2, 1]"), out.getvalue())
                    AhkTest.AssertEqual("", handler.save_filename)
                } finally {
                    StdlibPillowTest.CloseImage(source)
                }
                StdlibPillowTest.CloseImage(handled)
            } finally {
                plugin.register_handler(previous)
            }

            plugin.register_handler(stdlib.None)
            try {
                AhkTest.RaisesMatch(OSError, "^WMF save handler not installed$", (*) => stdlib.pillow.Image.new("RGB", [1, 1]).save(stdlib.io.BytesIO(), "WMF"))
            } finally {
                plugin.register_handler(previous)
            }

            AhkTest.RaisesMatch(ValueError, "^Invalid inch$", (*) => plugin.WmfStubImageFile(stdlib.io.BytesIO(StdlibPillowTestWmfBytes(0, 0, 1440, 720, 0))))
            AhkTest.RaisesMatch(SyntaxError, "^Unsupported WMF file format$", (*) => plugin.WmfStubImageFile(stdlib.io.BytesIO(StdlibPillowTestWmfBytes(0, 0, 1440, 720, 1440, false))))
            AhkTest.RaisesMatch(SyntaxError, "^Unsupported file format$", (*) => plugin.WmfStubImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("bad"))))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("bad")), "r", ["WMF"]))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.WmfStubImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.WmfStubImageFile(stdlib.io.BytesIO(wmfBytes), "x", "y"))
        } finally {
            if IsSet(emf)
                StdlibPillowTest.CloseImage(emf)
            if IsSet(registered)
                StdlibPillowTest.CloseImage(registered)
            if IsSet(direct)
                StdlibPillowTest.CloseImage(direct)
        }
    }

    static TestXVThumbImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "XVThumbImagePlugin"))
        plugin := stdlib.pillow.XVThumbImagePlugin

        AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("P7 332"), plugin._MAGIC)
        AhkTest.AssertEqual(768, plugin.PALETTE.Length)
        AhkTest.AssertEqual([0, 0, 0, 0, 0, 85, 0, 0, 170, 0, 0, 255, 0, 36, 0, 0, 36, 85], StdlibPillowTest.ArraySlice(plugin.PALETTE, 1, 18))
        AhkTest.AssertEqual([255, 255, 0, 255, 255, 85, 255, 255, 170, 255, 255, 255], StdlibPillowTest.ArraySlice(plugin.PALETTE, plugin.PALETTE.Length - 11, plugin.PALETTE.Length))
        AhkTest.AssertEqual("XVThumb", plugin.XVThumbImageFile.format)
        AhkTest.AssertEqual("XV thumbnail image", plugin.XVThumbImageFile.format_description)
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("P7 332`n")))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("P7 332")))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("P7 332 demo")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("P7 333`n")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("P7 33")))

        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("XVTHUMB"))
        AhkTest.AssertFalse(stdlib.pillow.Image.OPEN.Has("XVThumb"))
        AhkTest.AssertFalse(stdlib.pillow.Image.SAVE.Has("XVTHUMB"))
        AhkTest.AssertFalse(stdlib.pillow.Image.SAVE_ALL.Has("XVTHUMB"))
        AhkTest.AssertTrue(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "XVTHUMB"))
        AhkTest.AssertFalse(stdlib.pillow.Image.registered_extensions().Has(".xv"))
        AhkTest.AssertFalse(stdlib.pillow.Image.MIME.Has("XVThumb"))

        thumbBytes := StdlibPillowTestXVThumbBytes(3, 2, [0, 1, 2, 3, 4, 5], ["#IMGINFO:demo", "#THUMBONLY"])
        spaceBytes := StdlibPillowTest.AsciiBytes("P7 332 extra text ignored`n#comment`n2`t1`n")
        spaceBytes.Push(7)
        spaceBytes.Push(8)
        direct := unset
        registered := unset
        space := unset
        try {
            direct := plugin.XVThumbImageFile(stdlib.io.BytesIO(thumbBytes))
            AhkTest.AssertEqual("XVThumb", direct.format)
            AhkTest.AssertEqual("XV thumbnail image", direct.format_description)
            AhkTest.AssertEqual("P", direct.mode)
            AhkTest.AssertEqual([3, 2], direct.size)
            AhkTest.AssertEqual([0, 1, 2, 3, 4, 5], direct.getdata())
            AhkTest.AssertEqual([0, 0, 0, 0, 0, 85, 0, 0, 170, 0, 0, 255, 0, 36, 0, 0, 36, 85], StdlibPillowTest.ArraySlice(direct.getpalette(), 1, 18))
            AhkTest.AssertEqual(["raw", [0, 0, 3, 2], 36, "P"], direct.tile[1])

            registered := stdlib.pillow.Image.open(stdlib.io.BytesIO(thumbBytes), "r", ["XVThumb"])
            AhkTest.AssertEqual("XVThumb", registered.format)
            AhkTest.AssertEqual("P", registered.mode)
            AhkTest.AssertEqual([0, 1, 2, 3, 4, 5], registered.getdata())

            space := plugin.XVThumbImageFile(stdlib.io.BytesIO(spaceBytes))
            AhkTest.AssertEqual([2, 1], space.size)
            AhkTest.AssertEqual([7, 8], space.getdata())
            AhkTest.AssertEqual(["raw", [0, 0, 2, 1], 39, "P"], space.tile[1])

            AhkTest.RaisesMatch(SyntaxError, "^not an XV thumbnail file$", (*) => plugin.XVThumbImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("P7 333`n1 1`n`0"))))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("P7 333`n1 1`n`0")), "r", ["XVThumb"]))
            AhkTest.RaisesMatch(SyntaxError, "^Unexpected EOF reading XV thumbnail file$", (*) => plugin.XVThumbImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("P7 332`n#only-comment`n"))))
            AhkTest.RaisesMatch(ValueError, "^invalid literal for int\(\) with base 10: b'wide'$", (*) => plugin.XVThumbImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("P7 332`nwide high`n`0"))))
            AhkTest.RaisesMatch(OSError, "^image file is truncated", (*) => plugin.XVThumbImageFile(stdlib.io.BytesIO(StdlibPillowTestXVThumbBytes(2, 2, [1, 2]))).load())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.XVThumbImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.XVThumbImageFile(stdlib.io.BytesIO(thumbBytes), "x", "y"))
        } finally {
            if IsSet(space)
                StdlibPillowTest.CloseImage(space)
            if IsSet(registered)
                StdlibPillowTest.CloseImage(registered)
            if IsSet(direct)
                StdlibPillowTest.CloseImage(direct)
        }
    }

    static TestXbmImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "XbmImagePlugin"))
        plugin := stdlib.pillow.XbmImagePlugin

        AhkTest.AssertEqual("XBM", plugin.XbmImageFile.format)
        AhkTest.AssertEqual("X11 Bitmap", plugin.XbmImageFile.format_description)
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("#define im_width 1`n")))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes(" `t`r`n#define im_width 1`n")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("/*x*/#define im_width 1`n")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("#Define im_width 1`n")))
        AhkTest.AssertFalse(plugin._accept([]))

        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("XBM"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("XBM"))
        AhkTest.AssertFalse(stdlib.pillow.Image.SAVE_ALL.Has("XBM"))
        AhkTest.AssertTrue(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "XBM"))
        AhkTest.AssertEqual("XBM", stdlib.pillow.Image.registered_extensions()[".xbm"])
        AhkTest.AssertEqual("image/xbm", stdlib.pillow.Image.MIME["XBM"])

        basicBytes := StdlibPillowTestXbmBytes(false)
        hotspotBytes := StdlibPillowTestXbmBytes(true)
        commentedBytes := StdlibPillowTest.AsciiBytes("#define demo_width 3`n#define demo_height 1`nstatic char demo_bits[] = /* comment */ {`n0x05};`n")
        direct := unset
        registered := unset
        hotspot := unset
        commented := unset
        source := unset
        openedSaved := unset
        hotspotSource := unset
        openedHotspotSaved := unset
        try {
            direct := plugin.XbmImageFile(stdlib.io.BytesIO(basicBytes))
            AhkTest.AssertEqual("XBM", direct.format)
            AhkTest.AssertEqual("X11 Bitmap", direct.format_description)
            AhkTest.AssertEqual("1", direct.mode)
            AhkTest.AssertEqual([5, 2], direct.size)
            AhkTest.AssertEqual([255, 0, 255, 0, 255, 0, 255, 0, 255, 0], direct.getdata())
            AhkTest.AssertEqual(["xbm", [0, 0, 5, 2], 60, stdlib.None], direct.tile[1])

            registered := stdlib.pillow.Image.open(stdlib.io.BytesIO(basicBytes), "r", ["XBM"])
            AhkTest.AssertEqual("XBM", registered.format)
            AhkTest.AssertEqual([255, 0, 255, 0, 255, 0, 255, 0, 255, 0], registered.getdata())

            hotspot := plugin.XbmImageFile(stdlib.io.BytesIO(hotspotBytes))
            AhkTest.AssertEqual([1, 0], hotspot.info["hotspot"])
            AhkTest.AssertEqual(["xbm", [0, 0, 5, 2], 123, stdlib.None], hotspot.tile[1])
            AhkTest.AssertEqual([255, 0, 255, 0, 255, 0, 255, 0, 255, 0], hotspot.getdata())

            commented := plugin.XbmImageFile(stdlib.io.BytesIO(commentedBytes))
            AhkTest.AssertEqual([3, 1], commented.size)
            AhkTest.AssertEqual([255, 0, 255], commented.getdata())
            AhkTest.AssertEqual(["xbm", [0, 0, 3, 1], 66, stdlib.None], commented.tile[1])

            source := stdlib.pillow.Image.new("1", [5, 2], 0)
            for xy in [[0, 0], [2, 0], [4, 0], [1, 1], [3, 1]]
                source.putpixel(xy, 255)
            out := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, source.save(out, "XBM"))
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("#define im_width 5`n#define im_height 2`nstatic char im_bits[] = {`n0x15,0x0a`n};`n"), out.getvalue())
            openedSaved := stdlib.pillow.Image.open(stdlib.io.BytesIO(out.getvalue()), "r", ["XBM"])
            AhkTest.AssertEqual([255, 0, 255, 0, 255, 0, 255, 0, 255, 0], openedSaved.getdata())

            hotspotSource := stdlib.pillow.Image.new("1", [5, 2], 0)
            for xy in [[0, 0], [2, 0], [4, 0], [1, 1], [3, 1]]
                hotspotSource.putpixel(xy, 255)
            hotspotOut := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, hotspotSource.save(hotspotOut, "XBM", { hotspot: [3, 1] }))
            AhkTest.AssertContains("#define im_x_hot 3`n#define im_y_hot 1`n", StdlibPillowTest.AsciiFromBytes(hotspotOut.getvalue()))
            openedHotspotSaved := stdlib.pillow.Image.open(stdlib.io.BytesIO(hotspotOut.getvalue()), "r", ["XBM"])
            AhkTest.AssertEqual([3, 1], openedHotspotSaved.info["hotspot"])

            AhkTest.RaisesMatch(SyntaxError, "^not a XBM file$", (*) => plugin.XbmImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("not xbm"))))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("not xbm")), "r", ["XBM"]))
            AhkTest.RaisesMatch(SyntaxError, "^not a XBM file$", (*) => plugin.XbmImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("#define im_width 1`nstatic char im_bits[] = {0x00};`n"))))
            AhkTest.RaisesMatch(OSError, "^image file is truncated", (*) => plugin.XbmImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("#define im_width 9`n#define im_height 2`nstatic char im_bits[] = {`n0x01};`n"))).load())
            AhkTest.RaisesMatch(OSError, "^cannot write mode L as XBM$", (*) => stdlib.pillow.Image.new("L", [1, 1], 0).save(stdlib.io.BytesIO(), "XBM"))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.XbmImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.XbmImageFile(stdlib.io.BytesIO(basicBytes), "x", "y"))
        } finally {
            if IsSet(openedHotspotSaved)
                StdlibPillowTest.CloseImage(openedHotspotSaved)
            if IsSet(hotspotSource)
                StdlibPillowTest.CloseImage(hotspotSource)
            if IsSet(openedSaved)
                StdlibPillowTest.CloseImage(openedSaved)
            if IsSet(source)
                StdlibPillowTest.CloseImage(source)
            if IsSet(commented)
                StdlibPillowTest.CloseImage(commented)
            if IsSet(hotspot)
                StdlibPillowTest.CloseImage(hotspot)
            if IsSet(registered)
                StdlibPillowTest.CloseImage(registered)
            if IsSet(direct)
                StdlibPillowTest.CloseImage(direct)
        }
    }

    static TestXpmImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "XpmImagePlugin"))
        plugin := stdlib.pillow.XpmImagePlugin

        AhkTest.AssertEqual("XPM", plugin.XpmImageFile.format)
        AhkTest.AssertEqual("X11 Pixel Map", plugin.XpmImageFile.format_description)
        AhkTest.AssertTrue(plugin.XpmDecoder("P")._pulls_fd)
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("/* XPM */`n")))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("/* XPM */x")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes(" /* XPM */")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("/* xpm */")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("/* XPM *")))
        AhkTest.AssertFalse(plugin._accept([]))

        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("XPM"))
        AhkTest.AssertTrue(stdlib.pillow.Image.DECODERS.Has("xpm"))
        AhkTest.AssertFalse(stdlib.pillow.Image.SAVE.Has("XPM"))
        AhkTest.AssertFalse(stdlib.pillow.Image.SAVE_ALL.Has("XPM"))
        AhkTest.AssertTrue(StdlibPillowTest.ArrayContains(stdlib.pillow.Image.ID, "XPM"))
        AhkTest.AssertEqual("XPM", stdlib.pillow.Image.registered_extensions()[".xpm"])
        AhkTest.AssertEqual("image/xpm", stdlib.pillow.Image.MIME["XPM"])

        pBytes := StdlibPillowTestXpmPBytes()
        rgbBytes := StdlibPillowTestXpmRgbBytes()
        direct := unset
        registered := unset
        rgb := unset
        try {
            direct := plugin.XpmImageFile(stdlib.io.BytesIO(pBytes))
            AhkTest.AssertEqual("XPM", direct.format)
            AhkTest.AssertEqual("X11 Pixel Map", direct.format_description)
            AhkTest.AssertEqual("P", direct.mode)
            AhkTest.AssertEqual([4, 2], direct.size)
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("c"), direct.info["transparency"])
            AhkTest.AssertEqual([255, 0, 0, 0, 255, 0], direct.getpalette())
            AhkTest.AssertEqual([0, 1, 1, 0, 1, 0, 0, 1], direct.getdata())
            AhkTest.AssertEqual(["xpm", [0, 0, 4, 2], 91, [1, [StdlibPillowTest.AsciiBytes("a"), StdlibPillowTest.AsciiBytes("b")]]], direct.tile[1])
            AhkTest.AssertEqual([0, 1, 1, 0, 1, 0, 0, 1], direct.tobytes())

            registered := stdlib.pillow.Image.open(stdlib.io.BytesIO(pBytes), "r", ["XPM"])
            AhkTest.AssertEqual("XPM", registered.format)
            AhkTest.AssertEqual("P", registered.mode)
            AhkTest.AssertEqual([0, 1, 1, 0, 1, 0, 0, 1], registered.getdata())

            rgb := plugin.XpmImageFile(stdlib.io.BytesIO(rgbBytes))
            AhkTest.AssertEqual("RGB", rgb.mode)
            AhkTest.AssertEqual([2, 1], rgb.size)
            AhkTest.AssertEqual([[0, 255, 0], [0, 255, 0]], rgb.getdata())
            AhkTest.AssertEqual("xpm", rgb.tile[1][1])
            AhkTest.AssertEqual([0, 0, 2, 1], rgb.tile[1][2])
            AhkTest.AssertEqual(4135, rgb.tile[1][3])
            AhkTest.AssertEqual(2, rgb.tile[1][4][1])

            AhkTest.RaisesMatch(SyntaxError, "^not an XPM file$", (*) => plugin.XpmImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("bad"))))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("bad")), "r", ["XPM"]))
            AhkTest.RaisesMatch(SyntaxError, "^broken XPM file$", (*) => plugin.XpmImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("/* XPM */`n/* no dimensions here */`n"))))
            AhkTest.RaisesMatch(ValueError, "^cannot read this XPM file$", (*) => plugin.XpmImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("/* XPM */`n`"1 1 1 1`",`n`"a c red`",`n`"a`"`n};`n"))))
            AhkTest.RaisesMatch(ValueError, "^cannot read this XPM file$", (*) => plugin.XpmImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("/* XPM */`n`"1 1 1 1`",`n`"a m #000000`",`n`"a`"`n};`n"))))
            AhkTest.RaisesMatch(ValueError, "^not enough image data$", (*) => plugin.XpmImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("/* XPM */`n`"3 1 1 1`",`n`"a c #000000`"`n};`n"))).getdata())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.XpmImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.XpmImageFile(stdlib.io.BytesIO(pBytes), "x", "y"))
        } finally {
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
            if IsSet(registered)
                StdlibPillowTest.CloseImage(registered)
            if IsSet(direct)
                StdlibPillowTest.CloseImage(direct)
        }
    }

    static TestCurImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "CurImagePlugin"))
        plugin := stdlib.pillow.CurImagePlugin

        AhkTest.AssertTrue(plugin._accept([0, 0, 2, 0, 114, 101, 115, 116]))
        AhkTest.AssertFalse(plugin._accept([0, 0, 1, 0, 114, 101, 115, 116]))
        AhkTest.AssertFalse(plugin._accept([0, 0, 2]))
        AhkTest.AssertEqual("CUR", plugin.CurImageFile.format)
        AhkTest.AssertEqual("Windows Cursor", plugin.CurImageFile.format_description)
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("CUR"))
        AhkTest.AssertEqual("CUR", stdlib.pillow.Image.registered_extensions()[".cur"])

        singleBytes := StdlibPillowTest.CurBytes([[2, 2, 24, StdlibPillowTest.CurDibBytes(2, 4, [10, 20, 30], [1, 0, [200, 10, 5]])]])
        multiBytes := StdlibPillowTest.CurBytes([
            [1, 1, 24, StdlibPillowTest.CurDibBytes(1, 2, [1, 2, 3])],
            [3, 3, 24, StdlibPillowTest.CurDibBytes(3, 6, [10, 20, 30], [1, 0, [200, 10, 5]])],
        ])

        openedSingle := unset
        openedMulti := unset
        directSingle := unset
        try {
            openedSingle := stdlib.pillow.Image.open(stdlib.io.BytesIO(singleBytes), "r", ["CUR"])
            AhkTest.AssertEqual("CUR", openedSingle.format)
            AhkTest.AssertEqual("Windows Cursor", openedSingle.format_description)
            AhkTest.AssertEqual("RGB", openedSingle.mode)
            AhkTest.AssertEqual([2, 2], openedSingle.size)
            AhkTest.AssertEqual([10, 20, 30], openedSingle.getpixel([1, 0]))

            openedMulti := stdlib.pillow.Image.open(stdlib.io.BytesIO(multiBytes), "r", ["CUR"])
            AhkTest.AssertEqual("CUR", openedMulti.format)
            AhkTest.AssertEqual("RGB", openedMulti.mode)
            AhkTest.AssertEqual([3, 3], openedMulti.size)
            AhkTest.AssertEqual([10, 20, 30], openedMulti.getpixel([1, 0]))

            directSingle := plugin.CurImageFile(stdlib.io.BytesIO(singleBytes))
            AhkTest.AssertEqual("CUR", directSingle.format)
            AhkTest.AssertEqual("Windows Cursor", directSingle.format_description)
            AhkTest.AssertEqual("RGB", directSingle.mode)
            AhkTest.AssertEqual([2, 2], directSingle.size)

            AhkTest.RaisesMatch(SyntaxError, "^not a CUR file$", (*) => plugin.CurImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD!"))))
            AhkTest.RaisesMatch(SyntaxError, "^No cursors were found$", (*) => plugin.CurImageFile(stdlib.io.BytesIO([0, 0, 2, 0, 0, 0])))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.CurImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.CurImageFile(stdlib.io.BytesIO(singleBytes), stdlib.None, "extra"))
        } finally {
            if IsSet(directSingle)
                StdlibPillowTest.CloseImage(directSingle)
            if IsSet(openedMulti)
                StdlibPillowTest.CloseImage(openedMulti)
            if IsSet(openedSingle)
                StdlibPillowTest.CloseImage(openedSingle)
        }
    }

    static TestDcxImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "DcxImagePlugin"))
        plugin := stdlib.pillow.DcxImagePlugin

        frameOne := StdlibPillowTest.PcxRgbBytes(2, 2, [10, 20, 30], [1, 0, [200, 10, 5]])
        frameTwo := StdlibPillowTest.PcxRgbBytes(2, 2, [40, 50, 60], [1, 0, [1, 2, 3]])
        singleBytes := StdlibPillowTest.DcxBytes([frameOne])
        multiBytes := StdlibPillowTest.DcxBytes([frameOne, frameTwo])

        AhkTest.AssertEqual(987654321, plugin.MAGIC)
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.ArraySlice(singleBytes, 1, 8)))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.ArraySlice(frameOne, 1, 8)))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.ArraySlice(singleBytes, 1, 3)))
        AhkTest.AssertEqual("DCX", plugin.DcxImageFile.format)
        AhkTest.AssertEqual("Intel DCX", plugin.DcxImageFile.format_description)
        AhkTest.AssertFalse(plugin.DcxImageFile._close_exclusive_fp_after_loading)
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("DCX"))
        AhkTest.AssertEqual("DCX", stdlib.pillow.Image.registered_extensions()[".dcx"])

        openedSingle := unset
        openedMulti := unset
        directSingle := unset
        try {
            openedSingle := stdlib.pillow.Image.open(stdlib.io.BytesIO(singleBytes), "r", ["DCX"])
            AhkTest.AssertEqual("DCX", openedSingle.format)
            AhkTest.AssertEqual("Intel DCX", openedSingle.format_description)
            AhkTest.AssertEqual("RGB", openedSingle.mode)
            AhkTest.AssertEqual([2, 2], openedSingle.size)
            AhkTest.AssertEqual(1, openedSingle.n_frames)
            AhkTest.AssertFalse(openedSingle.is_animated)
            AhkTest.AssertEqual(0, openedSingle.tell())
            AhkTest.AssertEqual([200, 10, 5], openedSingle.getpixel([1, 0]))

            openedMulti := stdlib.pillow.Image.open(stdlib.io.BytesIO(multiBytes), "r", ["DCX"])
            AhkTest.AssertEqual("DCX", openedMulti.format)
            AhkTest.AssertEqual("Intel DCX", openedMulti.format_description)
            AhkTest.AssertEqual(2, openedMulti.n_frames)
            AhkTest.AssertTrue(openedMulti.is_animated)
            AhkTest.AssertEqual(0, openedMulti.tell())
            AhkTest.AssertEqual([200, 10, 5], openedMulti.getpixel([1, 0]))
            AhkTest.AssertSame(stdlib.None, openedMulti.seek(1))
            AhkTest.AssertEqual(1, openedMulti.tell())
            AhkTest.AssertEqual("RGB", openedMulti.mode)
            AhkTest.AssertEqual([2, 2], openedMulti.size)
            AhkTest.AssertEqual([1, 2, 3], openedMulti.getpixel([1, 0]))
            AhkTest.AssertSame(stdlib.None, openedMulti.seek(0))
            AhkTest.AssertEqual(0, openedMulti.tell())
            AhkTest.AssertEqual([200, 10, 5], openedMulti.getpixel([1, 0]))

            directSingle := plugin.DcxImageFile(stdlib.io.BytesIO(singleBytes))
            AhkTest.AssertEqual("DCX", directSingle.format)
            AhkTest.AssertEqual("Intel DCX", directSingle.format_description)
            AhkTest.AssertEqual("RGB", directSingle.mode)
            AhkTest.AssertEqual([2, 2], directSingle.size)
            AhkTest.AssertEqual(1, directSingle.n_frames)
            AhkTest.AssertFalse(directSingle.is_animated)
            AhkTest.AssertEqual(0, directSingle.tell())

            AhkTest.RaisesMatch(SyntaxError, "^not a DCX file$", (*) => plugin.DcxImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD!"))))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.DcxImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.DcxImageFile(stdlib.io.BytesIO(singleBytes), stdlib.None, "extra"))
            AhkTest.RaisesMatch(EOFError, "^attempt to seek outside sequence$", (*) => openedSingle.seek(-1))
            AhkTest.RaisesMatch(EOFError, "^attempt to seek outside sequence$", (*) => openedSingle.seek(1))
        } finally {
            if IsSet(directSingle)
                StdlibPillowTest.CloseImage(directSingle)
            if IsSet(openedMulti)
                StdlibPillowTest.CloseImage(openedMulti)
            if IsSet(openedSingle)
                StdlibPillowTest.CloseImage(openedSingle)
        }
    }

    static TestDdsImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "DdsImagePlugin"))
        plugin := stdlib.pillow.DdsImagePlugin

        AhkTest.AssertEqual(542327876, plugin.DDS_MAGIC)
        AhkTest.AssertEqual(1, plugin.DDSD_CAPS)
        AhkTest.AssertEqual(2, plugin.DDSD_HEIGHT)
        AhkTest.AssertEqual(4, plugin.DDSD_WIDTH)
        AhkTest.AssertEqual(4096, plugin.DDSD_PIXELFORMAT)
        AhkTest.AssertEqual(4096, plugin.DDSCAPS_TEXTURE)
        AhkTest.AssertEqual(64, plugin.DDPF_RGB)
        AhkTest.AssertEqual(1, plugin.DDPF_ALPHAPIXELS)
        AhkTest.AssertEqual(131072, plugin.DDPF_LUMINANCE)
        AhkTest.AssertEqual(4, plugin.DDPF_FOURCC)
        AhkTest.AssertEqual(827611204, plugin.DXT1_FOURCC)
        AhkTest.AssertEqual(861165636, plugin.DXT3_FOURCC)
        AhkTest.AssertEqual(894720068, plugin.DXT5_FOURCC)
        AhkTest.AssertEqual(28, plugin.DXGI_FORMAT_R8G8B8A8_UNORM)
        AhkTest.AssertEqual(99, plugin.DXGI_FORMAT_BC7_UNORM_SRGB)

        AhkTest.AssertEqual(1, plugin.DDSD.CAPS.value)
        AhkTest.AssertEqual("CAPS", plugin.DDSD.CAPS.name)
        AhkTest.AssertEqual("DDSD.CAPS", String(plugin.DDSD.CAPS))
        AhkTest.AssertEqual("<DDSD.CAPS: 1>", plugin.DDSD.CAPS.__Repr())
        ddsdTextureFlags := plugin.DDSD.combine(plugin.DDSD.CAPS, plugin.DDSD.HEIGHT, plugin.DDSD.WIDTH, plugin.DDSD.PIXELFORMAT)
        AhkTest.AssertEqual(4103, ddsdTextureFlags.value)
        AhkTest.AssertEqual("DDSD.PIXELFORMAT|WIDTH|HEIGHT|CAPS", String(ddsdTextureFlags))
        AhkTest.AssertEqual(98, plugin.DXGI_FORMAT.BC7_UNORM.value)
        AhkTest.AssertEqual("BC7_UNORM", plugin.DXGI_FORMAT.BC7_UNORM.name)
        AhkTest.AssertEqual("DXGI_FORMAT.BC7_UNORM", String(plugin.DXGI_FORMAT.BC7_UNORM))
        AhkTest.AssertEqual(827611204, plugin.D3DFMT.DXT1.value)
        AhkTest.AssertEqual("D3DFMT.DXT1", String(plugin.D3DFMT.DXT1))

        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("DDS rest")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("DDS")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("BAD!")))
        AhkTest.AssertEqual("DDS", plugin.DdsImageFile.format)
        AhkTest.AssertEqual("DirectDraw Surface", plugin.DdsImageFile.format_description)
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("DDS"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("DDS"))
        AhkTest.AssertTrue(stdlib.pillow.Image.DECODERS.Has("dds_rgb"))
        AhkTest.AssertEqual("DDS", stdlib.pillow.Image.registered_extensions()[".dds"])

        rgb := unset
        rgba := unset
        gray := unset
        la := unset
        openedRgb := unset
        openedRgba := unset
        openedGray := unset
        openedLa := unset
        try {
            rgb := stdlib.pillow.Image.new("RGB", [2, 2], [10, 20, 30])
            rgb.putpixel([1, 0], [200, 10, 5])
            rgbBuffer := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, rgb.save(rgbBuffer, "DDS"))
            rgbBytes := rgbBuffer.getvalue()
            AhkTest.AssertEqual([68, 68, 83, 32, 124, 0, 0, 0], StdlibPillowTest.ArraySlice(rgbBytes, 1, 8))
            AhkTest.AssertEqual(140, rgbBytes.Length)
            openedRgb := stdlib.pillow.Image.open(stdlib.io.BytesIO(rgbBytes), "r", ["DDS"])
            AhkTest.AssertEqual("DDS", openedRgb.format)
            AhkTest.AssertEqual("DirectDraw Surface", openedRgb.format_description)
            AhkTest.AssertEqual("RGB", openedRgb.mode)
            AhkTest.AssertEqual([2, 2], openedRgb.size)
            AhkTest.AssertEqual([200, 10, 5], openedRgb.getpixel([1, 0]))

            rgba := stdlib.pillow.Image.new("RGBA", [2, 2], [10, 20, 30, 40])
            rgba.putpixel([1, 0], [200, 10, 5, 128])
            rgbaBuffer := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, rgba.save(rgbaBuffer, "DDS"))
            rgbaBytes := rgbaBuffer.getvalue()
            AhkTest.AssertEqual(144, rgbaBytes.Length)
            openedRgba := stdlib.pillow.Image.open(stdlib.io.BytesIO(rgbaBytes), "r", ["DDS"])
            AhkTest.AssertEqual("RGBA", openedRgba.mode)
            AhkTest.AssertEqual([200, 10, 5, 128], openedRgba.getpixel([1, 0]))

            gray := stdlib.pillow.Image.new("L", [2, 2], 10)
            gray.putpixel([1, 0], 200)
            grayBuffer := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, gray.save(grayBuffer, "DDS"))
            grayBytes := grayBuffer.getvalue()
            AhkTest.AssertEqual(132, grayBytes.Length)
            openedGray := stdlib.pillow.Image.open(stdlib.io.BytesIO(grayBytes), "r", ["DDS"])
            AhkTest.AssertEqual("L", openedGray.mode)
            AhkTest.AssertEqual(200, openedGray.getpixel([1, 0]))

            la := stdlib.pillow.Image.new("LA", [2, 2], [10, 40])
            la.putpixel([1, 0], [200, 128])
            laBuffer := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, la.save(laBuffer, "DDS"))
            laBytes := laBuffer.getvalue()
            AhkTest.AssertEqual(136, laBytes.Length)
            openedLa := stdlib.pillow.Image.open(stdlib.io.BytesIO(laBytes), "r", ["DDS"])
            AhkTest.AssertEqual("LA", openedLa.mode)
            AhkTest.AssertEqual([200, 128], openedLa.getpixel([1, 0]))

            AhkTest.RaisesMatch(SyntaxError, "^not a DDS file$", (*) => plugin.DdsImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD!"))))
            AhkTest.RaisesMatch(OSError, "^Unsupported header size 123$", (*) => plugin.DdsImageFile(stdlib.io.BytesIO(StdlibPillowTest.DdsHeader(123, []))))
            AhkTest.RaisesMatch(OSError, "^Incomplete header: 10 bytes$", (*) => plugin.DdsImageFile(stdlib.io.BytesIO(StdlibPillowTest.DdsHeader(124, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]))))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.DdsImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.DdsImageFile(stdlib.io.BytesIO(rgbBytes), stdlib.None, "extra"))
            AhkTest.RaisesMatch(OSError, "^cannot write mode P as DDS$", (*) => stdlib.pillow.Image.new("P", [1, 1]).save(stdlib.io.BytesIO(), "DDS"))
            AhkTest.RaisesMatch(OSError, "^cannot write pixel format BAD$", (*) => rgb.save(stdlib.io.BytesIO(), "DDS", { pixel_format: "BAD" }))
            AhkTest.RaisesMatch(OSError, "^only RGB mode can be written as BC5$", (*) => gray.save(stdlib.io.BytesIO(), "DDS", { pixel_format: "BC5" }))
        } finally {
            if IsSet(openedLa)
                StdlibPillowTest.CloseImage(openedLa)
            if IsSet(openedGray)
                StdlibPillowTest.CloseImage(openedGray)
            if IsSet(openedRgba)
                StdlibPillowTest.CloseImage(openedRgba)
            if IsSet(openedRgb)
                StdlibPillowTest.CloseImage(openedRgb)
            if IsSet(la)
                StdlibPillowTest.CloseImage(la)
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
        }
    }

    static TestEpsImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "EpsImagePlugin"))
        plugin := stdlib.pillow.EpsImagePlugin

        basicBytes := StdlibPillowTest.AsciiBytes("%!PS-Adobe-3.0 EPSF-3.0`n%%Creator: probe`n%%BoundingBox: 1 2 5 8`n%%Pages: 1`n%%EndComments`nshowpage`n%%EOF`n")
        atendBytes := StdlibPillowTest.AsciiBytes("%!PS-Adobe-3.0 EPSF-3.0`n%%BoundingBox: (atend)`n%%EndComments`nshowpage`n%%Trailer`n%%BoundingBox: 10.5 20.0 14.5 26.0`n%%EOF`n")
        imagedataBytes := StdlibPillowTest.AsciiBytes("%!PS-Adobe-3.0 EPSF-3.0`n%%BoundingBox: 0 0 100 100`n%%EndComments`n%ImageData: 3 2 8 1 0 1 1 `"data`"`ndata`n000000`n%%EOF`n")
        macBytes := StdlibPillowTest.EpsMacBytes(basicBytes)

        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("%!PS-Adobe-3.0 EPSF-3.0`n")))
        AhkTest.AssertTrue(plugin._accept([0xC5, 0xD0, 0xD3, 0xC6, 114, 101, 115, 116]))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("%!P")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("BAD!")))
        AhkTest.AssertEqual("EPS", plugin.EpsImageFile.format)
        AhkTest.AssertEqual("Encapsulated Postscript", plugin.EpsImageFile.format_description)
        AhkTest.AssertEqual("L", plugin.EpsImageFile.mode_map[1])
        AhkTest.AssertEqual("LAB", plugin.EpsImageFile.mode_map[2])
        AhkTest.AssertEqual("RGB", plugin.EpsImageFile.mode_map[3])
        AhkTest.AssertEqual("CMYK", plugin.EpsImageFile.mode_map[4])
        AhkTest.AssertFalse(plugin.has_ghostscript())
        AhkTest.AssertFalse(plugin.gs_binary)
        AhkTest.AssertFalse(plugin.gs_windows_binary)
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("EPS"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("EPS"))
        AhkTest.AssertEqual("EPS", stdlib.pillow.Image.registered_extensions()[".eps"])
        AhkTest.AssertEqual("EPS", stdlib.pillow.Image.registered_extensions()[".ps"])
        AhkTest.AssertEqual("application/postscript", stdlib.pillow.Image.MIME["EPS"])

        basic := unset
        atend := unset
        imagedata := unset
        mac := unset
        rgb := unset
        gray := unset
        try {
            basic := plugin.EpsImageFile(stdlib.io.BytesIO(basicBytes))
            AhkTest.AssertEqual("EPS", basic.format)
            AhkTest.AssertEqual("Encapsulated Postscript", basic.format_description)
            AhkTest.AssertEqual("RGB", basic.mode)
            AhkTest.AssertEqual([4, 6], basic.size)
            AhkTest.AssertEqual("probe", basic.info["Creator"])
            AhkTest.AssertEqual("3.0 EPSF-3.0", basic.info["PS-Adobe"])
            AhkTest.AssertEqual("1 2 5 8", basic.info["BoundingBox"])
            AhkTest.AssertEqual("1", basic.info["Pages"])
            AhkTest.AssertEqual("eps", basic.tile[1])
            AhkTest.AssertEqual([0, 0, 4, 6], basic.tile[2])
            AhkTest.AssertEqual(0, basic.tile[3])
            AhkTest.AssertEqual([104, [1, 2, 5, 8]], basic.tile[4])
            AhkTest.RaisesMatch(OSError, "^Unable to locate Ghostscript on paths$", (*) => basic.load())

            atend := plugin.EpsImageFile(stdlib.io.BytesIO(atendBytes))
            AhkTest.AssertEqual([4, 6], atend.size)
            AhkTest.AssertEqual("10.5 20.0 14.5 26.0", atend.info["BoundingBox"])
            AhkTest.AssertEqual([121, [10, 20, 14, 26]], atend.tile[4])

            imagedata := plugin.EpsImageFile(stdlib.io.BytesIO(imagedataBytes))
            AhkTest.AssertEqual("RGB", imagedata.mode)
            AhkTest.AssertEqual([100, 100], imagedata.size)
            AhkTest.AssertEqual([116, [0, 0, 100, 100]], imagedata.tile[4])

            mac := plugin.EpsImageFile(stdlib.io.BytesIO(macBytes))
            AhkTest.AssertEqual([4, 6], mac.size)
            AhkTest.AssertEqual(12, mac.tile[3])

            rgb := stdlib.pillow.Image.new("RGB", [2, 1], [10, 20, 30])
            rgb.putpixel([1, 0], [200, 10, 5])
            rgbBuffer := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, rgb.save(rgbBuffer, "EPS"))
            rgbBytes := rgbBuffer.getvalue()
            AhkTest.AssertEqual(331, rgbBytes.Length)
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("%!PS-Adobe-3.0 EPSF-3.0`n"), StdlibPillowTest.ArraySlice(rgbBytes, 1, 24))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(rgbBytes, "%%BoundingBox: 0 0 2 1`n"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(rgbBytes, "%ImageData: 2 1 8 3 0 1 1 `"false 3 colorimage`"`n"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(rgbBytes, "0a141ec80a05"))

            gray := stdlib.pillow.Image.new("L", [2, 1], 10)
            gray.putpixel([1, 0], 200)
            grayBuffer := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, gray.save(grayBuffer, "EPS"))
            grayBytes := grayBuffer.getvalue()
            AhkTest.AssertEqual(297, grayBytes.Length)
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(grayBytes, "%ImageData: 2 1 8 1 0 1 1 `"image`"`n"))
            AhkTest.AssertTrue(StdlibPillowTest.BytesContainsAscii(grayBytes, "0ac8"))

            AhkTest.RaisesMatch(SyntaxError, "^not an EPS file$", (*) => plugin.EpsImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD!"))))
            AhkTest.RaisesMatch(SyntaxError, '^EPS header missing "%!PS-Adobe" comment$', (*) => plugin.EpsImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("%!PS`n%%BoundingBox: 0 0 1 1`n%%EOF`n"))))
            AhkTest.RaisesMatch(SyntaxError, '^EPS header missing "%%BoundingBox" comment$', (*) => plugin.EpsImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("%!PS-Adobe-3.0 EPSF-3.0`n%%EOF`n"))))
            AhkTest.RaisesMatch(OSError, "^cannot determine EPS bounding box$", (*) => plugin.EpsImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("%!PS-Adobe-3.0 EPSF-3.0`n%%BoundingBox: bad`n%%EOF`n"))))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.EpsImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.EpsImageFile(stdlib.io.BytesIO(basicBytes), stdlib.None, "extra"))
            AhkTest.RaisesMatch(ValueError, "^image mode is not supported$", (*) => stdlib.pillow.Image.new("RGBA", [1, 1]).save(stdlib.io.BytesIO(), "EPS"))
        } finally {
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
            if IsSet(mac)
                StdlibPillowTest.CloseImage(mac)
            if IsSet(imagedata)
                StdlibPillowTest.CloseImage(imagedata)
            if IsSet(atend)
                StdlibPillowTest.CloseImage(atend)
            if IsSet(basic)
                StdlibPillowTest.CloseImage(basic)
        }
    }

    static TestFitsImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "FitsImagePlugin"))
        plugin := stdlib.pillow.FitsImagePlugin

        fits8Bytes := StdlibPillowTest.FitsSimpleBytes(8, 2, [3, 2])
        fits16Bytes := StdlibPillowTest.FitsSimpleBytes(16, 2, [3, 2])
        fits32Bytes := StdlibPillowTest.FitsSimpleBytes(32, 2, [3, 2])
        fitsFloat32Bytes := StdlibPillowTest.FitsSimpleBytes(-32, 2, [3, 2])
        fitsFloat64Bytes := StdlibPillowTest.FitsSimpleBytes(-64, 2, [3, 2])
        fitsNaxis1Bytes := StdlibPillowTest.FitsSimpleBytes(8, 1, [5])
        fitsGzipBytes := StdlibPillowTest.FitsGzipBytes()

        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("SIMPLE  = T")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("SIMPL")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("BAD     = T")))
        AhkTest.AssertEqual("FITS", plugin.FitsImageFile.format)
        AhkTest.AssertEqual("FITS", plugin.FitsImageFile.format_description)
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("FITS"))
        AhkTest.AssertTrue(stdlib.pillow.Image.DECODERS.Has("fits_gzip"))
        AhkTest.AssertEqual("FITS", stdlib.pillow.Image.registered_extensions()[".fit"])
        AhkTest.AssertEqual("FITS", stdlib.pillow.Image.registered_extensions()[".fits"])

        opened := unset
        bitpix8 := unset
        bitpix16 := unset
        bitpix32 := unset
        float32 := unset
        float64 := unset
        naxis1 := unset
        gzip := unset
        try {
            bitpix8 := plugin.FitsImageFile(stdlib.io.BytesIO(fits8Bytes))
            AhkTest.AssertEqual("FITS", bitpix8.format)
            AhkTest.AssertEqual("FITS", bitpix8.format_description)
            AhkTest.AssertEqual("L", bitpix8.mode)
            AhkTest.AssertEqual([3, 2], bitpix8.size)
            AhkTest.AssertEqual(1, bitpix8.readonly)
            AhkTest.AssertEqual("raw", bitpix8.tile[1][1])
            AhkTest.AssertEqual([0, 0, 3, 2], bitpix8.tile[1][2])
            AhkTest.AssertEqual(2880, bitpix8.tile[1][3])
            AhkTest.AssertEqual(["L", 0, -1], bitpix8.tile[1][4])

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(fits8Bytes), "r", ["FITS"])
            AhkTest.AssertEqual("FITS", opened.format)
            AhkTest.AssertEqual("L", opened.mode)
            AhkTest.AssertEqual([3, 2], opened.size)
            AhkTest.AssertEqual(["L", 0, -1], opened.tile[1][4])

            bitpix16 := plugin.FitsImageFile(stdlib.io.BytesIO(fits16Bytes))
            AhkTest.AssertEqual("I;16", bitpix16.mode)
            AhkTest.AssertEqual(["I;16", 0, -1], bitpix16.tile[1][4])

            bitpix32 := plugin.FitsImageFile(stdlib.io.BytesIO(fits32Bytes))
            AhkTest.AssertEqual("I", bitpix32.mode)
            AhkTest.AssertEqual(["I", 0, -1], bitpix32.tile[1][4])

            float32 := plugin.FitsImageFile(stdlib.io.BytesIO(fitsFloat32Bytes))
            AhkTest.AssertEqual("F", float32.mode)
            AhkTest.AssertEqual(["F", 0, -1], float32.tile[1][4])

            float64 := plugin.FitsImageFile(stdlib.io.BytesIO(fitsFloat64Bytes))
            AhkTest.AssertEqual("F", float64.mode)
            AhkTest.AssertEqual(["F", 0, -1], float64.tile[1][4])

            naxis1 := plugin.FitsImageFile(stdlib.io.BytesIO(fitsNaxis1Bytes))
            AhkTest.AssertEqual([1, 5], naxis1.size)
            AhkTest.AssertEqual([0, 0, 1, 5], naxis1.tile[1][2])

            gzip := plugin.FitsImageFile(stdlib.io.BytesIO(fitsGzipBytes))
            AhkTest.AssertEqual("I;16", gzip.mode)
            AhkTest.AssertEqual([2, 2], gzip.size)
            AhkTest.AssertEqual("fits_gzip", gzip.tile[1][1])
            AhkTest.AssertEqual([0, 0, 2, 2], gzip.tile[1][2])
            AhkTest.AssertEqual(5772, gzip.tile[1][3])
            AhkTest.AssertEqual([16], gzip.tile[1][4])

            AhkTest.RaisesMatch(SyntaxError, "^Not a FITS file$", (*) => plugin.FitsImageFile(stdlib.io.BytesIO(StdlibPillowTest.FitsBadMagicBytes())))
            AhkTest.RaisesMatch(OSError, "^Truncated FITS file$", (*) => plugin.FitsImageFile(stdlib.io.BytesIO([])))
            AhkTest.RaisesMatch(ValueError, "^No image data$", (*) => plugin.FitsImageFile(stdlib.io.BytesIO(StdlibPillowTest.FitsSimpleBytes(8, 0, []))))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.FitsImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.FitsImageFile(stdlib.io.BytesIO(fits8Bytes), stdlib.None, "extra"))
        } finally {
            if IsSet(gzip)
                StdlibPillowTest.CloseImage(gzip)
            if IsSet(naxis1)
                StdlibPillowTest.CloseImage(naxis1)
            if IsSet(float64)
                StdlibPillowTest.CloseImage(float64)
            if IsSet(float32)
                StdlibPillowTest.CloseImage(float32)
            if IsSet(bitpix32)
                StdlibPillowTest.CloseImage(bitpix32)
            if IsSet(bitpix16)
                StdlibPillowTest.CloseImage(bitpix16)
            if IsSet(opened)
                StdlibPillowTest.CloseImage(opened)
            if IsSet(bitpix8)
                StdlibPillowTest.CloseImage(bitpix8)
        }
    }

    static TestFliImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "FliImagePlugin"))
        plugin := stdlib.pillow.FliImagePlugin

        simpleBytes := StdlibPillowTest.FliBytes()
        animatedBytes := StdlibPillowTest.FliBytes(0xAF12, 2)
        fliBytes := StdlibPillowTest.FliBytes(0xAF11, 1, 70)
        flcBytes := StdlibPillowTest.FliBytes(0xAF12, 1, 123)
        palette4Bytes := StdlibPillowTest.FliBytes(0xAF12, 1, 70, 0, [StdlibPillowTest.FliFrameChunk(StdlibPillowTest.FliPaletteSubchunk(4, [1, 2, 3]), 1)])
        palette11Bytes := StdlibPillowTest.FliBytes(0xAF12, 1, 70, 0, [StdlibPillowTest.FliFrameChunk(StdlibPillowTest.FliPaletteSubchunk(11, [1, 2, 3]), 1)])
        prefixBytes := StdlibPillowTest.FliBytes(0xAF12, 1, 70, 0, [StdlibPillowTest.FliPrefixChunk(), StdlibPillowTest.FliFrameChunk()])

        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.ArraySlice(simpleBytes, 1, 16)))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.ArraySlice(fliBytes, 1, 16)))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.ArraySlice(StdlibPillowTest.FliBytes(0xAF12, 1, 70, 3), 1, 16)))
        AhkTest.AssertFalse(plugin._accept([1, 2, 3, 4, 5]))
        badMagicBytes := StdlibPillowTest.FliBytes(0x1234)
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.ArraySlice(badMagicBytes, 1, 16)))
        badFlagsBytes := StdlibPillowTest.FliBytes(0xAF12, 1, 70, 1)
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.ArraySlice(badFlagsBytes, 1, 16)))
        AhkTest.AssertEqual("FLI", plugin.FliImageFile.format)
        AhkTest.AssertEqual("Autodesk FLI/FLC Animation", plugin.FliImageFile.format_description)
        AhkTest.AssertFalse(plugin.FliImageFile._close_exclusive_fp_after_loading)
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("FLI"))
        AhkTest.AssertEqual("FLI", stdlib.pillow.Image.registered_extensions()[".fli"])
        AhkTest.AssertEqual("FLI", stdlib.pillow.Image.registered_extensions()[".flc"])

        simple := unset
        animated := unset
        fli := unset
        flc := unset
        palette4 := unset
        palette11 := unset
        prefix := unset
        opened := unset
        try {
            simple := plugin.FliImageFile(stdlib.io.BytesIO(simpleBytes))
            AhkTest.AssertEqual("FLI", simple.format)
            AhkTest.AssertEqual("Autodesk FLI/FLC Animation", simple.format_description)
            AhkTest.AssertEqual("P", simple.mode)
            AhkTest.AssertEqual([3, 2], simple.size)
            AhkTest.AssertEqual(1, simple.n_frames)
            AhkTest.AssertFalse(simple.is_animated)
            AhkTest.AssertEqual(70, simple.info["duration"])
            AhkTest.AssertEqual(0, simple.tell())
            AhkTest.AssertEqual(16, simple.decodermaxblock)
            AhkTest.AssertEqual("fli", simple.tile[1][1])
            AhkTest.AssertEqual([0, 0, 3, 2], simple.tile[1][2])
            AhkTest.AssertEqual(128, simple.tile[1][3])
            AhkTest.AssertSame(stdlib.None, simple.tile[1][4])
            AhkTest.AssertEqual("RGB", simple.palette.mode)
            AhkTest.AssertEqual([0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3], StdlibPillowTest.ArraySlice(simple.palette.palette, 1, 12))
            AhkTest.AssertSame(stdlib.None, simple.seek(0))
            AhkTest.AssertEqual(0, simple.tell())

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(simpleBytes), "r", ["FLI"])
            AhkTest.AssertEqual("FLI", opened.format)
            AhkTest.AssertEqual("P", opened.mode)
            AhkTest.AssertEqual([3, 2], opened.size)

            animated := plugin.FliImageFile(stdlib.io.BytesIO(animatedBytes))
            AhkTest.AssertEqual(2, animated.n_frames)
            AhkTest.AssertTrue(animated.is_animated)

            fli := plugin.FliImageFile(stdlib.io.BytesIO(fliBytes))
            AhkTest.AssertEqual(1000, fli.info["duration"])

            flc := plugin.FliImageFile(stdlib.io.BytesIO(flcBytes))
            AhkTest.AssertEqual(123, flc.info["duration"])

            palette4 := plugin.FliImageFile(stdlib.io.BytesIO(palette4Bytes))
            AhkTest.AssertEqual(29, palette4.decodermaxblock)
            AhkTest.AssertEqual([1, 2, 3, 1, 1, 1], StdlibPillowTest.ArraySlice(palette4.palette.palette, 1, 6))

            palette11 := plugin.FliImageFile(stdlib.io.BytesIO(palette11Bytes))
            AhkTest.AssertEqual(29, palette11.decodermaxblock)
            AhkTest.AssertEqual([4, 8, 12, 1, 1, 1], StdlibPillowTest.ArraySlice(palette11.palette.palette, 1, 6))

            prefix := plugin.FliImageFile(stdlib.io.BytesIO(prefixBytes))
            AhkTest.AssertEqual(128, prefix.tile[1][3])
            AhkTest.AssertEqual(16, prefix.decodermaxblock)

            badReservedBytes := StdlibPillowTest.FliBytes()
            badReservedBytes[21] := 1
            AhkTest.RaisesMatch(SyntaxError, "^not an FLI/FLC file$", (*) => plugin.FliImageFile(stdlib.io.BytesIO(badMagicBytes)))
            AhkTest.RaisesMatch(SyntaxError, "^not an FLI/FLC file$", (*) => plugin.FliImageFile(stdlib.io.BytesIO(badFlagsBytes)))
            AhkTest.RaisesMatch(SyntaxError, "^not an FLI/FLC file$", (*) => plugin.FliImageFile(stdlib.io.BytesIO(badReservedBytes)))
            AhkTest.RaisesMatch(SyntaxError, "^unpack_from requires a buffer of at least 6 bytes for unpacking 2 bytes at offset 4 \(actual buffer size is 0\)$", (*) => plugin.FliImageFile(stdlib.io.BytesIO(StdlibPillowTest.FliHeader())))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.FliImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.FliImageFile(stdlib.io.BytesIO(simpleBytes), stdlib.None, "extra"))
            AhkTest.RaisesMatch(EOFError, "^attempt to seek outside sequence$", (*) => simple.seek(-1))
            AhkTest.RaisesMatch(EOFError, "^attempt to seek outside sequence$", (*) => simple.seek(1))
        } finally {
            if IsSet(opened)
                StdlibPillowTest.CloseImage(opened)
            if IsSet(prefix)
                StdlibPillowTest.CloseImage(prefix)
            if IsSet(palette11)
                StdlibPillowTest.CloseImage(palette11)
            if IsSet(palette4)
                StdlibPillowTest.CloseImage(palette4)
            if IsSet(flc)
                StdlibPillowTest.CloseImage(flc)
            if IsSet(fli)
                StdlibPillowTest.CloseImage(fli)
            if IsSet(animated)
                StdlibPillowTest.CloseImage(animated)
            if IsSet(simple)
                StdlibPillowTest.CloseImage(simple)
        }
    }

    static TestFpxImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "FpxImagePlugin"))
        plugin := stdlib.pillow.FpxImagePlugin

        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.FpxMagicBytes([114, 101, 115, 116])))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.ArraySlice(StdlibPillowTest.FpxMagicBytes(), 1, 7)))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("BAD!")))
        AhkTest.AssertEqual("FPX", plugin.FpxImageFile.format)
        AhkTest.AssertEqual("FlashPix", plugin.FpxImageFile.format_description)
        AhkTest.AssertEqual(["RGB", "RGB"], plugin.MODES["(196608, 196609, 196610)"])
        AhkTest.AssertEqual(["L", "L"], plugin.MODES["(65536,)"])
        AhkTest.AssertEqual(["RGBA", "RGBA"], plugin.MODES["(229376, 229377, 229378, 229374)"])
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("FPX"))
        AhkTest.AssertEqual("FPX", stdlib.pillow.Image.registered_extensions()[".fpx"])
        AhkTest.RaisesMatch(SyntaxError, "^not an FPX file; invalid OLE file$", (*) => plugin.FpxImageFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD!"))))

        oldOlefile := plugin.olefile
        rgb := unset
        opened := unset
        gray := unset
        fill := unset
        jpeg := unset
        try {
            fakeModule := StdlibPillowFpxFakeOleModule()
            plugin.olefile := fakeModule

            fakeModule.Scenario := StdlibPillowFpxScenario()
            rgb := plugin.FpxImageFile(stdlib.io.BytesIO(StdlibPillowTest.FpxMagicBytes()))
            AhkTest.AssertEqual("FPX", rgb.format)
            AhkTest.AssertEqual("FlashPix", rgb.format_description)
            AhkTest.AssertEqual("RGB", rgb.mode)
            AhkTest.AssertEqual("RGB", rgb.rawmode)
            AhkTest.AssertEqual([128, 64], rgb.size)
            AhkTest.AssertEqual(1, rgb.maxid)
            AhkTest.AssertEqual(["Data Object Store 000001", "Resolution 0001", "Subimage 0000 Header"], rgb.stream)
            AhkTest.AssertTrue(rgb.fp_is_none)
            AhkTest.AssertEqual(2, rgb.tile.Length)
            AhkTest.AssertEqual(["raw", [0, 0, 64, 64], 128, "RGB"], rgb.tile[1])
            AhkTest.AssertEqual(["raw", [64, 0, 128, 64], 228, "RGB"], rgb.tile[2])
            AhkTest.AssertEqual(0, fakeModule.ClosedCount)
            rgb.close()
            AhkTest.AssertEqual(1, fakeModule.ClosedCount)

            fakeModule.Scenario := StdlibPillowFpxScenario()
            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(StdlibPillowTest.FpxMagicBytes()), "r", ["FPX"])
            AhkTest.AssertEqual("FPX", opened.format)
            AhkTest.AssertEqual("RGB", opened.mode)
            AhkTest.AssertEqual([128, 64], opened.size)

            fakeModule.Scenario := StdlibPillowFpxScenario({ size: [64, 64], maxid: 0, colors: [0x00010000], header_stream: StdlibPillowTest.FpxHeaderStream([64, 64], [64, 64], [StdlibPillowTest.FpxDescriptor(100, 0)]) })
            gray := plugin.FpxImageFile(stdlib.io.BytesIO(StdlibPillowTest.FpxMagicBytes()))
            AhkTest.AssertEqual("L", gray.mode)
            AhkTest.AssertEqual("L", gray.rawmode)
            AhkTest.AssertEqual(["raw", [0, 0, 64, 64], 128, "L"], gray.tile[1])

            fakeModule.Scenario := StdlibPillowFpxScenario({ size: [64, 64], maxid: 0, colors: [0x00038000, 0x00038001, 0x00038002, 0x00037FFE], header_stream: StdlibPillowTest.FpxHeaderStream([64, 64], [64, 64], [StdlibPillowTest.FpxDescriptor(100, 1, [97, 98, 99, 100])]) })
            fill := plugin.FpxImageFile(stdlib.io.BytesIO(StdlibPillowTest.FpxMagicBytes()))
            AhkTest.AssertEqual("RGBA", fill.mode)
            AhkTest.AssertEqual("RGBA", fill.rawmode)
            AhkTest.AssertEqual(["fill", [0, 0, 64, 64], 128, ["RGBA", [97, 98, 99, 100]]], fill.tile[1])

            fakeModule.Scenario := StdlibPillowFpxScenario({
                size: [64, 64],
                maxid: 0,
                colors: [0x00020000, 0x00020001, 0x00020002],
                extra_props: Map(0x3000001 | (7 << 16), StdlibPillowTest.AsciiBytes("JPEG-TABLE")),
                header_stream: StdlibPillowTest.FpxHeaderStream([64, 64], [64, 64], [StdlibPillowTest.FpxDescriptor(100, 2, [0, 0, 1, 7])])
            })
            jpeg := plugin.FpxImageFile(stdlib.io.BytesIO(StdlibPillowTest.FpxMagicBytes()))
            AhkTest.AssertEqual("RGB", jpeg.mode)
            AhkTest.AssertEqual("YCC;P", jpeg.rawmode)
            AhkTest.AssertEqual([7], jpeg.jpeg_keys)
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("JPEG-TABLE"), jpeg.tile_prefix)
            AhkTest.AssertEqual(["jpeg", [0, 0, 64, 64], 128, ["YCC;P", stdlib.None]], jpeg.tile[1])

            fakeModule.Scenario := StdlibPillowFpxScenario({ clsid: "00000000-0000-0000-0000-000000000000" })
            AhkTest.RaisesMatch(SyntaxError, "^not an FPX file; bad root CLSID$", (*) => plugin.FpxImageFile(stdlib.io.BytesIO(StdlibPillowTest.FpxMagicBytes())))
            fakeModule.Scenario := StdlibPillowFpxScenario({ size: [64, 64], maxid: 0, mode_blob: StdlibPillowTest.FpxModeBlob([1, 2, 3, 4, 5]), header_stream: StdlibPillowTest.FpxHeaderStream([64, 64], [64, 64], [StdlibPillowTest.FpxDescriptor(100, 0)]) })
            AhkTest.RaisesMatch(OSError, "^Invalid number of bands$", (*) => plugin.FpxImageFile(stdlib.io.BytesIO(StdlibPillowTest.FpxMagicBytes())))
            fakeModule.Scenario := StdlibPillowFpxScenario({ size: [64, 64], maxid: 0, colors: [12345], header_stream: StdlibPillowTest.FpxHeaderStream([64, 64], [64, 64], [StdlibPillowTest.FpxDescriptor(100, 0)]) })
            AhkTest.RaisesMatch(SyntaxError, "^\(12345,\)$", (*) => plugin.FpxImageFile(stdlib.io.BytesIO(StdlibPillowTest.FpxMagicBytes())))
            fakeModule.Scenario := StdlibPillowFpxScenario({ size: [64, 64], maxid: 0, header_stream: StdlibPillowTest.FpxHeaderStream([32, 64], [64, 64], [StdlibPillowTest.FpxDescriptor(100, 0)]) })
            AhkTest.RaisesMatch(OSError, "^subimage mismatch$", (*) => plugin.FpxImageFile(stdlib.io.BytesIO(StdlibPillowTest.FpxMagicBytes())))
            fakeModule.Scenario := StdlibPillowFpxScenario({ size: [64, 64], maxid: 0, header_stream: StdlibPillowTest.FpxHeaderStream([64, 64], [64, 64], [StdlibPillowTest.FpxDescriptor(100, 9)]) })
            AhkTest.RaisesMatch(OSError, "^unknown/invalid compression$", (*) => plugin.FpxImageFile(stdlib.io.BytesIO(StdlibPillowTest.FpxMagicBytes())))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.FpxImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.FpxImageFile(stdlib.io.BytesIO(StdlibPillowTest.FpxMagicBytes()), stdlib.None, "extra"))
        } finally {
            plugin.olefile := oldOlefile
            if IsSet(jpeg)
                StdlibPillowTest.CloseImage(jpeg)
            if IsSet(fill)
                StdlibPillowTest.CloseImage(fill)
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
            if IsSet(opened)
                StdlibPillowTest.CloseImage(opened)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
        }
    }

    static TestFtexImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "FtexImagePlugin"))
        plugin := stdlib.pillow.FtexImagePlugin

        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("FTEXrest")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("FTE")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("BAD!")))
        AhkTest.AssertEqual(0, plugin.Format.DXT1.value)
        AhkTest.AssertEqual("DXT1", plugin.Format.DXT1.name)
        AhkTest.AssertEqual("Format.DXT1", String(plugin.Format.DXT1))
        AhkTest.AssertEqual("<Format.DXT1: 0>", plugin.Format.DXT1.__Repr())
        AhkTest.AssertEqual(1, plugin.Format.UNCOMPRESSED.value)
        AhkTest.AssertEqual("UNCOMPRESSED", plugin.Format.UNCOMPRESSED.name)
        AhkTest.AssertEqual("Format.UNCOMPRESSED", String(plugin.Format.UNCOMPRESSED))
        AhkTest.AssertEqual("<Format.UNCOMPRESSED: 1>", plugin.Format.UNCOMPRESSED.__Repr())
        AhkTest.AssertEqual("FTEX", plugin.FtexImageFile.format)
        AhkTest.AssertEqual("Texture File Format (IW2:EOC)", plugin.FtexImageFile.format_description)
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("FTEX"))
        AhkTest.AssertEqual("FTEX", stdlib.pillow.Image.registered_extensions()[".ftc"])
        AhkTest.AssertEqual("FTEX", stdlib.pillow.Image.registered_extensions()[".ftu"])

        rgbData := StdlibPillowTest.FtexBytes(2, 2, plugin.Format.UNCOMPRESSED.value, [
            10, 20, 30,
            40, 50, 60,
            70, 80, 90,
            100, 110, 120,
        ])
        dxtData := StdlibPillowTest.FtexBytes(4, 4, plugin.Format.DXT1.value, [0, 248, 224, 7, 0, 0, 0, 0])
        rgb := unset
        opened := unset
        dxt := unset
        try {
            rgb := plugin.FtexImageFile(stdlib.io.BytesIO(rgbData))
            AhkTest.AssertEqual("FTEX", rgb.format)
            AhkTest.AssertEqual("Texture File Format (IW2:EOC)", rgb.format_description)
            AhkTest.AssertEqual("RGB", rgb.mode)
            AhkTest.AssertEqual([2, 2], rgb.size)
            AhkTest.AssertEqual(["raw", [0, 0, 2, 2], 0, "RGB"], rgb.tile[1])
            AhkTest.AssertEqual([10, 20, 30], rgb.getpixel([0, 0]))
            AhkTest.AssertEqual([40, 50, 60], rgb.getpixel([1, 0]))
            AhkTest.AssertEqual(0, rgb.tile.Length)

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(rgbData), "r", ["FTEX"])
            AhkTest.AssertEqual("FTEX", opened.format)
            AhkTest.AssertEqual("RGB", opened.mode)
            AhkTest.AssertEqual([2, 2], opened.size)
            AhkTest.AssertEqual([40, 50, 60], opened.getpixel([1, 0]))

            dxt := plugin.FtexImageFile(stdlib.io.BytesIO(dxtData))
            AhkTest.AssertEqual("RGBA", dxt.mode)
            AhkTest.AssertEqual([4, 4], dxt.size)
            AhkTest.AssertEqual(["bcn", [0, 0, 4, 4], 0, [1]], dxt.tile[1])

            badMagic := StdlibPillowTest.FtexBytes(1, 1, plugin.Format.UNCOMPRESSED.value, [1, 2, 3])
            badMagic[1] := 66
            AhkTest.RaisesMatch(SyntaxError, "^not an FTEX file$", (*) => plugin.FtexImageFile(stdlib.io.BytesIO(badMagic)))
            AhkTest.RaisesMatch(SyntaxError, "^unpack requires a buffer of 4 bytes$", (*) => plugin.FtexImageFile(stdlib.io.BytesIO([70, 84, 69, 88, 1, 0])))
            AhkTest.RaisesMatch(ValueError, "^Invalid texture compression format: 9$", (*) => plugin.FtexImageFile(stdlib.io.BytesIO(StdlibPillowTest.FtexBytes(1, 1, 9, [1, 2, 3]))))
            AhkTest.RaisesMatch(AssertionError, "^$", (*) => plugin.FtexImageFile(stdlib.io.BytesIO(StdlibPillowTest.FtexBytes(1, 1, plugin.Format.UNCOMPRESSED.value, [1, 2, 3], 1, 1, 2))))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.FtexImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.FtexImageFile(stdlib.io.BytesIO(rgbData), stdlib.None, "extra"))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file <AhkStdlibIoBytesIO object>$", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(badMagic), "r", ["FTEX"]))
        } finally {
            if IsSet(dxt)
                StdlibPillowTest.CloseImage(dxt)
            if IsSet(opened)
                StdlibPillowTest.CloseImage(opened)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
        }
    }

    static TestGbrImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "GbrImagePlugin"))
        plugin := stdlib.pillow.GbrImagePlugin

        grayBytes := StdlibPillowTest.GbrBytes(2, 2, 1, [1, 2, 3, 4], 2, "gray", 9)
        rgbaBytes := StdlibPillowTest.GbrBytes(2, 1, 4, [10, 20, 30, 40, 50, 60, 70, 80], 1, "rgba")
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.ArraySlice(grayBytes, 1, 8)))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.ArraySlice(rgbaBytes, 1, 8)))
        AhkTest.AssertFalse(plugin._accept([0, 0, 0]))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.GbrPrefix(19, 1)))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.GbrPrefix(20, 3)))
        AhkTest.AssertEqual("GBR", plugin.GbrImageFile.format)
        AhkTest.AssertEqual("GIMP brush file", plugin.GbrImageFile.format_description)
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("GBR"))
        AhkTest.AssertEqual("GBR", stdlib.pillow.Image.registered_extensions()[".gbr"])

        gray := unset
        opened := unset
        rgba := unset
        try {
            gray := plugin.GbrImageFile(stdlib.io.BytesIO(grayBytes))
            AhkTest.AssertEqual("GBR", gray.format)
            AhkTest.AssertEqual("GIMP brush file", gray.format_description)
            AhkTest.AssertEqual("L", gray.mode)
            AhkTest.AssertEqual([2, 2], gray.size)
            AhkTest.AssertEqual(4, gray._data_size)
            AhkTest.AssertEqual(9, gray.info["spacing"])
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("gray"), gray.info["comment"])
            AhkTest.AssertEqual(1, gray.getpixel([0, 0]))
            AhkTest.AssertEqual(4, gray.getpixel([1, 1]))
            AhkTest.AssertEqual(0, gray.tile.Length)

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(grayBytes), "r", ["GBR"])
            AhkTest.AssertEqual("GBR", opened.format)
            AhkTest.AssertEqual("L", opened.mode)
            AhkTest.AssertEqual([2, 2], opened.size)
            AhkTest.AssertEqual(4, opened.getpixel([1, 1]))

            rgba := plugin.GbrImageFile(stdlib.io.BytesIO(rgbaBytes))
            AhkTest.AssertEqual("RGBA", rgba.mode)
            AhkTest.AssertEqual([2, 1], rgba.size)
            AhkTest.AssertEqual(8, rgba._data_size)
            AhkTest.AssertFalse(rgba.info.Has("spacing"))
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("rgba"), rgba.info["comment"])
            AhkTest.AssertEqual([10, 20, 30, 40], rgba.getpixel([0, 0]))
            AhkTest.AssertEqual([50, 60, 70, 80], rgba.getpixel([1, 0]))

            AhkTest.RaisesMatch(SyntaxError, "^not a GIMP brush$", (*) => plugin.GbrImageFile(stdlib.io.BytesIO(StdlibPillowTest.GbrBytes(1, 1, 1, [1], 1, "x", 0, 19))))
            AhkTest.RaisesMatch(SyntaxError, "^Unsupported GIMP brush version: 3$", (*) => plugin.GbrImageFile(stdlib.io.BytesIO(StdlibPillowTest.GbrBytes(1, 1, 1, [1], 3, "x"))))
            AhkTest.RaisesMatch(SyntaxError, "^not a GIMP brush$", (*) => plugin.GbrImageFile(stdlib.io.BytesIO(StdlibPillowTest.GbrBytes(0, 1, 1, [1], 1, "x"))))
            AhkTest.RaisesMatch(SyntaxError, "^Unsupported GIMP brush color depth: 2$", (*) => plugin.GbrImageFile(stdlib.io.BytesIO(StdlibPillowTest.GbrBytes(1, 1, 2, [1, 2], 1, "x"))))
            AhkTest.RaisesMatch(SyntaxError, "^not a GIMP brush, bad magic number$", (*) => plugin.GbrImageFile(stdlib.io.BytesIO(StdlibPillowTest.GbrBytes(1, 1, 1, [1], 2, "x", 0, { magic: "BAD!" }))))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.GbrImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.GbrImageFile(stdlib.io.BytesIO(grayBytes), stdlib.None, "extra"))
        } finally {
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
            if IsSet(opened)
                StdlibPillowTest.CloseImage(opened)
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
        }
    }

    static TestGdImageFileMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "GdImageFile"))
        module := stdlib.pillow.GdImageFile
        AhkTest.AssertEqual(65534, module.i16([255, 254]))
        AhkTest.AssertEqual(305419896, module.i32([0x12, 0x34, 0x56, 0x78]))
        AhkTest.AssertEqual("GD", module.GdImageFile.format)
        AhkTest.AssertEqual("GD uncompressed images", module.GdImageFile.format_description)
        AhkTest.AssertFalse(stdlib.pillow.Image.OPEN.Has("GD"))
        AhkTest.AssertFalse(stdlib.pillow.Image.registered_extensions().Has(".gd"))

        indexedBytes := StdlibPillowTest.GdBytes(3, 2, 0, 2, [0, 1, 2, 3, 4, 5])
        trueColorBytes := StdlibPillowTest.GdBytes(3, 2, 1, 2, [0, 1, 2, 3, 4, 5])
        noTransparencyBytes := StdlibPillowTest.GdBytes(1, 1, 0, 256, [7])
        path := StdlibPillowTest.TempPath("sample.gd")
        StdlibPillowTest.WriteBytes(path, StdlibPillowTest.GdBytes(2, 1, 0, 2, [5, 6]))

        indexed := unset
        trueColor := unset
        openedStream := unset
        openedPath := unset
        noTransparency := unset
        try {
            indexed := module.GdImageFile(stdlib.io.BytesIO(indexedBytes))
            AhkTest.AssertEqual("GD", indexed.format)
            AhkTest.AssertEqual("GD uncompressed images", indexed.format_description)
            AhkTest.AssertEqual("P", indexed.mode)
            AhkTest.AssertEqual([3, 2], indexed.size)
            AhkTest.AssertEqual(2, indexed.info["transparency"])
            AhkTest.AssertEqual(["raw", [0, 0, 3, 2], 1037, "L"], indexed.tile[1])
            indexedPaletteData := indexed.palette.getdata()
            AhkTest.AssertEqual("RGBX", indexedPaletteData[1])
            AhkTest.AssertEqual([0, 0, 0, 99, 3, 5, 7, 99, 6, 10, 14, 99], StdlibPillowTest.ArraySlice(indexedPaletteData[2], 1, 12))
            AhkTest.AssertEqual([0, 1, 2, 3, 4, 5], indexed.getdata())
            AhkTest.AssertEqual(0, indexed.tile.Length)

            trueColor := module.GdImageFile(stdlib.io.BytesIO(trueColorBytes))
            AhkTest.AssertEqual(["raw", [0, 0, 3, 2], 1039, "L"], trueColor.tile[1])
            AhkTest.AssertEqual([0, 1, 2, 3, 4, 5], trueColor.getdata())
            AhkTest.AssertEqual(0, trueColor.tile.Length)

            openedStream := module.open(stdlib.io.BytesIO(StdlibPillowTest.GdBytes(2, 1, 0, 2, [7, 8])))
            AhkTest.AssertEqual("GD", openedStream.format)
            AhkTest.AssertEqual([2, 1], openedStream.size)
            AhkTest.AssertEqual([7, 8], openedStream.getdata())

            openedPath := module.open(path)
            AhkTest.AssertEqual("GD", openedPath.format)
            AhkTest.AssertEqual([2, 1], openedPath.size)
            AhkTest.AssertEqual([5, 6], openedPath.getdata())

            noTransparency := module.GdImageFile(stdlib.io.BytesIO(noTransparencyBytes))
            AhkTest.AssertFalse(noTransparency.info.Has("transparency"))

            AhkTest.RaisesMatch(ValueError, "^bad mode$", (*) => module.open(stdlib.io.BytesIO(indexedBytes), "w"))
            AhkTest.RaisesMatch(stdlib.pillow.Image.UnidentifiedImageError, "^cannot identify this image file$", (*) => module.open(stdlib.io.BytesIO(StdlibPillowTest.GdBytes(1, 1, 0, 2, [1], 1))))
            AhkTest.RaisesMatch(SyntaxError, "^Not a valid GD 2\.x \.gd file$", (*) => module.GdImageFile(stdlib.io.BytesIO(StdlibPillowTest.GdBytes(1, 1, 0, 2, [1], 1))))
            AhkTest.RaisesMatch(SyntaxError, "^unpack_from requires a buffer of at least 2 bytes for unpacking 2 bytes at offset 0 \(actual buffer size is 0\)$", (*) => module.GdImageFile(stdlib.io.BytesIO([])))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => module.GdImageFile())
            AhkTest.RaisesMatch(TypeError, "^open\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => module.open(stdlib.io.BytesIO(indexedBytes), "r", "extra"))
            AhkTest.RaisesMatch(KeyError, "^'GD'$", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(indexedBytes), "r", ["GD"]))
        } finally {
            if IsSet(noTransparency)
                StdlibPillowTest.CloseImage(noTransparency)
            if IsSet(openedPath)
                StdlibPillowTest.CloseImage(openedPath)
            if IsSet(openedStream)
                StdlibPillowTest.CloseImage(openedStream)
            if IsSet(trueColor)
                StdlibPillowTest.CloseImage(trueColor)
            if IsSet(indexed)
                StdlibPillowTest.CloseImage(indexed)
            if FileExist(path)
                FileDelete path
        }
    }

    static TestGifImagePluginMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "GifImagePlugin"))
        plugin := stdlib.pillow.GifImagePlugin

        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("GIF87a123")))
        AhkTest.AssertTrue(plugin._accept(StdlibPillowTest.AsciiBytes("GIF89a123")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("GIF")))
        AhkTest.AssertFalse(plugin._accept(StdlibPillowTest.AsciiBytes("BAD89a")))
        AhkTest.AssertEqual("GIF", plugin.GifImageFile.format)
        AhkTest.AssertEqual("Compuserve GIF", plugin.GifImageFile.format_description)
        AhkTest.AssertFalse(plugin.GifImageFile._close_exclusive_fp_after_loading)
        AhkTest.AssertSame(stdlib.None, plugin.GifImageFile.global_palette)
        AhkTest.AssertEqual("L", plugin.RAWMODE["1"])
        AhkTest.AssertEqual("L", plugin.RAWMODE["L"])
        AhkTest.AssertEqual("P", plugin.RAWMODE["P"])
        AhkTest.AssertEqual(0, plugin.LoadingStrategy.RGB_AFTER_FIRST.value)
        AhkTest.AssertEqual("RGB_AFTER_FIRST", plugin.LoadingStrategy.RGB_AFTER_FIRST.name)
        AhkTest.AssertEqual("LoadingStrategy.RGB_AFTER_FIRST", String(plugin.LoadingStrategy.RGB_AFTER_FIRST))
        AhkTest.AssertEqual("<LoadingStrategy.RGB_AFTER_FIRST: 0>", plugin.LoadingStrategy.RGB_AFTER_FIRST.__Repr())
        AhkTest.AssertEqual(1, plugin.LoadingStrategy.RGB_AFTER_DIFFERENT_PALETTE_ONLY.value)
        AhkTest.AssertEqual(2, plugin.LoadingStrategy.RGB_ALWAYS.value)
        AhkTest.AssertEqual(plugin.LoadingStrategy.RGB_AFTER_FIRST, plugin.LOADING_STRATEGY)
        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN.Has("GIF"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has("GIF"))
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE_ALL.Has("GIF"))
        AhkTest.AssertEqual("GIF", stdlib.pillow.Image.registered_extensions()[".gif"])
        AhkTest.AssertEqual("image/gif", stdlib.pillow.Image.MIME["GIF"])

        gif89Bytes := StdlibPillowTest.GifBytes()
        gif87Bytes := StdlibPillowTest.GifBytes("GIF87a", false, false, false)
        badBytes := gif89Bytes.Clone()
        badBytes[1] := 66
        direct := unset
        opened := unset
        gif87 := unset
        roundtrip := unset
        try {
            direct := plugin.GifImageFile(stdlib.io.BytesIO(gif89Bytes))
            AhkTest.AssertEqual("GIF", direct.format)
            AhkTest.AssertEqual("Compuserve GIF", direct.format_description)
            AhkTest.AssertEqual("P", direct.mode)
            AhkTest.AssertEqual([2, 2], direct.size)
            AhkTest.AssertEqual(1, direct.info["background"])
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("GIF89a"), direct.info["version"])
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("hello"), direct.info["comment"])
            AhkTest.AssertEqual(50, direct.info["duration"])
            AhkTest.AssertEqual(7, direct.info["loop"])
            AhkTest.AssertEqual(2, direct.info["transparency"])
            AhkTest.AssertEqual([StdlibPillowTest.AsciiBytes("NETSCAPE2.0"), 48], direct.info["extension"])
            AhkTest.AssertEqual(1, direct.n_frames)
            AhkTest.AssertFalse(direct.is_animated)
            AhkTest.AssertEqual(0, direct.tell())
            AhkTest.AssertEqual(["gif", [0, 0, 2, 2], 72, [2, false, -1]], direct.tile[1])
            directPalette := direct.palette.getdata()
            AhkTest.AssertEqual("RGB", directPalette[1])
            AhkTest.AssertEqual([0, 0, 0, 255, 0, 0, 0, 255, 0, 0, 0, 255], StdlibPillowTest.ArraySlice(directPalette[2], 1, 12))
            AhkTest.AssertEqual([0, 1, 2, 3], direct.getdata())
            AhkTest.AssertEqual(0, direct.tile.Length)

            opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(gif89Bytes), "r", ["GIF"])
            AhkTest.AssertEqual("GIF", opened.format)
            AhkTest.AssertEqual("P", opened.mode)
            AhkTest.AssertEqual([2, 2], opened.size)
            AhkTest.AssertEqual([0, 1, 2, 3], opened.getdata())

            gif87 := plugin.GifImageFile(stdlib.io.BytesIO(gif87Bytes))
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("GIF87a"), gif87.info["version"])
            AhkTest.AssertFalse(gif87.info.Has("transparency"))
            AhkTest.AssertFalse(gif87.info.Has("comment"))
            AhkTest.AssertFalse(gif87.info.Has("loop"))
            AhkTest.AssertEqual(["gif", [0, 0, 2, 2], 36, [2, false, -1]], gif87.tile[1])
            AhkTest.AssertEqual([0, 1, 2, 3], gif87.getdata())

            roundtrip := stdlib.pillow.Image.new("P", [2, 2])
            roundtrip.putpalette([
                0, 0, 0,
                255, 0, 0,
                0, 255, 0,
                0, 0, 255,
            ])
            roundtrip.putdata([0, 1, 2, 3])
            output := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, roundtrip.save(output, "GIF", { transparency: 0, loop: 3, duration: 40, comment: StdlibPillowTest.AsciiBytes("ok") }))
            savedBytes := output.getvalue()
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("GIF89a"), StdlibPillowTest.ArraySlice(savedBytes, 1, 6))
            saved := stdlib.pillow.Image.open(stdlib.io.BytesIO(savedBytes), "r", ["GIF"])
            try {
                AhkTest.AssertEqual("GIF", saved.format)
                AhkTest.AssertEqual([2, 2], saved.size)
                AhkTest.AssertEqual([0, 1, 2, 3], saved.getdata())
                AhkTest.AssertEqual(0, saved.info["transparency"])
                AhkTest.AssertEqual(3, saved.info["loop"])
                AhkTest.AssertEqual(40, saved.info["duration"])
                AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("ok"), saved.info["comment"])
            } finally {
                StdlibPillowTest.CloseImage(saved)
            }

            multiAppend := stdlib.pillow.Image.new("P", [2, 2])
            multiAppend.putpalette([
                0, 0, 0,
                255, 0, 0,
                0, 255, 0,
                0, 0, 255,
            ])
            multiAppend.putdata([3, 2, 1, 0])
            multiOutput := stdlib.io.BytesIO()
            AhkTest.AssertSame(stdlib.None, roundtrip.save(multiOutput, "GIF", { save_all: true, append_images: [multiAppend], loop: 2, duration: [40, 70] }))
            multiBytes := multiOutput.getvalue()
            AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("GIF89a"), StdlibPillowTest.ArraySlice(multiBytes, 1, 6))
            multiOpened := stdlib.pillow.Image.open(stdlib.io.BytesIO(multiBytes), "r", ["GIF"])
            try {
                AhkTest.AssertEqual("GIF", multiOpened.format)
                AhkTest.AssertEqual("P", multiOpened.mode)
                AhkTest.AssertEqual([2, 2], multiOpened.size)
                AhkTest.AssertEqual(2, multiOpened.n_frames)
                AhkTest.AssertTrue(multiOpened.is_animated)
                AhkTest.AssertEqual(2, multiOpened.info["loop"])
                AhkTest.AssertEqual(40, multiOpened.info["duration"])
                AhkTest.AssertEqual(0, multiOpened.tell())
                AhkTest.AssertEqual([0, 1, 2, 3], multiOpened.getdata())
                AhkTest.AssertSame(stdlib.None, multiOpened.seek(1))
                AhkTest.AssertEqual(1, multiOpened.tell())
                AhkTest.AssertEqual("RGB", multiOpened.mode)
                AhkTest.AssertEqual(70, multiOpened.info["duration"])
                AhkTest.AssertEqual([[0, 0, 255], [0, 255, 0], [255, 0, 0], [0, 0, 0]], multiOpened.getdata())
                AhkTest.RaisesMatch(EOFError, "^attempt to seek outside sequence$", (*) => multiOpened.seek(2))
                AhkTest.RaisesMatch(EOFError, "^attempt to seek outside sequence$", (*) => multiOpened.seek(-1))
            } finally {
                StdlibPillowTest.CloseImage(multiOpened)
            }
            StdlibPillowTest.CloseImage(multiAppend)

            AhkTest.RaisesMatch(SyntaxError, "^not a GIF file$", (*) => plugin.GifImageFile(stdlib.io.BytesIO(badBytes)))
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => plugin.GifImageFile())
            AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => plugin.GifImageFile(stdlib.io.BytesIO(gif89Bytes), stdlib.None, "extra"))
            AhkTest.RaisesMatch(OSError, "^cannot identify image file <AhkStdlibIoBytesIO object>$", (*) => stdlib.pillow.Image.open(stdlib.io.BytesIO(badBytes), "r", ["GIF"]))
        } finally {
            if IsSet(multiAppend)
                StdlibPillowTest.CloseImage(multiAppend)
            if IsSet(roundtrip)
                StdlibPillowTest.CloseImage(roundtrip)
            if IsSet(gif87)
                StdlibPillowTest.CloseImage(gif87)
            if IsSet(opened)
                StdlibPillowTest.CloseImage(opened)
            if IsSet(direct)
                StdlibPillowTest.CloseImage(direct)
        }
    }

    static TestGimpGradientFileMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "GimpGradientFile"))
        module := stdlib.pillow.GimpGradientFile

        AhkTest.AssertEqual(0.0000000001, module.EPSILON)
        AhkTest.AssertEqual(["linear", "curved", "sine", "sphere_increasing", "sphere_decreasing"], module.SEGMENTS)
        AhkTest.AssertApprox(0.25, module.linear(0.5, 0.25), { Abs: 0.000000000001, Rel: 0.0 })
        AhkTest.AssertApprox(0.853553390593, module.sine(0.5, 0.75), { Abs: 0.000000000001, Rel: 0.0 })
        AhkTest.AssertApprox(0.866025403784, module.sphere_increasing(0.5, 0.5), { Abs: 0.000000000001, Rel: 0.0 })
        AhkTest.AssertApprox(0.133974596216, module.sphere_decreasing(0.5, 0.5), { Abs: 0.000000000001, Rel: 0.0 })
        AhkTest.AssertApprox(0.625, module.linear(0.0, 0.25), { Abs: 0.000000000001, Rel: 0.0 })
        AhkTest.AssertApprox(0.375, module.linear(1.0, 0.75), { Abs: 0.000000000001, Rel: 0.0 })

        simpleBytes := StdlibPillowTest.AsciiBytes(
            "GIMP Gradient`n"
            "Name: demo`n"
            "1`n"
            "0.0 0.5 1.0 0 0 0 1 1 0 0 1 0 0`n"
        )
        noNameBytes := StdlibPillowTest.AsciiBytes(
            "GIMP Gradient`n"
            "1`n"
            "0.0 0.5 1.0 0 0 1 1 0 1 0 0.5 0 0`n"
        )
        multiBytes := StdlibPillowTest.AsciiBytes(
            "GIMP Gradient`n"
            "Name: multi`n"
            "2`n"
            "0.0 0.5 0.5 0 0 0 1 1 0 0 1 0 0`n"
            "0.5 0.75 1.0 1 0 0 1 0 0 1 0.5 0 0`n"
        )
        hsvBytes := StdlibPillowTest.AsciiBytes(
            "GIMP Gradient`n"
            "Name: hsv`n"
            "1`n"
            "0.0 0.5 1.0 0 0 0 1 1 1 1 1 0 1`n"
        )
        badSegmentBytes := StdlibPillowTest.AsciiBytes(
            "GIMP Gradient`n"
            "Name: bad segment`n"
            "1`n"
            "0.0 0.5 1.0 0 0 0 1 1 1 1 1 99 0`n"
        )

        gradient := module.GimpGradientFile(stdlib.io.BytesIO(simpleBytes))
        AhkTest.AssertEqual("GimpGradientFile", gradient.AhkStdlibTypeName)
        AhkTest.AssertEqual(1, gradient.gradient.Length)
        AhkTest.AssertEqual([0.0, 1.0, 0.5, [0.0, 0.0, 0.0, 1.0], [1.0, 0.0, 0.0, 1.0], "linear"], gradient.gradient[1])
        simple2 := gradient.getpalette(2)
        AhkTest.AssertEqual([0, 0, 0, 255, 255, 0, 0, 255], simple2[1])
        AhkTest.AssertEqual("RGBA", simple2[2])
        AhkTest.AssertEqual([0, 0, 0, 255, 128, 0, 0, 255, 255, 0, 0, 255], gradient.getpalette(3)[1])
        AhkTest.AssertEqual([0, 0, 0, 255, 64, 0, 0, 255, 128, 0, 0, 255, 191, 0, 0, 255, 255, 0, 0, 255], gradient.getpalette(5)[1])
        AhkTest.AssertEqual([0, 0, 0, 255, 36, 0, 0, 255, 73, 0, 0, 255, 109, 0, 0, 255, 146, 0, 0, 255, 182, 0, 0, 255, 219, 0, 0, 255, 255, 0, 0, 255], gradient.getpalette(8)[1])

        noName := module.GimpGradientFile(stdlib.io.BytesIO(noNameBytes))
        AhkTest.AssertEqual([0, 0, 255, 255, 0, 128, 128, 191, 0, 255, 0, 128], noName.getpalette(3)[1])

        multi := module.GimpGradientFile(stdlib.io.BytesIO(multiBytes))
        AhkTest.AssertEqual(2, multi.gradient.Length)
        AhkTest.AssertEqual("linear", multi.gradient[2][6])
        AhkTest.AssertEqual([0, 0, 0, 255, 64, 0, 0, 255, 128, 0, 0, 255, 128, 0, 128, 191, 0, 0, 255, 128], multi.getpalette(5)[1])

        base := module.GradientFile()
        AhkTest.AssertEqual("GradientFile", base.AhkStdlibTypeName)
        AhkTest.AssertSame(stdlib.None, base.gradient)

        AhkTest.RaisesMatch(AssertionError, "^$", (*) => base.getpalette())
        AhkTest.RaisesMatch(ZeroDivisionError, "^division by zero$", (*) => gradient.getpalette(1))
        AhkTest.RaisesMatch(SyntaxError, "^not a GIMP gradient file$", (*) => module.GimpGradientFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD`n1`n"))))
        AhkTest.RaisesMatch(OSError, "^cannot handle HSV colour space$", (*) => module.GimpGradientFile(stdlib.io.BytesIO(hsvBytes)))
        AhkTest.RaisesMatch(IndexError, "^list index out of range$", (*) => module.GimpGradientFile(stdlib.io.BytesIO(badSegmentBytes)))
        AhkTest.RaisesMatch(ValueError, "^invalid literal for int\(\) with base 10: b'not-an-int\\n'$", (*) => module.GimpGradientFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("GIMP Gradient`nnot-an-int`n"))))
        AhkTest.RaisesMatch(TypeError, "^GimpGradientFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => module.GimpGradientFile())
        AhkTest.RaisesMatch(TypeError, "^GimpGradientFile\.__init__\(\) takes 2 positional arguments but 3 were given$", (*) => module.GimpGradientFile(stdlib.io.BytesIO(simpleBytes), stdlib.None))
    }

    static TestGimpPaletteFileMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "GimpPaletteFile"))
        module := stdlib.pillow.GimpPaletteFile

        simpleBytes := StdlibPillowTest.AsciiBytes(
            "GIMP Palette`n"
            "Name: demo`n"
            "Columns: 2`n"
            "# comment`n"
            "0 0 0 black`n"
            "255 0 0 red`n"
            "1 2 3`n"
        )
        manyBytes := StdlibPillowTest.AsciiBytes("GIMP Palette`n")
        loop 300 {
            value := Mod(A_Index - 1, 256)
            for byte in StdlibPillowTest.AsciiBytes(value " " value " " value "`n")
                manyBytes.Push(byte)
        }
        longBytes := StdlibPillowTest.AsciiBytes("GIMP Palette`n1 2 3 " StrReplace(Format("{:120}", ""), " ", "x") "`n")

        palette := module.GimpPaletteFile(stdlib.io.BytesIO(simpleBytes))
        AhkTest.AssertEqual("GimpPaletteFile", palette.AhkStdlibTypeName)
        AhkTest.AssertEqual("RGB", palette.rawmode)
        AhkTest.AssertEqual([0, 0, 0, 255, 0, 0, 1, 2, 3], palette.palette)
        AhkTest.AssertEqual([[0, 0, 0, 255, 0, 0, 1, 2, 3], "RGB"], palette.getpalette())

        frombytes := module.frombytes(simpleBytes)
        AhkTest.AssertEqual("GimpPaletteFile", frombytes.AhkStdlibTypeName)
        AhkTest.AssertEqual([0, 0, 0, 255, 0, 0, 1, 2, 3], frombytes.palette)
        AhkTest.AssertEqual([[0, 0, 0, 255, 0, 0, 1, 2, 3], "RGB"], frombytes.getpalette())

        limited := module.GimpPaletteFile(stdlib.io.BytesIO(manyBytes))
        unlimited := module.frombytes(manyBytes)
        AhkTest.AssertEqual(768, limited.palette.Length)
        AhkTest.AssertEqual([254, 254, 254, 255, 255, 255], StdlibPillowTest.ArraySlice(limited.palette, 763, 768))
        AhkTest.AssertEqual(900, unlimited.palette.Length)
        AhkTest.AssertEqual([42, 42, 42, 43, 43, 43], StdlibPillowTest.ArraySlice(unlimited.palette, 895, 900))

        AhkTest.RaisesMatch(SyntaxError, "^bad palette file$", (*) => module.GimpPaletteFile(stdlib.io.BytesIO(longBytes)))
        AhkTest.AssertEqual([1, 2, 3], module.frombytes(longBytes).palette)

        AhkTest.RaisesMatch(SyntaxError, "^not a GIMP palette file$", (*) => module.GimpPaletteFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD`n"))))
        AhkTest.RaisesMatch(ValueError, "^bad palette entry$", (*) => module.GimpPaletteFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("GIMP Palette`n1 2`n"))))
        AhkTest.RaisesMatch(ValueError, "^invalid literal for int\(\) with base 10: b'x'$", (*) => module.GimpPaletteFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("GIMP Palette`n1 2 x`n"))))
        AhkTest.RaisesMatch(ValueError, "^bytes must be in range\(0, 256\)$", (*) => module.GimpPaletteFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("GIMP Palette`n-1 256 300 name`n"))))
        AhkTest.RaisesMatch(TypeError, "^GimpPaletteFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => module.GimpPaletteFile())
        AhkTest.RaisesMatch(TypeError, "^GimpPaletteFile\.__init__\(\) takes 2 positional arguments but 3 were given$", (*) => module.GimpPaletteFile(stdlib.io.BytesIO(simpleBytes), stdlib.None))
        AhkTest.RaisesMatch(TypeError, "^GimpPaletteFile\.frombytes\(\) missing 1 required positional argument: 'data'$", (*) => module.frombytes())
        AhkTest.RaisesMatch(TypeError, "^GimpPaletteFile\.frombytes\(\) takes 2 positional arguments but 3 were given$", (*) => module.frombytes(simpleBytes, stdlib.None))
        AhkTest.RaisesMatch(TypeError, "^GimpPaletteFile\.getpalette\(\) takes 1 positional argument but 2 were given$", (*) => palette.getpalette(stdlib.None))
    }

    static TestBdfFontFileAndFontFileMatchLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "FontFile"))
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "BdfFontFile"))
        AhkTest.AssertEqual(800, stdlib.pillow.FontFile.WIDTH)

        putBuffer := stdlib.io.BytesIO()
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.FontFile.puti16(putBuffer, [1, -1, 0x1234, -2, 0, 32767, -32768, 255, 256, -255]))
        AhkTest.AssertEqual([0, 1, 255, 255, 18, 52, 255, 254, 0, 0, 127, 255, 128, 0, 0, 255, 1, 0, 255, 1], putBuffer.getvalue())

        bdfBytes := StdlibPillowTest.BdfFontBytes()
        first := stdlib.pillow.BdfFontFile.bdf_char(stdlib.io.BytesIO(bdfBytes))
        AhkTest.AssertEqual("A", first[1])
        AhkTest.AssertEqual(65, first[2])
        AhkTest.AssertEqual([[7, 0], [1, -6, 6, 1], [0, 0, 5, 7]], first[3])
        AhkTest.AssertEqual("1", first[4].mode)
        AhkTest.AssertEqual([5, 7], first[4].size)
        AhkTest.AssertEqual([0, 0, 5, 7], first[4].getbbox())
        AhkTest.AssertEqual([
            [0, 255, 255, 255, 0],
            [255, 0, 0, 0, 255],
            [255, 0, 0, 0, 255],
            [255, 255, 255, 255, 255],
            [255, 0, 0, 0, 255],
            [255, 0, 0, 0, 255],
            [255, 0, 0, 0, 255],
        ], StdlibPillowTest.PixelRows(first[4]))

        charStream := stdlib.io.BytesIO(bdfBytes)
        stdlib.pillow.BdfFontFile.bdf_char(charStream)
        zero := stdlib.pillow.BdfFontFile.bdf_char(charStream)
        outOfRange := stdlib.pillow.BdfFontFile.bdf_char(charStream)
        exhausted := stdlib.pillow.BdfFontFile.bdf_char(charStream)
        AhkTest.AssertEqual("zero", zero[1])
        AhkTest.AssertEqual(0, zero[2])
        AhkTest.AssertEqual([[3, 0], [0, -4, 0, 0], [0, 0, 0, 4]], zero[3])
        AhkTest.AssertEqual([0, 4], zero[4].size)
        AhkTest.AssertSame(stdlib.None, zero[4].getbbox())
        AhkTest.AssertEqual("out", outOfRange[1])
        AhkTest.AssertEqual(300, outOfRange[2])
        AhkTest.AssertSame(stdlib.None, exhausted)

        empty := stdlib.pillow.FontFile.FontFile()
        AhkTest.AssertEqual("FontFile", empty.AhkStdlibTypeName)
        AhkTest.AssertTrue(empty.info is Map)
        AhkTest.AssertEqual(0, empty.info.Count)
        AhkTest.AssertEqual(256, empty.glyph.Length)
        AhkTest.AssertSame(stdlib.None, empty.bitmap)
        AhkTest.AssertSame(stdlib.None, empty.compile())
        AhkTest.AssertFalse(HasProp(empty, "ysize"))
        AhkTest.AssertFalse(HasProp(empty, "metrics"))

        font := stdlib.pillow.BdfFontFile.BdfFontFile(stdlib.io.BytesIO(bdfBytes))
        AhkTest.AssertEqual("BdfFontFile", font.AhkStdlibTypeName)
        AhkTest.AssertEqual(0, font.info.Count)
        AhkTest.AssertEqual(256, font.glyph.Length)
        AhkTest.AssertSame(stdlib.None, font.bitmap)
        AhkTest.AssertEqual([[7, 0], [1, -6, 6, 1], [0, 0, 5, 7]], StdlibPillowTest.FontGlyphMetrics(font.glyph[66]))
        AhkTest.AssertEqual([[7, 0], [1, -6, 6, 1], [0, 0, 5, 7]], StdlibPillowTest.FontGlyphMetrics(font[65]))
        AhkTest.AssertEqual([[3, 0], [0, -4, 0, 0], [0, 0, 0, 4]], StdlibPillowTest.FontGlyphMetrics(font.glyph[1]))
        AhkTest.AssertSame(stdlib.None, font.glyph[256])

        AhkTest.AssertSame(stdlib.None, font.compile())
        AhkTest.AssertEqual(7, font.ysize)
        AhkTest.AssertEqual("1", font.bitmap.mode)
        AhkTest.AssertEqual([5, 7], font.bitmap.size)
        AhkTest.AssertEqual([0, 0, 5, 7], font.bitmap.getbbox())
        AhkTest.AssertEqual([[3, 0], [0, -4, 0, 0], [0, 0, 0, 4]], font.metrics[1])
        AhkTest.AssertEqual([[7, 0], [1, -6, 6, 1], [0, 0, 5, 7]], font.metrics[66])
        AhkTest.AssertSame(stdlib.None, font.metrics[256])

        savePath := StdlibPillowTest.TempPath("bdf-font-output.pil")
        saveRoot := RegExReplace(savePath, "\.pil$")
        AhkTest.AssertSame(stdlib.None, font.save(savePath))
        pilBytes := StdlibPillowTest.ReadBytes(saveRoot ".pil")
        glyphBytes := StdlibPillowTest.ReadBytes(saveRoot ".pbm")
        AhkTest.AssertEqual([80, 73, 76, 102, 111, 110, 116, 10, 59, 59, 59, 59, 59, 59, 55, 59, 10, 68, 65, 84, 65, 10, 0, 3], StdlibPillowTest.ArraySlice(pilBytes, 1, 24))
        AhkTest.AssertEqual([137, 80, 78, 71, 13, 10, 26, 10], StdlibPillowTest.ArraySlice(glyphBytes, 1, 8))
        loaded := stdlib.pillow.ImageFont.load(saveRoot ".pil")
        AhkTest.AssertEqual(saveRoot ".pbm", loaded.file)
        AhkTest.AssertEqual([], loaded.info)
        AhkTest.AssertEqual([0, 0, 7, 7], loaded.getbbox("A"))
        AhkTest.AssertEqual(7, loaded.getlength("A"))

        AhkTest.RaisesMatch(TypeError, "^BdfFontFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => stdlib.pillow.BdfFontFile.BdfFontFile())
        AhkTest.RaisesMatch(TypeError, "^BdfFontFile\.__init__\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.pillow.BdfFontFile.BdfFontFile(stdlib.io.BytesIO(bdfBytes), "extra"))
        AhkTest.RaisesMatch(SyntaxError, "^not a valid BDF file$", (*) => stdlib.pillow.BdfFontFile.BdfFontFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("STARTFONT 2.0`n"))))
        AhkTest.RaisesMatch(TypeError, "^FontFile\.__init__\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.pillow.FontFile.FontFile("extra"))
        AhkTest.RaisesMatch(ValueError, "^No bitmap created$", (*) => stdlib.pillow.FontFile.FontFile().save(StdlibPillowTest.TempPath("empty-font.pil")))
    }

    static TestPcfFontFileMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "PcfFontFile"))
        module := stdlib.pillow.PcfFontFile

        AhkTest.AssertEqual(0x70636601, module.PCF_MAGIC)
        AhkTest.AssertEqual(1, module.PCF_PROPERTIES)
        AhkTest.AssertEqual(2, module.PCF_ACCELERATORS)
        AhkTest.AssertEqual(4, module.PCF_METRICS)
        AhkTest.AssertEqual(8, module.PCF_BITMAPS)
        AhkTest.AssertEqual(16, module.PCF_INK_METRICS)
        AhkTest.AssertEqual(32, module.PCF_BDF_ENCODINGS)
        AhkTest.AssertEqual(64, module.PCF_SWIDTHS)
        AhkTest.AssertEqual(128, module.PCF_GLYPH_NAMES)
        AhkTest.AssertEqual(256, module.PCF_BDF_ACCELERATORS)
        AhkTest.AssertEqual([[0, 0, 0, 0], [1, 2, 4, 8], [2, 2, 4, 8], [4, 4, 4, 8], [5, 6, 8, 8]], [
            [module.BYTES_PER_ROW[1](0), module.BYTES_PER_ROW[2](0), module.BYTES_PER_ROW[3](0), module.BYTES_PER_ROW[4](0)],
            [module.BYTES_PER_ROW[1](1), module.BYTES_PER_ROW[2](1), module.BYTES_PER_ROW[3](1), module.BYTES_PER_ROW[4](1)],
            [module.BYTES_PER_ROW[1](9), module.BYTES_PER_ROW[2](9), module.BYTES_PER_ROW[3](9), module.BYTES_PER_ROW[4](9)],
            [module.BYTES_PER_ROW[1](31), module.BYTES_PER_ROW[2](31), module.BYTES_PER_ROW[3](31), module.BYTES_PER_ROW[4](31)],
            [module.BYTES_PER_ROW[1](33), module.BYTES_PER_ROW[2](33), module.BYTES_PER_ROW[3](33), module.BYTES_PER_ROW[4](33)],
        ])
        AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("abc"), module.sz([97, 98, 99, 0, 100, 101, 102, 0], 0))
        AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("def"), module.sz([97, 98, 99, 0, 100, 101, 102, 0], 4))

        pcfBytes := StdlibPillowTest.PcfBytes()
        AhkTest.AssertEqual([1, 102, 99, 112, 4, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 57, 0, 0, 0, 72, 0, 0, 0], StdlibPillowTest.ArraySlice(pcfBytes, 1, 24))
        font := module.PcfFontFile(stdlib.io.BytesIO(pcfBytes))
        AhkTest.AssertEqual("PcfFontFile", font.AhkStdlibTypeName)
        AhkTest.AssertEqual("name", font.name)
        AhkTest.AssertEqual("iso8859-1", font.charset_encoding)
        AhkTest.AssertEqual(256, font.glyph.Length)
        AhkTest.AssertEqual(2, StdlibPillowTest.CountFontGlyphs(font))
        AhkTest.AssertEqual(4, font.toc.Count)
        AhkTest.AssertEqual(StdlibPillowTest.AsciiBytes("demo-pcf"), font.info["FONT"])
        AhkTest.AssertEqual(120, font.info["POINT_SIZE"])
        AhkTest.AssertSame(stdlib.None, font.glyph[65])
        AhkTest.AssertSame(stdlib.None, font.glyph[68])

        glyphA := font.glyph[66]
        glyphB := font.glyph[67]
        AhkTest.AssertEqual([[4, 0], [0, -2, 3, 1], [0, 0, 3, 3]], StdlibPillowTest.FontGlyphMetrics(glyphA))
        AhkTest.AssertEqual([[5, 0], [-1, -3, 2, 1], [0, 0, 3, 4]], StdlibPillowTest.FontGlyphMetrics(glyphB))
        AhkTest.AssertEqual("1", glyphA[4].mode)
        AhkTest.AssertEqual([3, 3], glyphA[4].size)
        AhkTest.AssertEqual([0, 0, 3, 3], glyphA[4].getbbox())
        AhkTest.AssertEqual([[255, 0, 255], [0, 255, 0], [255, 255, 255]], StdlibPillowTest.PixelRows(glyphA[4]))
        AhkTest.AssertEqual("1", glyphB[4].mode)
        AhkTest.AssertEqual([3, 4], glyphB[4].size)
        AhkTest.AssertEqual([0, 0, 3, 4], glyphB[4].getbbox())
        AhkTest.AssertEqual([[255, 255, 0], [0, 0, 255], [255, 255, 255], [255, 0, 0]], StdlibPillowTest.PixelRows(glyphB[4]))

        AhkTest.AssertSame(stdlib.None, font.compile())
        AhkTest.AssertEqual("1", font.bitmap.mode)
        AhkTest.AssertEqual([6, 4], font.bitmap.size)
        AhkTest.AssertEqual([[4, 0], [0, -2, 3, 1], [0, 0, 3, 3]], font.metrics[66])
        AhkTest.AssertEqual([[5, 0], [-1, -3, 2, 1], [3, 0, 6, 4]], font.metrics[67])

        AhkTest.RaisesMatch(SyntaxError, "^not a PCF file$", (*) => module.PcfFontFile(stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("BAD!"))))
        AhkTest.RaisesMatch(OSError, "^Wrong number of bitmaps$", (*) => module.PcfFontFile(stdlib.io.BytesIO(StdlibPillowTest.PcfBytes(, 1))))
        AhkTest.RaisesMatch(TypeError, "^PcfFontFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => module.PcfFontFile())
        AhkTest.RaisesMatch(TypeError, "^PcfFontFile\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => module.PcfFontFile(stdlib.io.BytesIO(pcfBytes), "iso8859-1", stdlib.None))
        AhkTest.RaisesMatch(ValueError, "^subsection not found$", (*) => module.sz(StdlibPillowTest.AsciiBytes("abc"), 0))
    }

    static TestImageDeferredErrorMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow.Image, "DeferredError"))

        sourceError := RuntimeError("deferred boom", -1)
        deferred := stdlib.pillow.Image.DeferredError(sourceError)
        AhkTest.AssertEqual("DeferredError", deferred.AhkStdlibTypeName)
        AhkTest.AssertSame(sourceError, deferred.ex)

        try {
            unused := deferred.anything
            AhkTest.Fail("Image.DeferredError attribute access should raise the wrapped exception")
        } catch as err {
            AhkTest.AssertSame(sourceError, err)
        }

        newDeferred := stdlib.pillow.Image.DeferredError.new(sourceError)
        AhkTest.AssertEqual("DeferredError", newDeferred.AhkStdlibTypeName)
        AhkTest.AssertSame(sourceError, newDeferred.ex)
        try {
            unused := newDeferred.other
            AhkTest.Fail("Image.DeferredError.new attribute access should raise the wrapped exception")
        } catch as err {
            AhkTest.AssertSame(sourceError, err)
        }

        AhkTest.RaisesMatch(TypeError, "^DeferredError\.__init__\(\) missing 1 required positional argument: 'ex'$", (*) => stdlib.pillow.Image.DeferredError())
        AhkTest.RaisesMatch(TypeError, "^DeferredError\.__init__\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.pillow.Image.DeferredError(sourceError, sourceError))
        AhkTest.RaisesMatch(TypeError, "^DeferredError\.new\(\) missing 1 required positional argument: 'ex'$", (*) => stdlib.pillow.Image.DeferredError.new())
        AhkTest.RaisesMatch(TypeError, "^DeferredError\.new\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.pillow.Image.DeferredError.new(sourceError, sourceError))
    }

    static TestImageRegistryMatchesLocalPillow113()
    {
        fmt := "AHKSTDLIB_TEST_FORMAT"
        fmtLower := "ahkstdlib_test_format"
        extPrimary := ".ahkstdlib-reg"
        extSecond := ".ahkstdlib-reg-2"
        mime := "image/x-ahkstdlib-reg"

        extensionsBefore := stdlib.pillow.Image.registered_extensions()
        AhkTest.AssertEqual("PNG", extensionsBefore[".png"])
        AhkTest.AssertEqual("JPEG", extensionsBefore[".jpg"])
        AhkTest.AssertEqual("JPEG", extensionsBefore[".jpeg"])
        AhkTest.AssertEqual("BMP", extensionsBefore[".bmp"])
        AhkTest.AssertEqual("TIFF", extensionsBefore[".tiff"])
        AhkTest.AssertEqual("WEBP", extensionsBefore[".webp"])
        AhkTest.AssertFalse(extensionsBefore.Has(extPrimary))

        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_open(fmt, StdlibPillowTest.RegistryFactory, StdlibPillowRegistryAccept))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_save(fmt, StdlibPillowTest.RegistrySave))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_save_all(fmt, StdlibPillowTest.RegistrySave))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_decoder(fmtLower, StdlibPillowRegistryDecoder))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_encoder(fmtLower, StdlibPillowRegistryEncoder))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_extension(fmt, extPrimary))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_extensions(fmt, [extSecond]))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_mime(fmt, mime))

        extensionsAfter := stdlib.pillow.Image.registered_extensions()
        AhkTest.AssertEqual(fmt, extensionsAfter[extPrimary])
        AhkTest.AssertEqual(fmt, extensionsAfter[extSecond])
        AhkTest.AssertEqual("PNG", extensionsAfter[".png"])

        AhkTest.RaisesMatch(TypeError, "^register_decoder\(\) missing 2 required positional arguments: 'name' and 'decoder'$", (*) => stdlib.pillow.Image.register_decoder())
        AhkTest.RaisesMatch(TypeError, "^register_encoder\(\) missing 2 required positional arguments: 'name' and 'encoder'$", (*) => stdlib.pillow.Image.register_encoder())
        AhkTest.RaisesMatch(TypeError, "^register_extension\(\) missing 2 required positional arguments: 'id' and 'extension'$", (*) => stdlib.pillow.Image.register_extension())
        AhkTest.RaisesMatch(TypeError, "^register_mime\(\) missing 2 required positional arguments: 'id' and 'mimetype'$", (*) => stdlib.pillow.Image.register_mime())
    }

    static TestImagePublicRegistryDictsMatchLocalPillow113()
    {
        fmt := "ahkdict_demo"
        upperFmt := "AHKDICT_DEMO"
        ext := ".ahkdict-demo"
        ext2 := ".ahkdict-demo-2"
        mime := "image/x-ahkdict-demo"
        decoderName := "ahkdict_decoder"
        encoderName := "ahkdict_encoder"

        AhkTest.AssertTrue(stdlib.pillow.Image.OPEN is Map)
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE is Map)
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE_ALL is Map)
        AhkTest.AssertTrue(stdlib.pillow.Image.DECODERS is Map)
        AhkTest.AssertTrue(stdlib.pillow.Image.ENCODERS is Map)
        AhkTest.AssertTrue(stdlib.pillow.Image.EXTENSION is Map)
        AhkTest.AssertTrue(stdlib.pillow.Image.MIME is Map)
        AhkTest.AssertTrue(stdlib.pillow.Image.ID is Array)
        AhkTest.AssertTrue(stdlib.pillow.Image.MODES is Array)
        AhkTest.AssertSame(stdlib.pillow.Image.EXTENSION, stdlib.pillow.Image.registered_extensions())
        AhkTest.AssertEqual(["1", "CMYK", "F", "HSV", "I", "I;16", "I;16B", "I;16L"], StdlibPillowTest.ArraySlice(stdlib.pillow.Image.MODES, 1, 8))
        AhkTest.AssertTrue(HasMethod(stdlib.pillow.Image, "open"))
        AhkTest.AssertTrue(HasMethod(stdlib.pillow.Image, "OPEN"))
        AhkTest.AssertFalse(stdlib.pillow.Image.OPEN.Has(upperFmt))
        AhkTest.AssertFalse(stdlib.pillow.Image.SAVE.Has(upperFmt))
        AhkTest.AssertFalse(stdlib.pillow.Image.EXTENSION.Has(ext))

        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_open(fmt, StdlibPillowTest.RegistryFactory, StdlibPillowRegistryAccept))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_save(fmt, StdlibPillowTest.RegistrySave))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_save_all(fmt, StdlibPillowTest.RegistrySave))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_decoder(decoderName, StdlibPillowRegistryDecoder))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_encoder(encoderName, StdlibPillowRegistryEncoder))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_extension(fmt, ext))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_extensions(fmt, [ext2]))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_mime(fmt, mime))

        AhkTest.AssertSame(StdlibPillowTest.RegistryFactory, stdlib.pillow.Image.OPEN[upperFmt][1])
        AhkTest.AssertSame(StdlibPillowRegistryAccept, stdlib.pillow.Image.OPEN[upperFmt][2])
        AhkTest.AssertEqual(upperFmt, stdlib.pillow.Image.ID[stdlib.pillow.Image.ID.Length])
        AhkTest.AssertTrue(stdlib.pillow.Image.SAVE.Has(upperFmt))
        AhkTest.AssertFalse(stdlib.pillow.Image.SAVE.Has(fmt))
        AhkTest.AssertSame(StdlibPillowTest.RegistrySave, stdlib.pillow.Image.SAVE[upperFmt])
        AhkTest.AssertSame(StdlibPillowTest.RegistrySave, stdlib.pillow.Image.SAVE_ALL[upperFmt])
        AhkTest.AssertSame(StdlibPillowRegistryDecoder, stdlib.pillow.Image.DECODERS[decoderName])
        AhkTest.AssertSame(StdlibPillowRegistryEncoder, stdlib.pillow.Image.ENCODERS[encoderName])
        AhkTest.AssertEqual(upperFmt, stdlib.pillow.Image.EXTENSION[ext])
        AhkTest.AssertEqual(upperFmt, stdlib.pillow.Image.EXTENSION[ext2])
        AhkTest.AssertEqual(upperFmt, stdlib.pillow.Image.registered_extensions()[ext])
        AhkTest.AssertEqual(mime, stdlib.pillow.Image.MIME[upperFmt])

        stdlib.pillow.Image.EXTENSION[".ahkdict-direct"] := "DIRECT"
        stdlib.pillow.Image.MIME["DIRECT"] := "image/x-direct"
        stdlib.pillow.Image.ID.Push("DIRECTID")
        stdlib.pillow.Image.MODES.Push("DIRECTMODE")
        AhkTest.AssertEqual("DIRECT", stdlib.pillow.Image.registered_extensions()[".ahkdict-direct"])
        AhkTest.AssertEqual("image/x-direct", stdlib.pillow.Image.MIME["DIRECT"])
        AhkTest.AssertEqual(["DIRECTID"], StdlibPillowTest.ArraySlice(stdlib.pillow.Image.ID, stdlib.pillow.Image.ID.Length, stdlib.pillow.Image.ID.Length))
        AhkTest.AssertEqual(["DIRECTMODE"], StdlibPillowTest.ArraySlice(stdlib.pillow.Image.MODES, stdlib.pillow.Image.MODES.Length, stdlib.pillow.Image.MODES.Length))
    }

    static TestImageCompressionConstantsMatchLocalPillow113()
    {
        AhkTest.AssertEqual(0, stdlib.pillow.Image.DEFAULT_STRATEGY)
        AhkTest.AssertEqual(1, stdlib.pillow.Image.FILTERED)
        AhkTest.AssertEqual(2, stdlib.pillow.Image.HUFFMAN_ONLY)
        AhkTest.AssertEqual(3, stdlib.pillow.Image.RLE)
        AhkTest.AssertEqual(4, stdlib.pillow.Image.FIXED)
        AhkTest.AssertEqual(0, stdlib.pillow.Image.WEB)
        AhkTest.AssertTrue(stdlib.pillow.Image.DEFAULT_STRATEGY is Integer)
        AhkTest.AssertTrue(stdlib.pillow.Image.WEB is Integer)
        AhkTest.AssertTrue(stdlib.pillow.Image.DEFAULT_STRATEGY < stdlib.pillow.Image.FILTERED)
        AhkTest.AssertTrue(stdlib.pillow.Image.RLE > stdlib.pillow.Image.HUFFMAN_ONLY)
    }

    static TestImageExifMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow.Image, "Exif"))

        exifClass := stdlib.pillow.Image.Exif
        AhkTest.AssertEqual("AhkStdlibPillowExif", exifClass.Prototype.__Class)

        exif := stdlib.pillow.Image.Exif()
        AhkTest.AssertEqual("Exif", exif.AhkStdlibTypeName)
        AhkTest.AssertTrue(exif is Map)
        AhkTest.AssertEqual(0, exif.Count)
        AhkTest.AssertFalse(exif.Has(274))
        AhkTest.AssertEqual([], exif.keys())
        AhkTest.AssertEqual([], exif.items())
        AhkTest.AssertSame(stdlib.None, exif.get(274))
        AhkTest.AssertEqual("fallback", exif.get(274, "fallback"))
        AhkTest.AssertEqual([69, 120, 105, 102, 0, 0, 77, 77, 0, 42, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0], exif.tobytes())
        AhkTest.AssertEqual(0, exif.get_ifd("bad").Count)

        exif[274] := 6
        exif[305] := "AHK"
        AhkTest.AssertEqual(2, exif.Count)
        AhkTest.AssertTrue(exif.Has(274))
        AhkTest.AssertEqual(6, exif[274])
        AhkTest.AssertEqual("AHK", exif[305])
        AhkTest.AssertEqual([305, 274], exif.keys())
        AhkTest.AssertEqual([[305, "AHK"], [274, 6]], exif.items())
        AhkTest.AssertEqual(6, exif.get(274))
        exif.Delete(274)
        AhkTest.AssertEqual(1, exif.Count)
        AhkTest.AssertFalse(exif.Has(274))
        AhkTest.AssertEqual([305], exif.keys())
        AhkTest.AssertEqual([[305, "AHK"]], exif.items())

        AhkTest.RaisesMatch(TypeError, "^Exif\.__init__\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.pillow.Image.Exif(Map(274, 6)))
        AhkTest.RaisesMatch(KeyError, "^274$", (*) => StdlibPillowTestReadExifKey(exif, 274))
        AhkTest.RaisesMatch(KeyError, "^274$", (*) => exif.Delete(274))

        image := unset
        copied := unset
        try {
            image := stdlib.pillow.Image.new("RGB", [1, 1])
            imageExif := image.getexif()
            imageExif[274] := 3
            AhkTest.AssertEqual("Exif", imageExif.AhkStdlibTypeName)
            AhkTest.AssertSame(imageExif, image.getexif())
            AhkTest.AssertEqual(1, image.getexif().Count)
            AhkTest.AssertEqual(3, image.getexif()[274])

            copied := image.copy()
            AhkTest.AssertEqual("Exif", copied.getexif().AhkStdlibTypeName)
            AhkTest.AssertEqual(3, copied.getexif()[274])
            AhkTest.AssertTrue(ObjPtr(copied.getexif()) != ObjPtr(imageExif))
        } finally {
            if IsSet(copied)
                StdlibPillowTest.CloseImage(copied)
            if IsSet(image)
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestExifTagsMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "ExifTags"))

        tags := stdlib.pillow.ExifTags.TAGS
        gpsTags := stdlib.pillow.ExifTags.GPSTAGS
        AhkTest.AssertTrue(tags is Map)
        AhkTest.AssertTrue(gpsTags is Map)
        AhkTest.AssertEqual(273, tags.Count)
        AhkTest.AssertEqual(32, gpsTags.Count)
        AhkTest.AssertEqual("ImageWidth", tags[256])
        AhkTest.AssertEqual("ImageLength", tags[257])
        AhkTest.AssertEqual("BitsPerSample", tags[258])
        AhkTest.AssertEqual("Make", tags[271])
        AhkTest.AssertEqual("Model", tags[272])
        AhkTest.AssertEqual("Orientation", tags[274])
        AhkTest.AssertEqual("Software", tags[305])
        AhkTest.AssertEqual("DateTime", tags[306])
        AhkTest.AssertEqual("ExifOffset", tags[34665])
        AhkTest.AssertEqual("GPSInfo", tags[34853])
        AhkTest.AssertFalse(tags.Has(999999))

        AhkTest.AssertEqual("GPSVersionID", gpsTags[0])
        AhkTest.AssertEqual("GPSLatitudeRef", gpsTags[1])
        AhkTest.AssertEqual("GPSLatitude", gpsTags[2])
        AhkTest.AssertEqual("GPSLongitudeRef", gpsTags[3])
        AhkTest.AssertEqual("GPSLongitude", gpsTags[4])
        AhkTest.AssertEqual("GPSAltitudeRef", gpsTags[5])
        AhkTest.AssertEqual("GPSAltitude", gpsTags[6])
        AhkTest.AssertEqual("GPSTimeStamp", gpsTags[7])
        AhkTest.AssertEqual("GPSDateStamp", gpsTags[29])
        AhkTest.AssertEqual("GPSHPositioningError", gpsTags[31])

        AhkTest.AssertEqual(256, stdlib.pillow.ExifTags.Base.ImageWidth)
        AhkTest.AssertEqual(257, stdlib.pillow.ExifTags.Base.ImageLength)
        AhkTest.AssertEqual(258, stdlib.pillow.ExifTags.Base.BitsPerSample)
        AhkTest.AssertEqual(271, stdlib.pillow.ExifTags.Base.Make)
        AhkTest.AssertEqual(272, stdlib.pillow.ExifTags.Base.Model)
        AhkTest.AssertEqual(274, stdlib.pillow.ExifTags.Base.Orientation)
        AhkTest.AssertEqual(305, stdlib.pillow.ExifTags.Base.Software)
        AhkTest.AssertEqual(34665, stdlib.pillow.ExifTags.Base.ExifOffset)
        AhkTest.AssertEqual(34853, stdlib.pillow.ExifTags.Base.GPSInfo)

        AhkTest.AssertEqual(0, stdlib.pillow.ExifTags.GPS.GPSVersionID)
        AhkTest.AssertEqual(1, stdlib.pillow.ExifTags.GPS.GPSLatitudeRef)
        AhkTest.AssertEqual(2, stdlib.pillow.ExifTags.GPS.GPSLatitude)
        AhkTest.AssertEqual(4, stdlib.pillow.ExifTags.GPS.GPSLongitude)
        AhkTest.AssertEqual(29, stdlib.pillow.ExifTags.GPS.GPSDateStamp)
        AhkTest.AssertEqual(31, stdlib.pillow.ExifTags.GPS.GPSHPositioningError)

        AhkTest.AssertEqual(34665, stdlib.pillow.ExifTags.IFD.Exif)
        AhkTest.AssertEqual(34853, stdlib.pillow.ExifTags.IFD.GPSInfo)
        AhkTest.AssertEqual(40965, stdlib.pillow.ExifTags.IFD.Interop)
        AhkTest.AssertEqual(-1, stdlib.pillow.ExifTags.IFD.IFD1)
        AhkTest.AssertEqual(37500, stdlib.pillow.ExifTags.IFD.MakerNote)

        AhkTest.AssertEqual(1, stdlib.pillow.ExifTags.Interop.InteropIndex)
        AhkTest.AssertEqual(2, stdlib.pillow.ExifTags.Interop.InteropVersion)
        AhkTest.AssertEqual(4096, stdlib.pillow.ExifTags.Interop.RelatedImageFileFormat)
        AhkTest.AssertEqual(4097, stdlib.pillow.ExifTags.Interop.RelatedImageWidth)
        AhkTest.AssertEqual(4098, stdlib.pillow.ExifTags.Interop.RelatedImageHeight)

        AhkTest.AssertEqual(0, stdlib.pillow.ExifTags.LightSource.Unknown)
        AhkTest.AssertEqual(1, stdlib.pillow.ExifTags.LightSource.Daylight)
        AhkTest.AssertEqual(2, stdlib.pillow.ExifTags.LightSource.Fluorescent)
        AhkTest.AssertEqual(3, stdlib.pillow.ExifTags.LightSource.Tungsten)
        AhkTest.AssertEqual(4, stdlib.pillow.ExifTags.LightSource.Flash)
    }

    static TestTiffTagsMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "TiffTags"))

        tiff := stdlib.pillow.TiffTags
        AhkTest.AssertEqual(1, tiff.BYTE)
        AhkTest.AssertEqual(2, tiff.ASCII)
        AhkTest.AssertEqual(3, tiff.SHORT)
        AhkTest.AssertEqual(4, tiff.LONG)
        AhkTest.AssertEqual(5, tiff.RATIONAL)
        AhkTest.AssertEqual(6, tiff.SIGNED_BYTE)
        AhkTest.AssertEqual(7, tiff.UNDEFINED)
        AhkTest.AssertEqual(8, tiff.SIGNED_SHORT)
        AhkTest.AssertEqual(9, tiff.SIGNED_LONG)
        AhkTest.AssertEqual(10, tiff.SIGNED_RATIONAL)
        AhkTest.AssertEqual(11, tiff.FLOAT)
        AhkTest.AssertEqual(12, tiff.DOUBLE)
        AhkTest.AssertEqual(13, tiff.IFD)
        AhkTest.AssertEqual(16, tiff.LONG8)

        tags := tiff.TAGS
        tagsV2 := tiff.TAGS_V2
        types := tiff.TYPES
        lzw := tiff.TagInfo(1, "Name", 2, 3, Map("A", 4))
        AhkTest.AssertTrue(tags is Map)
        AhkTest.AssertTrue(tagsV2 is Map)
        AhkTest.AssertTrue(types is Map)
        AhkTest.AssertEqual(266, tags.Count)
        AhkTest.AssertEqual(110, tagsV2.Count)
        AhkTest.AssertEqual(0, types.Count)
        AhkTest.AssertEqual("ImageWidth", tags[256])
        AhkTest.AssertEqual("ImageLength", tags[257])
        AhkTest.AssertEqual("BitsPerSample", tags[258])
        AhkTest.AssertEqual("Compression", tags[259])
        AhkTest.AssertEqual("PhotometricInterpretation", tags[262])
        AhkTest.AssertEqual("ImageDescription", tags[270])
        AhkTest.AssertEqual("Make", tags[271])
        AhkTest.AssertEqual("Model", tags[272])
        AhkTest.AssertEqual("Orientation", tags[274])
        AhkTest.AssertEqual("XResolution", tags[282])
        AhkTest.AssertEqual("YResolution", tags[283])
        AhkTest.AssertEqual("ResolutionUnit", tags[296])
        AhkTest.AssertEqual("Software", tags[305])
        AhkTest.AssertEqual("DateTime", tags[306])
        AhkTest.AssertEqual("Artist", tags[315])
        AhkTest.AssertEqual("Predictor", tags[317])
        AhkTest.AssertEqual("ColorMap", tags[320])
        AhkTest.AssertEqual("SubIFDs", tags[330])
        AhkTest.AssertEqual("ExtraSamples", tags[338])
        AhkTest.AssertEqual("SampleFormat", tags[339])
        AhkTest.AssertEqual("ExifIFD", tags[34665])
        AhkTest.AssertEqual("GPSInfoIFD", tags[34853])
        AhkTest.AssertEqual("LZW", tags["(259, 5)"])
        AhkTest.AssertEqual("RGB", tags["(262, 2)"])
        AhkTest.AssertEqual("inch", tags["(296, 2)"])
        AhkTest.AssertEqual("Horizontal Differencing", tags["(317, 2)"])
        AhkTest.AssertEqual("Safe", tags["(50741, 1)"])
        AhkTest.AssertFalse(tags.Has(999999))

        info := tagsV2[256]
        AhkTest.AssertEqual(256, info.value)
        AhkTest.AssertEqual("ImageWidth", info.name)
        AhkTest.AssertEqual(4, info.type)
        AhkTest.AssertEqual(1, info.length)
        AhkTest.AssertEqual(0, info.enum.Count)
        AhkTest.AssertEqual(256, info[1])
        AhkTest.AssertEqual("ImageWidth", info[2])
        AhkTest.AssertEqual(4, info[3])
        AhkTest.AssertEqual(1, info[4])
        AhkTest.AssertEqual(Map(), info[5])
        AhkTest.AssertRegex(info.__Repr(), "^TagInfo\(value=256, name='ImageWidth', type=4, length=1, enum=\{\}\)$")

        compression := tagsV2[259]
        AhkTest.AssertEqual("Compression", compression.name)
        AhkTest.AssertEqual(7, compression.enum.Count)
        AhkTest.AssertEqual(1, compression.enum["Uncompressed"])
        AhkTest.AssertEqual(5, compression.enum["LZW"])
        AhkTest.AssertEqual(32773, compression.enum["PackBits"])
        AhkTest.AssertEqual(0, tagsV2[258].length)
        AhkTest.AssertEqual(0, tagsV2[320].length)
        AhkTest.AssertEqual("ExifIFD", tagsV2[34665].name)
        AhkTest.AssertEqual("GPSInfoIFD", tagsV2[34853].name)

        AhkTest.AssertEqual(1, lzw[1])
        AhkTest.AssertEqual("Name", lzw[2])
        AhkTest.AssertEqual(2, lzw[3])
        AhkTest.AssertEqual(3, lzw[4])
        AhkTest.AssertEqual(Map("A", 4), lzw[5])
        AhkTest.AssertEqual(4, lzw.enum["A"])
        AhkTest.AssertRegex(lzw.__Repr(), "^TagInfo\(value=1, name='Name', type=2, length=3, enum=\{'A': 4\}\)$")
        defaultInfo := tiff.TagInfo()
        AhkTest.AssertSame(stdlib.None, defaultInfo.value)
        AhkTest.AssertEqual("unknown", defaultInfo.name)
        AhkTest.AssertSame(stdlib.None, defaultInfo.type)
        AhkTest.AssertSame(stdlib.None, defaultInfo.length)
        AhkTest.AssertEqual(0, defaultInfo.enum.Count)
        AhkTest.AssertSame(stdlib.None, defaultInfo[1])
        AhkTest.AssertEqual("unknown", defaultInfo[2])
        AhkTest.AssertSame(stdlib.None, defaultInfo[3])
        AhkTest.AssertSame(stdlib.None, defaultInfo[4])
        AhkTest.AssertEqual(Map(), defaultInfo[5])
        AhkTest.RaisesMatch(TypeError, "^TagInfo\.__new__\(\) takes from 1 to 6 positional arguments but 7 were given$", (*) => tiff.TagInfo(1, 2, 3, 4, 5, 6))

        lookup := tiff.lookup(274)
        AhkTest.AssertEqual(274, lookup.value)
        AhkTest.AssertEqual("Orientation", lookup.name)
        AhkTest.AssertEqual(3, lookup.type)
        AhkTest.AssertEqual(1, lookup.length)
        unknown := tiff.lookup(999999)
        AhkTest.AssertEqual(999999, unknown.value)
        AhkTest.AssertEqual("unknown", unknown.name)
        AhkTest.AssertSame(stdlib.None, unknown.type)
        stringLookup := tiff.lookup("ImageWidth")
        AhkTest.AssertEqual("ImageWidth", stringLookup.value)
        AhkTest.AssertEqual("unknown", stringLookup.name)
        groupLookup := tiff.lookup(36864, 34665)
        AhkTest.AssertEqual("ExifVersion", groupLookup.name)
        AhkTest.AssertEqual(7, groupLookup.type)
        groupUnknown := tiff.lookup(999, 34853)
        AhkTest.AssertEqual(999, groupUnknown.value)
        AhkTest.AssertEqual("unknown", groupUnknown.name)
        AhkTest.RaisesMatch(TypeError, "^lookup\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => tiff.lookup(1, 2, 3))

        core := tiff.LIBTIFF_CORE
        groups := tiff.TAGS_V2_GROUPS
        AhkTest.AssertTrue(core is Map)
        AhkTest.AssertEqual(36, core.Count)
        AhkTest.AssertTrue(core.Has(256))
        AhkTest.AssertTrue(core.Has(274))
        AhkTest.AssertFalse(core.Has(34665))
        AhkTest.AssertTrue(groups is Map)
        AhkTest.AssertEqual(3, groups.Count)
        AhkTest.AssertEqual(4, groups[34665].Count)
        AhkTest.AssertEqual(31, groups[34853].Count)
        AhkTest.AssertEqual(2, groups[40965].Count)
        AhkTest.AssertEqual("ExifVersion", groups[34665][36864].name)
        AhkTest.AssertEqual(7, groups[34665][36864].type)
        AhkTest.AssertEqual("GPSLatitude", groups[34853][2].name)
        AhkTest.AssertEqual(5, groups[34853][2].type)
        AhkTest.AssertEqual(3, groups[34853][2].length)
        AhkTest.AssertEqual("GPSDateStamp", groups[34853][29].name)
        AhkTest.AssertEqual("InteropVersion", groups[40965][2].name)
    }

    static TestImageCodecRegistryMatchesLocalPillow113()
    {
        decoderName := "ahk_demo_decoder"
        shortDecoderName := "ahk_short_decoder"
        errorDecoderName := "ahk_error_decoder"
        encoderName := "ahk_demo_encoder"
        errorEncoderName := "ahk_error_encoder"

        StdlibPillowDemoDecoder.Events := []
        StdlibPillowDemoEncoder.Events := []
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_decoder(decoderName, StdlibPillowDemoDecoder))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_decoder(shortDecoderName, StdlibPillowShortDecoder))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_decoder(errorDecoderName, StdlibPillowErrorDecoder))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_encoder(encoderName, StdlibPillowDemoEncoder))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_encoder(errorEncoderName, StdlibPillowErrorEncoder))

        target := unset
        factory := unset
        encodedSource := unset
        try {
            target := stdlib.pillow.Image.new("L", [3, 1], 0)
            AhkTest.AssertSame(stdlib.None, target.frombytes([7, 8, 9], decoderName, "marker"))
            AhkTest.AssertEqual([7, 8, 9], target.getdata())

            factory := stdlib.pillow.Image.frombytes("L", [3, 1], [1, 2, 3], decoderName, ["tuple-arg"])
            AhkTest.AssertEqual([1, 2, 3], factory.getdata())
            AhkTest.AssertEqual([
                ["decoder_init", "L", ["marker"]],
                ["decoder_setimage", "L", [3, 1]],
                ["decoder_decode", [7, 8, 9]],
                ["decoder_init", "L", ["tuple-arg"]],
                ["decoder_setimage", "L", [3, 1]],
                ["decoder_decode", [1, 2, 3]],
            ], StdlibPillowDemoDecoder.Events)

            encodedSource := stdlib.pillow.Image.new("L", [2, 1], 5)
            AhkTest.AssertEqual([65, 66, 67], encodedSource.tobytes(encoderName, "enc"))
            AhkTest.AssertEqual([
                ["encoder_init", "L", ["enc"]],
                ["encoder_setimage", "L", [2, 1]],
                ["encoder_encode", 65536, 1],
                ["encoder_encode", 65536, 2],
            ], StdlibPillowDemoEncoder.Events)

            AhkTest.RaisesMatch(ValueError, "^not enough image data$", (*) => stdlib.pillow.Image.new("L", [1, 1], 0).frombytes([1], shortDecoderName))
            AhkTest.RaisesMatch(ValueError, "^cannot decode image data$", (*) => stdlib.pillow.Image.new("L", [1, 1], 0).frombytes([1], errorDecoderName))
            AhkTest.RaisesMatch(RuntimeError, "^encoder error -3 in tobytes$", (*) => stdlib.pillow.Image.new("L", [1, 1], 0).tobytes(errorEncoderName))
            AhkTest.RaisesMatch(OSError, "^decoder missing_decoder not available$", (*) => stdlib.pillow.Image.new("L", [1, 1], 0).frombytes([1], "missing_decoder"))
            AhkTest.RaisesMatch(OSError, "^encoder missing_encoder not available$", (*) => stdlib.pillow.Image.new("L", [1, 1], 0).tobytes("missing_encoder"))
        } finally {
            if IsSet(encodedSource)
                StdlibPillowTest.CloseImage(encodedSource)
            if IsSet(factory)
                StdlibPillowTest.CloseImage(factory)
            if IsSet(target)
                StdlibPillowTest.CloseImage(target)
        }
    }

    static TestImageOpenRegistryMatchesLocalPillow113()
    {
        fmt := "AHKOPEN_DEMO"
        skipFmt := "AHKOPEN_SKIP"
        warnFmt := "AHKOPEN_WARN"
        path := StdlibPillowTest.TempPath("sample.ahkopen-demo")
        payload := [65, 72, 75, 79, 80, 69, 78, 48, 49, 50, 51, 52, 53, 54, 55, 56, 109, 111, 114, 101]
        StdlibPillowOpenFactory.Events := []

        StdlibPillowTest.WriteBytes(path, payload)
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_open(skipFmt, StdlibPillowOpenFactory, StdlibPillowOpenSkipAccept))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_open(warnFmt, StdlibPillowOpenFactory, StdlibPillowOpenWarnAccept))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_open(fmt, StdlibPillowOpenFactory, StdlibPillowOpenAccept))

        opened := unset
        try {
            opened := stdlib.pillow.Image.open(path, "r", [skipFmt, warnFmt, fmt])
            AhkTest.AssertEqual("L", opened.mode)
            AhkTest.AssertEqual([2, 1], opened.size)
            AhkTest.AssertEqual(fmt, opened.format)
            prefix := StdlibPillowTest.ArraySlice(payload, 1, 16)
            AhkTest.AssertEqual([
                ["accept_skip", prefix],
                ["accept_warn", prefix],
                ["accept", prefix],
                ["factory_enter", path, 0, [65, 72, 75, 79, 80, 69, 78]],
                ["factory_after_read", 7],
            ], StdlibPillowOpenFactory.Events)

            StdlibPillowOpenFactory.Events := []
            stream := stdlib.io.BytesIO(payload)
            streamOpened := stdlib.pillow.Image.open(stream, "r", [fmt])
            AhkTest.AssertEqual("L", streamOpened.mode)
            AhkTest.AssertEqual([2, 1], streamOpened.size)
            AhkTest.AssertEqual(fmt, streamOpened.format)
            AhkTest.AssertEqual(7, stream.tell())
            AhkTest.AssertEqual([
                ["accept", prefix],
                ["factory_enter", "", 0, [65, 72, 75, 79, 80, 69, 78]],
                ["factory_after_read", 7],
            ], StdlibPillowOpenFactory.Events)

            AhkTest.RaisesMatch(ValueError, "^bad mode 'w'$", (*) => stdlib.pillow.Image.open(path, "w", [fmt]))
            AhkTest.RaisesMatch(TypeError, "^formats must be a list or tuple$", (*) => stdlib.pillow.Image.open(path, "r", fmt))
            AhkTest.RaisesMatch(OSError, "^No such file or directory: '.*missing\.ahkopen-demo'$", (*) => stdlib.pillow.Image.open(StdlibPillowTest.TempPath("missing.ahkopen-demo"), "r", [fmt]))
        } finally {
            if IsSet(streamOpened)
                StdlibPillowTest.CloseImage(streamOpened)
            if IsSet(opened)
                StdlibPillowTest.CloseImage(opened)
            try FileDelete path
        }
    }

    static TestImageSaveRegistryMatchesLocalPillow113()
    {
        fmt := "AHKSTDLIB_SAVE_TEST"
        failFmt := "AHKSTDLIB_FAIL_TEST"
        ext := ".ahksave-test"
        failExt := ".ahkfail-test"

        StdlibPillowDemoSave.Events := []
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_save(fmt, StdlibPillowDemoSave))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_save_all(fmt, StdlibPillowDemoSaveAll))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_save(failFmt, StdlibPillowFailSave))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_extension(fmt, ext))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_extension(failFmt, failExt))

        image := unset
        appendImage := unset
        try {
            image := stdlib.pillow.Image.new("RGB", [2, 1], [10, 20, 30])
            normalPath := StdlibPillowTest.TempPath("sample" ext)
            explicitPath := StdlibPillowTest.TempPath("explicit.out")
            saveAllPath := StdlibPillowTest.TempPath("sample-save-all" ext)
            appendPath := StdlibPillowTest.TempPath("sample-append" ext)
            failPath := StdlibPillowTest.TempPath("broken" failExt)

            AhkTest.AssertSame(stdlib.None, image.save(normalPath, unset, { quality: 77 }))
            AhkTest.AssertEqual([65, 72, 75, 83, 65, 86, 69, 58, 82, 71, 66], StdlibPillowTest.ReadBytes(normalPath))

            AhkTest.AssertSame(stdlib.None, image.save(explicitPath, fmt))
            AhkTest.AssertEqual([65, 72, 75, 83, 65, 86, 69, 58, 82, 71, 66], StdlibPillowTest.ReadBytes(explicitPath))

            AhkTest.AssertSame(stdlib.None, image.save(saveAllPath, fmt, { save_all: true, quality: 88 }))
            AhkTest.AssertEqual([65, 72, 75, 83, 65, 86, 69, 65, 76, 76], StdlibPillowTest.ReadBytes(saveAllPath))

            appendImage := stdlib.pillow.Image.new("RGB", [1, 1], [1, 2, 3])
            AhkTest.AssertSame(stdlib.None, image.save(appendPath, fmt, { append_images: [appendImage] }))
            AhkTest.AssertEqual([65, 72, 75, 83, 65, 86, 69, 65, 76, 76], StdlibPillowTest.ReadBytes(appendPath))

            AhkTest.AssertEqual([
                ["save", "RGB", [2, 1], normalPath, Map("quality", 77)],
                ["save_write_return", 11],
                ["save", "RGB", [2, 1], explicitPath, Map()],
                ["save_write_return", 11],
                ["save_all", "RGB", [2, 1], saveAllPath, Map("quality", 88)],
                ["save_all_write_return", 10],
                ["save_all", "RGB", [2, 1], appendPath, Map("append_images", [["Image", "RGB", [1, 1]]])],
                ["save_all_write_return", 10],
            ], StdlibPillowDemoSave.Events)

            AhkTest.RaisesMatch(ValueError, "^unknown file extension: .unknown$", (*) => image.save(StdlibPillowTest.TempPath("missing.unknown")))
            AhkTest.RaisesMatch(ValueError, "^unknown file extension: $", (*) => image.save(StdlibPillowTest.TempPath("no_extension")))
            AhkTest.RaisesMatch(RuntimeError, "^save boom$", (*) => image.save(failPath))
            AhkTest.AssertFalse(FileExist(failPath))
        } finally {
            if IsSet(appendImage)
                StdlibPillowTest.CloseImage(appendImage)
            if IsSet(image)
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestImageSaveFileLikeRegistryMatchesLocalPillow113()
    {
        fmt := "AHKFILELIKE_SAVE"
        failFmt := "AHKFILELIKE_FAIL"

        StdlibPillowMemorySave.Events := []
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_save(fmt, StdlibPillowMemorySave))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_save_all(fmt, StdlibPillowMemorySaveAll))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_save(failFmt, StdlibPillowMemoryFailSave))

        image := unset
        appendImage := unset
        try {
            image := stdlib.pillow.Image.new("RGB", [2, 1], [10, 20, 30])

            normalFp := StdlibPillowMemorySaveFile()
            AhkTest.AssertSame(stdlib.None, image.save(normalFp, fmt, { quality: 77 }))
            AhkTest.AssertEqual([65, 72, 75, 83, 65, 86, 69, 58, 77, 69, 77], normalFp.Bytes)
            AhkTest.AssertEqual(11, normalFp.tell())
            AhkTest.AssertFalse(normalFp.Closed)

            saveAllFp := StdlibPillowMemorySaveFile()
            AhkTest.AssertSame(stdlib.None, image.save(saveAllFp, fmt, { save_all: true, quality: 88 }))
            AhkTest.AssertEqual([65, 72, 75, 83, 65, 86, 69, 65, 76, 76], saveAllFp.Bytes)
            AhkTest.AssertEqual(10, saveAllFp.tell())
            AhkTest.AssertFalse(saveAllFp.Closed)

            appendImage := stdlib.pillow.Image.new("RGB", [1, 1], [1, 2, 3])
            appendFp := StdlibPillowMemorySaveFile()
            AhkTest.AssertSame(stdlib.None, image.save(appendFp, fmt, { append_images: [appendImage] }))
            AhkTest.AssertEqual([65, 72, 75, 83, 65, 86, 69, 65, 76, 76], appendFp.Bytes)
            AhkTest.AssertEqual(10, appendFp.tell())
            AhkTest.AssertFalse(appendFp.Closed)

            failFp := StdlibPillowMemorySaveFile()
            AhkTest.RaisesMatch(RuntimeError, "^save boom$", (*) => image.save(failFp, failFmt))
            AhkTest.AssertEqual([112, 97, 114, 116, 105, 97, 108], failFp.Bytes)
            AhkTest.AssertEqual(7, failFp.tell())
            AhkTest.AssertFalse(failFp.Closed)

            noFormatFp := StdlibPillowMemorySaveFile()
            AhkTest.RaisesMatch(ValueError, "^unknown file extension: $", (*) => image.save(noFormatFp))
            AhkTest.AssertEqual([], noFormatFp.Bytes)
            AhkTest.AssertEqual(0, noFormatFp.tell())
            AhkTest.AssertFalse(noFormatFp.Closed)

            AhkTest.AssertEqual([
                ["save", "RGB", [2, 1], "", Map("quality", 77), Map("quality", 77), 0],
                ["save_write_return", 11, 11],
                ["save_all", "RGB", [2, 1], "", Map("quality", 88), Map("quality", 88), 0],
                ["save_all_write_return", 10, 10],
                ["save_all", "RGB", [2, 1], "", Map("append_images", [["Image", "RGB", [1, 1]]]), Map("append_images", [["Image", "RGB", [1, 1]]]), 0],
                ["save_all_write_return", 10, 10],
                ["fail", "", 0],
            ], StdlibPillowMemorySave.Events)
        } finally {
            if IsSet(appendImage)
                StdlibPillowTest.CloseImage(appendImage)
            if IsSet(image)
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestImageRegistryCaseNormalizationMatchesLocalPillow113()
    {
        lowerFmt := "ahkcase_demo"
        upperFmt := "AHKCASE_DEMO"
        ext := ".ahkcase-demo"
        mime := "image/x-ahkcase-demo"

        StdlibPillowDemoSave.Events := []
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_save(lowerFmt, StdlibPillowDemoSave))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_save_all(lowerFmt, StdlibPillowDemoSaveAll))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_extension(lowerFmt, ext))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.register_mime(lowerFmt, mime))
        AhkTest.AssertEqual(upperFmt, stdlib.pillow.Image.registered_extensions()[ext])

        image := unset
        try {
            image := stdlib.pillow.Image.new("RGB", [1, 1], [1, 2, 3])
            byExtensionPath := StdlibPillowTest.TempPath("case" ext)
            explicitLowerPath := StdlibPillowTest.TempPath("case-explicit.out")
            saveAllLowerPath := StdlibPillowTest.TempPath("case-save-all.out")

            AhkTest.AssertSame(stdlib.None, image.save(byExtensionPath, unset, { quality: 44 }))
            AhkTest.AssertEqual([65, 72, 75, 83, 65, 86, 69, 58, 82, 71, 66], StdlibPillowTest.ReadBytes(byExtensionPath))
            AhkTest.AssertSame(stdlib.None, image.save(explicitLowerPath, lowerFmt))
            AhkTest.AssertEqual([65, 72, 75, 83, 65, 86, 69, 58, 82, 71, 66], StdlibPillowTest.ReadBytes(explicitLowerPath))
            AhkTest.AssertSame(stdlib.None, image.save(saveAllLowerPath, lowerFmt, { save_all: true }))
            AhkTest.AssertEqual([65, 72, 75, 83, 65, 86, 69, 65, 76, 76], StdlibPillowTest.ReadBytes(saveAllLowerPath))
            AhkTest.AssertEqual([
                ["save", "RGB", [1, 1], byExtensionPath, Map("quality", 44)],
                ["save_write_return", 11],
                ["save", "RGB", [1, 1], explicitLowerPath, Map()],
                ["save_write_return", 11],
                ["save_all", "RGB", [1, 1], saveAllLowerPath, Map()],
                ["save_all_write_return", 10],
            ], StdlibPillowDemoSave.Events)
        } finally {
            if IsSet(image)
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestImageModuleHelpersAndGradientsMatchLocalPillow113()
    {
        linear := unset
        radial := unset
        linearP := unset
        radialP := unset
        image := unset
        try {
            AhkTest.AssertEqual(1, stdlib.pillow.Image.getmodebands("L"))
            AhkTest.AssertEqual(2, stdlib.pillow.Image.getmodebands("LA"))
            AhkTest.AssertEqual(3, stdlib.pillow.Image.getmodebands("RGB"))
            AhkTest.AssertEqual(4, stdlib.pillow.Image.getmodebands("RGBA"))
            AhkTest.AssertEqual(["R", "G", "B"], stdlib.pillow.Image.getmodebandnames("RGB"))
            AhkTest.AssertEqual(["C", "M", "Y", "K"], stdlib.pillow.Image.getmodebandnames("CMYK"))
            AhkTest.AssertEqual(["L", "A"], stdlib.pillow.Image.getmodebandnames("LA"))
            AhkTest.AssertEqual("L", stdlib.pillow.Image.getmodebase("1"))
            AhkTest.AssertEqual("L", stdlib.pillow.Image.getmodebase("I;16"))
            AhkTest.AssertEqual("RGB", stdlib.pillow.Image.getmodebase("RGBA"))
            AhkTest.AssertEqual("L", stdlib.pillow.Image.getmodetype("RGBA"))
            AhkTest.AssertEqual("I", stdlib.pillow.Image.getmodetype("I"))
            AhkTest.AssertEqual("F", stdlib.pillow.Image.getmodetype("F"))

            image := stdlib.pillow.Image.new("RGB", [1, 1])
            AhkTest.AssertTrue(stdlib.pillow.Image.isImageType(image))
            AhkTest.AssertFalse(stdlib.pillow.Image.isImageType(stdlib.None))
            AhkTest.AssertFalse(stdlib.pillow.Image.isImageType(Map()))

            linear := stdlib.pillow.Image.linear_gradient("L")
            AhkTest.AssertEqual("L", linear.mode)
            AhkTest.AssertEqual([256, 256], linear.size)
            AhkTest.AssertEqual(0, linear.getpixel([0, 0]))
            AhkTest.AssertEqual(1, linear.getpixel([0, 1]))
            AhkTest.AssertEqual(127, linear.getpixel([0, 127]))
            AhkTest.AssertEqual(128, linear.getpixel([0, 128]))
            AhkTest.AssertEqual(255, linear.getpixel([0, 255]))
            AhkTest.AssertEqual(127, linear.getpixel([127, 127]))

            radial := stdlib.pillow.Image.radial_gradient("L")
            AhkTest.AssertEqual("L", radial.mode)
            AhkTest.AssertEqual([256, 256], radial.size)
            AhkTest.AssertEqual(255, radial.getpixel([0, 0]))
            AhkTest.AssertEqual(181, radial.getpixel([0, 127]))
            AhkTest.AssertEqual(181, radial.getpixel([0, 128]))
            AhkTest.AssertEqual(2, radial.getpixel([127, 127]))
            AhkTest.AssertEqual(254, radial.getpixel([255, 255]))

            linearP := stdlib.pillow.Image.linear_gradient("P")
            radialP := stdlib.pillow.Image.radial_gradient("P")
            AhkTest.AssertEqual("P", linearP.mode)
            AhkTest.AssertEqual("P", radialP.mode)
            AhkTest.AssertEqual(128, linearP.getpixel([0, 128]))
            AhkTest.AssertEqual(2, radialP.getpixel([127, 127]))

            AhkTest.RaisesMatch(KeyError, "^'BAD'$", (*) => stdlib.pillow.Image.getmodebands("BAD"))
            AhkTest.RaisesMatch(KeyError, "^'BAD'$", (*) => stdlib.pillow.Image.getmodebandnames("BAD"))
            AhkTest.RaisesMatch(KeyError, "^'BAD'$", (*) => stdlib.pillow.Image.getmodebase("BAD"))
            AhkTest.RaisesMatch(KeyError, "^'BAD'$", (*) => stdlib.pillow.Image.getmodetype("BAD"))
            AhkTest.RaisesMatch(ValueError, "^image has wrong mode$", (*) => stdlib.pillow.Image.linear_gradient("RGB"))
            AhkTest.RaisesMatch(ValueError, "^image has wrong mode$", (*) => stdlib.pillow.Image.radial_gradient("RGBA"))
        } finally {
            if IsSet(radialP)
                StdlibPillowTest.CloseImage(radialP)
            if IsSet(linearP)
                StdlibPillowTest.CloseImage(linearP)
            if IsSet(radial)
                StdlibPillowTest.CloseImage(radial)
            if IsSet(linear)
                StdlibPillowTest.CloseImage(linear)
            if IsSet(image)
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestImageEndianHelpersMatchLocalPillow113()
    {
        bytes := Buffer(4, 0)
        NumPut("UChar", 0x78, bytes, 0)
        NumPut("UChar", 0x56, bytes, 1)
        NumPut("UChar", 0x34, bytes, 2)
        NumPut("UChar", 0x12, bytes, 3)

        AhkTest.AssertTrue(HasMethod(stdlib.pillow.Image, "i32le"))
        AhkTest.AssertTrue(HasMethod(stdlib.pillow.Image, "o32le"))
        AhkTest.AssertTrue(HasMethod(stdlib.pillow.Image, "o32be"))
        AhkTest.AssertEqual(0, stdlib.pillow.Image.i32le([0, 0, 0, 0]))
        AhkTest.AssertEqual(305419896, stdlib.pillow.Image.i32le([0x78, 0x56, 0x34, 0x12]))
        AhkTest.AssertEqual(305419896, stdlib.pillow.Image.i32le(bytes))
        AhkTest.AssertEqual(305419896, stdlib.pillow.Image.i32le([120, 120, 0x78, 0x56, 0x34, 0x12, 121, 121], 2))
        AhkTest.AssertEqual(4294967295, stdlib.pillow.Image.i32le([255, 255, 255, 255]))
        AhkTest.AssertEqual([0, 0, 0, 0], stdlib.pillow.Image.o32le(0))
        AhkTest.AssertEqual([120, 86, 52, 18], stdlib.pillow.Image.o32le(0x12345678))
        AhkTest.AssertEqual([255, 255, 255, 255], stdlib.pillow.Image.o32le(0xFFFFFFFF))
        AhkTest.AssertEqual([0, 0, 0, 0], stdlib.pillow.Image.o32be(0))
        AhkTest.AssertEqual([18, 52, 86, 120], stdlib.pillow.Image.o32be(0x12345678))
        AhkTest.AssertEqual([255, 255, 255, 255], stdlib.pillow.Image.o32be(0xFFFFFFFF))

        AhkTest.RaisesMatch(TypeError, "^i32le\(\) missing 1 required positional argument: 'c'$", (*) => stdlib.pillow.Image.i32le())
        AhkTest.RaisesMatch(TypeError, "^i32le\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => stdlib.pillow.Image.i32le([49, 50, 51, 52], 0, 1))
        AhkTest.RaisesMatch(Error, "^unpack_from requires a buffer of at least 4 bytes for unpacking 4 bytes at offset 0 \(actual buffer size is 3\)$", (*) => stdlib.pillow.Image.i32le([49, 50, 51]))
        AhkTest.RaisesMatch(TypeError, "^'str' object cannot be interpreted as an integer$", (*) => stdlib.pillow.Image.i32le([49, 50, 51, 52], "x"))
        AhkTest.RaisesMatch(TypeError, "^a bytes-like object is required, not 'str'$", (*) => stdlib.pillow.Image.i32le("1234"))
        AhkTest.RaisesMatch(TypeError, "^o32le\(\) missing 1 required positional argument: 'i'$", (*) => stdlib.pillow.Image.o32le())
        AhkTest.RaisesMatch(TypeError, "^o32le\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.pillow.Image.o32le(1, 2))
        AhkTest.RaisesMatch(Error, "^argument out of range$", (*) => stdlib.pillow.Image.o32le(-1))
        AhkTest.RaisesMatch(Error, "^argument out of range$", (*) => stdlib.pillow.Image.o32le(0x100000000))
        AhkTest.RaisesMatch(Error, "^required argument is not an integer$", (*) => stdlib.pillow.Image.o32le("1"))
        AhkTest.RaisesMatch(TypeError, "^o32be\(\) missing 1 required positional argument: 'i'$", (*) => stdlib.pillow.Image.o32be())
        AhkTest.RaisesMatch(TypeError, "^o32be\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.pillow.Image.o32be(1, 2))
        AhkTest.RaisesMatch(Error, "^argument out of range$", (*) => stdlib.pillow.Image.o32be(-1))
        AhkTest.RaisesMatch(Error, "^argument out of range$", (*) => stdlib.pillow.Image.o32be(0x100000000))
        AhkTest.RaisesMatch(Error, "^required argument is not an integer$", (*) => stdlib.pillow.Image.o32be("1"))
    }

    static TestImageInitHelpersMatchLocalPillow113()
    {
        AhkTest.AssertTrue(HasMethod(stdlib.pillow.Image, "preinit"))
        AhkTest.AssertTrue(HasMethod(stdlib.pillow.Image, "init"))
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.preinit())

        extensionsAfterPreinit := stdlib.pillow.Image.registered_extensions()
        AhkTest.AssertEqual("PNG", extensionsAfterPreinit[".png"])
        AhkTest.AssertEqual("JPEG", extensionsAfterPreinit[".jpg"])
        AhkTest.AssertEqual("BMP", extensionsAfterPreinit[".bmp"])

        AhkTest.AssertTrue(stdlib.pillow.Image.init())
        extensionsAfterInit := stdlib.pillow.Image.registered_extensions()
        AhkTest.AssertEqual("TIFF", extensionsAfterInit[".tif"])
        AhkTest.AssertFalse(stdlib.pillow.Image.init())
        AhkTest.AssertSame(stdlib.None, stdlib.pillow.Image.preinit())

        AhkTest.RaisesMatch(TypeError, "^preinit\(\) takes 0 positional arguments but 1 was given$", (*) => stdlib.pillow.Image.preinit(1))
        AhkTest.RaisesMatch(TypeError, "^init\(\) takes 0 positional arguments but 1 was given$", (*) => stdlib.pillow.Image.init(1))
    }

    static TestImageModeDescriptorMatchesLocalPillow113()
    {
        AhkTest.AssertEqual(["mode", "bands", "basemode", "basetype", "typestr"], stdlib.pillow.ImageMode.ModeDescriptor._fields)

        rgb := stdlib.pillow.ImageMode.getmode("RGB")
        AhkTest.AssertSame(rgb, stdlib.pillow.ImageMode.getmode("RGB"))
        AhkTest.AssertEqual("RGB", rgb.mode)
        AhkTest.AssertEqual(["R", "G", "B"], rgb.bands)
        AhkTest.AssertEqual("RGB", rgb.basemode)
        AhkTest.AssertEqual("L", rgb.basetype)
        AhkTest.AssertEqual("|u1", rgb.typestr)
        AhkTest.AssertEqual(5, rgb.Length)
        AhkTest.AssertEqual("RGB", rgb[1])
        AhkTest.AssertEqual(["R", "G", "B"], rgb[2])
        AhkTest.AssertEqual(["RGB", ["R", "G", "B"], "RGB", "L", "|u1"], StdlibPillowTest.ToArray(rgb))
        AhkTest.AssertEqual("RGB", String(rgb))
        AhkTest.AssertEqual("ModeDescriptor(mode='RGB', bands=('R', 'G', 'B'), basemode='RGB', basetype='L', typestr='|u1')", rgb.__Repr())
        rgbDict := rgb._asdict()
        AhkTest.AssertEqual("RGB", rgbDict["mode"])
        AhkTest.AssertEqual(["R", "G", "B"], rgbDict["bands"])
        AhkTest.AssertEqual("RGB", rgbDict["basemode"])
        AhkTest.AssertEqual("L", rgbDict["basetype"])
        AhkTest.AssertEqual("|u1", rgbDict["typestr"])

        rgba := stdlib.pillow.ImageMode.getmode("RGBA")
        AhkTest.AssertEqual(["R", "G", "B", "A"], rgba.bands)
        AhkTest.AssertEqual("RGB", rgba.basemode)
        AhkTest.AssertEqual("L", rgba.basetype)
        AhkTest.AssertEqual("|u1", rgba.typestr)

        lMode := stdlib.pillow.ImageMode.getmode("L")
        AhkTest.AssertEqual(["L"], lMode.bands)
        AhkTest.AssertEqual("L", lMode.basemode)
        AhkTest.AssertEqual("L", lMode.basetype)

        palette := stdlib.pillow.ImageMode.getmode("P")
        AhkTest.AssertEqual(["P"], palette.bands)
        AhkTest.AssertEqual("P", palette.basemode)
        AhkTest.AssertEqual("L", palette.basetype)

        cmyk := stdlib.pillow.ImageMode.getmode("CMYK")
        AhkTest.AssertEqual(["C", "M", "Y", "K"], cmyk.bands)
        AhkTest.AssertEqual("RGB", cmyk.basemode)

        i16 := stdlib.pillow.ImageMode.getmode("I;16")
        AhkTest.AssertEqual(["I"], i16.bands)
        AhkTest.AssertEqual("L", i16.basemode)
        AhkTest.AssertEqual("L", i16.basetype)
        AhkTest.AssertEqual("<u2", i16.typestr)

        custom := stdlib.pillow.ImageMode.ModeDescriptor("X", ["A"], "X", "X", "|u1")
        AhkTest.AssertEqual("X", String(custom))
        AhkTest.AssertEqual("ModeDescriptor(mode='X', bands=('A',), basemode='X', basetype='X', typestr='|u1')", custom.__Repr())

        AhkTest.RaisesMatch(KeyError, "^'BAD'$", (*) => stdlib.pillow.ImageMode.getmode("BAD"))
        AhkTest.RaisesMatch(KeyError, "^None$", (*) => stdlib.pillow.ImageMode.getmode(stdlib.None))
        AhkTest.RaisesMatch(KeyError, "^1$", (*) => stdlib.pillow.ImageMode.getmode(1))
        AhkTest.RaisesMatch(TypeError, "^getmode\(\) missing 1 required positional argument: 'mode'$", (*) => stdlib.pillow.ImageMode.getmode())
        AhkTest.RaisesMatch(TypeError, "^getmode\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.pillow.ImageMode.getmode("RGB", "x"))
    }

    static TestImagePathModuleMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "ImagePath"))
        AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImagePath, "Path"))

        path := stdlib.pillow.ImagePath.Path([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        AhkTest.AssertEqual(5, path.__Len)
        AhkTest.AssertEqual([0.0, 1.0], path[0])
        AhkTest.AssertEqual([8.0, 9.0], path[-1])
        AhkTest.AssertEqual([[0.0, 1.0]], path[stdlib.slice(stdlib.None, 1)])
        AhkTest.AssertEqual([
            [0.0, 1.0],
            [2.0, 3.0],
            [4.0, 5.0],
            [6.0, 7.0],
            [8.0, 9.0],
        ], StdlibPillowTest.ToArray(path))
        AhkTest.AssertEqual([
            [0.0, 1.0],
            [2.0, 3.0],
            [4.0, 5.0],
            [6.0, 7.0],
            [8.0, 9.0],
        ], path.tolist())
        AhkTest.AssertEqual([0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0], path.tolist(true))
        AhkTest.AssertEqual([0.0, 1.0, 8.0, 9.0], path.getbbox())
        AhkTest.AssertEqual(2, path.compact(5))
        AhkTest.AssertEqual([[0.0, 1.0], [4.0, 5.0], [8.0, 9.0]], path.tolist())
        AhkTest.AssertSame(stdlib.None, path.transform([1, 0, 1, 0, 1, 1]))
        AhkTest.AssertEqual([[1.0, 2.0], [5.0, 6.0], [9.0, 10.0]], path.tolist())

        mapped := stdlib.pillow.ImagePath.Path([0, 1, 2, 3, 4, 5])
        AhkTest.AssertSame(stdlib.None, mapped.map((x, y) => [x * 2, y * 3]))
        AhkTest.AssertEqual([[0.0, 3.0], [4.0, 9.0], [8.0, 15.0]], mapped.tolist())

        wrapped := stdlib.pillow.ImagePath.Path([0, 1, 2, 3])
        AhkTest.AssertSame(stdlib.None, wrapped.transform([1, 0, 20, 0, 1, 20], 1.0))
        AhkTest.AssertEqual([[0.0, 21.0], [0.0, 23.0]], wrapped.tolist())

        AhkTest.AssertEqual([], stdlib.pillow.ImagePath.Path(0).tolist())
        AhkTest.AssertEqual([[0.0, 0.0]], stdlib.pillow.ImagePath.Path(1).tolist())
        AhkTest.AssertEqual([[0.0, 1.0]], stdlib.pillow.ImagePath.Path([[0, 1]]).tolist())
        AhkTest.AssertEqual([[0.0, 1.0]], stdlib.pillow.ImagePath.Path(stdlib.pillow.ImagePath.Path([0, 1])).tolist())
        AhkTest.AssertEqual([1.0, 0.0, 3.0, 2.0], stdlib.pillow.ImagePath.Path([3, 2, 1, 0]).getbbox())
        AhkTest.AssertEqual([0.0, 0.0, 0.0, 0.0], stdlib.pillow.ImagePath.Path(0).getbbox())
        AhkTest.AssertEqual(0, stdlib.pillow.ImagePath.Path([0, 1, 2, 3]).compact())

        AhkTest.RaisesMatch(TypeError, "^Path indices must be integers, not str$", (*) => path["foo"])
        AhkTest.RaisesMatch(ValueError, "^incorrect coordinate type$", (*) => stdlib.pillow.ImagePath.Path(["a", "b"]))
        AhkTest.RaisesMatch(ValueError, "^wrong number of coordinates$", (*) => stdlib.pillow.ImagePath.Path([0]))
        AhkTest.RaisesMatch(ValueError, "^wrong number of coordinates$", (*) => stdlib.pillow.ImagePath.Path([0, 1, 2]))
        AhkTest.RaisesMatch(TypeError, "^getbbox\(\) takes exactly 0 arguments \(1 given\)$", (*) => path.getbbox(1))
    }

    static TestImageMathModuleMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "ImageMath"))
        AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageMath, "unsafe_eval"))
        AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageMath, "lambda_eval"))
        AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageMath, "eval"))

        a := stdlib.pillow.Image.new("L", [3, 2])
        b := stdlib.pillow.Image.new("L", [3, 2])
        c := stdlib.pillow.Image.new("RGB", [1, 1], [1, 2, 3])
        outputs := []
        try {
            a.putdata([10, 100, 250, 0, 128, 255])
            b.putdata([20, 160, 30, 255, 128, 1])
            context := Map("A", a, "B", b)

            sum := stdlib.pillow.ImageMath.unsafe_eval("A+B", context)
            outputs.Push(sum)
            AhkTest.AssertEqual("I", sum.mode)
            AhkTest.AssertEqual([3, 2], sum.size)
            AhkTest.AssertEqual([[30, 260, 280], [255, 256, 256]], StdlibPillowTest.PixelRows(sum))

            addScalar := stdlib.pillow.ImageMath.unsafe_eval("A+2", context)
            outputs.Push(addScalar)
            AhkTest.AssertEqual("I", addScalar.mode)
            AhkTest.AssertEqual([[12, 102, 252], [2, 130, 257]], StdlibPillowTest.PixelRows(addScalar))
            reverseAdd := stdlib.pillow.ImageMath.unsafe_eval("2+A", context)
            outputs.Push(reverseAdd)
            AhkTest.AssertEqual(StdlibPillowTest.PixelRows(addScalar), StdlibPillowTest.PixelRows(reverseAdd))

            subtract := stdlib.pillow.ImageMath.unsafe_eval("A-B", context)
            outputs.Push(subtract)
            AhkTest.AssertEqual([[-10, -60, 220], [-255, 0, 254]], StdlibPillowTest.PixelRows(subtract))
            multiply := stdlib.pillow.ImageMath.unsafe_eval("A*B", context)
            outputs.Push(multiply)
            AhkTest.AssertEqual([[200, 16000, 7500], [0, 16384, 255]], StdlibPillowTest.PixelRows(multiply))
            divided := stdlib.pillow.ImageMath.unsafe_eval("B/2", context)
            outputs.Push(divided)
            AhkTest.AssertEqual([[10, 80, 15], [127, 64, 0]], StdlibPillowTest.PixelRows(divided))
            absolute := stdlib.pillow.ImageMath.unsafe_eval("abs(A-12)", context)
            outputs.Push(absolute)
            AhkTest.AssertEqual([[2, 88, 238], [12, 116, 243]], StdlibPillowTest.PixelRows(absolute))

            minImage := stdlib.pillow.ImageMath.unsafe_eval("min(A,B)", context)
            outputs.Push(minImage)
            AhkTest.AssertEqual([[10, 100, 30], [0, 128, 1]], StdlibPillowTest.PixelRows(minImage))
            maxImage := stdlib.pillow.ImageMath.unsafe_eval("max(A, 60)", context)
            outputs.Push(maxImage)
            AhkTest.AssertEqual([[60, 100, 250], [60, 128, 255]], StdlibPillowTest.PixelRows(maxImage))
            equalImage := stdlib.pillow.ImageMath.unsafe_eval("equal(A,B)", context)
            outputs.Push(equalImage)
            AhkTest.AssertEqual([[0, 0, 0], [0, 1, 0]], StdlibPillowTest.PixelRows(equalImage))
            notEqualImage := stdlib.pillow.ImageMath.unsafe_eval("notequal(A,B)", context)
            outputs.Push(notEqualImage)
            AhkTest.AssertEqual([[1, 1, 1], [1, 0, 1]], StdlibPillowTest.PixelRows(notEqualImage))

            converted := stdlib.pillow.ImageMath.unsafe_eval("convert(A, `"L`")", context)
            outputs.Push(converted)
            AhkTest.AssertEqual("L", converted.mode)
            AhkTest.AssertEqual(StdlibPillowTest.PixelRows(a), StdlibPillowTest.PixelRows(converted))
            coerced := stdlib.pillow.ImageMath.unsafe_eval("int(float(A))", context)
            outputs.Push(coerced)
            AhkTest.AssertEqual("I", coerced.mode)
            AhkTest.AssertEqual(StdlibPillowTest.PixelRows(a), StdlibPillowTest.PixelRows(coerced))

            AhkTest.AssertEqual(42, stdlib.pillow.ImageMath.unsafe_eval("42", context))
            same := stdlib.pillow.ImageMath.unsafe_eval("A", context)
            AhkTest.AssertSame(a, same)
            AhkTest.AssertEqual(3, stdlib.pillow.ImageMath.lambda_eval((args) => 1 + args["x"], Map("x", 2)))
            lambdaImage := stdlib.pillow.ImageMath.lambda_eval((args) => args["A"], Map("A", a))
            AhkTest.AssertSame(a, lambdaImage)
            evaluated := stdlib.pillow.ImageMath.eval("A+B", context)
            outputs.Push(evaluated)
            AhkTest.AssertEqual([[30, 260, 280], [255, 256, 256]], StdlibPillowTest.PixelRows(evaluated))

            AhkTest.RaisesMatch(ValueError, "^'open' not allowed$", (*) => stdlib.pillow.ImageMath.unsafe_eval("open(`"x`")"))
            AhkTest.RaisesMatch(ValueError, "^'__x' not allowed$", (*) => stdlib.pillow.ImageMath.unsafe_eval("A", Map("__x", a)))
            AhkTest.RaisesMatch(ValueError, "^unsupported mode: RGB$", (*) => stdlib.pillow.ImageMath.unsafe_eval("C+C", Map("C", c)))
            AhkTest.RaisesMatch(ValueError, "^'Z' not allowed$", (*) => stdlib.pillow.ImageMath.unsafe_eval("A+Z", Map("A", a)))
        } finally {
            for image in outputs
                StdlibPillowTest.CloseImage(image)
            StdlibPillowTest.CloseImage(c)
            StdlibPillowTest.CloseImage(b)
            StdlibPillowTest.CloseImage(a)
        }
    }

    static TestImageFileParserMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "ImageFile"))
        AhkTest.AssertEqual(65536, stdlib.pillow.ImageFile.MAXBLOCK)
        AhkTest.AssertFalse(stdlib.pillow.ImageFile.LOAD_TRUNCATED_IMAGES)
        AhkTest.AssertEqual("image buffer overrun error", stdlib.pillow.ImageFile.ERRORS[-1])
        AhkTest.AssertEqual("decoding error", stdlib.pillow.ImageFile.ERRORS[-2])
        AhkTest.AssertEqual("unknown error", stdlib.pillow.ImageFile.ERRORS[-3])
        AhkTest.AssertEqual("bad configuration", stdlib.pillow.ImageFile.ERRORS[-8])
        AhkTest.AssertEqual("out of memory error", stdlib.pillow.ImageFile.ERRORS[-9])

        source := stdlib.pillow.Image.new("RGB", [2, 1])
        pngFp := stdlib.io.BytesIO()
        bmpFp := stdlib.io.BytesIO()
        jpegFp := stdlib.io.BytesIO()
        pngImage := unset
        bmpImage := unset
        jpegImage := unset
        contextImage := unset
        try {
            source.putdata([[10, 20, 30], [200, 10, 5]])
            source.save(pngFp, "PNG")
            source.save(bmpFp, "BMP")
            source.save(jpegFp, "JPEG")

            pngBytes := pngFp.getvalue()
            parser := stdlib.pillow.ImageFile.Parser()
            AhkTest.AssertSame(stdlib.None, parser.data)
            AhkTest.AssertSame(stdlib.None, parser.image)
            AhkTest.AssertEqual(0, parser.finished)
            AhkTest.AssertSame(stdlib.None, parser.incremental)
            AhkTest.AssertSame(parser, parser.__Enter())

            AhkTest.AssertSame(stdlib.None, parser.feed(StdlibPillowTest.ArraySlice(pngBytes, 1, 1)))
            AhkTest.AssertSame(stdlib.None, parser.feed(StdlibPillowTest.ArraySlice(pngBytes, 2, 4)))
            AhkTest.AssertSame(stdlib.None, parser.feed(StdlibPillowTest.ArraySlice(pngBytes, 5, pngBytes.Length)))
            AhkTest.AssertEqual(pngBytes.Length, parser.data.Length)
            AhkTest.AssertTrue(IsObject(parser.image))
            AhkTest.AssertEqual("PNG", parser.image.format)
            pngImage := parser.close()
            AhkTest.AssertSame(pngImage, parser.image)
            AhkTest.AssertEqual("PNG", pngImage.format)
            AhkTest.AssertEqual("RGB", pngImage.mode)
            AhkTest.AssertEqual([2, 1], pngImage.size)
            AhkTest.AssertEqual([[[10, 20, 30], [200, 10, 5]]], StdlibPillowTest.PixelRows(pngImage))
            AhkTest.AssertSame(pngImage, parser.close())

            bmpParser := stdlib.pillow.ImageFile.Parser()
            AhkTest.AssertSame(stdlib.None, bmpParser.feed(bmpFp.getvalue()))
            bmpImage := bmpParser.close()
            AhkTest.AssertEqual("BMP", bmpImage.format)
            AhkTest.AssertEqual([[[10, 20, 30], [200, 10, 5]]], StdlibPillowTest.PixelRows(bmpImage))

            jpegParser := stdlib.pillow.ImageFile.Parser()
            AhkTest.AssertSame(stdlib.None, jpegParser.feed(jpegFp.getvalue()))
            jpegImage := jpegParser.close()
            AhkTest.AssertEqual("JPEG", jpegImage.format)
            AhkTest.AssertEqual("RGB", jpegImage.mode)
            AhkTest.AssertEqual([2, 1], jpegImage.size)

            resetParser := stdlib.pillow.ImageFile.Parser()
            AhkTest.AssertSame(stdlib.None, resetParser.reset())
            AhkTest.AssertSame(stdlib.None, resetParser.data)
            AhkTest.AssertSame(stdlib.None, resetParser.image)
            resetUsed := stdlib.pillow.ImageFile.Parser()
            resetUsed.feed(StdlibPillowTest.ArraySlice(pngBytes, 1, 10))
            AhkTest.RaisesMatch(stdlib.assert.AssertionError, "^cannot reuse parsers$", (*) => resetUsed.reset())

            contextParser := stdlib.pillow.ImageFile.Parser()
            AhkTest.AssertSame(contextParser, contextParser.__Enter())
            contextParser.feed(pngBytes)
            contextImage := contextParser.close()
            AhkTest.AssertSame(stdlib.None, contextParser.__Exit(stdlib.None, stdlib.None, stdlib.None))
            AhkTest.AssertEqual([[[10, 20, 30], [200, 10, 5]]], StdlibPillowTest.PixelRows(contextImage))

            AhkTest.RaisesMatch(TypeError, "^a bytes-like object is required, not 'str'$", (*) => stdlib.pillow.ImageFile.Parser().feed("abc"))
            AhkTest.RaisesMatch(OSError, "^cannot parse this image$", (*) => stdlib.pillow.ImageFile.Parser().close())
            AhkTest.RaisesMatch(OSError, "^cannot parse this image$", (*) => stdlib.pillow.ImageFile.Parser().__Exit(stdlib.None, stdlib.None, stdlib.None))
            AhkTest.RaisesMatch(TypeError, "^Parser\(\) takes no arguments$", (*) => stdlib.pillow.ImageFile.Parser(1))
        } finally {
            if IsSet(contextImage)
                StdlibPillowTest.CloseImage(contextImage)
            if IsSet(jpegImage)
                StdlibPillowTest.CloseImage(jpegImage)
            if IsSet(bmpImage)
                StdlibPillowTest.CloseImage(bmpImage)
            if IsSet(pngImage)
                StdlibPillowTest.CloseImage(pngImage)
            if IsSet(source)
                StdlibPillowTest.CloseImage(source)
        }
    }

    static TestImageFileBaseAndCodecSurfaceMatchesLocalPillow113()
    {
        imageFile := stdlib.pillow.ImageFile
        AhkTest.AssertEqual(1048576, imageFile.SAFEBLOCK)
        AhkTest.AssertTrue(HasProp(imageFile, "ImageFile"))
        AhkTest.AssertTrue(HasProp(imageFile, "PyCodec"))
        AhkTest.AssertTrue(HasProp(imageFile, "PyCodecState"))
        AhkTest.AssertTrue(HasProp(imageFile, "PyDecoder"))
        AhkTest.AssertTrue(HasProp(imageFile, "PyEncoder"))
        AhkTest.AssertTrue(HasProp(imageFile, "StubHandler"))
        AhkTest.AssertTrue(HasProp(imageFile, "StubImageFile"))
        AhkTest.AssertTrue(HasProp(imageFile, "raise_oserror"))

        state := imageFile.PyCodecState()
        state.xoff := 2
        state.yoff := 3
        state.xsize := 4
        state.ysize := 5
        AhkTest.AssertEqual([2, 3, 6, 8], state.extents())

        AhkTest.RaisesMatch(TypeError, "^Can't instantiate abstract class PyCodec with abstract method init$", (*) => imageFile.PyCodec("RGB"))
        AhkTest.RaisesMatch(TypeError, "^Can't instantiate abstract class PyDecoder with abstract method decode$", (*) => imageFile.PyDecoder("RGB"))
        AhkTest.RaisesMatch(TypeError, "^Can't instantiate abstract class PyEncoder with abstract method encode$", (*) => imageFile.PyEncoder("RGB"))
        AhkTest.RaisesMatch(TypeError, "^Can't instantiate abstract class StubHandler with abstract method load$", (*) => imageFile.StubHandler())
        AhkTest.RaisesMatch(TypeError, "^Can't instantiate abstract class StubImageFile with abstract methods _load, _open$", (*) => imageFile.StubImageFile(stdlib.io.BytesIO([97, 98, 99])))
        AhkTest.RaisesMatch(TypeError, "^ImageFile\.__init__\(\) missing 1 required positional argument: 'fp'$", (*) => imageFile.ImageFile())
        AhkTest.RaisesMatch(TypeError, "^PyCodec\.__init__\(\) missing 1 required positional argument: 'mode'$", (*) => imageFile.PyDecoder())
        AhkTest.RaisesMatch(TypeError, "^PyCodec\.__init__\(\) missing 1 required positional argument: 'mode'$", (*) => imageFile.PyEncoder())

        raiseRecords := stdlib.warnings.catch_warnings(true).Call((records) => (
            AhkTest.RaisesMatch(OSError, "^broken data stream when reading image file$", (*) => imageFile.raise_oserror(-2)),
            records
        ))
        AhkTest.AssertEqual(1, raiseRecords.Length)
        AhkTest.AssertSame(stdlib.warnings.DeprecationWarning, raiseRecords[1].category)
        AhkTest.AssertContains("raise_oserror is deprecated", raiseRecords[1].message)
    }

    static TestImageFileSubclassBehaviorMatchesLocalPillow113()
    {
        imageFile := stdlib.pillow.ImageFile

        decoder := StdlibPillowImageFileProbeDecoder("RGB")
        AhkTest.AssertEqual("RGB", decoder.mode)
        AhkTest.AssertEqual([], decoder.args)
        AhkTest.AssertFalse(decoder.pulls_fd)

        encoder := StdlibPillowImageFileProbeEncoder("RGB", 1, "x")
        AhkTest.AssertEqual([1, "x"], encoder.args)
        AhkTest.AssertFalse(encoder.pushes_fd)
        AhkTest.AssertEqual([0, -8], encoder.encode_to_pyfd())

        pushEncoder := StdlibPillowImageFileProbePushEncoder("RGB")
        pushSink := stdlib.io.BytesIO()
        AhkTest.AssertSame(stdlib.None, pushEncoder.setfd(pushSink))
        AhkTest.AssertEqual([3, 1], pushEncoder.encode_to_pyfd())
        AhkTest.AssertEqual([97, 98, 99], pushSink.getvalue())

        stub := StdlibPillowImageFileProbeStub(stdlib.io.BytesIO([97, 98, 99]))
        AhkTest.AssertEqual("RGB", stub.mode)
        AhkTest.AssertEqual([1, 1], stub.size)
        AhkTest.AssertEqual("ProbeStub", stub.AhkStdlibTypeName)
        AhkTest.AssertEqual("PixelAccess", Type(stub.load()))
        AhkTest.AssertTrue(stub is AhkStdlibPillowImage)
        AhkTest.AssertEqual([1, 2, 3], stub.getpixel([0, 0]))

        base := StdlibPillowImageFileProbeImageFile(stdlib.io.BytesIO([97, 98, 99]))
        AhkTest.AssertEqual("RGB", base.mode)
        AhkTest.AssertEqual([1, 1], base.size)
        AhkTest.AssertEqual(1, base.readonly)
        AhkTest.AssertEqual([], base.tile)
        AhkTest.AssertEqual([], base.get_child_images())
        AhkTest.AssertSame(stdlib.None, base.get_format_mimetype())
        AhkTest.AssertSame(stdlib.None, base.verify())
        AhkTest.AssertSame(stdlib.None, base.fp)

        baseLoadError := StdlibPillowImageFileProbeImageFile(stdlib.io.BytesIO([97, 98, 99]))
        AhkTest.RaisesMatch(OSError, "^cannot load this image$", (*) => baseLoadError.load())

        basePrepare := StdlibPillowImageFileProbeImageFile(stdlib.io.BytesIO([97, 98, 99]))
        AhkTest.AssertSame(stdlib.None, basePrepare.load_prepare())
        AhkTest.AssertEqual([1, 1], basePrepare.im.size)
        AhkTest.AssertSame(stdlib.None, basePrepare.load_end())

        baseClose := StdlibPillowImageFileProbeImageFile(stdlib.io.BytesIO([97, 98, 99]))
        AhkTest.AssertSame(stdlib.None, baseClose.close())
        AhkTest.AssertSame(stdlib.None, baseClose.fp)
    }

    static TestImageFontLoadDefaultMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "ImageFont"))
        AhkTest.AssertEqual(1000000, stdlib.pillow.ImageFont.MAX_STRING_LENGTH)
        AhkTest.AssertEqual(0, stdlib.pillow.ImageFont.Layout.BASIC)
        AhkTest.AssertEqual(1, stdlib.pillow.ImageFont.Layout.RAQM)
        AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageFont, "load_default"))

        font := stdlib.pillow.ImageFont.load_default()
        AhkTest.AssertEqual("FreeTypeFont", font.AhkStdlibTypeName)
        AhkTest.AssertEqual([0, 0, 0, 0], font.getbbox(""))
        AhkTest.AssertEqual(0.0, font.getlength(""))
        AhkTest.AssertEqual([0, 2, 7, 10], font.getbbox("A"))
        AhkTest.AssertEqual(6.0, font.getlength("A"))
        AhkTest.AssertEqual([0, 2, 16, 10], font.getbbox("abc"))
        AhkTest.AssertEqual(16.0, font.getlength("abc"))
        AhkTest.AssertEqual([0, 2, 25, 10], font.getbbox("Hello"))
        AhkTest.AssertEqual(25.0, font.getlength("Hello"))
        AhkTest.AssertEqual([0, 2, 58, 10], font.getbbox("Hello`nWorld"))
        AhkTest.AssertEqual(58.0, font.getlength("Hello`nWorld"))

        emptyMask := font.getmask("")
        AhkTest.AssertEqual("L", emptyMask.mode)
        AhkTest.AssertEqual([0, 0], emptyMask.size)
        AhkTest.AssertSame(stdlib.None, emptyMask.getbbox())
        AhkTest.AssertEqual(0, emptyMask.__Len)

        helloMask := font.getmask("Hello")
        AhkTest.AssertEqual("L", helloMask.mode)
        AhkTest.AssertEqual([25, 8], helloMask.size)
        AhkTest.AssertEqual([1, 0, 25, 8], helloMask.getbbox())
        AhkTest.AssertEqual(200, helloMask.__Len)

        sized := stdlib.pillow.ImageFont.load_default(20)
        AhkTest.AssertEqual([0, 5, 34, 20], sized.getbbox("abc"))
        AhkTest.AssertEqual(34.0, sized.getlength("abc"))

        AhkTest.RaisesMatch(TypeError, "^load_default\(\) takes from 0 to 1 positional arguments but 2 were given$", (*) => stdlib.pillow.ImageFont.load_default(1, 2))
        AhkTest.RaisesMatch(ValueError, "^font size must be greater than 0, not 0$", (*) => stdlib.pillow.ImageFont.load_default(0))
        AhkTest.RaisesMatch(ValueError, "^font size must be greater than 0, not -1$", (*) => stdlib.pillow.ImageFont.load_default(-1))
        AhkTest.RaisesMatch(TypeError, "^'<=' not supported between instances of 'str' and 'int'$", (*) => stdlib.pillow.ImageFont.load_default("x"))
        AhkTest.RaisesMatch(TypeError, "^object of type 'NoneType' has no len\(\)$", (*) => font.getbbox(stdlib.None))
        AhkTest.RaisesMatch(TypeError, "^object of type 'NoneType' has no len\(\)$", (*) => font.getlength(stdlib.None))
        AhkTest.RaisesMatch(TypeError, "^object of type 'NoneType' has no len\(\)$", (*) => font.getmask(stdlib.None))
    }

    static TestImageFontBaseClassMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageFont, "ImageFont"))

        font := stdlib.pillow.ImageFont.ImageFont()
        AhkTest.AssertEqual("ImageFont", font.AhkStdlibTypeName)
        AhkTest.AssertFalse(HasProp(font, "path"))
        AhkTest.AssertFalse(HasProp(font, "size"))
        AhkTest.AssertFalse(HasProp(font, "font"))
        AhkTest.AssertTrue(HasMethod(font, "getmask"))
        AhkTest.AssertTrue(HasMethod(font, "getbbox"))
        AhkTest.AssertTrue(HasMethod(font, "getlength"))

        AhkTest.RaisesMatch(TypeError, "^ImageFont\(\) takes no arguments$", (*) => stdlib.pillow.ImageFont.ImageFont(1))
        AhkTest.RaisesMatch(TypeError, "^ImageFont\.getmask\(\) missing 1 required positional argument: 'text'$", (*) => font.getmask())
        AhkTest.RaisesMatch(TypeError, "^ImageFont\.getbbox\(\) missing 1 required positional argument: 'text'$", (*) => font.getbbox())
        AhkTest.RaisesMatch(TypeError, "^ImageFont\.getlength\(\) missing 1 required positional argument: 'text'$", (*) => font.getlength())
        AhkTest.RaisesMatch(AttributeError, "^'ImageFont' object has no attribute 'font'$", (*) => font.getmask("A"))
        AhkTest.RaisesMatch(AttributeError, "^'ImageFont' object has no attribute 'font'$", (*) => font.getbbox("A"))
        AhkTest.RaisesMatch(AttributeError, "^'ImageFont' object has no attribute 'font'$", (*) => font.getlength("A"))
        AhkTest.RaisesMatch(TypeError, "^object of type 'NoneType' has no len\(\)$", (*) => font.getmask(stdlib.None))
        AhkTest.RaisesMatch(TypeError, "^object of type 'NoneType' has no len\(\)$", (*) => font.getbbox(stdlib.None))
        AhkTest.RaisesMatch(TypeError, "^object of type 'NoneType' has no len\(\)$", (*) => font.getlength(stdlib.None))
    }

    static TestImageFontLoadDefaultImagefontMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageFont, "load_default_imagefont"))

        font := stdlib.pillow.ImageFont.load_default_imagefont()
        AhkTest.AssertEqual("ImageFont", font.AhkStdlibTypeName)
        AhkTest.AssertFalse(HasProp(font, "path"))
        AhkTest.AssertFalse(HasProp(font, "size"))

        AhkTest.AssertEqual([0, 0, 0, 11], font.getbbox(""))
        AhkTest.AssertEqual(0, font.getlength(""))
        emptyMask := font.getmask("")
        AhkTest.AssertEqual("1", emptyMask.mode)
        AhkTest.AssertEqual([0, 11], emptyMask.size)
        AhkTest.AssertSame(stdlib.None, emptyMask.getbbox())
        AhkTest.AssertEqual(0, emptyMask.__Len)

        AhkTest.AssertEqual([0, 0, 6, 11], font.getbbox("A"))
        AhkTest.AssertEqual(6, font.getlength("A"))
        aMask := font.getmask("A")
        AhkTest.AssertEqual("1", aMask.mode)
        AhkTest.AssertEqual([6, 11], aMask.size)
        AhkTest.AssertEqual([0, 3, 6, 9], aMask.getbbox())
        AhkTest.AssertEqual(66, aMask.__Len)

        AhkTest.AssertEqual([0, 0, 18, 11], font.getbbox("abc"))
        AhkTest.AssertEqual(18, font.getlength("abc"))
        abcMask := font.getmask("abc")
        AhkTest.AssertEqual("1", abcMask.mode)
        AhkTest.AssertEqual([18, 11], abcMask.size)
        AhkTest.AssertEqual([0, 2, 17, 9], abcMask.getbbox())
        AhkTest.AssertEqual(198, abcMask.__Len)

        AhkTest.AssertEqual([0, 0, 30, 11], font.getbbox("Hello"))
        AhkTest.AssertEqual(30, font.getlength("Hello"))
        helloMask := font.getmask("Hello")
        AhkTest.AssertEqual("1", helloMask.mode)
        AhkTest.AssertEqual([30, 11], helloMask.size)
        AhkTest.AssertEqual([0, 2, 29, 9], helloMask.getbbox())
        AhkTest.AssertEqual(330, helloMask.__Len)

        AhkTest.RaisesMatch(TypeError, "^load_default_imagefont\(\) takes 0 positional arguments but 1 was given$", (*) => stdlib.pillow.ImageFont.load_default_imagefont(1))
        AhkTest.RaisesMatch(TypeError, "^object of type 'NoneType' has no len\(\)$", (*) => font.getbbox(stdlib.None))
        AhkTest.RaisesMatch(TypeError, "^object of type 'NoneType' has no len\(\)$", (*) => font.getlength(stdlib.None))
        AhkTest.RaisesMatch(TypeError, "^object of type 'NoneType' has no len\(\)$", (*) => font.getmask(stdlib.None))
    }

    static TestImageFontLoadAndLoadPathBitmapFontMatchLocalPillow113()
    {
        pilPath := StdlibPillowTest.TempPath("mini.pil")
        root := RegExReplace(pilPath, "\.pil$")
        StdlibPillowTest.WriteMiniPilFont(root)

        AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageFont, "load"))
        AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageFont, "load_path"))

        font := stdlib.pillow.ImageFont.load(pilPath)
        AhkTest.AssertEqual("ImageFont", font.AhkStdlibTypeName)
        AhkTest.AssertEqual(root ".pbm", font.file)
        AhkTest.AssertEqual([], font.info)
        AhkTest.AssertEqual([0, 0, 0, 5], font.getbbox(""))
        AhkTest.AssertEqual(0, font.getlength(""))
        emptyMask := font.getmask("")
        AhkTest.AssertEqual("1", emptyMask.mode)
        AhkTest.AssertEqual([0, 5], emptyMask.size)
        AhkTest.AssertSame(stdlib.None, emptyMask.getbbox())
        AhkTest.AssertEqual(0, emptyMask.__Len)

        AhkTest.AssertEqual([0, 0, 3, 5], font.getbbox("A"))
        AhkTest.AssertEqual(3, font.getlength("A"))
        aMask := font.getmask("A")
        AhkTest.AssertEqual("1", aMask.mode)
        AhkTest.AssertEqual([3, 5], aMask.size)
        AhkTest.AssertEqual([0, 0, 3, 5], aMask.getbbox())
        AhkTest.AssertEqual(15, aMask.__Len)

        AhkTest.AssertEqual([0, 0, 5, 5], font.getbbox("AB"))
        AhkTest.AssertEqual(5, font.getlength("AB"))
        abMask := font.getmask("AB")
        AhkTest.AssertEqual([5, 5], abMask.size)
        AhkTest.AssertEqual([0, 0, 5, 5], abMask.getbbox())
        AhkTest.AssertEqual(25, abMask.__Len)

        AhkTest.AssertEqual([0, 0, 0, 5], font.getbbox("C"))
        AhkTest.AssertEqual(0, font.getlength("C"))
        missingMask := font.getmask("C")
        AhkTest.AssertEqual([0, 5], missingMask.size)
        AhkTest.AssertSame(stdlib.None, missingMask.getbbox())
        AhkTest.AssertEqual(0, missingMask.__Len)

        found := stdlib.pillow.ImageFont.load_path(pilPath)
        AhkTest.AssertEqual([0, 0, 3, 5], found.getbbox("A"))
        AhkTest.AssertEqual(3, found.getlength("A"))

        AhkTest.RaisesMatch(TypeError, "^load\(\) missing 1 required positional argument: 'filename'$", (*) => stdlib.pillow.ImageFont.load())
        AhkTest.RaisesMatch(TypeError, "^load\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.pillow.ImageFont.load(pilPath, "x"))
        AhkTest.RaisesMatch(OSError, "No such file or directory", (*) => stdlib.pillow.ImageFont.load(StdlibPillowTest.TempPath("missing.pil")))
        AhkTest.RaisesMatch(TypeError, "^load_path\(\) missing 1 required positional argument: 'filename'$", (*) => stdlib.pillow.ImageFont.load_path())
        AhkTest.RaisesMatch(TypeError, "^load_path\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.pillow.ImageFont.load_path(pilPath, "x"))
        AhkTest.RaisesMatch(OSError, '^cannot find font file "missing\.pil" in sys\.path$', (*) => stdlib.pillow.ImageFont.load_path("missing.pil"))
    }

    static TestImageFontFreeTypeFontVariantMatchesLocalPillow113()
    {
        fontPath := "C:\Windows\Fonts\arial.ttf"
        if !FileExist(fontPath)
            AhkTest.SkipNow("C:\Windows\Fonts\arial.ttf is required for the local Pillow 11.3.0 ImageFont variant probe")

        font := stdlib.pillow.ImageFont.truetype(fontPath, 12)
        AhkTest.AssertTrue(HasMethod(font, "getname"))
        AhkTest.AssertTrue(HasMethod(font, "getmetrics"))
        AhkTest.AssertTrue(HasMethod(font, "font_variant"))
        AhkTest.AssertEqual("FreeTypeFont", font.AhkStdlibTypeName)
        AhkTest.AssertEqual(12, font.size)
        AhkTest.AssertEqual(fontPath, font.path)
        AhkTest.AssertEqual(["Arial", "Regular"], font.getname())
        AhkTest.AssertEqual([11, 3], font.getmetrics())
        AhkTest.AssertEqual([0, 2, 11, 11], font.getbbox("Hi"))
        AhkTest.AssertApprox(11.34375, font.getlength("Hi"), { Abs: 0.000000000001, Rel: 0.0 })

        variantSame := font.font_variant()
        AhkTest.AssertNotEqual(ObjPtr(font), ObjPtr(variantSame))
        AhkTest.AssertEqual(12, variantSame.size)
        AhkTest.AssertEqual(fontPath, variantSame.path)
        AhkTest.AssertEqual(["Arial", "Regular"], variantSame.getname())
        AhkTest.AssertEqual([11, 3], variantSame.getmetrics())
        AhkTest.AssertEqual([0, 2, 11, 11], variantSame.getbbox("Hi"))
        AhkTest.AssertApprox(11.34375, variantSame.getlength("Hi"), { Abs: 0.000000000001, Rel: 0.0 })

        variantSize := font.font_variant(stdlib.None, 18)
        AhkTest.AssertNotEqual(ObjPtr(font), ObjPtr(variantSize))
        AhkTest.AssertEqual(18, variantSize.size)
        AhkTest.AssertEqual(fontPath, variantSize.path)
        AhkTest.AssertEqual(["Arial", "Regular"], variantSize.getname())
        AhkTest.AssertEqual([17, 4], variantSize.getmetrics())
        AhkTest.AssertEqual([0, 4, 17, 17], variantSize.getbbox("Hi"))
        AhkTest.AssertApprox(17.0, variantSize.getlength("Hi"), { Abs: 0.000000000001, Rel: 0.0 })

        variantFontSize := font.font_variant(fontPath, 14)
        AhkTest.AssertEqual(14, variantFontSize.size)
        AhkTest.AssertEqual(fontPath, variantFontSize.path)
        AhkTest.AssertEqual(["Arial", "Regular"], variantFontSize.getname())
        AhkTest.AssertEqual([13, 3], variantFontSize.getmetrics())
        AhkTest.AssertEqual([0, 3, 13, 13], variantFontSize.getbbox("Hi"))
        AhkTest.AssertApprox(13.21875, variantFontSize.getlength("Hi"), { Abs: 0.000000000001, Rel: 0.0 })

        AhkTest.RaisesMatch(TypeError, "^FreeTypeFont\.getname\(\) takes 1 positional argument but 2 were given$", (*) => font.getname(1))
        AhkTest.RaisesMatch(TypeError, "^FreeTypeFont\.getmetrics\(\) takes 1 positional argument but 2 were given$", (*) => font.getmetrics(1))
        AhkTest.RaisesMatch(OSError, "^cannot open resource$", (*) => font.font_variant("C:\no-such-font.ttf"))
        AhkTest.RaisesMatch(ValueError, "^font size must be greater than 0, not 0$", (*) => font.font_variant(stdlib.None, 0))
        AhkTest.RaisesMatch(TypeError, "^'<=' not supported between instances of 'str' and 'int'$", (*) => font.font_variant(stdlib.None, "x"))
    }

    static TestImageFontFreeTypeFontConstructorMatchesLocalPillow113()
    {
        fontPath := "C:\Windows\Fonts\arial.ttf"
        if !FileExist(fontPath)
            AhkTest.SkipNow("C:\Windows\Fonts\arial.ttf is required for the local Pillow 11.3.0 FreeTypeFont constructor probe")

        AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageFont, "FreeTypeFont"))

        defaultSize := stdlib.pillow.ImageFont.FreeTypeFont(fontPath)
        AhkTest.AssertEqual("FreeTypeFont", defaultSize.AhkStdlibTypeName)
        AhkTest.AssertEqual(fontPath, defaultSize.path)
        AhkTest.AssertEqual(10, defaultSize.size)
        AhkTest.AssertEqual(["Arial", "Regular"], defaultSize.getname())
        AhkTest.AssertEqual([10, 3], defaultSize.getmetrics())
        AhkTest.AssertEqual([0, 3, 9, 10], defaultSize.getbbox("Hi"))
        AhkTest.AssertApprox(9.4375, defaultSize.getlength("Hi"), { Abs: 0.000000000001, Rel: 0.0 })
        defaultMask := defaultSize.getmask("Hi")
        AhkTest.AssertEqual("L", defaultMask.mode)
        AhkTest.AssertEqual([9, 7], defaultMask.size)
        AhkTest.AssertEqual([0, 0, 9, 7], defaultMask.getbbox())
        AhkTest.AssertEqual(63, defaultMask.__Len)

        size12 := stdlib.pillow.ImageFont.FreeTypeFont(fontPath, 12)
        AhkTest.AssertEqual("FreeTypeFont", size12.AhkStdlibTypeName)
        AhkTest.AssertEqual(fontPath, size12.path)
        AhkTest.AssertEqual(12, size12.size)
        AhkTest.AssertEqual(["Arial", "Regular"], size12.getname())
        AhkTest.AssertEqual([11, 3], size12.getmetrics())
        AhkTest.AssertEqual([0, 2, 11, 11], size12.getbbox("Hi"))
        AhkTest.AssertApprox(11.34375, size12.getlength("Hi"), { Abs: 0.000000000001, Rel: 0.0 })

        viaTruetype := stdlib.pillow.ImageFont.truetype(fontPath, 12)
        AhkTest.AssertEqual(viaTruetype.getname(), size12.getname())
        AhkTest.AssertEqual(viaTruetype.getmetrics(), size12.getmetrics())
        AhkTest.AssertEqual(viaTruetype.getbbox("Hi"), size12.getbbox("Hi"))
        AhkTest.AssertApprox(viaTruetype.getlength("Hi"), size12.getlength("Hi"), { Abs: 0.000000000001, Rel: 0.0 })

        AhkTest.RaisesMatch(TypeError, "^FreeTypeFont\.__init__\(\) missing 1 required positional argument: 'font'$", (*) => stdlib.pillow.ImageFont.FreeTypeFont())
        AhkTest.RaisesMatch(TypeError, "^FreeTypeFont\.__init__\(\) takes from 2 to 6 positional arguments but 7 were given$", (*) => stdlib.pillow.ImageFont.FreeTypeFont(fontPath, 12, 0, "", stdlib.None, stdlib.None))
        AhkTest.RaisesMatch(OSError, "^cannot open resource$", (*) => stdlib.pillow.ImageFont.FreeTypeFont("C:\no-such-font.ttf", 12))
        AhkTest.RaisesMatch(ValueError, "^font size must be greater than 0, not 0$", (*) => stdlib.pillow.ImageFont.FreeTypeFont(fontPath, 0))
        AhkTest.RaisesMatch(TypeError, "^'<=' not supported between instances of 'str' and 'int'$", (*) => stdlib.pillow.ImageFont.FreeTypeFont(fontPath, "x"))
    }

    static TestImageFontHelpersMatchLocalPillow113()
    {
        AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageFont, "is_path"))
        AhkTest.AssertTrue(HasProp(stdlib.pillow.ImageFont, "DeferredError"))

        AhkTest.AssertTrue(stdlib.pillow.ImageFont.is_path("x.pil"))
        AhkTest.AssertTrue(stdlib.pillow.ImageFont.is_path(stdlib.pathlib.Path("x.pil")))
        AhkTest.AssertTrue(stdlib.pillow.ImageFont.is_path(StdlibPillowPathLike()))
        AhkTest.AssertFalse(stdlib.pillow.ImageFont.is_path(stdlib.io.BytesIO([120])))
        AhkTest.AssertFalse(stdlib.pillow.ImageFont.is_path(stdlib.None))
        AhkTest.AssertFalse(stdlib.pillow.ImageFont.is_path(1))
        AhkTest.AssertFalse(stdlib.pillow.ImageFont.is_path({}))

        sourceError := RuntimeError("deferred boom", -1)
        deferred := stdlib.pillow.ImageFont.DeferredError(sourceError)
        AhkTest.AssertEqual("DeferredError", deferred.AhkStdlibTypeName)
        AhkTest.AssertSame(sourceError, deferred.ex)

        try {
            unused := deferred.anything
            AhkTest.Fail("DeferredError attribute access should raise the wrapped exception")
        } catch as err {
            AhkTest.AssertSame(sourceError, err)
        }

        newDeferred := stdlib.pillow.ImageFont.DeferredError.new(sourceError)
        AhkTest.AssertEqual("DeferredError", newDeferred.AhkStdlibTypeName)
        AhkTest.AssertSame(sourceError, newDeferred.ex)
        try {
            unused := newDeferred.other
            AhkTest.Fail("DeferredError.new attribute access should raise the wrapped exception")
        } catch as err {
            AhkTest.AssertSame(sourceError, err)
        }

        AhkTest.RaisesMatch(TypeError, "^is_path\(\) missing 1 required positional argument: 'f'$", (*) => stdlib.pillow.ImageFont.is_path())
        AhkTest.RaisesMatch(TypeError, "^is_path\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.pillow.ImageFont.is_path("x", "y"))
        AhkTest.RaisesMatch(TypeError, "^DeferredError\.__init__\(\) missing 1 required positional argument: 'ex'$", (*) => stdlib.pillow.ImageFont.DeferredError())
        AhkTest.RaisesMatch(TypeError, "^DeferredError\.__init__\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.pillow.ImageFont.DeferredError(sourceError, sourceError))
        AhkTest.RaisesMatch(TypeError, "^DeferredError\.new\(\) missing 1 required positional argument: 'ex'$", (*) => stdlib.pillow.ImageFont.DeferredError.new())
        AhkTest.RaisesMatch(TypeError, "^DeferredError\.new\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.pillow.ImageFont.DeferredError.new(sourceError, sourceError))
    }

    static TestImageFontTransposedFontMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageFont, "TransposedFont"))

        font := stdlib.pillow.ImageFont.load_default()
        normal := stdlib.pillow.ImageFont.TransposedFont(font)
        AhkTest.AssertEqual("TransposedFont", normal.AhkStdlibTypeName)
        AhkTest.AssertSame(font, normal.font)
        AhkTest.AssertSame(stdlib.None, normal.orientation)
        AhkTest.AssertEqual([0, 0, 25, 8], normal.getbbox("Hello"))
        AhkTest.AssertEqual(25.0, normal.getlength("Hello"))
        normalMask := normal.getmask("Hello")
        AhkTest.AssertEqual("L", normalMask.mode)
        AhkTest.AssertEqual([25, 8], normalMask.size)
        AhkTest.AssertEqual([1, 0, 25, 8], normalMask.getbbox())
        AhkTest.AssertEqual(200, normalMask.__Len)

        flipped := stdlib.pillow.ImageFont.TransposedFont(font, stdlib.pillow.Image.Transpose.FLIP_LEFT_RIGHT)
        AhkTest.AssertEqual(stdlib.pillow.Image.Transpose.FLIP_LEFT_RIGHT, flipped.orientation)
        AhkTest.AssertEqual([0, 0, 25, 8], flipped.getbbox("Hello"))
        AhkTest.AssertEqual(25.0, flipped.getlength("Hello"))
        flippedMask := flipped.getmask("Hello")
        AhkTest.AssertEqual([25, 8], flippedMask.size)
        AhkTest.AssertEqual([0, 0, 24, 8], flippedMask.getbbox())
        AhkTest.AssertEqual(200, flippedMask.__Len)

        rotated := stdlib.pillow.ImageFont.TransposedFont(font, stdlib.pillow.Image.Transpose.ROTATE_90)
        AhkTest.AssertEqual([0, 0, 8, 25], rotated.getbbox("Hello"))
        AhkTest.RaisesMatch(ValueError, "^text length is undefined for text rotated by 90 or 270 degrees$", (*) => rotated.getlength("Hello"))
        rotatedMask := rotated.getmask("Hello")
        AhkTest.AssertEqual([8, 25], rotatedMask.size)
        AhkTest.AssertEqual([0, 0, 8, 24], rotatedMask.getbbox())
        AhkTest.AssertEqual(200, rotatedMask.__Len)

        rotatedBack := stdlib.pillow.ImageFont.TransposedFont(font, stdlib.pillow.Image.Transpose.ROTATE_270)
        AhkTest.AssertEqual([0, 0, 8, 25], rotatedBack.getbbox("Hello"))
        AhkTest.RaisesMatch(ValueError, "^text length is undefined for text rotated by 90 or 270 degrees$", (*) => rotatedBack.getlength("Hello"))
        rotatedBackMask := rotatedBack.getmask("Hello")
        AhkTest.AssertEqual([8, 25], rotatedBackMask.size)
        AhkTest.AssertEqual([0, 1, 8, 25], rotatedBackMask.getbbox())

        fontPath := "C:\Windows\Fonts\arial.ttf"
        if FileExist(fontPath) {
            trueType := stdlib.pillow.ImageFont.truetype(fontPath, 12)
            trueTypeNormal := stdlib.pillow.ImageFont.TransposedFont(trueType)
            AhkTest.AssertEqual([0, 0, 11, 9], trueTypeNormal.getbbox("Hi"))
            AhkTest.AssertApprox(11.34375, trueTypeNormal.getlength("Hi"), { Abs: 0.000000000001, Rel: 0.0 })
            trueTypeMask := trueTypeNormal.getmask("Hi")
            AhkTest.AssertEqual([11, 9], trueTypeMask.size)
            AhkTest.AssertEqual([0, 0, 11, 9], trueTypeMask.getbbox())
            AhkTest.AssertEqual(99, trueTypeMask.__Len)

            trueTypeRotated := stdlib.pillow.ImageFont.TransposedFont(trueType, stdlib.pillow.Image.Transpose.ROTATE_90)
            AhkTest.AssertEqual([0, 0, 9, 11], trueTypeRotated.getbbox("Hi"))
            AhkTest.RaisesMatch(ValueError, "^text length is undefined for text rotated by 90 or 270 degrees$", (*) => trueTypeRotated.getlength("Hi"))
            trueTypeRotatedMask := trueTypeRotated.getmask("Hi")
            AhkTest.AssertEqual([9, 11], trueTypeRotatedMask.size)
            AhkTest.AssertEqual([0, 0, 9, 11], trueTypeRotatedMask.getbbox())
            AhkTest.AssertEqual(99, trueTypeRotatedMask.__Len)
        }

        AhkTest.RaisesMatch(TypeError, "^TransposedFont\.__init__\(\) missing 1 required positional argument: 'font'$", (*) => stdlib.pillow.ImageFont.TransposedFont())
        AhkTest.RaisesMatch(TypeError, "^TransposedFont\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => stdlib.pillow.ImageFont.TransposedFont(font, stdlib.None, stdlib.None))
        AhkTest.RaisesMatch(ValueError, "^No such transpose operation$", (*) => stdlib.pillow.ImageFont.TransposedFont(font, 99).getmask("Hello"))
    }

    static TestImageDraw2BasicWrappingMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "ImageDraw2"))
        AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageDraw2, "Pen"))
        AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageDraw2, "Brush"))
        AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageDraw2, "Draw"))

        pen := stdlib.pillow.ImageDraw2.Pen("red")
        widePen := stdlib.pillow.ImageDraw2.Pen("blue", 2)
        brush := stdlib.pillow.ImageDraw2.Brush("green")
        AhkTest.AssertEqual([255, 0, 0], pen.color)
        AhkTest.AssertEqual(1, pen.width)
        AhkTest.AssertEqual([0, 0, 255], widePen.color)
        AhkTest.AssertEqual(2, widePen.width)
        AhkTest.AssertEqual([0, 128, 0], brush.color)

        line := stdlib.pillow.Image.new("RGB", [5, 4], "black")
        rectangle := stdlib.pillow.Image.new("RGB", [5, 4], "black")
        ellipse := stdlib.pillow.Image.new("RGB", [5, 5], "black")
        polygon := stdlib.pillow.Image.new("RGB", [5, 5], "black")
        try {
            drawLine := stdlib.pillow.ImageDraw2.Draw(line)
            AhkTest.AssertSame(stdlib.None, drawLine.line([0, 0, 4, 3], pen))
            AhkTest.AssertSame(line, drawLine.flush())
            AhkTest.AssertEqual([
                [[255, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [255, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [255, 0, 0], [255, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [255, 0, 0]],
            ], StdlibPillowTest.PixelRows(line))

            drawRectangle := stdlib.pillow.ImageDraw2.Draw(rectangle)
            AhkTest.AssertSame(stdlib.None, drawRectangle.rectangle([1, 1, 3, 2], pen, brush))
            drawRectangle.flush()
            AhkTest.AssertEqual([
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
            ], StdlibPillowTest.PixelRows(rectangle))

            drawEllipse := stdlib.pillow.ImageDraw2.Draw(ellipse)
            AhkTest.AssertSame(stdlib.None, drawEllipse.ellipse([1, 1, 3, 3], widePen, brush))
            drawEllipse.flush()
            AhkTest.AssertEqual([
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 255], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 255], [0, 128, 0], [0, 0, 255], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 255], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
            ], StdlibPillowTest.PixelRows(ellipse))

            drawPolygon := stdlib.pillow.ImageDraw2.Draw(polygon)
            AhkTest.AssertSame(stdlib.None, drawPolygon.polygon([1, 1, 3, 1, 2, 3], pen, brush))
            drawPolygon.flush()
            AhkTest.AssertEqual([
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [255, 0, 0], [255, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [255, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
            ], StdlibPillowTest.PixelRows(polygon))

            AhkTest.RaisesMatch(TypeError, "^Pen\.__init__\(\) missing 1 required positional argument: 'color'$", (*) => stdlib.pillow.ImageDraw2.Pen())
            AhkTest.RaisesMatch(TypeError, "^Brush\.__init__\(\) missing 1 required positional argument: 'color'$", (*) => stdlib.pillow.ImageDraw2.Brush())
            AhkTest.RaisesMatch(AttributeError, "^'NoneType' object has no attribute 'load'$", (*) => stdlib.pillow.ImageDraw2.Draw(stdlib.None))
            AhkTest.RaisesMatch(TypeError, "^Draw\.line\(\) missing 1 required positional argument: 'pen'$", (*) => stdlib.pillow.ImageDraw2.Draw(stdlib.pillow.Image.new("RGB", [1, 1])).line([0, 0, 1, 1]))
            AhkTest.RaisesMatch(ValueError, "^wrong number of coordinates$", (*) => drawRectangle.rectangle([0, 0, 1], pen))
        } finally {
            StdlibPillowTest.CloseImage(polygon)
            StdlibPillowTest.CloseImage(ellipse)
            StdlibPillowTest.CloseImage(rectangle)
            StdlibPillowTest.CloseImage(line)
        }
    }

    static TestImageDraw2ArcChordAndPiesliceMatchLocalPillow113()
    {
        pen := stdlib.pillow.ImageDraw2.Pen("red")
        widePen := stdlib.pillow.ImageDraw2.Pen("blue", 2)
        brush := stdlib.pillow.ImageDraw2.Brush("green")
        translucentBrush := stdlib.pillow.ImageDraw2.Brush("#10203040")

        arc := unset
        wideArc := unset
        chord := unset
        pieslice := unset
        try {
            arc := stdlib.pillow.Image.new("RGB", [7, 7], "black")
            drawArc := stdlib.pillow.ImageDraw2.Draw(arc)
            AhkTest.AssertSame(stdlib.None, drawArc.arc([1, 1, 5, 5], pen, 0, 180))
            drawArc.flush()
            AhkTest.AssertEqual([
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [255, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [255, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [255, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [255, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
            ], StdlibPillowTest.PixelRows(arc))

            wideArc := stdlib.pillow.Image.new("RGB", [7, 7], "black")
            drawWideArc := stdlib.pillow.ImageDraw2.Draw(wideArc)
            AhkTest.AssertSame(stdlib.None, drawWideArc.arc([1, 1, 5, 5], widePen, 0, 180))
            drawWideArc.flush()
            AhkTest.AssertEqual([
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 255], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 255], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 255], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 255], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 255], [0, 0, 255], [0, 0, 255], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
            ], StdlibPillowTest.PixelRows(wideArc))

            chord := stdlib.pillow.Image.new("RGB", [7, 7], "black")
            drawChord := stdlib.pillow.ImageDraw2.Draw(chord)
            AhkTest.AssertSame(stdlib.None, drawChord.chord([1, 1, 5, 5], pen, 0, 180, brush))
            drawChord.flush()
            AhkTest.AssertEqual([
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
            ], StdlibPillowTest.PixelRows(chord))

            pieslice := stdlib.pillow.Image.new("RGBA", [7, 7], [0, 0, 0, 0])
            drawPieslice := stdlib.pillow.ImageDraw2.Draw(pieslice)
            AhkTest.AssertSame(stdlib.None, drawPieslice.pieslice([1, 1, 5, 5], pen, 90, 270, translucentBrush))
            drawPieslice.flush()
            AhkTest.AssertEqual([
                [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [0, 0, 0, 0], [255, 0, 0, 255], [255, 0, 0, 255], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [255, 0, 0, 255], [255, 0, 0, 255], [255, 0, 0, 255], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [255, 0, 0, 255], [255, 0, 0, 255], [255, 0, 0, 255], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [255, 0, 0, 255], [255, 0, 0, 255], [255, 0, 0, 255], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [0, 0, 0, 0], [255, 0, 0, 255], [255, 0, 0, 255], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
            ], StdlibPillowTest.PixelRows(pieslice))

            AhkTest.RaisesMatch(TypeError, "^Draw\.arc\(\) missing 1 required positional argument: 'end'$", (*) => drawArc.arc([0, 0, 1, 1], 0, 90))
            AhkTest.RaisesMatch(ValueError, "^wrong number of coordinates$", (*) => drawArc.arc([0, 0, 1], pen, 0, 90))
            AhkTest.RaisesMatch(TypeError, "^Draw\.chord\(\) missing 1 required positional argument: 'end'$", (*) => drawChord.chord([0, 0, 1, 1], 0, 90))
            AhkTest.RaisesMatch(ValueError, "^wrong number of coordinates$", (*) => drawChord.chord([0, 0, 1], pen, 0, 90))
            AhkTest.RaisesMatch(TypeError, "^Draw\.pieslice\(\) missing 1 required positional argument: 'end'$", (*) => drawPieslice.pieslice([0, 0, 1, 1], 0, 90))
            AhkTest.RaisesMatch(ValueError, "^wrong number of coordinates$", (*) => drawPieslice.pieslice([0, 0, 1], pen, 0, 90))
        } finally {
            if IsSet(pieslice)
                StdlibPillowTest.CloseImage(pieslice)
            if IsSet(chord)
                StdlibPillowTest.CloseImage(chord)
            if IsSet(wideArc)
                StdlibPillowTest.CloseImage(wideArc)
            if IsSet(arc)
                StdlibPillowTest.CloseImage(arc)
        }
    }

    static TestImageDraw2RenderAndSettransformMatchLocalPillow113()
    {
        pen := stdlib.pillow.ImageDraw2.Pen("red")
        widePen := stdlib.pillow.ImageDraw2.Pen("blue", 2)
        brush := stdlib.pillow.ImageDraw2.Brush("green")

        line := unset
        rectangle := unset
        polygon := unset
        renderLine := unset
        renderRectangle := unset
        try {
            line := stdlib.pillow.Image.new("RGB", [5, 4], "black")
            drawLine := stdlib.pillow.ImageDraw2.Draw(line)
            AhkTest.AssertSame(stdlib.None, drawLine.settransform([1, 1]))
            AhkTest.AssertEqual([1, 0, 1, 0, 1, 1], drawLine.transform)
            AhkTest.AssertSame(stdlib.None, drawLine.line([0, 0, 2, 0], pen))
            drawLine.flush()
            AhkTest.AssertEqual([
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
            ], StdlibPillowTest.PixelRows(line))

            rectangle := stdlib.pillow.Image.new("RGB", [5, 4], "black")
            drawRectangle := stdlib.pillow.ImageDraw2.Draw(rectangle)
            AhkTest.AssertSame(stdlib.None, drawRectangle.settransform([1, 1]))
            AhkTest.AssertSame(stdlib.None, drawRectangle.rectangle([0, 0, 2, 1], pen, brush))
            drawRectangle.flush()
            AhkTest.AssertEqual([
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
            ], StdlibPillowTest.PixelRows(rectangle))

            polygon := stdlib.pillow.Image.new("RGB", [5, 5], "black")
            drawPolygon := stdlib.pillow.ImageDraw2.Draw(polygon)
            AhkTest.AssertSame(stdlib.None, drawPolygon.settransform([1, 1]))
            AhkTest.AssertSame(stdlib.None, drawPolygon.polygon([0, 0, 2, 0, 1, 2], pen, brush))
            drawPolygon.flush()
            AhkTest.AssertEqual([
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [255, 0, 0], [255, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [255, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
            ], StdlibPillowTest.PixelRows(polygon))

            renderLine := stdlib.pillow.Image.new("RGB", [5, 4], "black")
            drawRenderLine := stdlib.pillow.ImageDraw2.Draw(renderLine)
            AhkTest.AssertSame(stdlib.None, drawRenderLine.render("line", [0, 0, 2, 0], widePen))
            drawRenderLine.flush()
            AhkTest.AssertEqual([
                [[0, 0, 255], [0, 0, 255], [0, 0, 255], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 255], [0, 0, 255], [0, 0, 255], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
            ], StdlibPillowTest.PixelRows(renderLine))

            renderRectangle := stdlib.pillow.Image.new("RGB", [5, 4], "black")
            drawRenderRectangle := stdlib.pillow.ImageDraw2.Draw(renderRectangle)
            AhkTest.AssertSame(stdlib.None, drawRenderRectangle.settransform([1, 1]))
            AhkTest.AssertSame(stdlib.None, drawRenderRectangle.render("rectangle", [0, 0, 2, 1], pen, brush))
            drawRenderRectangle.flush()
            AhkTest.AssertEqual(StdlibPillowTest.PixelRows(rectangle), StdlibPillowTest.PixelRows(renderRectangle))

            AhkTest.RaisesMatch(TypeError, "^Draw\.settransform\(\) missing 1 required positional argument: 'offset'$", (*) => stdlib.pillow.ImageDraw2.Draw(stdlib.pillow.Image.new("RGB", [1, 1])).settransform())
            AhkTest.RaisesMatch(ValueError, "^not enough values to unpack \(expected 2, got 1\)$", (*) => drawLine.settransform([1]))
            AhkTest.RaisesMatch(TypeError, "^cannot unpack non-iterable NoneType object$", (*) => drawLine.settransform(stdlib.None))
            AhkTest.RaisesMatch(TypeError, "^Draw\.render\(\) missing 2 required positional arguments: 'xy' and 'pen'$", (*) => drawLine.render("line"))
            AhkTest.RaisesMatch(AttributeError, "^'ImageDraw' object has no attribute 'nope'$", (*) => drawLine.render("nope", [0, 0, 1, 1], pen))
            AhkTest.RaisesMatch(TypeError, "^ImageDraw\.arc\(\) missing 2 required positional arguments: 'start' and 'end'$", (*) => drawLine.render("arc", [0, 0, 1, 1], pen))
        } finally {
            if IsSet(renderRectangle)
                StdlibPillowTest.CloseImage(renderRectangle)
            if IsSet(renderLine)
                StdlibPillowTest.CloseImage(renderLine)
            if IsSet(polygon)
                StdlibPillowTest.CloseImage(polygon)
            if IsSet(rectangle)
                StdlibPillowTest.CloseImage(rectangle)
            if IsSet(line)
                StdlibPillowTest.CloseImage(line)
        }
    }

    static TestImageDraw2FontAndTextMethodsMatchLocalPillow113()
    {
        fontPath := "C:\Windows\Fonts\arial.ttf"
        if !FileExist(fontPath)
            AhkTest.SkipNow("C:\Windows\Fonts\arial.ttf is required for the local Pillow 11.3.0 ImageDraw2 text probe")

        AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageDraw2, "Font"))
        font := stdlib.pillow.ImageDraw2.Font("red", fontPath, 12)
        AhkTest.AssertEqual([255, 0, 0], font.color)
        AhkTest.AssertEqual("FreeTypeFont", font.font.AhkStdlibTypeName)
        AhkTest.AssertEqual(12, font.font.size)
        AhkTest.AssertEqual(fontPath, font.font.path)
        AhkTest.AssertEqual([0, 2, 11, 11], font.font.getbbox("Hi"))
        AhkTest.AssertApprox(11.34375, font.font.getlength("Hi"), { Abs: 0.000000000001, Rel: 0.0 })

        image := unset
        transformed := unset
        try {
            image := stdlib.pillow.Image.new("RGB", [36, 18], "black")
            draw := stdlib.pillow.ImageDraw2.Draw(image)
            AhkTest.AssertEqual([1, 3, 12, 12], draw.textbbox([1, 1], "Hi", font))
            AhkTest.AssertApprox(11.34375, draw.textlength("Hi", font), { Abs: 0.000000000001, Rel: 0.0 })
            AhkTest.AssertSame(stdlib.None, draw.text([1, 1], "Hi", font))
            AhkTest.AssertSame(image, draw.flush())
            AhkTest.AssertTrue(StdlibPillowTest.NonBlackPixelCount(image) > 0)

            transformed := stdlib.pillow.Image.new("RGB", [40, 20], "black")
            transformedDraw := stdlib.pillow.ImageDraw2.Draw(transformed)
            AhkTest.AssertSame(stdlib.None, transformedDraw.settransform([3, 4]))
            AhkTest.AssertEqual([1, 0, 3, 0, 1, 4], transformedDraw.transform)
            AhkTest.RaisesMatch(TypeError, "^unsupported operand type\(s\) for \+: 'int' and 'tuple'$", (*) => transformedDraw.textbbox([1, 1], "Hi", font))
            AhkTest.RaisesMatch(TypeError, "^int\(\) argument must be a string, a bytes-like object or a real number, not 'tuple'$", (*) => transformedDraw.text([1, 1], "Hi", font))

            AhkTest.RaisesMatch(TypeError, "^Font\.__init__\(\) missing 2 required positional arguments: 'color' and 'file'$", (*) => stdlib.pillow.ImageDraw2.Font())
            AhkTest.RaisesMatch(TypeError, "^Font\.__init__\(\) missing 1 required positional argument: 'file'$", (*) => stdlib.pillow.ImageDraw2.Font("red"))
            AhkTest.RaisesMatch(OSError, "^cannot open resource$", (*) => stdlib.pillow.ImageDraw2.Font("red", "C:\no-such-font.ttf"))
            AhkTest.RaisesMatch(ValueError, "^unknown color specifier: 'notacolor'$", (*) => stdlib.pillow.ImageDraw2.Font("notacolor", fontPath))
            AhkTest.RaisesMatch(TypeError, "^Draw\.text\(\) missing 1 required positional argument: 'font'$", (*) => draw.text([0, 0], "x"))
            AhkTest.RaisesMatch(AttributeError, "^'NoneType' object has no attribute 'font'$", (*) => draw.text([0, 0], "x", stdlib.None))
            AhkTest.RaisesMatch(AttributeError, "^'NoneType' object has no attribute 'font'$", (*) => draw.textbbox([0, 0], "x", stdlib.None))
            AhkTest.RaisesMatch(AttributeError, "^'NoneType' object has no attribute 'font'$", (*) => draw.textlength("x", stdlib.None))
        } finally {
            if IsSet(transformed)
                StdlibPillowTest.CloseImage(transformed)
            if IsSet(image)
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestImagePaletteModuleMatchesLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "ImagePalette"))
        AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImagePalette, "ImagePalette"))

        basic := stdlib.pillow.ImagePalette.ImagePalette("RGB", [1, 2, 3, 4, 5, 6])
        AhkTest.AssertEqual("RGB", basic.mode)
        AhkTest.AssertSame(stdlib.None, basic.rawmode)
        AhkTest.AssertSame(stdlib.None, basic.dirty)
        AhkTest.AssertEqual([1, 2, 3, 4, 5, 6], basic.palette)
        AhkTest.AssertEqual(["RGB", [1, 2, 3, 4, 5, 6]], basic.getdata())
        AhkTest.AssertEqual([1, 2, 3, 4, 5, 6], basic.tobytes())
        AhkTest.AssertEqual([1, 2, 3, 4, 5, 6], basic.tostring())
        AhkTest.AssertEqual(0, basic.colors["1,2,3"])
        AhkTest.AssertEqual(1, basic.colors["4,5,6"])

        copied := basic.copy()
        copied.palette[1] := 99
        AhkTest.AssertEqual([1, 2, 3, 4, 5, 6], basic.palette)
        AhkTest.AssertEqual([99, 2, 3, 4, 5, 6], copied.palette)
        AhkTest.AssertEqual(0, copied.colors["99,2,3"])

        empty := stdlib.pillow.ImagePalette.ImagePalette()
        AhkTest.AssertEqual("RGB", empty.mode)
        AhkTest.AssertEqual([], empty.palette)
        AhkTest.AssertEqual(["RGB", []], empty.getdata())
        AhkTest.AssertEqual(0, empty.colors.Count)

        allocatedRgb := stdlib.pillow.ImagePalette.ImagePalette("RGB")
        AhkTest.AssertEqual(0, allocatedRgb.getcolor([1, 2, 3]))
        AhkTest.AssertEqual(0, allocatedRgb.getcolor([1, 2, 3]))
        AhkTest.AssertEqual(1, allocatedRgb.getcolor([4, 5, 6, 255]))
        AhkTest.AssertEqual([1, 2, 3, 4, 5, 6], allocatedRgb.palette)
        AhkTest.AssertEqual(1, allocatedRgb.dirty)

        allocatedRgba := stdlib.pillow.ImagePalette.ImagePalette("RGBA")
        AhkTest.AssertEqual(0, allocatedRgba.getcolor([1, 2, 3]))
        AhkTest.AssertEqual(1, allocatedRgba.getcolor([1, 2, 3, 4]))
        AhkTest.AssertEqual([1, 2, 3, 1, 2, 3, 4], allocatedRgba.palette)
        AhkTest.AssertEqual(0, allocatedRgba.colors["1,2,3,255"])
        AhkTest.AssertEqual(1, allocatedRgba.colors["1,2,3,4"])

        raw := stdlib.pillow.ImagePalette.raw("RGB", [1, 2, 3])
        AhkTest.AssertEqual("RGB", raw.mode)
        AhkTest.AssertEqual("RGB", raw.rawmode)
        AhkTest.AssertEqual([1, 2, 3], raw.palette)
        AhkTest.AssertEqual(["RGB", [1, 2, 3]], raw.getdata())
        AhkTest.RaisesMatch(ValueError, "^palette contains raw palette data$", (*) => raw.tobytes())
        AhkTest.RaisesMatch(ValueError, "^palette contains raw palette data$", (*) => raw.tostring())
        AhkTest.RaisesMatch(ValueError, "^palette contains raw palette data$", (*) => raw.getcolor([1, 2, 3]))

        negativeRgb := stdlib.pillow.ImagePalette.negative("RGB")
        AhkTest.AssertEqual("RGB", negativeRgb.mode)
        AhkTest.AssertEqual(768, negativeRgb.palette.Length)
        AhkTest.AssertEqual([255, 255, 255, 254, 254, 254, 253, 253, 253], StdlibPillowTest.ArraySlice(negativeRgb.palette, 1, 9))
        AhkTest.AssertEqual([2, 2, 2, 1, 1, 1, 0, 0, 0], StdlibPillowTest.ArraySlice(negativeRgb.palette, 760, 768))

        wedgeL := stdlib.pillow.ImagePalette.wedge("L")
        AhkTest.AssertEqual("L", wedgeL.mode)
        AhkTest.AssertEqual(256, wedgeL.palette.Length)
        AhkTest.AssertEqual([0, 1, 2, 3, 4, 5, 6, 7], StdlibPillowTest.Take(wedgeL.palette, 8))
        AhkTest.AssertEqual([252, 253, 254, 255], StdlibPillowTest.ArraySlice(wedgeL.palette, 253, 256))

        sepia := stdlib.pillow.ImagePalette.sepia()
        AhkTest.AssertEqual("RGB", sepia.mode)
        AhkTest.AssertEqual(768, sepia.palette.Length)
        AhkTest.AssertEqual([0, 0, 0, 1, 0, 0, 2, 1, 1, 3, 2, 2], StdlibPillowTest.Take(sepia.palette, 12))
        AhkTest.AssertEqual([252, 237, 189, 253, 238, 190, 254, 239, 191, 255, 240, 192], StdlibPillowTest.ArraySlice(sepia.palette, 757, 768))

        linearLut := stdlib.pillow.ImagePalette.make_linear_lut(0, 20)
        AhkTest.AssertEqual([0, 0, 0, 0, 0, 0, 0, 0], StdlibPillowTest.Take(linearLut, 8))
        AhkTest.AssertEqual([19, 19, 20], StdlibPillowTest.ArraySlice(linearLut, 254, 256))
        gammaLut := stdlib.pillow.ImagePalette.make_gamma_lut(2.0)
        AhkTest.AssertEqual([0, 0, 0, 0, 0, 0, 0, 0], StdlibPillowTest.Take(gammaLut, 8))
        AhkTest.AssertEqual([251, 253, 255], StdlibPillowTest.ArraySlice(gammaLut, 254, 256))

        AhkTest.RaisesMatch(ValueError, "^unknown color specifier: 'red'$", (*) => allocatedRgb.getcolor("red"))
        AhkTest.RaisesMatch(ValueError, "^cannot add non-opaque RGBA color to RGB palette$", (*) => stdlib.pillow.ImagePalette.ImagePalette("RGB").getcolor([1, 2, 3, 4]))
        AhkTest.RaisesMatch(TypeError, "^ImagePalette\.getcolor\(\) missing 1 required positional argument: 'color'$", (*) => stdlib.pillow.ImagePalette.ImagePalette().getcolor())
        AhkTest.RaisesMatch(TypeError, "^raw\(\) missing 1 required positional argument: 'data'$", (*) => stdlib.pillow.ImagePalette.raw("RGB"))
        AhkTest.RaisesMatch(TypeError, "^negative\(\) takes from 0 to 1 positional arguments but 2 were given$", (*) => stdlib.pillow.ImagePalette.negative("RGB", "x"))
        AhkTest.RaisesMatch(NotImplementedError, "^unavailable when black is non-zero$", (*) => stdlib.pillow.ImagePalette.make_linear_lut(10, 20))
        AhkTest.RaisesMatch(TypeError, "^make_linear_lut\(\) missing 1 required positional argument: 'white'$", (*) => stdlib.pillow.ImagePalette.make_linear_lut(1))
        AhkTest.RaisesMatch(TypeError, "^make_gamma_lut\(\) missing 1 required positional argument: 'exp'$", (*) => stdlib.pillow.ImagePalette.make_gamma_lut())
    }

    static TestImageInspectionMethodsMatchLocalPillow113()
    {
        rgb := unset
        gray := unset
        rgba := unset
        bits := unset
        empty := unset
        try {
            rgb := StdlibPillowTest.InspectionRgbImage()
            AhkTest.AssertEqual(["R", "G", "B"], rgb.getbands())
            AhkTest.AssertEqual([1, 0, 4, 3], rgb.getbbox())
            AhkTest.AssertEqual([1, 0, 4, 3], rgb.getbbox({ alpha_only: false }))
            AhkTest.AssertEqual([[0, 255], [0, 255], [0, 255]], rgb.getextrema())
            AhkTest.AssertSame(stdlib.None, rgb.getcolors(3))
            AhkTest.AssertEqual([
                [1, [255, 255, 255]],
                [1, [200, 210, 220]],
                [1, [100, 110, 120]],
                [2, [10, 20, 30]],
                [1, [5, 6, 7]],
                [6, [0, 0, 0]],
            ], rgb.getcolors())
            rgbHistogram := rgb.histogram()
            AhkTest.AssertEqual(768, rgbHistogram.Length)
            AhkTest.AssertEqual([6, 0, 0, 0, 0, 1, 0, 0, 0, 0, 2, 0], StdlibPillowTest.Take(rgbHistogram, 12))
            AhkTest.AssertEqual([[0, 1, 1, 1], [1, 1, 1]], rgb.getprojection())

            gray := stdlib.pillow.Image.new("L", [4, 2], 0)
            for item in [[[0, 0], 0], [[1, 0], 10], [[2, 0], 10], [[3, 0], 255], [[2, 1], 100]]
                gray.putpixel(item[1], item[2])
            AhkTest.AssertEqual(["L"], gray.getbands())
            AhkTest.AssertEqual([1, 0, 4, 2], gray.getbbox())
            AhkTest.AssertEqual([0, 255], gray.getextrema())
            AhkTest.AssertEqual([[4, 0], [2, 10], [1, 100], [1, 255]], gray.getcolors())
            AhkTest.AssertSame(stdlib.None, gray.getcolors(3))
            grayHistogram := gray.histogram()
            AhkTest.AssertEqual(256, grayHistogram.Length)
            AhkTest.AssertEqual([4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0], StdlibPillowTest.Take(grayHistogram, 12))
            AhkTest.AssertEqual([[0, 1, 1, 1], [1, 1]], gray.getprojection())

            rgba := stdlib.pillow.Image.new("RGBA", [3, 2], [10, 20, 30, 0])
            rgba.putpixel([1, 0], [0, 0, 0, 0])
            rgba.putpixel([2, 0], [0, 0, 0, 128])
            rgba.putpixel([1, 1], [50, 60, 70, 255])
            AhkTest.AssertEqual(["R", "G", "B", "A"], rgba.getbands())
            AhkTest.AssertEqual([1, 0, 3, 2], rgba.getbbox())
            AhkTest.AssertEqual([0, 0, 3, 2], rgba.getbbox({ alpha_only: false }))
            AhkTest.AssertEqual([[0, 50], [0, 60], [0, 70], [0, 255]], rgba.getextrema())
            AhkTest.AssertEqual([
                [1, [50, 60, 70, 255]],
                [3, [10, 20, 30, 0]],
                [1, [0, 0, 0, 128]],
                [1, [0, 0, 0, 0]],
            ], rgba.getcolors())
            AhkTest.AssertEqual([[1, 1, 1], [1, 1]], rgba.getprojection())

            bits := stdlib.pillow.Image.new("1", [3, 1], 0)
            bits.putpixel([1, 0], 1)
            bits.putpixel([2, 0], 255)
            AhkTest.AssertEqual(["1"], bits.getbands())
            AhkTest.AssertEqual([1, 0, 3, 1], bits.getbbox())
            AhkTest.AssertEqual([0, 255], bits.getextrema())
            AhkTest.AssertEqual([[1, 0], [1, 1], [1, 255]], bits.getcolors(3))
            bitsHistogram := bits.histogram()
            AhkTest.AssertEqual(256, bitsHistogram.Length)
            AhkTest.AssertEqual([1, 1, 0, 0, 0], StdlibPillowTest.Take(bitsHistogram, 5))
            AhkTest.AssertEqual([[0, 1, 1], [1]], bits.getprojection())

            empty := stdlib.pillow.Image.new("L", [2, 2], 0)
            AhkTest.AssertSame(stdlib.None, empty.getbbox())
            AhkTest.RaisesMatch(TypeError, "^Image\.getbbox\(\) takes 1 positional argument but 2 were given$", (*) => rgb.getbbox(true))
            AhkTest.RaisesMatch(TypeError, "^'str' object cannot be interpreted as an integer$", (*) => rgb.getcolors("x"))
            AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute 'load'$", (*) => rgb.histogram("x"))
        } finally {
            if IsSet(empty)
                StdlibPillowTest.CloseImage(empty)
            if IsSet(bits)
                StdlibPillowTest.CloseImage(bits)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
        }
    }

    static TestImageStatMatchesLocalPillow113()
    {
        rgb := unset
        gray := unset
        mask := unset
        badMaskSize := unset
        badMaskMode := unset
        try {
            rgb := stdlib.pillow.Image.new("RGB", [2, 2], [0, 0, 0])
            rgb.putdata([[0, 10, 20], [30, 40, 50], [60, 70, 80], [90, 100, 110]])
            rgbStat := stdlib.pillow.ImageStat.Stat(rgb)
            AhkTest.AssertEqual([4, 4, 4], rgbStat.count)
            AhkTest.AssertEqual([180.0, 220.0, 260.0], rgbStat.sum)
            AhkTest.AssertEqual([12600.0, 16600.0, 21400.0], rgbStat.sum2)
            AhkTest.AssertEqual([45.0, 55.0, 65.0], rgbStat.mean)
            AhkTest.AssertEqual([60, 70, 80], rgbStat.median)
            AhkTest.AssertEqual([56.124861, 64.420494, 73.143694], StdlibPillowTest.RoundValues(rgbStat.rms, 6))
            AhkTest.AssertEqual([1125.0, 1125.0, 1125.0], rgbStat.var)
            AhkTest.AssertEqual([33.54102, 33.54102, 33.54102], StdlibPillowTest.RoundValues(rgbStat.stddev, 6))
            AhkTest.AssertEqual([[0, 90], [10, 100], [20, 110]], rgbStat.extrema)

            gray := stdlib.pillow.Image.new("L", [3, 1], 0)
            gray.putdata([0, 10, 255])
            grayStat := stdlib.pillow.ImageStat.Stat(gray)
            AhkTest.AssertEqual([3], grayStat.count)
            AhkTest.AssertEqual([265.0], grayStat.sum)
            AhkTest.AssertEqual([65125.0], grayStat.sum2)
            AhkTest.AssertEqual([88.333333], StdlibPillowTest.RoundValues(grayStat.mean, 6))
            AhkTest.AssertEqual([10], grayStat.median)
            AhkTest.AssertEqual([147.337481], StdlibPillowTest.RoundValues(grayStat.rms, 6))
            AhkTest.AssertEqual([13905.555556], StdlibPillowTest.RoundValues(grayStat.var, 6))
            AhkTest.AssertEqual([117.92182], StdlibPillowTest.RoundValues(grayStat.stddev, 6))
            AhkTest.AssertEqual([[0, 255]], grayStat.extrema)

            mask := stdlib.pillow.Image.new("L", [2, 2], 0)
            mask.putdata([0, 255, 255, 0])
            maskedStat := stdlib.pillow.ImageStat.Stat(rgb, mask)
            AhkTest.AssertEqual([2, 2, 2], maskedStat.count)
            AhkTest.AssertEqual([90.0, 110.0, 130.0], maskedStat.sum)
            AhkTest.AssertEqual([4500.0, 6500.0, 8900.0], maskedStat.sum2)
            AhkTest.AssertEqual([45.0, 55.0, 65.0], maskedStat.mean)
            AhkTest.AssertEqual([60, 70, 80], maskedStat.median)
            AhkTest.AssertEqual([47.434165, 57.008771, 66.70832], StdlibPillowTest.RoundValues(maskedStat.rms, 6))
            AhkTest.AssertEqual([225.0, 225.0, 225.0], maskedStat.var)
            AhkTest.AssertEqual([15.0, 15.0, 15.0], maskedStat.stddev)
            AhkTest.AssertEqual([[30, 60], [40, 70], [50, 80]], maskedStat.extrema)

            hist := StdlibPillowTest.Repeat(0, 256)
            hist[1] := 1
            hist[11] := 2
            hist[256] := 1
            histStat := stdlib.pillow.ImageStat.Stat(hist)
            AhkTest.AssertEqual([4], histStat.count)
            AhkTest.AssertEqual([275.0], histStat.sum)
            AhkTest.AssertEqual([65225.0], histStat.sum2)
            AhkTest.AssertEqual([68.75], histStat.mean)
            AhkTest.AssertEqual([10], histStat.median)
            AhkTest.AssertEqual([127.695928], StdlibPillowTest.RoundValues(histStat.rms, 6))
            AhkTest.AssertEqual([11579.6875], histStat.var)
            AhkTest.AssertEqual([107.608956], StdlibPillowTest.RoundValues(histStat.stddev, 6))
            AhkTest.AssertEqual([[0, 255]], histStat.extrema)

            badMaskSize := stdlib.pillow.Image.new("L", [1, 1], 0)
            badMaskMode := stdlib.pillow.Image.new("RGB", [2, 2], [0, 0, 0])
            AhkTest.RaisesMatch(TypeError, "^first argument must be image or list$", (*) => stdlib.pillow.ImageStat.Stat("x"))
            AhkTest.RaisesMatch(TypeError, "^first argument must be image or list$", (*) => stdlib.pillow.ImageStat.Stat(1))
            AhkTest.RaisesMatch(ValueError, "^images do not match$", (*) => stdlib.pillow.ImageStat.Stat(rgb, badMaskSize))
            AhkTest.RaisesMatch(ValueError, "^bad transparency mask$", (*) => stdlib.pillow.ImageStat.Stat(rgb, badMaskMode))
            AhkTest.RaisesMatch(TypeError, "^Stat\.__init__\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => stdlib.pillow.ImageStat.Stat(rgb, mask, stdlib.None))
        } finally {
            if IsSet(badMaskMode)
                StdlibPillowTest.CloseImage(badMaskMode)
            if IsSet(badMaskSize)
                StdlibPillowTest.CloseImage(badMaskSize)
            if IsSet(mask)
                StdlibPillowTest.CloseImage(mask)
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
        }
    }

    static TestImageSequenceMatchesLocalPillow113()
    {
        image := unset
        listFrame := unset
        indexed := unset
        allFrames := unset
        allFramesList := unset
        allFramesFunc := unset
        try {
            image := stdlib.pillow.Image.new("RGB", [2, 1], [10, 20, 30])
            image.putpixel([1, 0], [40, 50, 60])

            iterator := stdlib.pillow.ImageSequence.Iterator(image)
            first := iterator.next()
            AhkTest.AssertSame(image, first)
            AhkTest.AssertEqual("RGB", first.mode)
            AhkTest.AssertEqual([2, 1], first.size)
            AhkTest.AssertEqual([10, 20, 30], first.getpixel([0, 0]))
            AhkTest.RaisesMatch(StopIteration, "^end of sequence$", (*) => iterator.next())

            indexed := stdlib.pillow.ImageSequence.Iterator(image)[0]
            AhkTest.AssertSame(image, indexed)
            AhkTest.RaisesMatch(IndexError, "^end of sequence$", (*) => stdlib.pillow.ImageSequence.Iterator(image)[1])
            AhkTest.RaisesMatch(IndexError, "^end of sequence$", (*) => stdlib.pillow.ImageSequence.Iterator(image)[-1])
            AhkTest.RaisesMatch(IndexError, "^end of sequence$", (*) => stdlib.pillow.ImageSequence.Iterator(image)["0"])

            for frame in stdlib.pillow.ImageSequence.Iterator(image) {
                AhkTest.AssertSame(image, frame)
                AhkTest.AssertEqual([10, 20, 30], frame.getpixel([0, 0]))
            }

            allFrames := stdlib.pillow.ImageSequence.all_frames(image)
            AhkTest.AssertEqual(1, allFrames.Length)
            AhkTest.AssertFalse(allFrames[1] == image)
            AhkTest.AssertEqual("RGB", allFrames[1].mode)
            AhkTest.AssertEqual([2, 1], allFrames[1].size)
            AhkTest.AssertEqual([10, 20, 30], allFrames[1].getpixel([0, 0]))
            allFrames[1].putpixel([0, 0], [99, 88, 77])
            AhkTest.AssertEqual([10, 20, 30], image.getpixel([0, 0]))

            listFrame := stdlib.pillow.Image.new("L", [1, 1], 7)
            allFramesList := stdlib.pillow.ImageSequence.all_frames([image, listFrame])
            AhkTest.AssertEqual(2, allFramesList.Length)
            AhkTest.AssertFalse(allFramesList[1] == image)
            AhkTest.AssertFalse(allFramesList[2] == listFrame)
            AhkTest.AssertEqual("RGB", allFramesList[1].mode)
            AhkTest.AssertEqual([10, 20, 30], allFramesList[1].getpixel([0, 0]))
            AhkTest.AssertEqual("L", allFramesList[2].mode)
            AhkTest.AssertEqual(7, allFramesList[2].getpixel([0, 0]))

            allFramesFunc := stdlib.pillow.ImageSequence.all_frames(image, (frame) => frame.convert("L"))
            AhkTest.AssertEqual(1, allFramesFunc.Length)
            AhkTest.AssertEqual("L", allFramesFunc[1].mode)
            AhkTest.AssertEqual(18, allFramesFunc[1].getpixel([0, 0]))

            AhkTest.RaisesMatch(AttributeError, "^im must have seek method$", (*) => stdlib.pillow.ImageSequence.Iterator("x"))
            AhkTest.RaisesMatch(TypeError, "^Iterator\.__init__\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.pillow.ImageSequence.Iterator(image, stdlib.None))
            AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute 'tell'$", (*) => stdlib.pillow.ImageSequence.all_frames("x"))
            AhkTest.RaisesMatch(TypeError, "^all_frames\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => stdlib.pillow.ImageSequence.all_frames(image, (frame) => frame, stdlib.None))
        } finally {
            if IsSet(allFramesFunc)
                StdlibPillowTest.CloseImages(allFramesFunc)
            if IsSet(allFramesList)
                StdlibPillowTest.CloseImages(allFramesList)
            if IsSet(allFrames)
                StdlibPillowTest.CloseImages(allFrames)
            if IsSet(listFrame)
                StdlibPillowTest.CloseImage(listFrame)
            if IsSet(image)
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestImageDataAccessMethodsMatchLocalPillow113()
    {
        rgb := unset
        gray := unset
        rgba := unset
        bits := unset
        frombytesRgb := unset
        frombytesGray := unset
        putdataScaled := unset
        shortData := unset
        badPixel := unset
        try {
            rgb := stdlib.pillow.Image.new("RGB", [3, 2], [0, 0, 0])
            rgb.putdata([
                [10, 20, 30],
                [40, 50, 60],
                [70, 80, 90],
                [100, 110, 120],
                [130, 140, 150],
                [160, 170, 180],
            ])
            AhkTest.AssertEqual([
                [10, 20, 30],
                [40, 50, 60],
                [70, 80, 90],
                [100, 110, 120],
                [130, 140, 150],
                [160, 170, 180],
            ], rgb.getdata())
            AhkTest.AssertEqual([10, 40, 70, 100, 130, 160], rgb.getdata(0))
            AhkTest.AssertEqual([20, 50, 80, 110, 140, 170], rgb.getdata(1))
            AhkTest.AssertEqual([10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180], rgb.tobytes())

            gray := stdlib.pillow.Image.new("L", [3, 2], 0)
            AhkTest.AssertSame(stdlib.None, gray.putdata([0, 10, 20, 30, 40, 255]))
            AhkTest.AssertEqual([0, 10, 20, 30, 40, 255], gray.getdata())
            AhkTest.AssertEqual([0, 10, 20, 30, 40, 255], gray.tobytes())

            rgba := stdlib.pillow.Image.new("RGBA", [2, 2], [0, 0, 0, 0])
            rgba.putdata([[1, 2, 3, 4], [50, 60, 70, 80], [100, 110, 120, 130], [250, 5, 128, 255]])
            AhkTest.AssertEqual([[1, 2, 3, 4], [50, 60, 70, 80], [100, 110, 120, 130], [250, 5, 128, 255]], rgba.getdata())
            AhkTest.AssertEqual([4, 80, 130, 255], rgba.getdata(3))
            AhkTest.AssertEqual([1, 2, 3, 4, 50, 60, 70, 80, 100, 110, 120, 130, 250, 5, 128, 255], rgba.tobytes())

            bits := stdlib.pillow.Image.new("1", [3, 1], 0)
            bits.putdata([0, 1, 255])
            AhkTest.AssertEqual([0, 1, 255], bits.getdata())
            AhkTest.AssertEqual([96], bits.tobytes())

            frombytesRgb := stdlib.pillow.Image.new("RGB", [2, 1])
            AhkTest.AssertSame(stdlib.None, frombytesRgb.frombytes([1, 2, 3, 4, 5, 6]))
            AhkTest.AssertEqual([[1, 2, 3], [4, 5, 6]], frombytesRgb.getdata())
            frombytesGray := stdlib.pillow.Image.new("L", [3, 1])
            AhkTest.AssertSame(stdlib.None, frombytesGray.frombytes([7, 8, 9]))
            AhkTest.AssertEqual([7, 8, 9], frombytesGray.getdata())

            putdataScaled := stdlib.pillow.Image.new("L", [3, 1], 0)
            AhkTest.AssertSame(stdlib.None, putdataScaled.putdata([1, 2, 3], 10, 5))
            AhkTest.AssertEqual([15, 25, 35], putdataScaled.getdata())

            shortData := stdlib.pillow.Image.new("L", [3, 1], 0)
            AhkTest.AssertSame(stdlib.None, shortData.putdata([1]))
            AhkTest.AssertEqual([1, 0, 0], shortData.getdata())

            badPixel := stdlib.pillow.Image.new("RGB", [1, 1], [0, 0, 0])
            AhkTest.AssertSame(stdlib.None, badPixel.putdata([1]))
            AhkTest.AssertEqual([[1, 0, 0]], badPixel.getdata())

            AhkTest.RaisesMatch(ValueError, "^band index out of range$", (*) => rgb.getdata(9))
            AhkTest.RaisesMatch(OSError, "^encoder bad not available$", (*) => rgb.tobytes("bad"))
            AhkTest.RaisesMatch(ValueError, "^not enough image data$", (*) => stdlib.pillow.Image.new("RGB", [2, 1]).frombytes([1, 2, 3]))
            AhkTest.RaisesMatch(TypeError, "^must be real number, not str$", (*) => stdlib.pillow.Image.new("L", [1, 1]).putdata([1], "x", 0))
        } finally {
            if IsSet(badPixel)
                StdlibPillowTest.CloseImage(badPixel)
            if IsSet(shortData)
                StdlibPillowTest.CloseImage(shortData)
            if IsSet(putdataScaled)
                StdlibPillowTest.CloseImage(putdataScaled)
            if IsSet(frombytesGray)
                StdlibPillowTest.CloseImage(frombytesGray)
            if IsSet(frombytesRgb)
                StdlibPillowTest.CloseImage(frombytesRgb)
            if IsSet(bits)
                StdlibPillowTest.CloseImage(bits)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
        }
    }

    static TestImagePaletteMethodsMatchLocalPillow113()
    {
        p := unset
        p2 := unset
        pRgba := unset
        gray := unset
        try {
            p := stdlib.pillow.Image.new("P", [3, 1], 0)
            p.putdata([0, 1, 2])
            AhkTest.AssertEqual([], p.getpalette())
            AhkTest.AssertSame(stdlib.None, p.putpalette([0, 0, 0, 10, 20, 30, 200, 210, 220]))
            AhkTest.AssertEqual([0, 0, 0, 10, 20, 30, 200, 210, 220], p.getpalette())
            AhkTest.AssertEqual([0, 0, 0, 10, 20, 30, 200, 210, 220], p.getpalette("RGB"))
            AhkTest.AssertEqual([0, 0, 0, 255, 10, 20, 30, 255, 200, 210, 220, 255], p.getpalette("RGBA"))
            AhkTest.AssertEqual([0, 1, 2], p.getdata())

            p2 := stdlib.pillow.Image.new("P", [2, 1], 0)
            p2.putpalette([1, 2, 3, 4, 5, 6])
            AhkTest.AssertEqual([1, 2, 3, 4, 5, 6], p2.getpalette())

            pRgba := stdlib.pillow.Image.new("P", [1, 1], 0)
            pRgba.putpalette([1, 2, 3, 4, 5, 6, 7, 8], "RGBA")
            AhkTest.AssertEqual([1, 2, 3, 5, 6, 7], pRgba.getpalette("RGB"))
            AhkTest.AssertEqual([1, 2, 3, 4, 5, 6, 7, 8], pRgba.getpalette("RGBA"))

            gray := stdlib.pillow.Image.new("L", [1, 1], 0)
            AhkTest.AssertSame(stdlib.None, gray.putpalette([1, 2, 3]))
            AhkTest.AssertEqual([1, 2, 3], gray.getpalette())

            AhkTest.RaisesMatch(ValueError, "^unrecognized raw mode$", (*) => p.getpalette("BAD"))
            AhkTest.RaisesMatch(ValueError, "^unrecognized raw mode$", (*) => p.putpalette([1, 2, 3], "BAD"))
            AhkTest.RaisesMatch(TypeError, "^'str' object cannot be interpreted as an integer$", (*) => p.putpalette([1, "x", 3]))
            AhkTest.RaisesMatch(TypeError, "^cannot convert 'NoneType' object to bytes$", (*) => p.putpalette(stdlib.None))
        } finally {
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
            if IsSet(pRgba)
                StdlibPillowTest.CloseImage(pRgba)
            if IsSet(p2)
                StdlibPillowTest.CloseImage(p2)
            if IsSet(p)
                StdlibPillowTest.CloseImage(p)
        }
    }

    static TestImageApplyTransparencyMatchesLocalPillow113()
    {
        pInt := unset
        pBytes := unset
        rgb := unset
        noKey := unset
        badString := unset
        badIndex := unset
        try {
            pInt := stdlib.pillow.Image.new("P", [3, 1], 0)
            pInt.putdata([0, 1, 2])
            pInt.putpalette([1, 2, 3, 4, 5, 6, 7, 8, 9])
            AhkTest.AssertFalse(pInt.has_transparency_data)
            pInt.info["transparency"] := 1
            AhkTest.AssertTrue(pInt.has_transparency_data)
            AhkTest.AssertSame(stdlib.None, pInt.apply_transparency())
            AhkTest.AssertFalse(pInt.info.Has("transparency"))
            AhkTest.AssertTrue(pInt.has_transparency_data)
            AhkTest.AssertEqual([1, 2, 3, 255, 4, 5, 6, 0, 7, 8, 9, 255], pInt.getpalette("RGBA"))
            AhkTest.AssertEqual([1, 2, 3, 4, 5, 6, 7, 8, 9], pInt.getpalette("RGB"))
            AhkTest.AssertEqual([0, 1, 2], pInt.getdata())

            pBytes := stdlib.pillow.Image.new("P", [4, 1], 0)
            pBytes.putdata([0, 1, 2, 3])
            pBytes.putpalette([10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120])
            pBytes.info["transparency"] := [0, 64, 128, 255]
            AhkTest.AssertSame(stdlib.None, pBytes.apply_transparency())
            AhkTest.AssertFalse(pBytes.info.Has("transparency"))
            AhkTest.AssertTrue(pBytes.has_transparency_data)
            AhkTest.AssertEqual([10, 20, 30, 0, 40, 50, 60, 64, 70, 80, 90, 128, 100, 110, 120, 255], pBytes.getpalette("RGBA"))
            AhkTest.AssertEqual([10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120], pBytes.getpalette("RGB"))

            rgb := stdlib.pillow.Image.new("RGB", [1, 1], [1, 2, 3])
            rgb.info["transparency"] := 0
            AhkTest.AssertTrue(rgb.has_transparency_data)
            AhkTest.AssertSame(stdlib.None, rgb.apply_transparency())
            AhkTest.AssertTrue(rgb.info.Has("transparency"))
            AhkTest.AssertEqual([1, 2, 3], rgb.getpixel([0, 0]))

            noKey := stdlib.pillow.Image.new("P", [1, 1], 0)
            noKey.putpalette([1, 2, 3])
            AhkTest.AssertFalse(noKey.has_transparency_data)
            AhkTest.AssertSame(stdlib.None, noKey.apply_transparency())
            AhkTest.AssertFalse(noKey.info.Has("transparency"))
            AhkTest.AssertEqual([1, 2, 3, 255], noKey.getpalette("RGBA"))

            badString := stdlib.pillow.Image.new("P", [1, 1], 0)
            badString.putpalette([1, 2, 3])
            badString.info["transparency"] := "x"
            AhkTest.RaisesMatch(TypeError, "^can only concatenate str \(not `"int`"\) to str$", (*) => badString.apply_transparency())
            AhkTest.AssertTrue(badString.info.Has("transparency"))

            badIndex := stdlib.pillow.Image.new("P", [1, 1], 0)
            badIndex.putpalette([1, 2, 3])
            badIndex.info["transparency"] := 999
            AhkTest.RaisesMatch(IndexError, "^list assignment index out of range$", (*) => badIndex.apply_transparency())
            AhkTest.AssertTrue(badIndex.info.Has("transparency"))
        } finally {
            if IsSet(badIndex)
                StdlibPillowTest.CloseImage(badIndex)
            if IsSet(badString)
                StdlibPillowTest.CloseImage(badString)
            if IsSet(noKey)
                StdlibPillowTest.CloseImage(noKey)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
            if IsSet(pBytes)
                StdlibPillowTest.CloseImage(pBytes)
            if IsSet(pInt)
                StdlibPillowTest.CloseImage(pInt)
        }
    }

    static TestImageRemapPaletteMatchesLocalPillow113()
    {
        p := unset
        pRemapped := unset
        pEmptyRemapped := unset
        pNegativeRemapped := unset
        pTransparency := unset
        pTransparencyRemapped := unset
        pUnusedTransparency := unset
        pUnusedTransparencyRemapped := unset
        pRgba := unset
        pRgbaRemapped := unset
        gray := unset
        grayRemapped := unset
        pSource := unset
        pSourceRemapped := unset
        pSourceShortRemapped := unset
        pSourceRgba := unset
        pSourceRgbaRemapped := unset
        rgb := unset
        badP := unset
        try {
            p := stdlib.pillow.Image.new("P", [3, 1], 0)
            p.putdata([0, 1, 2])
            p.putpalette([10, 20, 30, 40, 50, 60, 70, 80, 90])
            pRemapped := p.remap_palette([2, 0])
            AhkTest.AssertEqual("P", pRemapped.mode)
            AhkTest.AssertEqual([3, 1], pRemapped.size)
            AhkTest.AssertEqual([1, 0, 0], pRemapped.getdata())
            AhkTest.AssertEqual([70, 80, 90, 10, 20, 30], pRemapped.getpalette("RGB"))
            AhkTest.AssertEqual([0, 1, 2], p.getdata())
            AhkTest.AssertEqual([10, 20, 30, 40, 50, 60, 70, 80, 90], p.getpalette("RGB"))
            pEmptyRemapped := p.remap_palette([])
            AhkTest.AssertEqual([0, 0, 0], pEmptyRemapped.getdata())
            AhkTest.AssertEqual([], pEmptyRemapped.getpalette("RGB"))
            pNegativeRemapped := p.remap_palette([-1])
            AhkTest.AssertEqual([0, 0, 0], pNegativeRemapped.getdata())
            AhkTest.AssertEqual([], pNegativeRemapped.getpalette("RGB"))

            pTransparency := stdlib.pillow.Image.new("P", [2, 1], 0)
            pTransparency.putdata([0, 1])
            pTransparency.putpalette([1, 2, 3, 4, 5, 6])
            pTransparency.info["transparency"] := 0
            pTransparencyRemapped := pTransparency.remap_palette([1, 0])
            AhkTest.AssertEqual([1, 0], pTransparencyRemapped.getdata())
            AhkTest.AssertEqual([4, 5, 6, 1, 2, 3], pTransparencyRemapped.getpalette("RGB"))
            AhkTest.AssertTrue(pTransparencyRemapped.info.Has("transparency"))
            AhkTest.AssertEqual(1, pTransparencyRemapped.info["transparency"])

            pUnusedTransparency := stdlib.pillow.Image.new("P", [2, 1], 0)
            pUnusedTransparency.putdata([0, 1])
            pUnusedTransparency.putpalette([1, 2, 3, 4, 5, 6])
            pUnusedTransparency.info["transparency"] := 2
            pUnusedTransparencyRemapped := pUnusedTransparency.remap_palette([1, 0])
            AhkTest.AssertEqual([1, 0], pUnusedTransparencyRemapped.getdata())
            AhkTest.AssertFalse(pUnusedTransparencyRemapped.info.Has("transparency"))

            pRgba := stdlib.pillow.Image.new("P", [3, 1], 0)
            pRgba.putdata([0, 1, 2])
            pRgba.putpalette([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "RGBA")
            pRgbaRemapped := pRgba.remap_palette([2, 0])
            AhkTest.AssertEqual([1, 0, 0], pRgbaRemapped.getdata())
            AhkTest.AssertEqual([9, 10, 11, 12, 1, 2, 3, 4], pRgbaRemapped.getpalette("RGBA"))

            gray := stdlib.pillow.Image.new("L", [4, 1], 0)
            gray.putdata([0, 1, 2, 5])
            grayRemapped := gray.remap_palette([2, 0])
            AhkTest.AssertEqual("P", grayRemapped.mode)
            AhkTest.AssertEqual([1, 0, 0, 0], grayRemapped.getdata())
            AhkTest.AssertEqual([2, 2, 2, 0, 0, 0], grayRemapped.getpalette("RGB"))

            pSource := stdlib.pillow.Image.new("P", [3, 1], 0)
            pSource.putdata([0, 1, 2])
            pSource.putpalette([10, 20, 30, 40, 50, 60, 70, 80, 90])
            pSourceRemapped := pSource.remap_palette([2, 0], [100, 101, 102, 110, 111, 112, 120, 121, 122])
            AhkTest.AssertEqual([1, 0, 0], pSourceRemapped.getdata())
            AhkTest.AssertEqual([120, 121, 122, 100, 101, 102], pSourceRemapped.getpalette("RGB"))
            pSourceShortRemapped := pSource.remap_palette([1], [1, 2, 3])
            AhkTest.AssertEqual([0, 0, 0], pSourceShortRemapped.getdata())
            AhkTest.AssertEqual([], pSourceShortRemapped.getpalette("RGB"))

            sourceRgbaPalette := []
            loop 4 {
                loop 256
                    sourceRgbaPalette.Push(A_Index - 1)
            }
            pSourceRgba := stdlib.pillow.Image.new("P", [2, 1], 0)
            pSourceRgba.putdata([0, 1])
            pSourceRgba.putpalette([1, 2, 3, 4, 5, 6])
            pSourceRgbaRemapped := pSourceRgba.remap_palette([1, 0], sourceRgbaPalette)
            AhkTest.AssertEqual([1, 0], pSourceRgbaRemapped.getdata())
            AhkTest.AssertEqual([4, 5, 6, 7, 0, 1, 2, 3], pSourceRgbaRemapped.getpalette("RGBA"))

            rgb := stdlib.pillow.Image.new("RGB", [1, 1], [1, 2, 3])
            AhkTest.RaisesMatch(ValueError, "^illegal image mode$", (*) => rgb.remap_palette([]))

            badP := stdlib.pillow.Image.new("P", [1, 1], 0)
            badP.putpalette([1, 2, 3])
            AhkTest.RaisesMatch(TypeError, "^slice indices must be integers or None or have an __index__ method$", (*) => badP.remap_palette([0.5]))
            AhkTest.RaisesMatch(TypeError, "^can only concatenate str \(not `"int`"\) to str$", (*) => badP.remap_palette("x"))
            AhkTest.RaisesMatch(IndexError, "^list assignment index out of range$", (*) => badP.remap_palette([999]))
            AhkTest.RaisesMatch(TypeError, "^can't concat str to bytes$", (*) => badP.remap_palette([0], "abc"))
        } finally {
            if IsSet(badP)
                StdlibPillowTest.CloseImage(badP)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
            if IsSet(pSourceRgbaRemapped)
                StdlibPillowTest.CloseImage(pSourceRgbaRemapped)
            if IsSet(pSourceRgba)
                StdlibPillowTest.CloseImage(pSourceRgba)
            if IsSet(pSourceShortRemapped)
                StdlibPillowTest.CloseImage(pSourceShortRemapped)
            if IsSet(pSourceRemapped)
                StdlibPillowTest.CloseImage(pSourceRemapped)
            if IsSet(pSource)
                StdlibPillowTest.CloseImage(pSource)
            if IsSet(grayRemapped)
                StdlibPillowTest.CloseImage(grayRemapped)
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
            if IsSet(pRgbaRemapped)
                StdlibPillowTest.CloseImage(pRgbaRemapped)
            if IsSet(pRgba)
                StdlibPillowTest.CloseImage(pRgba)
            if IsSet(pUnusedTransparencyRemapped)
                StdlibPillowTest.CloseImage(pUnusedTransparencyRemapped)
            if IsSet(pUnusedTransparency)
                StdlibPillowTest.CloseImage(pUnusedTransparency)
            if IsSet(pTransparencyRemapped)
                StdlibPillowTest.CloseImage(pTransparencyRemapped)
            if IsSet(pTransparency)
                StdlibPillowTest.CloseImage(pTransparency)
            if IsSet(pRemapped)
                StdlibPillowTest.CloseImage(pRemapped)
            if IsSet(pNegativeRemapped)
                StdlibPillowTest.CloseImage(pNegativeRemapped)
            if IsSet(pEmptyRemapped)
                StdlibPillowTest.CloseImage(pEmptyRemapped)
            if IsSet(p)
                StdlibPillowTest.CloseImage(p)
        }
    }

    static TestImageEntropyMatchesLocalPillow113()
    {
        gray := unset
        gray4 := unset
        rgb := unset
        rgba := unset
        bits := unset
        mask := unset
        flat := unset
        try {
            gray := stdlib.pillow.Image.new("L", [4, 1], 0)
            gray.putdata([0, 0, 255, 255])
            AhkTest.AssertApprox(1.0, gray.entropy(), { Abs: 0.000000000001, Rel: 0.0 })

            gray4 := stdlib.pillow.Image.new("L", [4, 1], 0)
            gray4.putdata([0, 64, 128, 255])
            AhkTest.AssertApprox(2.0, gray4.entropy(), { Abs: 0.000000000001, Rel: 0.0 })

            mask := stdlib.pillow.Image.new("L", [4, 1], 0)
            mask.putdata([255, 0, 255, 0])
            AhkTest.AssertApprox(1.0, gray4.entropy(mask), { Abs: 0.000000000001, Rel: 0.0 })

            rgb := stdlib.pillow.Image.new("RGB", [2, 1], [0, 0, 0])
            rgb.putdata([[0, 0, 0], [255, 255, 255]])
            AhkTest.AssertApprox(2.584962500721156, rgb.entropy(), { Abs: 0.000000000001, Rel: 0.0 })

            rgba := stdlib.pillow.Image.new("RGBA", [2, 1], [0, 0, 0, 0])
            rgba.putdata([[0, 0, 0, 0], [255, 255, 255, 255]])
            AhkTest.AssertApprox(3.0, rgba.entropy(), { Abs: 0.000000000001, Rel: 0.0 })

            bits := stdlib.pillow.Image.new("1", [4, 1], 0)
            bits.putdata([0, 1, 255, 0])
            AhkTest.AssertApprox(1.5, bits.entropy(), { Abs: 0.000000000001, Rel: 0.0 })

            flat := stdlib.pillow.Image.new("L", [3, 1], 7)
            AhkTest.AssertApprox(0.0, flat.entropy(), { Abs: 0.000000000001, Rel: 0.0 })

            AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute 'load'$", (*) => gray.entropy("x"))
            AhkTest.RaisesMatch(ValueError, "^images do not match$", (*) => gray.entropy(stdlib.pillow.Image.new("L", [1, 1], 255)))
            AhkTest.RaisesMatch(ValueError, "^bad transparency mask$", (*) => gray.entropy(stdlib.pillow.Image.new("RGB", [4, 1], [255, 255, 255])))
        } finally {
            if IsSet(flat)
                StdlibPillowTest.CloseImage(flat)
            if IsSet(mask)
                StdlibPillowTest.CloseImage(mask)
            if IsSet(bits)
                StdlibPillowTest.CloseImage(bits)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
            if IsSet(gray4)
                StdlibPillowTest.CloseImage(gray4)
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
        }
    }

    static TestImageReduceMatchesLocalPillow113()
    {
        rgb := unset
        reducedRgb := unset
        gray := unset
        reducedGrayPair := unset
        reducedGrayBox := unset
        same := unset
        bits := unset
        try {
            rgb := stdlib.pillow.Image.new("RGB", [4, 4])
            rgb.putdata([
                [0, 0, 0], [10, 20, 30], [200, 0, 0], [250, 50, 100],
                [20, 40, 60], [30, 60, 90], [220, 20, 20], [240, 40, 80],
                [0, 200, 0], [10, 220, 30], [50, 50, 200], [60, 60, 220],
                [20, 240, 60], [30, 250, 90], [70, 70, 240], [80, 80, 255],
            ])
            reducedRgb := rgb.reduce(2)
            AhkTest.AssertEqual("RGB", reducedRgb.mode)
            AhkTest.AssertEqual([2, 2], reducedRgb.size)
            AhkTest.AssertEqual([
                [[15, 30, 45], [228, 28, 50]],
                [[15, 228, 45], [65, 65, 229]],
            ], StdlibPillowTest.PixelRows(reducedRgb))

            gray := stdlib.pillow.Image.new("L", [5, 3])
            gray.putdata([
                0, 10, 20, 30, 40,
                50, 60, 70, 80, 90,
                100, 110, 120, 130, 140,
            ])
            reducedGrayPair := gray.reduce([2, 1])
            AhkTest.AssertEqual("L", reducedGrayPair.mode)
            AhkTest.AssertEqual([3, 3], reducedGrayPair.size)
            AhkTest.AssertEqual([[5, 25, 40], [55, 75, 90], [105, 125, 140]], StdlibPillowTest.PixelRows(reducedGrayPair))

            reducedGrayBox := gray.reduce(2, [1, 0, 5, 3])
            AhkTest.AssertEqual([2, 2], reducedGrayBox.size)
            AhkTest.AssertEqual([[40, 60], [115, 135]], StdlibPillowTest.PixelRows(reducedGrayBox))

            same := rgb.reduce(1)
            same.putpixel([0, 0], [9, 9, 9])
            AhkTest.AssertEqual([0, 0, 0], rgb.getpixel([0, 0]))
            AhkTest.AssertEqual([9, 9, 9], same.getpixel([0, 0]))

            bits := stdlib.pillow.Image.new("1", [4, 2], 0)
            bits.putdata([0, 255, 255, 0, 255, 255, 0, 0])

            AhkTest.RaisesMatch(ValueError, "^scale must be > 0$", (*) => rgb.reduce(0))
            AhkTest.RaisesMatch(ValueError, "^scale must be > 0$", (*) => rgb.reduce(-1))
            AhkTest.RaisesMatch(TypeError, "^'str' object cannot be interpreted as an integer$", (*) => rgb.reduce("x"))
            AhkTest.RaisesMatch(TypeError, "^argument 1 must be sequence of length 2, not 3$", (*) => rgb.reduce([2, 2, 2]))
            AhkTest.RaisesMatch(TypeError, "^'NoneType' object cannot be interpreted as an integer$", (*) => rgb.reduce(stdlib.None))
            AhkTest.RaisesMatch(ValueError, "^box can't exceed original image size$", (*) => rgb.reduce(2, [0, 0, 5, 4]))
            AhkTest.RaisesMatch(ValueError, "^box offset can't be negative$", (*) => rgb.reduce(2, [-1, 0, 4, 4]))
            AhkTest.RaisesMatch(ValueError, "^box can't be empty$", (*) => rgb.reduce(2, [0, 0, 0, 4]))
            AhkTest.RaisesMatch(ValueError, "^image has wrong mode$", (*) => bits.reduce(2))
        } finally {
            if IsSet(bits)
                StdlibPillowTest.CloseImage(bits)
            if IsSet(same)
                StdlibPillowTest.CloseImage(same)
            if IsSet(reducedGrayBox)
                StdlibPillowTest.CloseImage(reducedGrayBox)
            if IsSet(reducedGrayPair)
                StdlibPillowTest.CloseImage(reducedGrayPair)
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
            if IsSet(reducedRgb)
                StdlibPillowTest.CloseImage(reducedRgb)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
        }
    }

    static TestImageEffectSpreadMatchesLocalPillow113()
    {
        gray := unset
        zero := unset
        negative := unset
        rgb := unset
        rgbSpread := unset
        rgba := unset
        rgbaSpread := unset
        try {
            gray := stdlib.pillow.Image.new("L", [4, 3])
            gray.putdata([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])

            zero := gray.effect_spread(0)
            AhkTest.AssertEqual("L", zero.mode)
            AhkTest.AssertEqual([4, 3], zero.size)
            AhkTest.AssertEqual([[0, 1, 2, 3], [4, 5, 6, 7], [8, 9, 10, 11]], StdlibPillowTest.PixelRows(zero))
            zero.putpixel([0, 0], 99)
            AhkTest.AssertEqual(0, gray.getpixel([0, 0]))

            negative := gray.effect_spread(-1)
            AhkTest.AssertEqual([4, 3], negative.size)
            AhkTest.AssertEqual([[0, 1, 2, 3], [4, 5, 6, 7], [8, 9, 10, 11]], StdlibPillowTest.PixelRows(negative))

            rgb := stdlib.pillow.Image.new("RGB", [3, 2])
            rgb.putdata([
                [10, 20, 30], [40, 50, 60], [70, 80, 90],
                [100, 110, 120], [130, 140, 150], [160, 170, 180],
            ])
            rgbSpread := rgb.effect_spread(3)
            AhkTest.AssertEqual("RGB", rgbSpread.mode)
            AhkTest.AssertEqual([3, 2], rgbSpread.size)
            StdlibPillowTest.AssertPixelsComeFrom(rgbSpread, [
                [10, 20, 30], [40, 50, 60], [70, 80, 90],
                [100, 110, 120], [130, 140, 150], [160, 170, 180],
            ])
            rgbSpread.putpixel([0, 0], [1, 1, 1])
            AhkTest.AssertEqual([10, 20, 30], rgb.getpixel([0, 0]))

            rgba := stdlib.pillow.Image.new("RGBA", [2, 2])
            rgba.putdata([
                [1, 2, 3, 4], [5, 6, 7, 8],
                [9, 10, 11, 12], [13, 14, 15, 16],
            ])
            rgbaSpread := rgba.effect_spread(2)
            AhkTest.AssertEqual("RGBA", rgbaSpread.mode)
            AhkTest.AssertEqual([2, 2], rgbaSpread.size)
            StdlibPillowTest.AssertPixelsComeFrom(rgbaSpread, [
                [1, 2, 3, 4], [5, 6, 7, 8],
                [9, 10, 11, 12], [13, 14, 15, 16],
            ])

            AhkTest.RaisesMatch(TypeError, "^'float' object cannot be interpreted as an integer$", (*) => gray.effect_spread(1.2))
            AhkTest.RaisesMatch(TypeError, "^'str' object cannot be interpreted as an integer$", (*) => gray.effect_spread("x"))
            AhkTest.RaisesMatch(TypeError, "^'NoneType' object cannot be interpreted as an integer$", (*) => gray.effect_spread(stdlib.None))
        } finally {
            if IsSet(rgbaSpread)
                StdlibPillowTest.CloseImage(rgbaSpread)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
            if IsSet(rgbSpread)
                StdlibPillowTest.CloseImage(rgbSpread)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
            if IsSet(negative)
                StdlibPillowTest.CloseImage(negative)
            if IsSet(zero)
                StdlibPillowTest.CloseImage(zero)
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
        }
    }

    static TestImageThumbnailMatchesLocalPillow113()
    {
        rgb := unset
        tall := unset
        same := unset
        fractional := unset
        try {
            rgb := StdlibPillowTest.ThumbnailRgbSource()
            AhkTest.AssertSame(stdlib.None, rgb.thumbnail([3, 3]))
            AhkTest.AssertEqual("RGB", rgb.mode)
            AhkTest.AssertEqual([3, 2], rgb.size)
            AhkTest.AssertEqual([
                [[17, 23, 38], [56, 43, 48], [95, 63, 57]],
                [[35, 77, 148], [74, 97, 158], [113, 117, 167]],
            ], StdlibPillowTest.PixelRows(rgb))

            tall := StdlibPillowTest.ThumbnailRgbSource()
            AhkTest.AssertSame(stdlib.None, tall.thumbnail([2, 9]))
            AhkTest.AssertEqual([2, 1], tall.size)
            AhkTest.AssertEqual([[[38, 56, 96], [92, 84, 109]]], StdlibPillowTest.PixelRows(tall))

            same := StdlibPillowTest.ThumbnailRgbSource()
            AhkTest.AssertSame(stdlib.None, same.thumbnail([20, 20]))
            AhkTest.AssertEqual([6, 4], same.size)
            same.putpixel([0, 0], [9, 9, 9])
            AhkTest.AssertEqual([9, 9, 9], same.getpixel([0, 0]))

            fractional := stdlib.pillow.Image.new("L", [5, 2])
            fractional.putdata([0, 25, 50, 75, 100, 125, 150, 175, 200, 225])
            AhkTest.AssertSame(stdlib.None, fractional.thumbnail([2.9, 1.9]))
            AhkTest.AssertEqual([2, 1], fractional.size)
            AhkTest.AssertEqual([[84, 142]], StdlibPillowTest.PixelRows(fractional))

            AhkTest.RaisesMatch(ValueError, "^not enough values to unpack \(expected 2, got 1\)$", (*) => StdlibPillowTest.ThumbnailRgbSource().thumbnail([2]))
            AhkTest.RaisesMatch(TypeError, "^must be real number, not str$", (*) => StdlibPillowTest.ThumbnailRgbSource().thumbnail("xy"))
            AhkTest.RaisesMatch(TypeError, "^'NoneType' object is not iterable$", (*) => StdlibPillowTest.ThumbnailRgbSource().thumbnail(stdlib.None))
            AhkTest.RaisesMatch(ZeroDivisionError, "^division by zero$", (*) => StdlibPillowTest.ThumbnailRgbSource().thumbnail([0, 0]))
            AhkTest.RaisesMatch(ValueError, "^invalid literal for int\(\) with base 10: 'xxx'$", (*) => StdlibPillowTest.ThumbnailRgbSource().thumbnail([3, 3], unset, "x"))
        } finally {
            if IsSet(fractional)
                StdlibPillowTest.CloseImage(fractional)
            if IsSet(same)
                StdlibPillowTest.CloseImage(same)
            if IsSet(tall)
                StdlibPillowTest.CloseImage(tall)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
        }
    }

    static TestImageConvertTransposeAndRotateMatchLocalPillow113()
    {
        image := StdlibPillowTest.TransformSourceImage()
        gray := unset
        rgba := unset
        backRgb := unset
        flipped := unset
        transposed := unset
        rotatedNoExpand := unset
        rotatedExpand := unset
        try {
            AhkTest.AssertEqual(0, stdlib.pillow.Image.Transpose.FLIP_LEFT_RIGHT)
            AhkTest.AssertEqual(2, stdlib.pillow.Image.Transpose.ROTATE_90)

            gray := image.convert("L")
            AhkTest.AssertEqual("L", gray.mode)
            AhkTest.AssertEqual([3, 2], gray.size)
            AhkTest.AssertEqual([[18, 48, 78], [108, 138, 168]], StdlibPillowTest.PixelRows(gray))

            rgba := image.convert("RGBA")
            AhkTest.AssertEqual("RGBA", rgba.mode)
            AhkTest.AssertEqual([3, 2], rgba.size)
            AhkTest.AssertEqual([10, 20, 30, 255], rgba.getpixel([0, 0]))
            backRgb := rgba.convert("RGB")
            AhkTest.AssertEqual("RGB", backRgb.mode)
            AhkTest.AssertEqual([10, 20, 30], backRgb.getpixel([0, 0]))

            flipped := image.transpose(stdlib.pillow.Image.Transpose.FLIP_LEFT_RIGHT)
            AhkTest.AssertEqual([3, 2], flipped.size)
            AhkTest.AssertEqual([
                [[70, 80, 90], [40, 50, 60], [10, 20, 30]],
                [[160, 170, 180], [130, 140, 150], [100, 110, 120]]
            ], StdlibPillowTest.PixelRows(flipped))

            transposed := image.transpose(stdlib.pillow.Image.Transpose.ROTATE_90)
            AhkTest.AssertEqual([2, 3], transposed.size)
            AhkTest.AssertEqual([
                [[70, 80, 90], [160, 170, 180]],
                [[40, 50, 60], [130, 140, 150]],
                [[10, 20, 30], [100, 110, 120]]
            ], StdlibPillowTest.PixelRows(transposed))

            rotatedNoExpand := image.rotate(90)
            AhkTest.AssertEqual([3, 2], rotatedNoExpand.size)
            AhkTest.AssertEqual([
                [[70, 80, 90], [160, 170, 180], [0, 0, 0]],
                [[40, 50, 60], [130, 140, 150], [0, 0, 0]]
            ], StdlibPillowTest.PixelRows(rotatedNoExpand))

            rotatedExpand := image.rotate(90, { expand: true })
            AhkTest.AssertEqual([2, 3], rotatedExpand.size)
            AhkTest.AssertEqual(StdlibPillowTest.PixelRows(transposed), StdlibPillowTest.PixelRows(rotatedExpand))
        } finally {
            if IsSet(rotatedExpand)
                StdlibPillowTest.CloseImage(rotatedExpand)
            if IsSet(rotatedNoExpand)
                StdlibPillowTest.CloseImage(rotatedNoExpand)
            if IsSet(transposed)
                StdlibPillowTest.CloseImage(transposed)
            if IsSet(flipped)
                StdlibPillowTest.CloseImage(flipped)
            if IsSet(backRgb)
                StdlibPillowTest.CloseImage(backRgb)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
            StdlibPillowTest.CloseImage(image)
        }
    }

    static TestImageTransformMatchesLocalPillow113()
    {
        image := stdlib.pillow.Image.new("RGB", [4, 2], [0, 0, 0])
        affineIdentity := unset
        affineShift := unset
        extentCrop := unset
        extentScale := unset
        quadIdentity := unset
        meshSwap := unset
        getdataResult := unset
        handlerResult := unset
        palette := unset
        paletteTransformed := unset
        bad := unset
        try {
            for item in [
                [[0, 0], [10, 20, 30]], [[1, 0], [40, 50, 60]], [[2, 0], [70, 80, 90]], [[3, 0], [100, 110, 120]],
                [[0, 1], [130, 140, 150]], [[1, 1], [160, 170, 180]], [[2, 1], [190, 200, 210]], [[3, 1], [220, 230, 240]],
            ]
                image.putpixel(item[1], item[2])
            image.info["comment"] := "kept"

            AhkTest.AssertEqual(0, stdlib.pillow.Image.Transform.AFFINE)
            AhkTest.AssertEqual(1, stdlib.pillow.Image.Transform.EXTENT)
            AhkTest.AssertEqual(2, stdlib.pillow.Image.Transform.PERSPECTIVE)
            AhkTest.AssertEqual(3, stdlib.pillow.Image.Transform.QUAD)
            AhkTest.AssertEqual(4, stdlib.pillow.Image.Transform.MESH)
            AhkTest.AssertEqual(0, stdlib.pillow.Image.Resampling.NEAREST)
            AhkTest.AssertEqual(1, stdlib.pillow.Image.Resampling.LANCZOS)
            AhkTest.AssertEqual(2, stdlib.pillow.Image.Resampling.BILINEAR)
            AhkTest.AssertEqual(3, stdlib.pillow.Image.Resampling.BICUBIC)
            AhkTest.AssertEqual(4, stdlib.pillow.Image.Resampling.BOX)
            AhkTest.AssertEqual(5, stdlib.pillow.Image.Resampling.HAMMING)

            affineIdentity := image.transform(image.size, stdlib.pillow.Image.Transform.AFFINE, [1, 0, 0, 0, 1, 0])
            AhkTest.AssertEqual(StdlibPillowTest.PixelRows(image), StdlibPillowTest.PixelRows(affineIdentity))
            AhkTest.AssertEqual("kept", affineIdentity.info["comment"])
            AhkTest.AssertTrue(ObjPtr(affineIdentity) != ObjPtr(image))

            affineShift := image.transform(image.size, stdlib.pillow.Image.Transform.AFFINE, [1, 0, 1, 0, 1, 0], unset, unset, [1, 2, 3])
            AhkTest.AssertEqual([
                [[40, 50, 60], [70, 80, 90], [100, 110, 120], [1, 2, 3]],
                [[160, 170, 180], [190, 200, 210], [220, 230, 240], [1, 2, 3]],
            ], StdlibPillowTest.PixelRows(affineShift))

            extentCrop := image.transform([3, 2], stdlib.pillow.Image.Transform.EXTENT, [1, 0, 4, 2])
            AhkTest.AssertEqual([
                [[40, 50, 60], [70, 80, 90], [100, 110, 120]],
                [[160, 170, 180], [190, 200, 210], [220, 230, 240]],
            ], StdlibPillowTest.PixelRows(extentCrop))

            extentScale := image.transform([2, 1], stdlib.pillow.Image.Transform.EXTENT, [0, 0, 4, 2])
            AhkTest.AssertEqual([[[160, 170, 180], [220, 230, 240]]], StdlibPillowTest.PixelRows(extentScale))

            quadIdentity := image.transform(image.size, stdlib.pillow.Image.Transform.QUAD, [0, 0, 0, 2, 4, 2, 4, 0])
            AhkTest.AssertEqual(StdlibPillowTest.PixelRows(image), StdlibPillowTest.PixelRows(quadIdentity))

            meshSwap := image.transform(image.size, stdlib.pillow.Image.Transform.MESH, [
                [[0, 0, 2, 2], [2, 0, 2, 2, 4, 2, 4, 0]],
                [[2, 0, 4, 2], [0, 0, 0, 2, 2, 2, 2, 0]],
            ])
            AhkTest.AssertEqual([
                [[70, 80, 90], [100, 110, 120], [10, 20, 30], [40, 50, 60]],
                [[190, 200, 210], [220, 230, 240], [130, 140, 150], [160, 170, 180]],
            ], StdlibPillowTest.PixelRows(meshSwap))

            getdataResult := image.transform([3, 2], StdlibPillowTransformGetData())
            AhkTest.AssertEqual(StdlibPillowTest.PixelRows(extentCrop), StdlibPillowTest.PixelRows(getdataResult))

            handler := StdlibPillowTransformHandler()
            handlerResult := image.transform([2, 1], handler, unset, unset, 0)
            AhkTest.AssertEqual([[[10, 20, 30], [40, 50, 60]]], StdlibPillowTest.PixelRows(handlerResult))
            AhkTest.AssertEqual([[[2, 1], "RGB", 0, 0]], handler.Calls)

            palette := stdlib.pillow.Image.new("P", [2, 1], 0)
            palette.putdata([0, 1])
            palette.putpalette([1, 2, 3, 4, 5, 6])
            paletteTransformed := palette.transform(palette.size, stdlib.pillow.Image.Transform.AFFINE, [1, 0, 0, 0, 1, 0])
            AhkTest.AssertEqual("P", paletteTransformed.mode)
            AhkTest.AssertEqual([[0, 1]], StdlibPillowTest.PixelRows(paletteTransformed))
            AhkTest.AssertEqual([1, 2, 3, 4, 5, 6], paletteTransformed.getpalette("RGB"))

            bad := stdlib.pillow.Image.new("RGB", [1, 1], [1, 2, 3])
            AhkTest.RaisesMatch(ValueError, "^missing method data$", (*) => bad.transform([1, 1], stdlib.pillow.Image.Transform.EXTENT))
            AhkTest.RaisesMatch(ValueError, "^unknown transformation method$", (*) => bad.transform([1, 1], 99, [0]))
            AhkTest.RaisesMatch(ValueError, "^Image\.Resampling\.BOX \(4\) cannot be used\. Use Image\.Resampling\.NEAREST \(0\), Image\.Resampling\.BILINEAR \(2\) or Image\.Resampling\.BICUBIC \(3\)$", (*) => bad.transform([1, 1], stdlib.pillow.Image.Transform.EXTENT, [0, 0, 1, 1], stdlib.pillow.Image.Resampling.BOX))
            AhkTest.RaisesMatch(ValueError, "^Unknown resampling filter \(99\)\. Use Image\.Resampling\.NEAREST \(0\), Image\.Resampling\.BILINEAR \(2\) or Image\.Resampling\.BICUBIC \(3\)$", (*) => bad.transform([1, 1], stdlib.pillow.Image.Transform.EXTENT, [0, 0, 1, 1], 99))
        } finally {
            if IsSet(bad)
                StdlibPillowTest.CloseImage(bad)
            if IsSet(paletteTransformed)
                StdlibPillowTest.CloseImage(paletteTransformed)
            if IsSet(palette)
                StdlibPillowTest.CloseImage(palette)
            if IsSet(handlerResult)
                StdlibPillowTest.CloseImage(handlerResult)
            if IsSet(getdataResult)
                StdlibPillowTest.CloseImage(getdataResult)
            if IsSet(meshSwap)
                StdlibPillowTest.CloseImage(meshSwap)
            if IsSet(quadIdentity)
                StdlibPillowTest.CloseImage(quadIdentity)
            if IsSet(extentScale)
                StdlibPillowTest.CloseImage(extentScale)
            if IsSet(extentCrop)
                StdlibPillowTest.CloseImage(extentCrop)
            if IsSet(affineShift)
                StdlibPillowTest.CloseImage(affineShift)
            if IsSet(affineIdentity)
                StdlibPillowTest.CloseImage(affineIdentity)
            StdlibPillowTest.CloseImage(image)
        }
    }

    static TestImageTransformModuleMatchesLocalPillow113()
    {
        image := stdlib.pillow.Image.new("RGB", [4, 2], [0, 0, 0])
        affineResult := unset
        extentResult := unset
        quadResult := unset
        perspectiveResult := unset
        meshResult := unset
        try {
            AhkTest.AssertTrue(HasProp(stdlib.pillow, "ImageTransform"))
            AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageTransform, "AffineTransform"))
            AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageTransform, "ExtentTransform"))
            AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageTransform, "QuadTransform"))
            AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageTransform, "PerspectiveTransform"))
            AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageTransform, "MeshTransform"))

            for item in [
                [[0, 0], [10, 20, 30]], [[1, 0], [40, 50, 60]], [[2, 0], [70, 80, 90]], [[3, 0], [100, 110, 120]],
                [[0, 1], [130, 140, 150]], [[1, 1], [160, 170, 180]], [[2, 1], [190, 200, 210]], [[3, 1], [220, 230, 240]],
            ]
                image.putpixel(item[1], item[2])

            affine := stdlib.pillow.ImageTransform.AffineTransform([1, 0, 0, 0, 1, 0])
            AhkTest.AssertEqual([stdlib.pillow.Image.Transform.AFFINE, [1, 0, 0, 0, 1, 0]], affine.getdata())
            AhkTest.AssertEqual([1, 0, 0, 0, 1, 0], affine.data)
            affineResult := affine.transform(image.size, image)
            AhkTest.AssertEqual(StdlibPillowTest.PixelRows(image), StdlibPillowTest.PixelRows(affineResult))

            extent := stdlib.pillow.ImageTransform.ExtentTransform([1, 0, 4, 2])
            AhkTest.AssertEqual([stdlib.pillow.Image.Transform.EXTENT, [1, 0, 4, 2]], extent.getdata())
            extentResult := extent.transform([3, 2], image)
            AhkTest.AssertEqual([
                [[40, 50, 60], [70, 80, 90], [100, 110, 120]],
                [[160, 170, 180], [190, 200, 210], [220, 230, 240]],
            ], StdlibPillowTest.PixelRows(extentResult))

            quad := stdlib.pillow.ImageTransform.QuadTransform([0, 0, 0, 2, 4, 2, 4, 0])
            AhkTest.AssertEqual([stdlib.pillow.Image.Transform.QUAD, [0, 0, 0, 2, 4, 2, 4, 0]], quad.getdata())
            quadResult := quad.transform(image.size, image)
            AhkTest.AssertEqual(StdlibPillowTest.PixelRows(image), StdlibPillowTest.PixelRows(quadResult))

            perspective := stdlib.pillow.ImageTransform.PerspectiveTransform([1, 0, 0, 0, 1, 0, 0, 0])
            AhkTest.AssertEqual([stdlib.pillow.Image.Transform.PERSPECTIVE, [1, 0, 0, 0, 1, 0, 0, 0]], perspective.getdata())
            perspectiveResult := perspective.transform(image.size, image)
            AhkTest.AssertEqual(StdlibPillowTest.PixelRows(image), StdlibPillowTest.PixelRows(perspectiveResult))

            mesh := stdlib.pillow.ImageTransform.MeshTransform([
                [[0, 0, 2, 2], [2, 0, 2, 2, 4, 2, 4, 0]],
                [[2, 0, 4, 2], [0, 0, 0, 2, 2, 2, 2, 0]],
            ])
            AhkTest.AssertEqual(stdlib.pillow.Image.Transform.MESH, mesh.getdata()[1])
            meshResult := mesh.transform(image.size, image)
            AhkTest.AssertEqual([
                [[70, 80, 90], [100, 110, 120], [10, 20, 30], [40, 50, 60]],
                [[190, 200, 210], [220, 230, 240], [130, 140, 150], [160, 170, 180]],
            ], StdlibPillowTest.PixelRows(meshResult))

            AhkTest.RaisesMatch(AttributeError, "^'Transform' object has no attribute 'method'$", (*) => stdlib.pillow.ImageTransform.Transform([1]).getdata())
            AhkTest.RaisesMatch(TypeError, "^Transform\.__init__\(\) missing 1 required positional argument: 'data'$", (*) => stdlib.pillow.ImageTransform.AffineTransform())
            AhkTest.RaisesMatch(TypeError, "^Transform\.__init__\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.pillow.ImageTransform.AffineTransform([1], 2))
            AhkTest.RaisesMatch(TypeError, "^Transform\.getdata\(\) takes 1 positional argument but 2 were given$", (*) => affine.getdata(1))
            AhkTest.RaisesMatch(TypeError, "^Transform\.transform\(\) missing 1 required positional argument: 'image'$", (*) => affine.transform([1, 1]))
        } finally {
            if IsSet(meshResult)
                StdlibPillowTest.CloseImage(meshResult)
            if IsSet(perspectiveResult)
                StdlibPillowTest.CloseImage(perspectiveResult)
            if IsSet(quadResult)
                StdlibPillowTest.CloseImage(quadResult)
            if IsSet(extentResult)
                StdlibPillowTest.CloseImage(extentResult)
            if IsSet(affineResult)
                StdlibPillowTest.CloseImage(affineResult)
            StdlibPillowTest.CloseImage(image)
        }
    }

    static TestImageQuantizeMatchesLocalPillow113()
    {
        rgb := unset
        rgbDefault := unset
        rgbDefaultAsRgb := unset
        rgbTwo := unset
        palette := unset
        rgbPalette := unset
        gray := unset
        grayDefault := unset
        rgba := unset
        rgbaDefault := unset
        badPalette := unset
        try {
            AhkTest.AssertEqual(0, stdlib.pillow.Image.Dither.NONE)
            AhkTest.AssertEqual(1, stdlib.pillow.Image.Dither.ORDERED)
            AhkTest.AssertEqual(2, stdlib.pillow.Image.Dither.RASTERIZE)
            AhkTest.AssertEqual(3, stdlib.pillow.Image.Dither.FLOYDSTEINBERG)
            AhkTest.AssertEqual(0, stdlib.pillow.Image.Quantize.MEDIANCUT)
            AhkTest.AssertEqual(1, stdlib.pillow.Image.Quantize.MAXCOVERAGE)
            AhkTest.AssertEqual(2, stdlib.pillow.Image.Quantize.FASTOCTREE)
            AhkTest.AssertEqual(3, stdlib.pillow.Image.Quantize.LIBIMAGEQUANT)

            rgb := stdlib.pillow.Image.new("RGB", [4, 1], [0, 0, 0])
            for item in [
                [[0, 0], [10, 20, 30]], [[1, 0], [10, 20, 30]],
                [[2, 0], [200, 210, 220]], [[3, 0], [1, 2, 3]],
            ]
                rgb.putpixel(item[1], item[2])

            rgbDefault := rgb.quantize()
            AhkTest.AssertEqual("P", rgbDefault.mode)
            AhkTest.AssertEqual([1, 1, 0, 2], rgbDefault.getdata())
            AhkTest.AssertEqual([200, 210, 220, 10, 20, 30, 1, 2, 3], rgbDefault.getpalette("RGB"))
            rgbDefaultAsRgb := rgbDefault.convert("RGB")
            AhkTest.AssertEqual([[[10, 20, 30], [10, 20, 30], [200, 210, 220], [1, 2, 3]]], StdlibPillowTest.PixelRows(rgbDefaultAsRgb))

            rgbTwo := rgb.quantize(2)
            AhkTest.AssertEqual([1, 1, 0, 1], rgbTwo.getdata())
            AhkTest.AssertEqual([73, 83, 93, 1, 2, 3], rgbTwo.getpalette("RGB"))

            palette := stdlib.pillow.Image.new("P", [2, 1], 0)
            palette.putdata([0, 1])
            palette.putpalette([0, 0, 0, 255, 0, 0])
            rgbPalette := rgb.quantize(256, unset, 0, palette, stdlib.pillow.Image.Dither.NONE)
            AhkTest.AssertEqual([0, 0, 1, 0], rgbPalette.getdata())
            AhkTest.AssertEqual([0, 0, 0, 255, 0, 0], rgbPalette.getpalette("RGB"))

            gray := stdlib.pillow.Image.new("L", [4, 1], 0)
            gray.putdata([0, 10, 200, 255])
            grayDefault := gray.quantize(3)
            AhkTest.AssertEqual([2, 1, 0, 0], grayDefault.getdata())
            AhkTest.AssertEqual([228, 228, 228, 10, 10, 10, 0, 0, 0], grayDefault.getpalette("RGB"))

            rgba := stdlib.pillow.Image.new("RGBA", [3, 1], [0, 0, 0, 0])
            rgba.putpixel([0, 0], [10, 20, 30, 255])
            rgba.putpixel([1, 0], [200, 210, 220, 128])
            rgba.putpixel([2, 0], [1, 2, 3, 0])
            rgbaDefault := rgba.quantize()
            AhkTest.AssertEqual([2, 1, 0], rgbaDefault.getdata())
            AhkTest.AssertEqual([1, 2, 3, 200, 210, 220, 10, 20, 30], StdlibPillowTest.Take(rgbaDefault.getpalette("RGB"), 9))

            badPalette := stdlib.pillow.Image.new("RGB", [1, 1], [0, 0, 0])
            AhkTest.RaisesMatch(ValueError, "^Fast Octree \(method == 2\) and libimagequant \(method == 3\) are the only valid methods for quantizing RGBA images$", (*) => rgba.quantize(256, stdlib.pillow.Image.Quantize.MEDIANCUT))
            AhkTest.RaisesMatch(ValueError, "^bad mode for palette image$", (*) => rgb.quantize(256, unset, 0, badPalette))
            AhkTest.RaisesMatch(ValueError, "^only RGB or L mode images can be quantized to a palette$", (*) => rgba.quantize(256, unset, 0, palette))
            AhkTest.RaisesMatch(ValueError, "^kmeans must not be negative$", (*) => rgb.quantize(256, unset, -1))
            AhkTest.RaisesMatch(ValueError, "^bad number of colors$", (*) => rgb.quantize(257))
        } finally {
            if IsSet(badPalette)
                StdlibPillowTest.CloseImage(badPalette)
            if IsSet(rgbaDefault)
                StdlibPillowTest.CloseImage(rgbaDefault)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
            if IsSet(grayDefault)
                StdlibPillowTest.CloseImage(grayDefault)
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
            if IsSet(rgbPalette)
                StdlibPillowTest.CloseImage(rgbPalette)
            if IsSet(palette)
                StdlibPillowTest.CloseImage(palette)
            if IsSet(rgbTwo)
                StdlibPillowTest.CloseImage(rgbTwo)
            if IsSet(rgbDefaultAsRgb)
                StdlibPillowTest.CloseImage(rgbDefaultAsRgb)
            if IsSet(rgbDefault)
                StdlibPillowTest.CloseImage(rgbDefault)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
        }
    }

    static TestImageOpenKeepsRgbaPngAlphaLikeLocalPillow113()
    {
        path := StdlibPillowTest.TempPath("rgba.png")
        image := unset
        opened := unset
        converted := unset
        try {
            image := stdlib.pillow.Image.new("RGBA", [2, 2], [1, 2, 3, 4])
            image.putpixel([1, 0], [250, 20, 30, 128])
            image.putpixel([0, 1], [0, 0, 0, 0])
            image.putpixel([1, 1], [255, 255, 255, 255])
            AhkTest.AssertSame(stdlib.None, image.save(path))

            opened := stdlib.pillow.Image.open(path)
            AhkTest.AssertEqual("PNG", opened.format)
            AhkTest.AssertEqual("RGBA", opened.mode)
            AhkTest.AssertEqual([2, 2], opened.size)
            AhkTest.AssertEqual([
                [[1, 2, 3, 4], [250, 20, 30, 128]],
                [[0, 0, 0, 0], [255, 255, 255, 255]]
            ], StdlibPillowTest.PixelRows(opened))

            converted := opened.convert("RGB")
            AhkTest.AssertEqual("RGB", converted.mode)
            AhkTest.AssertEqual([
                [[1, 2, 3], [250, 20, 30]],
                [[0, 0, 0], [255, 255, 255]]
            ], StdlibPillowTest.PixelRows(converted))
        } finally {
            if IsSet(converted)
                StdlibPillowTest.CloseImage(converted)
            if IsSet(opened)
                StdlibPillowTest.CloseImage(opened)
            if IsSet(image)
                StdlibPillowTest.CloseImage(image)
            if FileExist(path)
                FileDelete path
        }
    }

    static TestImageBlendMatchesLocalPillow113()
    {
        rgbA := unset
        rgbB := unset
        rgbBlend := unset
        rgbNegative := unset
        rgbOverOne := unset
        rgbaA := unset
        rgbaB := unset
        rgbaBlend := unset
        grayA := unset
        grayB := unset
        grayBlend := unset
        sizeMismatch := unset
        modeMismatch := unset
        try {
            rgbA := stdlib.pillow.Image.new("RGB", [2, 1], [10, 20, 30])
            rgbA.putpixel([1, 0], [100, 110, 120])
            rgbB := stdlib.pillow.Image.new("RGB", [2, 1], [210, 220, 230])
            rgbB.putpixel([1, 0], [0, 10, 20])

            rgbBlend := stdlib.pillow.Image.blend(rgbA, rgbB, 0.25)
            AhkTest.AssertEqual("RGB", rgbBlend.mode)
            AhkTest.AssertEqual([2, 1], rgbBlend.size)
            AhkTest.AssertEqual([[[60, 70, 80], [75, 85, 95]]], StdlibPillowTest.PixelRows(rgbBlend))
            AhkTest.AssertEqual([[[10, 20, 30], [100, 110, 120]]], StdlibPillowTest.PixelRows(stdlib.pillow.Image.blend(rgbA, rgbB, 0)))
            AhkTest.AssertEqual([[[210, 220, 230], [0, 10, 20]]], StdlibPillowTest.PixelRows(stdlib.pillow.Image.blend(rgbA, rgbB, 1)))

            rgbNegative := stdlib.pillow.Image.blend(rgbA, rgbB, -0.5)
            AhkTest.AssertEqual([[[0, 0, 0], [150, 160, 170]]], StdlibPillowTest.PixelRows(rgbNegative))
            rgbOverOne := stdlib.pillow.Image.blend(rgbA, rgbB, 1.5)
            AhkTest.AssertEqual([[[255, 255, 255], [0, 0, 0]]], StdlibPillowTest.PixelRows(rgbOverOne))

            rgbaA := stdlib.pillow.Image.new("RGBA", [1, 1], [10, 20, 30, 40])
            rgbaB := stdlib.pillow.Image.new("RGBA", [1, 1], [110, 120, 130, 140])
            rgbaBlend := stdlib.pillow.Image.blend(rgbaA, rgbaB, 0.5)
            AhkTest.AssertEqual("RGBA", rgbaBlend.mode)
            AhkTest.AssertEqual([[[60, 70, 80, 90]]], StdlibPillowTest.PixelRows(rgbaBlend))

            grayA := stdlib.pillow.Image.new("L", [1, 2], 10)
            grayA.putpixel([0, 1], 100)
            grayB := stdlib.pillow.Image.new("L", [1, 2], 210)
            grayB.putpixel([0, 1], 0)
            grayBlend := stdlib.pillow.Image.blend(grayA, grayB, 0.25)
            AhkTest.AssertEqual("L", grayBlend.mode)
            AhkTest.AssertEqual([[60], [75]], StdlibPillowTest.PixelRows(grayBlend))

            sizeMismatch := stdlib.pillow.Image.new("RGB", [1, 1], [0, 0, 0])
            modeMismatch := stdlib.pillow.Image.new("L", [2, 1], 0)
            AhkTest.RaisesMatch(ValueError, "^images do not match$", (*) => stdlib.pillow.Image.blend(rgbA, sizeMismatch, 0.5))
            AhkTest.RaisesMatch(ValueError, "^images do not match$", (*) => stdlib.pillow.Image.blend(rgbA, modeMismatch, 0.5))
        } finally {
            if IsSet(modeMismatch)
                StdlibPillowTest.CloseImage(modeMismatch)
            if IsSet(sizeMismatch)
                StdlibPillowTest.CloseImage(sizeMismatch)
            if IsSet(grayBlend)
                StdlibPillowTest.CloseImage(grayBlend)
            if IsSet(grayB)
                StdlibPillowTest.CloseImage(grayB)
            if IsSet(grayA)
                StdlibPillowTest.CloseImage(grayA)
            if IsSet(rgbaBlend)
                StdlibPillowTest.CloseImage(rgbaBlend)
            if IsSet(rgbaB)
                StdlibPillowTest.CloseImage(rgbaB)
            if IsSet(rgbaA)
                StdlibPillowTest.CloseImage(rgbaA)
            if IsSet(rgbOverOne)
                StdlibPillowTest.CloseImage(rgbOverOne)
            if IsSet(rgbNegative)
                StdlibPillowTest.CloseImage(rgbNegative)
            if IsSet(rgbBlend)
                StdlibPillowTest.CloseImage(rgbBlend)
            if IsSet(rgbB)
                StdlibPillowTest.CloseImage(rgbB)
            if IsSet(rgbA)
                StdlibPillowTest.CloseImage(rgbA)
        }
    }

    static TestImageCompositeMasksMatchLocalPillow113()
    {
        rgbA := unset
        rgbB := unset
        lMask := unset
        rgbComposite := unset
        rgbaA := unset
        rgbaB := unset
        rgbaMask := unset
        rgbaComposite := unset
        smallImage := unset
        sizeMismatchComposite := unset
        modeMismatchImage := unset
        modeMismatchComposite := unset
        maskSizeMismatch := unset
        badMask := unset
        try {
            rgbA := stdlib.pillow.Image.new("RGB", [3, 1], [10, 20, 30])
            rgbA.putpixel([1, 0], [100, 110, 120])
            rgbA.putpixel([2, 0], [200, 210, 220])
            rgbB := stdlib.pillow.Image.new("RGB", [3, 1], [210, 220, 230])
            rgbB.putpixel([1, 0], [0, 10, 20])
            rgbB.putpixel([2, 0], [50, 60, 70])
            lMask := stdlib.pillow.Image.new("L", [3, 1], 0)
            lMask.putpixel([1, 0], 128)
            lMask.putpixel([2, 0], 255)

            rgbComposite := stdlib.pillow.Image.composite(rgbA, rgbB, lMask)
            AhkTest.AssertEqual("RGB", rgbComposite.mode)
            AhkTest.AssertEqual([3, 1], rgbComposite.size)
            AhkTest.AssertEqual([[[210, 220, 230], [50, 60, 70], [200, 210, 220]]], StdlibPillowTest.PixelRows(rgbComposite))

            rgbaA := stdlib.pillow.Image.new("RGBA", [2, 1], [10, 20, 30, 40])
            rgbaA.putpixel([1, 0], [100, 110, 120, 130])
            rgbaB := stdlib.pillow.Image.new("RGBA", [2, 1], [210, 220, 230, 240])
            rgbaB.putpixel([1, 0], [0, 10, 20, 30])
            rgbaMask := stdlib.pillow.Image.new("RGBA", [2, 1], [0, 0, 0, 0])
            rgbaMask.putpixel([1, 0], [255, 255, 255, 128])
            rgbaComposite := stdlib.pillow.Image.composite(rgbaA, rgbaB, rgbaMask)
            AhkTest.AssertEqual("RGBA", rgbaComposite.mode)
            AhkTest.AssertEqual([2, 1], rgbaComposite.size)
            AhkTest.AssertEqual([[[210, 220, 230, 240], [50, 60, 70, 80]]], StdlibPillowTest.PixelRows(rgbaComposite))

            smallImage := stdlib.pillow.Image.new("RGB", [1, 1], [9, 8, 7])
            sizeMismatchComposite := stdlib.pillow.Image.composite(rgbA, smallImage, lMask)
            AhkTest.AssertEqual("RGB", sizeMismatchComposite.mode)
            AhkTest.AssertEqual([1, 1], sizeMismatchComposite.size)
            AhkTest.AssertEqual([[[9, 8, 7]]], StdlibPillowTest.PixelRows(sizeMismatchComposite))

            modeMismatchImage := stdlib.pillow.Image.new("L", [3, 1], 7)
            modeMismatchComposite := stdlib.pillow.Image.composite(rgbA, modeMismatchImage, lMask)
            AhkTest.AssertEqual("L", modeMismatchComposite.mode)
            AhkTest.AssertEqual([3, 1], modeMismatchComposite.size)
            AhkTest.AssertEqual([[7, 58, 208]], StdlibPillowTest.PixelRows(modeMismatchComposite))

            maskSizeMismatch := stdlib.pillow.Image.new("L", [1, 1], 0)
            badMask := stdlib.pillow.Image.new("RGB", [3, 1], [0, 0, 0])
            AhkTest.RaisesMatch(ValueError, "^images do not match$", (*) => stdlib.pillow.Image.composite(rgbA, rgbB, maskSizeMismatch))
            AhkTest.RaisesMatch(ValueError, "^bad transparency mask$", (*) => stdlib.pillow.Image.composite(rgbA, rgbB, badMask))
        } finally {
            if IsSet(badMask)
                StdlibPillowTest.CloseImage(badMask)
            if IsSet(maskSizeMismatch)
                StdlibPillowTest.CloseImage(maskSizeMismatch)
            if IsSet(modeMismatchComposite)
                StdlibPillowTest.CloseImage(modeMismatchComposite)
            if IsSet(modeMismatchImage)
                StdlibPillowTest.CloseImage(modeMismatchImage)
            if IsSet(sizeMismatchComposite)
                StdlibPillowTest.CloseImage(sizeMismatchComposite)
            if IsSet(smallImage)
                StdlibPillowTest.CloseImage(smallImage)
            if IsSet(rgbaComposite)
                StdlibPillowTest.CloseImage(rgbaComposite)
            if IsSet(rgbaMask)
                StdlibPillowTest.CloseImage(rgbaMask)
            if IsSet(rgbaB)
                StdlibPillowTest.CloseImage(rgbaB)
            if IsSet(rgbaA)
                StdlibPillowTest.CloseImage(rgbaA)
            if IsSet(rgbComposite)
                StdlibPillowTest.CloseImage(rgbComposite)
            if IsSet(lMask)
                StdlibPillowTest.CloseImage(lMask)
            if IsSet(rgbB)
                StdlibPillowTest.CloseImage(rgbB)
            if IsSet(rgbA)
                StdlibPillowTest.CloseImage(rgbA)
        }
    }

    static TestImageAlphaCompositeMatchesLocalPillow113()
    {
        base := unset
        overlay := unset
        result := unset
        transparentBase := unset
        opaqueOverlay := unset
        opaqueBase := unset
        transparentOverlay := unset
        boundaryA := unset
        boundaryB := unset
        sizeMismatch := unset
        modeMismatch := unset
        try {
            base := stdlib.pillow.Image.new("RGBA", [3, 1], [10, 20, 30, 40])
            base.putpixel([1, 0], [100, 110, 120, 130])
            base.putpixel([2, 0], [200, 210, 220, 230])
            overlay := stdlib.pillow.Image.new("RGBA", [3, 1], [210, 220, 230, 240])
            overlay.putpixel([1, 0], [0, 10, 20, 30])
            overlay.putpixel([2, 0], [50, 60, 70, 0])

            result := stdlib.pillow.Image.alpha_composite(base, overlay)
            AhkTest.AssertEqual("RGBA", result.mode)
            AhkTest.AssertEqual([3, 1], result.size)
            AhkTest.AssertEqual([[[208, 218, 228, 242], [79, 89, 99, 145], [200, 210, 220, 230]]], StdlibPillowTest.PixelRows(result))

            transparentBase := stdlib.pillow.Image.new("RGBA", [1, 1], [1, 2, 3, 0])
            opaqueOverlay := stdlib.pillow.Image.new("RGBA", [1, 1], [9, 8, 7, 255])
            boundaryA := stdlib.pillow.Image.alpha_composite(transparentBase, opaqueOverlay)
            AhkTest.AssertEqual([[[9, 8, 7, 255]]], StdlibPillowTest.PixelRows(boundaryA))

            opaqueBase := stdlib.pillow.Image.new("RGBA", [1, 1], [1, 2, 3, 255])
            transparentOverlay := stdlib.pillow.Image.new("RGBA", [1, 1], [9, 8, 7, 0])
            boundaryB := stdlib.pillow.Image.alpha_composite(opaqueBase, transparentOverlay)
            AhkTest.AssertEqual([[[1, 2, 3, 255]]], StdlibPillowTest.PixelRows(boundaryB))

            sizeMismatch := stdlib.pillow.Image.new("RGBA", [1, 1], [0, 0, 0, 0])
            modeMismatch := stdlib.pillow.Image.new("RGB", [3, 1], [0, 0, 0])
            AhkTest.RaisesMatch(ValueError, "^images do not match$", (*) => stdlib.pillow.Image.alpha_composite(base, sizeMismatch))
            AhkTest.RaisesMatch(ValueError, "^images do not match$", (*) => stdlib.pillow.Image.alpha_composite(base, modeMismatch))
        } finally {
            if IsSet(modeMismatch)
                StdlibPillowTest.CloseImage(modeMismatch)
            if IsSet(sizeMismatch)
                StdlibPillowTest.CloseImage(sizeMismatch)
            if IsSet(boundaryB)
                StdlibPillowTest.CloseImage(boundaryB)
            if IsSet(transparentOverlay)
                StdlibPillowTest.CloseImage(transparentOverlay)
            if IsSet(opaqueBase)
                StdlibPillowTest.CloseImage(opaqueBase)
            if IsSet(boundaryA)
                StdlibPillowTest.CloseImage(boundaryA)
            if IsSet(opaqueOverlay)
                StdlibPillowTest.CloseImage(opaqueOverlay)
            if IsSet(transparentBase)
                StdlibPillowTest.CloseImage(transparentBase)
            if IsSet(result)
                StdlibPillowTest.CloseImage(result)
            if IsSet(overlay)
                StdlibPillowTest.CloseImage(overlay)
            if IsSet(base)
                StdlibPillowTest.CloseImage(base)
        }
    }

    static TestImageInstanceAlphaCompositeMatchesLocalPillow113()
    {
        base := unset
        overlay := unset
        partialBase := unset
        partialOverlay := unset
        clipBase := unset
        clipOverlay := unset
        badModeBase := unset
        badModeOverlay := unset
        try {
            base := stdlib.pillow.Image.new("RGBA", [2, 1], [10, 20, 30, 255])
            overlay := stdlib.pillow.Image.new("RGBA", [2, 1], [110, 120, 130, 128])
            AhkTest.AssertSame(stdlib.None, base.alpha_composite(overlay))
            AhkTest.AssertEqual([[60, 70, 80, 255], [60, 70, 80, 255]], base.getdata())

            partialBase := stdlib.pillow.Image.new("RGBA", [4, 3], [0, 0, 0, 0])
            partialOverlay := stdlib.pillow.Image.new("RGBA", [3, 2], [0, 0, 0, 0])
            partialOverlay.putpixel([1, 0], [200, 10, 20, 128])
            partialOverlay.putpixel([2, 1], [0, 200, 20, 255])
            AhkTest.AssertSame(stdlib.None, partialBase.alpha_composite(partialOverlay, [0, 1], [1, 0]))
            AhkTest.AssertEqual([
                [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
                [[200, 10, 20, 128], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [0, 200, 20, 255], [0, 0, 0, 0], [0, 0, 0, 0]],
            ], StdlibPillowTest.PixelRows(partialBase))

            clipBase := stdlib.pillow.Image.new("RGBA", [2, 2], [0, 0, 0, 0])
            clipOverlay := stdlib.pillow.Image.new("RGBA", [2, 2], [255, 0, 0, 255])
            AhkTest.AssertSame(stdlib.None, clipBase.alpha_composite(clipOverlay, [1, 1]))
            AhkTest.AssertEqual([
                [[0, 0, 0, 0], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [255, 0, 0, 255]],
            ], StdlibPillowTest.PixelRows(clipBase))

            badModeBase := stdlib.pillow.Image.new("RGB", [1, 1], [0, 0, 0])
            badModeOverlay := stdlib.pillow.Image.new("RGB", [1, 1], [0, 0, 0])
            AhkTest.RaisesMatch(ValueError, "^image has wrong mode$", (*) => badModeBase.alpha_composite(overlay))
            AhkTest.RaisesMatch(ValueError, "^images do not match$", (*) => base.alpha_composite(badModeOverlay))
            AhkTest.RaisesMatch(ValueError, "^Destination must be a sequence of length 2$", (*) => base.alpha_composite(overlay, [0]))
            AhkTest.RaisesMatch(ValueError, "^Source must be a sequence of length 2 or 4$", (*) => base.alpha_composite(overlay, [0, 0], [0]))
            AhkTest.RaisesMatch(ValueError, "^Source must be non-negative$", (*) => base.alpha_composite(overlay, [0, 0], [-1, 0]))
        } finally {
            if IsSet(badModeOverlay)
                StdlibPillowTest.CloseImage(badModeOverlay)
            if IsSet(badModeBase)
                StdlibPillowTest.CloseImage(badModeBase)
            if IsSet(clipOverlay)
                StdlibPillowTest.CloseImage(clipOverlay)
            if IsSet(clipBase)
                StdlibPillowTest.CloseImage(clipBase)
            if IsSet(partialOverlay)
                StdlibPillowTest.CloseImage(partialOverlay)
            if IsSet(partialBase)
                StdlibPillowTest.CloseImage(partialBase)
            if IsSet(overlay)
                StdlibPillowTest.CloseImage(overlay)
            if IsSet(base)
                StdlibPillowTest.CloseImage(base)
        }
    }

    static TestImagePasteMatchesLocalPillow113()
    {
        colorTarget := unset
        imageTarget := unset
        patch := unset
        maskTarget := unset
        maskPatch := unset
        lMask := unset
        rgbaMaskTarget := unset
        rgbaPatch := unset
        rgbaMask := unset
        sizeMismatchTarget := unset
        sizeMismatchPatch := unset
        badMask := unset
        try {
            colorTarget := stdlib.pillow.Image.new("RGB", [4, 3], [10, 20, 30])
            AhkTest.AssertSame(stdlib.None, colorTarget.paste([200, 100, 50], [1, 1, 3, 3]))
            AhkTest.AssertEqual([
                [[10, 20, 30], [10, 20, 30], [10, 20, 30], [10, 20, 30]],
                [[10, 20, 30], [200, 100, 50], [200, 100, 50], [10, 20, 30]],
                [[10, 20, 30], [200, 100, 50], [200, 100, 50], [10, 20, 30]]
            ], StdlibPillowTest.PixelRows(colorTarget))

            imageTarget := stdlib.pillow.Image.new("RGB", [4, 3], [10, 20, 30])
            patch := stdlib.pillow.Image.new("RGB", [2, 2], [200, 100, 50])
            patch.putpixel([1, 0], [0, 10, 20])
            AhkTest.AssertSame(stdlib.None, imageTarget.paste(patch, [1, 1]))
            AhkTest.AssertEqual([
                [[10, 20, 30], [10, 20, 30], [10, 20, 30], [10, 20, 30]],
                [[10, 20, 30], [200, 100, 50], [0, 10, 20], [10, 20, 30]],
                [[10, 20, 30], [200, 100, 50], [200, 100, 50], [10, 20, 30]]
            ], StdlibPillowTest.PixelRows(imageTarget))

            maskTarget := stdlib.pillow.Image.new("RGB", [3, 1], [10, 20, 30])
            maskPatch := stdlib.pillow.Image.new("RGB", [3, 1], [210, 220, 230])
            maskPatch.putpixel([1, 0], [0, 10, 20])
            lMask := stdlib.pillow.Image.new("L", [3, 1], 0)
            lMask.putpixel([1, 0], 128)
            lMask.putpixel([2, 0], 255)
            AhkTest.AssertSame(stdlib.None, maskTarget.paste(maskPatch, [0, 0], lMask))
            AhkTest.AssertEqual([[[10, 20, 30], [5, 15, 25], [210, 220, 230]]], StdlibPillowTest.PixelRows(maskTarget))

            rgbaMaskTarget := stdlib.pillow.Image.new("RGBA", [2, 1], [10, 20, 30, 40])
            rgbaPatch := stdlib.pillow.Image.new("RGBA", [2, 1], [210, 220, 230, 240])
            rgbaPatch.putpixel([1, 0], [0, 10, 20, 30])
            rgbaMask := stdlib.pillow.Image.new("RGBA", [2, 1], [0, 0, 0, 0])
            rgbaMask.putpixel([1, 0], [255, 255, 255, 128])
            AhkTest.AssertSame(stdlib.None, rgbaMaskTarget.paste(rgbaPatch, [0, 0], rgbaMask))
            AhkTest.AssertEqual([[[10, 20, 30, 40], [5, 15, 25, 35]]], StdlibPillowTest.PixelRows(rgbaMaskTarget))

            sizeMismatchTarget := stdlib.pillow.Image.new("RGB", [2, 1], [10, 20, 30])
            sizeMismatchPatch := stdlib.pillow.Image.new("RGB", [3, 1], [200, 100, 50])
            AhkTest.AssertSame(stdlib.None, sizeMismatchTarget.paste(sizeMismatchPatch, [0, 0]))
            AhkTest.AssertEqual([[[200, 100, 50], [200, 100, 50]]], StdlibPillowTest.PixelRows(sizeMismatchTarget))

            badMask := stdlib.pillow.Image.new("RGB", [2, 1], [0, 0, 0])
            AhkTest.RaisesMatch(ValueError, "^bad transparency mask$", (*) => sizeMismatchTarget.paste(sizeMismatchPatch, [0, 0], badMask))
            AhkTest.RaisesMatch(TypeError, "^argument 2 must be sequence of length 4, not 5$", (*) => colorTarget.paste([1, 2, 3], [0, 0, 1, 1, 1]))
        } finally {
            if IsSet(badMask)
                StdlibPillowTest.CloseImage(badMask)
            if IsSet(sizeMismatchPatch)
                StdlibPillowTest.CloseImage(sizeMismatchPatch)
            if IsSet(sizeMismatchTarget)
                StdlibPillowTest.CloseImage(sizeMismatchTarget)
            if IsSet(rgbaMask)
                StdlibPillowTest.CloseImage(rgbaMask)
            if IsSet(rgbaPatch)
                StdlibPillowTest.CloseImage(rgbaPatch)
            if IsSet(rgbaMaskTarget)
                StdlibPillowTest.CloseImage(rgbaMaskTarget)
            if IsSet(lMask)
                StdlibPillowTest.CloseImage(lMask)
            if IsSet(maskPatch)
                StdlibPillowTest.CloseImage(maskPatch)
            if IsSet(maskTarget)
                StdlibPillowTest.CloseImage(maskTarget)
            if IsSet(patch)
                StdlibPillowTest.CloseImage(patch)
            if IsSet(imageTarget)
                StdlibPillowTest.CloseImage(imageTarget)
            if IsSet(colorTarget)
                StdlibPillowTest.CloseImage(colorTarget)
        }
    }

    static TestImageChannelsAndPutAlphaMatchLocalPillow113()
    {
        rgb := unset
        rgba := unset
        gray := unset
        green := unset
        alpha := unset
        blue := unset
        grayChannel := unset
        rgbAlphaConst := unset
        rgbAlphaImage := unset
        alphaImage := unset
        rgbaAlphaConst := unset
        lAlphaConst := unset
        badAlphaSize := unset
        badAlphaMode := unset
        try {
            rgb := stdlib.pillow.Image.new("RGB", [2, 1], [10, 20, 30])
            rgb.putpixel([1, 0], [100, 110, 120])
            rgba := stdlib.pillow.Image.new("RGBA", [2, 1], [10, 20, 30, 40])
            rgba.putpixel([1, 0], [100, 110, 120, 130])
            gray := stdlib.pillow.Image.new("L", [2, 1], 10)
            gray.putpixel([1, 0], 100)

            green := rgb.getchannel("G")
            AhkTest.AssertEqual("L", green.mode)
            AhkTest.AssertEqual([2, 1], green.size)
            AhkTest.AssertEqual([[20, 110]], StdlibPillowTest.PixelRows(green))
            alpha := rgba.getchannel("A")
            AhkTest.AssertEqual([[40, 130]], StdlibPillowTest.PixelRows(alpha))
            blue := rgb.getchannel(2)
            AhkTest.AssertEqual([[30, 120]], StdlibPillowTest.PixelRows(blue))
            grayChannel := gray.getchannel(0)
            AhkTest.AssertEqual([[10, 100]], StdlibPillowTest.PixelRows(grayChannel))
            AhkTest.RaisesMatch(ValueError, '^The image has no channel "A"$', (*) => rgb.getchannel("A"))
            AhkTest.RaisesMatch(ValueError, "^band index out of range$", (*) => rgb.getchannel(9))

            rgbAlphaConst := rgb.copy()
            AhkTest.AssertSame(stdlib.None, rgbAlphaConst.putalpha(128))
            AhkTest.AssertEqual("RGBA", rgbAlphaConst.mode)
            AhkTest.AssertEqual([[[10, 20, 30, 128], [100, 110, 120, 128]]], StdlibPillowTest.PixelRows(rgbAlphaConst))

            rgbAlphaImage := rgb.copy()
            alphaImage := stdlib.pillow.Image.new("L", [2, 1], 0)
            alphaImage.putpixel([1, 0], 255)
            AhkTest.AssertSame(stdlib.None, rgbAlphaImage.putalpha(alphaImage))
            AhkTest.AssertEqual("RGBA", rgbAlphaImage.mode)
            AhkTest.AssertEqual([[[10, 20, 30, 0], [100, 110, 120, 255]]], StdlibPillowTest.PixelRows(rgbAlphaImage))

            rgbaAlphaConst := rgba.copy()
            AhkTest.AssertSame(stdlib.None, rgbaAlphaConst.putalpha(64))
            AhkTest.AssertEqual("RGBA", rgbaAlphaConst.mode)
            AhkTest.AssertEqual([[[10, 20, 30, 64], [100, 110, 120, 64]]], StdlibPillowTest.PixelRows(rgbaAlphaConst))

            lAlphaConst := gray.copy()
            AhkTest.AssertSame(stdlib.None, lAlphaConst.putalpha(200))
            AhkTest.AssertEqual("LA", lAlphaConst.mode)
            AhkTest.AssertEqual([[[10, 200], [100, 200]]], StdlibPillowTest.PixelRows(lAlphaConst))

            badAlphaSize := stdlib.pillow.Image.new("L", [1, 1], 0)
            badAlphaMode := stdlib.pillow.Image.new("RGB", [2, 1], [0, 0, 0])
            AhkTest.RaisesMatch(ValueError, "^images do not match$", (*) => rgb.copy().putalpha(badAlphaSize))
            AhkTest.RaisesMatch(ValueError, "^illegal image mode$", (*) => rgb.copy().putalpha(badAlphaMode))
        } finally {
            if IsSet(badAlphaMode)
                StdlibPillowTest.CloseImage(badAlphaMode)
            if IsSet(badAlphaSize)
                StdlibPillowTest.CloseImage(badAlphaSize)
            if IsSet(lAlphaConst)
                StdlibPillowTest.CloseImage(lAlphaConst)
            if IsSet(rgbaAlphaConst)
                StdlibPillowTest.CloseImage(rgbaAlphaConst)
            if IsSet(alphaImage)
                StdlibPillowTest.CloseImage(alphaImage)
            if IsSet(rgbAlphaImage)
                StdlibPillowTest.CloseImage(rgbAlphaImage)
            if IsSet(rgbAlphaConst)
                StdlibPillowTest.CloseImage(rgbAlphaConst)
            if IsSet(grayChannel)
                StdlibPillowTest.CloseImage(grayChannel)
            if IsSet(blue)
                StdlibPillowTest.CloseImage(blue)
            if IsSet(alpha)
                StdlibPillowTest.CloseImage(alpha)
            if IsSet(green)
                StdlibPillowTest.CloseImage(green)
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
        }
    }

    static TestImageSplitAndMergeMatchLocalPillow113()
    {
        rgb := unset
        rgba := unset
        gray := unset
        la := unset
        rgbBands := unset
        rgbaBands := unset
        laBands := unset
        mergedRgb := unset
        mergedRgba := unset
        mergedLa := unset
        wrongSize := unset
        try {
            rgb := stdlib.pillow.Image.new("RGB", [2, 1], [10, 20, 30])
            rgb.putpixel([1, 0], [100, 110, 120])
            rgba := stdlib.pillow.Image.new("RGBA", [2, 1], [10, 20, 30, 40])
            rgba.putpixel([1, 0], [100, 110, 120, 130])
            gray := stdlib.pillow.Image.new("L", [2, 1], 10)
            gray.putpixel([1, 0], 100)
            la := gray.copy()
            la.putalpha(200)

            rgbBands := rgb.split()
            AhkTest.AssertTrue(rgbBands is AhkStdlibTuple)
            AhkTest.AssertEqual(3, rgbBands.Length)
            AhkTest.AssertEqual([[10, 100]], StdlibPillowTest.PixelRows(rgbBands[1]))
            AhkTest.AssertEqual([[20, 110]], StdlibPillowTest.PixelRows(rgbBands[2]))
            AhkTest.AssertEqual([[30, 120]], StdlibPillowTest.PixelRows(rgbBands[3]))

            rgbaBands := rgba.split()
            AhkTest.AssertEqual(4, rgbaBands.Length)
            AhkTest.AssertEqual([[40, 130]], StdlibPillowTest.PixelRows(rgbaBands[4]))
            laBands := la.split()
            AhkTest.AssertEqual(2, laBands.Length)
            AhkTest.AssertEqual([[10, 100]], StdlibPillowTest.PixelRows(laBands[1]))
            AhkTest.AssertEqual([[200, 200]], StdlibPillowTest.PixelRows(laBands[2]))

            mergedRgb := stdlib.pillow.Image.merge("RGB", rgbBands)
            AhkTest.AssertEqual("RGB", mergedRgb.mode)
            AhkTest.AssertEqual([[[10, 20, 30], [100, 110, 120]]], StdlibPillowTest.PixelRows(mergedRgb))
            mergedRgba := stdlib.pillow.Image.merge("RGBA", rgbaBands)
            AhkTest.AssertEqual("RGBA", mergedRgba.mode)
            AhkTest.AssertEqual([[[10, 20, 30, 40], [100, 110, 120, 130]]], StdlibPillowTest.PixelRows(mergedRgba))
            mergedLa := stdlib.pillow.Image.merge("LA", laBands)
            AhkTest.AssertEqual("LA", mergedLa.mode)
            AhkTest.AssertEqual([[[10, 200], [100, 200]]], StdlibPillowTest.PixelRows(mergedLa))

            wrongSize := stdlib.pillow.Image.new("L", [1, 1], 0)
            AhkTest.RaisesMatch(ValueError, "^wrong number of bands$", (*) => stdlib.pillow.Image.merge("RGB", [rgbBands[1], rgbBands[2]]))
            AhkTest.RaisesMatch(ValueError, "^mode mismatch$", (*) => stdlib.pillow.Image.merge("RGB", [rgbBands[1], rgbBands[2], rgba]))
            AhkTest.RaisesMatch(ValueError, "^size mismatch$", (*) => stdlib.pillow.Image.merge("RGB", [rgbBands[1], wrongSize, rgbBands[3]]))
            AhkTest.RaisesMatch(KeyError, "^'BAD'$", (*) => stdlib.pillow.Image.merge("BAD", rgbBands))
        } finally {
            if IsSet(wrongSize)
                StdlibPillowTest.CloseImage(wrongSize)
            if IsSet(mergedLa)
                StdlibPillowTest.CloseImage(mergedLa)
            if IsSet(mergedRgba)
                StdlibPillowTest.CloseImage(mergedRgba)
            if IsSet(mergedRgb)
                StdlibPillowTest.CloseImage(mergedRgb)
            if IsSet(laBands) {
                for band in laBands
                    StdlibPillowTest.CloseImage(band)
            }
            if IsSet(rgbaBands) {
                for band in rgbaBands
                    StdlibPillowTest.CloseImage(band)
            }
            if IsSet(rgbBands) {
                for band in rgbBands
                    StdlibPillowTest.CloseImage(band)
            }
            if IsSet(la)
                StdlibPillowTest.CloseImage(la)
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
        }
    }

    static TestImagePointAndEvalMatchLocalPillow113()
    {
        gray := unset
        rgb := unset
        rgba := unset
        la := unset
        lCallable := unset
        lTable := unset
        rgbCallable := unset
        rgbTableResult := unset
        rgbaCallable := unset
        laCallable := unset
        lToRgb := unset
        evalGray := unset
        evalRgb := unset
        countGray := unset
        countRgb := unset
        countEval := unset
        countGrayResult := unset
        countRgbResult := unset
        countEvalResult := unset
        try {
            gray := stdlib.pillow.Image.new("L", [3, 1], 0)
            gray.putpixel([1, 0], 120)
            gray.putpixel([2, 0], 250)
            rgb := stdlib.pillow.Image.new("RGB", [2, 1], [10, 20, 30])
            rgb.putpixel([1, 0], [100, 110, 120])
            rgba := stdlib.pillow.Image.new("RGBA", [2, 1], [10, 20, 30, 40])
            rgba.putpixel([1, 0], [100, 110, 120, 130])
            la := stdlib.pillow.Image.new("LA", [2, 1], [10, 20])
            la.putpixel([1, 0], [100, 200])

            lCallable := gray.point((value) => value + 10)
            AhkTest.AssertEqual("L", lCallable.mode)
            AhkTest.AssertEqual([[10, 130, 255]], StdlibPillowTest.PixelRows(lCallable))

            table := StdlibPillowTest.RangeTable()
            table[1] := 9
            table[121] := 77
            table[251] := 1
            lTable := gray.point(table)
            AhkTest.AssertEqual([[9, 77, 1]], StdlibPillowTest.PixelRows(lTable))

            rgbCallable := rgb.point((value) => value + 5)
            AhkTest.AssertEqual([[[15, 25, 35], [105, 115, 125]]], StdlibPillowTest.PixelRows(rgbCallable))
            rgbaCallable := rgba.point((value) => value + 5)
            AhkTest.AssertEqual([[[15, 25, 35, 45], [105, 115, 125, 135]]], StdlibPillowTest.PixelRows(rgbaCallable))
            laCallable := la.point((value) => value + 5)
            AhkTest.AssertEqual([[[15, 25], [105, 205]]], StdlibPillowTest.PixelRows(laCallable))

            rgbTable := StdlibPillowTest.RangeTable()
            for value in StdlibPillowTest.RangeTable()
                rgbTable.Push(Min(255, value + 1))
            for value in StdlibPillowTest.RangeTable()
                rgbTable.Push(255 - value)
            rgbTableResult := rgb.point(rgbTable)
            AhkTest.AssertEqual([[[10, 21, 225], [100, 111, 135]]], StdlibPillowTest.PixelRows(rgbTableResult))

            lToRgbTable := table.Clone()
            for value in StdlibPillowTest.RangeTable()
                lToRgbTable.Push(Min(255, value + 1))
            for value in StdlibPillowTest.RangeTable()
                lToRgbTable.Push(255 - value)
            lToRgb := gray.point(lToRgbTable, "RGB")
            AhkTest.AssertEqual("RGB", lToRgb.mode)
            AhkTest.AssertEqual([[[9, 1, 255], [77, 121, 135], [1, 251, 5]]], StdlibPillowTest.PixelRows(lToRgb))

            evalGray := stdlib.pillow.Image.eval(gray, (value) => 255 - value)
            AhkTest.AssertEqual([[255, 135, 5]], StdlibPillowTest.PixelRows(evalGray))
            evalRgb := stdlib.pillow.Image.eval(rgb, (value) => value * 2)
            AhkTest.AssertEqual([[[20, 40, 60], [200, 220, 240]]], StdlibPillowTest.PixelRows(evalRgb))

            countGray := StdlibPillowPointCounter()
            countRgb := StdlibPillowPointCounter()
            countEval := StdlibPillowPointCounter()
            countGrayResult := gray.point(countGray)
            countRgbResult := rgb.point(countRgb)
            countEvalResult := stdlib.pillow.Image.eval(gray, countEval)
            AhkTest.AssertEqual(256, countGray.Calls.Length)
            AhkTest.AssertEqual(256, countRgb.Calls.Length)
            AhkTest.AssertEqual(256, countEval.Calls.Length)
            AhkTest.AssertEqual([0, 1, 2, 3, 4], [countGray.Calls[1], countGray.Calls[2], countGray.Calls[3], countGray.Calls[4], countGray.Calls[5]])
            AhkTest.AssertEqual([251, 252, 253, 254, 255], [countGray.Calls[252], countGray.Calls[253], countGray.Calls[254], countGray.Calls[255], countGray.Calls[256]])
            AhkTest.AssertEqual([[0, 120, 250]], StdlibPillowTest.PixelRows(countGrayResult))
            AhkTest.AssertEqual([[[10, 20, 30], [100, 110, 120]]], StdlibPillowTest.PixelRows(countRgbResult))
            AhkTest.AssertEqual([[0, 120, 250]], StdlibPillowTest.PixelRows(countEvalResult))

            AhkTest.RaisesMatch(TypeError, "^'NoneType' object is not iterable$", (*) => gray.point(stdlib.None))
            AhkTest.RaisesMatch(ValueError, "^wrong number of lut entries$", (*) => gray.point([1, 2, 3]))
            AhkTest.RaisesMatch(ValueError, "^wrong number of lut entries$", (*) => gray.point((value) => value, "RGB"))
            AhkTest.RaisesMatch(ValueError, "^unrecognized image mode$", (*) => gray.point((value) => value, "BAD"))
            AhkTest.RaisesMatch(TypeError, "^'NoneType' object is not iterable$", (*) => stdlib.pillow.Image.eval(gray, stdlib.None))
        } finally {
            for image in [
                countEvalResult?, countRgbResult?, countGrayResult?, evalRgb?, evalGray?,
                lToRgb?, laCallable?, rgbaCallable?, rgbTableResult?, rgbCallable?, lTable?,
                lCallable?, la?, rgba?, rgb?, gray?
            ] {
                if IsSet(image)
                    StdlibPillowTest.CloseImage(image)
            }
        }
    }

    static TestImageFilterAndKernelMatchLocalPillow113()
    {
        gray5 := unset
        rgb5 := unset
        rgba5 := unset
        blur := unset
        contour := unset
        detail := unset
        edgeEnhance := unset
        edgeEnhanceMore := unset
        emboss := unset
        findEdges := unset
        sharpen := unset
        smooth := unset
        smoothMore := unset
        rgbSharpen := unset
        rgbaBlur := unset
        kernelIdentity := unset
        kernelSum := unset
        kernelOffset := unset
        badSizeKernel := unset
        try {
            AhkTest.AssertTrue(HasProp(stdlib.pillow, "ImageFilter"))
            AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageFilter, "Kernel"))

            gray5 := StdlibPillowTest.FilterSourceImage("L")
            rgb5 := StdlibPillowTest.FilterSourceImage("RGB")
            rgba5 := StdlibPillowTest.FilterSourceImage("RGBA")

            blur := gray5.filter(stdlib.pillow.ImageFilter.BLUR)
            contour := gray5.filter(stdlib.pillow.ImageFilter.CONTOUR)
            detail := gray5.filter(stdlib.pillow.ImageFilter.DETAIL)
            edgeEnhance := gray5.filter(stdlib.pillow.ImageFilter.EDGE_ENHANCE)
            edgeEnhanceMore := gray5.filter(stdlib.pillow.ImageFilter.EDGE_ENHANCE_MORE)
            emboss := gray5.filter(stdlib.pillow.ImageFilter.EMBOSS)
            findEdges := gray5.filter(stdlib.pillow.ImageFilter.FIND_EDGES)
            sharpen := gray5.filter(stdlib.pillow.ImageFilter.SHARPEN)
            smooth := gray5.filter(stdlib.pillow.ImageFilter.SMOOTH)
            smoothMore := gray5.filter(stdlib.pillow.ImageFilter.SMOOTH_MORE)

            AhkTest.AssertEqual("L", blur.mode)
            AhkTest.AssertEqual([5, 5], blur.size)
            AhkTest.AssertEqual(0, blur.getpixel([0, 0]))
            AhkTest.AssertEqual(85, blur.getpixel([2, 2]))
            AhkTest.AssertEqual(153, contour.getpixel([1, 1]))
            AhkTest.AssertEqual(255, contour.getpixel([2, 2]))
            AhkTest.AssertEqual(203, detail.getpixel([2, 2]))
            AhkTest.AssertEqual(46, edgeEnhance.getpixel([1, 2]))
            AhkTest.AssertEqual(255, edgeEnhanceMore.getpixel([2, 2]))
            AhkTest.AssertEqual(157, emboss.getpixel([2, 2]))
            AhkTest.AssertEqual(154, findEdges.getpixel([2, 1]))
            AhkTest.AssertEqual(217, sharpen.getpixel([2, 2]))
            AhkTest.AssertEqual(134, smooth.getpixel([2, 2]))
            AhkTest.AssertEqual(133, smoothMore.getpixel([2, 2]))

            rgbSharpen := rgb5.filter(stdlib.pillow.ImageFilter.SHARPEN)
            AhkTest.AssertEqual("RGB", rgbSharpen.mode)
            AhkTest.AssertEqual([217, 130, 105], rgbSharpen.getpixel([2, 2]))
            AhkTest.AssertEqual([255, 150, 255], rgbSharpen.getpixel([2, 3]))
            rgbaBlur := rgba5.filter(stdlib.pillow.ImageFilter.BLUR)
            AhkTest.AssertEqual("RGBA", rgbaBlur.mode)
            AhkTest.AssertEqual([85, 114, 89, 120], rgbaBlur.getpixel([2, 2]))

            kernelIdentity := gray5.filter(stdlib.pillow.ImageFilter.Kernel([3, 3], [0, 0, 0, 0, 1, 0, 0, 0, 0]))
            AhkTest.AssertEqual(166, kernelIdentity.getpixel([2, 2]))
            kernelSum := gray5.filter(stdlib.pillow.ImageFilter.Kernel([3, 3], [1, 1, 1, 1, 1, 1, 1, 1, 1], 9))
            AhkTest.AssertEqual(120, kernelSum.getpixel([2, 2]))
            kernelOffset := gray5.filter(stdlib.pillow.ImageFilter.Kernel([3, 3], [0, 0, 0, 0, 1, 0, 0, 0, 0], unset, 10))
            AhkTest.AssertEqual(176, kernelOffset.getpixel([2, 2]))

            badSizeKernel := stdlib.pillow.ImageFilter.Kernel([2, 2], [1, 1, 1, 1])
            AhkTest.RaisesMatch(ValueError, "^bad kernel size$", (*) => gray5.filter(badSizeKernel))
            AhkTest.RaisesMatch(ValueError, "^not enough coefficients in kernel$", (*) => stdlib.pillow.ImageFilter.Kernel([3, 3], [1, 2, 3]))
            AhkTest.RaisesMatch(TypeError, "^filter argument should be ImageFilter\.Filter instance or class$", (*) => gray5.filter(stdlib.None))
            AhkTest.RaisesMatch(TypeError, "^filter argument should be ImageFilter\.Filter instance or class$", (*) => gray5.filter({}))
        } finally {
            for image in [
                badSizeKernel?, kernelOffset?, kernelSum?, kernelIdentity?, rgbaBlur?,
                rgbSharpen?, smoothMore?, smooth?, sharpen?, findEdges?, emboss?,
                edgeEnhanceMore?, edgeEnhance?, detail?, contour?, blur?,
                rgba5?, rgb5?, gray5?
            ] {
                if IsSet(image) && IsObject(image) && image.HasOwnProp("AhkStdlibHandle")
                    StdlibPillowTest.CloseImage(image)
            }
        }
    }

    static TestImageFilterBaseClassesMatchLocalPillow113()
    {
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "ImageFilter"))
        AhkTest.AssertEqual("AhkStdlibPillowImageFilterFilter", stdlib.pillow.ImageFilter.Filter.Prototype.__Class)
        AhkTest.AssertEqual("AhkStdlibPillowImageFilterMultibandFilter", stdlib.pillow.ImageFilter.MultibandFilter.Prototype.__Class)
        AhkTest.AssertEqual("AhkStdlibPillowImageFilterBuiltinFilter", stdlib.pillow.ImageFilter.BuiltinFilter.Prototype.__Class)

        AhkTest.RaisesMatch(TypeError, "^Can't instantiate abstract class Filter with abstract method filter$", (*) => stdlib.pillow.ImageFilter.Filter())
        AhkTest.RaisesMatch(TypeError, "^Filter\(\) takes no arguments$", (*) => stdlib.pillow.ImageFilter.Filter(1))
        AhkTest.RaisesMatch(TypeError, "^Can't instantiate abstract class MultibandFilter with abstract method filter$", (*) => stdlib.pillow.ImageFilter.MultibandFilter())
        AhkTest.RaisesMatch(TypeError, "^MultibandFilter\(\) takes no arguments$", (*) => stdlib.pillow.ImageFilter.MultibandFilter(1))

        builtin := stdlib.pillow.ImageFilter.BuiltinFilter()
        image := unset
        try {
            AhkTest.AssertEqual("AhkStdlibPillowImageFilterBuiltinFilter", Type(builtin))
            image := stdlib.pillow.Image.new("L", [1, 1], 7)
            AhkTest.RaisesMatch(TypeError, "^BuiltinFilter\(\) takes no arguments$", (*) => stdlib.pillow.ImageFilter.BuiltinFilter(1))
            AhkTest.RaisesMatch(TypeError, "^BuiltinFilter\.filter\(\) missing 1 required positional argument: 'image'$", (*) => builtin.filter())
            AhkTest.RaisesMatch(AttributeError, "^'BuiltinFilter' object has no attribute 'filterargs'$", (*) => builtin.filter(image))
            AhkTest.RaisesMatch(TypeError, "^BuiltinFilter\.filter\(\) takes 2 positional arguments but 3 were given$", (*) => builtin.filter(image, image))
        } finally {
            if IsSet(image)
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestImageFilterRankFamilyMatchesLocalPillow113()
    {
        gray5 := unset
        rgb5 := unset
        rgba5 := unset
        flat := unset
        modeSource := unset
        outputs := []
        try {
            AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageFilter, "RankFilter"))
            AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageFilter, "MinFilter"))
            AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageFilter, "MaxFilter"))
            AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageFilter, "MedianFilter"))
            AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageFilter, "ModeFilter"))

            rankFilter := stdlib.pillow.ImageFilter.RankFilter(3, 4)
            AhkTest.AssertEqual(3, rankFilter.size)
            AhkTest.AssertEqual(4, rankFilter.rank)
            AhkTest.AssertEqual(3, stdlib.pillow.ImageFilter.MinFilter().size)
            AhkTest.AssertEqual(0, stdlib.pillow.ImageFilter.MinFilter().rank)
            AhkTest.AssertEqual(8, stdlib.pillow.ImageFilter.MaxFilter().rank)
            AhkTest.AssertEqual(4, stdlib.pillow.ImageFilter.MedianFilter().rank)
            AhkTest.AssertEqual(3, stdlib.pillow.ImageFilter.ModeFilter().size)

            gray5 := StdlibPillowTest.FilterSourceImage("L")
            rgb5 := StdlibPillowTest.FilterSourceImage("RGB")
            rgba5 := StdlibPillowTest.FilterSourceImage("RGBA")

            minGray := gray5.filter(stdlib.pillow.ImageFilter.MinFilter(3))
            outputs.Push(minGray)
            AhkTest.AssertEqual([
                [0, 0, 17, 16, 16],
                [0, 0, 13, 13, 13],
                [31, 31, 13, 13, 13],
                [62, 8, 8, 8, 13],
                [93, 8, 8, 8, 28],
            ], StdlibPillowTest.PixelRows(minGray))

            maxGray := gray5.filter(stdlib.pillow.ImageFilter.MaxFilter(3))
            outputs.Push(maxGray)
            AhkTest.AssertEqual([
                [57, 117, 211, 211, 211],
                [97, 166, 211, 211, 211],
                [137, 215, 215, 217, 217],
                [177, 215, 215, 217, 217],
                [177, 215, 215, 217, 217],
            ], StdlibPillowTest.PixelRows(maxGray))

            medianGray := gray5.filter(stdlib.pillow.ImageFilter.MedianFilter(3))
            outputs.Push(medianGray)
            AhkTest.AssertEqual([
                [17, 31, 68, 83, 83],
                [31, 62, 97, 117, 83],
                [62, 97, 117, 150, 150],
                [97, 124, 129, 129, 129],
                [124, 124, 129, 71, 71],
            ], StdlibPillowTest.PixelRows(medianGray))

            rank4Gray := gray5.filter(stdlib.pillow.ImageFilter.RankFilter(3, 4))
            outputs.Push(rank4Gray)
            AhkTest.AssertEqual(StdlibPillowTest.PixelRows(medianGray), StdlibPillowTest.PixelRows(rank4Gray))
            rank8Gray := gray5.filter(stdlib.pillow.ImageFilter.RankFilter(3, 8))
            outputs.Push(rank8Gray)
            AhkTest.AssertEqual(StdlibPillowTest.PixelRows(maxGray), StdlibPillowTest.PixelRows(rank8Gray))

            modeGray := gray5.filter(stdlib.pillow.ImageFilter.ModeFilter(3))
            outputs.Push(modeGray)
            AhkTest.AssertEqual(StdlibPillowTest.PixelRows(gray5), StdlibPillowTest.PixelRows(modeGray))

            rgbMin := rgb5.filter(stdlib.pillow.ImageFilter.MinFilter(3))
            outputs.Push(rgbMin)
            AhkTest.AssertEqual([13, 65, 38], rgbMin.getpixel([2, 2]))
            rgbMax := rgb5.filter(stdlib.pillow.ImageFilter.MaxFilter(3))
            outputs.Push(rgbMax)
            AhkTest.AssertEqual([215, 195, 252], rgbMax.getpixel([2, 2]))
            rgbMedian := rgb5.filter(stdlib.pillow.ImageFilter.MedianFilter(3))
            outputs.Push(rgbMedian)
            AhkTest.AssertEqual([117, 130, 122], rgbMedian.getpixel([2, 2]))
            rgbMode := rgb5.filter(stdlib.pillow.ImageFilter.ModeFilter(3))
            outputs.Push(rgbMode)
            AhkTest.AssertEqual([166, 130, 122], rgbMode.getpixel([2, 2]))

            rgbaMin := rgba5.filter(stdlib.pillow.ImageFilter.MinFilter(3))
            outputs.Push(rgbaMin)
            AhkTest.AssertEqual([13, 65, 38, 75], rgbaMin.getpixel([2, 2]))
            rgbaMax := rgba5.filter(stdlib.pillow.ImageFilter.MaxFilter(3))
            outputs.Push(rgbaMax)
            AhkTest.AssertEqual([215, 195, 252, 165], rgbaMax.getpixel([2, 2]))
            rgbaMedian := rgba5.filter(stdlib.pillow.ImageFilter.MedianFilter(3))
            outputs.Push(rgbaMedian)
            AhkTest.AssertEqual([117, 130, 122, 120], rgbaMedian.getpixel([2, 2]))
            rgbaMode := rgba5.filter(stdlib.pillow.ImageFilter.ModeFilter(3))
            outputs.Push(rgbaMode)
            AhkTest.AssertEqual([166, 130, 122, 120], rgbaMode.getpixel([2, 2]))

            flat := stdlib.pillow.Image.new("L", [3, 3], 7)
            flatMode := flat.filter(stdlib.pillow.ImageFilter.ModeFilter(3))
            outputs.Push(flatMode)
            AhkTest.AssertEqual([[7, 7, 7], [7, 7, 7], [7, 7, 7]], StdlibPillowTest.PixelRows(flatMode))

            modeSource := StdlibPillowTest.ModeFilterThresholdImage()
            modeThreshold := modeSource.filter(stdlib.pillow.ImageFilter.ModeFilter(3))
            outputs.Push(modeThreshold)
            AhkTest.AssertEqual([
                [0, 1, 9, 3, 4],
                [10, 9, 9, 9, 14],
                [20, 21, 9, 23, 24],
                [30, 31, 32, 33, 34],
                [40, 41, 42, 43, 44],
            ], StdlibPillowTest.PixelRows(modeThreshold))

            AhkTest.RaisesMatch(ValueError, "^bad filter size$", (*) => gray5.filter(stdlib.pillow.ImageFilter.RankFilter(2, 0)))
            AhkTest.RaisesMatch(ValueError, "^bad filter size$", (*) => gray5.filter(stdlib.pillow.ImageFilter.MinFilter(2)))
            AhkTest.RaisesMatch(ValueError, "^bad rank value$", (*) => gray5.filter(stdlib.pillow.ImageFilter.RankFilter(3, -1)))
            AhkTest.RaisesMatch(ValueError, "^bad rank value$", (*) => gray5.filter(stdlib.pillow.ImageFilter.RankFilter(3, 9)))
            AhkTest.RaisesMatch(TypeError, "^can't multiply sequence by non-int of type 'str'$", (*) => stdlib.pillow.ImageFilter.MedianFilter("x"))
            AhkTest.RaisesMatch(TypeError, "^unsupported operand type\(s\) for //: 'str' and 'int'$", (*) => gray5.filter(stdlib.pillow.ImageFilter.RankFilter("x", 0)))
        } finally {
            for image in outputs
                StdlibPillowTest.CloseImage(image)
            if IsSet(modeSource)
                StdlibPillowTest.CloseImage(modeSource)
            if IsSet(flat)
                StdlibPillowTest.CloseImage(flat)
            if IsSet(rgba5)
                StdlibPillowTest.CloseImage(rgba5)
            if IsSet(rgb5)
                StdlibPillowTest.CloseImage(rgb5)
            if IsSet(gray5)
                StdlibPillowTest.CloseImage(gray5)
        }
    }

    static TestImageFilterBoxBlurMatchesLocalPillow113()
    {
        gray5 := unset
        rgb5 := unset
        rgba5 := unset
        outputs := []
        try {
            AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageFilter, "BoxBlur"))
            scalar := stdlib.pillow.ImageFilter.BoxBlur(1)
            AhkTest.AssertEqual(1, scalar.radius)
            tupleRadius := stdlib.pillow.ImageFilter.BoxBlur([1, 0])
            AhkTest.AssertEqual([1, 0], tupleRadius.radius)

            gray5 := StdlibPillowTest.FilterSourceImage("L")
            rgb5 := StdlibPillowTest.FilterSourceImage("RGB")
            rgba5 := StdlibPillowTest.FilterSourceImage("RGBA")

            grayBlur := gray5.filter(stdlib.pillow.ImageFilter.BoxBlur(1))
            outputs.Push(grayBlur)
            AhkTest.AssertEqual([
                [17, 41, 95, 98, 83],
                [40, 68, 100, 109, 97],
                [74, 108, 120, 138, 133],
                [108, 120, 113, 111, 111],
                [131, 118, 117, 93, 97],
            ], StdlibPillowTest.PixelRows(grayBlur))

            horizontalBlur := gray5.filter(stdlib.pillow.ImageFilter.BoxBlur([1, 0]))
            outputs.Push(horizontalBlur)
            AhkTest.AssertEqual([
                [6, 28, 79, 79, 62],
                [40, 68, 128, 137, 126],
                [74, 108, 92, 110, 104],
                [108, 148, 141, 168, 168],
                [142, 103, 105, 55, 62],
            ], StdlibPillowTest.PixelRows(horizontalBlur))

            zeroBlur := gray5.filter(stdlib.pillow.ImageFilter.BoxBlur(0))
            outputs.Push(zeroBlur)
            AhkTest.AssertEqual(StdlibPillowTest.PixelRows(gray5), StdlibPillowTest.PixelRows(zeroBlur))
            zeroBlur.putpixel([0, 0], 99)
            AhkTest.AssertEqual(0, gray5.getpixel([0, 0]))

            rgbBlur := rgb5.filter(stdlib.pillow.ImageFilter.BoxBlur(1))
            outputs.Push(rgbBlur)
            AhkTest.AssertEqual([120, 130, 137], rgbBlur.getpixel([2, 2]))
            AhkTest.AssertEqual([17, 22, 13], rgbBlur.getpixel([0, 0]))

            rgbaBlur := rgba5.filter(stdlib.pillow.ImageFilter.BoxBlur(1))
            outputs.Push(rgbaBlur)
            AhkTest.AssertEqual([120, 130, 137, 120], rgbaBlur.getpixel([2, 2]))
            AhkTest.AssertEqual([17, 22, 13, 45], rgbaBlur.getpixel([0, 0]))

            AhkTest.RaisesMatch(ValueError, "^radius must be >= 0$", (*) => stdlib.pillow.ImageFilter.BoxBlur(-1))
            AhkTest.RaisesMatch(ValueError, "^radius must be >= 0$", (*) => stdlib.pillow.ImageFilter.BoxBlur([1, -1]))
            AhkTest.RaisesMatch(TypeError, "^'<' not supported between instances of 'str' and 'int'$", (*) => stdlib.pillow.ImageFilter.BoxBlur("x"))
            AhkTest.RaisesMatch(IndexError, "^tuple index out of range$", (*) => stdlib.pillow.ImageFilter.BoxBlur([1]))
        } finally {
            for image in outputs
                StdlibPillowTest.CloseImage(image)
            if IsSet(rgba5)
                StdlibPillowTest.CloseImage(rgba5)
            if IsSet(rgb5)
                StdlibPillowTest.CloseImage(rgb5)
            if IsSet(gray5)
                StdlibPillowTest.CloseImage(gray5)
        }
    }

    static TestImageFilterGaussianBlurMatchesLocalPillow113()
    {
        gray5 := unset
        rgb5 := unset
        rgba5 := unset
        outputs := []
        try {
            AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageFilter, "GaussianBlur"))
            defaultFilter := stdlib.pillow.ImageFilter.GaussianBlur()
            AhkTest.AssertEqual(2, defaultFilter.radius)
            scalar := stdlib.pillow.ImageFilter.GaussianBlur(1)
            AhkTest.AssertEqual(1, scalar.radius)
            tupleRadius := stdlib.pillow.ImageFilter.GaussianBlur([1, 0])
            AhkTest.AssertEqual([1, 0], tupleRadius.radius)
            zeroRadius := stdlib.pillow.ImageFilter.GaussianBlur(0)
            AhkTest.AssertEqual(0, zeroRadius.radius)
            floatRadius := stdlib.pillow.ImageFilter.GaussianBlur(1.5)
            AhkTest.AssertEqual(1.5, floatRadius.radius)

            gray5 := StdlibPillowTest.FilterSourceImage("L")
            rgb5 := StdlibPillowTest.FilterSourceImage("RGB")
            rgba5 := StdlibPillowTest.FilterSourceImage("RGBA")

            grayDefault := gray5.filter(stdlib.pillow.ImageFilter.GaussianBlur())
            outputs.Push(grayDefault)
            AhkTest.AssertEqual([
                [64, 71, 81, 88, 93],
                [73, 79, 87, 94, 97],
                [86, 90, 95, 99, 102],
                [98, 100, 102, 103, 104],
                [106, 106, 105, 105, 104],
            ], StdlibPillowTest.PixelRows(grayDefault))

            grayScalar := gray5.filter(stdlib.pillow.ImageFilter.GaussianBlur(1))
            outputs.Push(grayScalar)
            AhkTest.AssertEqual([
                [25, 48, 86, 102, 81],
                [47, 71, 103, 114, 103],
                [78, 99, 117, 116, 122],
                [106, 119, 120, 113, 121],
                [123, 122, 106, 97, 94],
            ], StdlibPillowTest.PixelRows(grayScalar))

            horizontalBlur := gray5.filter(stdlib.pillow.ImageFilter.GaussianBlur([1, 0]))
            outputs.Push(horizontalBlur)
            AhkTest.AssertEqual([
                [10, 32, 69, 85, 59],
                [45, 72, 118, 142, 122],
                [78, 98, 106, 93, 110],
                [113, 139, 155, 151, 174],
                [132, 118, 84, 73, 57],
            ], StdlibPillowTest.PixelRows(horizontalBlur))

            floatBlur := gray5.filter(stdlib.pillow.ImageFilter.GaussianBlur(1.5))
            outputs.Push(floatBlur)
            AhkTest.AssertEqual([
                [50, 65, 83, 94, 98],
                [65, 77, 92, 102, 105],
                [86, 94, 103, 109, 111],
                [105, 107, 110, 110, 110],
                [116, 114, 112, 108, 107],
            ], StdlibPillowTest.PixelRows(floatBlur))

            zeroBlur := gray5.filter(stdlib.pillow.ImageFilter.GaussianBlur(0))
            outputs.Push(zeroBlur)
            AhkTest.AssertEqual(StdlibPillowTest.PixelRows(gray5), StdlibPillowTest.PixelRows(zeroBlur))
            zeroBlur.putpixel([0, 0], 99)
            AhkTest.AssertEqual(0, gray5.getpixel([0, 0]))

            rgbBlur := rgb5.filter(stdlib.pillow.ImageFilter.GaussianBlur(1))
            outputs.Push(rgbBlur)
            AhkTest.AssertEqual([117, 128, 125], rgbBlur.getpixel([2, 2]))
            AhkTest.AssertEqual([25, 26, 19], rgbBlur.getpixel([0, 0]))

            rgbaBlur := rgba5.filter(stdlib.pillow.ImageFilter.GaussianBlur(1))
            outputs.Push(rgbaBlur)
            AhkTest.AssertEqual([117, 128, 125, 120], rgbaBlur.getpixel([2, 2]))
            rgbaTuple := rgba5.filter(stdlib.pillow.ImageFilter.GaussianBlur([1, 0]))
            outputs.Push(rgbaTuple)
            AhkTest.AssertEqual([106, 130, 122, 120], rgbaTuple.getpixel([2, 2]))

            negativeBlur := gray5.filter(stdlib.pillow.ImageFilter.GaussianBlur(-1))
            outputs.Push(negativeBlur)
            AhkTest.AssertEqual(StdlibPillowTest.PixelRows(grayScalar), StdlibPillowTest.PixelRows(negativeBlur))
            AhkTest.RaisesMatch(TypeError, "^argument 1 must be sequence of length 2, not 1$", (*) => gray5.filter(stdlib.pillow.ImageFilter.GaussianBlur("x")))
            AhkTest.RaisesMatch(TypeError, "^argument 1 must be sequence of length 2, not 1$", (*) => gray5.filter(stdlib.pillow.ImageFilter.GaussianBlur([1])))
        } finally {
            for image in outputs
                StdlibPillowTest.CloseImage(image)
            if IsSet(rgba5)
                StdlibPillowTest.CloseImage(rgba5)
            if IsSet(rgb5)
                StdlibPillowTest.CloseImage(rgb5)
            if IsSet(gray5)
                StdlibPillowTest.CloseImage(gray5)
        }
    }

    static TestImageFilterUnsharpMaskMatchesLocalPillow113()
    {
        gray5 := unset
        rgb5 := unset
        rgba5 := unset
        outputs := []
        try {
            AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageFilter, "UnsharpMask"))
            defaultFilter := stdlib.pillow.ImageFilter.UnsharpMask()
            AhkTest.AssertEqual(2, defaultFilter.radius)
            AhkTest.AssertEqual(150, defaultFilter.percent)
            AhkTest.AssertEqual(3, defaultFilter.threshold)
            explicitFilter := stdlib.pillow.ImageFilter.UnsharpMask(1, 150, 0)
            AhkTest.AssertEqual(1, explicitFilter.radius)
            AhkTest.AssertEqual(150, explicitFilter.percent)
            AhkTest.AssertEqual(0, explicitFilter.threshold)

            gray5 := StdlibPillowTest.FilterSourceImage("L")
            rgb5 := StdlibPillowTest.FilterSourceImage("RGB")
            rgba5 := StdlibPillowTest.FilterSourceImage("RGBA")

            grayDefault := gray5.filter(stdlib.pillow.ImageFilter.UnsharpMask())
            outputs.Push(grayDefault)
            AhkTest.AssertEqual([
                [0, 0, 49, 250, 0],
                [0, 24, 162, 255, 62],
                [26, 107, 255, 0, 222],
                [86, 192, 255, 23, 255],
                [151, 255, 0, 165, 0],
            ], StdlibPillowTest.PixelRows(grayDefault))

            grayExplicit := gray5.filter(stdlib.pillow.ImageFilter.UnsharpMask(1, 150, 0))
            outputs.Push(grayExplicit)
            AhkTest.AssertEqual([
                [0, 0, 41, 229, 0],
                [7, 36, 138, 255, 53],
                [38, 94, 239, 0, 192],
                [74, 164, 255, 8, 255],
                [125, 255, 0, 177, 0],
            ], StdlibPillowTest.PixelRows(grayExplicit))

            grayThreshold := gray5.filter(stdlib.pillow.ImageFilter.UnsharpMask(1, 150, 20))
            outputs.Push(grayThreshold)
            AhkTest.AssertEqual([
                [0, 0, 68, 229, 0],
                [31, 57, 117, 255, 83],
                [62, 97, 239, 0, 192],
                [93, 137, 255, 8, 255],
                [124, 255, 0, 177, 0],
            ], StdlibPillowTest.PixelRows(grayThreshold))

            percentZero := gray5.filter(stdlib.pillow.ImageFilter.UnsharpMask(1, 0, 0))
            outputs.Push(percentZero)
            AhkTest.AssertEqual(StdlibPillowTest.PixelRows(gray5), StdlibPillowTest.PixelRows(percentZero))
            percentZero.putpixel([0, 0], 99)
            AhkTest.AssertEqual(0, gray5.getpixel([0, 0]))

            radiusZero := gray5.filter(stdlib.pillow.ImageFilter.UnsharpMask(0, 150, 0))
            outputs.Push(radiusZero)
            AhkTest.AssertEqual(StdlibPillowTest.PixelRows(gray5), StdlibPillowTest.PixelRows(radiusZero))

            percentHigh := gray5.filter(stdlib.pillow.ImageFilter.UnsharpMask(1, 250, 0))
            outputs.Push(percentHigh)
            AhkTest.AssertEqual([
                [0, 0, 23, 255, 0],
                [0, 22, 152, 255, 33],
                [22, 92, 255, 0, 220],
                [61, 182, 255, 0, 255],
                [126, 255, 0, 209, 0],
            ], StdlibPillowTest.PixelRows(percentHigh))

            negativeRadius := gray5.filter(stdlib.pillow.ImageFilter.UnsharpMask(-1, 150, 0))
            outputs.Push(negativeRadius)
            AhkTest.AssertEqual(StdlibPillowTest.PixelRows(grayExplicit), StdlibPillowTest.PixelRows(negativeRadius))

            rgbSharp := rgb5.filter(stdlib.pillow.ImageFilter.UnsharpMask(1, 150, 0))
            outputs.Push(rgbSharp)
            AhkTest.AssertEqual([239, 133, 118], rgbSharp.getpixel([2, 2]))
            AhkTest.AssertEqual([0, 0, 0], rgbSharp.getpixel([0, 0]))

            rgbaSharp := rgba5.filter(stdlib.pillow.ImageFilter.UnsharpMask(1, 150, 0))
            outputs.Push(rgbaSharp)
            AhkTest.AssertEqual([239, 133, 118, 120], rgbaSharp.getpixel([2, 2]))
            rgbaThreshold := rgba5.filter(stdlib.pillow.ImageFilter.UnsharpMask(1, 150, 20))
            outputs.Push(rgbaThreshold)
            AhkTest.AssertEqual([239, 130, 122, 120], rgbaThreshold.getpixel([2, 2]))

            AhkTest.RaisesMatch(TypeError, "^must be real number, not str$", (*) => gray5.filter(stdlib.pillow.ImageFilter.UnsharpMask("x", 150, 0)))
            AhkTest.RaisesMatch(TypeError, "^'str' object cannot be interpreted as an integer$", (*) => gray5.filter(stdlib.pillow.ImageFilter.UnsharpMask(1, "x", 0)))
            AhkTest.RaisesMatch(TypeError, "^'str' object cannot be interpreted as an integer$", (*) => gray5.filter(stdlib.pillow.ImageFilter.UnsharpMask(1, 150, "x")))
        } finally {
            for image in outputs
                StdlibPillowTest.CloseImage(image)
            if IsSet(rgba5)
                StdlibPillowTest.CloseImage(rgba5)
            if IsSet(rgb5)
                StdlibPillowTest.CloseImage(rgb5)
            if IsSet(gray5)
                StdlibPillowTest.CloseImage(gray5)
        }
    }

    static TestImageFilterColor3DLUTCoreMatchesLocalPillow113()
    {
        rgb := unset
        rgba := unset
        gray := unset
        outputs := []
        try {
            AhkTest.AssertTrue(HasProp(stdlib.pillow.ImageFilter, "Color3DLUT"))
            AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageFilter.Color3DLUT, "generate"))

            identity := stdlib.pillow.ImageFilter.Color3DLUT.generate(2, (r, g, b) => [r, g, b])
            AhkTest.AssertEqual([2, 2, 2], identity.size)
            AhkTest.AssertEqual(3, identity.channels)
            AhkTest.AssertSame(stdlib.None, identity.mode)
            AhkTest.AssertEqual("<Color3DLUT from Array size=2x2x2 channels=3>", identity.__Repr())
            AhkTest.AssertEqual([0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0], StdlibPillowTest.Take(identity.table, 12))

            rgb := stdlib.pillow.Image.new("RGB", [3, 1], [0, 0, 0])
            rgb.putpixel([0, 0], [0, 0, 0])
            rgb.putpixel([1, 0], [64, 128, 192])
            rgb.putpixel([2, 0], [255, 255, 255])
            rgba := stdlib.pillow.Image.new("RGBA", [1, 1], [64, 128, 192, 200])
            gray := stdlib.pillow.Image.new("L", [1, 1], 128)

            rgbIdentity := rgb.filter(identity)
            outputs.Push(rgbIdentity)
            AhkTest.AssertEqual([[[0, 0, 0], [64, 128, 192], [255, 255, 255]]], StdlibPillowTest.PixelRows(rgbIdentity))
            rgbaIdentity := rgba.filter(identity)
            outputs.Push(rgbaIdentity)
            AhkTest.AssertEqual([64, 128, 192, 200], rgbaIdentity.getpixel([0, 0]))

            rgbaTarget := stdlib.pillow.ImageFilter.Color3DLUT.generate(2, (r, g, b) => [r, g, b, 0.5], 4, "RGBA")
            AhkTest.AssertEqual("<Color3DLUT from Array size=2x2x2 channels=4 target_mode=RGBA>", rgbaTarget.__Repr())
            AhkTest.AssertEqual([0.0, 0.0, 0.0, 0.5, 1.0, 0.0, 0.0, 0.5, 0.0, 1.0, 0.0, 0.5, 1.0, 1.0, 0.0, 0.5], StdlibPillowTest.Take(rgbaTarget.table, 16))
            rgbaTargetRgb := rgb.filter(rgbaTarget)
            outputs.Push(rgbaTargetRgb)
            AhkTest.AssertEqual("RGBA", rgbaTargetRgb.mode)
            AhkTest.AssertEqual([64, 128, 192, 128], rgbaTargetRgb.getpixel([1, 0]))

            inverted := rgbaTarget.transform((r, g, b, a) => [1 - r, 1 - g, 1 - b, a], false, 4)
            AhkTest.AssertEqual([1.0, 1.0, 1.0, 0.5, 0.0, 1.0, 1.0, 0.5, 1.0, 0.0, 1.0, 0.5, 0.0, 0.0, 1.0, 0.5], StdlibPillowTest.Take(inverted.table, 16))
            invertedRgb := rgb.filter(inverted)
            outputs.Push(invertedRgb)
            AhkTest.AssertEqual([191, 127, 63, 128], invertedRgb.getpixel([1, 0]))

            normals := rgbaTarget.transform((nr, ng, nb, r, g, b, a) => [nr, ng, nb, a], true, 4)
            AhkTest.AssertEqual(StdlibPillowTest.Take(rgbaTarget.table, 16), StdlibPillowTest.Take(normals.table, 16))
            normalsRgb := rgb.filter(normals)
            outputs.Push(normalsRgb)
            AhkTest.AssertEqual([64, 128, 192, 128], normalsRgb.getpixel([1, 0]))

            tupleTable := stdlib.pillow.ImageFilter.Color3DLUT(2, [
                [0, 0, 0],
                [1, 0, 0],
                [0, 1, 0],
                [1, 1, 0],
                [0, 0, 1],
                [1, 0, 1],
                [0, 1, 1],
                [1, 1, 1],
            ])
            AhkTest.AssertEqual([0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1, 0], StdlibPillowTest.Take(tupleTable.table, 12))
            tupleRgb := rgb.filter(tupleTable)
            outputs.Push(tupleRgb)
            AhkTest.AssertEqual(StdlibPillowTest.PixelRows(rgbIdentity), StdlibPillowTest.PixelRows(tupleRgb))

            AhkTest.RaisesMatch(ValueError, "^image has wrong mode$", (*) => gray.filter(identity))
            AhkTest.RaisesMatch(ValueError, "^Size should be in \[2, 65\] range\.$", (*) => stdlib.pillow.ImageFilter.Color3DLUT(1, [0, 0, 0]))
            AhkTest.RaisesMatch(ValueError, "^Size should be either an integer or a tuple of three integers\.$", (*) => stdlib.pillow.ImageFilter.Color3DLUT([2, 2], StdlibPillowTest.Repeat(0, 24)))
            AhkTest.RaisesMatch(ValueError, "^Only 3 or 4 output channels are supported$", (*) => stdlib.pillow.ImageFilter.Color3DLUT(2, StdlibPillowTest.Repeat(0, 16), 2))
            AhkTest.RaisesMatch(ValueError, "^The elements of the table should have a length of 3\.$", (*) => stdlib.pillow.ImageFilter.Color3DLUT(2, StdlibPillowTest.Repeat([0, 0], 8)))
            AhkTest.RaisesMatch(ValueError, "^The table should have either channels \* size\*\*3 float items or size\*\*3 items of channels-sized tuples with floats\. Table should be: 3x2x2x2\. Actual length: 3$", (*) => stdlib.pillow.ImageFilter.Color3DLUT(2, [0, 0, 0]))
            AhkTest.RaisesMatch(ValueError, "^Only 3 or 4 output channels are supported$", (*) => identity.transform((r, g, b) => [r, g], false, 2))
        } finally {
            for image in outputs
                StdlibPillowTest.CloseImage(image)
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
        }
    }

    static TestImageChopsMatchesLocalPillow113()
    {
        l1 := unset
        l2 := unset
        rgb1 := unset
        rgb2 := unset
        rgba1 := unset
        rgba2 := unset
        modeMismatch := unset
        duplicate := unset
        smallAdd := unset
        outputs := []
        try {
            AhkTest.AssertTrue(HasProp(stdlib.pillow, "ImageChops"))
            l1 := StdlibPillowTest.ChopsLImageA()
            l2 := StdlibPillowTest.ChopsLImageB()
            rgb1 := StdlibPillowTest.ChopsRgbImageA()
            rgb2 := StdlibPillowTest.ChopsRgbImageB()
            rgba1 := stdlib.pillow.Image.new("RGBA", [1, 2], [10, 20, 30, 40])
            rgba1.putpixel([0, 1], [250, 5, 128, 255])
            rgba2 := stdlib.pillow.Image.new("RGBA", [1, 2], [110, 120, 130, 140])
            rgba2.putpixel([0, 1], [10, 250, 128, 1])

            add := stdlib.pillow.ImageChops.add(l1, l2)
            outputs.Push(add)
            AhkTest.AssertEqual([[30, 255, 255], [255, 255, 255]], StdlibPillowTest.PixelRows(add))
            addScaled := stdlib.pillow.ImageChops.add(l1, l2, 2.0, 10)
            outputs.Push(addScaled)
            AhkTest.AssertEqual([[25, 140, 150], [137, 138, 138]], StdlibPillowTest.PixelRows(addScaled))
            subtract := stdlib.pillow.ImageChops.subtract(l1, l2)
            outputs.Push(subtract)
            AhkTest.AssertEqual([[0, 0, 220], [0, 0, 254]], StdlibPillowTest.PixelRows(subtract))
            subtractScaled := stdlib.pillow.ImageChops.subtract(l1, l2, 2.0, 10)
            outputs.Push(subtractScaled)
            AhkTest.AssertEqual([[5, 0, 120], [0, 10, 137]], StdlibPillowTest.PixelRows(subtractScaled))
            addModulo := stdlib.pillow.ImageChops.add_modulo(l1, l2)
            outputs.Push(addModulo)
            AhkTest.AssertEqual([[30, 4, 24], [255, 0, 0]], StdlibPillowTest.PixelRows(addModulo))
            subtractModulo := stdlib.pillow.ImageChops.subtract_modulo(l1, l2)
            outputs.Push(subtractModulo)
            AhkTest.AssertEqual([[246, 196, 220], [1, 0, 254]], StdlibPillowTest.PixelRows(subtractModulo))
            multiply := stdlib.pillow.ImageChops.multiply(l1, l2)
            outputs.Push(multiply)
            AhkTest.AssertEqual([[0, 62, 29], [0, 64, 1]], StdlibPillowTest.PixelRows(multiply))
            screen := stdlib.pillow.ImageChops.screen(l1, l2)
            outputs.Push(screen)
            AhkTest.AssertEqual([[30, 198, 251], [255, 192, 255]], StdlibPillowTest.PixelRows(screen))
            difference := stdlib.pillow.ImageChops.difference(l1, l2)
            outputs.Push(difference)
            AhkTest.AssertEqual([[10, 60, 220], [255, 0, 254]], StdlibPillowTest.PixelRows(difference))
            lighter := stdlib.pillow.ImageChops.lighter(l1, l2)
            outputs.Push(lighter)
            AhkTest.AssertEqual([[20, 160, 250], [255, 128, 255]], StdlibPillowTest.PixelRows(lighter))
            darker := stdlib.pillow.ImageChops.darker(l1, l2)
            outputs.Push(darker)
            AhkTest.AssertEqual([[10, 100, 30], [0, 128, 1]], StdlibPillowTest.PixelRows(darker))
            inverted := stdlib.pillow.ImageChops.invert(l1)
            outputs.Push(inverted)
            AhkTest.AssertEqual([[245, 155, 5], [255, 127, 0]], StdlibPillowTest.PixelRows(inverted))
            offsetX := stdlib.pillow.ImageChops.offset(l1, 1)
            outputs.Push(offsetX)
            AhkTest.AssertEqual([[255, 0, 128], [250, 10, 100]], StdlibPillowTest.PixelRows(offsetX))
            offsetYNone := stdlib.pillow.ImageChops.offset(l1, -1, stdlib.None)
            outputs.Push(offsetYNone)
            AhkTest.AssertEqual([[128, 255, 0], [100, 250, 10]], StdlibPillowTest.PixelRows(offsetYNone))
            constant := stdlib.pillow.ImageChops.constant(l1, 77)
            outputs.Push(constant)
            AhkTest.AssertEqual([[77, 77, 77], [77, 77, 77]], StdlibPillowTest.PixelRows(constant))
            constantHigh := stdlib.pillow.ImageChops.constant(l1, 300)
            outputs.Push(constantHigh)
            AhkTest.AssertEqual([[255, 255, 255], [255, 255, 255]], StdlibPillowTest.PixelRows(constantHigh))

            duplicate := stdlib.pillow.ImageChops.duplicate(l1)
            duplicate.putpixel([0, 0], 99)
            AhkTest.AssertEqual(10, l1.getpixel([0, 0]))
            AhkTest.AssertEqual(99, duplicate.getpixel([0, 0]))

            rgbAdd := stdlib.pillow.ImageChops.add(rgb1, rgb2)
            outputs.Push(rgbAdd)
            AhkTest.AssertEqual([[[30, 50, 70], [255, 255, 255]], [[230, 250, 255], [255, 255, 255]]], StdlibPillowTest.PixelRows(rgbAdd))
            rgbMultiply := stdlib.pillow.ImageChops.multiply(rgb1, rgb2)
            outputs.Push(rgbMultiply)
            AhkTest.AssertEqual([[[0, 2, 4], [62, 73, 84]], [[23, 32, 43], [9, 4, 64]]], StdlibPillowTest.PixelRows(rgbMultiply))
            rgbScreen := stdlib.pillow.ImageChops.screen(rgb1, rgb2)
            outputs.Push(rgbScreen)
            AhkTest.AssertEqual([[[30, 48, 66], [198, 207, 216]], [[207, 218, 227], [251, 251, 192]]], StdlibPillowTest.PixelRows(rgbScreen))
            rgbDifference := stdlib.pillow.ImageChops.difference(rgb1, rgb2)
            outputs.Push(rgbDifference)
            AhkTest.AssertEqual([[[10, 10, 10], [60, 60, 60]], [[170, 170, 170], [240, 245, 0]]], StdlibPillowTest.PixelRows(rgbDifference))
            rgbOffset := stdlib.pillow.ImageChops.offset(rgb1, -1, 1)
            outputs.Push(rgbOffset)
            AhkTest.AssertEqual([[[250, 5, 128], [200, 210, 220]], [[100, 110, 120], [10, 20, 30]]], StdlibPillowTest.PixelRows(rgbOffset))

            rgbaAdd := stdlib.pillow.ImageChops.add(rgba1, rgba2)
            outputs.Push(rgbaAdd)
            AhkTest.AssertEqual([[[120, 140, 160, 180]], [[255, 255, 255, 255]]], StdlibPillowTest.PixelRows(rgbaAdd))
            rgbaMultiply := stdlib.pillow.ImageChops.multiply(rgba1, rgba2)
            outputs.Push(rgbaMultiply)
            AhkTest.AssertEqual([[[4, 9, 15, 21]], [[9, 4, 64, 1]]], StdlibPillowTest.PixelRows(rgbaMultiply))

            smallAdd := stdlib.pillow.ImageChops.add(l1, stdlib.pillow.Image.new("L", [1, 1], 0))
            AhkTest.AssertEqual([1, 1], smallAdd.size)
            AhkTest.AssertEqual([[10]], StdlibPillowTest.PixelRows(smallAdd))
            modeMismatch := stdlib.pillow.Image.new("RGB", [3, 2], [0, 0, 0])
            AhkTest.RaisesMatch(ValueError, "^images do not match$", (*) => stdlib.pillow.ImageChops.add(l1, modeMismatch))
        } finally {
            for image in outputs
                StdlibPillowTest.CloseImage(image)
            if IsSet(smallAdd)
                StdlibPillowTest.CloseImage(smallAdd)
            if IsSet(duplicate)
                StdlibPillowTest.CloseImage(duplicate)
            if IsSet(modeMismatch)
                StdlibPillowTest.CloseImage(modeMismatch)
            if IsSet(rgba2)
                StdlibPillowTest.CloseImage(rgba2)
            if IsSet(rgba1)
                StdlibPillowTest.CloseImage(rgba1)
            if IsSet(rgb2)
                StdlibPillowTest.CloseImage(rgb2)
            if IsSet(rgb1)
                StdlibPillowTest.CloseImage(rgb1)
            if IsSet(l2)
                StdlibPillowTest.CloseImage(l2)
            if IsSet(l1)
                StdlibPillowTest.CloseImage(l1)
        }
    }

    static TestImageChopsBlendLightLogicalMatchesLocalPillow113()
    {
        l1 := unset
        l2 := unset
        rgb1 := unset
        rgb2 := unset
        rgba1 := unset
        rgba2 := unset
        mask := unset
        one1 := unset
        one2 := unset
        oneOne := unset
        one255 := unset
        modeMismatch := unset
        small := unset
        outputs := []
        try {
            l1 := StdlibPillowTest.ChopsLImageA()
            l2 := StdlibPillowTest.ChopsLImageB()
            rgb1 := StdlibPillowTest.ChopsRgbImageA()
            rgb2 := StdlibPillowTest.ChopsRgbImageB()
            rgba1 := stdlib.pillow.Image.new("RGBA", [2, 1], [10, 20, 30, 40])
            rgba1.putpixel([1, 0], [250, 5, 128, 255])
            rgba2 := stdlib.pillow.Image.new("RGBA", [2, 1], [110, 120, 130, 140])
            rgba2.putpixel([1, 0], [10, 250, 128, 1])
            mask := stdlib.pillow.Image.new("L", [3, 2], 0)
            for item in [
                [[0, 0], 0], [[1, 0], 128], [[2, 0], 255],
                [[0, 1], 64], [[1, 1], 192], [[2, 1], 255],
            ]
                mask.putpixel(item[1], item[2])

            blendL := stdlib.pillow.ImageChops.blend(l1, l2, 0.25)
            outputs.Push(blendL)
            AhkTest.AssertEqual([[12, 115, 195], [63, 128, 191]], StdlibPillowTest.PixelRows(blendL))
            blendRgb := stdlib.pillow.ImageChops.blend(rgb1, rgb2, 0.5)
            outputs.Push(blendRgb)
            AhkTest.AssertEqual([[[15, 25, 35], [130, 140, 150]], [[115, 125, 135], [130, 127, 128]]], StdlibPillowTest.PixelRows(blendRgb))

            compositeL := stdlib.pillow.ImageChops.composite(l1, l2, mask)
            outputs.Push(compositeL)
            AhkTest.AssertEqual([[20, 130, 250], [191, 128, 255]], StdlibPillowTest.PixelRows(compositeL))

            overlayL := stdlib.pillow.ImageChops.overlay(l1, l2)
            outputs.Push(overlayL)
            AhkTest.AssertEqual([[1, 125, 247], [0, 128, 255]], StdlibPillowTest.PixelRows(overlayL))
            hardLightL := stdlib.pillow.ImageChops.hard_light(l1, l2)
            outputs.Push(hardLightL)
            AhkTest.AssertEqual([[1, 140, 59], [255, 128, 2]], StdlibPillowTest.PixelRows(hardLightL))
            softLightL := stdlib.pillow.ImageChops.soft_light(l1, l2)
            outputs.Push(softLightL)
            AhkTest.AssertEqual([[1, 114, 246], [0, 127, 255]], StdlibPillowTest.PixelRows(softLightL))

            overlayRgb := stdlib.pillow.ImageChops.overlay(rgb1, rgb2)
            outputs.Push(overlayRgb)
            AhkTest.AssertEqual([[[1, 4, 9], [125, 147, 170]], [[158, 179, 199], [246, 9, 128]]], StdlibPillowTest.PixelRows(overlayRgb))
            hardLightRgb := stdlib.pillow.ImageChops.hard_light(rgb1, rgb2)
            outputs.Push(hardLightRgb)
            AhkTest.AssertEqual([[[1, 4, 9], [140, 158, 176]], [[47, 66, 86], [19, 246, 128]]], StdlibPillowTest.PixelRows(hardLightRgb))
            softLightRgb := stdlib.pillow.ImageChops.soft_light(rgb1, rgb2)
            outputs.Push(softLightRgb)
            AhkTest.AssertEqual([[[1, 5, 11], [114, 130, 145]], [[167, 184, 200], [246, 8, 127]]], StdlibPillowTest.PixelRows(softLightRgb))

            overlayRgba := stdlib.pillow.ImageChops.overlay(rgba1, rgba2)
            outputs.Push(overlayRgba)
            AhkTest.AssertEqual([[[8, 18, 30, 44], [246, 9, 128, 255]]], StdlibPillowTest.PixelRows(overlayRgba))
            hardLightRgba := stdlib.pillow.ImageChops.hard_light(rgba1, rgba2)
            outputs.Push(hardLightRgba)
            AhkTest.AssertEqual([[[8, 18, 34, 61], [19, 246, 128, 2]]], StdlibPillowTest.PixelRows(hardLightRgba))
            softLightRgba := stdlib.pillow.ImageChops.soft_light(rgba1, rgba2)
            outputs.Push(softLightRgba)
            AhkTest.AssertEqual([[[8, 18, 30, 42], [246, 8, 127, 255]]], StdlibPillowTest.PixelRows(softLightRgba))

            small := stdlib.pillow.Image.new("L", [1, 1], 90)
            overlaySmall := stdlib.pillow.ImageChops.overlay(l1, small)
            outputs.Push(overlaySmall)
            AhkTest.AssertEqual([1, 1], overlaySmall.size)
            AhkTest.AssertEqual([[7]], StdlibPillowTest.PixelRows(overlaySmall))

            one1 := stdlib.pillow.Image.new("1", [3, 2], 0)
            for item in [
                [[0, 0], 0], [[1, 0], 1], [[2, 0], 255],
                [[0, 1], 1], [[1, 1], 0], [[2, 1], 255],
            ]
                one1.putpixel(item[1], item[2])
            one2 := stdlib.pillow.Image.new("1", [3, 2], 0)
            for item in [
                [[0, 0], 0], [[1, 0], 0], [[2, 0], 255],
                [[0, 1], 1], [[1, 1], 255], [[2, 1], 0],
            ]
                one2.putpixel(item[1], item[2])
            oneOne := stdlib.pillow.Image.new("1", [2, 1], 1)
            one255 := stdlib.pillow.Image.new("1", [2, 1], 255)
            AhkTest.AssertEqual([[0, 1, 255], [1, 0, 255]], StdlibPillowTest.PixelRows(one1))
            AhkTest.AssertEqual([[1, 1]], StdlibPillowTest.PixelRows(oneOne))
            AhkTest.AssertEqual([[255, 255]], StdlibPillowTest.PixelRows(one255))
            logicalAnd := stdlib.pillow.ImageChops.logical_and(one1, one2)
            outputs.Push(logicalAnd)
            AhkTest.AssertEqual([[0, 0, 255], [255, 0, 0]], StdlibPillowTest.PixelRows(logicalAnd))
            logicalOr := stdlib.pillow.ImageChops.logical_or(one1, one2)
            outputs.Push(logicalOr)
            AhkTest.AssertEqual([[0, 255, 255], [255, 255, 255]], StdlibPillowTest.PixelRows(logicalOr))
            logicalXor := stdlib.pillow.ImageChops.logical_xor(one1, one2)
            outputs.Push(logicalXor)
            AhkTest.AssertEqual([[0, 255, 0], [0, 255, 255]], StdlibPillowTest.PixelRows(logicalXor))

            modeMismatch := stdlib.pillow.Image.new("RGB", [3, 2], [0, 0, 0])
            AhkTest.RaisesMatch(ValueError, "^image has wrong mode$", (*) => stdlib.pillow.ImageChops.logical_and(l1, l2))
            AhkTest.RaisesMatch(ValueError, "^image has wrong mode$", (*) => stdlib.pillow.ImageChops.logical_or(one1, l2))
            AhkTest.RaisesMatch(ValueError, "^images do not match$", (*) => stdlib.pillow.ImageChops.overlay(l1, modeMismatch))
            AhkTest.RaisesMatch(ValueError, "^images do not match$", (*) => stdlib.pillow.ImageChops.blend(l1, small, 0.5))
            AhkTest.RaisesMatch(TypeError, "^color must be int or single-element tuple$", (*) => stdlib.pillow.Image.new("1", [1, 1], [255, 255, 255]))
        } finally {
            for image in outputs
                StdlibPillowTest.CloseImage(image)
            if IsSet(modeMismatch)
                StdlibPillowTest.CloseImage(modeMismatch)
            if IsSet(one255)
                StdlibPillowTest.CloseImage(one255)
            if IsSet(oneOne)
                StdlibPillowTest.CloseImage(oneOne)
            if IsSet(one2)
                StdlibPillowTest.CloseImage(one2)
            if IsSet(one1)
                StdlibPillowTest.CloseImage(one1)
            if IsSet(small)
                StdlibPillowTest.CloseImage(small)
            if IsSet(mask)
                StdlibPillowTest.CloseImage(mask)
            if IsSet(rgba2)
                StdlibPillowTest.CloseImage(rgba2)
            if IsSet(rgba1)
                StdlibPillowTest.CloseImage(rgba1)
            if IsSet(rgb2)
                StdlibPillowTest.CloseImage(rgb2)
            if IsSet(rgb1)
                StdlibPillowTest.CloseImage(rgb1)
            if IsSet(l2)
                StdlibPillowTest.CloseImage(l2)
            if IsSet(l1)
                StdlibPillowTest.CloseImage(l1)
        }
    }

    static TestImageOpsMatchesLocalPillow113()
    {
        gray := unset
        rgb := unset
        rgba := unset
        outputs := []
        try {
            AhkTest.AssertTrue(HasProp(stdlib.pillow, "ImageOps"))
            gray := StdlibPillowTest.ChopsLImageA()
            rgb := StdlibPillowTest.OpsRgbImage()
            rgba := stdlib.pillow.Image.new("RGBA", [2, 2], [10, 20, 30, 40])
            rgba.putpixel([1, 0], [100, 110, 120, 130])
            rgba.putpixel([0, 1], [200, 210, 220, 230])
            rgba.putpixel([1, 1], [250, 5, 128, 255])

            lInvert := stdlib.pillow.ImageOps.invert(gray)
            outputs.Push(lInvert)
            AhkTest.AssertEqual([[245, 155, 5], [255, 127, 0]], StdlibPillowTest.PixelRows(lInvert))
            rgbInvert := stdlib.pillow.ImageOps.invert(rgb)
            outputs.Push(rgbInvert)
            AhkTest.AssertEqual([[[245, 235, 225], [155, 145, 135], [55, 45, 35]], [[5, 250, 127], [215, 175, 95], [255, 0, 245]]], StdlibPillowTest.PixelRows(rgbInvert))
            mirror := stdlib.pillow.ImageOps.mirror(gray)
            outputs.Push(mirror)
            AhkTest.AssertEqual([[250, 100, 10], [255, 128, 0]], StdlibPillowTest.PixelRows(mirror))
            flip := stdlib.pillow.ImageOps.flip(rgb)
            outputs.Push(flip)
            AhkTest.AssertEqual([[[250, 5, 128], [40, 80, 160], [0, 255, 10]], [[10, 20, 30], [100, 110, 120], [200, 210, 220]]], StdlibPillowTest.PixelRows(flip))

            grayscale := stdlib.pillow.ImageOps.grayscale(rgb)
            outputs.Push(grayscale)
            AhkTest.AssertEqual("L", grayscale.mode)
            AhkTest.AssertEqual([[18, 108, 208], [92, 77, 151]], StdlibPillowTest.PixelRows(grayscale))
            rgbaGray := stdlib.pillow.ImageOps.grayscale(rgba)
            outputs.Push(rgbaGray)
            AhkTest.AssertEqual([[18, 108], [208, 92]], StdlibPillowTest.PixelRows(rgbaGray))

            solarizeDefault := stdlib.pillow.ImageOps.solarize(gray)
            outputs.Push(solarizeDefault)
            AhkTest.AssertEqual([[10, 100, 5], [0, 127, 0]], StdlibPillowTest.PixelRows(solarizeDefault))
            solarize100 := stdlib.pillow.ImageOps.solarize(rgb, 100)
            outputs.Push(solarize100)
            AhkTest.AssertEqual([[[10, 20, 30], [155, 145, 135], [55, 45, 35]], [[5, 5, 127], [40, 80, 95], [0, 0, 10]]], StdlibPillowTest.PixelRows(solarize100))
            posterizeGray := stdlib.pillow.ImageOps.posterize(gray, 4)
            outputs.Push(posterizeGray)
            AhkTest.AssertEqual([[0, 96, 240], [0, 128, 240]], StdlibPillowTest.PixelRows(posterizeGray))
            posterizeRgb := stdlib.pillow.ImageOps.posterize(rgb, 4)
            outputs.Push(posterizeRgb)
            AhkTest.AssertEqual([[[0, 16, 16], [96, 96, 112], [192, 208, 208]], [[240, 0, 128], [32, 80, 160], [0, 240, 0]]], StdlibPillowTest.PixelRows(posterizeRgb))

            expandedGray := stdlib.pillow.ImageOps.expand(gray, 1, 77)
            outputs.Push(expandedGray)
            AhkTest.AssertEqual([5, 4], expandedGray.size)
            AhkTest.AssertEqual([[77, 77, 77, 77, 77], [77, 10, 100, 250, 77], [77, 0, 128, 255, 77], [77, 77, 77, 77, 77]], StdlibPillowTest.PixelRows(expandedGray))
            expandedRgb := stdlib.pillow.ImageOps.expand(rgb, [1, 2, 0, 1], [1, 2, 3])
            outputs.Push(expandedRgb)
            AhkTest.AssertEqual([4, 5], expandedRgb.size)
            AhkTest.AssertEqual([1, 2, 3], expandedRgb.getpixel([0, 0]))
            AhkTest.AssertEqual([10, 20, 30], expandedRgb.getpixel([1, 2]))
            croppedEmpty := stdlib.pillow.ImageOps.crop(gray, 1)
            outputs.Push(croppedEmpty)
            AhkTest.AssertEqual([1, 0], croppedEmpty.size)
            croppedRgb := stdlib.pillow.ImageOps.crop(rgb, [1, 0, 1, 1])
            outputs.Push(croppedRgb)
            AhkTest.AssertEqual([1, 1], croppedRgb.size)
            AhkTest.AssertEqual([100, 110, 120], croppedRgb.getpixel([0, 0]))

            AhkTest.RaisesMatch(OSError, "^not supported for mode RGBA$", (*) => stdlib.pillow.ImageOps.invert(rgba))
            AhkTest.RaisesMatch(TypeError, "^bad operand type for unary ~: 'float'$", (*) => stdlib.pillow.ImageOps.posterize(gray, 9))
        } finally {
            for image in outputs
                StdlibPillowTest.CloseImage(image)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
        }
    }

    static TestImageOpsContainMatchesLocalPillow113()
    {
        rgbWide := unset
        grayTall := unset
        rgbaSame := unset
        rgbSmallTarget := unset
        outputs := []
        try {
            rgbWide := stdlib.pillow.Image.new("RGB", [4, 2], [10, 20, 30])
            rgbWideContained := stdlib.pillow.ImageOps.contain(rgbWide, [3, 3])
            outputs.Push(rgbWideContained)
            AhkTest.AssertEqual("RGB", rgbWideContained.mode)
            AhkTest.AssertEqual([3, 2], rgbWideContained.size)
            AhkTest.AssertEqual([[[10, 20, 30], [10, 20, 30], [10, 20, 30]], [[10, 20, 30], [10, 20, 30], [10, 20, 30]]], StdlibPillowTest.PixelRows(rgbWideContained))
            AhkTest.AssertTrue(ObjPtr(rgbWideContained) != ObjPtr(rgbWide))

            grayTall := stdlib.pillow.Image.new("L", [2, 4], 90)
            grayTallContained := stdlib.pillow.ImageOps.contain(grayTall, [3, 3])
            outputs.Push(grayTallContained)
            AhkTest.AssertEqual("L", grayTallContained.mode)
            AhkTest.AssertEqual([2, 3], grayTallContained.size)
            AhkTest.AssertEqual([[90, 90], [90, 90], [90, 90]], StdlibPillowTest.PixelRows(grayTallContained))

            rgbaSame := stdlib.pillow.Image.new("RGBA", [2, 2], [1, 2, 3, 4])
            rgbaSameContained := stdlib.pillow.ImageOps.contain(rgbaSame, [2, 2])
            outputs.Push(rgbaSameContained)
            AhkTest.AssertEqual("RGBA", rgbaSameContained.mode)
            AhkTest.AssertEqual([2, 2], rgbaSameContained.size)
            AhkTest.AssertEqual([[[1, 2, 3, 4], [1, 2, 3, 4]], [[1, 2, 3, 4], [1, 2, 3, 4]]], StdlibPillowTest.PixelRows(rgbaSameContained))
            AhkTest.AssertTrue(ObjPtr(rgbaSameContained) != ObjPtr(rgbaSame))

            rgbSmallTarget := stdlib.pillow.Image.new("RGB", [5, 3], [100, 110, 120])
            smallContained := stdlib.pillow.ImageOps.contain(rgbSmallTarget, [1, 10])
            outputs.Push(smallContained)
            AhkTest.AssertEqual([1, 1], smallContained.size)
            AhkTest.AssertEqual([[[100, 110, 120]]], StdlibPillowTest.PixelRows(smallContained))

            AhkTest.RaisesMatch(AttributeError, "^'NoneType' object has no attribute 'width'$", (*) => stdlib.pillow.ImageOps.contain(stdlib.None, [1, 1]))
            AhkTest.RaisesMatch(IndexError, "^tuple index out of range$", (*) => stdlib.pillow.ImageOps.contain(rgbWide, [3]))
            AhkTest.RaisesMatch(ValueError, "^height and width must be > 0$", (*) => stdlib.pillow.ImageOps.contain(rgbWide, [0, 3]))
            AhkTest.RaisesMatch(ZeroDivisionError, "^division by zero$", (*) => stdlib.pillow.ImageOps.contain(rgbWide, [3, 0]))
            AhkTest.RaisesMatch(TypeError, "^unsupported operand type\(s\) for /: 'str' and 'str'$", (*) => stdlib.pillow.ImageOps.contain(rgbWide, "33"))
        } finally {
            for image in outputs
                StdlibPillowTest.CloseImage(image)
            if IsSet(rgbSmallTarget)
                StdlibPillowTest.CloseImage(rgbSmallTarget)
            if IsSet(rgbaSame)
                StdlibPillowTest.CloseImage(rgbaSame)
            if IsSet(grayTall)
                StdlibPillowTest.CloseImage(grayTall)
            if IsSet(rgbWide)
                StdlibPillowTest.CloseImage(rgbWide)
        }
    }

    static TestImageOpsCoverAndScaleMatchLocalPillow113()
    {
        rgbWide := unset
        grayTall := unset
        rgbaSame := unset
        outputs := []
        try {
            rgbWide := stdlib.pillow.Image.new("RGB", [4, 2], [10, 20, 30])
            rgbWideCovered := stdlib.pillow.ImageOps.cover(rgbWide, [3, 3])
            outputs.Push(rgbWideCovered)
            AhkTest.AssertEqual("RGB", rgbWideCovered.mode)
            AhkTest.AssertEqual([6, 3], rgbWideCovered.size)
            AhkTest.AssertTrue(ObjPtr(rgbWideCovered) != ObjPtr(rgbWide))

            grayTall := stdlib.pillow.Image.new("L", [2, 4], 90)
            grayTallCovered := stdlib.pillow.ImageOps.cover(grayTall, [3, 3])
            outputs.Push(grayTallCovered)
            AhkTest.AssertEqual("L", grayTallCovered.mode)
            AhkTest.AssertEqual([3, 6], grayTallCovered.size)

            rgbaSame := stdlib.pillow.Image.new("RGBA", [2, 1], [1, 2, 3, 4])
            rgbaSame.putpixel([1, 0], [100, 110, 120, 130])
            rgbaSameCovered := stdlib.pillow.ImageOps.cover(rgbaSame, [2, 1])
            outputs.Push(rgbaSameCovered)
            AhkTest.AssertEqual("RGBA", rgbaSameCovered.mode)
            AhkTest.AssertEqual([2, 1], rgbaSameCovered.size)
            AhkTest.AssertEqual([[[1, 2, 3, 4], [100, 110, 120, 130]]], StdlibPillowTest.PixelRows(rgbaSameCovered))
            AhkTest.AssertTrue(ObjPtr(rgbaSameCovered) != ObjPtr(rgbaSame))

            rgbScaled := stdlib.pillow.ImageOps.scale(rgbWide, 0.5)
            outputs.Push(rgbScaled)
            AhkTest.AssertEqual("RGB", rgbScaled.mode)
            AhkTest.AssertEqual([2, 1], rgbScaled.size)
            AhkTest.AssertTrue(ObjPtr(rgbScaled) != ObjPtr(rgbWide))

            grayScaled := stdlib.pillow.ImageOps.scale(grayTall, 1.5)
            outputs.Push(grayScaled)
            AhkTest.AssertEqual("L", grayScaled.mode)
            AhkTest.AssertEqual([3, 6], grayScaled.size)

            rgbaSameScaled := stdlib.pillow.ImageOps.scale(rgbaSame, 1)
            outputs.Push(rgbaSameScaled)
            AhkTest.AssertEqual([2, 1], rgbaSameScaled.size)
            AhkTest.AssertEqual([[[1, 2, 3, 4], [100, 110, 120, 130]]], StdlibPillowTest.PixelRows(rgbaSameScaled))
            AhkTest.AssertTrue(ObjPtr(rgbaSameScaled) != ObjPtr(rgbaSame))

            coverZeroWidth := stdlib.pillow.ImageOps.cover(rgbWide, [0, 3])
            outputs.Push(coverZeroWidth)
            AhkTest.AssertEqual([6, 3], coverZeroWidth.size)

            AhkTest.RaisesMatch(AttributeError, "^'NoneType' object has no attribute 'width'$", (*) => stdlib.pillow.ImageOps.cover(stdlib.None, [1, 1]))
            AhkTest.RaisesMatch(IndexError, "^tuple index out of range$", (*) => stdlib.pillow.ImageOps.cover(rgbWide, [3]))
            AhkTest.RaisesMatch(ZeroDivisionError, "^division by zero$", (*) => stdlib.pillow.ImageOps.cover(rgbWide, [3, 0]))
            AhkTest.RaisesMatch(AttributeError, "^'NoneType' object has no attribute 'copy'$", (*) => stdlib.pillow.ImageOps.scale(stdlib.None, 1))
            AhkTest.RaisesMatch(TypeError, "^'<=' not supported between instances of 'str' and 'int'$", (*) => stdlib.pillow.ImageOps.scale(rgbWide, "2"))
            AhkTest.RaisesMatch(ValueError, "^the factor must be greater than 0$", (*) => stdlib.pillow.ImageOps.scale(rgbWide, 0))
        } finally {
            for image in outputs
                StdlibPillowTest.CloseImage(image)
            if IsSet(rgbaSame)
                StdlibPillowTest.CloseImage(rgbaSame)
            if IsSet(grayTall)
                StdlibPillowTest.CloseImage(grayTall)
            if IsSet(rgbWide)
                StdlibPillowTest.CloseImage(rgbWide)
        }
    }

    static TestImageOpsPadAndFitMatchLocalPillow113()
    {
        rgbWide := unset
        grayTall := unset
        rgbaSame := unset
        outputs := []
        try {
            rgbWide := stdlib.pillow.Image.new("RGB", [4, 2], [10, 20, 30])
            rgbPadded := stdlib.pillow.ImageOps.pad(rgbWide, [4, 4], unset, [1, 2, 3], [0, 0])
            outputs.Push(rgbPadded)
            AhkTest.AssertEqual("RGB", rgbPadded.mode)
            AhkTest.AssertEqual([4, 4], rgbPadded.size)
            AhkTest.AssertEqual([
                [[10, 20, 30], [10, 20, 30], [10, 20, 30], [10, 20, 30]],
                [[10, 20, 30], [10, 20, 30], [10, 20, 30], [10, 20, 30]],
                [[1, 2, 3], [1, 2, 3], [1, 2, 3], [1, 2, 3]],
                [[1, 2, 3], [1, 2, 3], [1, 2, 3], [1, 2, 3]],
            ], StdlibPillowTest.PixelRows(rgbPadded))
            AhkTest.AssertTrue(ObjPtr(rgbPadded) != ObjPtr(rgbWide))

            grayTall := stdlib.pillow.Image.new("L", [2, 4], 90)
            grayPadded := stdlib.pillow.ImageOps.pad(grayTall, [4, 4], unset, 7, [1, 1])
            outputs.Push(grayPadded)
            AhkTest.AssertEqual("L", grayPadded.mode)
            AhkTest.AssertEqual([4, 4], grayPadded.size)
            AhkTest.AssertEqual([[7, 7, 90, 90], [7, 7, 90, 90], [7, 7, 90, 90], [7, 7, 90, 90]], StdlibPillowTest.PixelRows(grayPadded))

            rgbaSame := stdlib.pillow.Image.new("RGBA", [2, 1], [1, 2, 3, 4])
            rgbaSame.putpixel([1, 0], [100, 110, 120, 130])
            rgbaPadded := stdlib.pillow.ImageOps.pad(rgbaSame, [2, 1])
            outputs.Push(rgbaPadded)
            AhkTest.AssertEqual([2, 1], rgbaPadded.size)
            AhkTest.AssertEqual([[[1, 2, 3, 4], [100, 110, 120, 130]]], StdlibPillowTest.PixelRows(rgbaPadded))
            AhkTest.AssertTrue(ObjPtr(rgbaPadded) != ObjPtr(rgbaSame))

            rgbFit := stdlib.pillow.ImageOps.fit(rgbWide, [2, 2])
            outputs.Push(rgbFit)
            AhkTest.AssertEqual("RGB", rgbFit.mode)
            AhkTest.AssertEqual([2, 2], rgbFit.size)
            AhkTest.AssertTrue(ObjPtr(rgbFit) != ObjPtr(rgbWide))

            grayFit := stdlib.pillow.ImageOps.fit(grayTall, [2, 2], unset, 0.1, [0, 1])
            outputs.Push(grayFit)
            AhkTest.AssertEqual("L", grayFit.mode)
            AhkTest.AssertEqual([2, 2], grayFit.size)

            rgbaFit := stdlib.pillow.ImageOps.fit(rgbaSame, [2, 1])
            outputs.Push(rgbaFit)
            AhkTest.AssertEqual([2, 1], rgbaFit.size)
            AhkTest.AssertEqual([[[1, 2, 3, 4], [100, 110, 120, 130]]], StdlibPillowTest.PixelRows(rgbaFit))
            AhkTest.AssertTrue(ObjPtr(rgbaFit) != ObjPtr(rgbaSame))

            AhkTest.RaisesMatch(AttributeError, "^'NoneType' object has no attribute 'width'$", (*) => stdlib.pillow.ImageOps.pad(stdlib.None, [1, 1]))
            AhkTest.RaisesMatch(IndexError, "^tuple index out of range$", (*) => stdlib.pillow.ImageOps.pad(rgbWide, [4]))
            AhkTest.RaisesMatch(ZeroDivisionError, "^division by zero$", (*) => stdlib.pillow.ImageOps.pad(rgbWide, [4, 0]))
            AhkTest.RaisesMatch(AttributeError, "^'NoneType' object has no attribute 'size'$", (*) => stdlib.pillow.ImageOps.fit(stdlib.None, [1, 1]))
            AhkTest.RaisesMatch(IndexError, "^tuple index out of range$", (*) => stdlib.pillow.ImageOps.fit(rgbWide, [2]))
            AhkTest.RaisesMatch(ZeroDivisionError, "^division by zero$", (*) => stdlib.pillow.ImageOps.fit(rgbWide, [2, 0]))
            AhkTest.RaisesMatch(TypeError, "^cannot unpack non-iterable NoneType object$", (*) => stdlib.pillow.ImageOps.fit(rgbWide, [2, 2], unset, 0, stdlib.None))
        } finally {
            for image in outputs
                StdlibPillowTest.CloseImage(image)
            if IsSet(rgbaSame)
                StdlibPillowTest.CloseImage(rgbaSame)
            if IsSet(grayTall)
                StdlibPillowTest.CloseImage(grayTall)
            if IsSet(rgbWide)
                StdlibPillowTest.CloseImage(rgbWide)
        }
    }

    static TestImageOpsAutocontrastMatchesLocalPillow113()
    {
        gray := unset
        rgb := unset
        rgba := unset
        flat := unset
        mask := unset
        outputs := []
        try {
            gray := stdlib.pillow.Image.new("L", [4, 1], 0)
            gray.putpixel([0, 0], 10)
            gray.putpixel([1, 0], 20)
            gray.putpixel([2, 0], 100)
            gray.putpixel([3, 0], 200)

            grayAuto := stdlib.pillow.ImageOps.autocontrast(gray)
            outputs.Push(grayAuto)
            AhkTest.AssertEqual("L", grayAuto.mode)
            AhkTest.AssertEqual([4, 1], grayAuto.size)
            AhkTest.AssertEqual([[0, 13, 120, 255]], StdlibPillowTest.PixelRows(grayAuto))
            AhkTest.AssertTrue(ObjPtr(grayAuto) != ObjPtr(gray))

            grayIgnore := stdlib.pillow.ImageOps.autocontrast(gray, 0, 10)
            outputs.Push(grayIgnore)
            AhkTest.AssertEqual([[0, 0, 113, 255]], StdlibPillowTest.PixelRows(grayIgnore))

            grayCutoff := stdlib.pillow.ImageOps.autocontrast(gray, 25)
            outputs.Push(grayCutoff)
            AhkTest.AssertEqual([[0, 0, 255, 255]], StdlibPillowTest.PixelRows(grayCutoff))

            mask := stdlib.pillow.Image.new("L", [4, 1], 0)
            mask.putpixel([1, 0], 255)
            mask.putpixel([2, 0], 255)
            grayMask := stdlib.pillow.ImageOps.autocontrast(gray, 0, stdlib.None, mask)
            outputs.Push(grayMask)
            AhkTest.AssertEqual([[0, 0, 255, 255]], StdlibPillowTest.PixelRows(grayMask))

            rgb := stdlib.pillow.Image.new("RGB", [3, 1], [0, 0, 0])
            rgb.putpixel([0, 0], [10, 50, 100])
            rgb.putpixel([1, 0], [20, 100, 150])
            rgb.putpixel([2, 0], [200, 200, 250])
            rgbAuto := stdlib.pillow.ImageOps.autocontrast(rgb)
            outputs.Push(rgbAuto)
            AhkTest.AssertEqual("RGB", rgbAuto.mode)
            AhkTest.AssertEqual([[[0, 0, 0], [13, 85, 85], [255, 255, 255]]], StdlibPillowTest.PixelRows(rgbAuto))

            flat := stdlib.pillow.Image.new("L", [2, 1], 90)
            flatAuto := stdlib.pillow.ImageOps.autocontrast(flat)
            outputs.Push(flatAuto)
            AhkTest.AssertEqual([[90, 90]], StdlibPillowTest.PixelRows(flatAuto))
            AhkTest.AssertTrue(ObjPtr(flatAuto) != ObjPtr(flat))

            rgba := stdlib.pillow.Image.new("RGBA", [2, 1], [1, 2, 3, 4])
            AhkTest.RaisesMatch(OSError, "^not supported for mode RGBA$", (*) => stdlib.pillow.ImageOps.autocontrast(rgba))
            AhkTest.RaisesMatch(AttributeError, "^'NoneType' object has no attribute 'histogram'$", (*) => stdlib.pillow.ImageOps.autocontrast(stdlib.None))
            AhkTest.RaisesMatch(TypeError, "^list indices must be integers or slices, not str$", (*) => stdlib.pillow.ImageOps.autocontrast(gray, 0, "x"))
            AhkTest.RaisesMatch(TypeError, "^unsupported operand type\(s\) for //: 'str' and 'int'$", (*) => stdlib.pillow.ImageOps.autocontrast(gray, "x"))
            AhkTest.RaisesMatch(ValueError, "^images do not match$", (*) => stdlib.pillow.ImageOps.autocontrast(gray, 0, stdlib.None, rgb))
        } finally {
            for image in outputs
                StdlibPillowTest.CloseImage(image)
            if IsSet(mask)
                StdlibPillowTest.CloseImage(mask)
            if IsSet(flat)
                StdlibPillowTest.CloseImage(flat)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
        }
    }

    static TestImageOpsEqualizeMatchesLocalPillow113()
    {
        gray := unset
        mapped := unset
        rgb := unset
        rgba := unset
        flat := unset
        mask := unset
        outputs := []
        try {
            gray := stdlib.pillow.Image.new("L", [4, 1], 0)
            gray.putpixel([0, 0], 10)
            gray.putpixel([1, 0], 20)
            gray.putpixel([2, 0], 100)
            gray.putpixel([3, 0], 200)

            grayEqualized := stdlib.pillow.ImageOps.equalize(gray)
            outputs.Push(grayEqualized)
            AhkTest.AssertEqual("L", grayEqualized.mode)
            AhkTest.AssertEqual([4, 1], grayEqualized.size)
            AhkTest.AssertEqual([[10, 20, 100, 200]], StdlibPillowTest.PixelRows(grayEqualized))
            AhkTest.AssertTrue(ObjPtr(grayEqualized) != ObjPtr(gray))

            mapped := stdlib.pillow.Image.new("L", [512, 1], 0)
            loop 256
                mapped.putpixel([A_Index - 1, 0], 10)
            loop 255
                mapped.putpixel([A_Index + 255, 0], 100)
            mapped.putpixel([511, 0], 200)
            mappedEqualized := stdlib.pillow.ImageOps.equalize(mapped)
            outputs.Push(mappedEqualized)
            AhkTest.AssertEqual([512, 1], mappedEqualized.size)
            AhkTest.AssertEqual(0, mappedEqualized.getpixel([0, 0]))
            AhkTest.AssertEqual(0, mappedEqualized.getpixel([255, 0]))
            AhkTest.AssertEqual(128, mappedEqualized.getpixel([256, 0]))
            AhkTest.AssertEqual(128, mappedEqualized.getpixel([510, 0]))
            AhkTest.AssertEqual(255, mappedEqualized.getpixel([511, 0]))

            mask := stdlib.pillow.Image.new("L", [4, 1], 0)
            mask.putpixel([1, 0], 255)
            mask.putpixel([2, 0], 255)
            grayMask := stdlib.pillow.ImageOps.equalize(gray, mask)
            outputs.Push(grayMask)
            AhkTest.AssertEqual([[10, 20, 100, 200]], StdlibPillowTest.PixelRows(grayMask))

            rgb := stdlib.pillow.Image.new("RGB", [3, 1], [0, 0, 0])
            rgb.putpixel([0, 0], [10, 50, 100])
            rgb.putpixel([1, 0], [20, 100, 150])
            rgb.putpixel([2, 0], [200, 200, 250])
            rgbEqualized := stdlib.pillow.ImageOps.equalize(rgb)
            outputs.Push(rgbEqualized)
            AhkTest.AssertEqual("RGB", rgbEqualized.mode)
            AhkTest.AssertEqual([[[10, 50, 100], [20, 100, 150], [200, 200, 250]]], StdlibPillowTest.PixelRows(rgbEqualized))

            flat := stdlib.pillow.Image.new("L", [2, 1], 90)
            flatEqualized := stdlib.pillow.ImageOps.equalize(flat)
            outputs.Push(flatEqualized)
            AhkTest.AssertEqual([[90, 90]], StdlibPillowTest.PixelRows(flatEqualized))
            AhkTest.AssertTrue(ObjPtr(flatEqualized) != ObjPtr(flat))

            rgba := stdlib.pillow.Image.new("RGBA", [2, 1], [10, 20, 30, 40])
            AhkTest.RaisesMatch(AttributeError, "^'NoneType' object has no attribute 'mode'$", (*) => stdlib.pillow.ImageOps.equalize(stdlib.None))
            AhkTest.RaisesMatch(OSError, "^not supported for mode RGBA$", (*) => stdlib.pillow.ImageOps.equalize(rgba))
            AhkTest.RaisesMatch(ValueError, "^images do not match$", (*) => stdlib.pillow.ImageOps.equalize(gray, rgb))
        } finally {
            for image in outputs
                StdlibPillowTest.CloseImage(image)
            if IsSet(mask)
                StdlibPillowTest.CloseImage(mask)
            if IsSet(flat)
                StdlibPillowTest.CloseImage(flat)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
            if IsSet(mapped)
                StdlibPillowTest.CloseImage(mapped)
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
        }
    }

    static TestImageOpsColorizeMatchesLocalPillow113()
    {
        source := unset
        three := unset
        points := unset
        rgb := unset
        outputs := []
        try {
            source := stdlib.pillow.Image.new("L", [6, 1], 0)
            for item in [
                [[0, 0], 0],
                [[1, 0], 1],
                [[2, 0], 63],
                [[3, 0], 127],
                [[4, 0], 128],
                [[5, 0], 255],
            ]
                source.putpixel(item[1], item[2])

            twoColor := stdlib.pillow.ImageOps.colorize(source, "black", "white")
            outputs.Push(twoColor)
            AhkTest.AssertEqual("RGB", twoColor.mode)
            AhkTest.AssertEqual([6, 1], twoColor.size)
            AhkTest.AssertEqual([[[0, 0, 0], [1, 1, 1], [63, 63, 63], [127, 127, 127], [128, 128, 128], [255, 255, 255]]], StdlibPillowTest.PixelRows(twoColor))
            AhkTest.AssertTrue(ObjPtr(twoColor) != ObjPtr(source))

            tupleColors := stdlib.pillow.ImageOps.colorize(source, [10, 20, 30], [210, 220, 230])
            outputs.Push(tupleColors)
            AhkTest.AssertEqual([[[10, 20, 30], [10, 20, 30], [59, 69, 79], [109, 119, 129], [110, 120, 130], [210, 220, 230]]], StdlibPillowTest.PixelRows(tupleColors))
            AhkTest.AssertEqual([[0, 1, 63, 127, 128, 255]], StdlibPillowTest.PixelRows(source))

            three := stdlib.pillow.Image.new("L", [5, 1], 0)
            for item in [
                [[0, 0], 0],
                [[1, 0], 64],
                [[2, 0], 128],
                [[3, 0], 192],
                [[4, 0], 255],
            ]
                three.putpixel(item[1], item[2])
            threeColor := stdlib.pillow.ImageOps.colorize(three, "black", "#804020", "white", 0, 255, 128)
            outputs.Push(threeColor)
            AhkTest.AssertEqual([[[0, 0, 0], [127, 127, 127], [255, 255, 255], [191, 158, 142], [128, 64, 32]]], StdlibPillowTest.PixelRows(threeColor))

            points := stdlib.pillow.Image.new("L", [8, 1], 0)
            for item in [
                [[0, 0], 0],
                [[1, 0], 9],
                [[2, 0], 10],
                [[3, 0], 60],
                [[4, 0], 120],
                [[5, 0], 180],
                [[6, 0], 200],
                [[7, 0], 255],
            ]
                points.putpixel(item[1], item[2])
            pointColor := stdlib.pillow.ImageOps.colorize(points, [0, 10, 20], [200, 210, 220], [100, 120, 140], 10, 200, 120)
            outputs.Push(pointColor)
            AhkTest.AssertEqual([[[0, 10, 20], [0, 10, 20], [0, 10, 20], [45, 60, 74], [100, 120, 140], [175, 187, 200], [200, 210, 220], [200, 210, 220]]], StdlibPillowTest.PixelRows(pointColor))

            rgb := stdlib.pillow.Image.new("RGB", [1, 1], [1, 2, 3])
            AhkTest.RaisesMatch(stdlib.assert.AssertionError, "^$", (*) => stdlib.pillow.ImageOps.colorize(rgb, "black", "white"))
            AhkTest.RaisesMatch(stdlib.assert.AssertionError, "^$", (*) => stdlib.pillow.ImageOps.colorize(source, "black", "white", stdlib.None, 20, 10))
            AhkTest.RaisesMatch(stdlib.assert.AssertionError, "^$", (*) => stdlib.pillow.ImageOps.colorize(source, "black", "white", "red", 0, 200, 250))
            AhkTest.RaisesMatch(ValueError, "^unknown color specifier: 'no-such'$", (*) => stdlib.pillow.ImageOps.colorize(source, "no-such", "white"))
            AhkTest.RaisesMatch(AttributeError, "^'NoneType' object has no attribute 'mode'$", (*) => stdlib.pillow.ImageOps.colorize(stdlib.None, "black", "white"))
            AhkTest.RaisesMatch(TypeError, "^'int' object is not subscriptable$", (*) => stdlib.pillow.ImageOps.colorize(source, 1, "white"))
        } finally {
            for image in outputs
                StdlibPillowTest.CloseImage(image)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
            if IsSet(points)
                StdlibPillowTest.CloseImage(points)
            if IsSet(three)
                StdlibPillowTest.CloseImage(three)
            if IsSet(source)
                StdlibPillowTest.CloseImage(source)
        }
    }

    static TestImageOpsDeformMatchesLocalPillow113()
    {
        rgb := unset
        gray := unset
        outputs := []
        try {
            rgb := stdlib.pillow.Image.new("RGB", [4, 2], [0, 0, 0])
            for item in [
                [[0, 0], [10, 20, 30]], [[1, 0], [40, 50, 60]], [[2, 0], [70, 80, 90]], [[3, 0], [100, 110, 120]],
                [[0, 1], [130, 140, 150]], [[1, 1], [160, 170, 180]], [[2, 1], [190, 200, 210]], [[3, 1], [220, 230, 240]],
            ]
                rgb.putpixel(item[1], item[2])

            identityDeformer := StdlibPillowIdentityMeshDeformer()
            identity := stdlib.pillow.ImageOps.deform(rgb, identityDeformer)
            outputs.Push(identity)
            AhkTest.AssertEqual("RGB", identity.mode)
            AhkTest.AssertEqual([4, 2], identity.size)
            AhkTest.AssertEqual([
                [[10, 20, 30], [40, 50, 60], [70, 80, 90], [100, 110, 120]],
                [[130, 140, 150], [160, 170, 180], [190, 200, 210], [220, 230, 240]],
            ], StdlibPillowTest.PixelRows(identity))
            AhkTest.AssertTrue(ObjPtr(identity) != ObjPtr(rgb))
            AhkTest.AssertEqual([[4, 2, true]], identityDeformer.Calls)

            shiftDeformer := StdlibPillowShiftMeshDeformer()
            shifted := stdlib.pillow.ImageOps.deform(rgb, shiftDeformer)
            outputs.Push(shifted)
            AhkTest.AssertEqual([
                [[70, 80, 90], [100, 110, 120], [10, 20, 30], [40, 50, 60]],
                [[190, 200, 210], [220, 230, 240], [130, 140, 150], [160, 170, 180]],
            ], StdlibPillowTest.PixelRows(shifted))
            AhkTest.AssertEqual([[4, 2]], shiftDeformer.Calls)
            AhkTest.AssertEqual([
                [[10, 20, 30], [40, 50, 60], [70, 80, 90], [100, 110, 120]],
                [[130, 140, 150], [160, 170, 180], [190, 200, 210], [220, 230, 240]],
            ], StdlibPillowTest.PixelRows(rgb))

            gray := stdlib.pillow.Image.new("L", [4, 2], 0)
            for item in [
                [[0, 0], 10], [[1, 0], 20], [[2, 0], 30], [[3, 0], 40],
                [[0, 1], 50], [[1, 1], 60], [[2, 1], 70], [[3, 1], 80],
            ]
                gray.putpixel(item[1], item[2])
            grayShift := stdlib.pillow.ImageOps.deform(gray, StdlibPillowShiftMeshDeformer())
            outputs.Push(grayShift)
            AhkTest.AssertEqual("L", grayShift.mode)
            AhkTest.AssertEqual([[30, 40, 10, 20], [70, 80, 50, 60]], StdlibPillowTest.PixelRows(grayShift))

            empty := stdlib.pillow.ImageOps.deform(rgb, StdlibPillowEmptyMeshDeformer())
            outputs.Push(empty)
            AhkTest.AssertEqual([
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
            ], StdlibPillowTest.PixelRows(empty))

            AhkTest.RaisesMatch(AttributeError, "^'NoneType' object has no attribute 'transform'$", (*) => stdlib.pillow.ImageOps.deform(stdlib.None, StdlibPillowIdentityMeshDeformer()))
            AhkTest.RaisesMatch(AttributeError, "^'NoneType' object has no attribute 'getmesh'$", (*) => stdlib.pillow.ImageOps.deform(rgb, stdlib.None))
            AhkTest.RaisesMatch(ValueError, "^missing method data$", (*) => stdlib.pillow.ImageOps.deform(rgb, StdlibPillowBadNoneMeshDeformer()))
            AhkTest.RaisesMatch(IndexError, "^tuple index out of range$", (*) => stdlib.pillow.ImageOps.deform(rgb, StdlibPillowBadItemMeshDeformer()))
        } finally {
            for image in outputs
                StdlibPillowTest.CloseImage(image)
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
        }
    }

    static TestImageOpsExifTransposeMatchesLocalPillow113()
    {
        rgb := unset
        noOrientation := unset
        orientationOne := unset
        gray := unset
        inPlace := unset
        inPlaceNoOrientation := unset
        outputs := []
        orientationTag := 274
        try {
            noOrientation := StdlibPillowTest.TransformSourceImage()
            noOrientationResult := stdlib.pillow.ImageOps.exif_transpose(noOrientation)
            outputs.Push(noOrientationResult)
            AhkTest.AssertEqual([3, 2], noOrientationResult.size)
            AhkTest.AssertEqual(StdlibPillowTest.PixelRows(noOrientation), StdlibPillowTest.PixelRows(noOrientationResult))
            AhkTest.AssertTrue(ObjPtr(noOrientationResult) != ObjPtr(noOrientation))
            AhkTest.AssertFalse(noOrientationResult.getexif().Has(orientationTag))

            orientationOne := StdlibPillowTest.TransformSourceImage()
            orientationOne.getexif()[orientationTag] := 1
            orientationOneResult := stdlib.pillow.ImageOps.exif_transpose(orientationOne)
            outputs.Push(orientationOneResult)
            AhkTest.AssertEqual(StdlibPillowTest.PixelRows(orientationOne), StdlibPillowTest.PixelRows(orientationOneResult))
            AhkTest.AssertEqual(1, orientationOne.getexif()[orientationTag])
            AhkTest.AssertFalse(orientationOneResult.getexif().Has(orientationTag))

            rgb := StdlibPillowTest.TransformSourceImage()
            expectedRows := Map(
                2, [
                    [[70, 80, 90], [40, 50, 60], [10, 20, 30]],
                    [[160, 170, 180], [130, 140, 150], [100, 110, 120]],
                ],
                3, [
                    [[160, 170, 180], [130, 140, 150], [100, 110, 120]],
                    [[70, 80, 90], [40, 50, 60], [10, 20, 30]],
                ],
                4, [
                    [[100, 110, 120], [130, 140, 150], [160, 170, 180]],
                    [[10, 20, 30], [40, 50, 60], [70, 80, 90]],
                ],
                5, [
                    [[10, 20, 30], [100, 110, 120]],
                    [[40, 50, 60], [130, 140, 150]],
                    [[70, 80, 90], [160, 170, 180]],
                ],
                6, [
                    [[100, 110, 120], [10, 20, 30]],
                    [[130, 140, 150], [40, 50, 60]],
                    [[160, 170, 180], [70, 80, 90]],
                ],
                7, [
                    [[160, 170, 180], [70, 80, 90]],
                    [[130, 140, 150], [40, 50, 60]],
                    [[100, 110, 120], [10, 20, 30]],
                ],
                8, [
                    [[70, 80, 90], [160, 170, 180]],
                    [[40, 50, 60], [130, 140, 150]],
                    [[10, 20, 30], [100, 110, 120]],
                ],
            )
            for orientation in [2, 3, 4, 5, 6, 7, 8] {
                oriented := rgb.copy()
                outputs.Push(oriented)
                oriented.getexif()[orientationTag] := orientation
                transposed := stdlib.pillow.ImageOps.exif_transpose(oriented)
                outputs.Push(transposed)
                AhkTest.AssertEqual(expectedRows[orientation], StdlibPillowTest.PixelRows(transposed))
                AhkTest.AssertEqual(orientation, oriented.getexif()[orientationTag])
                AhkTest.AssertFalse(transposed.getexif().Has(orientationTag))
                AhkTest.AssertTrue(ObjPtr(transposed) != ObjPtr(oriented))
            }

            gray := stdlib.pillow.Image.new("L", [3, 2], 0)
            for item in [
                [[0, 0], 10], [[1, 0], 20], [[2, 0], 30],
                [[0, 1], 40], [[1, 1], 50], [[2, 1], 60],
            ]
                gray.putpixel(item[1], item[2])
            gray.getexif()[orientationTag] := 6
            grayTransposed := stdlib.pillow.ImageOps.exif_transpose(gray)
            outputs.Push(grayTransposed)
            AhkTest.AssertEqual("L", grayTransposed.mode)
            AhkTest.AssertEqual([[40, 10], [50, 20], [60, 30]], StdlibPillowTest.PixelRows(grayTransposed))

            inPlace := StdlibPillowTest.TransformSourceImage()
            inPlace.getexif()[orientationTag] := 6
            AhkTest.AssertSame(stdlib.None, stdlib.pillow.ImageOps.exif_transpose(inPlace, { in_place: true }))
            AhkTest.AssertEqual([2, 3], inPlace.size)
            AhkTest.AssertEqual(expectedRows[6], StdlibPillowTest.PixelRows(inPlace))
            AhkTest.AssertFalse(inPlace.getexif().Has(orientationTag))

            inPlaceNoOrientation := StdlibPillowTest.TransformSourceImage()
            AhkTest.AssertSame(stdlib.None, stdlib.pillow.ImageOps.exif_transpose(inPlaceNoOrientation, { in_place: true }))
            AhkTest.AssertEqual([
                [[10, 20, 30], [40, 50, 60], [70, 80, 90]],
                [[100, 110, 120], [130, 140, 150], [160, 170, 180]],
            ], StdlibPillowTest.PixelRows(inPlaceNoOrientation))

            AhkTest.RaisesMatch(AttributeError, "^'NoneType' object has no attribute 'load'$", (*) => stdlib.pillow.ImageOps.exif_transpose(stdlib.None))
            AhkTest.RaisesMatch(TypeError, "^exif_transpose\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.pillow.ImageOps.exif_transpose(inPlaceNoOrientation, true))
        } finally {
            for image in outputs
                StdlibPillowTest.CloseImage(image)
            if IsSet(inPlaceNoOrientation)
                StdlibPillowTest.CloseImage(inPlaceNoOrientation)
            if IsSet(inPlace)
                StdlibPillowTest.CloseImage(inPlace)
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
            if IsSet(orientationOne)
                StdlibPillowTest.CloseImage(orientationOne)
            if IsSet(noOrientation)
                StdlibPillowTest.CloseImage(noOrientation)
        }
    }

    static TestImageEnhanceMatchesLocalPillow113()
    {
        gray := unset
        rgb := unset
        rgba := unset
        rgb5 := unset
        outputs := []
        try {
            AhkTest.AssertTrue(HasProp(stdlib.pillow, "ImageEnhance"))
            gray := StdlibPillowTest.ChopsLImageA()
            rgb := StdlibPillowTest.OpsRgbImage()
            rgba := stdlib.pillow.Image.new("RGBA", [2, 2], [10, 20, 30, 40])
            rgba.putpixel([1, 0], [100, 110, 120, 130])
            rgba.putpixel([0, 1], [200, 210, 220, 230])
            rgba.putpixel([1, 1], [250, 5, 128, 255])
            rgb5 := StdlibPillowTest.FilterSourceImage("RGB")

            rgbBrightnessHalf := stdlib.pillow.ImageEnhance.Brightness(rgb).enhance(0.5)
            outputs.Push(rgbBrightnessHalf)
            AhkTest.AssertEqual([[[5, 10, 15], [50, 55, 60], [100, 105, 110]], [[125, 2, 64], [20, 40, 80], [0, 127, 5]]], StdlibPillowTest.PixelRows(rgbBrightnessHalf))
            rgbBrightnessHigh := stdlib.pillow.ImageEnhance.Brightness(rgb).enhance(1.5)
            outputs.Push(rgbBrightnessHigh)
            AhkTest.AssertEqual([[[15, 30, 45], [150, 165, 180], [255, 255, 255]], [[255, 7, 192], [60, 120, 240], [0, 255, 15]]], StdlibPillowTest.PixelRows(rgbBrightnessHigh))
            grayBrightness := stdlib.pillow.ImageEnhance.Brightness(gray).enhance(0.5)
            outputs.Push(grayBrightness)
            AhkTest.AssertEqual([[5, 50, 125], [0, 64, 127]], StdlibPillowTest.PixelRows(grayBrightness))
            rgbaBrightnessZero := stdlib.pillow.ImageEnhance.Brightness(rgba).enhance(0)
            outputs.Push(rgbaBrightnessZero)
            AhkTest.AssertEqual([[[0, 0, 0, 40], [0, 0, 0, 130]], [[0, 0, 0, 230], [0, 0, 0, 255]]], StdlibPillowTest.PixelRows(rgbaBrightnessZero))

            rgbColorZero := stdlib.pillow.ImageEnhance.Color(rgb).enhance(0)
            outputs.Push(rgbColorZero)
            AhkTest.AssertEqual([[[18, 18, 18], [108, 108, 108], [208, 208, 208]], [[92, 92, 92], [77, 77, 77], [151, 151, 151]]], StdlibPillowTest.PixelRows(rgbColorZero))
            rgbColorHigh := stdlib.pillow.ImageEnhance.Color(rgb).enhance(1.5)
            outputs.Push(rgbColorHigh)
            AhkTest.AssertEqual([[[6, 21, 36], [96, 111, 126], [196, 211, 226]], [[255, 0, 146], [21, 81, 201], [0, 255, 0]]], StdlibPillowTest.PixelRows(rgbColorHigh))
            rgbaColorZero := stdlib.pillow.ImageEnhance.Color(rgba).enhance(0)
            outputs.Push(rgbaColorZero)
            AhkTest.AssertEqual([[[18, 18, 18, 40], [108, 108, 108, 130]], [[208, 208, 208, 230], [92, 92, 92, 255]]], StdlibPillowTest.PixelRows(rgbaColorZero))

            rgbContrastZero := stdlib.pillow.ImageEnhance.Contrast(rgb).enhance(0)
            outputs.Push(rgbContrastZero)
            AhkTest.AssertEqual([[[109, 109, 109], [109, 109, 109], [109, 109, 109]], [[109, 109, 109], [109, 109, 109], [109, 109, 109]]], StdlibPillowTest.PixelRows(rgbContrastZero))
            rgbContrastHigh := stdlib.pillow.ImageEnhance.Contrast(rgb).enhance(1.5)
            outputs.Push(rgbContrastHigh)
            AhkTest.AssertEqual([[[0, 0, 0], [95, 110, 125], [245, 255, 255]], [[255, 0, 137], [5, 65, 185], [0, 255, 0]]], StdlibPillowTest.PixelRows(rgbContrastHigh))

            sharpnessZero := stdlib.pillow.ImageEnhance.Sharpness(rgb5).enhance(0)
            outputs.Push(sharpnessZero)
            AhkTest.AssertEqual([134, 130, 133], sharpnessZero.getpixel([2, 2]))
            AhkTest.AssertEqual([100, 175, 128], sharpnessZero.getpixel([3, 2]))
            sharpnessHalf := stdlib.pillow.ImageEnhance.Sharpness(rgb5).enhance(0.5)
            outputs.Push(sharpnessHalf)
            AhkTest.AssertEqual([150, 130, 127], sharpnessHalf.getpixel([2, 2]))
            sharpnessHigh := stdlib.pillow.ImageEnhance.Sharpness(rgb5).enhance(1.5)
            outputs.Push(sharpnessHigh)
            AhkTest.AssertEqual([182, 130, 116], sharpnessHigh.getpixel([2, 2]))
            AhkTest.AssertEqual([57, 205, 255], sharpnessHigh.getpixel([3, 3]))

            AhkTest.RaisesMatch(AttributeError, "^'NoneType' object has no attribute 'mode'$", (*) => stdlib.pillow.ImageEnhance.Brightness(stdlib.None))
            AhkTest.RaisesMatch(TypeError, "^must be real number, not str$", (*) => stdlib.pillow.ImageEnhance.Brightness(rgb).enhance("x"))
        } finally {
            for image in outputs
                StdlibPillowTest.CloseImage(image)
            if IsSet(rgb5)
                StdlibPillowTest.CloseImage(rgb5)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
        }
    }

    static TestImageColorMatchesLocalPillow113()
    {
        rgbImage := unset
        rgbaImage := unset
        grayImage := unset
        try {
            AhkTest.AssertTrue(HasProp(stdlib.pillow, "ImageColor"))
            AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageColor, "getrgb"))
            AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageColor, "getcolor"))

            AhkTest.AssertEqual([170, 187, 204], stdlib.pillow.ImageColor.getrgb("#abc"))
            AhkTest.AssertEqual([170, 187, 204, 221], stdlib.pillow.ImageColor.getrgb("#abcd"))
            AhkTest.AssertEqual([161, 178, 195], stdlib.pillow.ImageColor.getrgb("#a1b2c3"))
            AhkTest.AssertEqual([161, 178, 195, 212], stdlib.pillow.ImageColor.getrgb("#a1b2c3d4"))
            AhkTest.AssertEqual([1, 2, 3], stdlib.pillow.ImageColor.getrgb("RGB(1, 2, 3)"))
            AhkTest.AssertEqual([26, 51, 77], stdlib.pillow.ImageColor.getrgb("rgb(10%,20%,30%)"))
            AhkTest.AssertEqual([1, 2, 3, 4], stdlib.pillow.ImageColor.getrgb("rgba(1, 2, 3, 4)"))
            AhkTest.AssertEqual([32, 96, 32], stdlib.pillow.ImageColor.getrgb("hsl(120, 50%, 25%)"))
            AhkTest.AssertEqual([64, 64, 128], stdlib.pillow.ImageColor.getrgb("hsv(240, 50%, 50%)"))
            AhkTest.AssertEqual([204, 204, 153], stdlib.pillow.ImageColor.getrgb("hsb(60, 25%, 80%)"))
            AhkTest.AssertEqual([0, 0, 128], stdlib.pillow.ImageColor.getrgb("navy"))
            AhkTest.AssertEqual([102, 51, 153], stdlib.pillow.ImageColor.getrgb("rebeccapurple"))

            AhkTest.AssertEqual([0, 0, 128], stdlib.pillow.ImageColor.getcolor("navy", "RGB"))
            AhkTest.AssertEqual([0, 0, 128, 255], stdlib.pillow.ImageColor.getcolor("navy", "RGBA"))
            AhkTest.AssertEqual([2, 4], stdlib.pillow.ImageColor.getcolor("rgba(1, 2, 3, 4)", "LA"))
            AhkTest.AssertEqual(255, stdlib.pillow.ImageColor.getcolor("white", "L"))
            AhkTest.AssertEqual([0, 255, 255], stdlib.pillow.ImageColor.getcolor("red", "HSV"))

            rgbImage := stdlib.pillow.Image.new("RGB", [1, 1], "navy")
            AhkTest.AssertEqual([0, 0, 128], rgbImage.getpixel([0, 0]))
            rgbaImage := stdlib.pillow.Image.new("RGBA", [1, 1], "#11223344")
            AhkTest.AssertEqual([17, 34, 51, 68], rgbaImage.getpixel([0, 0]))
            grayImage := stdlib.pillow.Image.new("L", [1, 1], "white")
            AhkTest.AssertEqual(255, grayImage.getpixel([0, 0]))

            AhkTest.RaisesMatch(ValueError, "^unknown color specifier: 'no-such-color'$", (*) => stdlib.pillow.ImageColor.getrgb("no-such-color"))
            AhkTest.RaisesMatch(ValueError, "^unknown color specifier: 'transparent'$", (*) => stdlib.pillow.ImageColor.getrgb("transparent"))
            AhkTest.RaisesMatch(ValueError, "^color specifier is too long$", (*) => stdlib.pillow.ImageColor.getrgb("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"))
            AhkTest.RaisesMatch(TypeError, "^object of type 'NoneType' has no len\(\)$", (*) => stdlib.pillow.ImageColor.getrgb(stdlib.None))
            AhkTest.RaisesMatch(KeyError, "^'BAD'$", (*) => stdlib.pillow.ImageColor.getcolor("red", "BAD"))
        } finally {
            if IsSet(grayImage)
                StdlibPillowTest.CloseImage(grayImage)
            if IsSet(rgbaImage)
                StdlibPillowTest.CloseImage(rgbaImage)
            if IsSet(rgbImage)
                StdlibPillowTest.CloseImage(rgbImage)
        }
    }

    static TestImageDrawBasicGeometryMatchesLocalPillow113()
    {
        rgb := unset
        rgba := unset
        gray := unset
        try {
            AhkTest.AssertTrue(HasProp(stdlib.pillow, "ImageDraw"))
            AhkTest.AssertTrue(HasMethod(stdlib.pillow.ImageDraw, "Draw"))

            rgb := stdlib.pillow.Image.new("RGB", [6, 5], "black")
            draw := stdlib.pillow.ImageDraw.Draw(rgb)
            AhkTest.AssertSame(stdlib.None, draw.point([[0, 0], [2, 2]], "red"))
            AhkTest.AssertSame(stdlib.None, draw.line([[0, 4], [5, 4]], "white", 1))
            AhkTest.AssertSame(stdlib.None, draw.rectangle([1, 1, 4, 3], unset, "green"))
            AhkTest.AssertSame(stdlib.None, draw.rectangle([2, 1, 3, 2], "#112233"))
            AhkTest.AssertSame(stdlib.None, draw.polygon([[4, 0], [5, 2], [3, 2]], "blue"))
            AhkTest.AssertEqual([
                [[255, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 255], [0, 0, 0]],
                [[0, 0, 0], [0, 128, 0], [17, 34, 51], [17, 34, 51], [0, 0, 255], [0, 0, 0]],
                [[0, 0, 0], [0, 128, 0], [17, 34, 51], [0, 0, 255], [0, 0, 255], [0, 0, 255]],
                [[0, 0, 0], [0, 128, 0], [0, 128, 0], [0, 128, 0], [0, 128, 0], [0, 0, 0]],
                [[255, 255, 255], [255, 255, 255], [255, 255, 255], [255, 255, 255], [255, 255, 255], [255, 255, 255]],
            ], StdlibPillowTest.PixelRows(rgb))

            rgba := stdlib.pillow.Image.new("RGBA", [4, 4], [0, 0, 0, 0])
            rgbaDraw := stdlib.pillow.ImageDraw.Draw(rgba)
            rgbaDraw.rectangle([0, 0, 2, 2], "#10203040")
            AhkTest.AssertEqual([
                [[16, 32, 48, 64], [16, 32, 48, 64], [16, 32, 48, 64], [0, 0, 0, 0]],
                [[16, 32, 48, 64], [16, 32, 48, 64], [16, 32, 48, 64], [0, 0, 0, 0]],
                [[16, 32, 48, 64], [16, 32, 48, 64], [16, 32, 48, 64], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
            ], StdlibPillowTest.PixelRows(rgba))

            gray := stdlib.pillow.Image.new("L", [3, 3], 0)
            grayDraw := stdlib.pillow.ImageDraw.Draw(gray)
            grayDraw.line([[0, 0], [2, 2]], "white", 1)
            AhkTest.AssertEqual([[255, 0, 0], [0, 255, 0], [0, 0, 255]], StdlibPillowTest.PixelRows(gray))

            AhkTest.RaisesMatch(AttributeError, "^'NoneType' object has no attribute 'load'$", (*) => stdlib.pillow.ImageDraw.Draw(stdlib.None))
            AhkTest.RaisesMatch(ValueError, "^wrong number of coordinates$", (*) => draw.line([1], "red"))
        } finally {
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
        }
    }

    static TestImageDrawTextMethodsMatchLocalPillow113()
    {
        image := unset
        multiline := unset
        try {
            image := stdlib.pillow.Image.new("RGB", [24, 14], "black")
            draw := stdlib.pillow.ImageDraw.Draw(image)
            AhkTest.AssertTrue(HasMethod(draw, "getfont"))
            AhkTest.AssertTrue(HasMethod(draw, "text"))
            AhkTest.AssertTrue(HasMethod(draw, "textbbox"))
            AhkTest.AssertTrue(HasMethod(draw, "textlength"))
            AhkTest.AssertTrue(HasMethod(draw, "multiline_text"))
            AhkTest.AssertTrue(HasMethod(draw, "multiline_textbbox"))

            font := draw.getfont()
            AhkTest.AssertEqual("FreeTypeFont", font.AhkStdlibTypeName)
            AhkTest.AssertEqual([0, 2, 11, 10], font.getbbox("Hi"))
            AhkTest.AssertEqual(11.0, font.getlength("Hi"))
            AhkTest.AssertEqual([1, 3, 12, 11], draw.textbbox([1, 1], "Hi"))
            AhkTest.AssertEqual([2, 5, 13, 13], draw.textbbox([2, 3], "Hi", font))
            AhkTest.AssertEqual(11.0, draw.textlength("Hi"))
            AhkTest.AssertEqual(11.0, draw.textlength("Hi", font))
            AhkTest.AssertSame(stdlib.None, draw.text([1, 1], "Hi", "white"))
            AhkTest.AssertTrue(StdlibPillowTest.NonBlackPixelCount(image) > 0)

            multiline := stdlib.pillow.Image.new("RGB", [24, 28], "black")
            multilineDraw := stdlib.pillow.ImageDraw.Draw(multiline)
            AhkTest.AssertEqual([1, 3, 12, 25], multilineDraw.multiline_textbbox([1, 1], "Hi`nA"))
            AhkTest.AssertSame(stdlib.None, multilineDraw.multiline_text([1, 1], "Hi`nA", "white"))
            AhkTest.AssertTrue(StdlibPillowTest.NonBlackPixelCount(multiline) > 0)

            AhkTest.RaisesMatch(TypeError, "^ImageDraw\.text\(\) missing 2 required positional arguments: 'xy' and 'text'$", (*) => draw.text())
            AhkTest.RaisesMatch(TypeError, "^ImageDraw\.textbbox\(\) missing 2 required positional arguments: 'xy' and 'text'$", (*) => draw.textbbox())
            AhkTest.RaisesMatch(TypeError, "^ImageDraw\.textlength\(\) missing 1 required positional argument: 'text'$", (*) => draw.textlength())
        } finally {
            if IsSet(multiline)
                StdlibPillowTest.CloseImage(multiline)
            if IsSet(image)
                StdlibPillowTest.CloseImage(image)
        }
    }

    static TestImageDrawEllipseMatchesLocalPillow113()
    {
        rgb := unset
        rgba := unset
        gray := unset
        try {
            rgb := stdlib.pillow.Image.new("RGB", [7, 5], "black")
            draw := stdlib.pillow.ImageDraw.Draw(rgb)
            AhkTest.AssertSame(stdlib.None, draw.ellipse([1, 1, 5, 3], "red"))
            AhkTest.AssertEqual([
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
            ], StdlibPillowTest.PixelRows(rgb))
            AhkTest.AssertSame(stdlib.None, draw.ellipse([0, 0, 6, 4], unset, "green", 1))
            AhkTest.AssertEqual([
                [[0, 0, 0], [0, 0, 0], [0, 128, 0], [0, 128, 0], [0, 128, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 128, 0], [0, 128, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [0, 128, 0], [0, 128, 0]],
                [[0, 128, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [0, 128, 0]],
                [[0, 128, 0], [0, 128, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [0, 128, 0], [0, 128, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 128, 0], [0, 128, 0], [0, 128, 0], [0, 0, 0], [0, 0, 0]],
            ], StdlibPillowTest.PixelRows(rgb))

            rgba := stdlib.pillow.Image.new("RGBA", [5, 5], [0, 0, 0, 0])
            rgbaDraw := stdlib.pillow.ImageDraw.Draw(rgba)
            AhkTest.AssertSame(stdlib.None, rgbaDraw.ellipse([1, 1, 3, 3], "#10203040", "#ff000080", 1))
            AhkTest.AssertEqual([
                [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [0, 0, 0, 0], [255, 0, 0, 128], [0, 0, 0, 0], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [255, 0, 0, 128], [16, 32, 48, 64], [255, 0, 0, 128], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [0, 0, 0, 0], [255, 0, 0, 128], [0, 0, 0, 0], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
            ], StdlibPillowTest.PixelRows(rgba))

            gray := stdlib.pillow.Image.new("L", [5, 5], 0)
            grayDraw := stdlib.pillow.ImageDraw.Draw(gray)
            AhkTest.AssertSame(stdlib.None, grayDraw.ellipse([1, 0, 3, 4], "white"))
            AhkTest.AssertEqual([
                [0, 0, 255, 0, 0],
                [0, 255, 255, 255, 0],
                [0, 255, 255, 255, 0],
                [0, 255, 255, 255, 0],
                [0, 0, 255, 0, 0],
            ], StdlibPillowTest.PixelRows(gray))

            AhkTest.RaisesMatch(ValueError, "^wrong number of coordinates$", (*) => draw.ellipse([1, 2, 3], "red"))
            AhkTest.RaisesMatch(TypeError, "^argument must be sequence$", (*) => draw.ellipse(stdlib.None, "red"))
            AhkTest.RaisesMatch(TypeError, "^'str' object cannot be interpreted as an integer$", (*) => draw.ellipse([0, 0, 2, 2], unset, "red", "x"))
        } finally {
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
        }
    }

    static TestImageDrawArcChordAndPiesliceMatchLocalPillow113()
    {
        arc := unset
        chord := unset
        pieslice := unset
        gray := unset
        try {
            arc := stdlib.pillow.Image.new("RGB", [7, 7], "black")
            arcDraw := stdlib.pillow.ImageDraw.Draw(arc)
            AhkTest.AssertSame(stdlib.None, arcDraw.arc([1, 1, 5, 5], 0, 180, "red", 1))
            AhkTest.AssertEqual([
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [255, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [255, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [255, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [255, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
            ], StdlibPillowTest.PixelRows(arc))

            chord := stdlib.pillow.Image.new("RGB", [7, 7], "black")
            chordDraw := stdlib.pillow.ImageDraw.Draw(chord)
            AhkTest.AssertSame(stdlib.None, chordDraw.chord([1, 1, 5, 5], 0, 180, "blue", "green", 1))
            AhkTest.AssertEqual([
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 128, 0], [0, 128, 0], [0, 128, 0], [0, 128, 0], [0, 128, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 128, 0], [0, 128, 0], [0, 128, 0], [0, 128, 0], [0, 128, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 128, 0], [0, 128, 0], [0, 128, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
            ], StdlibPillowTest.PixelRows(chord))

            pieslice := stdlib.pillow.Image.new("RGBA", [7, 7], [0, 0, 0, 0])
            piesliceDraw := stdlib.pillow.ImageDraw.Draw(pieslice)
            AhkTest.AssertSame(stdlib.None, piesliceDraw.pieslice([1, 1, 5, 5], 90, 270, "#10203040", "#ff000080", 1))
            AhkTest.AssertEqual([
                [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [0, 0, 0, 0], [255, 0, 0, 128], [255, 0, 0, 128], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [255, 0, 0, 128], [255, 0, 0, 128], [255, 0, 0, 128], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [255, 0, 0, 128], [255, 0, 0, 128], [255, 0, 0, 128], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [255, 0, 0, 128], [255, 0, 0, 128], [255, 0, 0, 128], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [0, 0, 0, 0], [255, 0, 0, 128], [255, 0, 0, 128], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
            ], StdlibPillowTest.PixelRows(pieslice))

            gray := stdlib.pillow.Image.new("L", [7, 7], 0)
            grayDraw := stdlib.pillow.ImageDraw.Draw(gray)
            AhkTest.AssertSame(stdlib.None, grayDraw.chord([1, 1, 5, 5], 180, 360, "white"))
            AhkTest.AssertEqual([
                [0, 0, 0, 0, 0, 0, 0],
                [0, 0, 255, 255, 255, 0, 0],
                [0, 255, 255, 255, 255, 255, 0],
                [0, 255, 255, 255, 255, 255, 0],
                [0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0],
            ], StdlibPillowTest.PixelRows(gray))

            AhkTest.RaisesMatch(ValueError, "^wrong number of coordinates$", (*) => arcDraw.arc([1, 2, 3], 0, 90, "red"))
            AhkTest.RaisesMatch(TypeError, "^'str' object cannot be interpreted as an integer$", (*) => arcDraw.arc([1, 1, 5, 5], 0, 90, "red", "x"))
            AhkTest.RaisesMatch(TypeError, "^argument must be sequence$", (*) => chordDraw.chord(stdlib.None, 0, 90, "red"))
            AhkTest.RaisesMatch(TypeError, "^'str' object cannot be interpreted as an integer$", (*) => piesliceDraw.pieslice([1, 1, 5, 5], 0, 90, unset, "red", "x"))
        } finally {
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
            if IsSet(pieslice)
                StdlibPillowTest.CloseImage(pieslice)
            if IsSet(chord)
                StdlibPillowTest.CloseImage(chord)
            if IsSet(arc)
                StdlibPillowTest.CloseImage(arc)
        }
    }

    static TestImageDrawCircleAndRoundedRectangleMatchLocalPillow113()
    {
        circle := unset
        rounded := unset
        rgba := unset
        gray := unset
        try {
            circle := stdlib.pillow.Image.new("RGB", [7, 7], "black")
            circleDraw := stdlib.pillow.ImageDraw.Draw(circle)
            AhkTest.AssertSame(stdlib.None, circleDraw.circle([3, 3], 2, "red", "green", 1))
            AhkTest.AssertEqual([
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 128, 0], [0, 128, 0], [0, 128, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 128, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [0, 128, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 128, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [0, 128, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 128, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0], [0, 128, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 128, 0], [0, 128, 0], [0, 128, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
            ], StdlibPillowTest.PixelRows(circle))

            rounded := stdlib.pillow.Image.new("RGB", [8, 6], "black")
            roundedDraw := stdlib.pillow.ImageDraw.Draw(rounded)
            AhkTest.AssertSame(stdlib.None, roundedDraw.rounded_rectangle([1, 1, 6, 4], 2, "#112233", "yellow", 1))
            AhkTest.AssertEqual([
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [255, 255, 0], [255, 255, 0], [255, 255, 0], [255, 255, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [255, 255, 0], [17, 34, 51], [17, 34, 51], [17, 34, 51], [17, 34, 51], [255, 255, 0], [0, 0, 0]],
                [[0, 0, 0], [255, 255, 0], [17, 34, 51], [17, 34, 51], [17, 34, 51], [17, 34, 51], [255, 255, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [255, 255, 0], [255, 255, 0], [255, 255, 0], [255, 255, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
            ], StdlibPillowTest.PixelRows(rounded))

            rgba := stdlib.pillow.Image.new("RGBA", [6, 6], [0, 0, 0, 0])
            rgbaDraw := stdlib.pillow.ImageDraw.Draw(rgba)
            AhkTest.AssertSame(stdlib.None, rgbaDraw.rounded_rectangle([1, 1, 4, 4], 1, "#10203040", "#ff000080", 1))
            AhkTest.AssertEqual([
                [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [0, 0, 0, 0], [255, 0, 0, 128], [255, 0, 0, 128], [0, 0, 0, 0], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [255, 0, 0, 128], [16, 32, 48, 64], [16, 32, 48, 64], [255, 0, 0, 128], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [255, 0, 0, 128], [16, 32, 48, 64], [16, 32, 48, 64], [255, 0, 0, 128], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [0, 0, 0, 0], [255, 0, 0, 128], [255, 0, 0, 128], [0, 0, 0, 0], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
            ], StdlibPillowTest.PixelRows(rgba))

            gray := stdlib.pillow.Image.new("L", [5, 5], 0)
            grayDraw := stdlib.pillow.ImageDraw.Draw(gray)
            AhkTest.AssertSame(stdlib.None, grayDraw.circle([2, 2], 1, "white"))
            AhkTest.AssertEqual([
                [0, 0, 0, 0, 0],
                [0, 0, 255, 0, 0],
                [0, 255, 255, 255, 0],
                [0, 0, 255, 0, 0],
                [0, 0, 0, 0, 0],
            ], StdlibPillowTest.PixelRows(gray))

            AhkTest.RaisesMatch(IndexError, "^list index out of range$", (*) => circleDraw.circle([1], 2, "red"))
            AhkTest.RaisesMatch(TypeError, "^unsupported operand type\(s\) for -: 'int' and 'str'$", (*) => circleDraw.circle([3, 3], "x", "red"))
            AhkTest.RaisesMatch(ValueError, "^not enough values to unpack \(expected 4, got 3\)$", (*) => roundedDraw.rounded_rectangle([1, 2, 3], 1, "red"))
            AhkTest.RaisesMatch(TypeError, "^'str' object cannot be interpreted as an integer$", (*) => roundedDraw.rounded_rectangle([1, 1, 3, 3], 1, unset, "red", "x"))
        } finally {
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
            if IsSet(rounded)
                StdlibPillowTest.CloseImage(rounded)
            if IsSet(circle)
                StdlibPillowTest.CloseImage(circle)
        }
    }

    static TestImageDrawRegularPolygonAndPolygonWidthMatchLocalPillow113()
    {
        regular := unset
        polyWidth := unset
        rgba := unset
        gray := unset
        try {
            regular := stdlib.pillow.Image.new("RGB", [7, 7], "black")
            regularDraw := stdlib.pillow.ImageDraw.Draw(regular)
            AhkTest.AssertSame(stdlib.None, regularDraw.regular_polygon([[3, 3], 2], 3, 0, "red", "green", 1))
            AhkTest.AssertEqual([
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 128, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 128, 0], [0, 128, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 128, 0], [255, 0, 0], [0, 128, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 128, 0], [0, 128, 0], [0, 128, 0], [0, 128, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
            ], StdlibPillowTest.PixelRows(regular))

            polyWidth := stdlib.pillow.Image.new("RGB", [7, 5], "black")
            polyWidthDraw := stdlib.pillow.ImageDraw.Draw(polyWidth)
            AhkTest.AssertSame(stdlib.None, polyWidthDraw.polygon([[1, 1], [5, 1], [3, 3]], "#112233", "yellow", 2))
            AhkTest.AssertEqual([
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [255, 255, 0], [255, 255, 0], [255, 255, 0], [255, 255, 0], [255, 255, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [255, 255, 0], [255, 255, 0], [255, 255, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [255, 255, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
            ], StdlibPillowTest.PixelRows(polyWidth))

            rgba := stdlib.pillow.Image.new("RGBA", [7, 5], [0, 0, 0, 0])
            rgbaDraw := stdlib.pillow.ImageDraw.Draw(rgba)
            AhkTest.AssertSame(stdlib.None, rgbaDraw.regular_polygon([[3, 2], 2], 4, 45, "#10203040", "#ff000080", 1))
            AhkTest.AssertEqual([
                [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [255, 0, 0, 128], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [0, 0, 0, 0], [255, 0, 0, 128], [16, 32, 48, 64], [255, 0, 0, 128], [0, 0, 0, 0], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [255, 0, 0, 128], [16, 32, 48, 64], [16, 32, 48, 64], [16, 32, 48, 64], [255, 0, 0, 128], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [0, 0, 0, 0], [255, 0, 0, 128], [16, 32, 48, 64], [255, 0, 0, 128], [0, 0, 0, 0], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [255, 0, 0, 128], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
            ], StdlibPillowTest.PixelRows(rgba))

            gray := stdlib.pillow.Image.new("L", [5, 5], 0)
            grayDraw := stdlib.pillow.ImageDraw.Draw(gray)
            AhkTest.AssertSame(stdlib.None, grayDraw.polygon([[1, 1], [3, 1], [2, 3]], "white", 128, 1))
            AhkTest.AssertEqual([
                [0, 0, 0, 0, 0],
                [0, 128, 128, 128, 0],
                [0, 128, 128, 0, 0],
                [0, 0, 128, 0, 0],
                [0, 0, 0, 0, 0],
            ], StdlibPillowTest.PixelRows(gray))

            AhkTest.RaisesMatch(ValueError, "^n_sides should be an int > 2$", (*) => regularDraw.regular_polygon([[3, 3], 2], 2, 0, "red"))
            AhkTest.RaisesMatch(ValueError, "^bounding_circle should contain 2D coordinates and a radius \(e\.g\. \(x, y, r\) or \(\(x, y\), r\) \)$", (*) => regularDraw.regular_polygon([3, 3], 3, 0, "red"))
            AhkTest.RaisesMatch(TypeError, "^unsupported operand type\(s\) for -: 'str' and 'int'$", (*) => polyWidthDraw.polygon([[1, 1], [2, 2], [3, 1]], unset, "red", "x"))
        } finally {
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
            if IsSet(polyWidth)
                StdlibPillowTest.CloseImage(polyWidth)
            if IsSet(regular)
                StdlibPillowTest.CloseImage(regular)
        }
    }

    static TestImageDrawBitmapMatchesLocalPillow113()
    {
        rgb := unset
        mask := unset
        rgba := unset
        rgbaMask := unset
        gray := unset
        grayMask := unset
        defaultFill := unset
        defaultMask := unset
        offscreen := unset
        offscreenMask := unset
        try {
            rgb := stdlib.pillow.Image.new("RGB", [5, 4], "black")
            mask := stdlib.pillow.Image.new("L", [3, 2], 0)
            mask.putpixel([0, 0], 255)
            mask.putpixel([1, 0], 128)
            mask.putpixel([2, 1], 1)
            rgbDraw := stdlib.pillow.ImageDraw.Draw(rgb)
            AhkTest.AssertSame(stdlib.None, rgbDraw.bitmap([1, 1], mask, "red"))
            AhkTest.AssertEqual([
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [255, 0, 0], [128, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [1, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
            ], StdlibPillowTest.PixelRows(rgb))

            rgba := stdlib.pillow.Image.new("RGBA", [4, 3], [0, 0, 0, 0])
            rgbaMask := stdlib.pillow.Image.new("L", [2, 2], 0)
            rgbaMask.putpixel([0, 0], 255)
            rgbaMask.putpixel([1, 1], 64)
            rgbaDraw := stdlib.pillow.ImageDraw.Draw(rgba)
            AhkTest.AssertSame(stdlib.None, rgbaDraw.bitmap([1, 0], rgbaMask, "#10203040"))
            AhkTest.AssertEqual([
                [[0, 0, 0, 0], [16, 32, 48, 64], [0, 0, 0, 0], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [0, 0, 0, 0], [16, 32, 48, 16], [0, 0, 0, 0]],
                [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
            ], StdlibPillowTest.PixelRows(rgba))

            gray := stdlib.pillow.Image.new("L", [4, 3], 0)
            grayMask := stdlib.pillow.Image.new("L", [2, 2], 0)
            grayMask.putpixel([0, 1], 255)
            grayMask.putpixel([1, 0], 2)
            grayDraw := stdlib.pillow.ImageDraw.Draw(gray)
            AhkTest.AssertSame(stdlib.None, grayDraw.bitmap([0, 0], grayMask, 128))
            AhkTest.AssertEqual([
                [0, 1, 0, 0],
                [128, 0, 0, 0],
                [0, 0, 0, 0],
            ], StdlibPillowTest.PixelRows(gray))

            defaultFill := stdlib.pillow.Image.new("RGB", [3, 2], "white")
            defaultMask := stdlib.pillow.Image.new("L", [2, 1], 0)
            defaultMask.putpixel([0, 0], 255)
            defaultDraw := stdlib.pillow.ImageDraw.Draw(defaultFill)
            AhkTest.AssertSame(stdlib.None, defaultDraw.bitmap([1, 1], defaultMask))
            AhkTest.AssertEqual([
                [[255, 255, 255], [255, 255, 255], [255, 255, 255]],
                [[255, 255, 255], [255, 255, 255], [255, 255, 255]],
            ], StdlibPillowTest.PixelRows(defaultFill))

            offscreen := stdlib.pillow.Image.new("RGB", [3, 3], "black")
            offscreenMask := stdlib.pillow.Image.new("L", [3, 3], 255)
            offscreenDraw := stdlib.pillow.ImageDraw.Draw(offscreen)
            AhkTest.AssertSame(stdlib.None, offscreenDraw.bitmap([-1, 1], offscreenMask, "blue"))
            AhkTest.AssertEqual([
                [[0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 255], [0, 0, 255], [0, 0, 0]],
                [[0, 0, 255], [0, 0, 255], [0, 0, 0]],
            ], StdlibPillowTest.PixelRows(offscreen))

            AhkTest.RaisesMatch(ValueError, "^wrong number of coordinates$", (*) => rgbDraw.bitmap([0], mask, "red"))
            AhkTest.RaisesMatch(AttributeError, "^'NoneType' object has no attribute 'load'$", (*) => rgbDraw.bitmap([0, 0], stdlib.None, "red"))
            AhkTest.RaisesMatch(TypeError, "^color must be int, or tuple of one, three or four elements$", (*) => rgbDraw.bitmap([0, 0], mask, [1, 2]))
        } finally {
            if IsSet(offscreenMask)
                StdlibPillowTest.CloseImage(offscreenMask)
            if IsSet(offscreen)
                StdlibPillowTest.CloseImage(offscreen)
            if IsSet(defaultMask)
                StdlibPillowTest.CloseImage(defaultMask)
            if IsSet(defaultFill)
                StdlibPillowTest.CloseImage(defaultFill)
            if IsSet(grayMask)
                StdlibPillowTest.CloseImage(grayMask)
            if IsSet(gray)
                StdlibPillowTest.CloseImage(gray)
            if IsSet(rgbaMask)
                StdlibPillowTest.CloseImage(rgbaMask)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
            if IsSet(mask)
                StdlibPillowTest.CloseImage(mask)
            if IsSet(rgb)
                StdlibPillowTest.CloseImage(rgb)
        }
    }

    static TestImageDrawFloodfillMatchesLocalPillow113()
    {
        basic := unset
        border := unset
        threshold := unset
        rgba := unset
        noop := unset
        bad := unset
        try {
            basic := stdlib.pillow.Image.new("RGB", [5, 4], [0, 0, 0])
            Loop 4
                basic.putpixel([0, A_Index - 1], [9, 9, 9])
            Loop 5
                basic.putpixel([A_Index - 1, 0], [9, 9, 9])
            basic.putpixel([3, 2], [1, 2, 3])
            AhkTest.AssertSame(stdlib.None, stdlib.pillow.ImageDraw.floodfill(basic, [2, 2], [255, 0, 0]))
            AhkTest.AssertEqual([
                [[9, 9, 9], [9, 9, 9], [9, 9, 9], [9, 9, 9], [9, 9, 9]],
                [[9, 9, 9], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0]],
                [[9, 9, 9], [255, 0, 0], [255, 0, 0], [1, 2, 3], [255, 0, 0]],
                [[9, 9, 9], [255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0]],
            ], StdlibPillowTest.PixelRows(basic))

            border := stdlib.pillow.Image.new("RGB", [6, 5], [0, 0, 0])
            for x in [1, 2, 3, 4] {
                border.putpixel([x, 1], [0, 255, 0])
                border.putpixel([x, 3], [0, 255, 0])
            }
            for y in [1, 2, 3] {
                border.putpixel([1, y], [0, 255, 0])
                border.putpixel([4, y], [0, 255, 0])
            }
            AhkTest.AssertSame(stdlib.None, stdlib.pillow.ImageDraw.floodfill(border, [2, 2], [0, 0, 255], [0, 255, 0]))
            AhkTest.AssertEqual([
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 255, 0], [0, 255, 0], [0, 255, 0], [0, 255, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 255, 0], [0, 0, 255], [0, 0, 255], [0, 255, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 255, 0], [0, 255, 0], [0, 255, 0], [0, 255, 0], [0, 0, 0]],
                [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
            ], StdlibPillowTest.PixelRows(border))

            threshold := stdlib.pillow.Image.new("L", [4, 3], 10)
            threshold.putpixel([1, 0], 12)
            threshold.putpixel([2, 0], 16)
            threshold.putpixel([0, 1], 14)
            threshold.putpixel([1, 1], 15)
            threshold.putpixel([2, 1], 20)
            threshold.putpixel([1, 2], 9)
            AhkTest.AssertSame(stdlib.None, stdlib.pillow.ImageDraw.floodfill(threshold, [0, 0], 99, unset, 5))
            AhkTest.AssertEqual([
                [99, 99, 16, 99],
                [99, 99, 20, 99],
                [99, 99, 99, 99],
            ], StdlibPillowTest.PixelRows(threshold))

            rgba := stdlib.pillow.Image.new("RGBA", [3, 3], [1, 2, 3, 4])
            rgba.putpixel([2, 2], [8, 8, 8, 8])
            AhkTest.AssertSame(stdlib.None, stdlib.pillow.ImageDraw.floodfill(rgba, [1, 1], [16, 32, 48, 64]))
            AhkTest.AssertEqual([
                [[16, 32, 48, 64], [16, 32, 48, 64], [16, 32, 48, 64]],
                [[16, 32, 48, 64], [16, 32, 48, 64], [16, 32, 48, 64]],
                [[16, 32, 48, 64], [16, 32, 48, 64], [8, 8, 8, 8]],
            ], StdlibPillowTest.PixelRows(rgba))

            noop := stdlib.pillow.Image.new("RGB", [2, 2], [1, 2, 3])
            AhkTest.AssertSame(stdlib.None, stdlib.pillow.ImageDraw.floodfill(noop, [0, 0], [1, 2, 3]))
            AhkTest.AssertSame(stdlib.None, stdlib.pillow.ImageDraw.floodfill(noop, [9, 9], [255, 0, 0]))
            AhkTest.AssertEqual([
                [[1, 2, 3], [1, 2, 3]],
                [[1, 2, 3], [1, 2, 3]],
            ], StdlibPillowTest.PixelRows(noop))

            bad := stdlib.pillow.Image.new("RGB", [2, 2], [0, 0, 0])
            AhkTest.RaisesMatch(AttributeError, "^'NoneType' object has no attribute 'load'$", (*) => stdlib.pillow.ImageDraw.floodfill(stdlib.None, [0, 0], [255, 0, 0]))
            AhkTest.RaisesMatch(ValueError, "^not enough values to unpack \(expected 2, got 1\)$", (*) => stdlib.pillow.ImageDraw.floodfill(bad, [0], [255, 0, 0]))
            AhkTest.RaisesMatch(TypeError, "^cannot unpack non-iterable NoneType object$", (*) => stdlib.pillow.ImageDraw.floodfill(bad, stdlib.None, [255, 0, 0]))
            AhkTest.RaisesMatch(TypeError, "^unsupported operand type\(s\) for -: 'str' and 'int'$", (*) => stdlib.pillow.ImageDraw.floodfill(bad, [0, 0], "red"))
            AhkTest.RaisesMatch(TypeError, "^unsupported operand type\(s\) for -: 'str' and 'int'$", (*) => stdlib.pillow.ImageDraw.floodfill(bad, [0, 0], "red", unset, "x"))
        } finally {
            if IsSet(bad)
                StdlibPillowTest.CloseImage(bad)
            if IsSet(noop)
                StdlibPillowTest.CloseImage(noop)
            if IsSet(rgba)
                StdlibPillowTest.CloseImage(rgba)
            if IsSet(threshold)
                StdlibPillowTest.CloseImage(threshold)
            if IsSet(border)
                StdlibPillowTest.CloseImage(border)
            if IsSet(basic)
                StdlibPillowTest.CloseImage(basic)
        }
    }

    static TempPath(name)
    {
        root := A_Temp "\ahk-stdlib-pillow-tests"
        if !DirExist(root)
            DirCreate root
        return root "\" A_TickCount "-" Random(100000, 999999) "-" name
    }

    static CloseImage(image := unset)
    {
        if IsSet(image) && IsObject(image) && HasMethod(image, "close")
            image.close()
    }

    static CloseImages(images := unset)
    {
        if IsSet(images) && IsObject(images) {
            for image in images
                StdlibPillowTest.CloseImage(image)
        }
    }

    static ReadBytes(path)
    {
        file := FileOpen(path, "r")
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

    static WriteBytes(path, bytes)
    {
        file := FileOpen(path, "w")
        try {
            bytesBuffer := Buffer(bytes.Length, 0)
            for index, byte in bytes
                NumPut("UChar", byte, bytesBuffer, index - 1)
            file.RawWrite(bytesBuffer, bytesBuffer.Size)
        } finally {
            file.Close()
        }
    }

    static WriteMiniPilFont(root)
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
        StdlibPillowTest.WriteBytes(root ".pil", bytes)
        StdlibPillowTest.WriteBytes(root ".pbm", StdlibPillowTest.MiniPbmBytes())
    }

    static MiniPbmBytes()
    {
        textBytes := []
        for char in StrSplit("P4`n5 5`n")
            textBytes.Push(Ord(char))
        ; A occupies columns 0..2, B occupies columns 3..4.
        for byte in [248, 248, 248, 248, 248]
            textBytes.Push(byte)
        return textBytes
    }

    static BdfFontBytes()
    {
        return StdlibPillowTest.AsciiBytes(
            "STARTFONT 2.1`n"
            . "FONT -AHK-Stdlib-Medium-R-Normal--8-80-75-75-C-50-ISO10646-1`n"
            . "SIZE 8 75 75`n"
            . "FONTBOUNDINGBOX 8 8 0 -2`n"
            . "STARTPROPERTIES 3`n"
            . "FONT_ASCENT 7`n"
            . "FONT_DESCENT 2`n"
            . "COMMENT behavior probe`n"
            . "ENDPROPERTIES`n"
            . "CHARS 3`n"
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
            . "STARTCHAR zero`n"
            . "ENCODING 0`n"
            . "SWIDTH 0 0`n"
            . "DWIDTH 3 0`n"
            . "BBX 0 4 0 0`n"
            . "BITMAP`n"
            . "ENDCHAR`n"
            . "STARTCHAR out`n"
            . "ENCODING 300`n"
            . "SWIDTH 500 0`n"
            . "DWIDTH 9 0`n"
            . "BBX 2 2 0 0`n"
            . "BITMAP`n"
            . "C0`n"
            . "C0`n"
            . "ENDCHAR`n"
            . "ENDFONT`n"
        )
    }

    static PcfBytes(metricPayload := unset, bitmapCount := 2, encodingOffsets := unset)
    {
        if !IsSet(metricPayload) {
            metricPayload := StdlibPillowTest.ConcatBytes(
                StdlibPillowTest.Le16(2),
                [128, 131, 132, 130, 129],
                [127, 130, 133, 131, 129]
            )
        }
        if !IsSet(encodingOffsets) {
            encodingOffsets := []
            loop 67
                encodingOffsets.Push(0xFFFF)
            encodingOffsets[66] := 0
            encodingOffsets[67] := 1
        }

        stringData := StdlibPillowTest.ConcatBytes(
            StdlibPillowTest.AsciiBytes("FONT"),
            [0],
            StdlibPillowTest.AsciiBytes("demo-pcf"),
            [0],
            StdlibPillowTest.AsciiBytes("POINT_SIZE"),
            [0]
        )
        propsPayload := StdlibPillowTest.ConcatBytes(
            StdlibPillowTest.Le32(2),
            StdlibPillowTest.Le32(0), [1], StdlibPillowTest.Le32(5),
            StdlibPillowTest.Le32(14), [0], StdlibPillowTest.Le32(120),
            [0, 0],
            StdlibPillowTest.Le32(stringData.Length),
            stringData
        )
        bitmapData := [0x05, 0x02, 0x07, 0x03, 0x04, 0x07, 0x01]
        bitmapsPayload := StdlibPillowTest.ConcatBytes(
            StdlibPillowTest.Le32(bitmapCount),
            StdlibPillowTest.Le32(0),
            StdlibPillowTest.Le32(3),
            StdlibPillowTest.Le32(bitmapData.Length),
            StdlibPillowTest.Le32(bitmapData.Length),
            StdlibPillowTest.Le32(bitmapData.Length),
            StdlibPillowTest.Le32(bitmapData.Length),
            bitmapData
        )
        encodingBytes := []
        for value in encodingOffsets
            for byte in StdlibPillowTest.Le16(value)
                encodingBytes.Push(byte)
        encodingPayload := StdlibPillowTest.ConcatBytes(
            StdlibPillowTest.Le16(0),
            StdlibPillowTest.Le16(66),
            StdlibPillowTest.Le16(0),
            StdlibPillowTest.Le16(0),
            StdlibPillowTest.Le16(0xFFFF),
            encodingBytes
        )

        return StdlibPillowTest.PcfContainer([
            [1, 0, StdlibPillowTest.PcfTable(0, propsPayload)],
            [4, 0x100, StdlibPillowTest.PcfTable(0x100, metricPayload)],
            [8, 0, StdlibPillowTest.PcfTable(0, bitmapsPayload)],
            [32, 0, StdlibPillowTest.PcfTable(0, encodingPayload)],
        ])
    }

    static PcfTable(formatValue, payload)
    {
        return StdlibPillowTest.ConcatBytes(StdlibPillowTest.Le32(formatValue), payload)
    }

    static PcfContainer(tables)
    {
        count := tables.Length
        offset := 8 + count * 16
        toc := []
        chunks := []
        for table in tables {
            data := table[3]
            for byte in StdlibPillowTest.Le32(table[1])
                toc.Push(byte)
            for byte in StdlibPillowTest.Le32(table[2])
                toc.Push(byte)
            for byte in StdlibPillowTest.Le32(data.Length)
                toc.Push(byte)
            for byte in StdlibPillowTest.Le32(offset)
                toc.Push(byte)
            chunks.Push(data)
            offset += data.Length
        }
        return StdlibPillowTest.ConcatBytes(StdlibPillowTest.Le32(0x70636601), StdlibPillowTest.Le32(count), toc, chunks*)
    }

    static AsciiBytes(text)
    {
        bytes := []
        loop parse text
            bytes.Push(Ord(A_LoopField))
        return bytes
    }

    static AsciiFromBytes(bytes)
    {
        text := ""
        for byte in bytes {
            if byte = 0
                continue
            text .= Chr(byte)
        }
        return text
    }

    static ImBytes(lines, payload, palette := unset)
    {
        bytes := []
        for line in lines {
            for byte in StdlibPillowTest.AsciiBytes(line "`r`n")
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

    static ImSaveBadMode(plugin)
    {
        image := stdlib.pillow.Image.new("RGB", [1, 1], [0, 0, 0])
        try {
            image.AhkStdlibMode := "HSV"
            return plugin._save(image, stdlib.io.BytesIO(), "")
        } finally {
            StdlibPillowTest.CloseImage(image)
        }
    }

    static IcnsReadBe32(bytes, offset)
    {
        return (bytes[offset] << 24) | (bytes[offset + 1] << 16) | (bytes[offset + 2] << 8) | bytes[offset + 3]
    }

    static IcnsPngBytes(size := unset)
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
                StdlibPillowTest.CloseImage(image)
        }
    }

    static IcnsBytes(entries)
    {
        payload := []
        for entry in entries {
            for byte in StdlibPillowTest.AsciiBytes(entry[1])
                payload.Push(byte)
            for byte in StdlibPillowTest.Be32(8 + entry[2].Length)
                payload.Push(byte)
            for byte in entry[2]
                payload.Push(byte)
        }

        bytes := StdlibPillowTest.AsciiBytes("icns")
        for byte in StdlibPillowTest.Be32(8 + payload.Length)
            bytes.Push(byte)
        for byte in payload
            bytes.Push(byte)
        return bytes
    }

    static ConcatBytes(parts*)
    {
        bytes := []
        for part in parts {
            for byte in part
                bytes.Push(byte)
        }
        return bytes
    }

    static TarBytes(entries)
    {
        bytes := []
        for entry in entries {
            payload := entry[2]
            for byte in StdlibPillowTest.TarHeaderBytes(entry[1], payload.Length)
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

    static TarHeaderBytes(name, size)
    {
        bytes := StdlibPillowTest.ZeroBytes(512)
        nameBytes := StdlibPillowTest.AsciiBytes(name)
        for index, byte in nameBytes {
            if index > 100
                break
            bytes[index] := byte
        }
        sizeBytes := StdlibPillowTest.AsciiBytes(StdlibPillowTest.OctalText(size, 11))
        for index, byte in sizeBytes
            bytes[124 + index] := byte
        return bytes
    }

    static OctalText(value, width)
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

    static IptcBytes(fields)
    {
        bytes := []
        for item in fields {
            tag := item[1]
            data := item[2]
            bytes.Push(0x1C)
            bytes.Push(tag[1])
            bytes.Push(tag[2])
            bytes.Push((data.Length >> 8) & 0xFF)
            bytes.Push(data.Length & 0xFF)
            for byte in data
                bytes.Push(byte)
        }
        return bytes
    }

    static JpegHeaderBytes()
    {
        bytes := [0xFF, 0xD8]
        for byte in [0xFF, 0xE0, 0, 16]
            bytes.Push(byte)
        for byte in StdlibPillowTest.AsciiBytes("JFIF")
            bytes.Push(byte)
        for byte in [0, 1, 1, 1, 0, 72, 0, 96, 0, 0]
            bytes.Push(byte)

        for byte in [0xFF, 0xDB, 0, 67, 0]
            bytes.Push(byte)
        loop 64
            bytes.Push(A_Index - 1)

        for byte in [0xFF, 0xC0, 0, 17, 8]
            bytes.Push(byte)
        for byte in StdlibPillowTest.Be16(2)
            bytes.Push(byte)
        for byte in StdlibPillowTest.Be16(3)
            bytes.Push(byte)
        for byte in [3, 1, 0x22, 0, 2, 0x11, 0, 3, 0x11, 0]
            bytes.Push(byte)

        for byte in [0xFF, 0xDA, 0, 12, 3, 1, 0, 2, 0, 3, 0, 0, 63, 0, 0xFF, 0xD9]
            bytes.Push(byte)
        return bytes
    }

    static McIdasAreaBytes(width := 3, height := 2, bytesPerPixel := 1, bands := 1, prefix := 0, offset := 256, payload := unset)
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
            for byte in StdlibPillowTest.Be32(value)
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

    static TiffBytes(mode, pixels)
    {
        image := unset
        output := stdlib.io.BytesIO()
        try {
            fill := (mode = "RGB") ? [0, 0, 0] : 0
            image := stdlib.pillow.Image.new(mode, [2, 2], fill)
            image.putdata(pixels)
            image.save(output, "TIFF")
            return output.getvalue()
        } finally {
            if IsSet(image)
                StdlibPillowTest.CloseImage(image)
        }
    }

    static WalBytes(width, height, pixels, name := "demo/wall", nextName := "demo/next")
    {
        bytes := StdlibPillowTest.ZeroBytes(100)
        nameBytes := StdlibPillowTest.AsciiBytes(name)
        loop Min(nameBytes.Length, 31)
            bytes[A_Index] := nameBytes[A_Index]
        sizeBytes := StdlibPillowTest.Le32(width)
        loop 4
            bytes[32 + A_Index] := sizeBytes[A_Index]
        sizeBytes := StdlibPillowTest.Le32(height)
        loop 4
            bytes[36 + A_Index] := sizeBytes[A_Index]
        offsetBytes := StdlibPillowTest.Le32(100)
        loop 4
            bytes[40 + A_Index] := offsetBytes[A_Index]
        nextBytes := StdlibPillowTest.AsciiBytes(nextName)
        loop Min(nextBytes.Length, 31)
            bytes[56 + A_Index] := nextBytes[A_Index]
        for pixel in pixels
            bytes.Push(pixel)
        return bytes
    }

    static MpegBytes(width := 320, height := 240, tail := unset)
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

    static MpoBytes(attributes := unset)
    {
        entryAttributes := IsSet(attributes) ? attributes.Clone() : [0x030000, 0]
        while entryAttributes.Length < 2
            entryAttributes.Push(0)

        frames := []
        loop entryAttributes.Length
            frames.Push(StdlibPillowTest.JpegHeaderBytes())

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
            for byte in StdlibPillowTest.Le32(entryAttributes[index])
                mpEntries.Push(byte)
            for byte in StdlibPillowTest.Le32(sizes[index])
                mpEntries.Push(byte)
            for byte in StdlibPillowTest.Le32(dataOffset)
                mpEntries.Push(byte)
            for byte in StdlibPillowTest.Le16(0)
                mpEntries.Push(byte)
            for byte in StdlibPillowTest.Le16(0)
                mpEntries.Push(byte)
            if index = 1
                dataOffset -= mpOffset
            dataOffset += sizes[index]
        }
        ifd := StdlibPillowTest.ConcatBytes(
            StdlibPillowTest.Le16(3),
            StdlibPillowTest.MpoIfdEntry(0xB000, 7, 4, StdlibPillowTest.AsciiBytes("0100")),
            StdlibPillowTest.MpoIfdEntry(0xB001, 4, 1, StdlibPillowTest.Le32(frames.Length)),
            StdlibPillowTest.MpoIfdEntry(0xB002, 7, mpEntries.Length, StdlibPillowTest.Le32(50)),
            StdlibPillowTest.Le32(0),
            mpEntries
        )
        payload := StdlibPillowTest.ConcatBytes(
            StdlibPillowTest.AsciiBytes("MPF"),
            [0],
            StdlibPillowTest.AsciiBytes("II"),
            StdlibPillowTest.Le16(42),
            StdlibPillowTest.Le32(8),
            ifd
        )
        app2 := StdlibPillowTest.ConcatBytes([0xFF, 0xE2], StdlibPillowTest.Be16(payload.Length + 2), payload)
        bytes := StdlibPillowTest.ConcatBytes(
            StdlibPillowTest.ArraySlice(first, 1, app0End),
            app2,
            StdlibPillowTest.ArraySlice(first, app0End + 1, first.Length)
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

    static MpoIfdEntry(tag, type, count, valueBytes)
    {
        bytes := StdlibPillowTest.ConcatBytes(
            StdlibPillowTest.Le16(tag),
            StdlibPillowTest.Le16(type),
            StdlibPillowTest.Le32(count)
        )
        padded := valueBytes.Clone()
        while padded.Length < 4
            padded.Push(0)
        for byte in StdlibPillowTest.ArraySlice(padded, 1, 4)
            bytes.Push(byte)
        return bytes
    }

    static MpoBytesWithApp1(payload, attributes := unset)
    {
        fixture := StdlibPillowTest.MpoBytes(attributes?)
        app1 := StdlibPillowTest.ConcatBytes([0xFF, 0xE1], StdlibPillowTest.Be16(payload.Length + 2), payload)
        return StdlibPillowTest.ConcatBytes(
            StdlibPillowTest.ArraySlice(fixture["bytes"], 1, 20),
            app1,
            StdlibPillowTest.ArraySlice(fixture["bytes"], 21, fixture["bytes"].Length)
        )
    }

    static JpegAppSegments(image)
    {
        segments := []
        for item in image.applist
            segments.Push(item[1])
        return segments
    }

    static MspDanMBytes()
    {
        return StdlibPillowTest.ConcatBytes(StdlibPillowTest.MspHeader("DanM", 9, 2), [111, 0, 190, 128])
    }

    static MspLinSBytes()
    {
        return StdlibPillowTest.ConcatBytes(
            StdlibPillowTest.MspHeader("LinS", 9, 2),
            StdlibPillowTest.Le16(3),
            StdlibPillowTest.Le16(3),
            [2, 111, 0],
            [2, 190, 128]
        )
    }

    static MspLinSZeroRowBytes()
    {
        return StdlibPillowTest.ConcatBytes(
            StdlibPillowTest.MspHeader("LinS", 9, 2),
            StdlibPillowTest.Le16(0),
            StdlibPillowTest.Le16(3),
            [2, 190, 128]
        )
    }

    static MspLinSTruncatedRowMapBytes()
    {
        return StdlibPillowTest.ConcatBytes(StdlibPillowTest.MspHeader("LinS", 9, 2), StdlibPillowTest.Le16(3))
    }

    static MspLinSTruncatedRowBytes()
    {
        return StdlibPillowTest.ConcatBytes(StdlibPillowTest.MspHeader("LinS", 9, 2), StdlibPillowTest.Le16(3), StdlibPillowTest.Le16(0), [3, 1])
    }

    static MspLinSCorruptedRowBytes()
    {
        return StdlibPillowTest.ConcatBytes(StdlibPillowTest.MspHeader("LinS", 9, 2), StdlibPillowTest.Le16(2), StdlibPillowTest.Le16(0), [0, 2])
    }

    static MspHeader(magic, width, height)
    {
        header := StdlibPillowTest.ConcatBytes(
            StdlibPillowTest.AsciiBytes(magic),
            StdlibPillowTest.Le16(width),
            StdlibPillowTest.Le16(height),
            StdlibPillowTest.Le16(1),
            StdlibPillowTest.Le16(1),
            StdlibPillowTest.Le16(1),
            StdlibPillowTest.Le16(1),
            StdlibPillowTest.Le16(width),
            StdlibPillowTest.Le16(height),
            StdlibPillowTest.Le16(0),
            StdlibPillowTest.Le16(0),
            StdlibPillowTest.Le16(0),
            StdlibPillowTest.Le16(0),
            StdlibPillowTest.Le16(0),
            StdlibPillowTest.Le16(0)
        )
        checksum := StdlibPillowTest.MspChecksum(header)
        header[25] := checksum & 0xFF
        header[26] := (checksum >> 8) & 0xFF
        return header
    }

    static MspChecksum(bytes)
    {
        checksum := 0
        index := 1
        while index + 1 <= bytes.Length {
            checksum := checksum ^ (bytes[index] | (bytes[index + 1] << 8))
            index += 2
        }
        return checksum
    }

    static PalmOneBytes()
    {
        return [0, 9, 0, 2, 0, 2, 0, 0, 1, 0, 0, 0, 0, 255, 0, 0, 144, 128, 65, 0]
    }

    static PalmPBytes()
    {
        return [
            0, 2, 0, 2, 0, 2, 64, 0, 8, 1, 0, 0, 0, 255, 0, 0,
            0, 4, 0, 255, 0, 0, 1, 0, 255, 0, 2, 0, 0, 255, 3, 1, 2, 3,
            0, 1, 2, 3
        ]
    }

    static PalmPNoPaletteBytes()
    {
        return [0, 1, 0, 1, 0, 2, 64, 0, 8, 1, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0]
    }

    static PcdBytes(orientation := 0, marker := "PCD_")
    {
        bytes := []
        loop 2048
            bytes.Push(0)
        sector := []
        loop 2048
            sector.Push(0)
        markerBytes := StdlibPillowTest.AsciiBytes(marker)
        for byte in markerBytes
            sector[A_Index] := byte
        sector[1539] := orientation
        for byte in sector
            bytes.Push(byte)
        return bytes
    }

    static Jp2Box(type, payload)
    {
        bytes := StdlibPillowTest.Be32(payload.Length + 8)
        for byte in StdlibPillowTest.AsciiBytes(type)
            bytes.Push(byte)
        for byte in payload
            bytes.Push(byte)
        return bytes
    }

    static Jp2Bytes(width, height, components, bpc, brand := "jp2 ", dpi := false, cmyk := false)
    {
        signature := [0, 0, 0, 12]
        for byte in StdlibPillowTest.AsciiBytes("jP  ")
            signature.Push(byte)
        for byte in [13, 10, 135, 10]
            signature.Push(byte)

        ftypPayload := StdlibPillowTest.AsciiBytes(brand)
        for byte in [0, 0, 0, 0]
            ftypPayload.Push(byte)
        for byte in StdlibPillowTest.AsciiBytes(brand)
            ftypPayload.Push(byte)

        ihdrPayload := []
        for byte in StdlibPillowTest.Be32(height)
            ihdrPayload.Push(byte)
        for byte in StdlibPillowTest.Be32(width)
            ihdrPayload.Push(byte)
        for byte in StdlibPillowTest.Be16(components)
            ihdrPayload.Push(byte)
        for byte in [bpc, 0, 0, 0]
            ihdrPayload.Push(byte)

        headerPayload := StdlibPillowTest.Jp2Box("ihdr", ihdrPayload)
        if cmyk {
            colrPayload := [1, 0, 0]
            for byte in StdlibPillowTest.Be32(12)
                colrPayload.Push(byte)
            for byte in StdlibPillowTest.Jp2Box("colr", colrPayload)
                headerPayload.Push(byte)
        }
        if dpi {
            rescPayload := []
            for value in [300, 254, 600, 254]
                for byte in StdlibPillowTest.Be16(value)
                    rescPayload.Push(byte)
            for byte in [2, 2]
                rescPayload.Push(byte)
            resPayload := StdlibPillowTest.Jp2Box("resc", rescPayload)
            for byte in StdlibPillowTest.Jp2Box("res ", resPayload)
                headerPayload.Push(byte)
        }

        return StdlibPillowTest.ConcatBytes(
            signature,
            StdlibPillowTest.Jp2Box("ftyp", ftypPayload),
            StdlibPillowTest.Jp2Box("jp2h", headerPayload)
        )
    }

    static J2kBytes(width, height, components, ssiz, comment)
    {
        bytes := [0xFF, 0x4F, 0xFF, 0x51]
        for byte in StdlibPillowTest.Be16(38 + components * 3)
            bytes.Push(byte)
        for byte in StdlibPillowTest.Be16(0)
            bytes.Push(byte)
        for value in [width, height, 0, 0, width, height, 0, 0]
            for byte in StdlibPillowTest.Be32(value)
                bytes.Push(byte)
        for byte in StdlibPillowTest.Be16(components)
            bytes.Push(byte)
        loop components {
            bytes.Push(ssiz)
            bytes.Push(1)
            bytes.Push(1)
        }
        commentBytes := StdlibPillowTest.AsciiBytes(comment)
        bytes.Push(0xFF)
        bytes.Push(0x64)
        for byte in StdlibPillowTest.Be16(4 + commentBytes.Length)
            bytes.Push(byte)
        bytes.Push(0)
        bytes.Push(0)
        for byte in commentBytes
            bytes.Push(byte)
        bytes.Push(0xFF)
        bytes.Push(0x90)
        return bytes
    }

    static AsciiList(values)
    {
        result := []
        if values is Array {
            for item in values
                result.Push(StdlibPillowTest.AsciiFromBytes(item))
        } else {
            result.Push(StdlibPillowTest.AsciiFromBytes(values))
        }
        return result
    }

    static CountPngSignatures(bytes)
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

    static IcoLe16(bytes, offset)
    {
        return bytes[offset] | (bytes[offset + 1] << 8)
    }

    static IcoLe32(bytes, offset)
    {
        return bytes[offset] | (bytes[offset + 1] << 8) | (bytes[offset + 2] << 16) | (bytes[offset + 3] << 24)
    }

    static IcoDirectoryEntries(bytes)
    {
        count := StdlibPillowTest.IcoLe16(bytes, 5)
        entries := []
        loop count {
            entryOffset := 7 + (A_Index - 1) * 16
            payloadOffset := StdlibPillowTest.IcoLe32(bytes, entryOffset + 12)
            entries.Push(Map(
                "width", bytes[entryOffset] ? bytes[entryOffset] : 256,
                "height", bytes[entryOffset + 1] ? bytes[entryOffset + 1] : 256,
                "nb_color", bytes[entryOffset + 2],
                "reserved", bytes[entryOffset + 3],
                "planes", StdlibPillowTest.IcoLe16(bytes, entryOffset + 4),
                "bpp", StdlibPillowTest.IcoLe16(bytes, entryOffset + 6),
                "size", StdlibPillowTest.IcoLe32(bytes, entryOffset + 8),
                "offset", payloadOffset,
                "payload_prefix", StdlibPillowTest.ArraySlice(bytes, payloadOffset + 1, payloadOffset + 8)
            ))
        }
        return entries
    }

    static CurDibBytes(width, height, fill, point := unset)
    {
        image := unset
        try {
            image := stdlib.pillow.Image.new("RGB", [width, height], fill)
            if IsSet(point)
                image.putpixel([point[1], point[2]], point[3])
            buffer := stdlib.io.BytesIO()
            image.save(buffer, "BMP")
            bytes := buffer.getvalue()
            return StdlibPillowTest.ArraySlice(bytes, 15, bytes.Length)
        } finally {
            if IsSet(image)
                StdlibPillowTest.CloseImage(image)
        }
    }

    static CurBytes(entries)
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

    static PixarBytes(width := 2, height := 2, channelDesc := 14, depthDesc := 2, pixels := unset)
    {
        if !IsSet(pixels)
            pixels := [[10, 20, 30], [200, 10, 5], [40, 50, 60], [1, 2, 3]]
        bytes := []
        loop 1024
            bytes.Push(0)
        bytes[1] := 0x80
        bytes[2] := 0xE8
        StdlibPillowTest.PutLe16(bytes, 417, height)
        StdlibPillowTest.PutLe16(bytes, 419, width)
        StdlibPillowTest.PutLe16(bytes, 425, channelDesc)
        StdlibPillowTest.PutLe16(bytes, 427, depthDesc)
        for pixel in pixels {
            for byte in pixel
                bytes.Push(byte)
        }
        return bytes
    }

    static PutLe16(bytes, offset, value)
    {
        bytes[offset] := value & 0xFF
        bytes[offset + 1] := (value >> 8) & 0xFF
        return stdlib.None
    }

    static PcxRgbBytes(width, height, fill, point := unset)
    {
        data := []
        loop height {
            y := A_Index - 1
            loop width {
                x := A_Index - 1
                pixel := fill
                if IsSet(point) && x = point[1] && y = point[2]
                    pixel := point[3]
                data.Push(pixel)
            }
        }
        return StdlibPillowTest.PcxBytes("RGB", [width, height], data)
    }

    static PcxBytes(mode, size, data, palette := unset)
    {
        width := size[1]
        height := size[2]
        spec := Map("1", [2, 1, 1, "1"], "L", [5, 8, 1, "L"], "P", [5, 8, 1, "P"], "RGB", [5, 8, 3, "RGB;L"])[mode]
        version := spec[1]
        bits := spec[2]
        planes := spec[3]
        stride := (width * bits + 7) // 8
        stride += Mod(stride, 2)
        bytes := [
            10, version, 1, bits,
            0, 0, 0, 0,
            (width - 1) & 0xFF, ((width - 1) >> 8) & 0xFF,
            (height - 1) & 0xFF, ((height - 1) >> 8) & 0xFF,
            100, 0, 100, 0,
        ]
        loop 24
            bytes.Push(0)
        loop 24
            bytes.Push(255)
        bytes.Push(0)
        bytes.Push(planes)
        for byte in stdlib.pillow.BmpImagePlugin.o16(stride)
            bytes.Push(byte)
        for byte in stdlib.pillow.BmpImagePlugin.o16(1)
            bytes.Push(byte)
        for byte in stdlib.pillow.BmpImagePlugin.o16(width)
            bytes.Push(byte)
        for byte in stdlib.pillow.BmpImagePlugin.o16(height)
            bytes.Push(byte)
        loop 54
            bytes.Push(0)

        loop height {
            rowStart := (A_Index - 1) * width + 1
            if mode = "RGB" {
                loop 3 {
                    channel := A_Index
                    plane := []
                    loop width
                        plane.Push(data[rowStart + A_Index - 1][channel])
                    while plane.Length < stride
                        plane.Push(0)
                    for byte in StdlibPillowTest.PcxEncodeRle(plane)
                        bytes.Push(byte)
                }
            } else if mode = "1" {
                plane := StdlibPillowTest.PcxPackOneBits(StdlibPillowTest.ArraySlice(data, rowStart, rowStart + width - 1))
                while plane.Length < stride
                    plane.Push(0)
                for byte in StdlibPillowTest.PcxEncodeRle(plane)
                    bytes.Push(byte)
            } else {
                plane := StdlibPillowTest.ArraySlice(data, rowStart, rowStart + width - 1)
                while plane.Length < stride
                    plane.Push(0)
                for byte in StdlibPillowTest.PcxEncodeRle(plane)
                    bytes.Push(byte)
            }
        }

        if mode = "P" {
            bytes.Push(12)
            paletteBytes := IsSet(palette) ? palette.Clone() : []
            while paletteBytes.Length < 768
                paletteBytes.Push(0)
            for byte in StdlibPillowTest.ArraySlice(paletteBytes, 1, 768)
                bytes.Push(byte)
        } else if mode = "L" {
            bytes.Push(12)
            loop 256 {
                value := A_Index - 1
                bytes.Push(value)
                bytes.Push(value)
                bytes.Push(value)
            }
        }
        return bytes
    }

    static PcxPackOneBits(values)
    {
        packed := []
        current := 0
        bit := 7
        for value in values {
            current |= (value ? 1 : 0) << bit
            bit -= 1
            if bit < 0 {
                packed.Push(current)
                current := 0
                bit := 7
            }
        }
        if bit != 7
            packed.Push(current)
        return packed
    }

    static PcxEncodeRle(values)
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

    static DcxBytes(frames)
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

    static DdsHeader(headerSize, payload)
    {
        bytes := StdlibPillowTest.AsciiBytes("DDS ")
        for byte in stdlib.pillow.BmpImagePlugin.o32(headerSize)
            bytes.Push(byte)
        for byte in payload
            bytes.Push(byte)
        return bytes
    }

    static EpsMacBytes(payload)
    {
        bytes := [0xC5, 0xD0, 0xD3, 0xC6]
        for byte in stdlib.pillow.BmpImagePlugin.o32(12)
            bytes.Push(byte)
        for byte in stdlib.pillow.BmpImagePlugin.o32(payload.Length)
            bytes.Push(byte)
        for byte in payload
            bytes.Push(byte)
        return bytes
    }

    static FitsCard(keyword, value := unset)
    {
        key := String(keyword)
        while StrLen(key) < 8
            key .= " "
        if StrLen(key) > 8
            key := SubStr(key, 1, 8)
        text := IsSet(value) ? key "= " value : key
        bytes := StdlibPillowTest.AsciiBytes(text)
        while bytes.Length < 80
            bytes.Push(32)
        while bytes.Length > 80
            bytes.Pop()
        return bytes
    }

    static FitsHeader(cards)
    {
        bytes := []
        for cardBytes in cards {
            for byte in cardBytes
                bytes.Push(byte)
        }
        for byte in StdlibPillowTest.FitsCard("END")
            bytes.Push(byte)
        while Mod(bytes.Length, 2880) != 0
            bytes.Push(32)
        return bytes
    }

    static FitsSimpleBytes(bitpix := 8, naxis := 2, dims := unset, data := unset)
    {
        if !IsSet(dims)
            dims := [3, 2]
        cards := [
            StdlibPillowTest.FitsCard("SIMPLE", "T"),
            StdlibPillowTest.FitsCard("BITPIX", String(bitpix)),
            StdlibPillowTest.FitsCard("NAXIS", String(naxis)),
        ]
        for index, dim in dims
            cards.Push(StdlibPillowTest.FitsCard("NAXIS" index, String(dim)))
        bytes := StdlibPillowTest.FitsHeader(cards)
        if IsSet(data) {
            for byte in data
                bytes.Push(byte)
        } else {
            loop 80
                bytes.Push(0)
        }
        return bytes
    }

    static FitsGzipBytes()
    {
        primary := StdlibPillowTest.FitsHeader([
            StdlibPillowTest.FitsCard("SIMPLE", "T"),
            StdlibPillowTest.FitsCard("BITPIX", "8"),
            StdlibPillowTest.FitsCard("NAXIS", "0"),
        ])
        extension := StdlibPillowTest.FitsHeader([
            StdlibPillowTest.FitsCard("XTENSION", "'BINTABLE'"),
            StdlibPillowTest.FitsCard("BITPIX", "8"),
            StdlibPillowTest.FitsCard("NAXIS", "2"),
            StdlibPillowTest.FitsCard("NAXIS1", "4"),
            StdlibPillowTest.FitsCard("NAXIS2", "3"),
            StdlibPillowTest.FitsCard("ZIMAGE", "T"),
            StdlibPillowTest.FitsCard("ZCMPTYPE", "'GZIP_1  '"),
            StdlibPillowTest.FitsCard("ZBITPIX", "16"),
            StdlibPillowTest.FitsCard("ZNAXIS", "2"),
            StdlibPillowTest.FitsCard("ZNAXIS1", "2"),
            StdlibPillowTest.FitsCard("ZNAXIS2", "2"),
        ])
        bytes := []
        for byte in primary
            bytes.Push(byte)
        for byte in extension
            bytes.Push(byte)
        loop 80
            bytes.Push(0)
        return bytes
    }

    static FitsBadMagicBytes()
    {
        bytes := StdlibPillowTest.FitsHeader([
            StdlibPillowTest.FitsCard("BAD", "T"),
        ])
        loop 80
            bytes.Push(0)
        return bytes
    }

    static FliHeader(magic := 0xAF12, frames := 1, width := 3, height := 2, duration := 70, flags := 0)
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

    static FliFrameChunk(subchunks := unset, subchunkCount := 0)
    {
        if !IsSet(subchunks)
            subchunks := []
        size := 16 + subchunks.Length
        bytes := []
        for byte in stdlib.pillow.BmpImagePlugin.o32(size)
            bytes.Push(byte)
        for byte in stdlib.pillow.BmpImagePlugin.o16(0xF1FA)
            bytes.Push(byte)
        for byte in stdlib.pillow.BmpImagePlugin.o16(subchunkCount)
            bytes.Push(byte)
        while bytes.Length < 16
            bytes.Push(0)
        for byte in subchunks
            bytes.Push(byte)
        return bytes
    }

    static FliPrefixChunk(size := 16)
    {
        bytes := []
        for byte in stdlib.pillow.BmpImagePlugin.o32(size)
            bytes.Push(byte)
        for byte in stdlib.pillow.BmpImagePlugin.o16(0xF100)
            bytes.Push(byte)
        while bytes.Length < size
            bytes.Push(0)
        return bytes
    }

    static FliPaletteSubchunk(chunkType, rgb, skip := 0)
    {
        payload := []
        for byte in stdlib.pillow.BmpImagePlugin.o16(1)
            payload.Push(byte)
        payload.Push(skip)
        payload.Push(1)
        for byte in rgb
            payload.Push(byte)
        bytes := []
        for byte in stdlib.pillow.BmpImagePlugin.o32(6 + payload.Length)
            bytes.Push(byte)
        for byte in stdlib.pillow.BmpImagePlugin.o16(chunkType)
            bytes.Push(byte)
        for byte in payload
            bytes.Push(byte)
        return bytes
    }

    static FliBytes(magic := 0xAF12, frames := 1, duration := 70, flags := 0, chunks := unset)
    {
        if !IsSet(chunks)
            chunks := [StdlibPillowTest.FliFrameChunk()]
        bytes := StdlibPillowTest.FliHeader(magic, frames, 3, 2, duration, flags)
        for chunk in chunks {
            for byte in chunk
                bytes.Push(byte)
        }
        return bytes
    }

    static FpxMagicBytes(tail := unset)
    {
        bytes := [208, 207, 17, 224, 161, 177, 26, 225]
        if IsSet(tail) {
            for byte in tail
                bytes.Push(byte)
        }
        return bytes
    }

    static FpxModeBlob(colors)
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

    static FpxDescriptor(offset, compression, extra := unset, length := 16)
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

    static FpxHeaderStream(size := unset, tileSize := unset, descriptors := unset, descriptorLength := 16)
    {
        if !IsSet(size)
            size := [128, 64]
        if !IsSet(tileSize)
            tileSize := [64, 64]
        if !IsSet(descriptors)
            descriptors := [StdlibPillowTest.FpxDescriptor(100, 0), StdlibPillowTest.FpxDescriptor(200, 0)]
        bytes := []
        loop 28
            bytes.Push(0)
        header := []
        loop 4
            header.Push(0)
        for byte in stdlib.pillow.BmpImagePlugin.o32(size[1])
            header.Push(byte)
        for byte in stdlib.pillow.BmpImagePlugin.o32(size[2])
            header.Push(byte)
        for byte in stdlib.pillow.BmpImagePlugin.o32(descriptors.Length)
            header.Push(byte)
        for byte in stdlib.pillow.BmpImagePlugin.o32(tileSize[1])
            header.Push(byte)
        for byte in stdlib.pillow.BmpImagePlugin.o32(tileSize[2])
            header.Push(byte)
        for byte in stdlib.pillow.BmpImagePlugin.o32(3)
            header.Push(byte)
        for byte in stdlib.pillow.BmpImagePlugin.o32(64)
            header.Push(byte)
        for byte in stdlib.pillow.BmpImagePlugin.o32(descriptorLength)
            header.Push(byte)
        for byte in header
            bytes.Push(byte)
        loop 28
            bytes.Push(0)
        for descriptorBytes in descriptors {
            for byte in descriptorBytes
                bytes.Push(byte)
        }
        return bytes
    }

    static FtexBytes(width, height, format, payload, version := 1, mipmapCount := 1, formatCount := 1, where := 32)
    {
        bytes := StdlibPillowTest.AsciiBytes("FTEX")
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

    static GbrPrefix(headerSize, version)
    {
        bytes := []
        for byte in StdlibPillowTest.Be32(headerSize)
            bytes.Push(byte)
        for byte in StdlibPillowTest.Be32(version)
            bytes.Push(byte)
        return bytes
    }

    static GbrBytes(width, height, colorDepth, payload, version := 2, comment := "brush", spacing := 7, options := unset)
    {
        magic := "GIMP"
        headerSize := unset
        if IsSet(options) && IsObject(options) {
            if options.HasProp("magic")
                magic := options.magic
            if options.HasProp("header_size")
                headerSize := options.header_size
        } else if IsSet(options) && options is Integer {
            headerSize := options
        }

        commentBytes := StdlibPillowTest.AsciiBytes(comment)
        commentBytes.Push(0)
        if !IsSet(headerSize)
            headerSize := (version = 1 ? 20 : 28) + commentBytes.Length

        bytes := []
        for byte in StdlibPillowTest.Be32(headerSize)
            bytes.Push(byte)
        for byte in StdlibPillowTest.Be32(version)
            bytes.Push(byte)
        for byte in StdlibPillowTest.Be32(width)
            bytes.Push(byte)
        for byte in StdlibPillowTest.Be32(height)
            bytes.Push(byte)
        for byte in StdlibPillowTest.Be32(colorDepth)
            bytes.Push(byte)
        if version != 1 {
            for byte in StdlibPillowTest.AsciiBytes(magic)
                bytes.Push(byte)
            for byte in StdlibPillowTest.Be32(spacing)
                bytes.Push(byte)
        }
        for byte in commentBytes
            bytes.Push(byte)
        for byte in payload
            bytes.Push(byte)
        return bytes
    }

    static GdBytes(width, height, trueColor, transparency, pixels, magic := 65534)
    {
        bytes := []
        for byte in StdlibPillowTest.Be16(magic)
            bytes.Push(byte)
        for byte in StdlibPillowTest.Be16(width)
            bytes.Push(byte)
        for byte in StdlibPillowTest.Be16(height)
            bytes.Push(byte)
        bytes.Push(trueColor)
        if trueColor {
            bytes.Push(88)
            bytes.Push(89)
        }
        for byte in StdlibPillowTest.Be32(transparency)
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

    static GifBytes(version := "GIF89a", transparent := true, comment := true, loopExtension := true)
    {
        bytes := StdlibPillowTest.AsciiBytes(version)
        for byte in StdlibPillowTest.Le16(2)
            bytes.Push(byte)
        for byte in StdlibPillowTest.Le16(2)
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
            for byte in StdlibPillowTest.AsciiBytes("hello")
                bytes.Push(byte)
            bytes.Push(0)
        }
        if loopExtension {
            bytes.Push(0x21)
            bytes.Push(0xFF)
            bytes.Push(11)
            for byte in StdlibPillowTest.AsciiBytes("NETSCAPE2.0")
                bytes.Push(byte)
            bytes.Push(3)
            bytes.Push(1)
            for byte in StdlibPillowTest.Le16(7)
                bytes.Push(byte)
            bytes.Push(0)
        }
        if transparent {
            bytes.Push(0x21)
            bytes.Push(0xF9)
            bytes.Push(4)
            bytes.Push(1)
            for byte in StdlibPillowTest.Le16(5)
                bytes.Push(byte)
            bytes.Push(2)
            bytes.Push(0)
        }
        bytes.Push(0x2C)
        for byte in StdlibPillowTest.Le16(0)
            bytes.Push(byte)
        for byte in StdlibPillowTest.Le16(0)
            bytes.Push(byte)
        for byte in StdlibPillowTest.Le16(2)
            bytes.Push(byte)
        for byte in StdlibPillowTest.Le16(2)
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

    static PsdBytes(modeCode, bits, channels, width, height, channelData, colorData := unset, resources := unset, layerInfo := unset, compression := 0, version := 1, magic := "8BPS")
    {
        if !IsSet(colorData)
            colorData := []
        if !IsSet(resources)
            resources := []
        if !IsSet(layerInfo)
            layerInfo := []

        header := StdlibPillowTest.ConcatBytes(
            StdlibPillowTest.AsciiBytes(magic),
            StdlibPillowTest.Be16(version),
            [0, 0, 0, 0, 0, 0],
            StdlibPillowTest.Be16(channels),
            StdlibPillowTest.Be32(height),
            StdlibPillowTest.Be32(width),
            StdlibPillowTest.Be16(bits),
            StdlibPillowTest.Be16(modeCode)
        )
        layerSection := []
        if layerInfo.Length
            layerSection := StdlibPillowTest.ConcatBytes(StdlibPillowTest.Be32(layerInfo.Length), layerInfo)
        return StdlibPillowTest.ConcatBytes(
            header,
            StdlibPillowTest.Be32(colorData.Length),
            colorData,
            StdlibPillowTest.Be32(resources.Length),
            resources,
            StdlibPillowTest.Be32(layerSection.Length),
            layerSection,
            StdlibPillowTest.Be16(compression),
            channelData
        )
    }

    static PsdPalette()
    {
        bytes := []
        loop 256
            bytes.Push(A_Index - 1)
        loop 256
            bytes.Push(256 - A_Index)
        loop 256
            bytes.Push(42)
        return bytes
    }

    static PsdResourceBlock(resourceId, name, data)
    {
        nameBytes := StdlibPillowTest.AsciiBytes(name)
        pascal := [nameBytes.Length]
        for byte in nameBytes
            pascal.Push(byte)
        if Mod(nameBytes.Length, 2) = 0
            pascal.Push(0)

        bytes := StdlibPillowTest.ConcatBytes(
            StdlibPillowTest.AsciiBytes("8BIM"),
            StdlibPillowTest.Be16(resourceId),
            pascal,
            StdlibPillowTest.Be32(data.Length),
            data
        )
        if Mod(data.Length, 2)
            bytes.Push(0)
        return bytes
    }

    static PsdLayerInfoBytes()
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
            for byte in StdlibPillowTest.PsdS32(bbox[2])
                records.Push(byte)
            for byte in StdlibPillowTest.PsdS32(bbox[1])
                records.Push(byte)
            for byte in StdlibPillowTest.PsdS32(bbox[4])
                records.Push(byte)
            for byte in StdlibPillowTest.PsdS32(bbox[3])
                records.Push(byte)
            for byte in StdlibPillowTest.Be16(channels.Length)
                records.Push(byte)
            for channel in channels {
                for byte in StdlibPillowTest.Be16(channel[1])
                    records.Push(byte)
                for byte in StdlibPillowTest.Be32(2 + channel[2].Length)
                    records.Push(byte)
            }
            for byte in StdlibPillowTest.AsciiBytes("8BIMnorm")
                records.Push(byte)
            for byte in [255, 0, 0, 0]
                records.Push(byte)
            extra := StdlibPillowTest.ConcatBytes(StdlibPillowTest.Be32(0), StdlibPillowTest.Be32(0), StdlibPillowTest.PsdPascalName(layer["name"]))
            for byte in StdlibPillowTest.Be32(extra.Length)
                records.Push(byte)
            for byte in extra
                records.Push(byte)
            for channel in channels {
                for byte in StdlibPillowTest.Be16(0)
                    payload.Push(byte)
                for byte in channel[2]
                    payload.Push(byte)
                if Mod(payload.Length, 2)
                    payload.Push(0)
            }
        }
        return StdlibPillowTest.ConcatBytes(StdlibPillowTest.PsdS16(layers.Length), records, payload)
    }

    static PsdPascalName(name)
    {
        nameBytes := StdlibPillowTest.AsciiBytes(name)
        bytes := [nameBytes.Length]
        for byte in nameBytes
            bytes.Push(byte)
        while Mod(bytes.Length, 4)
            bytes.Push(0)
        return bytes
    }

    static PsdS16(value)
    {
        value := Integer(value)
        if value < 0
            value += 0x10000
        return StdlibPillowTest.Be16(value)
    }

    static PsdS32(value)
    {
        value := Integer(value)
        if value < 0
            value += 0x100000000
        return StdlibPillowTest.Be32(value)
    }

    static QoiBytes(width, height, channels, payload, colorspace := 1)
    {
        return StdlibPillowTest.ConcatBytes(
            StdlibPillowTest.AsciiBytes("qoif"),
            StdlibPillowTest.Be32(width),
            StdlibPillowTest.Be32(height),
            [channels, colorspace],
            payload,
            [0, 0, 0, 0, 0, 0, 0, 1]
        )
    }

    static SgiHeader(width, height, zsize, bpc := 1, dimension := 3, compression := 0, name := "")
    {
        nameBytes := StdlibPillowTest.AsciiBytes(SubStr(name, 1, 79))
        nameField := []
        for byte in nameBytes
            nameField.Push(byte)
        while nameField.Length < 80
            nameField.Push(0)
        padding := []
        loop 404
            padding.Push(0)
        return StdlibPillowTest.ConcatBytes(
            StdlibPillowTest.Be16(474),
            [compression, bpc],
            StdlibPillowTest.Be16(dimension),
            StdlibPillowTest.Be16(width),
            StdlibPillowTest.Be16(height),
            StdlibPillowTest.Be16(zsize),
            StdlibPillowTest.Be32(0),
            StdlibPillowTest.Be32(255),
            [0, 0, 0, 0],
            nameField,
            StdlibPillowTest.Be32(0),
            padding
        )
    }

    static SgiRawBytes(width, height, zsize, planes, bpc := 1, dimension := 3, name := "")
    {
        parts := [StdlibPillowTest.SgiHeader(width, height, zsize, bpc, dimension, 0, name)]
        for plane in planes
            parts.Push(plane)
        return StdlibPillowTest.ConcatBytes(parts*)
    }

    static SgiRleBytes(width, height, zsize, rowsByChannel, bpc := 1, dimension := 3)
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
        parts := [StdlibPillowTest.SgiHeader(width, height, zsize, bpc, dimension, 1)]
        for value in offsets
            parts.Push(StdlibPillowTest.Be32(value))
        for value in lengths
            parts.Push(StdlibPillowTest.Be32(value))
        for payload in payloads
            parts.Push(payload)
        return StdlibPillowTest.ConcatBytes(parts*)
    }

    static SunBytes(width, height, depth, payload, fileType := 1, paletteType := 0, palette := unset, magic := 0x59A66A95)
    {
        if !IsSet(palette)
            palette := []
        return StdlibPillowTest.ConcatBytes(
            StdlibPillowTest.Be32(magic),
            StdlibPillowTest.Be32(width),
            StdlibPillowTest.Be32(height),
            StdlibPillowTest.Be32(depth),
            StdlibPillowTest.Be32(payload.Length),
            StdlibPillowTest.Be32(fileType),
            StdlibPillowTest.Be32(paletteType),
            StdlibPillowTest.Be32(palette.Length),
            palette,
            payload
        )
    }

    static TgaBytes(width, height, depth, payload, imageType, flags := 0x20, idSection := unset, palette := unset, paletteEntry := 0, paletteFirst := 0)
    {
        if !IsSet(idSection)
            idSection := []
        if !IsSet(palette)
            palette := []
        paletteBytesPerEntry := paletteEntry ? paletteEntry // 8 : 0
        paletteLength := paletteBytesPerEntry ? palette.Length // paletteBytesPerEntry : 0
        return StdlibPillowTest.ConcatBytes(
            [idSection.Length, palette.Length ? 1 : 0, imageType],
            StdlibPillowTest.Le16(paletteFirst),
            StdlibPillowTest.Le16(paletteLength),
            [paletteEntry],
            StdlibPillowTest.Le16(0),
            StdlibPillowTest.Le16(0),
            StdlibPillowTest.Le16(width),
            StdlibPillowTest.Le16(height),
            [depth, flags],
            idSection,
            palette,
            payload
        )
    }

    static ZeroBytes(count)
    {
        bytes := []
        loop count
            bytes.Push(0)
        return bytes
    }

    static SpiderHeaderValues(width := 2, height := 2, iform := 1, istack := 0, nimages := 1, imgnumber := 0)
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

    static SpiderHeader(width := 2, height := 2, little := true, iform := 1, istack := 0, nimages := 1, imgnumber := 0)
    {
        bytes := []
        for value in StdlibPillowTest.SpiderHeaderValues(width, height, iform, istack, nimages, imgnumber)
            for byte in StdlibPillowTest.Float32(value, little)
                bytes.Push(byte)
        return bytes
    }

    static SpiderImageBytes(width := 2, height := 2, pixels := unset, little := true, iform := 1, istack := 0, nimages := 1, imgnumber := 0)
    {
        if !IsSet(pixels)
            pixels := [0.0, 1.0, 2.5, 5.0]
        parts := [StdlibPillowTest.SpiderHeader(width, height, little, iform, istack, nimages, imgnumber)]
        data := []
        for value in pixels
            for byte in StdlibPillowTest.Float32(value, little)
                data.Push(byte)
        parts.Push(data)
        return StdlibPillowTest.ConcatBytes(parts*)
    }

    static SpiderStackBytes()
    {
        frame1 := []
        for value in [1.0, 2.0, 3.0, 4.0]
            for byte in StdlibPillowTest.Float32(value, true)
                frame1.Push(byte)
        frame2 := []
        for value in [10.0, 20.0, 30.0, 40.0]
            for byte in StdlibPillowTest.Float32(value, true)
                frame2.Push(byte)
        return StdlibPillowTest.ConcatBytes(
            StdlibPillowTest.SpiderHeader(2, 2, true, 1, 1, 2, 0),
            StdlibPillowTest.SpiderHeader(2, 2, true, 1, 0, 0, 1),
            frame1,
            StdlibPillowTest.SpiderHeader(2, 2, true, 1, 0, 0, 2),
            frame2
        )
    }

    static Float32(value, little := true)
    {
        bytes := Buffer(4, 0)
        NumPut("Float", value + 0.0, bytes, 0)
        if little
            return [NumGet(bytes, 0, "UChar"), NumGet(bytes, 1, "UChar"), NumGet(bytes, 2, "UChar"), NumGet(bytes, 3, "UChar")]
        return [NumGet(bytes, 3, "UChar"), NumGet(bytes, 2, "UChar"), NumGet(bytes, 1, "UChar"), NumGet(bytes, 0, "UChar")]
    }

    static Le16(value)
    {
        value := Integer(value)
        return [value & 0xFF, (value >> 8) & 0xFF]
    }

    static Le32(value)
    {
        value := Integer(value)
        return [value & 0xFF, (value >> 8) & 0xFF, (value >> 16) & 0xFF, (value >> 24) & 0xFF]
    }

    static Be16(value)
    {
        value := Integer(value)
        return [(value >> 8) & 0xFF, value & 0xFF]
    }

    static Be32(value)
    {
        value := Integer(value)
        return [(value >> 24) & 0xFF, (value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF]
    }

    static BytesContainsAscii(bytes, text)
    {
        needle := StdlibPillowTest.AsciiBytes(text)
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

    static CountAscii(bytes, text)
    {
        needle := StdlibPillowTest.AsciiBytes(text)
        if needle.Length = 0 || bytes.Length < needle.Length
            return 0
        count := 0
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
                count += 1
        }
        return count
    }

    static FontGlyphMetrics(glyph)
    {
        return [glyph[1], glyph[2], glyph[3]]
    }

    static CountFontGlyphs(font)
    {
        count := 0
        for glyph in font.glyph {
            if !AhkStdlibIsNone(glyph)
                count += 1
        }
        return count
    }

    static ArraySlice(values, startIndex, endIndex)
    {
        sliced := []
        index := startIndex
        while index <= endIndex && index <= values.Length {
            sliced.Push(values[index])
            index += 1
        }
        return sliced
    }

    static ArrayContains(values, needle)
    {
        for value in values {
            if value = needle
                return true
        }
        return false
    }

    static ArraySum(values)
    {
        total := 0
        for value in values
            total += value
        return total
    }

    static AvifFtyp(brand)
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

    static BlpPaletteImage(paletteMode)
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

    static BlpControlsCode(values := unset)
    {
        if !IsSet(values)
            values := [0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3]
        code := 0
        for index, value in values
            code |= value << (2 * (index - 1))
        return code
    }

    static BlpLe16(value)
    {
        return [value & 0xFF, (value >> 8) & 0xFF]
    }

    static BlpLe32(value)
    {
        return [value & 0xFF, (value >> 8) & 0xFF, (value >> 16) & 0xFF, (value >> 24) & 0xFF]
    }

    static BlpDxt1Block()
    {
        bytes := []
        for byte in StdlibPillowTest.BlpLe16(0xF800)
            bytes.Push(byte)
        for byte in StdlibPillowTest.BlpLe16(0x07E0)
            bytes.Push(byte)
        for byte in StdlibPillowTest.BlpLe32(StdlibPillowTest.BlpControlsCode())
            bytes.Push(byte)
        return bytes
    }

    static BlpDxt1TransparentBlock()
    {
        bytes := []
        for byte in StdlibPillowTest.BlpLe16(0x001F)
            bytes.Push(byte)
        for byte in StdlibPillowTest.BlpLe16(0xFFFF)
            bytes.Push(byte)
        for byte in StdlibPillowTest.BlpLe32(StdlibPillowTest.BlpControlsCode())
            bytes.Push(byte)
        return bytes
    }

    static BlpDxt3Block()
    {
        bytes := [0x10, 0x32, 0x54, 0x76, 0x98, 0xBA, 0xDC, 0xFE]
        for byte in StdlibPillowTest.BlpDxt1Block()
            bytes.Push(byte)
        return bytes
    }

    static BlpDxt5Block()
    {
        alphaBits := 0
        for index, value in [0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 2, 3, 4, 5, 6, 7]
            alphaBits |= value << (3 * (index - 1))
        bytes := [200, 20]
        loop 6 {
            bytes.Push((alphaBits >> (8 * (A_Index - 1))) & 0xFF)
        }
        for byte in StdlibPillowTest.BlpDxt1Block()
            bytes.Push(byte)
        return bytes
    }

    static TransformSourceImage()
    {
        image := stdlib.pillow.Image.new("RGB", [3, 2], [0, 0, 0])
        values := [
            [[0, 0], [10, 20, 30]],
            [[1, 0], [40, 50, 60]],
            [[2, 0], [70, 80, 90]],
            [[0, 1], [100, 110, 120]],
            [[1, 1], [130, 140, 150]],
            [[2, 1], [160, 170, 180]],
        ]
        for item in values
            image.putpixel(item[1], item[2])
        return image
    }

    static PixelRows(image)
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

    static RangeTable()
    {
        values := []
        loop 256
            values.Push(A_Index - 1)
        return values
    }

    static Take(values, count)
    {
        result := []
        loop count
            result.Push(values[A_Index])
        return result
    }

    static ToArray(values)
    {
        result := []
        for value in values
            result.Push(value)
        return result
    }

    static RoundValues(values, places)
    {
        rounded := []
        for value in values
            rounded.Push(Round(value, places))
        return rounded
    }

    static Repeat(value, count)
    {
        result := []
        loop count
            result.Push(value)
        return result
    }

    static AssertPixelsComeFrom(image, allowedPixels)
    {
        allowed := Map()
        for pixel in allowedPixels
            allowed[StdlibPillowTest.PixelKey(pixel)] := true
        for row in StdlibPillowTest.PixelRows(image) {
            for pixel in row
                AhkTest.AssertTrue(allowed.Has(StdlibPillowTest.PixelKey(pixel)), "unexpected effect_spread pixel")
        }
    }

    static PixelKey(pixel)
    {
        if pixel is Array {
            text := ""
            for index, value in pixel {
                if index > 1
                    text .= ","
                text .= String(value)
            }
            return text
        }
        return String(pixel)
    }

    static NonBlackPixelCount(image)
    {
        count := 0
        loop image.height {
            y := A_Index - 1
            loop image.width {
                x := A_Index - 1
                if StdlibPillowTest.PixelKey(image.getpixel([x, y])) != "0,0,0"
                    count += 1
            }
        }
        return count
    }

    static FilterSourceImage(mode)
    {
        image := stdlib.pillow.Image.new(mode, [5, 5], mode = "L" ? 0 : (mode = "RGB" ? [0, 0, 0] : [0, 0, 0, 0]))
        loop 5 {
            y := A_Index - 1
            loop 5 {
                x := A_Index - 1
                grayValue := Mod(x * x * 17 + y * 31 + x * y * 9, 256)
                if mode = "L"
                    pixel := grayValue
                else {
                    green := Mod(x * 45 + y * 20, 256)
                    blue := Mod(x * 15 + y * y * 23, 256)
                    if mode = "RGB"
                        pixel := [grayValue, green, blue]
                    else
                        pixel := [grayValue, green, blue, 30 + x * 20 + y * 25]
                }
                image.putpixel([x, y], pixel)
            }
        }
        return image
    }

    static ThumbnailRgbSource()
    {
        image := stdlib.pillow.Image.new("RGB", [6, 4])
        image.putdata([
            [0, 0, 0], [20, 10, 5], [40, 20, 10], [60, 30, 15], [80, 40, 20], [100, 50, 25],
            [10, 30, 60], [30, 40, 65], [50, 50, 70], [70, 60, 75], [90, 70, 80], [110, 80, 85],
            [20, 60, 120], [40, 70, 125], [60, 80, 130], [80, 90, 135], [100, 100, 140], [120, 110, 145],
            [30, 90, 180], [50, 100, 185], [70, 110, 190], [90, 120, 195], [110, 130, 200], [130, 140, 205],
        ])
        return image
    }

    static ModeFilterThresholdImage()
    {
        image := stdlib.pillow.Image.new("L", [5, 5], 0)
        loop 5 {
            y := A_Index - 1
            loop 5 {
                x := A_Index - 1
                value := (x = 1 && y = 1) || (x = 2 && y = 1) || (x = 3 && y = 1) ? 9 : x + y * 10
                image.putpixel([x, y], value)
            }
        }
        return image
    }

    static ChopsLImageA()
    {
        image := stdlib.pillow.Image.new("L", [3, 2], 0)
        for item in [
            [[0, 0], 10], [[1, 0], 100], [[2, 0], 250],
            [[0, 1], 0], [[1, 1], 128], [[2, 1], 255],
        ]
            image.putpixel(item[1], item[2])
        return image
    }

    static ChopsLImageB()
    {
        image := stdlib.pillow.Image.new("L", [3, 2], 0)
        for item in [
            [[0, 0], 20], [[1, 0], 160], [[2, 0], 30],
            [[0, 1], 255], [[1, 1], 128], [[2, 1], 1],
        ]
            image.putpixel(item[1], item[2])
        return image
    }

    static ChopsRgbImageA()
    {
        image := stdlib.pillow.Image.new("RGB", [2, 2], [0, 0, 0])
        values := [
            [[0, 0], [10, 20, 30]],
            [[1, 0], [100, 110, 120]],
            [[0, 1], [200, 210, 220]],
            [[1, 1], [250, 5, 128]],
        ]
        for item in values
            image.putpixel(item[1], item[2])
        return image
    }

    static ChopsRgbImageB()
    {
        image := stdlib.pillow.Image.new("RGB", [2, 2], [0, 0, 0])
        values := [
            [[0, 0], [20, 30, 40]],
            [[1, 0], [160, 170, 180]],
            [[0, 1], [30, 40, 50]],
            [[1, 1], [10, 250, 128]],
        ]
        for item in values
            image.putpixel(item[1], item[2])
        return image
    }

    static OpsRgbImage()
    {
        image := stdlib.pillow.Image.new("RGB", [3, 2], [0, 0, 0])
        values := [
            [[0, 0], [10, 20, 30]],
            [[1, 0], [100, 110, 120]],
            [[2, 0], [200, 210, 220]],
            [[0, 1], [250, 5, 128]],
            [[1, 1], [40, 80, 160]],
            [[2, 1], [0, 255, 10]],
        ]
        for item in values
            image.putpixel(item[1], item[2])
        return image
    }

    static InspectionRgbImage()
    {
        image := stdlib.pillow.Image.new("RGB", [4, 3], [0, 0, 0])
        values := [
            [[0, 0], [0, 0, 0]],
            [[1, 0], [10, 20, 30]],
            [[2, 0], [10, 20, 30]],
            [[3, 0], [255, 255, 255]],
            [[0, 1], [0, 0, 0]],
            [[1, 1], [100, 110, 120]],
            [[2, 1], [200, 210, 220]],
            [[3, 1], [0, 0, 0]],
            [[0, 2], [0, 0, 0]],
            [[1, 2], [0, 0, 0]],
            [[2, 2], [0, 0, 0]],
            [[3, 2], [5, 6, 7]],
        ]
        for item in values
            image.putpixel(item[1], item[2])
        return image
    }

    static RegistryFactory(args*)
    {
        return args.Length
    }

    static RegistrySave(args*)
    {
        return args.Length
    }
}

class StdlibPillowRegistryAccept
{
}

class StdlibPillowRegistryDecoder
{
}

class StdlibPillowRegistryEncoder
{
}

class StdlibPillowDemoDecoder
{
    static Events := []

    static Call(mode, args*)
    {
        return StdlibPillowDemoDecoderInstance(mode, args)
    }
}

class StdlibPillowDemoDecoderInstance
{
    __New(mode, args)
    {
        this.Mode := mode
        this.Args := args.Clone()
        StdlibPillowDemoDecoder.Events.Push(["decoder_init", mode, args.Clone()])
    }

    setimage(image)
    {
        this.Image := image
        StdlibPillowDemoDecoder.Events.Push(["decoder_setimage", image.mode, image.size])
        return stdlib.None
    }

    decode(data)
    {
        bytes := data.Clone()
        StdlibPillowDemoDecoder.Events.Push(["decoder_decode", bytes.Clone()])
        return [-1, 0, bytes]
    }
}

class StdlibPillowShortDecoder
{
    static Call(mode, args*)
    {
        return StdlibPillowShortDecoderInstance()
    }
}

class StdlibPillowShortDecoderInstance
{
    setimage(image)
    {
        return stdlib.None
    }

    decode(data)
    {
        return [0, 0]
    }
}

class StdlibPillowErrorDecoder
{
    static Call(mode, args*)
    {
        return StdlibPillowErrorDecoderInstance()
    }
}

class StdlibPillowErrorDecoderInstance
{
    setimage(image)
    {
        return stdlib.None
    }

    decode(data)
    {
        return [-1, -2]
    }
}

class StdlibPillowDemoEncoder
{
    static Events := []

    static Call(mode, args*)
    {
        return StdlibPillowDemoEncoderInstance(mode, args)
    }
}

class StdlibPillowDemoEncoderInstance
{
    __New(mode, args)
    {
        this.Mode := mode
        this.Args := args.Clone()
        this.Calls := 0
        StdlibPillowDemoEncoder.Events.Push(["encoder_init", mode, args.Clone()])
    }

    setimage(image)
    {
        this.Image := image
        StdlibPillowDemoEncoder.Events.Push(["encoder_setimage", image.mode, image.size])
        return stdlib.None
    }

    encode(bufsize)
    {
        this.Calls += 1
        StdlibPillowDemoEncoder.Events.Push(["encoder_encode", bufsize, this.Calls])
        if this.Calls = 1
            return [2, 0, [65, 66]]
        return [1, 1, [67]]
    }
}

class StdlibPillowErrorEncoder
{
    static Call(mode, args*)
    {
        return StdlibPillowErrorEncoderInstance()
    }
}

class StdlibPillowErrorEncoderInstance
{
    setimage(image)
    {
        return stdlib.None
    }

    encode(bufsize)
    {
        return [0, -3, [98, 97, 100]]
    }
}

class StdlibPillowDemoSave
{
    static Events := []

    static Call(image, fp, filename)
    {
        StdlibPillowDemoSave.Events.Push(["save", image.mode, image.size, filename, StdlibPillowDemoSave.NormalizeInfo(image.encoderinfo)])
        written := fp.write([65, 72, 75, 83, 65, 86, 69, 58, 82, 71, 66])
        StdlibPillowDemoSave.Events.Push(["save_write_return", written])
        return stdlib.None
    }

    static NormalizeInfo(info)
    {
        normalized := Map()
        for key, value in info {
            if key = "append_images" {
                images := []
                for image in value
                    images.Push(["Image", image.mode, image.size])
                normalized[key] := images
            } else {
                normalized[key] := value
            }
        }
        return normalized
    }
}

class StdlibPillowOpenAccept
{
    static Call(prefix)
    {
        StdlibPillowOpenFactory.Events.Push(["accept", prefix.Clone()])
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

class StdlibPillowOpenSkipAccept
{
    static Call(prefix)
    {
        StdlibPillowOpenFactory.Events.Push(["accept_skip", prefix.Clone()])
        return false
    }
}

class StdlibPillowOpenWarnAccept
{
    static Call(prefix)
    {
        StdlibPillowOpenFactory.Events.Push(["accept_warn", prefix.Clone()])
        return "warn-only"
    }
}

class StdlibPillowOpenFactory
{
    static Events := []

    static Call(fp, filename)
    {
        bytes := fp.read(7)
        StdlibPillowOpenFactory.Events.Push(["factory_enter", filename, fp.tell() - bytes.Length, bytes])
        StdlibPillowOpenFactory.Events.Push(["factory_after_read", fp.tell()])
        image := stdlib.pillow.Image.new("L", [2, 1], 9)
        return image
    }
}

class StdlibPillowDemoSaveAll
{
    static Call(image, fp, filename)
    {
        StdlibPillowDemoSave.Events.Push(["save_all", image.mode, image.size, filename, StdlibPillowDemoSave.NormalizeInfo(image.encoderinfo)])
        written := fp.write([65, 72, 75, 83, 65, 86, 69, 65, 76, 76])
        StdlibPillowDemoSave.Events.Push(["save_all_write_return", written])
        return stdlib.None
    }
}

class StdlibPillowMemorySaveFile
{
    __New()
    {
        this.Bytes := []
        this.Closed := false
    }

    write(data)
    {
        bytes := AhkStdlibPillowByteSequence(data)
        for byte in bytes
            this.Bytes.Push(byte)
        return bytes.Length
    }

    tell()
    {
        return this.Bytes.Length
    }

    close()
    {
        this.Closed := true
        return stdlib.None
    }
}

class StdlibPillowMemorySave
{
    static Events := []

    static Call(image, fp, filename)
    {
        StdlibPillowMemorySave.Events.Push(["save", image.mode, image.size, filename, StdlibPillowDemoSave.NormalizeInfo(image.encoderinfo), StdlibPillowDemoSave.NormalizeInfo(image._default_encoderinfo), fp.tell()])
        written := fp.write([65, 72, 75, 83, 65, 86, 69, 58, 77, 69, 77])
        StdlibPillowMemorySave.Events.Push(["save_write_return", written, fp.tell()])
        return stdlib.None
    }
}

class StdlibPillowMemorySaveAll
{
    static Call(image, fp, filename)
    {
        StdlibPillowMemorySave.Events.Push(["save_all", image.mode, image.size, filename, StdlibPillowDemoSave.NormalizeInfo(image.encoderinfo), StdlibPillowDemoSave.NormalizeInfo(image._default_encoderinfo), fp.tell()])
        written := fp.write([65, 72, 75, 83, 65, 86, 69, 65, 76, 76])
        StdlibPillowMemorySave.Events.Push(["save_all_write_return", written, fp.tell()])
        return stdlib.None
    }
}

class StdlibPillowMemoryFailSave
{
    static Call(image, fp, filename)
    {
        StdlibPillowMemorySave.Events.Push(["fail", filename, fp.tell()])
        fp.write([112, 97, 114, 116, 105, 97, 108])
        throw RuntimeError("save boom", -1)
    }
}

class StdlibPillowBufrHandler
{
    __New()
    {
        this.Events := []
    }

    open(image)
    {
        this.Events.Push(["open", image.format, image.format_description, image.mode, image.size, image.fp.tell()])
        return stdlib.None
    }

    save(image, fp, filename)
    {
        this.Events.Push(["save", image.mode, image.size, filename])
        fp.write(StdlibPillowTest.AsciiBytes("saved:" image.mode))
        return stdlib.None
    }
}

class StdlibPillowFailSave
{
    static Call(image, fp, filename)
    {
        fp.write([112, 97, 114, 116, 105, 97, 108])
        throw RuntimeError("save boom", -1)
    }
}

class StdlibPillowPointCounter
{
    __New()
    {
        this.Calls := []
    }

    Call(value)
    {
        this.Calls.Push(value)
        return value
    }
}

class StdlibPillowTransformGetData
{
    getdata()
    {
        return [stdlib.pillow.Image.Transform.EXTENT, [1, 0, 4, 2]]
    }
}

class StdlibPillowTransformHandler
{
    __New()
    {
        this.Calls := []
    }

    transform(size, image, options*)
    {
        resample := options.Length >= 1 && !AhkStdlibIsNone(options[1]) ? options[1] : stdlib.pillow.Image.Resampling.NEAREST
        fill := options.Length >= 2 ? options[2] : 1
        this.Calls.Push([size, image.mode, resample, fill])
        return image.transform(size, stdlib.pillow.Image.Transform.EXTENT, [0, 0, 2, 1])
    }
}

class StdlibPillowIdentityMeshDeformer
{
    __New()
    {
        this.Calls := []
    }

    getmesh(image)
    {
        this.Calls.Push([image.size[1], image.size[2], image.mode = "RGB"])
        return [
            [[0, 0, 4, 2], [0, 0, 0, 2, 4, 2, 4, 0]],
        ]
    }
}

class StdlibPillowShiftMeshDeformer
{
    __New()
    {
        this.Calls := []
    }

    getmesh(image)
    {
        this.Calls.Push([image.size[1], image.size[2]])
        return [
            [[0, 0, 2, 2], [2, 0, 2, 2, 4, 2, 4, 0]],
            [[2, 0, 4, 2], [0, 0, 0, 2, 2, 2, 2, 0]],
        ]
    }
}

class StdlibPillowEmptyMeshDeformer
{
    getmesh(image)
    {
        return []
    }
}

class StdlibPillowBadNoneMeshDeformer
{
    getmesh(image)
    {
        return stdlib.None
    }
}

class StdlibPillowBadItemMeshDeformer
{
    getmesh(image)
    {
        return [
            [[0, 0, 1, 1], [0, 0, 1, 1]],
        ]
    }
}

class StdlibPillowPathLike
{
    __fspath()
    {
        return "custom-font.pil"
    }
}

class StdlibPillowImageQtFakeImage
{
    __New(mode, size, data)
    {
        this.AhkStdlibHandle := -1
        this.mode := mode
        this.size := size
        this.width := size[1]
        this.height := size[2]
        this.AhkStdlibData := data
    }

    tobytes(args*)
    {
        if this.mode = "I;16"
            return [0, 1, 0, 1]
        return []
    }

    getpixel(xy)
    {
        index := xy[2] * this.width + xy[1] + 1
        return this.AhkStdlibData[index]
    }

    convert(mode)
    {
        image := stdlib.pillow.Image.new(mode, this.size, [0, 0, 0])
        if this.mode = "I;16" && mode = "RGB" {
            values := []
            for value in this.AhkStdlibData
                values.Push([Mod(value, 256), Mod(value, 256), Mod(value, 256)])
            image.putdata(values)
        }
        return image
    }
}

class StdlibPillowImageShowFakeImage
{
    __New(mode, size)
    {
        this.AhkStdlibHandle := -1
        this.mode := mode
        this.size := size
        this.width := size[1]
        this.height := size[2]
        this.ConvertCalls := []
    }

    convert(mode)
    {
        this.ConvertCalls.Push(mode)
        return StdlibPillowImageShowFakeImage(mode, this.size)
    }

    close()
    {
        return stdlib.None
    }
}

class StdlibPillowRecordingViewer
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

StdlibPillowFpxScenario(overrides := unset)
{
    scenario := Map()
    scenario["clsid"] := "56616700-C154-11CE-8553-00AA00A1F95B"
    scenario["size"] := [128, 64]
    scenario["maxid"] := 1
    scenario["colors"] := [0x00030000, 0x00030001, 0x00030002]
    scenario["header_stream"] := StdlibPillowTest.FpxHeaderStream()
    scenario["extra_props"] := Map()
    if IsSet(overrides) && IsObject(overrides) {
        for key, value in overrides.OwnProps()
            scenario[key] := value
    }
    return scenario
}

class StdlibPillowFpxFakeOleModule
{
    __New()
    {
        this.MAGIC := StdlibPillowTest.FpxMagicBytes()
        this.Scenario := StdlibPillowFpxScenario()
        this.ClosedCount := 0
    }

    OleFileIO(fp)
    {
        return StdlibPillowFpxFakeOle(this, fp)
    }
}

class StdlibPillowFpxFakeOle
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
        if scenario.Has("mode_blob")
            prop[0x2000002 | (maxid << 16)] := scenario["mode_blob"]
        else
            prop[0x2000002 | (maxid << 16)] := StdlibPillowTest.FpxModeBlob(scenario["colors"])
        for key, value in scenario["extra_props"]
            prop[key] := value
        return prop
    }

    openstream(stream)
    {
        if stream[stream.Length] = "Subimage 0000 Header"
            return stdlib.io.BytesIO(this.Module.Scenario["header_stream"])
        return stdlib.io.BytesIO(StdlibPillowTest.AsciiBytes("pixel-data"))
    }

    close()
    {
        this.Module.ClosedCount += 1
        return stdlib.None
    }
}

class StdlibPillowImageFileProbeDecoder extends AhkStdlibPillowImageFileModule.PyDecoder
{
    init(args)
    {
        return super.init(args)
    }

    decode(buffer)
    {
        return [-1, 0]
    }
}

class StdlibPillowImageFileProbeEncoder extends AhkStdlibPillowImageFileModule.PyEncoder
{
    init(args)
    {
        return super.init(args)
    }

    encode(bufsize)
    {
        return [0, 1, []]
    }
}

class StdlibPillowImageFileProbePushEncoder extends AhkStdlibPillowImageFileModule.PyEncoder
{
    _pushes_fd := true

    init(args)
    {
        return super.init(args)
    }

    encode(bufsize)
    {
        return [3, 1, [97, 98, 99]]
    }
}

class StdlibPillowImageFileProbeStubHandler extends AhkStdlibPillowImageFileModule.StubHandler
{
    load(im)
    {
        return stdlib.pillow.Image.new("RGB", [1, 1], [1, 2, 3])
    }
}

class StdlibPillowImageFileProbeStub extends AhkStdlibPillowImageFileModule.StubImageFile
{
    AhkStdlibTypeName := "ProbeStub"

    _open()
    {
        this.AhkStdlibMode := "RGB"
        this.AhkStdlibWidth := 1
        this.AhkStdlibHeight := 1
        this.AhkStdlibFormat := "PROBE"
        this.tile := []
        return stdlib.None
    }

    _load()
    {
        return StdlibPillowImageFileProbeStubHandler()
    }
}

class StdlibPillowImageFileProbeImageFile extends AhkStdlibPillowImageFileModule.ImageFile
{
    _open()
    {
        this.AhkStdlibMode := "RGB"
        this.AhkStdlibWidth := 1
        this.AhkStdlibHeight := 1
        this.AhkStdlibFormat := "PROBE"
        this.tile := []
        return stdlib.None
    }
}

class StdlibPillowMicFakeOleModule
{
    __New(entries, fail := false)
    {
        this.MAGIC := [208, 207, 17, 224, 161, 177, 26, 225]
        this.Entries := entries
        this.Fail := fail
        this.ClosedCount := 0
    }

    OleFileIO(fp)
    {
        return StdlibPillowMicFakeOle(this, fp)
    }
}

class StdlibPillowMicFakeOle
{
    __New(module, fp)
    {
        if module.Fail
            throw OSError("fake invalid", -1)
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
            if StdlibPillowMicPathEquals(entry[1], filename)
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

StdlibPillowMicPathEquals(left, right)
{
    if left.Length != right.Length
        return false
    loop left.Length {
        if left[A_Index] != right[A_Index]
            return false
    }
    return true
}

class StdlibPillowWmfRecordingHandler
{
    __New()
    {
        this.open_calls := 0
        this.load_calls := 0
        this.save_calls := 0
        this.open_bbox := stdlib.None
        this.load_size := stdlib.None
        this.save_filename := stdlib.None
    }

    open(image)
    {
        this.open_calls += 1
        this.open_bbox := image.info["wmf_bbox"]
        image.AhkStdlibMode := "RGB"
        return stdlib.None
    }

    load(image)
    {
        this.load_calls += 1
        this.load_size := image.size
        loaded := stdlib.pillow.Image.new("RGB", image.size, [1, 2, 3])
        return loaded
    }

    save(image, fp, filename)
    {
        this.save_calls += 1
        this.save_filename := filename
        fp.write(StdlibPillowTest.AsciiBytes("saved:[" image.size[1] ", " image.size[2] "]"))
        return stdlib.None
    }
}

StdlibPillowTestWmfBytes(x0 := 0, y0 := 0, x1 := 1440, y1 := 720, inch := 1440, standard := true)
{
    bytes := []
    loop 44
        bytes.Push(0)
    bytes[1] := 0xD7
    bytes[2] := 0xCD
    bytes[3] := 0xC6
    bytes[4] := 0x9A
    StdlibPillowTestPutLe16(bytes, 7, x0)
    StdlibPillowTestPutLe16(bytes, 9, y0)
    StdlibPillowTestPutLe16(bytes, 11, x1)
    StdlibPillowTestPutLe16(bytes, 13, y1)
    StdlibPillowTestPutLe16(bytes, 15, inch)
    if standard {
        bytes[23] := 1
        bytes[24] := 0
        bytes[25] := 9
        bytes[26] := 0
    }
    return bytes
}

StdlibPillowTestEmfBytes(x0 := 0, y0 := 0, x1 := 96, y1 := 48, frame := unset)
{
    if !IsSet(frame)
        frame := [0, 0, 2540, 1270]
    bytes := []
    loop 44
        bytes.Push(0)
    bytes[1] := 1
    StdlibPillowTestPutLe32(bytes, 9, x0)
    StdlibPillowTestPutLe32(bytes, 13, y0)
    StdlibPillowTestPutLe32(bytes, 17, x1)
    StdlibPillowTestPutLe32(bytes, 21, y1)
    loop 4
        StdlibPillowTestPutLe32(bytes, 25 + (A_Index - 1) * 4, frame[A_Index])
    bytes[41] := 32
    bytes[42] := Ord("E")
    bytes[43] := Ord("M")
    bytes[44] := Ord("F")
    return bytes
}

StdlibPillowTestXbmBytes(hotspot := false)
{
    if hotspot
        return StdlibPillowTest.AsciiBytes(" `t#define demo_width 5`r`n#define demo_height 2`r`n#define demo_x_hot 1`r`n#define demo_y_hot 0`r`nstatic unsigned char demo_bits[] = {`r`n0x15,0x0a};`r`n")
    return StdlibPillowTest.AsciiBytes("#define im_width 5`n#define im_height 2`nstatic char im_bits[] = {`n0x15, 0x0a};`n")
}

StdlibPillowTestXpmPBytes()
{
    return StdlibPillowTest.AsciiBytes(
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

StdlibPillowTestXpmRgbBytes()
{
    charCodes := StdlibPillowTestXpmColorKeyCodes()
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

    bytes := StdlibPillowTest.AsciiBytes("/* XPM */`n`"2 1 257 2`",`n")
    for index, key in keys {
        zeroIndex := index - 1
        r := zeroIndex & 0xFF
        g := (255 - zeroIndex) & 0xFF
        b := (zeroIndex * 3) & 0xFF
        line := "`"" key " c #" Format("{:02x}{:02x}{:02x}", r, g, b) "`",`n"
        for byte in StdlibPillowTest.AsciiBytes(line)
            bytes.Push(byte)
    }
    for byte in StdlibPillowTest.AsciiBytes("`"" keys[1] keys[257] "`"`n};`n")
        bytes.Push(byte)
    return bytes
}

StdlibPillowTestXpmColorKeyCodes()
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

StdlibPillowTestPutLe16(bytes, offset, value)
{
    bytes[offset] := value & 0xFF
    bytes[offset + 1] := (value >> 8) & 0xFF
    return stdlib.None
}

StdlibPillowTestPutLe32(bytes, offset, value)
{
    bytes[offset] := value & 0xFF
    bytes[offset + 1] := (value >> 8) & 0xFF
    bytes[offset + 2] := (value >> 16) & 0xFF
    bytes[offset + 3] := (value >> 24) & 0xFF
    return stdlib.None
}

StdlibPillowTestXVThumbBytes(width := 3, height := 2, pixels := unset, comments := unset)
{
    if !IsSet(pixels)
        pixels := [0, 1, 2, 3, 4, 5]
    if !IsSet(comments)
        comments := ["#IMGINFO:demo", "#THUMBONLY"]

    bytes := StdlibPillowTest.AsciiBytes("P7 332`n")
    for comment in comments {
        for byte in StdlibPillowTest.AsciiBytes(comment "`n")
            bytes.Push(byte)
    }
    for byte in StdlibPillowTest.AsciiBytes(width " " height "`n")
        bytes.Push(byte)
    for byte in pixels
        bytes.Push(byte)
    return bytes
}

StdlibPillowTestThrow(err)
{
    throw err
}

StdlibPillowTestReadExifKey(exif, key)
{
    return exif[key]
}

AhkTest.Collect(StdlibPillowTest)

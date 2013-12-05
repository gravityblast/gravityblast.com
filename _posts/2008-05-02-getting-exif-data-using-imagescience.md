---
layout: post
title: Getting Exif data using ImageScience
tags:
- Development
- Exif
- Ruby
status: publish
type: post
published: true
meta:
  _edit_last: '1'
---
In my current <a href="http://www.rubyonrails.org/" title="Ruby on Rails">rails</a> project I need to upload photos and save some exif data taken from them. I use <a href="http://github.com/technoweenie/attachment_fu/">attachment_fu</a> as uploading system that let me choose which image processor to use. Using rmagick and mini_magick I can extract exif data with the following code:


    # rmagick
    image = Magick::ImageList.new(filename).first
    puts image['EXIF:Model'] # The camera model used to take the picture
    
    # mini_magick
    image = MiniMagick::Image.from_file(filename)
    puts image["EXIF:Model"]


The problem is that I can't do the same thing with <a href="http://seattlerb.rubyforge.org/ImageScience.html" title="ImageScience">image_science</a>, because it has no methods that return exif data, so I want to add a method to the ImageScience class to do that.
Looking the <a href="http://freeimage.sourceforge.net/">FreeImage</a> <a href="http://freeimage.sourceforge.net/fip/index.html">documentation</a> I found some helpful functions, FreeImage_GetMetadata and FreeImage_TagToString. With these 2 functions I'm able to get an exif tag and convert it to a readable string. Each one of the available tags belongs to one of the following meta models:
      
<pre lang="c">FI_ENUM(FREE_IMAGE_MDMODEL) {
  FIMD_NODATA         = -1,
  FIMD_COMMENTS       = 0,	// single comment or keywords
  FIMD_EXIF_MAIN      = 1,	// Exif-TIFF metadata
  FIMD_EXIF_EXIF      = 2,	// Exif-specific metadata
  FIMD_EXIF_GPS       = 3,	// Exif GPS metadata
  FIMD_EXIF_MAKERNOTE = 4,	// Exif maker note metadata
  FIMD_EXIF_INTEROP   = 5,	// Exif interoperability metadata
  FIMD_IPTC           = 6,	// IPTC/NAA metadata
  FIMD_XMP            = 7,	// Abobe XMP metadata
  FIMD_GEOTIFF        = 8,	// GeoTIFF metadata
  FIMD_ANIMATION      = 9,	// Animation metadata
  FIMD_CUSTOM         = 10	// Used to attach other metadata types to a dib
};</pre>

Ok, now I can extract the model of the camera:

<pre lang="c">FreeImage_GetMetadata(FIMD_EXIF_MAIN, bitmap, "Model", &tag);
printf(FreeImage_TagToString(FIMD_EXIF_MAIN, tag, NULL));</pre>

As you can see, I need to pass the model of the "Model" tag. But if I don't know which model to use, I can loop through all of them until the returned value of the <strong>FreeImage_GetMetadata</strong> function is not NULL:

<pre lang="c">for(model = 0; model < 11; model++) {
  if(FreeImage_GetMetadata(model, bitmap, tagName, &tag))
    return rb_str_new2(FreeImage_TagToString(model, tag, NULL));
}</pre>

Finally I can write a ruby module that extends ImageScience and adds the ability to get an exif tag:

<pre lang="ruby">module ImageScienceExifData
  
  def [](key)
    if key =~ /^EXIF:(\w+)?/    
      get_exif($1)
    end
  end
  
  inline do |builder|
    if test ?d, "/opt/local" then
      builder.add_compile_flags "-I/opt/local/include"
      builder.add_link_flags "-L/opt/local/lib"
    end
    builder.add_link_flags "-lfreeimage"
    builder.add_link_flags "-lstdc++" # only needed on PPC for some reason. lame
    builder.include '"FreeImage.h"'

    builder.prefix <<-"END"
      #define GET_BITMAP(name) FIBITMAP *(name); Data_Get_Struct(self, FIBITMAP, (name)); if (!(name)) rb_raise(rb_eTypeError, "Bitmap has already been freed")
    END

    builder.c <<-"END"
      VALUE get_exif(char *tagName) {
        GET_BITMAP(bitmap);
        FITAG *tag = NULL;
        const char *value;
        int model;

        for(model = 0; model < 11; model++) {
          if(FreeImage_GetMetadata(model, bitmap, tagName, &tag))
            return rb_str_new2(FreeImage_TagToString(model, tag, NULL));
        }

        return Qnil;
      }
    END
    
  end
end
ImageScience.send(:include, ImageScienceExifData)

ImageScience.with_image(filename) do |img|
  puts img["EXIF:Model"]
end
</pre>

The output with the picture I used is the following :

<pre>NIKON
COOLPIX S3
2006:12:10 12:09:17</pre>

It doesn't work with all the exif names but for now it's ok for my needs. The next step is to add the code above in my rails application and use it with attachment_fu. I'll write another post about that soon.

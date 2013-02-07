# Asset Image Quality

The Asset Image Quality plugin for Movable Type gives you the opportunity to
control the file size of automatically generated JPEG image assets.

When resized image assets are used, you may notice that the file size is quite
large -- much larger than you'd expect it to be. This is because a very
high-quality low-compression setting is used to generate a JPEG. The result is
an image that looks great, but has an unnecessarily large file size.

This plugin provides the opportunity to control the compression applied to
generated image assets, therefore creating something that still looks good but
has an appropriate file size.


# Prerequisites

* Movable Type 4.x or 5.x
* ImageMagick must be used to generate images

# Installation

To install this plugin follow the instructions found here:

http://tinyurl.com/easy-plugin-install


# Configuration

Image quality is controlled at the system level. Select System Overview >
Plugins and find the Asset Image Quality plugin. There you can define how the
plugin works.

The default JPEG compression level (as set by ImageMagick and used by Movable
Type) is 92 (on a scale of 1-100, where a bigger number is more quality and
less compression). There are three options to configure for this plugin:

* Large JPEG: specify a compression level for large images. Large images need
  less compression (more quality) to look good. A value of 80 will often halve
  the file size while still retaining excellent image quality.
* Small JPEG: specify a compression level for small images. Thumbnails can
  often be compressed much more because they are so small and contain
  relatively little detail compared to their larger counterpart. You can
  probably use a value of roughly 2/3 what is used for the "large" selection
  and still create an acceptable image. For example, if you used "80" for the
  Large option, you can probably use roughly "50" for small.
* Large/Small Threshold: Specify an image dimension as the size threshold for
  determining whether the large or small compression value is applied.

Save the settings and you're done! Whenever a new image is generated (by
inserting a thumbnail, or creating a new image with the AssetThumbnailURL tag,
for example), the plugin will be invoked and create the image at the specified
quality level.

Note that this does *not* affect older images, only new ones.


# License

This plugin is licensed under the same terms as Perl itself.

#Copyright

Copyright 2010, Endevver LLC. All rights reserved.

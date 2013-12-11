package AssetImageQuality::Plugin;

use strict;
use warnings;

# The cms_post_save.asset callback lets us access the image and work on it.
sub quality {
    my ($cb, $app, $asset, $original) = @_;
    my $plugin = $cb->plugin;

    my $file_path = $asset->file_path;
    return 1 unless $file_path;

    # Determine the file type of the image. Give up if it's not a jpeg,
    # because that is the only type we can recompress, and the only things
    # that we give the user an opportunity to control.
    return 1 unless $asset->file_ext =~ /jpe?g/i;

    # This plugin requires ImageMagick. Look for IM before proceeding,
    # and give up if it isn't found.
    eval { require Image::Magick; };
    if ($@) {
        MT->log({
            level   => MT->model('log')->ERROR(),
            message => 'The Asset Image Quality plugin could not find'
                . ' ImageMagick. ' . $@,
        });
        return 1;
    }

    my $image = Image::Magick->new;
    $image->Read(filename => $file_path);

    unless ($image) {
        MT->log({
            level   => MT->model('log')->ERROR(),
            blog_id => $asset->blog_id,
            message => 'The Asset Image Quality plugin could not read the'
                . ' specified file at ' . $file_path . '.',
        });
        return 1;
    }

    # Load the user-defined size for this image type.
    my $size = $plugin->get_config_value('compression_quality_jpeg_size_threshold');

    # Use the image size (dimensions) to determine if this is a "large" or
    # "small" image. Compare both the asset width and height to decide if
    # its large or small. Then, apply the correct user-supplied compression
    # to the image.
    my $quality;
    if ($asset->image_width > $size || $asset->image_height > $size) {
        $quality = $plugin->get_config_value('compression_quality_jpeg_large')
    }
    else {
        $quality = $plugin->get_config_value('compression_quality_jpeg_small')
    }

    # Give up if the saved image's quality is already less than or equal to the
    # the quality the Asset Image Quality plugin wants to set.
    my $current_quality = $image->Get('quality');
    return 1 if $current_quality <= $quality;

    # Set the quality and write the file.
    $image->Set(quality => $quality);
    $image->Write(filename => $file_path);

    1;
}

1;

__END__

package AssetImageQuality::Plugin;

sub quality {
    my ($cb, $app, $obj, $original) = @_;
    my $plugin = $cb->plugin;

    my $id = $obj->column_values->{'id'};
    return unless $id;
    my $asset = MT->model('asset')->load( $id );
    
    # A file path should always be returned (right?) but just give up if 
    # there isn't one.
    my $file_path = $asset->file_path;
    return unless $file_path;
    
    # Determine the file type of the image. Give up if it's not a jpeg, 
    # because that is the only type we can recompress, and the only things 
    # that we give the user an opportunity to control.
    my %Types = (jpg => 'jpeg', jpeg => 'jpeg', gif => 'gif', 'png' => 'png');
    my $type = $Types{ lc $asset->file_ext };
    return unless $type =~ /(jpeg)/;
    
    # This plugin requires ImageMagick. Look for IM before proceeding, 
    # and give up if it isn't found.
    eval { require Image::Magick; };
    if ($@) {
        MT->log({
            level   => MT->model('log')->ERROR(),
            message => 'The Asset Image Quality plugin could not find'
                . ' ImageMagick. ' . $@,
        });
        return;
    }
    
    my $image = Image::Magick->new;
    $image->Read(filename => $file_path);

    unless ($image) {
        MT->log({
            level   => MT->model('log')->ERROR(),
            message => 'The Asset Image Quality plugin could not read the'
                . ' specified file.',
        });
        return;
    }
    
    # Load the user-defined size for this image type.
    my $size = $plugin->get_config_value('compression_quality_'.$type.'_size_threshold');

    # Use the image size (dimensions) to determine if this is a "large" or 
    # "small" image. Compare both the asset width and height to decide if
    # its large or small. Then, apply the correct user-supplied compression
    # to the image.
    my $quality;
    if ($asset->image_width > $size || $asset->image_height > $size) {
        $quality = $plugin->get_config_value('compression_quality_'.$type.'_large')
    }
    else {
        $quality = $plugin->get_config_value('compression_quality_'.$type.'_small')
    }

    # Set the quality and write the file.
    $image->Set(quality => $quality);
    $image->Write(filename => $file_path);
}

1;

__END__

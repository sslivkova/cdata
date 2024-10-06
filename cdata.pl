use strict;
use warnings;
use Image::PNG::Libpng qw(read_png_file write_png_file);
use MIME::Base64;
use JSON::PP;
use Data::Dumper;

sub read_def_from_png ($) {
    my ($src) = @_;
    my $card = read_png_file($src) or die $!;
    my $chunks = $card->get_text();
    my ($chunk) = (grep { $_->{key} eq 'chara'} @$chunks);
    unless ($chunk) { die "Cannot parse file $src"; }
    decode_json decode_base64($chunk->{text});
}

sub read_from_defs ($$) {
    my ($defs, $field) = @_;

    if ($field) {
        my $value = $defs->{data}->{$field};
        print $value if $value;
        print "No data for field '$field'\n" unless $value;
    } else {
        print Dumper \$defs;
    }

}

sub insert_field ($$$) {
    my ($defs, $field, $value) = @_;
    die "Cannot insert '$field': Field already exists" if exists($defs->{data}->{$field});
    $defs->{data}->{$field} = $value;
    print "Field '$field' inserted with value '$value'\n";
    $defs;
}

sub update_field ($$$) {
    my ($defs, $field, $value) = @_;
    die "Cannot update '$field': Field does not exist" unless exists($defs->{data}->{$field});
    $defs->{data}->{$field} = $value;
    print "Field '$field' updated with value '$value'\n";
    $defs;

}

sub delete_field ($$) {
    my ($defs, $field) = @_;
    die "Cannot delete '$field': Field does not exist" unless exists($defs->{data}->{$field});
    delete ($defs->{data}->{$field});
    print "Field '$field' deleted\n";
    $defs;
}

sub clear ($$) {
    my ($defs, $field) = @_;
    die "Cannot clear '$field': Field does not exist" unless exists($defs->{data}->{$field});

    if (ref $defs->{data}->{$field} eq 'ARRAY') {
        $defs->{data}->{$field} = [];
    } else {
        $defs->{data}->{$field} = '';
    }
    
    print "Field '$field' cleared\n";
    $defs;
}

sub append($$$) {
    my ($defs, $field, $value) = @_;
    die "Cannot append to '$field': Field does not exist or is not an array" unless exists($defs->{data}->{$field}) && ref $defs->{data}->{$field} eq 'ARRAY';
    
    my @values = grep { length } split /,/, $value; 

    push @{$defs->{data}->{$field}}, @values;
    print "Appended value(s) '$value' to array '$field'\n";
    $defs;
}

sub write_card($$$) {
    my ($src, $defs, $dest) = @_;
    my $card = read_png_file($src)->copy_png() or die $!;
    $defs = encode_base64 encode_json($defs);
    $card->set_text([{
        key => 'chara',
        text => $defs
    }]);

    $card -> write_png_file($dest) or die "$!"; 
}


my $src = shift @ARGV;
die "Source file not specified" unless $src;
die "Source '$src' does not exist or could not be read" unless -e -r $src;

my $defs = read_def_from_png($src);

my $op = shift @ARGV;
die "Operation not specified" unless $op;

my $field = shift @ARGV;
die "'$field' is a hash. Hash ops aren't supported yet" if $field && ref $defs->{data}->{$field} eq 'HASH'; 

if ($op eq 'read') { 
    read_from_defs($defs, $field); 

} elsif ($op eq 'delete') {
    my $dest = shift @ARGV;
    $defs = delete_field($defs, $field);
    write_card($src, $defs, $dest);

} elsif ($op eq 'insert') {
    my $value = shift @ARGV;
    my $dest = shift @ARGV;
    die "Destination file not specified" unless $dest;
    die "New value not specified" unless $value;
    $defs = insert_field($defs, $field, $value);
    write_card($src, $defs, $dest);

} elsif ($op eq 'update') {
    my $value = shift @ARGV;
    my $dest = shift @ARGV;
    die "Destination file not specified" unless $dest;
    die "New value not specified" unless $value;
    $defs = update_field($defs, $field, $value);
    write_card($src, $defs, $dest);

} elsif ($op eq 'clear') {
    my $dest = shift @ARGV;
    die "Destination file not specified" unless $dest;
    $defs = clear($defs, $field);
    write_card($src, $defs, $dest);

} elsif ($op eq 'append') {
    my $value = shift @ARGV;
    my $dest = shift @ARGV;
    die "Destination file not specified" unless $dest;
    $defs = append($defs, $field, $value);
    write_card($src, $defs, $dest);
} else {
    die "Unknown operation '$op'";
}


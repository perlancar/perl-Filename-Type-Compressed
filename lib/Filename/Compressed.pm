package Filename::Compressed;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(check_compressed_filename);
#list_compressor_suffixes

our %SUFFIXES = (
    '.Z'   => {name=>'NCompress'},
    '.gz'  => {name=>'Gzip'},
    '.bz2' => {name=>'Bzip2'},
    '.xz'  => {name=>'XZ'},
    '.lz'  => {name=>'LZ'},
    '.lzma'=> {name=>'LZMA'},
    '.zst' => {name=>'Zstandard'},
    '.br'  => {name=>'Brotli'},
);

our %COMPRESSORS = (
    NCompress => {
        # all programs mentioned here must accept filename(s) as arguments.
        # preferably CLI.
        compressor_programs => [
            {name => 'compress', opts => ''},
        ],
        decompressor_programs => [
            {name => 'uncompress', opts => ''},
        ],
    },
    Gzip => {
        compressor_programs => [
            {name => 'gzip', opts => ''},
        ],
        decompressor_programs => [
            {name => 'gzip', opts => '-d'},
            {name => 'gunzip', opts => ''},
        ],
    },
    Bzip2 => {
        compressor_programs => [
            {name => 'bzip2', opts => ''},
        ],
        decompressor_programs => [
            {name => 'bzip2', opts => '-d'},
            {name => 'bunzip2', opts => ''},
        ],
    },
    XZ => {
        compressor_programs => [
            {name => 'xz', opts => ''},
        ],
        decompressor_programs => [
            {name => 'xz', opts => '-d'},
            {name => 'unxz', opts => ''},
        ],
    },
    Zstandard => {
        compressor_programs => [
            {name => 'zstd', opts => ''},
        ],
        decompressor_programs => [
            {name => 'zstd', opts => '-d'},
            {name => 'unzstd', opts => ''},
        ],
    },
    Brotli => {
        compressor_programs => [
        ],
        decompressor_programs => [
        ],
    },
    LZ => {
        compressor_programs => [
        ],
        decompressor_programs => [
        ],
    },
    LZMA => {
        compressor_programs => [
            {name => 'lzma', opts => ''},
        ],
        decompressor_programs => [
            {name => 'lzma', opts => '-d'},
            {name => 'unlzma', opts => ''},
        ],
    },
);

our %SPEC;

$SPEC{check_compressed_filename} = {
    v => 1.1,
    summary => 'Check whether filename indicates being compressed',
    description => <<'_',


_
    args => {
        filename => {
            schema => 'str*',
            req => 1,
            pos => 0,
        },
        # recurse?
        ci => {
            summary => 'Whether to match case-insensitively',
            schema  => 'bool',
            default => 1,
        },
    },
    result_naked => 1,
    result => {
        schema => ['any*', of=>['bool*', 'hash*']],
        description => <<'_',

Return false if no compressor suffixes detected. Otherwise return a hash of
information, which contains these keys: `compressor_name`, `compressor_suffix`,
`uncompressed_filename`.

_
    },
};
sub check_compressed_filename {
    my %args = @_;

    my $filename = $args{filename};
    $filename =~ /(\.\w+)\z/ or return 0;
    my $ci = $args{ci} // 1;

    my $suffix = $1;

    my $spec;
    if ($ci) {
        my $suffix_lc = lc($suffix);
        for (keys %SUFFIXES) {
            if (lc($_) eq $suffix_lc) {
                $spec = $SUFFIXES{$_};
                last;
            }
        }
    } else {
        $spec = $SUFFIXES{$suffix};
    }
    return 0 unless $spec;

    (my $ufilename = $filename) =~ s/\.\w+\z//;

    return {
        compressor_name       => $spec->{name},
        compressor_suffix     => $suffix,
        uncompressed_filename => $ufilename,
    };
}

1;
# ABSTRACT:

=head1 SYNOPSIS

 use Filename::Compressed qw(check_compressed_filename);
 my $res = check_compressed_filename(filename => "foo.txt.gz");
 if ($res) {
     printf "File is compressed with %s, uncompressed name: %s\n",
         $res->{compressor_name},
         $res->{uncompressed_filename};
 } else {
     print "File is not compressed\n";
 }

=head1 DESCRIPTION


=head1 SEE ALSO

L<Filename::Archive>

=cut

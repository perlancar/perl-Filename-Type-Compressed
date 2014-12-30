#!perl

use 5.010;
use strict;
use warnings;

use Filename::Compressed qw(check_compressed_filename);
use Test::More 0.98;

is_deeply(check_compressed_filename(filename=>"foo.txt"), 0);
is_deeply(check_compressed_filename(filename=>"foo.txt.gz"),
          {
              compressor_name=>'Gzip',
              compressor_suffix=>'.gz',
              uncompressed_filename=>'foo.txt',
          });
is_deeply(check_compressed_filename(filename=>"foo.Z"),
          {
              compressor_name=>'NCompress',
              compressor_suffix=>'.Z',
              uncompressed_filename=>'foo',
          });
is_deeply(check_compressed_filename(filename=>"foo.txt.2.bz2"),
          {
              compressor_name=>'Bzip2',
              compressor_suffix=>'.bz2',
              uncompressed_filename=>'foo.txt.2',
          });
is_deeply(check_compressed_filename(filename=>"foo.xz"),
          {
              compressor_name=>'XZ',
              compressor_suffix=>'.xz',
              uncompressed_filename=>'foo',
          });

DONE_TESTING:
done_testing;

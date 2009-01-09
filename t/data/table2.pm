package data::table2;

use strict;
use warnings;

use Cwd;
use Data::Dumper;

#warn __PACKAGE__ . ' cwd - ' . getcwd() ;

sub new {
  my $this = shift;
  bless {}, ref($this) || $this;
}

sub load_data {

  my @file = qw(4dig 3dig);

  my %data;

  for my $file (@file) {
    my $f = "t/data/$file.dat";
    my @data;
    open F, $f or die "couldnt open $f: $!";
    while (<F>) {
      push @data, [ split ',', $_ ] ;
    }
    $data{$file} = \@data;
  }
  #warn Dumper \%data;
  \%data;

}

1;


# This might look like shell script, but it's actually -*- perl -*-
use strict;use warnings;
use lib qw(t/ t/m/);

use File::Slurp;
use Test::More qw(no_plan);

use TestUtils;
use HTML::TreeBuilder;
use HTML::Element::Library;

sub tage {

  my $root = "t/html/fillinform/fillinform";

  my $tree = HTML::TreeBuilder->new_from_file("$root.initial")->guts;

  my %data = (state => 'catatonic');

  my $new_tree = HTML::TreeBuilder->new_from_content( $tree->fillinform(\%data) ) ;

  my $generated_html = ptree($new_tree, "$root.gen");

  is ($generated_html, File::Slurp::read_file("$root.exp"), "HTML for fillinform");
}


tage();


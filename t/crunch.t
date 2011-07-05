# This might look like shell script, but it's actually -*- perl -*-
use strict;use warnings;
use lib qw(t/ t/m/);

use File::Slurp;
use Test::More;

use TestUtils;
use HTML::TreeBuilder;
use HTML::Element::Library;

sub tage {

  my $root = "t/html/crunch/crunch";

  my $tree = HTML::TreeBuilder->new_from_file("$root.initial")->guts;


  $tree->crunch(look_down => [ class => 'imageElement' ], leave => 1);

  my $generated_html = ptree($tree, "$root.gen");

  is ($generated_html, File::Slurp::read_file("$root.exp"), "HTML for crunch");
}


tage();

done_testing;

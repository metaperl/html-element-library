# This might look like shell script, but it's actually -*- perl -*-
use strict;use warnings;
use lib qw(t/ t/m/);

use File::Slurp;
use Test::More;

use TestUtils;
use HTML::TreeBuilder;
use HTML::Element::Library;
use Test::XML;

sub tage {

  my $root = "t/html/crunch/crunch";

  my $tree = HTML::TreeBuilder->new_from_file("$root.initial")->guts;


  $tree->crunch(look_down => [ class => 'imageElement' ], leave => 1);

  my $generated_html = strip_ws ( ptree($tree, "$root.gen") );
  # must put read_file() in scalar context so that a string instead of first line is returned.
  my $expected_html = strip_ws(scalar File::Slurp::read_file("$root.exp"));

  #warn "g:$generated_html";
  #warn "e:$expected_html";

  is ($generated_html, $expected_html, "HTML for crunch");
}


tage();

done_testing;

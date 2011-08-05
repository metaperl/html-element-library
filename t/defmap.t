# This might look like shell script, but it's actually -*- perl -*-
use strict;use warnings;
use lib qw(t/ t/m/);

use File::Slurp;
use Test::More qw(no_plan);
use Test::XML;

use TestUtils;
use HTML::TreeBuilder;
use HTML::Element::Library;

sub tage {

  my $root = "t/html/defmap/defmap";

  my $tree = HTML::TreeBuilder->new_from_file("$root.initial")->guts;

  #warn "TREE: $tree" . $tree->as_HTML;

  my %data = (pause => 'arsenal rules');

  $tree->defmap(smap => \%data, 1);

  my $g = ptree($tree, "$root.gen");
  my $e = File::Slurp::read_file("$root.exp");
  warn "generated:$g:\nexpected:$e:";

  is_xml ($g, $e, "HTML for defmap");
}


tage();


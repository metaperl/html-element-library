# This might look like shell script, but it's actually -*- perl -*-
use strict;
use lib qw(t/ t/m/);

use File::Slurp;
use Test::More qw(no_plan);

use TestUtils;
use HTML::TreeBuilder;
use HTML::Element::Library;

sub replace_age { 
  my $branch = shift;
  my $age = shift;
  $branch->look_down(id => 'age')->replace_content($age);
}


sub tage {
  my $age = shift;

  my $tree = HTML::TreeBuilder->new_from_file('t/html/highlander2.html');

  my $saved_child = $tree->passover('under18');

  my $root = "t/html/highlander2-passover";

  my $generated_html = ptree($tree, "$root.gen");

  is ($generated_html, File::Slurp::read_file("$root.exp"), "HTML for $age");
}


tage('666');


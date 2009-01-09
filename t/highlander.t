# This might look like shell script, but it's actually -*- perl -*-
use strict;
use lib qw(t/ t/m/);

use File::Slurp;
use Test::More qw(no_plan);

use TestUtils;
use HTML::TreeBuilder;
use HTML::Element::Library;


sub tage {
  my $age = shift;
  my $tree = HTML::TreeBuilder->new_from_file('t/html/highlander.html');


  $tree->highlander
    (age_dialog =>
     [
      under10 => sub { $_[0] < 10} , 
      under18 => sub { $_[0] < 18} ,
      welcome => sub { 1 }
     ],
     $age
    );

  my $root = "t/html/highlander-$age";

  my $generated_html = ptree($tree, "$root.gen");

  is ($generated_html, File::Slurp::read_file("$root.exp"), "HTML for $age");
}


tage($_) for qw(5 15 50);

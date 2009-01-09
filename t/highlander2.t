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
  my $if_then = $tree->look_down(id => 'age_dialog');

  $if_then->highlander2(
    cond => [
      under10 => [
	sub { $_[0] < 10} , 
	\&replace_age
       ],
      under18 => [
	sub { $_[0] < 18} ,
	\&replace_age
       ],
      welcome => [
	sub { 1 },
	\&replace_age
       ]
     ],
    cond_arg => [ $age ]
		       );

  my $root = "t/html/highlander2-$age";

  my $generated_html = ptree($tree, "$root.gen");

  is ($generated_html, File::Slurp::read_file("$root.exp"), "HTML for $age");
}


tage($_) for qw(5 15 27);

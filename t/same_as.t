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

  my $root = "t/html/same_as/same_as";

  my $tree = HTML::TreeBuilder->new_from_file("$root.initial");

  warn "TREE: $tree" . $tree->as_HTML;

  my %data = (people_id => 888, phone => '444-4444', email => 'dont-you-dare-render@xml.com');

  $tree->data_map(href => \%data, with_attr => 'sid', excluding => ['email']);

  my $generated_html = ptree($tree, "$root.gen");

  is ($generated_html, File::Slurp::read_file("$root.exp"), "HTML for same_as");
}


tage();


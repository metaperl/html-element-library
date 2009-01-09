# This might look like shell script, but it's actually -*- perl -*-
use strict;
use lib qw(t/ t/m/);


use File::Slurp;
use Test::More qw(no_plan);

use TestUtils;
use HTML::TreeBuilder;
use HTML::Element::Library;

my $root = 't/html/iter';

my $tree = HTML::TreeBuilder->new_from_file("$root.html");

my $li = $tree->look_down(class => 'store_items');

my @items = qw(bread butter vodka);

$tree->iter($li, @items);

  my $generated_html = ptree($tree, "$root.gen");

  is ($generated_html, File::Slurp::read_file("$root.exp"), 
      "HTML for generated li");

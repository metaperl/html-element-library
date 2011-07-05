# This might look like shell script, but it's actually -*- perl -*-
# Test the 3 possible look_down calls to table2()
#   a = default
#   b = supplied array ref
#   c = supplied code ref

use strict;
use lib qw(t/ t/m/);


use File::Slurp;
use Test::More;

use TestUtils;
use HTML::TreeBuilder;
use HTML::Element::Library;

use data::table2;


my $o    = data::table2->new;

# a - default table_ld

my $root = 't/html/table2-table_ld-default';
my $tree = HTML::TreeBuilder->new_from_file("$root.html");


my $table = HTML::Element::Library::ref_or_ld(
  $tree,
  ['_tag' => 'table']
 );

my $generated_html = ptree($table, "$root.gen");

is ($generated_html, File::Slurp::read_file("$root.exp"), $root);

# b - arrayref table_ld

$root = 't/html/table2-table_ld-arrayref';
$tree = HTML::TreeBuilder->new_from_file("$root.html");


$table = HTML::Element::Library::ref_or_ld(
  $tree,
  [frame => 'hsides', rules => 'groups']
 );

$generated_html = ptree($table, "$root.gen");

is ($generated_html, File::Slurp::read_file("$root.exp"), $root);

# c - coderef table_ld

$root = 't/html/table2-table_ld-coderef';
$tree = HTML::TreeBuilder->new_from_file("$root.html");


$table = HTML::Element::Library::ref_or_ld(
  $tree,
  sub {
    my ($t) = @_;
    my $caption = $t->look_down('_tag' => 'caption');
    $caption->parent;
  }
 );

$generated_html = ptree($table, "$root.gen");

is ($generated_html, File::Slurp::read_file("$root.exp"), $root);


done_testing;

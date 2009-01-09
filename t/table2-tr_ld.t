# This might look like shell script, but it's actually -*- perl -*-
# Test the 3 possible look_down calls to table2()
#   a = default
#   b = supplied array ref
#   c = supplied code ref

use strict;
use lib qw(t/ t/m/);


use File::Slurp;
use Test::More qw(no_plan);

use TestUtils;
use HTML::TreeBuilder;
use HTML::Element::Library;
use Scalar::Listify;

use data::table2;


my $o    = data::table2->new;

# a - default table_ld

my $root = 't/html/table2-tr_ld-default';
my $tree = HTML::TreeBuilder->new_from_file("$root.html");


my @tr = HTML::Element::Library::ref_or_ld(
  $tree,
  ['_tag' => 'tr']
 );

is (scalar @tr, 16, 'default ld_tr');

# b - arrayref tr_ld

$root = 't/html/table2-tr_ld-arrayref';
$tree = HTML::TreeBuilder->new_from_file("$root.html");


my $tr = HTML::Element::Library::ref_or_ld(
  $tree,
  [class => 'findMe']
 );

my $generated_html = ptree($tr, "$root.gen");

is ($generated_html, File::Slurp::read_file("$root.exp"), $root);

# c - coderef tr_ld
# removes windows listings before returning @tr

$root = 't/html/table2-tr_ld-coderef';
$tree = HTML::TreeBuilder->new_from_file("$root.html");


@tr = HTML::Element::Library::ref_or_ld(
  $tree,
  sub {
    my ($t) = @_;
    my @tr = $t->look_down('_tag' => 'tr');
    my @keep;
    for my $tr (@tr) {

      my @td = $tr->look_down ('_tag' => 'td') ;
      my $detached;
      for my $td (@td) {
	if (grep { $_ =~ /Windows/ } $td->content_list) {
	  $tr->detach();
	  ++$detached;
	  last;
	}
      }
      push @keep, $tr unless $detached;
    }
    @keep;
  }
 );

#warn $_->as_HTML, $/ for @tr;

$generated_html = ptree($tree, "$root.gen");

is ($generated_html, File::Slurp::read_file("$root.exp"), $root);


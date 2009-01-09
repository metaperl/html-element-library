# This might look like shell script, but it's actually -*- perl -*-
use strict;
use lib qw(t/ t/m/);


use File::Slurp;
use Test::More qw(no_plan);

use TestUtils;

use Data::Dumper;
use HTML::TreeBuilder;
use HTML::Element::Library;

use data::table2;

my $root = 't/html/table2';
my $o    = data::table2->new;
my $d    = data::table2->load_data;
my $tree = HTML::TreeBuilder->new_from_file("$root.html");

#warn 'D:', Dumper $d;

for my $dataset (keys %$d) {
  my %tbody = ('4dig' => 0, '3dig' => 1);
  $tree->table2 (
#    debug => 1,
    table_data => $d->{$dataset},
    tr_base_id => $dataset,
    tr_ld => sub {
      my $t = shift;
      my $tbody = ($t->look_down('_tag' => 'tbody'))[$tbody{$dataset}];
      my @tbody_child = $tbody->content_list;
      $tbody_child[$_]->detach for (1 .. $#tbody_child) ;
      $tbody->content_list;
    },
    td_proc => sub {
      my ($tr, $data) = @_;
      my @td = $tr->look_down('_tag' => 'td');
      for my $i (0..$#td) {
#	warn $i;
	$td[$i]->splice_content(0, 1, $data->[$i]);
      }
    }
   );
}


my $generated_html = ptree($tree, "$root.gen");

is ($generated_html, File::Slurp::read_file("$root.exp"), 
    "HTML for non-alternating table");

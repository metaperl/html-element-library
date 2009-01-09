# This might look like shell script, but it's actually -*- perl -*-
use strict;
use lib qw(t/ t/m/);


use File::Slurp;
use Test::More qw(no_plan);

use TestUtils;
use HTML::TreeBuilder;
use HTML::Element::Library;

use SelectData;

my $root = 't/html/unroll_select';

my $tree = HTML::TreeBuilder->new_from_file("$root.html");


$tree->unroll_select
 (
   select_label     => 'clan_list', 
   option_value     => sub { my $row = shift; $row->{clan_id} },
   option_content   => sub { my $row = shift; $row->{clan_name} },
   option_selected  => sub { my $row = shift; $row->{selected} },
   data             => SelectData->load_data,
   data_iter        => sub { my $data = shift; shift @$data }
  );

  my $generated_html = ptree($tree, "$root.gen");

  is ($generated_html, File::Slurp::read_file("$root.exp"), 
      "HTML for non-alternating table");

# This might look like shell script, but it's actually -*- perl -*-
use strict;
use lib qw(t/ t/m/);


use File::Slurp;
use Test::More qw(no_plan);

use TestUtils;
use HTML::TreeBuilder;
use HTML::Element::Library;

use SimpleClass;

my $root = 't/html/table';
my $o    = SimpleClass->new;
my $tree = HTML::TreeBuilder->new_from_file("$root.html");


$tree->table
 (
    # tell seamstress where to find the table, via the method call
    # ->look_down('id', $gi_table). Seamstress detaches the table from the
    # HTML tree automatically if no table rows can be built
 
      gi_table    => 'load_data',
 
    # tell seamstress where to find the tr. This is a bit useless as
    # the <tr> usually can be found as the first child of the parent
 
      gi_tr       => 'data_row',
      
    # the model data to be pushed into the table
 
      table_data  => $o->load_data,
 
    # the way to take the model data and obtain one row
    # if the table data were a hashref, we would do:
    # my $key = (keys %$data)[0]; my $val = $data->{$key}; delete $data->{$key}
 
      tr_data     => sub { my ($self, $data) = @_;
                          shift(@{$data}) ;
                        },
 
    # the way to take a row of data and fill the <td> tags
 
      td_data     => sub { my ($tr_node, $tr_data) = @_;
                          $tr_node->content_handler($_ => $tr_data->{$_})
                            for qw(name age weight) }
 
   );

  my $generated_html = ptree($tree, "$root.gen");

  is ($generated_html, File::Slurp::read_file("$root.exp"), 
      "HTML for non-alternating table");

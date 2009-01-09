# This might look like shell script, but it's actually -*- perl -*-
use strict;
use lib qw(t/ t/m/);


use File::Slurp;
use Test::More qw(no_plan);

use TestUtils;
use HTML::TreeBuilder;
use HTML::Element::Library;

my $root = 't/html/iter2';

my $tree = HTML::TreeBuilder->new_from_file("$root.html");

my @items = (
  [    Programmer => 'one who likes Perl and Seamstress', ],
  [ DBA        => 'one who does business as', ],
  [ Admin      => 'one who plays Tetris all day' ]
 );

$tree->iter2(
  # default wrapper_ld ok
  wrapper_data => \@items,
  wrapper_proc => sub {
    my ($container) = @_;

    # only keep the last 2 dts and dds
    my @content_list = $container->content_list;
    $container->splice_content(0, @content_list - 2); 
  },
  # default item_ld is k00l
  # default item_data is phrEsh
  # default item_proc will do w0rk
  splice       => sub {
    my ($container, @item_elems) = @_;
    $container->unshift_content(@item_elems);
  },

  debug => 1,
 );
  

  my $generated_html = ptree($tree, "$root.gen");

  is ($generated_html, File::Slurp::read_file("$root.exp"), 
      "HTML for generated li");

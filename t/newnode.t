#!/usr/bin/perl -T


use warnings;
use strict;

use Test::More;
use Test::XML;

BEGIN {
    use_ok('HTML::TreeBuilder');
    use_ok('HTML::Element::Library');
}


my $initial_lol = [ note => [ shopping => [ item => 'sample' ] ] ];
my $new_lol = HTML::Element::newnode($initial_lol, item => shopping_items());


sub shopping_items {
  my @shopping_items = map { [ item => $_ ] } qw(bread butter beans);
  \@shopping_items;
}

my $expected =  [
          'note',
          [
            'shopping',
            [
              [
                'item',
                'bread'
              ],
              [
                'item',
                'butter'
              ],
              [
                'item',
                'beans'
              ]
            ]
          ]
        ];

is_deeply($new_lol, $expected, 'test unrolling');



done_testing;

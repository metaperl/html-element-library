use strict;
use Test::More qw(no_plan);

use HTML::Element::Library;


my $t1;
my $lol;
$t1 = HTML::Element->new_from_lol
  (
   $lol =
   ['html',
    ['head',
     [ 'title', 'I like stuff!' ],
    ],
    ['body',
     {
      'lang', 'en-JP'},
     'stuff',
     ['p', 
      ['span', {id => 'wrapme'},
      'um, p < 4!', 
       ],
      {'class' => 'par123'}],
     ['div', {foo => 'bar'}, '123'], # at 0.1.2
     ['div', {jack => 'olantern'}, '456'], # at 0.1.2
    ]
   ]
  )
  ;

my $bold = HTML::Element->new('b', id => 'wrapper');

my $W = $t1->look_down('id' => 'wrapme');
$W->wrap_content($bold);
is( $W->as_HTML, '<span id="wrapme"><b id="wrapper">um, p &lt; 4!</b></span>', "wrapped text");



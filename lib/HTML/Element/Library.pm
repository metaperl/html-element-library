package HTML::Element::Library;


use strict;
use warnings;


our $DEBUG = 0;
#our $DEBUG = 1;

use Array::Group qw(:all);
use Carp qw(confess);
use Data::Dumper;
use HTML::Element;
use List::Util qw(first);
use List::MoreUtils qw/:all/;
use Params::Validate qw(:all);
use Scalar::Listify;
#use Tie::Cycle;
use List::Rotation::Cycle;

our %EXPORT_TAGS = ( 'all' => [ qw() ] );
our @EXPORT_OK   = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT      = qw();



our $VERSION = '4.2.c';



# Preloaded methods go here.

# https://rt.cpan.org/Ticket/Display.html?id=44105
sub HTML::Element::fillinform {

    my ($tree, $hashref, $return_tree, $guts)=@_;

    (ref $hashref) eq 'HASH' or die 'hashref not supplied as argument' ;

    use HTML::FillInForm;
    my $html = $tree->as_HTML;
    my $new_html = HTML::FillInForm->fill(\$html, $hashref);

    if ($return_tree) {
	my $tree = HTML::TreeBuilder->new_from_content($new_html);
        $tree = $guts ? $tree->guts : $tree ;
    } else {
	$new_html;
    }

}

sub HTML::Element::siblings {
  my $element = shift;
  my $p = $element->parent;
  return () unless $p;
  $p->content_list;
}

sub HTML::Element::defmap {
    my($tree,$attr,$hashref,$debug)=@_;

    while (my ($k, $v) = (each %$hashref)) {
	warn "defmap looks for ($attr => $k)" if $debug;
	my $found = $tree->look_down($attr => $k);
	if ($found) {
	    warn "($attr => $k) was found.. replacing with '$v'" if $debug;
	    $found->replace_content( $v );
	}
    }

}

sub HTML::Element::crunch {
    my $container = shift;

    my %p = validate(@_, {
			  look_down => { type => ARRAYREF },
			  leave => { default => 1 },
			 });

    my @look_down = @{$p{look_down}} ;
    my @elem = $container->look_down( @look_down ) ;
    
    my $left;
    
    for my $elem (@elem) {
	$elem->detach if $left++ >= $p{leave} ;
    }

}

sub HTML::Element::hash_map {
    my $container = shift;

    my %p = validate(@_, {
			  hash => { type => HASHREF },
			  to_attr => 1,
			  excluding => { type => ARRAYREF , default => [] },
			  debug => { default => 0 },
			 });

    warn 'The container tag is ', $container->tag if $p{debug} ;
    warn 'hash' . Dumper($p{hash}) if $p{debug} ;
    #warn 'at_under' . Dumper(\@_) if $p{debug} ;

    my @same_as = $container->look_down( $p{to_attr} => qr/.+/ ) ;

    warn 'Found ' . scalar(@same_as) . ' nodes' if $p{debug} ;


    for my $same_as (@same_as) {
	my $attr_val = $same_as->attr($p{to_attr}) ;
	if (first { $attr_val eq $_ } @{$p{excluding}}) {
	    warn "excluding $attr_val" if $p{debug} ;
	    next;
	}
	warn "processing $attr_val" if $p{debug} ;
	$same_as->replace_content( $p{hash}->{$attr_val} ) ;
    }

}

sub HTML::Element::hashmap {
    my ($container, $attr_name, $hashref, $excluding, $debug) = @_;

    $excluding ||= [] ;

    $container->hash_map(hash => $hashref, 
                          to_attr => $attr_name,
                          excluding => $excluding,
                          debug => $debug);

}


sub HTML::Element::passover {
  my ($tree, @to_preserve) = @_;
  
  warn "ARGS:   my ($tree, @to_preserve)" if $DEBUG;
  warn $tree->as_HTML(undef, ' ') if $DEBUG;

  my $exodus = $tree->look_down(id => $to_preserve[0]);

  warn "E: $exodus" if $DEBUG;

  my @s = HTML::Element::siblings($exodus);

  for my $s (@s) {
    next unless ref $s;
    if (first { $s->attr('id') eq $_ } @to_preserve) {
      ;
    } else {
      $s->delete;
    }
  }

  return $exodus; # Goodbye Egypt! http://en.wikipedia.org/wiki/Passover

}

sub HTML::Element::sibdex {

  my $element = shift;
  firstidx { $_ eq $element } $element->siblings

}

sub HTML::Element::addr { goto &HTML::Element::sibdex }

sub HTML::Element::replace_content {
  my $elem = shift;
  $elem->delete_content;
  $elem->push_content(@_);
}

sub HTML::Element::wrap_content {
  my($self, $wrap) = @_;
  my $content = $self->content;
  if (ref $content) {
    $wrap->push_content(@$content);
    @$content = ($wrap);
  }
  else {
    $self->push_content($wrap);
  }
  $wrap;
}

sub HTML::Element::Library::super_literal {
  my($text) = @_;

  HTML::Element->new('~literal', text => $text);
}


sub HTML::Element::position {
  # Report coordinates by chasing addr's up the
  # HTML::ElementSuper tree.  We know we've reached
  # the top when a) there is no parent, or b) the
  # parent is some HTML::Element unable to report
  # it's position.
  my $p = shift;
  my @pos;
  while ($p) {
    my $a = $p->addr;
    unshift(@pos, $a) if defined $a;
    $p = $p->parent;
  }
  @pos;
}


sub HTML::Element::content_handler {
  my ($tree, %content_hash) = @_;

  for my $k (keys %content_hash) {
      $tree->set_child_content(id => $k, $content_hash{$k});      
  }


}

sub HTML::Element::assign {
    goto &HTML::Element::content_handler;
}


sub make_counter {
  my $i = 1;
  sub {
    shift() . ':' . $i++
  }
}


sub HTML::Element::iter {
  my ($tree, $p, @data) = @_;

  #  warn 'P: ' , $p->attr('id') ;
  #  warn 'H: ' , $p->as_HTML;

  #  my $id_incr = make_counter;
  my @item = map {
    my $new_item = clone $p;
    $new_item->replace_content($_);
    $new_item;
  } @data;

  $p->replace_with(@item);

}


sub HTML::Element::iter2 {

  my $tree = shift;

  #warn "INPUT TO TABLE2: ", Dumper \@_;

  my %p = validate(
    @_, {
      wrapper_ld    => { default => ['_tag' => 'dl'] },
      wrapper_data  => 1,
      wrapper_proc  => { default => undef },
      item_ld       => { default => sub { 
			   my $tree = shift;
			   [
			     $tree->look_down('_tag' => 'dt'),
			     $tree->look_down('_tag' => 'dd')
			    ];
			 }
			},
      item_data     => { default => sub { my ($wrapper_data) = @_;
					  shift(@{$wrapper_data}) ;
					}},
      item_proc     => {
	default => sub {
	  my ($item_elems, $item_data, $row_count) = @_;
	  $item_elems->[$_]->replace_content($item_data->[$_]) for (0,1) ;
	  $item_elems;
	}},
      splice        => { default => sub {
			   my ($container, @item_elems) = @_;
			   $container->splice_content(0, 2, @item_elems);
			 }
			},
      debug => {default => 0}
     }
   );

  warn "wrapper_data: " . Dumper $p{wrapper_data} if $p{debug} ;

  my $container = ref_or_ld($tree, $p{wrapper_ld});
  warn "container: " . $container if $p{debug} ;
  warn "wrapper_(preproc): " . $container->as_HTML if $p{debug} ;
  $p{wrapper_proc}->($container) if defined $p{wrapper_proc} ;
  warn "wrapper_(postproc): " . $container->as_HTML if $p{debug} ;

  my $_item_elems = $p{item_ld}->($container);
  


  my $row_count;
  my @item_elem;
  {
    my $item_data  = $p{item_data}->($p{wrapper_data});
    last unless defined $item_data;

    warn Dumper("item_data", $item_data);


    my $item_elems = [ map { $_->clone } @{$_item_elems} ] ;

    if ($p{debug}) {
      for (@{$item_elems}) {
	warn "ITEM_ELEMS ", $_->as_HTML;
      }
    }

    my $new_item_elems = $p{item_proc}->($item_elems, $item_data, ++$row_count);

    if ($p{debug}) {
      for (@{$new_item_elems}) {
	warn "NEWITEM_ELEMS ", $_->as_HTML;
      }
    }


    push @item_elem, @{$new_item_elems} ;

    redo;
  }

  warn "pushing " . @item_elem . " elems " if $p{debug} ;

  $p{splice}->($container, @item_elem);

}

sub HTML::Element::dual_iter {
  my ($parent, $data) = @_;

  my ($prototype_a, $prototype_b) = $parent->content_list;

  #  my $id_incr = make_counter;

  my $i;

  @$data %2 == 0 or 
    confess 'dataset does not contain an even number of members';

  my @iterable_data = ngroup 2 => @$data;

  my @item = map {
    my ($new_a, $new_b) = map { clone $_ } ($prototype_a, $prototype_b) ;
    $new_a->splice_content(0,1, $_->[0]);
    $new_b->splice_content(0,1, $_->[1]);
    #$_->attr('id', $id_incr->($_->attr('id'))) for ($new_a, $new_b) ;
    ($new_a, $new_b)
  } @iterable_data;

  $parent->splice_content(0, 2, @item);

}


sub HTML::Element::set_child_content {
  my $tree      = shift;
  my $content   = pop;
  my @look_down = @_;

  my $content_tag = $tree->look_down(@look_down);

  unless ($content_tag) {
    warn "criteria [@look_down] not found";
    return;
  }

  $content_tag->replace_content($content);

}

sub HTML::Element::highlander {
  my ($tree, $local_root_id, $aref, @arg) = @_;

  ref $aref eq 'ARRAY' or confess 
    "must supply array reference";
    
  my @aref = @$aref;
  @aref % 2 == 0 or confess 
    "supplied array ref must have an even number of entries";

  warn __PACKAGE__ if $DEBUG;

  my $survivor;
  while (my ($id, $test) = splice @aref, 0, 2) {
    warn $id if $DEBUG;
    if ($test->(@arg)) {
      $survivor = $id;
      last;
    }
  }


  my @id_survivor = (id => $survivor);
  my $survivor_node = $tree->look_down(@id_survivor);
#  warn $survivor;
#  warn $local_root_id;
#  warn $node;

  warn "survivor: $survivor" if $DEBUG;
  warn "tree: "  . $tree->as_HTML if $DEBUG;

  $survivor_node or die "search for @id_survivor failed in tree($tree): " . $tree->as_HTML;

  my $survivor_node_parent = $survivor_node->parent;
  $survivor_node = $survivor_node->clone;
  $survivor_node_parent->replace_content($survivor_node);

  warn "new tree: " . $tree->as_HTML if $DEBUG;

  $survivor_node;
}


sub HTML::Element::highlander2 {
  my $tree = shift;

  my %p = validate(@_, {
    cond => { type => ARRAYREF },
    cond_arg => { type => ARRAYREF,
		  default => []
		 },
    debug => { default => 0 }
   }
		  );


  my @cond = @{$p{cond}};
  @cond % 2 == 0 or confess 
    "supplied array ref must have an even number of entries";

  warn __PACKAGE__ if $p{debug};

  my @cond_arg = @{$p{cond_arg}};

  my $survivor; my $then;
  while (my ($id, $if_then) = splice @cond, 0, 2) {

    warn $id if $p{debug};
    my ($if, $_then);

    if (ref $if_then eq 'ARRAY') {
      ($if, $_then) = @$if_then;
    } else {
      ($if, $_then) = ($if_then, sub {});
    }

    if ($if->(@cond_arg)) {
      $survivor = $id;
      $then = $_then;
      last;
    }

  }

  my @ld = (ref $survivor eq 'ARRAY')
      ? @$survivor
	  : (id => $survivor)
	      ;

  warn "survivor:    ", $survivor if $p{debug};
  warn "survivor_ld: ", Dumper \@ld if $p{debug};


  my $survivor_node = $tree->look_down(@ld);

  $survivor_node or confess
      "search for @ld failed in tree($tree): " . $tree->as_HTML;

  my $survivor_node_parent = $survivor_node->parent;
  $survivor_node = $survivor_node->clone;
  $survivor_node_parent->replace_content($survivor_node);


  # **************** NEW FUNCTIONALITY *******************

  # apply transforms on survivor node


  warn "SURV::pre_trans "  . $survivor_node->as_HTML if $p{debug};
  $then->($survivor_node, @cond_arg);
  warn "SURV::post_trans "  . $survivor_node->as_HTML if $p{debug};

  # **************** NEW FUNCTIONALITY *******************




  $survivor_node;
}


sub overwrite_action {
  my ($mute_node, %X) = @_;

  $mute_node->attr($X{local_attr}{name} => $X{local_attr}{value}{new});
}


sub HTML::Element::overwrite_attr {
  my $tree = shift;
  
  $tree->mute_elem(@_, \&overwrite_action);
}



sub HTML::Element::mute_elem {
  my ($tree, $mute_attr, $closures, $post_hook) = @_;

  warn "my mute_node = $tree->look_down($mute_attr => qr/.*/) ;";
  my @mute_node = $tree->look_down($mute_attr => qr/.*/) ;

  for my $mute_node (@mute_node) {
    my ($local_attr,$mute_key)        = split /\s+/, $mute_node->attr($mute_attr);
    my $local_attr_value_current      = $mute_node->attr($local_attr);
    my $local_attr_value_new          = $closures->{$mute_key}->($tree, $mute_node, $local_attr_value_current);
    $post_hook->(
      $mute_node,
      tree => $tree,
      local_attr => {
	name => $local_attr,
	value => {
	  current => $local_attr_value_current,
	  new     => $local_attr_value_new
	 }
       }
     ) if ($post_hook) ;
  }
}



sub HTML::Element::table {

  my ($s, %table) = @_;

  my $table = {};

  #  use Data::Dumper; warn Dumper \%table;

  #  ++$DEBUG if $table{debug} ;


  # Get the table element
  $table->{table_node} = $s->look_down(id => $table{gi_table});
  $table->{table_node} or confess
    "table tag not found via (id => $table{gi_table}";

  # Get the prototype tr element(s) 
  my @table_gi_tr = listify $table{gi_tr} ;
  my @iter_node = map 
    {
      my $tr = $table->{table_node}->look_down(id => $_);
      $tr or confess "tr with id => $_ not found";
      $tr;
    } @table_gi_tr;

  warn "found " . @iter_node . " iter nodes " if $DEBUG;
  #  tie my $iter_node, 'Tie::Cycle', \@iter_node;
  my $iter_node =  List::Rotation::Cycle->new(@iter_node);

  #  warn $iter_node;
  warn Dumper ($iter_node, \@iter_node) if $DEBUG;

  # $table->{content}    = $table{content};
  #$table->{parent}     = $table->{table_node}->parent;


  #  $table->{table_node}->detach;
  #  $_->detach for @iter_node;

  my @table_rows;

  {
    my $row = $table{tr_data}->($table, $table{table_data});
    last unless defined $row;

    # get a sample table row and clone it.
    my $I = $iter_node->next;
    warn  "I: $I" if $DEBUG;
    my $new_iter_node = $I->clone;


      $table{td_data}->($new_iter_node, $row);
      push @table_rows, $new_iter_node;

    redo;
  }

  if (@table_rows) {

    my $replace_with_elem = $s->look_down(id => shift @table_gi_tr) ;
    for (@table_gi_tr) {
      $s->look_down(id => $_)->detach;
    }

    $replace_with_elem->replace_with(@table_rows);

  }

}

sub ref_or_ld {

  my ($tree, $slot) = @_;

  if (ref($slot) eq 'CODE') {
    $slot->($tree);
  } else {
    $tree->look_down(@$slot);
  }
}



sub HTML::Element::table2 {

  my $tree = shift;



  my %p = validate(
    @_, {
      table_ld    => { default => ['_tag' => 'table'] },
      table_data  => 1,
      table_proc  => { default => undef },
      
      tr_ld       => { default => ['_tag' => 'tr']    },
      tr_data     => { default => sub { my ($self, $data) = @_;
				      shift(@{$data}) ;
				    }},
      tr_base_id  => { default => undef },
      tr_proc     => { default => sub {} },
      td_proc     => 1,
      debug => {default => 0}
     }
   );

  warn "INPUT TO TABLE2: ", Dumper \@_ if $p{debug};

  warn "table_data: " . Dumper $p{table_data} if $p{debug} ;

  my $table = {};

  #  use Data::Dumper; warn Dumper \%table;

  #  ++$DEBUG if $table{debug} ;

  # Get the table element
  #warn 1;
  $table->{table_node} = ref_or_ld( $tree, $p{table_ld} ) ;
  #warn 2;
  $table->{table_node} or confess
    "table tag not found via " . Dumper($p{table_ld}) ;

  warn "table: " . $table->{table_node}->as_HTML if $p{debug};


  # Get the prototype tr element(s) 
  my @proto_tr = ref_or_ld( $table->{table_node},  $p{tr_ld} ) ;

  warn "found " . @proto_tr . " iter nodes " if $p{debug};

  @proto_tr or return ;

  if ($p{debug}) {
    warn $_->as_HTML for @proto_tr;
  }
  my $proto_tr =  List::Rotation::Cycle->new(@proto_tr);

  my $tr_parent = $proto_tr[0]->parent;
  warn "parent element of trs: " . $tr_parent->as_HTML if $p{debug};

  my $row_count;

  my @table_rows;

  {
    my $row = $p{tr_data}->($table, $p{table_data}, $row_count);
    warn  "data row: " . Dumper $row if $p{debug};
    last unless defined $row;

    # wont work:      my $new_iter_node = $table->{iter_node}->clone;
    my $new_tr_node = $proto_tr->next->clone;
    warn  "new_tr_node: $new_tr_node" if $p{debug};

    $p{tr_proc}->($tree, $new_tr_node, $row, $p{tr_base_id}, ++$row_count)
	if defined $p{tr_proc};

    warn  "data row redux: " . Dumper $row if $p{debug};
    #warn 3.3;

    $p{td_proc}->($new_tr_node, $row);
    push @table_rows, $new_tr_node;

    #warn 4.4;

    redo;
  }

  $_->detach for @proto_tr;

  $tr_parent->push_content(@table_rows) if (@table_rows) ;

}


sub HTML::Element::unroll_select {

  my ($s, %select) = @_;

  my $select = {};

  warn "Select Hash: " . Dumper(\%select) if $select{debug};

  my $select_node = $s->look_down(id => $select{select_label});
  warn "Select Node: " . $select_node if $select{debug};

  unless ($select{append}) {
      for my $option ($select_node->look_down('_tag' => 'option')) {
	  $option->delete;
      }
  }


  my $option = HTML::Element->new('option');
  warn "Option Node: " . $option if $select{debug};

  $option->detach;

  while (my $row = $select{data_iter}->($select{data}))
    {
	warn "Data Row:" . Dumper($row) if $select{debug};
	my $o = $option->clone;
	$o->attr('value', $select{option_value}->($row));
	$o->attr('SELECTED', 1) if (exists $select{option_selected} and $select{option_selected}->($row)) ;

	$o->replace_content($select{option_content}->($row));
	$select_node->push_content($o);
	warn $o->as_HTML if $select{debug};
    }


}



sub HTML::Element::set_sibling_content {
  my ($elt, $content) = @_;

  $elt->parent->splice_content($elt->pindex + 1, 1, $content);

}

sub HTML::TreeBuilder::parse_string {
  my ($package, $string) = @_;

  my $h = HTML::TreeBuilder->new;
  HTML::TreeBuilder->parse($string);

}



1;
__END__

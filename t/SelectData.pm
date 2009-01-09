package SelectData;



my @clan_data = (
  { clan_name => 'janglers',    clan_id => 12, selected => 1 },
  { clan_name => 'thugknights', clan_id => 14 },
  { clan_name => 'cavaliers' ,  clan_id => 13 }
 );


sub new {
    my $this = shift;
    bless {}, ref($this) || $this;
}

sub load_data {
  \@clan_data
}


1;

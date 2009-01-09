package SimpleClass;


my @name   = qw(bob bill brian babette bobo bix);
my @age    = qw(99  12   44    52      12   43);
my @weight = qw(99  52   80   124     120  230);


sub new {
    my $this = shift;
    bless {}, ref($this) || $this;
}

sub load_data {
    my @data;

    for (0 .. 5) {
	push @data, { 
		     age    => shift @age,
		     name   => shift @name,
		     weight => shift @weight
		    }
    }

    \@data
}


1;

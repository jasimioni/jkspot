package Captive::Model::Config;

use strict;
use warnings;
use Log::Any qw/$log/;
use Data::Dumper;

use parent 'Catalyst::Model';
=for later
use parent 'Catalyst::Model::DBI';

__PACKAGE__->config(
  dsn           => '',
  user          => '',
  password      => '',
  options       => {},
);
=cut

__PACKAGE__->config( 
	customer_id  => 'cincoincubadora',
	radius_attrs => {
		'Mikrotik-Rate-Limit' => '2000k/2000k 4000k/4000k 2000k/2000k 60/60',
		'Port-Limit'          => 1,
		'Session-Timeout'     => 3600,
		'Idle-Timeout'        => 1800,
	}
);

sub customer_id {
	my $self = shift;
	$self->config->{customer_id};
}

sub radius_attrs {
	my $self = shift;
	$self->config->{radius_attrs};
}

1;

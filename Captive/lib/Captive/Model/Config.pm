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
		speed   => 2,
		ports   => 3,
		session => 3600,
		idle    => 1800,
	},
	authentication => {
		default => 'click_only', # username_password, name_email, click_only
		username_password => {
			allow_guest_creation => 0,
		},
		facebook => {
			enabled 	  => 1,
			appid   	  => '',
			guest_allowed => 1,
		}
	},
	pages => {
		pre_page => { 
			activate => 1,
			url 	 => undef,
			timeout  => 5,
		},
		pos_page => {
			activate => 0,
			url 	 => undef,
			timeout  => 5,
		},
	}
);

sub pos_page {
	my $self = shift;
	return $self->config->{pages}{pos_page};
}

sub pre_page {
	my $self = shift;
	return $self->config->{pages}{pre_page};
}

sub customer_id {
	my $self = shift;
	return $self->config->{customer_id};
}

sub radius_attrs {
	my $self = shift;
	return $self->config->{radius_attrs};
}

sub authentication {
	my $self = shift;
	return $self->config->{authentication};
}

1;

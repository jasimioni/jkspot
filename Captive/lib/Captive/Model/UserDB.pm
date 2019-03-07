package Captive::Model::UserDB;

use strict;
use warnings;
use parent 'Catalyst::Model::DBI';

__PACKAGE__->config(
  dsn           => '',
  user          => '',
  password      => '',
  options       => {},
);

sub authenticate {
	my ( $self, $username, $password ) = @_;
	return 1;
}

1;

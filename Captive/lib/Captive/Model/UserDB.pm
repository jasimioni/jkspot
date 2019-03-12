package Captive::Model::UserDB;

use strict;
use warnings;
use Try::Tiny;
use JSON::MaybeXS;
use parent 'Catalyst::Model::DBI';
use Log::Any qw/$log/;
use Data::Dumper;

__PACKAGE__->config(
  dsn           => 'dbi:Pg:dbname=customer_cincoincubadora;host=127.0.0.1',
  user          => 'customer_cincoincubadora',
  password      => '27fxNxvKbag2',
  options       => { RaiseError => 1 },
);

sub authenticate {
	my ( $self, $username, $password ) = @_;

	my ( $return, $result );
	try {
		$self->connection->run(fixup => sub {
	    	$result = $_->selectall_arrayref('SELECT * FROM fn_check_username_password(?, ?)', { Slice => {} }, $username, $password);
		});

		die "Sem retorno\n" unless @$result;

		$return = $result->[0];
	} catch {
		$return = {
			username 		=> $username,
			attribute 		=> undef,
			validity_period => undef,
			valid 			=> 0,
			message 		=> $_,
		}
	};

	try {
		$return->{attribute} = decode_json($return->{attribute});
	} catch {
		$return->{attribute} = {};
	};
	
	return $return;
}

1;

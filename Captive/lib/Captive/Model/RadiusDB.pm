package Captive::Model::RadiusDB;

use strict;
use warnings;
use Try::Tiny;
use JSON::MaybeXS;
use Digest::MD5 qw/md5_hex/;
use parent 'Catalyst::Model::DBI';

__PACKAGE__->config(
  dsn           => 'dbi:Pg:dbname=radius;host=127.0.0.1',
  user          => 'radius',
  password      => 'AfzdvAVBM2uNrgZv',
  options       => { RaiseError => 1 },
);

my @chars = ("A".."Z", "a".."z", "0" .. "9");

sub create_radius_credentials {
	my ( $self, $userid, $customer_id, $mac, $ip, $details, $radius_attrs, $expiration_time ) = @_;

	my $password;
	$password .= $chars[rand @chars] for 1..10;
	$password = md5_hex($customer_id, $password);

	$details      = {} if ref $details      ne 'HASH';
	$radius_attrs = {} if ref $radius_attrs ne 'HASH';

	my $error;
	try {
		$self->connection->run(fixup => sub {
	    	$_->do('INSERT INTO temp_credentials (userid, password, customer_id, mac, ip, details, radius_attrs, expiration_time) 
	    			     VALUES (?, ?, ?, ?, ?, ?, ?, ?)', undef, 
	    			     $userid, $password, $customer_id, $mac, $ip, encode_json($details), encode_json($radius_attrs), $expiration_time );
		});

	} catch {
		$error = $_;
	};

	return defined $error ? ( 0, $error ) : ( 1, $password );
}



1;

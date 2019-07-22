#!/usr/bin/perl

use common::sense;
use JSON::MaybeXS;
use Data::Dumper;
use DBI;
use Try::Tiny;

my $dbname = 'radius';
my $dbpass = 'AfzdvAVBM2uNrgZv';
my $dbhost = '127.0.0.1';
my $dbuser = 'radius';

my $dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=$dbhost", $dbuser, $dbpass, { RaiseError => 1 });

my $sth = $dbh->prepare('SELECT * FROM radacct WHERE customer_id IS NULL');
$sth->execute;

while (my $row = $sth->fetchrow_hashref) {
	print "Checking rowid: ", $row->{radacctid}, "\n";

	my ( $customer_id, $profile );

	if (defined $row->{class}) {
		my $details = {};
		try {
			$details = decode_json($row->{class});
		};
		print Dumper $details;
		if (defined $details->{customer_id}) {
			$customer_id = $details->{customer_id};
            $profile     = $details->{profile};
		}
	}	

	if ( ! defined $customer_id ) {
		my $sth2 = $dbh->prepare("SELECT customer_id, details->>'profile' profile FROM temp_credentials 
							       WHERE userid = ? AND DATE_TRUNC('second', created) <= ?::timestamp
							    ORDER BY created DESC LIMIT 1");

		print "$row->{username}, $row->{acctstarttime}\n";

		$sth2->execute($row->{username}, $row->{acctstarttime});

		($customer_id, $profile) = $sth2->fetchrow_array;
	}

	$customer_id = 'unknown' if ! defined $customer_id;
    $profile     = 'unknown' if ! defined $profile;

	$dbh->do('UPDATE radacct SET customer_id = ?, profile = ? WHERE radacctid = ?', undef, $customer_id, $profile, $row->{radacctid});
}


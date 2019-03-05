#!/usr/bin/perl

use common::sense;
use DBI;

my $dbname = 'radius';
my $dbpass = 'AfzdvAVBM2uNrgZv';
my $dbhost = '127.0.0.1';
my $dbuser = 'radius';

my $dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=$dbhost", $dbuser, $dbpass, { RaiseError => 1 });

$dbh->do("UPDATE temp_credentials SET valid = false WHERE valid = true AND created + expiration_time * interval '1 seconds' < NOW()");
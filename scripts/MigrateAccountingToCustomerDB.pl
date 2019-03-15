#!/usr/bin/perl

use common::sense;
use JSON::MaybeXS;
use Data::Dumper;
use DBI;
use Try::Tiny;

my $dbpass = 'razTBepJBY5T';
my $dbhost = '127.0.0.1';
my $dbuser = 'postgres';
my $dbname = 'postgres';

my $dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=$dbhost", $dbuser, $dbpass, { RaiseError => 1 });
my @databases = map { $_->[0] } @{$dbh->selectall_arrayref('SELECT datname FROM pg_database WHERE datname LIKE ?', undef, 'customer_%')};
my %cDbh;

foreach my $database (@databases) {
	my ($customer_id) = $database =~ /^customer_(.*)/;
	$cDbh{$customer_id} = DBI->connect("dbi:Pg:dbname=$database;host=$dbhost", $dbuser, $dbpass, { RaiseError => 1 });
}

$dbname = 'radius';
$dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=$dbhost", $dbuser, $dbpass, { RaiseError => 1 });

my @now = localtime(time - 120); # 2 minutos atrás

my $nowstr = sprintf("%04d-%02d-%02d %02d:%02d", $now[5] + 1900, $now[4] + 1, $now[3], $now[2], $now[1]);

my $last_radacct_migration = $dbh->selectall_arrayref('SELECT value FROM task_control WHERE var = ?', undef, 'last_radacct_migration')->[0][0];
$last_radacct_migration = '2010-01-01 00:00:00' if ! defined $last_radacct_migration;

my $sth = $dbh->prepare('SELECT * FROM radacct WHERE acctupdatetime < ? AND acctupdatetime > ?');
$sth->execute($nowstr, $last_radacct_migration);

while (my $row = $sth->fetchrow_hashref) {
	next if ! exists $cDbh{$row->{customer_id}};
	my $keys = join(', ', keys %$row);
	my $qmarks = join(', ', map { '?' } keys %$row);

	my $sql = <<SQL
INSERT INTO radacct ($keys) VALUES ($qmarks)
	     ON CONFLICT (radacctid)
DO UPDATE SET
	acctsessiontime    = ?,
	acctinterval       = ?,
	acctupdatetime     = ?,
	acctinputoctets    = ?,
	acctoutputoctets   = ?,
	acctstoptime       = ?,
	acctterminatecause = ?
SQL
;
	
	print $sql;

	try {
		$cDbh{$row->{customer_id}}->do($sql, undef, values %$row, 
			  @{$row}{qw/acctsessiontime acctinterval acctupdatetime acctinputoctets acctoutputoctets acctstoptime acctterminatecause radacctid/});
	} catch {
		print "Failed: $_\n";
		exit;
	};

}
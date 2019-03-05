#!/usr/bin/perl

use strict;
use warnings;
use Digest::MD5 qw/md5_hex/;

my @chars = ("A".."Z", "a".."z", "0" .. "9");

my $customer_id = 'JOAO';

my $password;
$password .= $chars[rand @chars] for 1..10;

print "Random password: $password\n";

$password = md5_hex($customer_id, $password);

print "Password: $password\n";
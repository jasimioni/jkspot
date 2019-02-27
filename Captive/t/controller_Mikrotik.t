use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Captive';
use Captive::Controller::Mikrotik;

ok( request('/mikrotik')->is_success, 'Request should succeed' );
done_testing();

use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Captive';
use Captive::Controller::EAP;

ok( request('/eap')->is_success, 'Request should succeed' );
done_testing();

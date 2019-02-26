use strict;
use warnings;

use Captive;

my $app = Captive->apply_default_middlewares(Captive->psgi_app);
$app;


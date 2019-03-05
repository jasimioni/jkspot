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

=head1 NAME

Captive::Model::UserDB - DBI Model Class

=head1 SYNOPSIS

See L<Captive>

=head1 DESCRIPTION

DBI Model Class.

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

package Captive::View::HTMLNW;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die         => 1,
    ENCODING           => 'utf-8',
);


=head1 NAME

Captive::View::HTMLNW - Catalyst View

=head1 DESCRIPTION

Catalyst View.


=encoding utf8

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

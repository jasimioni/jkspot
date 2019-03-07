package Captive::View::HTMLSW;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die         => 1,
    ENCODING           => 'utf-8',
    WRAPPER            => 'simple-wrapper.tt',
);

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
package Captive::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config(namespace => '');

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # Hello World
    $c->response->body( $c->welcome_message );
}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

sub auto :Private {
    my ($self, $c) = @_;
    if (! exists $c->stash->{title}) {
	    $c->stash(title => 'Captive Portal');
	}

    if ($c->session->{target} !~ /^https?:\/\//) {
        $c->session(target => $c->uri_for('/login/form'));
    }

    return 1;
}

sub end : ActionClass('RenderView') {}

__PACKAGE__->meta->make_immutable;

1;

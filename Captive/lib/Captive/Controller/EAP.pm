package Captive::Controller::EAP;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $mac    = $c->req->params->{'clientMac'};
    my $target = $c->req->params->{'target'};

    $c->session('target'    => $target);
    $c->session('clientMac' => $mac);
    $c->session('device'    => 'eap');

    $c->go('/login/form');
}

sub doauth :Local {
    my ( $self, $c ) = @_;

    $c->stash(target      => $c->session->{target});
    $c->stash('clientMac' => $c->session->{clientMac});
}

__PACKAGE__->meta->make_immutable;

1;

package Captive::Controller::Mikrotik;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $target = $c->req->params->{'target'};
    my $dst	   = $c->req->params->{'dst'};

    $c->session('target' => $target);
    $c->session('dst'    => $dst);
    $c->session('device' => 'mikrotik');

    $c->go('/login/form');
}

sub doauth :Local {
    my ( $self, $c ) = @_;

    $c->stash(target => $c->session->{target});
    $c->stash(dst    => $c->session->{dst});
}

__PACKAGE__->meta->make_immutable;

1;

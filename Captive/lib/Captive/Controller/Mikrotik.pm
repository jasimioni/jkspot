package Captive::Controller::Mikrotik;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $target = $c->req->params->{'target'};
    my $dst	   = $c->req->params->{'dst'};
    my $ip     = $c->req->params->{'ip'};
    my $mac    = $c->req->params->{'mac'};

    $c->session('target' => $target);
    $c->session('dst'    => $dst);
    $c->session('mac'    => $mac);
    $c->session('ip'     => $ip);
    $c->session('device' => 'mikrotik');

    my $error = $c->req->params->{'error'};
    push @{$c->stash->{errors}}, $error if $error;

    $c->go('/login/form');
}

sub doauth :Local {
    my ( $self, $c ) = @_;

    $c->stash(target => $c->session->{target});
    $c->stash(dst    => $c->session->{dst});
}

__PACKAGE__->meta->make_immutable;

1;

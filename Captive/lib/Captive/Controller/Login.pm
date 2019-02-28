package Captive::Controller::Login;
use Moose;
use namespace::autoclean;
use utf8;

BEGIN { extends 'Catalyst::Controller'; }

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
}

sub form :Local {
    my ( $self, $c ) = @_;
}

sub check_login :Local {
    my ( $self, $c ) = @_;

    my $username = $c->req->params->{username};
    my $password = $c->req->params->{password};

    if ($username eq 'joao' && $password eq 'simioni') {
        $c->stash(tok_username => 'joao');
        $c->stash(tok_password => 'simioni');
        $c->stash(auth_domain  => 'basic_internal');
        $c->go('/' . $c->session->{device} . '/doauth');
    } else {
        push @{$c->stash->{errors}}, "Usuário ou senha inválidos";
        $c->go('/login/form');
    }
}

__PACKAGE__->meta->make_immutable;

1;

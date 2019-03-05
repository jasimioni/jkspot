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

sub internal_db :Local {
    my ( $self, $c ) = @_;

    my $username = $c->req->params->{username};
    my $password = $c->req->params->{password};

    if (1) { # Any Password
        $c->stash(tok_username => $username);
        $c->stash(auth_domain  => 'internaldb');
        $c->go('create_radius_credentials');
    } else {
        push @{$c->stash->{errors}}, "Usuário ou senha inválidos";
        $c->go('/login/form');
    }
}

sub create_radius_credentials :Local {
    my ( $self, $c ) = @_;

    my $userid          = $c->stash->{tok_username};
    my $customer_id     = $c->model('Config')->customer_id;
    my $mac             = $c->session->{mac};
    my $ip              = $c->session->{ip};
    my $details         = {
        auth_domain => $c->stash->{auth_domain},
        customer_id => $customer_id,
    };
    my $radius_attrs    = $c->model('Config')->radius_attrs;
    my $expiration_time = 5;

    my ($success, $return) = $c->model('RadiusDB')->create_radius_credentials($userid, $customer_id, $mac, $ip, $details, $radius_attrs, $expiration_time);

    if ($success) {
        $c->stash(tok_password => $return);
        $c->go('/' . $c->session->{device} . '/doauth');
    } else {
        push @{$c->stash->{errors}}, $return;
        $c->go('/login/form');        
    }

}

__PACKAGE__->meta->make_immutable;

1;

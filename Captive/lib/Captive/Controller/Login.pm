package Captive::Controller::Login;
use Moose;
use namespace::autoclean;
use utf8;
use Try::Tiny;

BEGIN { extends 'Catalyst::Controller'; }

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
}

sub form :Local {
    my ( $self, $c ) = @_;

    $c->stash(authentication => $c->model('Config')->authentication);
}

sub name_email :Local {
    my ( $self, $c ) = @_;

    my $name         = $c->req->params->{name};
    my $email        = $c->req->params->{email};
    my $allowcontact = $c->req->params->{allowcontact};

    try {
        die "Método de autenticação não permitido\n" if $c->model('Config')->authentication->{default} ne 'name_email';
        $c->stash(tok_username => $email);
        $c->stash(auth_domain  => 'name_email');
        # $c->model('UserDB')->register_name_email($name, $email, $allowcontact);
        $c->go('/login/create_radius_credentials');
    } catch {
        push @{$c->stash->{errors}}, "$_";
        $c->go('/login/form');
    };
}

sub click_only :Local {
    my ( $self, $c ) = @_;

    try {
        die "Método de autenticação não permitido\n" if $c->model('Config')->authentication->{default} ne 'click_only';
        my @chars = ("A".."Z", "a".."z", "0" .. "9");
        my $login = "clickonly_" . time() . '_';
        $login .= $chars[rand @chars] for 1..4;
        $c->stash(tok_username => $login);
        $c->stash(auth_domain  => 'click_only');
        $c->go('/login/create_radius_credentials');        
    } catch {
        push @{$c->stash->{errors}}, "$_";
        $c->go('/login/form');
    };
}

sub username_password :Local {
    my ( $self, $c ) = @_;

    try {
        my $username = $c->req->params->{username};
        my $password = $c->req->params->{password};

        die "Usuário ou senha inválidos\n" unless $c->model('UserDB')->authenticate($username, $password);

        $c->stash(tok_username => $username);
        $c->stash(auth_domain  => 'internaldb');
        $c->go('/login/create_radius_credentials');
    } catch {
        push @{$c->stash->{errors}}, "$_";
        $c->go('/login/form');
    };
}

sub create_radius_credentials :Private {
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
        $c->log->debug("Success creating radius credentials - going to doauth");
        $c->stash(tok_password => $return);
        my $destination = '/' . $c->session->{device} . '/doauth';
        $c->go($destination);
    } else {
        $c->log->debug("Failed to create credentials - $return");
        push @{$c->stash->{errors}}, $return;
        $c->go('/login/form');        
    }

}

__PACKAGE__->meta->make_immutable;

1;

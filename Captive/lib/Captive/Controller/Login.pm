package Captive::Controller::Login;
use Moose;
use namespace::autoclean;
use utf8;
use Try::Tiny;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller'; }

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
}

sub form :Local {
    my ( $self, $c ) = @_;

    my $pre_page = $c->model('Config')->pre_page;

    if ($pre_page->{activate} && ! $c->session->{pre_page_displayed}) {
        $c->log->debug("Pre page activated - redirecting");
        $c->session(pre_page_displayed => 1);
        my $timeout = defined $pre_page->{timeout} ? int($pre_page->{timeout}) : 5;
        $c->session(pre_page_timeout => $timeout);

        my $redirect_url = $pre_page->{url} ? $pre_page->{url} : $c->uri_for('/pre_page');

        $c->response->redirect($redirect_url);
    } else {
        $c->stash(authentication => $c->model('Config')->authentication);
    }
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

        my $return = $c->model('UserDB')->authenticate($username, $password);
        $c->log->debug("Return from authentication: " . Dumper $return);

        die $return->{message} . "\n" unless $return->{valid};

        $c->stash(tok_username => $username);
        $c->stash(auth_domain  => 'internaldb');

        $c->stash(auth_attrs  => $return->{attribute});
        $c->stash(auth_period => $return->{validity_period});

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
    # Get Default Attributes
    my $radius_attrs = $c->model('Config')->radius_attrs;

    # Overwrite keys from authentication
    foreach my $key (keys %{$c->stash->{auth_attrs}}) {
        $radius_attrs->{$key} = $c->stash->{auth_attrs}{$key};
    }

    # Apply transformations
    $radius_attrs = $c->model('AttrTranslate')->translate($c->session->{device}, $radius_attrs);

    my $expiration_time = 5;

    $c->log->debug("Trying to create credentials: $userid, $customer_id, $mac, $ip");
    $c->log->debug('Details: ' . Dumper $details);
    $c->log->debug('Radius Attributes: '. Dumper $radius_attrs);

    my ($success, $return) = $c->model('RadiusDB')->create_radius_credentials($userid, $customer_id, $mac, $ip, 
                                                                              $details, $radius_attrs, $expiration_time);

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

package Captive;
use Moose;
use namespace::autoclean;
use Log::Any::Adapter ('Stdout');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    -Debug
    ConfigLoader
    Static::Simple
    Session
    Session::State::Cookie
    Session::Store::File
    SmartURI
    LogWarnings
/;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in captive.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'Captive',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 1, # Send X-Catalyst header
    using_frontend_proxy => 1,
    default_view => 'HTML',
    case_sensitive => 0,
    'Plugin::Static::Simple' => {
        expires => 3600, # Caching allowed for one hour.
        logging => 1,
        debug => 1,
    },
    'Plugin::Session' => {
        'storage' => '/tmp/captive_session_' . $<
    },
    'Plugin::SmartURI' => {
        disposition => 'relative',
        uri_class   => 'URI::SmartURI'
    }

);

# Start the application
__PACKAGE__->setup();
__PACKAGE__->log->levels( qw/info error fatal/ ) unless __PACKAGE__->debug;
__PACKAGE__->log->disable('warn') unless __PACKAGE__->debug;
Log::Any::Adapter->set('Catalyst', logger => __PACKAGE__->log);


=encoding utf8

=head1 NAME

Captive - Catalyst based application

=head1 SYNOPSIS

    script/captive_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<Captive::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

package Captive::Model::AttrTranslate;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

my $tr = {
	ut => {
		speed => sub {
            my $speed = shift;
            my $base  = $speed * 1000;
            my $burst = $base  * 2;
            return ( 'Mikrotik-Rate-Limit' => sprintf('%ik/%ik %ik/%ik %ik/%ik 60/60', $base, $base, $burst, $burst, $base, $base) );
		},
        ports   => sub { return ( 'Port-Limit'      => shift ); },
        session => sub { return ( 'Session-Timeout' => shift ); },
        idle    => sub { return ( 'Idle-Timeout'    => shift ); },		
	}
};

sub translate {
	my ( $self, $device, $attrs ) = @_;

	if (exists $tr->{$device}) {

		my $tr = $tr->{$device};

		foreach my $key (keys %$attrs) {
			if (exists $tr->{$key}) {
				my ($newkey, $value) = $tr->{$key}->($attrs->{$key});
				delete $attrs->{$key};
				$attrs->{$newkey} = $value;	
			}
		}
	}

	return $attrs;
}

__PACKAGE__->meta->make_immutable;

1;

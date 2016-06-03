# A fairly simple example:
use strict;
use warnings;
use POE qw(Component::Server::IRC);

my %config = (
    servername => 'simple.poco.server.irc',
    nicklen    => 15,
    network    => 'SimpleNET'
);

my $pocosi = POE::Component::Server::IRC->spawn( config => \%config );

POE::Session->create(
    package_states => [
        'main' => [qw(_start _default)],
    ],
    heap => { ircd => $pocosi },
);

$poe_kernel->run();

sub _start {
    my ($kernel, $heap) = @_[KERNEL, HEAP];

    $heap->{ircd}->yield('register', 'all');

    # Anyone connecting from the loopback gets spoofed hostname
    # $heap->{ircd}->add_auth(
    #     mask     => '*@localhost',
    #     spoof    => 'm33p.com',
    #     no_tilde => 1,
    # );

    # We have to add an auth as we have specified one above.
    $heap->{ircd}->add_auth(mask => '*@*');

    # Start a listener on the 'standard' IRC port.
    $heap->{ircd}->add_listener(port => 5667);

    # Add an operator who can connect from localhost
    $heap->{ircd}->add_operator(
        {
            username => 'moo',
            password => 'fishdont',
        }
    );
}

sub _default {
    my ($event, @args) = @_[ARG0 .. $#_];

    print "$event: ";
    for my $arg (@args) {
        if (ref($arg) eq 'ARRAY') {
            print "[", join ( ", ", @$arg ), "] ";
        }
        elsif (ref($arg) eq 'HASH') {
            print "{", join ( ", ", %$arg ), "} ";
        }
        else {
            print "'$arg' ";
        }
    }

    print "\n";
 }

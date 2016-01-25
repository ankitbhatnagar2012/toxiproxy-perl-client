package Proxy;

use Moose;
use namespace::autoclean;

use Utils;

use constant {
    UPSTREAM    => 'upstream',
    DOWNSTREAM  => 'downstream',
};

has toxiproxy => (
    is => 'rw',
    isa => 'Object',
);

has enabled => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
);

has name => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);

has upstream => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);

has listen => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);

has upstreamToxics => (
    is => 'rw',
    isa => 'Maybe[Array]',
);

has downstreamToxics => (
    is => 'rw',
    isa => 'Maybe[Array]',
);

sub getListenIP {
    my ( $self ) = @_;
    my ( $listenIP, $listenPort ) = split /\:/, $self->listen;
    return $listenIP;
}

sub getListenPort {
    my ( $self ) = @_;
    my ( $listenIP, $listenPort ) = split /\:/, $self->listen;
    return $listenPort;
}

sub setToxic {
    my ( $self, $toxic, $direction, $data ) = @_;
    my $url = ""; # XXX ( $self->name, $direction, $toxic );
    my $response = Utils::HTTP({
        ua => $self->toxiproxy->{ ua },
        endpoint => $url,
        body => json_encode $data,
    });

    return $response->content(); # XXX
}

sub setProxy {
    my ( $self, $data ) = @_;
    my $response = Utils::HTTP({
        ua => $self->toxiproxy->{ ua },
        endpoint => $self->toxiproxy->{ base_url } . "/proxies/" . $self->name,
        body => json_encode( $data ),
    });

    return $response->content(); # XXX
}

sub update {
    my ( $self, $toxic, $direction, @options ) = @_;
    my @valid_directions = ( UPSTREAM, DOWNSTREAM );
    
    die "Invalid direction, must be one of valid_directions"
        unless grep { $_ eq $direction } @valid_directions;

    my @settings = (); # XXX check on what this does!
    my $key = $direction . "Toxics";
    my @direction_data = $self->{ $key };
    
    push @direction_data, $toxic
        unless ( grep { $_ eq $toxic } @direction_data );

    return $self->setToxic(
        $toxic,
        $direction,
        ( @direction_data, @options ) # FIXME : think about the request object
    );
}

sub updateDownStream {
    my ( $self, $toxic, @options ) = @_;
    return $self->update(
        $toxic,
        DOWNSTREAM,
        @options,
    );
}

sub updateUpStream {
    my ( $self, $toxic, @options ) = @_;
    return $self->update(
        $toxic,
        UPSTREAM,
        @options,
    );
}

sub disable {
    my ( $self ) = @_;
    return $self->setProxy( { enabled => 0 } );
}

sub enable {
    my ( $self ) = @_;
    return $self->setProxy( { enabled => 1 } );
}

__PACKAGE__->meta->make_immutable;
1;
# vim: ts=4 sw=4 et:
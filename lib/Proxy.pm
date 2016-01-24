package Proxy;

use Moose;
use namespace::autoclean;

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
    my $url = _constructUrl( $self->name, $direction, $toxic );
    eval {
        # TODO : POST $url json_encode( $data );
        1;
    } or do {
        my $eval_error = $@ || "Zombie error";
        # XXX
    };
}

sub setProxy {
    my ( $self, $data ) = @_;
    eval {
        # TODO : POST /proxies/$self->name, json_encode( $data )
        1; 
    } or do {
        my $eval_error = $@ || "Zombie error";
        # XXX
    };
}

sub update {
    my ( $self, $toxic, $direction, @options ) = @_;
    my @valid_directions = ( UPSTREAM, DOWNSTREAM );
    
    die "Invalid direction, must be one of valid_directions"
        unless grep { $_ eq $direction } @valid_directions;

    my @settings = ();
    my $key = $direction . "Toxics";
    my $direction_data = $self->key;
    if( exists $direction_data->{ $toxic } ) {
        push @settings, $direction_data->{ $toxic };
    }

    return $self->setToxic(
        $toxic,
        $direction,
        ( @settings, @options )
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
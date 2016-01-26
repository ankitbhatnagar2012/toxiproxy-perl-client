package Proxy;

use Moose;
use namespace::autoclean;

use JSON qw( encode_json decode_json );

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
    isa => 'Maybe[ HashRef ]',
);

has downstreamToxics => (
    is => 'rw',
    isa => 'Maybe[ HashRef ]',
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
    
    my $url = sprintf("%s/proxies/%s/%s/toxics/%s", 
        $self->toxiproxy->{ base_url},
        $self->name,
        $direction,
        $toxic
    );

    my $response = Utils::HTTP({
        ua          => $self->toxiproxy->{ ua },
        method      => 'POST',
        endpoint    => $url,
        body        => encode_json $data,
    });

    return $response->content();
}

sub setProxy {
    my ( $self, $data ) = @_;

    my $response = Utils::HTTP({
        ua          => $self->toxiproxy->{ ua },
        method      => 'POST',
        endpoint    => $self->toxiproxy->{ base_url } . "/proxies/" . $self->name,
        body        => encode_json $data,
    });

    return $response->content();
}

sub update {
    my ( $self, $toxic, $direction, $options ) = @_;
    my @valid_directions = ( UPSTREAM, DOWNSTREAM );
    
    die "Invalid direction, must be one of valid_directions"
        unless grep { $_ eq $direction } @valid_directions;

    return $self->setToxic(
        $toxic,
        $direction,
        $options,
    );
}

sub updateDownStream {
    my ( $self, $toxic, $options ) = @_;
    return $self->update(
        $toxic,
        DOWNSTREAM,
        $options,
    );
}

sub updateUpStream {
    my ( $self, $toxic, $options ) = @_;
    return $self->update(
        $toxic,
        UPSTREAM,
        $options,
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
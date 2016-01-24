package Toxiproxy;

use Moose;
use namespace::autoclean;

use LWP;

use JSON qw( encode_json decode_json );

use Proxy;
use Utils;

has base_url => (
    is => 'ro',
    isa => 'Str',
    default => 'http://127.0.0.1:8474',
);

has ua => (
    is => 'rw',
    isa => 'Object',
    lazy_build => 1,
);

sub _build_ua {
    my ( $self ) = @_;

    my $ua = LWP::UserAgent->new;
    
    return $ua;
}

sub responseToProxy {
    my ( $self, $response ) = @_;

    return $self->contentsToProxy( decode_json $response );
}

sub contentsToProxy {
    my ( $self, $contents ) = @_;

    $contents->{ toxiproxy } = $self;

    return Proxy->new( $contents );
}

sub create {
    my ( $self, $name, $upstream, $listen ) = @_;

    my $response = Utils::HTTP({
        ua          => $self->ua,
        method      => 'POST',
        endpoint    => $self->base_url . "/proxies",
        body        => encode_json({
                            name        => $name,
                            upstream    => $upstream,
                            listen      => $listen
                        }),
    });

    if( $response->is_success ) {
        return $self->responseToProxy( $response->content );    
    } else {
        return { 
            code        => $response->code,
            message     => $response->message,
        };
    }
}

sub delete {
    my ( $self, $name ) = @_;
    my $response = Utils::HTTP({
        ua          => $self->ua,
        method      => 'DELETE',
        endpoint    => $self->base_url . "/proxies/" . $name,
    });

    return $response;
}

__PACKAGE__->meta->make_immutable;
1;
# vim: ts=4 sw=4 et:
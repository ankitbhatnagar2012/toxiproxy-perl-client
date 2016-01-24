package Utils;

use strict;
use warnings;

use LWP;

sub HTTP {
    my ( $params ) = @_;

    my $ua = $params->{ ua } // undef;
    die "Could not resolve application user-agent. Terminating..." unless $ua;

    my $method = $params->{ method } // undef;
    die "Could not resolve HTTP method. Terminating..." unless $method;

    my $endpoint = $params->{ endpoint } // undef;
    die "Could not resolve HTTP endpoint. Terminating..." unless $endpoint;

    my $request = HTTP::Request->new( $method => $endpoint );
    
    $request->header('content-type' => 'application/json');
    
    $request->content( $params->{ body } // "" );

    my $response;
    eval {
        $response = $ua->request( $request );
        1;
    } or do {
        my $eval_error = $@ || "Zombie Error";
        die "Error executing HTTP request : $eval_error";
    };

    return $response;
}

1;
# vim: ts=4 sw=4 et:
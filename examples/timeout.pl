use strict;
use warnings;

use Data::Dumper;

use Toxiproxy;

sub main {
    my $toxiproxy = Toxiproxy->new( base_url => "http://127.0.0.1:8474" );

    $toxiproxy->delete("examples_timeout_redis_master");

    my $proxy = $toxiproxy->create(
        "examples_timeout_redis_master",
        "127.0.0.1:6379",
    );

    $proxy->updateDownStream(
        "timeout",
        {
            enabled     => 1,
            delay       => 5 * 1000,
        }
    );

    print STDERR Data::Dumper::Dumper $proxy, $proxy->getListenIP(), $proxy->getListenPort();
}

exit main() unless caller;

1;
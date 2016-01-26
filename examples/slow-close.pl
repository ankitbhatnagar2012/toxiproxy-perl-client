use strict;
use warnings;

use Data::Dumper;

use Toxiproxy;

sub main {
    my $toxiproxy = Toxiproxy->new( base_url => "http://127.0.0.1:8474" );

    $toxiproxy->delete("examples_slow_close_redis_master");

    my $proxy = $toxiproxy->create(
        "examples_slow_close_redis_master",
        "127.0.0.1:6379",
    );

    $proxy->updateDownStream(
        "slow_close",
        {
            enabled     => 1,
            delay       => 1000,
        }
    );

    print STDERR Data::Dumper::Dumper $proxy, $proxy->getListenIP(), $proxy->getListenPort();
}

exit main() unless caller;

1;
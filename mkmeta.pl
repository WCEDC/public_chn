#!/usr/bin/env perl
use strict;
use warnings;

my $target = "/run/media/peterpan/87bdb8c0-b2c5-4d4f-8e56-b436b5750f7e";
my $net = "A1";
my $loc = "01";
my $Q = "D";
my %station;
open (IN, "< index.txt") or die;
foreach (<IN>) {
    #BBSX /data/2017LiangCT_WuJ_LushanGAP/BBSX/2016327/2016.327.09.BBSX.00.BHE.SAC 1479806682 1479808857.99
    my ($sta, $sacfile, $b, $e) = split m/\s+/;
    next if (defined($station{$sta}));
    my ($stla, $stlo, $stel, $delta) = (split m/\s+/, `saclst stla stlo stel delta f $sacfile`)[1..4];
    $station{$sta} = "$stla $stlo $stel $delta";
}
close(IN);
close(IN);
open (OUT, "> $target/plain.A1.mkmeta") or die;
foreach my $sta (keys %station) {
    print OUT "$sta $net $loc $station{$sta}\n";
}
close(OUT);

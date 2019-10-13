#!/usr/bin/env perl
use strict;
use warnings;
use List::Util qw(min);
use List::Util qw(max);
use Time::Local;

my $target = "/run/media/peterpan/87bdb8c0-b2c5-4d4f-8e56-b436b5750f7e";
my $net = "A1";
my $loc = "01";
my $Q = "D";
my %station;
my %start;
my %end;
my $i = 0;
open (IN, "< index.txt") or die;
foreach (<IN>) {
    #BBSX /data/2017LiangCT_WuJ_LushanGAP/BBSX/2016327/2016.327.09.BBSX.00.BHE.SAC 1479806682 1479808857.99
    my ($sta, $sacfile, $b, $e) = split m/\s+/;
    my ($stla, $stlo, $stel, $stdp, $cmpaz, $cmpinc) = (split m/\s+/, `saclst stla stlo stel stdp cmpaz cmpinc f $sacfile`)[1..6];
    my ($filename) = (split m/\//, $sacfile)[-1];
    die unless (-e $sacfile);
    $station{$sta} = "$stla|$stlo|$stel|$stdp|$cmpaz|$cmpinc|unknown|unknown|unknown|unknown|unknown";
    $start{$sta} = imin ($b, $start{$sta});
    $end{$sta} = imax ($e, $end{$sta});
    $i++;
}
close(IN);
close(IN);
foreach my $sta (keys %station) {
    open (OUT, "> $target/${net}_${sta}.meta") or die;
    print OUT "#net|sta|loc|chan|lat|lon|elev|depth|azimuth|dip|instrument|scale|scalefreq|scaleunits|samplerate|start|end\n";
    foreach ("E", "N", "Z") {
        #CI|BHP|--|BHE|33.99053|-118.36171|81|1.6|90|0|CMG-3T,VELOCITY-TRANSDUCER,GURALP|839699000|0.03|M/S|40|2009-05-20T19:45:00|2018-07-05T15:30:00
        my $info = $station{$sta};
        my ($start) = gettime($start{$sta});
        my ($end) = gettime($end{$sta});
        print OUT "$net|$sta|$loc|BH$_|$info|$start|$end\n";
    }
    close(OUT);
}

sub imin {
    my ($i, $a) = @_;
    my $out = $i;
    $out = min($out, $a) if (defined($a));
    return($out);
}
sub imax {
    my ($i, $a) = @_;
    my $out = $i;
    $out = max($out, $a) if (defined($a));
    return($out);
}
sub gettime {
    my ($sec_since_1970) = @_;
    my ($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdast) = gmtime($sec_since_1970);
    $year += 1900;
    $mon++;
    ($mon, $day, $sec, $min, $hour) = add_zero($mon, $day, $sec, $min, $hour);
    return ("${year}-${mon}-${day}T${hour}:${min}:${sec}");
}
sub add_zero(){
    my @in = @_;
    my @out;
    foreach (@in) {
        if (length($_) < 2) {
            push @out, "0$_";
        }else{
            push @out, "$_";
        }
    }
    return @out;
}

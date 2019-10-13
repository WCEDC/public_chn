#!/usr/bin/env perl
use strict;
use warnings;
use List::Util qw(min);
use List::Util qw(max);
use Time::Local;

my $target = "/run/media/peterpan/87bdb8c0-b2c5-4d4f-8e56-b436b5750f7e";
unlink glob "$target/*.mseed";
my $net = "A1";
my $loc = "01";
my $Q = "D";

my $i = 1;
open (IN, "< index.txt") or die;
foreach (<IN>) {
    #BBSX /data/2017LiangCT_WuJ_LushanGAP/BBSX/2016327/2016.327.09.BBSX.00.BHE.SAC 1479806682 1479808857.99
    my ($sta, $sacfile, $b, $e) = split m/\s+/;
    my ($filename) = (split m/\//, $sacfile)[-1];
    my ($chn) = (split m/\./, $filename)[5];
    my ($time) = gettime($b);
    die unless (-e $sacfile);
    #net.sta.YYYYJJJHHMMSS.D.LOC.CHN.mseed
    #-n netcode     Specify the SEED network code, default is KNETWK header value
    #-t stacode     Specify the SEED station code, default is KSTNM header value
    #-l locid       Specify the SEED location ID, default is KHOLE header value
    #-c chancodes   Specify the SEED channel codes, default is KCMPNM header value
    system "sac2mseed -s 1 $sacfile -n $net -t $sta -l $loc -c $chn -o $target/$net.$sta.$time.$Q.$loc.$chn.mseed";
    $i++;
    #last if ($i == 10);
}
close(IN);
sub gettime {
    #YYYYJJJHHMMSS
    my ($sec_since_1970) = @_;
    my ($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdast) = gmtime($sec_since_1970);
    $year += 1900;# 对年份和月份特殊处理
    ($sec, $min, $hour) = add_zero($sec, $min, $hour);
    $yday = "0$yday" if (length($yday) < 3);
    return ("${year}${yday}${hour}${min}${sec}");
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

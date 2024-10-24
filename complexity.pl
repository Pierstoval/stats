#!/usr/bin/perl

require "./stats/tag2date.pm";

sub num {
    my ($t)=@_;
    if($t =~ /^curl-(\d)_(\d+)_(\d+)/) {
        return 10000*$1 + 100*$2 + $3;
    }
    elsif($t =~ /^curl-(\d)_(\d+)/) {
        return 10000*$1 + 100*$2;
    }
}

sub sortthem {
    return num($a) <=> num($b);
}

@alltags= `git tag -l`;

foreach my $t (@alltags) {
    chomp $t;
    if($t =~ /^curl-([0-9_]*[0-9])\z/) {
        push @releases, $t;
    }
}

sub median {
    my @a = @_;
    my @vals = sort {$a <=> $b} @a;
    my $len = @vals;
    if($len%2) { #odd?
        return $vals[int($len/2)];
    }
    else {
        #even
        return ($vals[int($len/2)-1] + $vals[int($len/2)])/2;
    }
}

sub p99 {
    my @a = @_;
    my @vals = sort {$b <=> $a} @a;
    my $i = scalar(@vals) * 0.01;
    return $vals[$i];
}

sub worst {
    my @a = @_;
    my @vals = sort {$b <=> $a} @a;
    return $vals[0];
}

sub complexity {
    my ($tag, $path) = @_;

    # Get source files to count
    my @files;
    open(G, "git ls-tree -r --name-only $tag -- $path 2>/dev/null|");
    while(<G>) {
        chomp;
        if($_ =~ /[ch]\z/) {
            push @files, $_;
        }
    }
    close(G);

    my $cmd;
    for(@files) {
        $cmd .= "$tag:$_ ";
    }

    #  Modified McCabe Cyclomatic Complexity
    #  |   Traditional McCabe Cyclomatic Complexity
    #  |       |    # Statements in function
    #  |       |        |   First line of function
    #  |       |        |       |   # lines in function
    #  |       |        |       |       |

    my @mod;
    my @mcb;
    my @sta;
    my @lin;
    my $funcs;
    open(G, "git show $cmd 2>/dev/null| pmccabe 2>/dev/null|");
    while(<G>) {
        if($_ =~ /^(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)/) {
            my ($modmccabe, $mccabe, $statements, $first, $lines)=($1, $2, $3, $4, $5);
            push @mod, $modmccabe;
            push @mcb, $mccabe;
            push @sta, $statements;
            push @lin, $lines;
            $funcs++;
        }
    }
    close(G);
    return p99(@mod), worst(@mod), p99(@lin), worst(@lin), $funcs;
}

print <<CACHE
2000-03-14;102;105;881;1315;139
2000-03-21;102;105;874;1315;139
2000-03-21;102;105;874;1380;139
2000-08-21;95;107;881;1439;169
2000-08-30;95;107;881;1454;171
2000-09-28;97;111;781;1510;202
2000-10-16;98;111;792;1517;215
2000-12-04;96;123;823;1561;220
2001-01-05;96;123;826;1697;225
2001-01-27;98;124;801;917;225
2001-02-13;100;149;881;1054;227
2001-03-22;115;152;847;1073;234
2001-04-04;116;152;866;1073;234
2001-04-23;116;153;881;1079;234
2001-05-07;119;153;881;1080;234
2001-06-07;121;153;881;1097;239
2001-08-20;122;148;881;1063;249
2001-09-25;126;141;881;1002;270
2001-11-04;112;144;718;932;282
2001-12-05;112;148;720;1012;288
2002-01-23;106;148;672;1027;322
2002-02-05;106;148;670;1026;322
2002-03-07;107;148;676;1027;322
2002-04-15;109;148;691;1005;326
2002-05-13;110;148;712;1011;334
2002-06-13;111;147;721;1093;334
2002-10-01;119;155;775;1108;354
2002-10-11;120;156;775;1110;355
2002-11-18;122;166;777;1124;356
2003-01-14;128;168;791;1143;355
2003-04-02;129;177;770;1168;352
2003-05-19;137;178;773;1181;355
2003-07-28;141;208;840;1240;382
2003-08-15;148;214;849;1171;395
2003-11-01;130;190;900;1144;396
2004-01-22;103;189;845;1152;407
2004-03-18;99;191;646;1162;377
2004-04-26;103;195;872;1162;433
2004-06-02;110;197;876;1200;461
2004-08-10;109;199;877;1215;478
2004-10-18;109;212;877;1231;491
2004-12-20;109;212;822;1248;503
2005-02-01;109;212;822;1246;511
2005-03-04;109;213;831;1250;551
2005-04-05;109;213;831;1250;554
2005-05-16;109;215;790;1275;582
2005-09-01;109;219;790;1303;590
2005-10-13;109;219;790;1343;598
2005-12-06;90;219;476;1349;602
2006-02-27;90;221;476;1327;604
2006-03-20;90;221;476;1327;604
2006-06-12;90;224;585;1329;658
2006-08-07;90;225;585;1329;660
2006-10-29;90;232;594;1226;678
2007-01-29;89;239;543;1297;705
2007-04-11;89;242;597;1312;735
2007-06-25;89;243;607;1316;748
2007-07-10;89;243;607;1320;756
2007-09-13;90;244;616;1386;778
2007-10-29;90;244;616;1417;790
2008-01-28;89;248;611;1394;801
2008-03-30;89;249;564;1506;802
2008-06-04;89;249;578;1536;808
2008-09-01;77;213;498;1556;823
2008-11-05;79;214;501;1592;842
2008-11-13;79;214;501;1592;842
2009-01-19;79;219;500;1633;844
2009-03-02;79;219;536;1633;858
2009-05-18;80;220;536;1638;858
2009-08-12;80;234;536;1753;864
2009-11-04;88;236;536;1779;871
2010-02-09;88;248;520;1785;986
2010-04-14;88;236;520;1825;999
2010-06-16;88;241;520;1823;1066
2010-08-11;88;250;520;1822;1078
2010-10-12;88;252;520;1830;1086
2010-12-15;88;258;520;1826;1096
2011-02-17;75;258;452;1837;1123
2011-04-17;75;260;453;1856;1147
2011-04-22;75;261;451;1881;1151
2013-04-12;74;336;439;1859;1393
2013-06-22;74;337;418;1859;1409
2013-08-11;74;353;418;1859;1468
2013-10-13;72;364;442;1863;1493
2013-12-16;63;365;418;1869;1505
2014-01-29;63;365;418;1877;1510
2014-03-26;63;334;418;1887;1549
2014-05-20;69;335;418;1887;1567
2014-07-16;69;335;418;1889;1573
2014-09-10;65;335;417;1889;1600
2014-11-05;69;335;419;1909;1588
2015-01-07;67;336;420;1923;1636
2015-02-25;67;337;422;1934;1600
2015-04-22;67;343;425;1951;1606
2015-04-28;67;344;425;1951;1606
2015-06-17;69;347;442;1971;1621
2015-08-11;69;349;442;1972;1629
2015-10-07;69;351;442;1978;1630
2015-12-01;69;351;442;2001;1653
2016-01-27;69;355;442;2001;1654
2016-02-08;69;352;442;2001;1655
2016-03-23;69;353;444;2008;1659
2016-05-17;70;355;444;2019;1674
2016-05-30;70;355;444;2019;1675
2016-07-21;70;355;450;2023;1679
2016-08-03;70;355;450;2023;1679
2016-09-07;70;355;450;2023;1692
2016-09-14;70;355;450;2023;1692
2016-11-02;70;355;450;2023;1691
2016-12-20;68;371;445;2179;1711
2016-12-22;68;371;445;2179;1711
2017-02-22;70;377;446;2196;1717
2017-02-24;70;381;446;2200;1717
2017-04-19;70;378;445;2208;1731
2017-06-14;70;378;444;2225;1731
2017-08-09;70;381;444;2234;1741
2017-08-13;70;381;444;2234;1742
2017-10-04;68;384;442;2259;1813
2017-10-23;68;384;442;2415;1820
2017-11-29;70;384;447;2421;1845
2018-01-23;71;384;463;2422;1880
2018-03-13;71;384;463;2451;1895
2018-05-15;69;389;446;2459;1910
2018-07-11;69;390;446;2491;1919
2018-09-04;69;402;446;2496;1924
2018-10-30;68;403;441;2527;1980
2018-12-12;70;403;441;2533;1978
2019-02-06;70;403;443;2548;1998
2019-03-27;68;406;438;2577;2004
2019-05-22;70;406;448;2631;1981
2019-06-04;70;406;448;2631;1982
2019-07-17;70;407;448;2629;1985
2019-07-19;70;407;448;2629;1985
2019-09-10;70;280;447;2624;2074
2019-11-05;70;286;435;2625;2079
2020-01-08;67;298;428;2625;2119
2020-03-04;69;300;444;2629;2128
2020-03-11;69;300;444;2645;2128
2020-04-29;70;302;447;2648;2155
2020-06-23;70;329;449;2717;2175
2020-06-30;70;329;449;2717;2178
2020-08-19;70;329;449;2719;2184
2020-10-14;70;330;435;2719;2196
2020-12-09;69;331;433;2758;2214
2021-02-03;70;331;427;2779;2236
2021-03-31;70;339;427;2811;2253
2021-04-14;70;339;428;2811;2254
2021-05-26;70;342;427;2855;2281
2021-07-21;70;328;413;2859;2268
2021-09-14;70;328;413;2855;2271
2021-09-22;70;328;413;2855;2271
2021-11-10;71;330;413;2880;2281
2022-01-05;71;331;412;2893;2295
2022-03-05;71;325;412;2879;2279
2022-04-27;71;329;393;2879;2314
2022-05-11;71;329;395;2884;2314
2022-06-27;71;329;395;2888;2323
2022-08-31;71;329;417;2905;2335
2022-10-26;71;335;419;2929;2348
2022-12-21;70;340;390;2941;2443
2023-02-15;68;341;388;2954;2576
2023-02-20;68;346;388;2970;2576
2023-03-20;68;346;388;2970;2591
2023-03-20;68;346;388;2970;2590
2023-05-17;66;348;360;2968;2756
2023-05-23;66;348;360;2968;2756
2023-05-30;66;348;360;2968;2749
2023-07-19;66;350;368;2977;2758
2023-07-26;66;350;368;2977;2758
2023-09-13;67;350;373;2988;2690
2023-10-11;67;353;373;2988;2698
2023-12-06;67;354;370;2949;2724
2024-01-31;63;353;370;2957;2798
2024-03-27;62;353;350;2949;2920
2024-03-27;62;353;350;2949;2920
2024-05-22;63;356;354;2998;2979
2024-07-24;62;358;353;3013;3075
2024-07-31;62;358;353;3013;3079
2024-09-11;60;378;325;3032;3151
2024-09-18;60;374;325;3032;3152
CACHE
    ;

sub show {
    my ($t, $d) = @_;
    my ($mod, $wmod, $lines, $wlines, $funcs) = complexity($t, "src lib");
    if($mod < 1000) {
        printf "$d;%u;%u;%u;%u;%u\n", $mod, $wmod, $lines, $wlines, $funcs;
    }

}

foreach my $t (sort sortthem @releases) {
    if(num($t) <= 81001) {
        next;
    }
    my $d = tag2date($t);
    show($t, $d);
}

$t=`git describe`;
chomp $t;

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
    localtime(time);
my $d = sprintf "%04d-%02d-%02d", $year + 1900, $mon + 1, $mday;

show($t, $d);
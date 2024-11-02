#!/usr/bin/perl

require "./stats/tag2date.pm";

my %authors;

sub num {
    my ($t)=@_;
    if($t =~ /^(\d+)\.(\d+)\.(\d+)/) {
        return 10000*$1 + 100*$2 + $3;
    }
    elsif($t =~ /^(\d+)\.(\d+)/) {
        return 10000*$1 + 100*$2;
    }
}

sub sortthem {
    return num($a) <=> num($b);
}

@alltags= `git tag -l`;

foreach my $t (@alltags) {
    chomp $t;
    if($t =~ /^(\d+)\.(\d+)\.(\d+)/) {
        push @releases, $t;
    }
}

$filename = "output.csv";

# start is the epoch date to check for
# @a is the array of epoch commit dates
#
# Returns number of lines from before the cut-off date
sub frombefore {
    my ($before, @a) = (@_);
    my @vals = sort {$a <=> $b} @a;
    my $count;
    for my $i (@vals) {
        if($i < $before) {
            $count++;
        }
    }

    return $count;
}

sub singlefile {
    my ($tag, $f) = @_;
    open(G, "git blame -t --line-porcelain $f $tag|");
    my $author;
    my @stamp;

    while(<G>) {
        if(/^committer-time (.*)/) {
            # store every timestamp
            push @stamp, $1;
        }
    }
    close(G);
    return @stamp;
}

my %cutoff;

# store the cutoff years in epoch seconds
for my $year (2000 .. 2030) {
    $cutoff{$year} = `date +%s -d "$year-01-01"`;
}

sub show {
    my ($tag, $date) = @_;
    my @stamp;
    my @f=`git ls-tree -r --name-only $tag -- src front tests ajax config install 2>/dev/null`;

    for my $e (@f) {
        chomp $e;
        push @stamp, singlefile($tag, $e);
    }

    printf "$date";

    for (my $i = 2000; $i <= 2026; $i += 2) {
        $out = frombefore($cutoff{$i}, @stamp);
        printf ";%u", $out;
    }
    print "\n";
}

#show("ae1912cb0d494", "1999-12-29");
foreach my $t (sort sortthem @releases) {
    my $d = tag2date($t);
    show($t, $d);
}

#!/usr/bin/env perl
use strict;
use warnings;
use Cwd qw/cwd/;
use File::Basename qw/dirname/;
use LWP::Simple qw/mirror/;

my $git_exe;
for (qw(/bin /usr/bin /usr/local/bin)) {
    if (-x "$_/git") {
        $git_exe = "$_/git";
        last;
    }
};
$git_exe or die "no git found.";

my $data_dir = (dirname __FILE__) . "/data";
my $base_url = 'http://www.bizoole.com/power';

my @files = qw/all.all timetable.txt runtable.txt/;

sub exec_git(@) {
    my @cmd = @_;

    my $orig_dir = cwd;
    chdir $data_dir or die $!;

    my $exit_code = system $git_exe, @cmd;
    $exit_code >> 8 == 0 or die +(join ' ', @cmd) . " failed: $exit_code";

    chdir $orig_dir or die $!;
}

exec_git "clean", "-fd";

for (@files) {
    my $code = mirror "$base_url/$_", "$data_dir/$_";
    $code =~ /^[23]/ or die "bad status code: $code";
}

exec_git "add", $_ for @files;
exec_git "commit", "-m", "the latest files.";
exec_git "push", "origin", "master";

#!/bin/sh
exec perl -wx $0 "$@"; # -*- perl -*-
#!perl

sub Lookup {
    my $sym = shift;
    die "error: environment variable $sym not found" unless($ENV{$sym});
    return $ENV{$sym};
}

sub Replace {
    my $line = shift;
    $line =~ s!%(\w+)%!&Lookup($1)!goe;
    return $line
}

while (<>) {
    print(Replace($_));
}

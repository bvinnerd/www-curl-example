#!/usr/bin/env perl

use strict;
use warnings;
use lib 'extlib/lib/perl5';
use feature qw/say/;

use WWW::Curl::Easy;

use constant {
	DOWNLOAD_URL => 'http://192.168.56.1:3000/cdn/hyper-go-go-never-let-go.mp3',
	OUT_FILENAME => 'out.mp3',
};

my $curl;
my $code;
my $fh;

# 1st pass (wuth throttling), download part file to simulate a broken download
open($fh, '>' . OUT_FILENAME); # create
$curl = WWW::Curl::Easy->new;
$curl->setopt(WWW::Curl::Easy::CURLOPT_WRITEDATA => $fh);
$curl->setopt(WWW::Curl::Easy::CURLOPT_MAX_RECV_SPEED_LARGE => 250_000); # bytes/sec
$curl->setopt(WWW::Curl::Easy::CURLOPT_HTTPHEADER => ['Range: bytes=0-999999']); # download first 100KB
$curl->setopt(WWW::Curl::Easy::CURLOPT_URL => DOWNLOAD_URL);
$code = $curl->perform;
close($fh);
say("code: $code");
say("bytes downloaded (part 1): " . -s OUT_FILENAME);

# Resume download
open($fh, '>>' . OUT_FILENAME); # append
$curl = WWW::Curl::Easy->new;
$curl->setopt(WWW::Curl::Easy::CURLOPT_WRITEDATA => $fh);
$curl->setopt(WWW::Curl::Easy::CURLOPT_RESUME_FROM_LARGE => -s OUT_FILENAME);
$curl->setopt(WWW::Curl::Easy::CURLOPT_URL => DOWNLOAD_URL);
$code = $curl->perform;
close($fh);
say("code: $code");
say("total bytes downloaded: " . -s OUT_FILENAME);

#!/usr/bin/env perl

use strict;
use warnings;

# ================================ #

use File::Find;
use Digest::MD5;
use Storable qw(nstore retrieve);
use Term::ANSIColor;
use Text::ASCIITable;
use Getopt::Long 'HelpMessage';

# ================================================================ #
# ========================== VARIABLES =========================== #
# ================================================================ #

# File in which to store the change information
my $info_file_name;

# A list of directoris to search
my $dirs_to_search = '.';

# Real-time MD5 hash values of files being processed
my %real_info;

# MD5 information saved on file the last time the script was run
my $file_info = {};

my $table = Text::ASCIITable->new({headingText => 'Result'});

my %total = (NEW => 0, MOD => 0, DEL => 0);

# ================================================================ #
# ========================== FUNCTIONS =========================== #
# ================================================================ #

sub md5 {
    
    my $file = shift ;
    
    open my $f, "<", $file or die "Can't open the file $file: $!\n";
    binmode($f);
    
    my $result = Digest::MD5->new->addfile($f)->hexdigest;
    
    close $f;
    
    return $result;
}

sub print_help {

}

# ================================================================ #
# ============================= MAIN ============================= #
# ================================================================ #

GetOptions(
    'file=s'   => \($info_file_name = ".change.info"),
    'target=s' => \$dirs_to_search,
    'help'     => sub { HelpMessage(0) },
) or die "Invalid options passed to $0\n";

if ($info_file_name !~ /^\./) {
    $info_file_name = '.' . $info_file_name;
}

$table->setCols('NEW', "MOD", 'DEL');
$table->setColWidth("NEW", 64);
$table->setColWidth("MOD", 64);
$table->setColWidth("DEL", 64);

# Check for an existing information file and read it if there is one
if (-f $info_file_name) {
    $file_info = retrieve($info_file_name);
}

# If nothing there, return nothing
if (not defined $dirs_to_search) {
    print "Noothing to look at\n";
    exit(0);
}

# Go through the file tree an store the information of the files
find( sub {-f $_ && ($real_info{$File::Find::name} = md5($_))}, $dirs_to_search);

# Check for changed, added files
# (clear any entries from the stored information for any files we found)
foreach my $file (sort keys %real_info) {
    
    if (not defined($file_info->{$file})) {
        $total{NEW}++;
        $table->addRow($file, '', '');
    }
    else {
        if ($real_info{$file} ne $file_info->{$file}) {
            $total{MOD}++;
            $table->addRow('', $file, '');
        }
        
        delete $file_info->{$file};
    }
}

# All file information for existing files has been removed from the information data.
# So what's left is information on deleted files
foreach  my $file (sort keys %$file_info) {
    $total{DEL}++;
    $table->addRow('', '', $file);
}

$table->addRowLine();
$table->addRow($total{NEW}, $total{MOD}, $total{DEL});

nstore \%real_info, $info_file_name;

if ($total{NEW} != 0 || $total{MOD} != 0 || $total{DEL} != 0) {
    print $table;
}

=head1 NAME

c4cf - Checking for Changed Filess

=head1 SYNOPSIS

    --file,-f       Storage filename (defaults to .change.info)
    --target,-t     Directory to check (defaults to .)
    --help,-h       Print this help

=cut

#!/usr/bin/perl
use strict;
use warnings;

### FIX SCRIPT

# usage: perl convert_gff3_togtf.pl GFF3_file.gff3 outname.gtf

my ($line, $name, $nameout);
$nameout = $ARGV[1];

my %exoncount;
my %idpar;

open (Results, ">", $nameout);
open (GFFfile , "<", $ARGV[0]); 
while (<GFFfile>) {
	chomp;
	$line = $_;
	next if ($line !~ /\S+/);
	next if ($line =~ /^#/);
	next if ($line =~ /^END\t/);
	my @subline = split (/\t/, $line);

	if ($subline[2] =~ /mRNA/){
		my $id = "";
		if ($subline[8] =~ /ID=([^;]+)/){
			$id = $1;
		} else {die "Error: Can't find ID in $line\n";}

		my $parentid = "";
		if ($subline[8] =~ /Parent=([^;]+)/){
			$parentid = $1;
		} else {die "Error: Can't find Parent in $line\n";}

		$idpar{$id} = $parentid;

		print Results "$subline[0]\t$subline[1]\tgene\t$subline[3]\t$subline[4]\t$subline[5]\t$subline[6]\t$subline[7]\tgene id \"$parentid\"; gene type \"protein_coding\";\n";	
		print Results "$subline[0]\t$subline[1]\ttranscript\t$subline[3]\t$subline[4]\t$subline[5]\t$subline[6]\t$subline[7]\tgene id \"$parentid\"; transcript id \"$id\"; gene type \"protein_coding\";\n";	

		$exoncount{$id} = 0;

	}

	elsif ($subline[2] =~ /CDS/){
		my $id = "";
		if ($subline[8] =~ /Parent=([^;]+)/){
			$id = $1;
		} else {die "Can't find Parent in $line\n";}

		my $cds = "";
		if ($subline[8] =~ /ID=([^;]+)/){
			$cds = $1;
		} else {die "Can't find ID in $line\n";}

		my $parentid = $idpar{$id};

		$exoncount{$id}++;

		print Results "$subline[0]\t$subline[1]\texon\t$subline[3]\t$subline[4]\t$subline[5]\t$subline[6]\t\.\tgene id \"$parentid\"; transcript id \"$id\"; exon number \"$exoncount{$id}\"; gene type \"protein_coding\";\n";	
		print Results "$subline[0]\t$subline[1]\tCDS\t$subline[3]\t$subline[4]\t$subline[5]\t$subline[6]\t$subline[7]\tgene id \"$parentid\"; transcript id \"$id\"; exon number \"$exoncount{$id}\"; gene type \"protein_coding\";\n";	

	}

}
close GFFfile;

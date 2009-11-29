#!/usr/bin/perl

# Enter jail based on name (or anything that matches).
#  cubix@pobox.com, Aug 2008

my $jls_cmd = '/usr/sbin/jls';
my $jexec_cmd = '/usr/sbin/jexec';
my $shell = $ENV{"SHELL"};
print STDERR "usage: jk -<JID> | <pattern> [ <shell> ]\n" and exit 1
  if (!defined($ARGV[0]));
my $jid_req = ($ARGV[0] =~ /^\-(\d+)$/) ? $1 : 0;

open(JAILS, "$jls_cmd |")
  or die "cannot execute: $jls_cmd: $!";
my $header = <JAILS>;
my @jails;
while(<JAILS>) {
  if (/^\s+$jid_req\s+/) {
    @jails = ( $_ ); break;
  }
  if (/$ARGV[0]/) {
    push @jails, $_;
  }
}
close JAILS;

my $matches = scalar @jails;
if ($matches > 1)
  {
    print $header;
    foreach $line (reverse @jails) {
      print $line;
    }
    print "$matches matches.\n";
  }
elsif ($matches == 1)
  {
    @line = split /\s+/, $jails[0];
    shift @line;
    my ($jid, $ip, $host) = @line;
    $shell = $ARGV[1] if (defined $ARGV[1]);
    print STDERR "Entering jail {$host, $ip, $shell}\n";
    exec $jexec_cmd, ($jid, $shell);
    die "Error: exec $jexec_cmd: $!";
  }
else
  {
    print STDERR "No match.\n";
  } 
exit 0;

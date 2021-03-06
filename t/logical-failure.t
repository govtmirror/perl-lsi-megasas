#!/usr/bin/perl
use warnings;
use strict;

use Test::More tests => 7;

# Test logical drive information parsing

BEGIN {
    use_ok( 'LSI::MegaSAS' ) || print "Bail out!
";
}

my $m; # LSI::MegaSAS object

#  new_ok() does not work in Test::More version 0.62 (CentOS 5).
if (defined(&{'new_ok'})) {
	$m = new_ok( 'LSI::MegaSAS' );
} else {
	#  use the older new() + isa_ok().
	$m = LSI::MegaSAS->new();
	isa_ok($m, 'LSI::MegaSAS');
}

$ENV{'TEST_MEGACLI'} = 1;
# Sample output from -LDInfo -Lall -aALL
$ENV{'TEST_MEGACLI_OUTPUT'} = <<__EOF;
Adapter 1 -- Virtual Drive Information:
Virtual Drive: 0 (Target Id: 0)
Name                :
RAID Level          : Primary-0, Secondary-0, RAID Level Qualifier-0
Size                : 45.634 GB
State               : Optimal
Strip Size          : 128 KB
Number Of Drives    : 1
Span Depth          : 1
Default Cache Policy: WriteThrough, ReadAheadNone, Direct, No Write Cache if Bad BBU
Current Cache Policy: WriteThrough, ReadAheadNone, Direct, No Write Cache if Bad BBU
Access Policy       : Read/Write
Disk Cache Policy   : Disabled
Encryption Type     : None
Default Power Savings Policy: Controller Defined
Current Power Savings Policy: Automatic
Can spin up in 1 minute: No
LD has drives that support T10 power conditions: No
LD's IO profile supports MAX power savings with cached writes: No


Virtual Drive: 1 (Target Id: 1)
Name                :
RAID Level          : Primary-1, Secondary-0, RAID Level Qualifier-0
Size                : 67.054 GB
State               : Degraded
Strip Size          : 128 KB
Number Of Drives    : 2
Span Depth          : 1
Default Cache Policy: WriteThrough, ReadAheadNone, Direct, No Write Cache if Bad BBU
Current Cache Policy: WriteThrough, ReadAheadNone, Direct, No Write Cache if Bad BBU
Access Policy       : Read/Write
Disk Cache Policy   : Disabled
Encryption Type     : None
Default Power Savings Policy: Automatic
Current Power Savings Policy: Maximum without caching
Can spin up in 1 minute: Yes
LD has drives that support T10 power conditions: Yes
LD's IO profile supports MAX power savings with cached writes: No
__EOF

can_ok($m, 'logical_drive_failures');
my @failed = $m->logical_drive_failures;

# Basic datatype checks
is(@failed, 1, 'logical_drive_failures() returns one failed drive');

# Verify the failure information
like($failed[0], qr/Adapter 1/i, 'failed drive is on the correct adapter ID');
like($failed[0], qr/Logical Drive 1/i, 'failed drive is the correct drive ID');
unlike($failed[0], qr/Optimal/i, 'failed drive is not listed as "optimal"');

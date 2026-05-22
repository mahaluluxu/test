#!/usr/bin/perl -w
################################################################################
##
## Name:        collect_sta.pl
## Author:      Yi Xu (yixu@synaptics.com)
## Description: Produces a summary HTML of the STA timing reports
## Use:         ....,
##
################################################################################

BEGIN {
    use strict;
    use warnings;
    use Getopt::Long;
    use Cwd;

    # add common perl modules
    push (@INC, "/proj/vsysip01/vsysip/scripts/perl_modules");
    if (defined $ENV{SOS_CLIENT}) {
        # project related perl search directories
        push (@INC, "$ENV{SOS_CLIENT}/vsys/comm/asic/flow/scripts/perl_modules");
    }
}

#==================================================================
# START OF PERL SCRIPT
#==================================================================

use File::Basename;
use Data::Dumper;
#use List::MoreUtils ':all';
#STORE PATH TO STA RUN AND OPEN SANITY REPORT FILE
my $STA_RUN_PATH = "";
my $OUT_FILE_PATH;
my $OUT_FILE;
my $OUT_FILE2;
my $REPORT_TIMING = 0;
my $PATH_FROM_ARG;

my $my_dir = getcwd;
if (!defined $ARGV[0]) {
    die "\nError: Please give the STA run folder path.\n\n";
}

#process arguements
#$REPORT_TIMING = 1 if ($ARGV[0] =~ m/-timing/ or (defined $ARGV[1] and $ARGV[1] =~ m/-timing/));
$REPORT_TIMING = 1;
if ($ARGV[0] =~ m/-timing/) {
    if (!defined $ARGV[1]) {die "\nError: Please give the STA run folder path.\n\n";}
    $PATH_FROM_ARG = $ARGV[1];
} else {
    $PATH_FROM_ARG = $ARGV[0];
}

if ($PATH_FROM_ARG =~ m/^[^\/]+\/[^\/]+$/) { #checking if path given in argument is for a directory other than the users run/STA directory
    $STA_RUN_PATH = "$ENV{SOS_CLIENT}/run/STA/$PATH_FROM_ARG";
    $OUT_FILE_PATH = $STA_RUN_PATH;
} else {
    $STA_RUN_PATH = "$PATH_FROM_ARG";
    $OUT_FILE_PATH = "$ENV{SOS_CLIENT}/run/STA";
}

if ($STA_RUN_PATH =~ m/(.*)\/+$/) {
    $STA_RUN_PATH = $1;
}

my $collect_name = fileparse($STA_RUN_PATH);
#$STA_RUN_PATH = "$ENV{SOS_CLIENT}/run/STA/$ARG";
my $HTML_FILE;
open ($OUT_FILE, '>', "$OUT_FILE_PATH/collect_sta_detail_.rpt") or die "Can't open $OUT_FILE_PATH/collect_sta_detail_.rpt\n";
open ($OUT_FILE2, '>', "$OUT_FILE_PATH/collect_sta_summary_.rpt") or die "Can't open $OUT_FILE_PATH/collect_sta_summary_.rpt\n";
open ($HTML_FILE, '>', "$OUT_FILE_PATH/${collect_name}_sta_detail.html") or die "Can't open $OUT_FILE_PATH/${collect_name}_sta_detail.html\n";

#STORE RUN NAMES
my @STA_RUNS = glob ("$STA_RUN_PATH/*");
@STA_RUNS = grep /[\/+](fast|slow|typ)/, @STA_RUNS; #[\/+] in regex is to get to the directory name from the full path
@STA_RUNS = grep !/shift|capture|nocase|nocts/, @STA_RUNS;
@STA_RUNS = sort { $a cmp $b } @STA_RUNS;
print "\nAll Function Corners:\n"; 
foreach my $co (@STA_RUNS) {print "$co\n";}
#STORE SHIFT RUN NAMES
my @STA_SHIFT_RUNS = glob ("$STA_RUN_PATH/*");
@STA_SHIFT_RUNS = grep /shift/, @STA_SHIFT_RUNS;
#print "shift corner number $#STA_SHIFT_RUNS \n";
#STORE CAPTURE RUN NAMES
my @STA_CAPTURE_RUNS = glob ("$STA_RUN_PATH/*");
@STA_CAPTURE_RUNS = grep /capture/, @STA_CAPTURE_RUNS;

my $error_flag = 0;

#STA sanity checks
print "\nCOLLECT STA CHECKS SUMMARY:\n";
print "----------------------------------------\n";


print $HTML_FILE "<html>\n";
print $HTML_FILE "<body>\n";
#print $HTML_FILE "<h1> COLLECT STA CHECKS SUMMARY </h1>\n";

print $HTML_FILE "<header>\n";
print $HTML_FILE "<meta charset=\"utf-8\" />\n";
print $HTML_FILE "<style>\n";
print $HTML_FILE ".menuss{\n";
print $HTML_FILE "    width:800px;\n";
print $HTML_FILE "    height:400px;\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".pp p{\n";
print $HTML_FILE "    font-family:Georgia;\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".bb pre{\n";
print $HTML_FILE "    font-family: Consolas,DejaVu Sans Mono,Menlo;\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".bb pre{\n";
print $HTML_FILE "    font-size: 15px;\n";
print $HTML_FILE "}\n";


#print $HTML_FILE ".pp p{\n";
#print $HTML_FILE "    font-weight:bold;\n";
#print $HTML_FILE "}\n";
print $HTML_FILE ".ss table{\n";
print $HTML_FILE "    border-collapse:collapse\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".ss table{\n";
print $HTML_FILE "    border: 2px solid black\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".ss table{\n";
print $HTML_FILE "    table-layout:fixed\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".ss table{\n";
print $HTML_FILE "    word-wrap:break-word\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".ss table{\n";
print $HTML_FILE "    word-break:break-all\n";
print $HTML_FILE "}\n";
#print $HTML_FILE ".ss table{\n";
#print $HTML_FILE "    width:2800px\n";
#print $HTML_FILE "}\n";

print $HTML_FILE ".ss td{\n";
print $HTML_FILE "    overflow:hidden\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".ss td{\n";
print $HTML_FILE "    word-break:break-all\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".ss td{\n";
print $HTML_FILE "    white-space: nomal\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".ss td{\n";
print $HTML_FILE "    word-wrap:break-word\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".ss td{\n";
print $HTML_FILE "    text-width:180px\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".ss td{\n";
print $HTML_FILE "    text-align:center\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".ss caption{\n";
print $HTML_FILE "    caption-side: top\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".ss caption{\n";
print $HTML_FILE "    padding: .15em\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".ss caption{\n";
print $HTML_FILE "    text-align:left\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".ss caption{\n";
print $HTML_FILE "    color: #00F\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".ss caption{\n";
print $HTML_FILE "    font-weight: bolder\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".ss caption{\n";
print $HTML_FILE "    text-size: 15em\n";
print $HTML_FILE "}\n";

print $HTML_FILE ".bb table{\n";
print $HTML_FILE "    border-collapse:collapse\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".bb table{\n";
print $HTML_FILE "    border: 2px solid black\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".bb table{\n";
print $HTML_FILE "    table-layout:fixed\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".bb table{\n";
print $HTML_FILE "    word-wrap:break-word\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".bb table{\n";
print $HTML_FILE "    word-break:break-all\n";
print $HTML_FILE "}\n";
#print $HTML_FILE ".bb table{\n";
#print $HTML_FILE "    width:2800px\n";
#print $HTML_FILE "}\n";

print $HTML_FILE ".bb td{\n";
print $HTML_FILE "    overflow:hidden\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".bb td{\n";
print $HTML_FILE "    word-break:break-all\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".bb td{\n";
print $HTML_FILE "    white-space: nomal\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".bb td{\n";
print $HTML_FILE "    word-wrap:break-word\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".bb td{\n";
print $HTML_FILE "    text-width:180px\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".bb td{\n";
print $HTML_FILE "    text-align:left\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".bb caption{\n";
print $HTML_FILE "    caption-side: top\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".bb caption{\n";
print $HTML_FILE "    padding: .15em\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".bb caption{\n";
print $HTML_FILE "    text-align:left\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".bb caption{\n";
print $HTML_FILE "    color: #00F\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".bb caption{\n";
print $HTML_FILE "    font-weight: bolder\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".bb caption{\n";
print $HTML_FILE "    font-size: 1.5em\n";
print $HTML_FILE "}\n";

print $HTML_FILE ".bb td{\n";
print $HTML_FILE "    font-family: Verdana\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".bb td{\n";
print $HTML_FILE "    padding: .15em\n";
print $HTML_FILE "}\n";
print $HTML_FILE ".bb pre{\n";
print $HTML_FILE "    padding: .15em\n";
print $HTML_FILE "}\n";




print $HTML_FILE "</style>\n";
print $HTML_FILE "</header>\n";
print $HTML_FILE "<div class=\"menuss\">\n";
print $HTML_FILE "<p id=\'demo\'>Sta Info: </p>\n";

my %Check_runlog = ();
my %Check_sdclog = ();
my %Check_RC = ();
my %Check_annotated = ();
my %Check_annotated_pocv = ();
my %Check_constraint = ();
my %Check_timing_report = ();
my %Noclk_report = ();
my %Check_clktransition = ();
my %Check_trans_data = ();
my %Check_trans_cap = ();
my %Check_si = ();
my %Check_si_type = ();
my %Check_si_clk = ();
my %Check_si_clk_type = ();
my %Check_clk_xtalk = ();
my %Check_noise = ();
my %Check_noise_double_switching = ();
my %Check_noise_double_switching_clk = ();
my %Check_nonCTS = ();
my %Check_clkTranNoneClkBuf = ();
my %Check_min_pulse = ();
my %Check_min_period = ();

my %num_Check_runlog = ();
my %num_Check_sdclog = ();
my %num_Check_RC = ();
my %num_Check_annotated = ();
my %num_Check_annotated_pocv = ();
my %num_Check_constraint = ();
my %num_Check_timing_report = ();
my %num_Noclk_report = ();
my %num_Check_clktransition = ();
my %sum_Check_clktransition = ();
my %num_Check_trans_data = ();
my %worst_Check_trans_data = ();
my %sum_Check_trans_data = ();
my %num_Check_trans_cap = ();
my %sum_Check_trans_cap = ();
my %num_Check_si = ();
my %sum_Check_si = ();
my %num_Check_si_clk = ();
my %sum_Check_si_clk = ();
my %num_Check_clk_xtalk = ();
my %sum_Check_clk_xtalk = ();
my %num_Check_noise = ();
my %sum_Check_noise = ();
my %num_Check_noise_double_switching = ();
my %num_Check_noise_double_switching_clk = ();
my %num_Check_nonCTS = ();
my %sum_Check_nonCTS = ();
my %num_Check_clkTranNoneClkBuf = ();
my %num_Check_min_pulse = ();
my %num_Check_min_period = ();

my %run_corners = ();
my %sum_corners = ();
if (defined $STA_RUNS[0]) {
    	print "\nSumarize Function timing\n";
	print "==========================================================\n";
	check_allv_timing_reports ("setup", $OUT_FILE2, @STA_RUNS);
	check_allv_timing_reports ("hold", $OUT_FILE2, @STA_RUNS);
	check_sum_timing_reports("setup hold", @STA_RUNS);
    	print "\nFUNCTIONAL RUNS\n";
        $error_flag += check_sanity_reports ($OUT_FILE, $OUT_FILE2, @STA_RUNS);
}
if (defined $STA_CAPTURE_RUNS[0]) {
    	print "\nSumarize Capture timing\n";
	print "==========================================================\n";
	check_allv_timing_reports ("setup", $OUT_FILE2, @STA_CAPTURE_RUNS);
	check_allv_timing_reports ("hold", $OUT_FILE2, @STA_CAPTURE_RUNS);
	check_sum_timing_reports("setup hold", @STA_CAPTURE_RUNS);
        print "\nCAPTURE RUNS\n";
        $error_flag += check_sanity_reports ($OUT_FILE, $OUT_FILE2, @STA_CAPTURE_RUNS);
}
if (defined $STA_SHIFT_RUNS[0]) {
    	print "\nSumarize Shift timing\n";
	print "==========================================================\n";
	check_allv_timing_reports ("setup", $OUT_FILE2, @STA_SHIFT_RUNS);
	check_allv_timing_reports ("hold", $OUT_FILE2, @STA_SHIFT_RUNS);
	check_sum_timing_reports("setup hold", @STA_SHIFT_RUNS);
        print "\nSHIFT RUNS\n";
        $error_flag += check_sanity_reports ($OUT_FILE, $OUT_FILE2, @STA_SHIFT_RUNS);
}
### Generate Basic Infomation Of The Sta Run ###
my @set_module_list = glob("$STA_RUN_PATH/*/set_module.tcl");
#print "@set_module_list\n";
my $set_module_file = $set_module_list[0];
my $Module_File;
open($Module_File, "<", "$set_module_file") or die "Cannot open $Module_File for check!";
my @module_lines = <$Module_File>;
#print "@module_lines\n";
my $macro_name;
my $netlist;
my $sdc_file;
my $capture;
my $shift;
my $pba;
my @all_modes;
my $length_shift = @STA_SHIFT_RUNS;
my $length_capture = @STA_CAPTURE_RUNS;
if ($length_shift > 0) { $shift = "true";} else {$shift = "false";}
if ($length_capture > 0) { $capture = "true";} else {$capture = "false";}
foreach my $module_line (@module_lines) {
	my $line = $module_line;
    if ($line =~ m/set MODULE_TOP +(.*)/) {$macro_name = $1;}
    if ($line =~ m/set NETLIST +"(.*)"/) {$netlist = $1; $netlist =~ s/\s+/\<br\>/g;}
    if ($line =~ m/set SDCFILE +(.*)/) {$sdc_file = $1;}
    if ($line =~ m/set PBA +"(.*)"/) {$pba = $1;}


}


close $Module_File;

print $HTML_FILE "<button type=\"button\" onclick=\"document.getElementById(\'basic_table\').style.display=\'none\'\">\n";
print $HTML_FILE "Hide Basic Info\n";
print $HTML_FILE "</button>\n";
print $HTML_FILE "<button type=\"button\" onclick=\"document.getElementById(\'basic_table\').style.display=\'table\'\">\n";
print $HTML_FILE "Show Basic Info\n";
print $HTML_FILE "</button>\n";

print $HTML_FILE "<div class=\"bb\" id=\"vidoshow\">\n";
print $HTML_FILE "<table id=\"basic_table\" width=1600px border=\"1\";>\n";
print $HTML_FILE "<caption><em> Basic Info </caption></em>\n";
print $HTML_FILE "<tr>\n";
print $HTML_FILE "<td width=200px style=\"font-weight: 600\">Module Name: </td>\n";
print $HTML_FILE "<td>$macro_name</td>\n";
print $HTML_FILE "</tr>\n";

print $HTML_FILE "<tr>\n";
print $HTML_FILE "<td style=\"font-weight: bold\">Netlist: </td>\n";
print $HTML_FILE "<td>$netlist</td>\n";
print $HTML_FILE "</tr>\n";

print $HTML_FILE "<tr>\n";
print $HTML_FILE "<td style=\"font-weight: bold\">SDC file: </td>\n";
print $HTML_FILE "<td>$sdc_file</td>\n";
print $HTML_FILE "</tr>\n";

print $HTML_FILE "<tr>\n";
print $HTML_FILE "<td style=\"font-weight: bold\">Capture Mode: </td>\n";
print $HTML_FILE "<td>$capture</td>\n";
print $HTML_FILE "</tr>\n";

print $HTML_FILE "<tr>\n";
print $HTML_FILE "<td style=\"font-weight: bold\">Shift Mode: </td>\n";
print $HTML_FILE "<td>$shift</td>\n";
print $HTML_FILE "</tr>\n";

print $HTML_FILE "<tr>\n";
print $HTML_FILE "<td style=\"font-weight: bold\">PBA: </td>\n";
print $HTML_FILE "<td>$pba</td>\n";
print $HTML_FILE "</tr>\n";

print $HTML_FILE "<tr>\n";
print $HTML_FILE "<td style=\"font-weight: bold\">STA Run Path: </td>\n";
print $HTML_FILE "<td>$STA_RUN_PATH</td>\n";
print $HTML_FILE "</tr>\n";

print $HTML_FILE "<tr>\n";
print $HTML_FILE "<td style=\"font-weight: bold\">Setup: </td>\n";
print $HTML_FILE "<td>\n";
my @SETUP_STA_RUNS = grep {$_ !~ m/capture/} grep {$_ !~ m/shift/} grep {$_ =~ m/slow/} grep {$_ =~ m/setup/} keys %sum_corners;
my @setup_keys_sorted_by_tns ;
if ($#SETUP_STA_RUNS >= 0) {
@setup_keys_sorted_by_tns = sort {$sum_corners{$a}->[1] <=> $sum_corners{$b}[1]} @SETUP_STA_RUNS;
print "All Setup Corners: @setup_keys_sorted_by_tns\n";
print "@SETUP_STA_RUNS \n";
my $filename = fileparse($setup_keys_sorted_by_tns[0]);
my $filename_2;
if ($setup_keys_sorted_by_tns[1] =~ m/\// ) {
	$filename_2 = fileparse($setup_keys_sorted_by_tns[1]);
} else {
	$filename_2 = $setup_keys_sorted_by_tns[1]	;
}
my $setup_qor_file = glob("$STA_RUN_PATH/$setup_keys_sorted_by_tns[0]/report/qor_sum_pba_*rpt");
print "$setup_qor_file \n";
my @qor_setup_lines = split(/\n/, `awk \'(NR>11) && (NR<27){print \$0}\' $setup_qor_file`) ;
printf $HTML_FILE "Corner: %43s    WNS: %5.4f  TNS: %5.4f  NVP: %-6d\n", $filename, $sum_corners{$setup_keys_sorted_by_tns[0]}->[0], $sum_corners{$setup_keys_sorted_by_tns[0]}->[1], $sum_corners{$setup_keys_sorted_by_tns[0]}->[2];
print $HTML_FILE "<br/>";
print $HTML_FILE "<pre><span class=\"inner-pre\" style=\"font-size: 14px; color: blue\">";
print $HTML_FILE "$qor_setup_lines[0]\n";
print $HTML_FILE "$qor_setup_lines[1]\n";
print $HTML_FILE "$qor_setup_lines[2]\n";
print $HTML_FILE "$qor_setup_lines[3]\n";
print $HTML_FILE "$qor_setup_lines[4]\n";
print $HTML_FILE "$qor_setup_lines[5]\n";
print $HTML_FILE "$qor_setup_lines[6]\n";
print $HTML_FILE "$qor_setup_lines[7]\n";
print $HTML_FILE "</span></pre>";
print $HTML_FILE "</td>\n";
print $HTML_FILE "</tr>\n";
}
my $wns_str = "WNS:";
my $tns_str = "TNS:";

my @HOLD_STA_RUNS = grep {$_ !~ m/capture/} grep {$_ !~ m/shift/} grep {$_ !~ m/typ/} keys %sum_corners;
my @hold_keys_sorted_by_tns ;
if ($#HOLD_STA_RUNS >= 0) {
@hold_keys_sorted_by_tns = sort {$sum_corners{$a}->[4] <=> $sum_corners{$b}[4]} @HOLD_STA_RUNS ;
$filename = fileparse($hold_keys_sorted_by_tns[0]);
$filename_2 = fileparse($hold_keys_sorted_by_tns[1]);
my $hold_qor_file = glob("$STA_RUN_PATH/$hold_keys_sorted_by_tns[0]/report/qor_sum_pba_*rpt");
print "$hold_qor_file \n";
my @qor_hold_lines = split(/\n/, `awk \'(NR>11) && (NR<27){print \$0}\' $hold_qor_file`) ;
print $HTML_FILE "<tr>\n";
print $HTML_FILE "<td style=\"font-weight: bold\">Hold: </td>\n";
print $HTML_FILE "<td>\n";
printf $HTML_FILE "Corner: %43s    WNS: %5.4f  TNS: %5.4f  NVP: %-6d\n", $filename, $sum_corners{$hold_keys_sorted_by_tns[0]}->[3], $sum_corners{$hold_keys_sorted_by_tns[0]}->[4], $sum_corners{$hold_keys_sorted_by_tns[0]}->[5];
print $HTML_FILE "<pre><span class=\"inner-pre\" style=\"font-size: 14px; color: blue\">";
print $HTML_FILE "$qor_hold_lines[0]\n";
print $HTML_FILE "$qor_hold_lines[1]\n";
print $HTML_FILE "$qor_hold_lines[2]\n";
print $HTML_FILE "$qor_hold_lines[3]\n";
print $HTML_FILE "$qor_hold_lines[4]\n";
print $HTML_FILE "$qor_hold_lines[5]\n";
print $HTML_FILE "$qor_hold_lines[6]\n";
print $HTML_FILE "$qor_hold_lines[7]\n";
print $HTML_FILE "</span></pre>";
print $HTML_FILE "</td>\n";
print $HTML_FILE "</tr>\n";
}
my @shift_hold_keys_sorted_by_tns ;
if ($#STA_SHIFT_RUNS >= 0) {
my @SHIFT_HOLD_STA_RUNS = grep {$_ !~ m/capture/} grep {$_ =~ m/shift/} grep {$_ !~ m/typ/}  keys %sum_corners;
if ($#SHIFT_HOLD_STA_RUNS > 0) {
	@shift_hold_keys_sorted_by_tns = sort {$sum_corners{$a}->[4] <=> $sum_corners{$b}->[4]} @SHIFT_HOLD_STA_RUNS ;
} else {
	@shift_hold_keys_sorted_by_tns = @SHIFT_HOLD_STA_RUNS;
}
if (-e  $shift_hold_keys_sorted_by_tns[0]) {
$filename = fileparse($shift_hold_keys_sorted_by_tns[0]);
$filename_2 = fileparse($shift_hold_keys_sorted_by_tns[1]);
}
my $shift_hold_qor_file = glob("$STA_RUN_PATH/$shift_hold_keys_sorted_by_tns[0]/report/qor_sum_pba_*rpt");
print "$shift_hold_qor_file \n";
my @shift_qor_hold_lines = split(/\n/, `awk \'(NR>11) && (NR<27){print \$0}\' $shift_hold_qor_file`) ;
print $HTML_FILE "<tr>\n";
print $HTML_FILE "<td style=\"font-weight: bold\">Shift Hold: </td>\n";
print $HTML_FILE "<td>\n";
printf $HTML_FILE "Corner: %43s    WNS: %5.4f  TNS: %5.4f  NVP: %-6d\n", $shift_hold_keys_sorted_by_tns[0],  $sum_corners{$shift_hold_keys_sorted_by_tns[0]}->[3], $sum_corners{$shift_hold_keys_sorted_by_tns[0]}->[4], $sum_corners{$shift_hold_keys_sorted_by_tns[0]}->[5];
print $HTML_FILE "<pre><span class=\"inner-pre\" style=\"font-size: 14px; color: blue\">";
print $HTML_FILE "$shift_qor_hold_lines[0]\n";
print $HTML_FILE "$shift_qor_hold_lines[1]\n";
print $HTML_FILE "$shift_qor_hold_lines[2]\n";
print $HTML_FILE "$shift_qor_hold_lines[3]\n";
print $HTML_FILE "$shift_qor_hold_lines[4]\n";
print $HTML_FILE "$shift_qor_hold_lines[5]\n";
print $HTML_FILE "</span></pre>";
print $HTML_FILE "</td>\n";
print $HTML_FILE "</tr>\n";
}

my @capture_setup_keys_sorted_by_tns ;
if ($#STA_CAPTURE_RUNS >= 0) {
my @CAPTURE_SETUP_STA_RUNS = grep {$_ =~ m/capture/} grep {$_ !~ m/shift/} grep {$_ !~ m/typ/}  keys %sum_corners;
if ($#CAPTURE_SETUP_STA_RUNS > 0) {
	@capture_setup_keys_sorted_by_tns = sort {$sum_corners{$a}->[1] <=> $sum_corners{$b}->[1]} @CAPTURE_SETUP_STA_RUNS ;
} else {
	@capture_setup_keys_sorted_by_tns = @CAPTURE_SETUP_STA_RUNS;
}
if (-e  $capture_setup_keys_sorted_by_tns[0]) {
$filename = fileparse($capture_setup_keys_sorted_by_tns[0]);
$filename_2 = fileparse($capture_setup_keys_sorted_by_tns[1]);
}
print $HTML_FILE "<tr>\n";
print $HTML_FILE "<td style=\"font-weight: bold\">Capture Setup: </td>\n";
print $HTML_FILE "<td>\n";
printf $HTML_FILE "Corner: %43s    WNS: %5.4f  TNS: %5.4f  NVP: %-6d\n", $capture_setup_keys_sorted_by_tns[0],  $sum_corners{$capture_setup_keys_sorted_by_tns[0]}->[0], $sum_corners{$capture_setup_keys_sorted_by_tns[0]}->[1], $sum_corners{$capture_setup_keys_sorted_by_tns[0]}->[2];
print $HTML_FILE "<pre><span class=\"inner-pre\" style=\"font-size: 14px; color: blue\">";
print $HTML_FILE "</span></pre>";
print $HTML_FILE "</td>\n";
print $HTML_FILE "</tr>\n";

my @CAPTURE_HOLD_STA_RUNS = grep {$_ =~ m/capture/} grep {$_ !~ m/shift/} grep {$_ !~ m/typ/}  keys %sum_corners;
if ($#CAPTURE_HOLD_STA_RUNS > 0) {
	@capture_hold_keys_sorted_by_tns = sort {$sum_corners{$a}->[4] <=> $sum_corners{$b}->[4]} @CAPTURE_HOLD_STA_RUNS ;
} else {
	@capture_hold_keys_sorted_by_tns = @CAPTURE_HOLD_STA_RUNS;
}
if (-e  $capture_hold_keys_sorted_by_tns[0]) {
$filename = fileparse($capture_hold_keys_sorted_by_tns[0]);
$filename_2 = fileparse($capture_hold_keys_sorted_by_tns[1]);
}
print $HTML_FILE "<tr>\n";
print $HTML_FILE "<td style=\"font-weight: bold\">Capture Hold: </td>\n";
print $HTML_FILE "<td>\n";
printf $HTML_FILE "Corner: %43s    WNS: %5.4f  TNS: %5.4f  NVP: %-6d\n", $capture_hold_keys_sorted_by_tns[0],  $sum_corners{$capture_hold_keys_sorted_by_tns[0]}->[3], $sum_corners{$capture_hold_keys_sorted_by_tns[0]}->[4], $sum_corners{$capture_hold_keys_sorted_by_tns[0]}->[5];
print $HTML_FILE "<pre><span class=\"inner-pre\" style=\"font-size: 14px; color: blue\">";
print $HTML_FILE "</span></pre>";
print $HTML_FILE "</td>\n";
print $HTML_FILE "</tr>\n";

}

my @power_line_1 = split(/\s+/, `grep \"Cell Leakage Power\" $STA_RUN_PATH/typ85.si_pocv_typical85_vdd0.8/report/${macro_name}_power.rpt`);
my @power_line_2 = split(/\s+/, `grep \"Cell Leakage Power\" $STA_RUN_PATH/typ25.si_pocv_typical25_vdd0.8/report/${macro_name}_power.rpt`);
# Convert to mW
my $leakage_power_1 = $power_line_1[5] * 1000;
my $leakage_power_2 = $power_line_2[5] * 1000;
print $HTML_FILE "<tr>\n";
print $HTML_FILE "<td style=\"font-weight: bold\">Leakage (mW): </td>\n";
print $HTML_FILE "<td>\n";
#print $HTML_FILE "$power_line[5]";
printf $HTML_FILE "%.4f (TT/85C/0.8V)<br>%.4f (TT/25C/0.8V)", $leakage_power_1, $leakage_power_2;
print $HTML_FILE "</td>\n";
print $HTML_FILE "</tr>\n";

my $vt_rpt = `cat $STA_RUN_PATH/typ85.si_pocv_typical85_vdd0.8/report/report_vt.rpt | grep -v TURBO`;
chomp $vt_rpt;
print $HTML_FILE "<tr>\n";
print $HTML_FILE "<td style=\"font-weight: bold\">VT Ratio </td>\n";
print $HTML_FILE "<td>\n";
print $HTML_FILE "<pre>$vt_rpt</pre>";
print $HTML_FILE "</td>\n";
print $HTML_FILE "</tr>\n";
#print Dumper(\%sum_Check_clktransition);
#my @CLK_DRC_TRANS_RUNS = grep {$_ !~ m/capture/} grep {$_ !~ m/shift/} grep {$_ !~ m/typ/} keys %sum_Check_clktransition;
#my @file_name_CLK_DRC_TRANS_RUNS;
#my $filename_1;
##print "DEBUGGING: @CLK_DRC_TRANS_RUNS\n";
#my @clk_drc_trans_keys_sorted_by_tns = sort {$sum_Check_clktransition{$b}->[2] <=> $sum_Check_clktransition{$a}->[2]} @CLK_DRC_TRANS_RUNS ;
#if (-e $clk_drc_trans_keys_sorted_by_tns[0]) {
#	$filename = fileparse($clk_drc_trans_keys_sorted_by_tns[0]);
#} else {
#	print "clk tran info on no corners ";	
#}
#if (-e $clk_drc_trans_keys_sorted_by_tns[1]) {
#	$filename_1 = fileparse($clk_drc_trans_keys_sorted_by_tns[1]);
#} else {
#	print "clk tran info on no corners ";	
#}
#print $HTML_FILE "<tr>\n";
#print $HTML_FILE "<td>DRC Clock transition: </td>\n";
#print $HTML_FILE "<td>\n";
#print $HTML_FILE "Corner: $filename\n";
#print $HTML_FILE "<br/>";
#print $HTML_FILE "-total number of violations: $sum_Check_clktransition{$clk_drc_trans_keys_sorted_by_tns[0]}->[2] \n";
#print $HTML_FILE "<br/>";
#print $HTML_FILE "-worst violator: $sum_Check_clktransition{$clk_drc_trans_keys_sorted_by_tns[0]}->[0] ($sum_Check_clktransition{$clk_drc_trans_keys_sorted_by_tns[0]}->[1])\n";
#print $HTML_FILE "<br/>";
#print $HTML_FILE "-number of clock names: $sum_Check_clktransition{$clk_drc_trans_keys_sorted_by_tns[0]}->[3]\n";
#print $HTML_FILE "<br/>";
#
#print $HTML_FILE "Corner: $filename_1\n";
#print $HTML_FILE "<br/>";
#print $HTML_FILE "-total number of violations: $sum_Check_clktransition{$clk_drc_trans_keys_sorted_by_tns[1]}->[2] \n";
#print $HTML_FILE "<br/>";
#print $HTML_FILE "-worst violator: $sum_Check_clktransition{$clk_drc_trans_keys_sorted_by_tns[1]}->[0] ($sum_Check_clktransition{$clk_drc_trans_keys_sorted_by_tns[1]}->[1])\n";
#print $HTML_FILE "<br/>";
#print $HTML_FILE "-number of clock names: $sum_Check_clktransition{$clk_drc_trans_keys_sorted_by_tns[1]}->[3]\n";
#print $HTML_FILE "<br/>";
#
##print $HTML_FILE "-total number of violations: $sum_Check_clktransition{$clk_drc_trans_keys_sorted_by_tns[2]}->[2] \n";
##print $HTML_FILE "<br/>";
##print $HTML_FILE "-worst violator: $sum_Check_clktransition{$clk_drc_trans_keys_sorted_by_tns[2]}->[0] ($sum_Check_clktransition{$clk_drc_trans_keys_sorted_by_tns[2]}->[1])\n";
##print $HTML_FILE "<br/>";
#print $HTML_FILE "</td>\n";
#print $HTML_FILE "</tr>\n";

my @DRC_TRANS_RUNS = grep {$_ !~ m/capture/} grep {$_ !~ m/shift/} grep {$_ !~ m/typ/} keys %worst_Check_trans_data;
my @drc_trans_keys_sorted_by_num = sort {$worst_Check_trans_data{$a} <=> $worst_Check_trans_data{$b}} @DRC_TRANS_RUNS ;
my $trans_filename = fileparse($drc_trans_keys_sorted_by_num[0]);
print $HTML_FILE "<tr>\n";
print $HTML_FILE "<td style=\"font-weight: bold\">DRC transition: </td>\n";
print $HTML_FILE "<td>\n";
print $HTML_FILE "Corner: $trans_filename";
print $HTML_FILE "<br/>";
print $HTML_FILE "-Number of violations: $num_Check_trans_data{$drc_trans_keys_sorted_by_num[0]}";
print $HTML_FILE "<br/>";
print $HTML_FILE "-Worst violator: $sum_Check_trans_data{$drc_trans_keys_sorted_by_num[0]}->[1]\n";
print $HTML_FILE "<br/>";
print $HTML_FILE "-Worst violation: $sum_Check_trans_data{$drc_trans_keys_sorted_by_num[0]}->[0]\n";
print $HTML_FILE "</td>\n";
print $HTML_FILE "</tr>\n";

my @DRC_CAP_RUNS = grep {$_ !~ m/capture/} grep {$_ !~ m/shift/} grep {$_ !~ m/typ/} keys %num_Check_trans_cap;
my @drc_cap_keys_sorted_by_num = sort {$num_Check_trans_cap{$b} <=> $num_Check_trans_cap{$a}} @DRC_CAP_RUNS ;
my $cap_filename = fileparse($drc_cap_keys_sorted_by_num[0]);
print $HTML_FILE "<tr>\n";
print $HTML_FILE "<td style=\"font-weight: bold\">DRC Max Cap: </td>\n";
print $HTML_FILE "<td>\n";
print $HTML_FILE "Corner: $cap_filename";
print $HTML_FILE "<br/>";
print $HTML_FILE "-Number of violations: $num_Check_trans_cap{$drc_cap_keys_sorted_by_num[0]}";
print $HTML_FILE "<br/>";
print $HTML_FILE "-Worst violator: $sum_Check_trans_cap{$drc_cap_keys_sorted_by_num[0]}->[1]";
print $HTML_FILE "<br/>";
print $HTML_FILE "-Worst violation: $sum_Check_trans_cap{$drc_cap_keys_sorted_by_num[0]}->[0]";
print $HTML_FILE "</td>\n";
print $HTML_FILE "</tr>\n";

my @DRC_SI_RUNS = grep {$_ !~ m/capture/} grep {$_ !~ m/shift/} grep {$_ !~ m/typ/} keys %num_Check_si;
my @drc_si_keys_sorted_by_num = sort {$num_Check_si{$b} <=> $num_Check_si{$a}} @DRC_SI_RUNS ;
my $si_filename = fileparse($drc_si_keys_sorted_by_num[0]);
print $HTML_FILE "<tr>\n";
print $HTML_FILE "<td style=\"font-weight: bold\">SI  bottleneck: </td>\n";
print $HTML_FILE "<td>\n";
print $HTML_FILE "Corner: $si_filename";
print $HTML_FILE "<br/>";
print $HTML_FILE "-Number of violations: $num_Check_si{$drc_si_keys_sorted_by_num[0]}";
print $HTML_FILE "<br/>";
print $HTML_FILE "-Worst violator: $sum_Check_si{$drc_si_keys_sorted_by_num[0]}->[0]";
print $HTML_FILE "<br/>";
print $HTML_FILE "-Worst violation: $sum_Check_si{$drc_si_keys_sorted_by_num[0]}->[1]";
print $HTML_FILE "</td>\n";
print $HTML_FILE "</tr>\n";


my @DRC_CLK_XTALK_RUNS = grep {$_ !~ m/capture/} grep {$_ !~ m/shift/} grep {$_ !~ m/typ/} keys %num_Check_clk_xtalk;
#my @DRC_CLK_XTALK_RUNS =  keys %num_Check_clk_xtalk;
#print "Debug: @DRC_CLK_XTALK_RUNS\n";
my @drc_clk_xtalk_keys_sorted_by_num = sort {$num_Check_clk_xtalk{$b} <=> $num_Check_clk_xtalk{$a}} @DRC_CLK_XTALK_RUNS ;
if ($#DRC_CLK_XTALK_RUNS > 0) {
my $siclk_filename = fileparse($drc_clk_xtalk_keys_sorted_by_num[0]);
} else {
my $siclk_filename = "";
}
if ($#DRC_CLK_XTALK_RUNS > 0) {
print $HTML_FILE "<tr>\n";
print $HTML_FILE "<td style=\"font-weight: bold\">Clk xtalk: </td>\n";
print $HTML_FILE "<td>\n";
print $HTML_FILE "Corner: $siclk_filename";
print $HTML_FILE "<br/>";
print $HTML_FILE "-Number of violations: $num_Check_clk_xtalk{$drc_clk_xtalk_keys_sorted_by_num[0]}";
print $HTML_FILE "<br/>";
print $HTML_FILE "-Worst violator: $sum_Check_clk_xtalk{$drc_clk_xtalk_keys_sorted_by_num[0]}->[0]";
print $HTML_FILE "<br/>";
print $HTML_FILE "-Worst violation: $sum_Check_clk_xtalk{$drc_clk_xtalk_keys_sorted_by_num[0]}->[1]";
print $HTML_FILE "</td>\n";
print $HTML_FILE "</tr>\n";
}

my @DRC_NOISE_RUNS = grep {$_ !~ m/capture/} grep {$_ !~ m/shift/} grep {$_ !~ m/typ/} keys %num_Check_noise;
my @drc_noise_keys_sorted_by_num = sort {$num_Check_noise{$b} <=> $num_Check_noise{$a}} @DRC_NOISE_RUNS ;
my $noise_filename = fileparse($drc_noise_keys_sorted_by_num[0]);
print $HTML_FILE "<tr>\n";
print $HTML_FILE "<td style=\"font-weight: bold\">Noise at endpoint: </td>\n";
print $HTML_FILE "<td>\n";
print $HTML_FILE "Corner: $noise_filename";
print $HTML_FILE "<br/>";
print $HTML_FILE "-Number of violations: $num_Check_noise{$drc_noise_keys_sorted_by_num[0]}";
print $HTML_FILE "<br/>";
print $HTML_FILE "-Number of violations above_low: $sum_Check_noise{$drc_noise_keys_sorted_by_num[0]}->[0]";
print $HTML_FILE "<br/>";
print $HTML_FILE "-Worst violator above_low: $sum_Check_noise{$drc_noise_keys_sorted_by_num[0]}->[1]";
print $HTML_FILE "<br/>";
print $HTML_FILE "-Number of violations below_high: $sum_Check_noise{$drc_noise_keys_sorted_by_num[0]}->[3]";
print $HTML_FILE "<br/>";
print $HTML_FILE "-Worst violator below_high: $sum_Check_noise{$drc_noise_keys_sorted_by_num[0]}->[4]";
print $HTML_FILE "<br/>";
print $HTML_FILE "-Number of violations below_low: $sum_Check_noise{$drc_noise_keys_sorted_by_num[0]}->[6]";
print $HTML_FILE "<br/>";
print $HTML_FILE "-Worst violator below_low: $sum_Check_noise{$drc_noise_keys_sorted_by_num[0]}->[7]";
print $HTML_FILE "<br/>";
print $HTML_FILE "-Number of violations above_high: $sum_Check_noise{$drc_noise_keys_sorted_by_num[0]}->[9]";
print $HTML_FILE "<br/>";
print $HTML_FILE "-Worst violator above_high: $sum_Check_noise{$drc_noise_keys_sorted_by_num[0]}->[10]";
print $HTML_FILE "<br/>";
print $HTML_FILE "</td>\n";
print $HTML_FILE "</tr>\n";

my @DRC_NOISE_DW_RUNS = grep {$_ !~ m/capture/} grep {$_ !~ m/shift/} grep {$_ !~ m/typ/} keys %num_Check_noise_double_switching;
my @drc_noise_dw_keys_sorted_by_num = sort {$num_Check_noise_double_switching{$b} <=> $num_Check_noise_double_switching{$a}} @DRC_NOISE_DW_RUNS ;
if ($#DRC_NOISE_DW_RUNS > 0) {
my $noise_dw_filename = fileparse($drc_noise_dw_keys_sorted_by_num[0]);
print $HTML_FILE "<tr>\n";
print $HTML_FILE "<td style=\"font-weight: bold\">Noise double switching: </td>\n";
print $HTML_FILE "<td>\n";
print $HTML_FILE "Corner: $noise_dw_filename";
print $HTML_FILE "<br/>";
print $HTML_FILE "-Number of violations: $num_Check_noise_double_switching{$drc_noise_dw_keys_sorted_by_num[0]}";
print $HTML_FILE "</td>\n";
print $HTML_FILE "</tr>\n";
}

my @NON_CTS_RUNS = grep {$_ !~ m/capture/} grep {$_ !~ m/shift/} grep {$_ !~ m/typ/} keys %num_Check_nonCTS;
my @non_cts_keys_sorted_by_num = sort {$num_Check_nonCTS{$b} <=> $num_Check_nonCTS{$a}} @NON_CTS_RUNS ;
print $HTML_FILE "<tr>\n";
print $HTML_FILE "<td style=\"font-weight: bold\">Non-CTS cells on Clock tree: </td>\n";
print $HTML_FILE "<td>\n";
print $HTML_FILE "-Error: Number of NonCTS cell: $num_Check_nonCTS{$non_cts_keys_sorted_by_num[0]}";
print $HTML_FILE "<br/>";
print $HTML_FILE "-Warning: Number of *uor*,*uxor* cell: $sum_Check_nonCTS{$non_cts_keys_sorted_by_num[0]}->[0]";
print $HTML_FILE "</td>\n";
print $HTML_FILE "</tr>\n";

my @MIN_PULSE_RUNS = grep {$_ !~ m/capture/} grep {$_ !~ m/shift/} grep {$_ !~ m/typ/} keys %num_Check_min_pulse;
my @min_pulse_keys_sorted_by_num = sort {$num_Check_min_pulse{$b} <=> $num_Check_min_pulse{$a}} @MIN_PULSE_RUNS ;
print $HTML_FILE "<tr>\n";
print $HTML_FILE "<td style=\"font-weight: bold\">Min_pulse_width: </td>\n";
print $HTML_FILE "<td>\n";
if ($num_Check_min_pulse{$min_pulse_keys_sorted_by_num[0]} == 0) {
	print $HTML_FILE "Clean";
} else {
	print $HTML_FILE "-Number of violations: $num_Check_min_pulse{$min_pulse_keys_sorted_by_num[0]}";
}
print $HTML_FILE "</td>\n";
print $HTML_FILE "</tr>\n";

my @MIN_PERIOD_RUNS = grep {$_ !~ m/capture/} grep {$_ !~ m/shift/} grep {$_ !~ m/typ/} keys %num_Check_min_period;
my @min_period_keys_sorted_by_num = sort {$num_Check_min_period{$b} <=> $num_Check_min_period{$a}} @MIN_PERIOD_RUNS ;
print $HTML_FILE "<tr>\n";
print $HTML_FILE "<td style=\"font-weight: bold\">min_period: </td>\n";
print $HTML_FILE "<td>\n";
if ($num_Check_min_period{$min_period_keys_sorted_by_num[0]} == 0) {
	print $HTML_FILE "Clean";
} else {
	print $HTML_FILE "-Number of violations: $num_Check_min_period{$min_period_keys_sorted_by_num[0]}";
}
print $HTML_FILE "</td>\n";
print $HTML_FILE "</tr>\n";


print $HTML_FILE "</table>\n";
print $HTML_FILE "<!-- send_mail -->\n";


my @CHECKED_STA_RUNS = grep {$_ =~ m/slow|fast|typ/} glob ("$STA_RUN_PATH/*");
print $HTML_FILE "<p> Spef Info <p>\n";

print $HTML_FILE "<button type=\"button\" onclick=\"document.getElementById(\'spef table\').style.display=\'none\'\">\n";
print $HTML_FILE "Hide Spef Table\n";
print $HTML_FILE "</button>\n";
print $HTML_FILE "<button type=\"button\" onclick=\"document.getElementById(\'spef table\').style.display=\'table\'\">\n";
print $HTML_FILE "Show Spef Table\n";
print $HTML_FILE "</button>\n";

print $HTML_FILE "<table id=\"spef table\" width=3550px border=\"1\";>\n";
print $HTML_FILE "<caption><em> Spef&Lib List </caption></em>\n";
print $HTML_FILE "<tr>\n";
print $HTML_FILE "<td width=420px>Corner Name: </td>\n";
print $HTML_FILE "<td width=1350px>Spef File Name</td>\n";
print $HTML_FILE "<td>First Standard Lib File Name</td>\n";
print $HTML_FILE "</tr>\n";


foreach (@CHECKED_STA_RUNS) {
	print $HTML_FILE "<tr>\n";
	my $co  = $_;
	my $filename = fileparse($co);
	#my $nelist   = `grep "set NETLIST" $STA_RUN_PATH/$filename/set_module.tcl | awk '{print \$3}'`
	#my $spef_dir = dirname($netlist)
	my $spef_name = `grep read_parasitics $STA_RUN_PATH/$filename/parasitics_command.log | awk '{print \$4}'`;
	my $db_name   = `less $STA_RUN_PATH/$filename/libs_used.rpt | awk '(NR == 4) {print \$2}'`;
	if ($db_name =~ m/(.*):(.*)/) {
		$db_name = $1;
	}
	print $HTML_FILE "<td width=420px>$filename </td>\n";
	print $HTML_FILE "<td>$spef_name</td>\n";
	print $HTML_FILE "<td>$db_name</td>\n";
	#print "$filename : $spef_name $db_name\n";
	print $HTML_FILE "</tr>\n";
}

print $HTML_FILE "</table>\n";
print $HTML_FILE "</div>\n";


print $HTML_FILE "<div class=\"ss\" id=\"vidoshow\">\n";
### Generate Clock Summary Table Of The Sta Run ###
### Generate Sanity Table Of The Sta Run ###
if (defined $STA_RUNS[0]) {
    print "\nGENERATING FUNCTIONAL TABLE\n";
    print $HTML_FILE "<p> Function Sanity Table: <p>\n";
    generate_sanity_table("Func", @STA_RUNS);
    
}

if (defined $STA_CAPTURE_RUNS[0]) {
    print "GENERATING CAPTURE TABLE\n";
    print $HTML_FILE "<p> Capture Scanity Table: <p>\n";
    generate_sanity_table("Capture", @STA_CAPTURE_RUNS);
}

if (defined $STA_SHIFT_RUNS[0]) {
    print "GENERATING SHIFT TABLE\n";
    print $HTML_FILE "<p> Shift Scanity Table: <p>\n";
    generate_sanity_table("Shift", @STA_SHIFT_RUNS);
}

print $HTML_FILE "<script language=\"JavaScript\">\n";
print $HTML_FILE "</script>\n";
#if ($error_flag > 0) {
#    print "\nSanity check FAILED.\n";
#    print $OUT_FILE2 "\nSanity check FAILED.\n";
#}
#else {
#    print "\nSanity check PASSED.\n";
#    print $OUT_FILE2 "\nSanity check PASSED.\n";
#}
#my %run_corners = ();

### Generate Timing Table Of The Sta Run ###
#print "corners debug: @STA_RUNS\n";
if ($REPORT_TIMING) {
    print "\n----------------------------------------\n";
    print "STA TIMING SUMMARY:\n";
    if (defined $STA_RUNS[0]) {
        print "\nFUNCTIONAL RUNS\n";

        print $HTML_FILE "<br/>\n";
        print $HTML_FILE "<br/>\n";
        print $HTML_FILE "<br/>\n";
	print $HTML_FILE "<div class=\"pp\">\n";
        print $HTML_FILE "<p align=\"left\">  Function Timing Table: </p>\n";
	print $HTML_FILE "</div>\n";
	#check_allv_timing_reports ("setup", $OUT_FILE2, @STA_RUNS);
	generate_timing_table("setup", "Func_Setup");
        print $HTML_FILE "<br/>\n";
	#print "================================== DEBUGGING =======================================";
	#%run_corners = ();
	#check_allv_timing_reports ("hold", $OUT_FILE2, @STA_RUNS);
	generate_timing_table("hold", "Func_Hold");
        print $HTML_FILE "<br/>\n";
	#%run_corners = ();
    }

    if (defined $STA_CAPTURE_RUNS[0]) {
        print "\nCAPTURE RUNS\n";
        print $HTML_FILE "<br/>\n";
        print $HTML_FILE "<br/>\n";
        print $HTML_FILE "<br/>\n";
	print $HTML_FILE "<div class=\"pp\">\n";
        print $HTML_FILE "<p align=\"left\">  Capture Timing Table: </p>\n";
	print $HTML_FILE "</div>\n";

	#check_allv_timing_reports ("setup", $OUT_FILE2, @STA_CAPTURE_RUNS);
	generate_timing_table("setup", "Capture_Setup");
        print $HTML_FILE "<br/>\n";
	#%run_corners = ();
	#check_allv_timing_reports ("hold", $OUT_FILE2, @STA_CAPTURE_RUNS);
	generate_timing_table("hold", "Capture_Hold");
        print $HTML_FILE "<br/>\n";
	#%run_corners = ();
    }

    if (defined $STA_SHIFT_RUNS[0]) {
        print "\nSHIFT RUNS\n";
	print $HTML_FILE "<div class=\"pp\">\n";
        print $HTML_FILE "<p> Shift Timing Table: <p>\n";
	print $HTML_FILE "</div>\n";

	#check_allv_timing_reports ("setup", $OUT_FILE2, @STA_SHIFT_RUNS);
	generate_timing_table("setup", "Shift_Setup");
        print $HTML_FILE "<br/>\n";
	#%run_corners = ();
	#check_allv_timing_reports ("hold", $OUT_FILE2, @STA_SHIFT_RUNS);
	generate_timing_table("hold", "Shift_Hold");
        print $HTML_FILE "<br/>\n";
	#%run_corners = ();
    }
}

print $HTML_FILE "<p> Collecting all info from : </p>\n";
print $HTML_FILE "<a href= \"$STA_RUN_PATH\"> $STA_RUN_PATH </a>";
print $HTML_FILE "</p>\n";

print $HTML_FILE "<script language=\"JavaScript\">\n";
print $HTML_FILE "document.write(\"The file is last modified on:&nbsp\" + document.lastModified)\n";
print $HTML_FILE "</script>\n";

print $HTML_FILE "</div>\n";
print $HTML_FILE "</div>\n";
print $HTML_FILE "<script language=\"JavaScript\">\n";
print $HTML_FILE "document.vlinkColor=\"660099\"\n";
print $HTML_FILE "document.linkColor=\"green\"\n";
print $HTML_FILE "document.alinkColor=\"000000\"\n";
print $HTML_FILE "</script>\n";
print $HTML_FILE "</body>\n";
print $HTML_FILE "</html>\n";


close $OUT_FILE;
close $OUT_FILE2;
close $HTML_FILE;

print "$OUT_FILE_PATH \n";
print "---------------------------------------------------\n";
print "---------------------------------------------------\n";
print "Please Check Html With: \n";
print "firefox $OUT_FILE_PATH/${collect_name}_sta_detail.html &\n";
print "---------------------------------------------------\n";
print "---------------------------------------------------\n";
#system("less $OUT_FILE_PATH/${collect_name}_sta_detail.html | grep -v Hide | grep -v Show | grep -B10000 send_mail | mutt \$USER\@synaptics.com -s \"Sta Result\" -e \'set content_type=\"text/html\"\' -a $OUT_FILE_PATH/${collect_name}_sta_detail.html");
system("less $OUT_FILE_PATH/${collect_name}_sta_detail.html | grep -v Hide | grep -v Show |  mutt \$USER\@synaptics.com -s \"Sta Result\" -e \'set content_type=\"text/html\"\' -a $OUT_FILE_PATH/${collect_name}_sta_detail.html");
#combine_reports ($OUT_FILE_PATH);
#====================================================================
# END OF PERL SCRIPT
#====================================================================


#====================================================================
# BEGIN SUB MODULES
#====================================================================
sub check_sanity_reports {

    my $error_flag = 0;
    my ($OUT_FILE, $OUT_FILE2, @STA_RUNS) = (@_) ;

    #run.log
    print "Checking run.log: ";
    #print $OUT_FILE2 "Checking run.log: ";
    #print $OUT_FILE "\n#run.log\n";
    #print $OUT_FILE "#---------------------------------------------------#";
    if (check_runlog ($OUT_FILE, @STA_RUNS) == 1) {
        $error_flag ++;
        print "- - - - - - - - - - - - - - - - Errors detected\n";
	#print $OUT_FILE2 "- - - - - - - - - - - - - - - - Errors detected\n";
    } else {
        print "- - - - - - - - - - - - - - - - Clean\n";
	#print $OUT_FILE2 "- - - - - - - - - - - - - - - - Clean\n";
    }

    #*_sdc.log
    my $result = check_sdclog ($OUT_FILE, $OUT_FILE2, @STA_RUNS);
    if ($result == 1) {
        $error_flag ++;
        print "- - - - - - - - - - - - - Errors detected\n";
	#print $OUT_FILE2 "- - - - - - - - - - - - - Errors detected\n";
    } elsif ($result == 0) {
        print "- - - - - - - - - - - - - Clean\n";
	#print $OUT_FILE2 "- - - - - - - - - - - - - Clean\n";
    }

    #parasitics_command report
        print "Checking parasitics_command.log: ";
	#print $OUT_FILE2 "Checking parasitics_command.log: ";
	#print $OUT_FILE "\n#REPORT parasitics_command\n";
	#print $OUT_FILE "#---------------------------------------------------#";
        if (check_RC ($OUT_FILE, @STA_RUNS) == 1) {
            $error_flag ++;
            print "- - - - - - - -  Errors detected\n";
	    #print $OUT_FILE2 "- - - - - - - -  Errors detected\n";
        } else {
            print "- - - - - - - -  Clean\n";
	    #print $OUT_FILE2 "- - - - - - - -  Clean\n";
        }
    
	#report/not_annotated_pin_to_pin_parasitics report
        print "Checking not_annotated_pin_to_pin_parasitics.rpt: ";
	#print $OUT_FILE2 "Checking not_annotated_pin_to_pin_parasitics.rpt: ";
	#print $OUT_FILE "\n#REPORT report/not_annotated_pin_to_pin_parasitics\n";
	#print $OUT_FILE "#---------------------------------------------------#";
        if (check_annotated ($OUT_FILE, @STA_RUNS) == 1) {
            $error_flag ++;
            print "Errors detected\n";
	    #print $OUT_FILE2 "Errors detected\n";
        } else {
            print "Clean\n";
	    #print $OUT_FILE2 "Clean\n";
        }
    
	##report/not_annotated_cell_pocv_* report
	print "Checking not_annotated_cell_pocv.rpt: ";
	##print $OUT_FILE2 "Checking not_annotated_cell_pocv.rpt: ";
	##print $OUT_FILE "\n#REPORT report/not_annotated_cell_pocv\n";
	##print $OUT_FILE "#---------------------------------------------------#";
        if (check_annotated_pocv ($OUT_FILE, @STA_RUNS) == 1) {
            $error_flag ++;
            print "- - - - - - Errors detected\n";
	    #print $OUT_FILE2 "- - - - - - Errors detected\n";
        } else {
            print "- - - - - - Clean\n";
	    #print $OUT_FILE2 "- - - - - - Clean\n";
        }
    
        #report/checkConstraints report
        print "Checking checkConstraints.rpt: ";
	#print $OUT_FILE2 "Checking checkConstraints.rpt: ";
	#print $OUT_FILE "\n#REPORT report/checkConstraints.rpt\n";
	#print $OUT_FILE "#---------------------------------------------------#";
        if (check_constraint ($OUT_FILE, @STA_RUNS) == 1) {
            $error_flag ++;
            print "- - - - - - - - - -Errors detected\n";
	    #print $OUT_FILE2 "- - - - - - - - - -Errors detected\n";
        } else {
            print "- - - - - - - - - -Clean\n";
	    #print $OUT_FILE2 "- - - - - - - - - -Clean\n";
        }
    
	#report/$MODULE_NAME_checkTiming report
	    print "Checking checkTiming.rpt: ";
	    #print $OUT_FILE2 "Checking checkTiming.rpt: ";
	    #print $OUT_FILE "\n#REPORT report/checkTiming\n";
	    #print $OUT_FILE "#---------------------------------------------------#";
    	    if (check_timing_report ($OUT_FILE, @STA_RUNS) == 1) {
    	        $error_flag ++;
    	        print "- - - - - - - - - - - - Errors detected\n";
		#print $OUT_FILE2 "- - - - - - - - - - - - Errors detected\n";
    	    } else {
    	        print "- - - - - - - - - - - - Clean\n";
		#print $OUT_FILE2 "- - - - - - - - - - - - Clean\n";
    	    }
    	
        #report/$MODULE_NAME_noClk report
        print "Checking noClk.rpt: ";
	#print $OUT_FILE2 "Checking noClk.rpt: ";
	#print $OUT_FILE "\n#REPORT report/noClk\n";
	#print $OUT_FILE "#---------------------------------------------------#";
        $result = noclk_report ($OUT_FILE, @STA_RUNS);
        if ($result == 1) {
            $error_flag ++;
            print "- - - - - - - - - - - - - - - Errors detected\n";
	    #print $OUT_FILE2 "- - - - - - - - - - - - - - - Errors detected\n";
        } elsif ($result == 2) {
            print "- - - - - - - - - - - - - - - Warnings detected\n";
	    #print $OUT_FILE2 "- - - - - - - - - - - - - - - Warnings detected\n";
        } else {
            print "- - - - - - - - - - - - - - - Clean\n";
	    #print $OUT_FILE2 "- - - - - - - - - - - - - - - Clean\n";
        }
    
	#clkTransition report
	print "Checking clkTransition.rpt: ";
	#print $OUT_FILE2 "Checking clkTransition.rpt: ";
	#print $OUT_FILE "\n#REPORT report/clkTransition\n";
	#print $OUT_FILE "#---------------------------------------------------#";
	if (check_clktransition ($OUT_FILE, @STA_RUNS) == 1) {
	    $error_flag ++;
	    print "- - - - - - - - - - - Errors detected\n";
	    #print $OUT_FILE2 "- - - - - - - - - - - Errors detected\n";
	} else {
	    print "- - - - - - - - - - - Clean\n";
	    #print $OUT_FILE2 "- - - - - - - - - - - Clean\n";
	}
    
        #report/drc_transition report
        print "Checking drc_transition_valid.rpt: ";
	#print $OUT_FILE2 "Checking drc_transition_valid.rpt: ";
	#print $OUT_FILE "\n#REPORT report/drc_transition_valid\n";
	#print $OUT_FILE "#---------------------------------------------------#";
        $result = check_transition ($OUT_FILE, "data", @STA_RUNS);
        if ($result == 1) {
            $error_flag ++;
            print "- - - - - - -  Errors detected\n";
	    #print $OUT_FILE2 "- - - - - - -  Errors detected\n";
        } elsif ($result == 2) {
            print "- - - - - - -  Warnings detected\n";
	    #print $OUT_FILE2 "- - - - - - -  Warnings detected\n";
        } else {
            print "- - - - - - -  Clean\n";
	    #print $OUT_FILE2 "- - - - - - -  Clean\n";
        }
    
        #report/drc_capacitance report
        print "Checking drc_capacitance_valid.rpt: ";
	#print $OUT_FILE2 "Checking drc_capacitance_valid.rpt: ";
	#print $OUT_FILE "\n#REPORT report/drc_capacitance_valid\n";
	#print $OUT_FILE "#---------------------------------------------------#";
        if (check_transition ($OUT_FILE, "cap", @STA_RUNS) == 1) {
            $error_flag ++;
            print "- - - - - - - Errors detected\n";
	    #print $OUT_FILE2 "- - - - - - - Errors detected\n";
        } else {
            print "- - - - - - - Clean\n";
	    #print $OUT_FILE2 "- - - - - - - Clean\n";
        }
    
        #report/report_si_bottleneck report
	    print "Checking report_si_bottleneck.rpt: ";
        print $OUT_FILE2 "Checking report_si_bottleneck.rpt: ";
        print $OUT_FILE "\n#REPORT report/report_si_bottleneck\n";
        print $OUT_FILE "#---------------------------------------------------#";
         if (check_si ($OUT_FILE, "max.rpt|min.rpt", @STA_RUNS) == 1) {
             $error_flag ++;
             print "- - - - - - - -Errors detected\n";
             print $OUT_FILE2 "- - - - - - - -Errors detected\n";
         } else {
             print "- - - - - - - -Clean\n";
             print $OUT_FILE2 "- - - - - - - -Clean\n";
         }
    
        #report/report_si_bottleneck report
        print "Checking report_si_bottleneck_with_clock.rpt: ";
        print $OUT_FILE2 "Checking report_si_bottleneck_with_clock.rpt: ";
        print $OUT_FILE "\n#REPORT report/report_si_bottleneck_with_clock\n";
        print $OUT_FILE "#---------------------------------------------------#";
        if (check_si ($OUT_FILE, "with_clock", @STA_RUNS) == 1) {
            $error_flag ++;
            print "- - Errors detected\n";
            print $OUT_FILE2 "- - Errors detected\n";
        } else {
            print "- - - - - - - -Clean\n";
            print $OUT_FILE2 "- - - - - - - -Clean\n";
        }
    
    
        #report/clk_xtalk.rpt
        print "Checking clk_xtalk.rpt: ";
        print $OUT_FILE2 "Checking clk_xtalk.rpt: ";
        print $OUT_FILE "\n#REPORT report/clk_xtalk\n";
        print $OUT_FILE "#---------------------------------------------------#";
        if (check_clk_xtalk ($OUT_FILE, @STA_RUNS) == 1) {
            $error_flag ++;
            print "- - - - - - - - - - - - - Errors detected\n";
            print $OUT_FILE2 "- - - - - - - - - - - - - Errors detected\n";
        } else {
            print "- - - - - - - -Clean\n";
            print $OUT_FILE2 "- - - - - - - -Clean\n";
        }
    
    
        #report/
        print "Checking noise_at_end_point.rpt";
        print $OUT_FILE2 "Checking noise_at_end_point.rpt";
        print $OUT_FILE "\n#REPORT report/noise_at_end_point.rpt\n";
        print $OUT_FILE "#---------------------------------------------------#";
        if (check_noise ($OUT_FILE, "noise", @STA_RUNS) == 1) {
            $error_flag ++;
            print "- - - - - - - - - -Errors detected\n";
            print $OUT_FILE2 "- - - - - - - - - -Errors detected\n";
        } else {
            print "- - - - - - - -- - Clean\n";
            print $OUT_FILE2 "- - - - - - - - - -Clean\n";
        }
    
        #report/noise_double_switching.rpt
        print "Checking noise_double_switching.rpt";
        print $OUT_FILE2 "Checking noise_double_switching.rpt";
        print $OUT_FILE "\n#REPORT report/noise_double_switching.rpt\n";
        print $OUT_FILE "#---------------------------------------------------#";
        if (check_noise_double_switching ($OUT_FILE, "noise_double_switching,rpt", @STA_RUNS) == 1) {
            $error_flag ++;
            print "- - - - - - - -Errors detected\n";
            print $OUT_FILE2 "- - - - - - - -Errors detected\n";
        } else {
            print "- - - - - - - -Clean\n";
            print $OUT_FILE2 "- - - - - - - -Clean\n";
        }
    
        #report/noise_double_switching_on_clock.rpt
        print "Checking noise_double_switching_on_clock.rpt";
        print $OUT_FILE2 "Checking noise_double_switching_on_clock.rpt";
        print $OUT_FILE "\n#REPORT report/noise_double_switching_on_clock.rpt\n";
        print $OUT_FILE "#---------------------------------------------------#";
        if (check_noise_double_switching ($OUT_FILE, "noise_double_switching_on_clock", @STA_RUNS) == 1) {
            $error_flag ++;
            print "- - - Errors detected\n";
            print $OUT_FILE2 "- - - Errors detected\n";
        } else {
            print "- - - Clean\n";
            print $OUT_FILE2 "- - - Clean\n";
        }
    
    
        #report/NonCTSCell.rpt
        print "Checking NonCTSCell.rpt";
        print $OUT_FILE2 "Checking NonCTSCell.rpt";
        print $OUT_FILE "\n#REPORT NonCTSCell.rpt\n";
        print $OUT_FILE "#---------------------------------------------------#";
        $result = check_nonCTS ($OUT_FILE, "NonCTSCell", @STA_RUNS);
        if ($result == 1) {
            $error_flag ++;
            print "- - - - - - - - - - - - - -Errors detected\n";
            print $OUT_FILE2 "- - - - - - - - - - - - - -Errors detected\n";
        } elsif ($result == 2) {
            print "- - - - - - - - - - - - - -Warnings detected\n";
            print $OUT_FILE2 "- - - - - - - - - - - - - -Warnings detected\n";
        } else {
            print "- - - - - - - - - - - - - -Clean\n";
            print $OUT_FILE2 "- - - - - - - - - - - - - -Clean\n";
        }
    
        #report/clkTransition_noneClkBufList.rpt
        print "Checking clkTransition_noneClkBufList.rpt";
        print $OUT_FILE2 "Checking clkTransition_noneClkBufList.rpt";
        print $OUT_FILE "\n#REPORT clkTransition_noneClkBufList.rpt\n";
        print $OUT_FILE "#---------------------------------------------------#";
        $result = check_clkTranNoneClkBuf ($OUT_FILE, "noneClkBufList", @STA_RUNS);
        if ($result == 1) {
            $error_flag ++;
            print " - - - - Errors detected\n";
            print $OUT_FILE2 " - - - - Errors detected\n";
        } else {
            print "- - - - -Clean\n";
            print $OUT_FILE2 "- - - - -Clean\n";
        }
    
    
    
        #report/allv_min_pulse_width report
        print "Checking allv_min_pulse_width.rpt: ";
        print $OUT_FILE2 "Checking allv_min_pulse_width.rpt: ";
        print $OUT_FILE "\n#REPORT report/allv_min_pulse_width\n";
        print $OUT_FILE "#---------------------------------------------------#";
        if (check_min_pulse ($OUT_FILE, "pulse", @STA_RUNS) == 1) {
            $error_flag ++;
            print "- - - - - - -  Errors detected\n";
            print $OUT_FILE2 "- - - - - - -  Errors detected\n";
        } else {
            print "- - - - - - -  Clean\n";
            print $OUT_FILE2 "- - - - - - -  Clean\n";
        }
    
        #report/allv_min_period report
        print "Checking allv_min_period.rpt: ";
        print $OUT_FILE2 "Checking allv_min_period.rpt: ";
        print $OUT_FILE "\n#REPORT report/allv_min_period\n";
        print $OUT_FILE "#---------------------------------------------------#";
        if (check_min_pulse ($OUT_FILE, "period", @STA_RUNS) == 1) {
            $error_flag ++;
            print "- - - - - - - - - - Errors detected\n";
            print $OUT_FILE2 "- - - - - - - - - - Errors detected\n";
        } else {
            print "- - - - - - - - - - Clean\n";
            print $OUT_FILE2 "- - - - - - - - - - Clean\n";
        }
    
        return $error_flag;
} #sub check_sanity_reports



sub check_allv_timing_reports {

    my ($run_type, $OUT_FILE, @STA_RUNS) = (@_);

    my @TEMP_STA_RUNS = @STA_RUNS;
    
    foreach (@TEMP_STA_RUNS) {
        my $STA_RUN = $_;
        my $filename = fileparse($STA_RUN); #extracting directory name from full path
	my  @v_rpt_list = glob("$STA_RUN/report/allv_*.rpt");
	#print "@v_rpt_list\n";
	my $rpt;
	foreach $rpt (@v_rpt_list) {
	    my $rpt_type;
	    my $a_mode;
	    my $b_mode;
	    my $ex;
	    if ($rpt =~ m/allv_($run_type)_(gba|pba)(_exh|_path)*\.rpt/) {
	    	$rpt_type = $1;
		$a_mode = $2;
		$ex = $3;
		if ($rpt_type =~ m/setup/) { $b_mode = "max";} else { $b_mode = "min";}
	    my @group_sorted_by_line;
            if ($STA_RUN =~ m/(slow|fast|typ)(.*)(_|\.)/) { #looking for slow corner
		print "Checking allv*.rpt of $run_type in : ";
		print "$filename/report/allv_${rpt_type}_${a_mode}$ex.rpt: \n";
                print $OUT_FILE "$filename/report/allv_${rpt_type}_${a_mode}$ex.rpt: \n";
                my $length = length("$filename/report/allv_${rpt_type}_${a_mode}$ex.rpt: ");
		my %path_group = ();
		if (defined($run_corners{$filename})) {
			#print "$filename data has already been established\n";
			$run_corners{$filename}->{$rpt_type} = \%path_group;
		} else {
			my %check_type = ();
			$check_type{$rpt_type} = \%path_group;
			$run_corners{$filename} = \%check_type;
		}
                if (open (LOGFILE, "$STA_RUN/report/allv_${rpt_type}_${a_mode}$ex.rpt")) {
                    my $REPORT_IS_CLEAN = 1;
		    my $line_control = -1;
                    while (<LOGFILE>) {
			$line_control ++;	
			#if ($filename =~ m/setup/) {
			#print "$line_control \n";
			#}
			my $line = $_;
			#print "$line\n";
                        if ($line =~ m/${b_mode}_delay.*\((.*) group\)/) {
				#print "find violated group\n";
		    		my @info = [];
				$info[0] = $line_control;
				$info[1] = 0;
				$run_corners{$filename}->{$rpt_type}->{$1} = \@info ;
				$run_corners{$filename}->{$rpt_type}->{$1}->[0] = $line_control ;
				#print "$run_corners{$filename}->{$rpt_type}->{$1}->[0]\n";
					
			}
		    }
		    my %groups_info = %{$run_corners{$filename}->{$rpt_type}};
		    @group_sorted_by_line = sort {$groups_info{$a}->[0] <=> $groups_info{$b}->[0]} keys %groups_info;
	        }

                } else {
                    print " Unable to open file: $STA_RUN/report/allv_${rpt_type}_${a_mode}$ex.rpt\n";
                    print $OUT_FILE " Unable to open file: $STA_RUN/report/allv_${rpt_type}_${a_mode}$ex.rpt\n"
                }
                close LOGFILE;
                my @all_v_lines; 	
		if (open (LOGFILE, "$STA_RUN/report/allv_${rpt_type}_${a_mode}$ex.rpt")) {
			@all_v_lines = <LOGFILE>;
		} else {
			print " Unable to open file: $STA_RUN/report/allv_${rpt_type}_${a_mode}$ex.rpt\n";
		}
		close LOGFILE;
		my $num;
		#print "@group_sorted_by_line \n";
		for( $num = 0; $num <= $#group_sorted_by_line; $num = $num + 1 ) {
			my $group_counter = $num + 1;
			if ($num == $#group_sorted_by_line) {
				#print "Total Groups: $group_counter\n\n";
			}
			my $worst_violation;
			my $group_name = $group_sorted_by_line[$num];
			#print "Debug: $group_name\n";
			my $worst_violation_line = $run_corners{$filename}->{$rpt_type}->{$group_name}->[0] + 5;
			my $next_group_name = $group_sorted_by_line[$num + 1];
			my $next_group_line;
			if (defined($next_group_name)) {
				$next_group_line = $run_corners{$filename}->{$rpt_type}->{$next_group_name}->[0];
			} else {
				$next_group_line = $#all_v_lines - 2;
			}
			if ($all_v_lines[$worst_violation_line] =~ m/^   .*\s+(-.*) +\(VIOLATED/) {
				$worst_violation = $1;
				#print "$worst_violation\n";
			}
			my $line_num;
			my $total_violation = 0;
			for( $line_num = $worst_violation_line ; $line_num <= $next_group_line; $line_num = $line_num + 1 ) {
				if ($all_v_lines[$line_num] =~ m/^   .*\s+(-.*) +\(VIOLATED/) {
					$total_violation = $total_violation + $1;
				}
			}
			#print "$total_violation\n";
			#print "Group name:$group_name\n";
			#print "Worst Violation: $worst_violation\n";
			#print "Total Violation: $total_violation\n";
			$run_corners{$filename}->{$rpt_type}->{$group_name}->[1] = $next_group_line - $worst_violation_line - 1;
			$run_corners{$filename}->{$rpt_type}->{$group_name}->[2] = $worst_violation;
			$run_corners{$filename}->{$rpt_type}->{$group_name}->[3] = $total_violation;
		}
		
	
	}		
       }
       #print "Finish allv*rpt $run_type Check in Corner $filename \n";	
      }
    
} #sub check_allv_timing_reports

sub check_sum_timing_reports {

    my ($run_type, @STA_RUNS) = (@_);

    my @TEMP_STA_RUNS = @STA_RUNS;
    
    foreach (@TEMP_STA_RUNS) {
        my $STA_RUN = $_;
	my $filename = fileparse($STA_RUN); #extracting directory name from full path
	my  @v_rpt_list = glob("$STA_RUN/report/allv_*.rpt");
	my $setup_WNS = 0;
	my $setup_TNS = 0;
	my $setup_NVP = 0;
	my $hold_WNS = 0;
	my $hold_TNS = 0;
	my $hold_NVP = 0;
	my @filter_io_groups;
	print "Checking summary of $run_type in corner: $STA_RUN\n";
	my @info;
	@run_types = split(/\s+/, $run_type);
	foreach my $type (@run_types) {
		my @path_groups = keys %{$run_corners{$filename}->{$type}};
	
	        @filter_io_groups = grep {$_ !~ m/in2out/} grep {$_ !~ m/reg2out/} grep {$_ !~ m/io_/} grep {$_ !~ m/Reg2Out/} grep {$_ !~ m/In2Reg/} grep {$_ !~ m/input2reg/} @path_groups ;
		foreach my $grp (@filter_io_groups) {
			if ($type =~ m/setup/) {
				$setup_TNS = $setup_TNS + $run_corners{$filename}->{$type}->{$grp}->[3]; 
				$setup_NVP = $setup_NVP + $run_corners{$filename}->{$type}->{$grp}->[1]; 
				if ($run_corners{$filename}->{$type}->{$grp}->[2] < $setup_WNS) {$setup_WNS = $run_corners{$filename}->{$type}->{$grp}->[2]; }
			} else {
				$hold_TNS = $hold_TNS + $run_corners{$filename}->{$type}->{$grp}->[3]; 
				$hold_NVP = $hold_NVP + $run_corners{$filename}->{$type}->{$grp}->[1]; 
				if ($run_corners{$filename}->{$type}->{$grp}->[2] < $hold_WNS) {$hold_WNS = $run_corners{$filename}->{$type}->{$grp}->[2]; }
			}
		}
	}
	$sum_corners{$filename} = \@info;
	$sum_corners{$filename}->[0] = $setup_WNS;
	$sum_corners{$filename}->[1] = $setup_TNS;
	$sum_corners{$filename}->[2] = $setup_NVP;
	$sum_corners{$filename}->[3] = $hold_WNS;
	$sum_corners{$filename}->[4] = $hold_TNS;
	$sum_corners{$filename}->[5] = $hold_NVP;
	
      }
    
} #check_sum_timing_report
                    
sub print_formatting {
    my ($OUT_FILE, $LENGTH_FILE_NAME) = (@_);

    if ($LENGTH_FILE_NAME < 66) {
        my $LENGTH_TO_PRINT = 66 - $LENGTH_FILE_NAME;
        my $PRINT_DASH = 1;

        while ($LENGTH_TO_PRINT > 0) {

            if ($PRINT_DASH) {
                print "-";
                print $OUT_FILE "-";
                $PRINT_DASH = 0;
            } else {
                print " ";
                print $OUT_FILE " ";
                $PRINT_DASH = 1;
            }
            $LENGTH_TO_PRINT = $LENGTH_TO_PRINT - 1;
        }
    }
} #sub print_formatting

sub check_runlog {
    my $error_flag = 0;
    my ($OUT_FILE, @STA_RUNS) = (@_);
    my @LOG_LOG_FILENAME;

    foreach (@STA_RUNS) {
        my $STA_RUN = $_;

        $num_Check_runlog{$STA_RUN} = 0;
        if (open (LOGFILE, "$STA_RUN/run.log")) { #checking if file has opened successfully
            my $LNK_warnings = 0;
            my $UITE_136_warnings = 0;
            my $UITE_137_warnings = 0;
            my $SEL_warnings = 0;
            my $PARA_error = 0;
            my $UITE_318_warnings = 0;
            my $ADVLicence_warnings = 0;
            my $PTE_084_warnings = 0;

            my $filename = fileparse($STA_RUN); #extracting directory name from full path

            print $OUT_FILE "\nChecking $filename\n";
            while (<LOGFILE>) {
                if ($_ !~ m/^\#/) {
                    $LNK_warnings = 1 if ($_ =~ m/\(LNK-005\)/);
                    $UITE_136_warnings = 1 if ($_ =~ m/\(UITE-136\)/);
                    $UITE_137_warnings = 1 if ($_ =~ m/\(UITE-137\)/);
                    $SEL_warnings = 1 if ($_ =~ m/\(SEL-005\)/);
                    $PARA_error = 1 if ($_ =~ m/\(PARA-001\)/);
                    $UITE_318_warnings = 1 if ($_ =~ m/\(UITE-318\)/);
                    $ADVLicence_warnings = 1 if ($_ =~m/PT-010/);
                    $PTE_084_warnings = 1 if ($_ =~ m/\(PTE-084\)/);
                }
            }

            if ($LNK_warnings == 0 and $UITE_137_warnings == 0 and $UITE_136_warnings == 0 and $SEL_warnings == 0 and $PARA_error == 0 and $UITE_318_warnings == 0 and $ADVLicence_warnings == 0 and $PTE_084_warnings == 0) {
                print $OUT_FILE "\t-Clean\n";
		$Check_runlog{$STA_RUN} = 0;
            } else {
                print $OUT_FILE "\t-LNK-005 Error Found\n" if ($LNK_warnings);
                print $OUT_FILE "\t-UITE-136 Error Found\n" if ($UITE_136_warnings);
                print $OUT_FILE "\t-UITE-137 Error Found\n" if ($UITE_137_warnings);
                print $OUT_FILE "\t-SEL-005 Error Found\n" if ($SEL_warnings);
                print $OUT_FILE "\t-PARA-001 Error Found\n" if ($PARA_error);
                print $OUT_FILE "\t-UITE-318 Error Found\n" if ($UITE_318_warnings);
                print $OUT_FILE "\t-PT-010 Error Found\n" if ($ADVLicence_warnings);
                print $OUT_FILE "\t-PTE-084 Error Found\n" if ($PTE_084_warnings);
		$num_Check_runlog{$STA_RUN} = $num_Check_runlog{$STA_RUN} + 1  if ($LNK_warnings);
                $num_Check_runlog{$STA_RUN} = $num_Check_runlog{$STA_RUN} + 1  if ($UITE_136_warnings);
                $num_Check_runlog{$STA_RUN} = $num_Check_runlog{$STA_RUN} + 1  if ($UITE_137_warnings);
                $num_Check_runlog{$STA_RUN} = $num_Check_runlog{$STA_RUN} + 1  if ($SEL_warnings);
                $num_Check_runlog{$STA_RUN} = $num_Check_runlog{$STA_RUN} + 1  if ($PARA_error);
                $num_Check_runlog{$STA_RUN} = $num_Check_runlog{$STA_RUN} + 1  if ($UITE_318_warnings);
                $num_Check_runlog{$STA_RUN} = $num_Check_runlog{$STA_RUN} + 1  if ($ADVLicence_warnings);
                $num_Check_runlog{$STA_RUN} = $num_Check_runlog{$STA_RUN} + 1  if ($PTE_084_warnings);


                $error_flag = 1;
		$Check_runlog{$STA_RUN} = 1;
            }

            close LOGFILE;
        } else { #if file not opened, print error message and continue with analyzing other reports
            print $OUT_FILE "\nError: Cannot open $STA_RUN/run.log\n";
            $error_flag = 1;
	    $Check_runlog{$STA_RUN} = 2;
            next;
        }

        opendir DIR, "$STA_RUN/log";
        @LOG_LOG_FILENAME = grep (/.*\.log$/, readdir DIR);
        closedir DIR;

        foreach (@LOG_LOG_FILENAME) {
            my $FILE_NAME = $_;
            #print $FILE_NAME ;

            if (open (LOGFILE, "$STA_RUN/log/$FILE_NAME")) { #checking if file has opened successfully
                my $LNK_warnings = 0;
                my $UITE_136_warnings = 0;
                my $UITE_137_warnings = 0;
                my $SEL_warnings = 0;
                my $PARA_error = 0;
                my $UITE_318_warnings = 0;
                my $ADVLicence_warnings = 0;
                my $PTE_084_warnings = 0;

                #my $filename = fileparse($STA_RUN); #extracting directory name from full path
                #print $FILE_NAME;

                print $OUT_FILE "\nChecking $FILE_NAME\n";

                while (<LOGFILE>) {
                    if ($_ !~ m/^\#/) {
                        $LNK_warnings = 1 if ($_ =~ m/\(LNK-005\)/);
                        $UITE_136_warnings = 1 if ($_ =~ m/\(UITE-136\)/);
                        $UITE_137_warnings = 1 if ($_ =~ m/\(UITE-137\)/);
                        $SEL_warnings = 1 if ($_ =~ m/\(SEL-005\)/);
                        $PARA_error = 1 if ($_ =~ m/\(PARA-001\)/);
                        $UITE_318_warnings = 1 if ($_ =~ m/\(UITE-318\)/);
                        $ADVLicence_warnings = 1 if ($_ =~m/PT-010/);
                        $PTE_084_warnings = 1 if ($_ =~ m/\(PTE-084\)/);
                    }
                }

                if ($LNK_warnings == 0 and $UITE_137_warnings == 0 and $UITE_136_warnings == 0 and $SEL_warnings == 0 and $PARA_error == 0 and $UITE_318_warnings == 0 and $ADVLicence_warnings == 0 and $PTE_084_warnings = 0) {
                    print $OUT_FILE "\t-Clean\n";
                } else {
                    print $OUT_FILE "\t-LNK-005 Error Found\n" if ($LNK_warnings);
                    print $OUT_FILE "\t-UITE-136 Error Found\n" if ($UITE_136_warnings);
                    print $OUT_FILE "\t-UITE-137 Error Found\n" if ($UITE_137_warnings);
                    print $OUT_FILE "\t-SEL-005 Error Found\n" if ($SEL_warnings);
                    print $OUT_FILE "\t-PARA-001 Error Found\n" if ($PARA_error);
                    print $OUT_FILE "\t-UITE-318 Error Found\n" if ($UITE_318_warnings);
                    print $OUT_FILE "\t-PT-010 Error Found\n" if ($ADVLicence_warnings);
                    print $OUT_FILE "\t-PTE-084 Error Found\n" if ($PTE_084_warnings);

                    $error_flag = 1;
                }

                close LOGFILE;
            } else { #if file not opened, print error message and continue with analyzing other reports
                print $OUT_FILE "\nError: Cannot open $STA_RUN/log/$FILE_NAME\n";
                $error_flag = 1;
                next;
            }
        }
    }

    return $error_flag;
} #sub check_runlog

sub check_sdclog {

    my $error_flag = 2; #if error_flag == 2, it means that no sdc.log files were found
    my ($OUT_FILE, $OUT_FILE2, @STA_RUNS) = (@_);
    my $PRINTED_MESSAGE = 0;
    my @SDC_LOG_FILENAME;

    foreach (@STA_RUNS) {
        my $STA_RUN = $_;

        opendir DIR, "$STA_RUN";
        @SDC_LOG_FILENAME = grep (/.+_sdc\.log$/, readdir DIR);
        closedir DIR;

        if (defined $SDC_LOG_FILENAME[0]) {
            if (!$PRINTED_MESSAGE) {
                print "Checking sdc.log files: ";
                print $OUT_FILE2 "Checking sdc.log files: ";
                print $OUT_FILE "\n#sdc.log files#\n";
                print $OUT_FILE "#---------------------------------------------------#";
                $PRINTED_MESSAGE = 1;
            }

            my $STA_run_name = fileparse($STA_RUN); #extracting directory name from full path
            print $OUT_FILE "\nChecking $STA_run_name\n";
        }

        foreach (@SDC_LOG_FILENAME) {
            my $FILE_NAME = $_;

            $error_flag = 0 if ($error_flag == 2); #set error_flag = 0, which means that sdc file is found

            if (open (LOGFILE, "$STA_RUN/$FILE_NAME")) { #checking if file has opened successfully

                my $LNK_warnings = 0;
                my $UITE_136_warnings = 0;
                my $UITE_137_warnings = 0;
                my $SEL_warnings = 0;
                my $PARA_error = 0;
                my $UITE_318_warnings = 0;
                my $PTE_084_warnings = 0;

                print $OUT_FILE "\t-$FILE_NAME: ";
		
                while (<LOGFILE>) {
                    if ($_ !~ m/^\#/) {
                        $LNK_warnings = 1 if ($_ =~ m/LNK-005/);
                        $UITE_136_warnings = 1 if ($_ =~ m/UITE-136/);
                        $UITE_137_warnings = 1 if ($_ =~ m/UITE-137/);
                        $SEL_warnings = 1 if ($_ =~ m/SEL-005/);
                        $PARA_error = 1 if ($_ =~ m/PARA-001/);
                        $UITE_318_warnings = 1 if ($_ =~ m/UITE-318/);
                        $PTE_084_warnings = 1 if ($_ =~ m/PTE-084/);
                    }
                }

                if ($LNK_warnings == 0 and $UITE_137_warnings == 0 and $UITE_136_warnings == 0 and $SEL_warnings == 0 and $PARA_error == 0 and $UITE_318_warnings == 0 and $PTE_084_warnings == 0) {
                    print $OUT_FILE "Clean\n";
		    $Check_sdclog{$STA_RUN} = 0;
                } else {
                    my @ERROR_ARY;
                    push (@ERROR_ARY, "LNK-005") if ($LNK_warnings);
                    push (@ERROR_ARY, "UITE-136") if ($UITE_136_warnings);
                    push (@ERROR_ARY, "UITE-137") if ($UITE_137_warnings);
                    push (@ERROR_ARY, "SEL-005") if ($SEL_warnings);
                    push (@ERROR_ARY, "PARA-001") if ($PARA_error);
                    push (@ERROR_ARY, "UITE-318") if ($UITE_318_warnings);
                    push (@ERROR_ARY, "PTE-084") if ($PTE_084_warnings);

                    print $OUT_FILE join(", ", @ERROR_ARY);
                    print $OUT_FILE " error(s) found\n";
	            	
		    $Check_sdclog{$STA_RUN} = 1;
                    $error_flag = 1;
                }
                close LOGFILE;
            }
        }
    }
    return $error_flag;
} #sub check_sdclog

sub check_RC {

    my $error_flag = 0;
    my ($OUT_FILE, @STA_RUNS) = (@_);

    foreach (@STA_RUNS) {
        my $STA_RUN = $_;
        my $RC_VALID = 0;

        #get correct RC name from directory name
        my $RC_NAME_FROM_DIR;
        my $filename = fileparse($STA_RUN);
        my @parse_arg_Ary =  split (/_|\./, $filename); #format assumed: <module>.<STA_corner>_<RC>

        foreach (@parse_arg_Ary) {
            my $argument = $_;
        if ($argument =~ /^(rcbest(0|n40|m40|125|105)|cbest(0|n40|m40|105|125)|rcworst(0|125|n40|m40|105)|rcworstt(0|125|n40|m40)|cworstt(0|125|n40|m40)|cworst(0|n40|m40|125|105)|c?typical(2|8)5)$/i) {
                $RC_NAME_FROM_DIR = $argument;
                $RC_VALID = 1;
                last;
            }
        }

        if ($RC_VALID) {
            if (open (REPORT, "$STA_RUN/parasitics_command.log")) {
                my $RC_not_correct = 0;
                my $RC_NAME;

                print $OUT_FILE "\nChecking $filename\n";

                while (<REPORT>) {
                    #look for line starting with word 'Report' to find the name of RC being used
                    if ($_ =~ m/^Report/) {
                        my ($TEMP, $TEMP2, $TEMP3, $RC_WITH_PATH) = split(/\s+/);
                        my $RC_NAME_IN_REPORT = basename($RC_WITH_PATH);

                        my $RC_CHECK_REGEXP;

                        #special cases where temperature as well as the RC name is needed to check if RC is correct
                        if ($RC_NAME_FROM_DIR =~ m/r?cworstn40/i) { #cworstn40
                            $RC_CHECK_REGEXP = "((cworst.*(n40|m40|-40))|(slow.*(n40|m40|-40)))";
                        } elsif ($RC_NAME_FROM_DIR =~ m/r?cworsttn40/i) { #cworstn40
                            $RC_CHECK_REGEXP = "((cworst.*_T.*(n40|m40|-40))|(slow.*_T.*(n40|m40|-40)))";
                        } elsif ($RC_NAME_FROM_DIR =~ m/^r?cworst125/i) {
                            $RC_CHECK_REGEXP = "((cworst.*125)|(slow.*125))";
                        } elsif ($RC_NAME_FROM_DIR =~ m/^r?cworstt125/i) {
                            $RC_CHECK_REGEXP = "((cworst.*_T.*125)|(slow.*_T.*125))";
                        } elsif ($RC_NAME_FROM_DIR =~ m/^r?cworstt0/i) {
                            $RC_CHECK_REGEXP = "((cworst.*_T.*0)|(slow.*_T.*0))";
                        } elsif ($RC_NAME_FROM_DIR =~ m/^r?cworst105/i) {
                            $RC_CHECK_REGEXP = "((cworst.*105)|(slow.*105))";
                        } elsif ($RC_NAME_FROM_DIR =~ m/^r?cworst0/i) {
                            $RC_CHECK_REGEXP = "((cworst.*\.0\.)|(slow.*\.0\.))";
                        } elsif ($RC_NAME_FROM_DIR =~ m/^r?cbest105/i) {
                            $RC_CHECK_REGEXP = "((cbest.*105)|(fast.*105))";
                        } elsif ($RC_NAME_FROM_DIR =~ m/^r?cbest125/i) {
                            $RC_CHECK_REGEXP = "((cbest.*125)|(fast.*125))";
                        } elsif ($RC_NAME_FROM_DIR =~ m/^r?cbestn40/i) {
                            $RC_CHECK_REGEXP = "((cbest.*(n40|m40|-40))|(fast.*(n40|m40|-40)))";
                        } elsif ($RC_NAME_FROM_DIR =~ m/^r?cbest0/i) {
                            $RC_CHECK_REGEXP = "((cbest.*\.0\.)|(fast.*\.0\.))";
                        } elsif ($RC_NAME_FROM_DIR =~ m/typical/i) {
                            $RC_NAME_FROM_DIR = "(nominal|typical)";
                        }

                        #check if RC in report is correct
                        if (!defined $RC_CHECK_REGEXP) {
                            if ($RC_NAME_IN_REPORT !~ m/(_+|\.+)c?$RC_NAME_FROM_DIR/i) {
                                $RC_not_correct = 1;
                            }
                        } else {
                            if ($RC_NAME_IN_REPORT !~ m/$RC_CHECK_REGEXP/i) {
                                print $OUT_FILE "\t-Incorrect RC <><>: $RC_NAME_IN_REPORT\n";
                                print $OUT_FILE "\t$RC_NAME_IN_REPORT,$RC_CHECK_REGEXP\n";
                                $RC_not_correct = 1;
                            }
                        }
                    }
                }

                if ($RC_not_correct) {
                    $error_flag = 1;
		    $Check_RC{$STA_RUN} = 1;
		    $num_Check_RC{$STA_RUN} = 1;
                } else {
                    print $OUT_FILE "\t-Correct RC\n";
		    $Check_RC{$STA_RUN} = 0;
		    $num_Check_RC{$STA_RUN} = 0;
                }

                close REPORT;

            } else {
                print $OUT_FILE "\nError: Cannot open $STA_RUN/parasitics_command.log\n";
                $error_flag = 1;
		    $Check_RC{$STA_RUN} = 1;
            }
        } else {
            print $OUT_FILE "\t-Error: RC (starund <module>.<STA_corner>_<RC>) invalid or not found\n";
	    #print $OUT_FILE "hahaha $STA_RUN\n";
            print $OUT_FILE "\t-The supported RCs are: (r)cbest(n40|m40|125|0), (r)cworst(n40|m40|125|0) and typical(25|85)\n";
            $Check_RC{$STA_RUN} = 1;
            $error_flag = 1;
        }
    }
    return $error_flag;
} #sub check_RC

sub check_timing_report {

    my $error_flag = 0;
    my $report_is_clean = 1;
    my ($OUT_FILE, @STA_RUNS) = (@_);

    foreach (@STA_RUNS) {
        my $STA_RUN = $_;
        $Check_timing_report{$STA_RUN} = 0;
        if (opendir DIR, "$STA_RUN/report") {
            my @CHKTIMING_REPORT = grep (/checkTiming\.rpt$/, readdir DIR);
            closedir DIR;

            if (@CHKTIMING_REPORT && open (REPORT, "$STA_RUN/report/$CHKTIMING_REPORT[0]")) {
                my $filename = fileparse($STA_RUN);
                my $print_next_line = 0;
                print $OUT_FILE "\nChecking $filename\n";

                while (<REPORT>) {
                    chomp;
                    print $OUT_FILE "$_\n" if ($print_next_line);
                    $print_next_line = 0;
                    if ($_ =~ m/^Warning/ or $_ =~ m/^Error/) {
                        if ($_ =~ m/Error/) {
                            $error_flag = 1;
			    $Check_timing_report{$STA_RUN} = 1;
                            $print_next_line = 1 if ($_ !~ m/.\. \(.\)/); #checking if error message is continued on next line
                        }
                        $error_flag = 1 if ($_ =~ m/Error/);
                        $report_is_clean = 0;
                        if ($print_next_line) {
                            print $OUT_FILE "\t-$_"; #allowing for the next line from report to be printed in the same line in summary report
                        } else {
                            print $OUT_FILE "\t-$_\n";
                        }
                    }
                }
                if ($report_is_clean) {print $OUT_FILE "\t-Clean\n"; $Check_timing_report{$STA_RUN} = 0;}
                close REPORT;
            } else {
                print $OUT_FILE "\nError: Cannot open $STA_RUN/report/*checkTiming.rpt report\n";
                $error_flag = 1;
		$Check_timing_report{$STA_RUN} = 2;

            }
        } else {
            print $OUT_FILE "\nError: Cannot open report directory: $STA_RUNS[0]/report\n";
            $error_flag = 1;
	    $Check_timing_report{$STA_RUN} = 2;
        }
    }
    return $error_flag;
} #sub check_timing_report

sub noclk_report {
    my $error_flag = 0;
    my $report_is_clean = 1;
    my ($OUT_FILE, @STA_RUNS) = (@_);

    foreach (@STA_RUNS) {
        my $STA_RUN = $_;
        if (opendir DIR, "$STA_RUN/report") { #directory check
            my @NOCLK_REPORT = grep (/noClk\.rpt$/, readdir DIR);
            closedir DIR;

            if (@NOCLK_REPORT && open (REPORT, "$STA_RUN/report/$NOCLK_REPORT[0]")) { #report check
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename\n";

                my $line_in_report = 0;
                my $violation_counter = 0;
                my $SPARE_cells = 0;
                my $RB_SB_cells = 0;
                my $POWER_pins = 0;

                while (<REPORT>) {
                    chomp;
                    if ($_ =~ m/check_timing succeeded/) {last;} #this line indicates that report is clean
                    if ($line_in_report > 4) { #line 5 is the first line of pin names in the report
                        if ($_ =~ m/SPARE/) { #waive SPARE_FF cells
                            $SPARE_cells = 1;
                        } elsif ($_ =~ m/(RB|SB)/) { #waive RB/SB pins
                            $RB_SB_cells = 1;
                        } elsif ($_ =~ /DEEPSLEEP|POWERGATE/) {
                            $POWER_pins = 1;
                        } elsif (($_ !~/0$/) && ($_ !~ /^$/)) {
                            $violation_counter++;
                            $report_is_clean = 0;
                        }
                    }
                    $line_in_report++;
                }
                if ($report_is_clean) {
                    print $OUT_FILE "\t-Clean\n";
		    $Noclk_report{$STA_RUN} = 0;
                } else {
                    print $OUT_FILE "\t-SPARE cells waived\n" if ($SPARE_cells);
                    print $OUT_FILE "\t-RB/SB clock pins waived\n" if ($RB_SB_cells);
                    print $OUT_FILE "\t-DEEPSLEEP/POWERGATE PINS waived\n" if ($POWER_pins);
                    print $OUT_FILE "\t-$violation_counter pins with no clock found\n";
                    $error_flag = 2 if ($error_flag == 0); #this is done to prevent an error from being over-written by warnings
		    $Noclk_report{$STA_RUN} = 1;
		    $num_Noclk_report{$STA_RUN} = $violation_counter;
                }
                close REPORT;
            } else { #check if report exists
                print $OUT_FILE "\nError: Cannot open $STA_RUN/report/*noClk.rpt report\n";
                $error_flag = 1;
		    $Noclk_report{$STA_RUN} = 2;
            }
        } else { #check is directory exists
            print $OUT_FILE "\nError: Cannot open report directory: $STA_RUNS[0]/report\n";
            $error_flag = 1;
		    $Noclk_report{$STA_RUN} = 2;
        }
    }
    return $error_flag;
} #sub noclk_report


sub check_annotated {

    my $error_flag = 0;
    my $report_is_clean = 1;
    my ($OUT_FILE, @STA_RUNS) = (@_);

    foreach (@STA_RUNS) {
        my $STA_RUN = $_;
        @files = glob("$STA_RUN/report/not_annotated_pin_to_pin_parasitics_*");
        foreach $file (@files) {

        if (open (REPORT, $file)) {
            my $filename = fileparse($STA_RUN);
            print $OUT_FILE "\nChecking $filename:\n";

            my $line_number = 0;
            my $logic_error_num = 0;
            my $unconnected_error_num = 0;
            my $vssm_error_num = 0;
            my $total_error_num = 0;
            my $not_waived_error_num = 0;
            my $error_messages_num = 0;

            while (<REPORT>) {
                if ($line_number == 0 and $_ =~ m/^\*/) {
                    last;
                }
                $line_number++;

                if ($_ =~ m/^\d+\./) { #only check lines that start with a number followed by '.' eg. "1." or "2." etc
                    if ($_ =~ m/Logic0|Logic1/) { #ignore logic0/logic1 errors
                        $logic_error_num++;
                    } elsif ($_ =~ m/UNCONNECTED/) {
                        $unconnected_error_num++;
                    } elsif ($_ =~ m/VSSM/) {
                        $vssm_error_num++;
                    } else {
                        $not_waived_error_num++;
                    }
                    $total_error_num++;
                }

                if ($_ =~ m/Pin to pin nets/) {
                    my @parse_line = split(/\s+/);
                    my $not_annotated_num = $parse_line[-2];
                    if ($not_annotated_num > 0) {
                        print $OUT_FILE "\t-$not_annotated_num not annotated internal pin to pin nets.\n";
                    }
                    last; #assuming that the internal nets are printed before boundary/port nets
                }

                if ($_ =~ m/^Error:/) {
                    $error_messages_num++;
                }
            }

            if ($total_error_num > 0) {
                if ($not_waived_error_num > 0) {
                    print $OUT_FILE "\t-Total pin errors: $total_error_num ($not_waived_error_num not waived)\n";
                    $error_flag = 1;
		    $Check_annotated{$STA_RUN} = 1;
		    $num_Check_annotated{$STA_RUN} = $total_error_num;
                } else {
                    print $OUT_FILE "\t-Total pin errors: $total_error_num (all errors waived)\n";
                }
                print $OUT_FILE "\t\t-$logic_error_num Logic0/Logic1 errors waived\n" if ($logic_error_num > 0);
                print $OUT_FILE "\t\t-$unconnected_error_num UNCONNECTED errors waived\n" if ($unconnected_error_num > 0);
                print $OUT_FILE "\t\t-$vssm_error_num VSSM errors waived\n" if ($vssm_error_num > 0);
            }

            if ($error_messages_num > 0) {
                print $OUT_FILE "\t-$error_messages_num other error message(s) detected. Check report for details.\n";
                $error_flag = 1;
		$Check_annotated{$STA_RUN} = 1;
		$num_Check_annotated{$STA_RUN} = $error_messages_num;
            }

            if ($line_number == 0) {
                print $OUT_FILE "\t-Clean\n";
		$Check_annotated{$STA_RUN} = 0;
            }
            close REPORT;
        } else {
            print $OUT_FILE "\nError: Cannot open $STA_RUN/report/not_annotated_pin_to_pin_parasitics.rpt\n";
            $error_flag = 1;
	    $Check_annotated{$STA_RUN} = 2;
            next;
        }
        }
    }
    return $error_flag;
} #sub check_annotated

sub check_annotated_pocv {

    my $error_flag = 0;
    my $report_is_clean = 1;
    my ($OUT_FILE, @STA_RUNS) = (@_);

    foreach (@STA_RUNS) {
        my $STA_RUN = $_;
        @files = glob("$STA_RUN/report/not_annotated_cell_pocv_*");
        foreach $file (@files) {

          if (open (REPORT, $file)) {
              my $filename = fileparse($STA_RUN);
              print $OUT_FILE "\nChecking $filename:\n";

              my $line_number = 0;
              my $total_error_num = 0;

              while (<REPORT>) {
                     
                  if ($_ =~ m/^\s.+\*$/) {
                      $total_error_num++;
                      $line_number++;
                  }
              }

              if ($total_error_num > 0) {
		      #print $OUT_FILE "\t-Total errors: $total_error_num \n";
              	      $error_flag = 1;
		      $Check_annotated_pocv{$STA_RUN} = 1;
		      $num_Check_annotated_pocv{$STA_RUN} = $total_error_num;
              }

              if ($line_number == 0) {
                  print $OUT_FILE "\t-Clean\n";
		  $Check_annotated_pocv{$STA_RUN} = 0;
              }
              close REPORT;
          } else {
              print $OUT_FILE "\nError: Cannot open $STA_RUN/report/not_annotated_cell_pocv_*.rpt\n";
              $error_flag = 1;
	      $Check_annotated_pocv{$STA_RUN} = 2;
              next;
          }
        }
    }
    return $error_flag;
} #sub check_annotated_pocv

sub check_constraint {

    my $error_flag = 0;
    my ($OUT_FILE, @STA_RUNS) = (@_);

    foreach (@STA_RUNS) {
        my $STA_RUN = $_;
        @files = glob("$STA_RUN/report/*_checkConstraints.rpt");
	if (defined $files[0]) {
        foreach $file (@files) {

        if (open (REPORT, $file)) {
            my $filename = fileparse($STA_RUN);
            print $OUT_FILE "\nChecking $filename:\n";

            my $line_number = 0;
            my $error_messages_num = 0;
            my @error_list = ();
            my %error_info = ();
            my $error_id;
            my $error_num;
            my $total_error_num = 0;
            my $error_sp;

            while (<REPORT>) {
                $line_number++;

                if (/^ +(EXC|CLK|CGR|HIER)_\d+ /) {
                    push @error_list, $_;
                    $error_messages_num++;
                }

            }

            if ($error_messages_num > 0) {
                foreach (@error_list) {
                    @error_sp = split;
                    ($error_id, $error_num) = ($error_sp[0], $error_sp[1]);
                    $error_info{$error_id} = $error_num;
                    $total_error_num += $error_num
                }
                print $OUT_FILE "\t-Total $total_error_num errors detected. Check report for details.\n";
                foreach (sort keys %error_info) {
                    print $OUT_FILE "\t\t-$_ : $error_info{$_}\n";
                }
		$Check_constraint{$STA_RUN} = 1;
                $error_flag = 1;
            } else {
                print $OUT_FILE "\t-Clean\n";
		$Check_constraint{$STA_RUN} = 0;
            }
            close REPORT;
        } else {
            print $OUT_FILE "\nError: Cannot open $STA_RUN/report/<top>_checkConstraints.rpt\n";
            $error_flag = 1;
	    $Check_constraint{$STA_RUN} = 2;
            next;
        }
    }
    } else {
         $error_flag = 1;
      }
   }
    return $error_flag;
} #sub check_constraint

sub check_clktransition {

    my $error_flag = 0;
    my ($OUT_FILE, @STA_RUNS) = (@_);

    foreach (@STA_RUNS) {
        my $STA_RUN = $_;
        my $report_is_open = 0;

        if ($STA_RUN =~ m/slow|typ|fast/) {

            if (opendir DIR, "$STA_RUN/") {
                my @VIOLATION_REPORT = grep (/violationSummary\.rpt$/, readdir DIR);
                closedir DIR;

                if (@VIOLATION_REPORT && open (REPORT, "$STA_RUN/$VIOLATION_REPORT[0]")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";

                    $report_is_open = 1;
                } else {
                    $error_flag = check_pdClockTran ($OUT_FILE, $STA_RUN);
                    next;
                }
            } else {
                print $OUT_FILE "\nError: Cannot open report directory: $STA_RUN/\n";
                $error_flag = 1;
		$Check_clktransition{$STA_RUN} = 2;
                last;
            }
        }

        if ($report_is_open) {
            my $line_in_report = 0;
            my $violation_counter = 0;
            my $worst_violator = "";
            my $worst_violation = 0;
            my $total_vios = 0;

            while(<REPORT>) {
                if ($line_in_report > 5) {
                    my ($VIOLATOR_NAME, $CLOCK_CYCLE, $TRANS_LIMIT, $VIOLATION, $NUM_OF_VIOLATIONS) = split(/\s+/); #split report columns
                    $worst_violator = $VIOLATOR_NAME if ($worst_violator =~ m/^\s*$/ or $TRANS_LIMIT - $VIOLATION  < $worst_violation);
                    $worst_violation = $TRANS_LIMIT - $VIOLATION if ( $TRANS_LIMIT - $VIOLATION < $worst_violation);
                    $violation_counter++;
                    $total_vios = $total_vios + $NUM_OF_VIOLATIONS;
                }
                $line_in_report++;
            }
            if ($line_in_report == 6) {print $OUT_FILE "\t-Clean\n"; 
		                       $Check_clktransition{$STA_RUN} = 0;
			       }
            else {
                $error_flag = 1;
                print $OUT_FILE "\t-Number of clock names: $violation_counter\n";
                print $OUT_FILE "\t-Total number of violations: $total_vios\n";
                print $OUT_FILE "\t-Worst violator: $worst_violator ($worst_violation)\n";
		my @info = ($worst_violator, $worst_violation, $total_vios, $violation_counter);
		$sum_Check_clktransition{$STA_RUN} = \@info;
		$num_Check_clktransition{$STA_RUN} = $total_vios;
		$Check_clktransition{$STA_RUN} = 1;
            }
        }
        close REPORT;
    }
    return $error_flag;
} #sub check_clktransition

sub check_pdClockTran {

    my $error_flag = 0;
    my ($OUT_FILE, $STA_RUN) = (@_);

    if (open (REPORT, "$STA_RUN/pdClockTran.tran")) {
        my $filename = fileparse($STA_RUN);
        print $OUT_FILE "\nChecking $filename\n";

        my $check_next_line = 0;
        my $violation_counter = 0;
        my $worst_violator = "";
        my $worst_violation = 0;

        while (<REPORT>) {
            if ($check_next_line) { #start checking for violations from this line
                if ($_ !~ /^\#\#/) {
                    my ($BLANK, $VIOLATOR_NAME, $VIOLATION, $REST_OF_LINE) = split(/\s+/); #split report columns
                    $worst_violator = $VIOLATOR_NAME if ($worst_violator =~ m/^\s*$/ or $VIOLATION > $worst_violation);
                    $worst_violation = $VIOLATION if ($VIOLATION > $worst_violation);
                    $violation_counter++;
                }
            }
            if ($_ =~ /\=+$/) {$check_next_line = 1;} #check if the current line is a string of '=' chars
            else {$check_next_line = 0;}
        }

        if ($violation_counter == 0) {print $OUT_FILE "\t-Clean\n";$Check_clktransition{$STA_RUN} = 0}
        else {
            $error_flag = 1;
            print $OUT_FILE "\t-Number of violations: $violation_counter\n";
            print $OUT_FILE "\t-Worst violator: $worst_violator ($worst_violation)\n";
	    $Check_clktransition{$STA_RUN} = 1
        }
        close REPORT
    } else {
        print $OUT_FILE "\nError: Cannot open any clk transistion report ($STA_RUN/*violationSummary.rpt or pdClockTran.tran)\n";
        $error_flag = 1;
	    $Check_clktransition{$STA_RUN} = 2
}
    return $error_flag;
} #sub check_pdClockTran

sub check_transition {

    my $error_flag = 0;
    my ($OUT_FILE, $REPORT, @STA_RUNS) = (@_);

    foreach (@STA_RUNS) {
        my $STA_RUN = $_;
        if ($STA_RUN =~ m/slow|slown40|typ85.si|typ25|fast/) {
            if ($REPORT =~ m/data/) { #if data is specified, then open drc_transition_valid report
                if (open (REPORT, "$STA_RUN/report/drc_transition_slow125_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_transition_slow125_0p81v_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_transition_slow105_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif  (open (REPORT, "$STA_RUN/report/drc_transition_slown40_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif  (open (REPORT, "$STA_RUN/report/drc_transition_slown40_0p81v_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif  (open (REPORT, "$STA_RUN/report/drc_transition_slow0_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif  (open (REPORT, "$STA_RUN/report/drc_transition_slow0_0p81v_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif  (open (REPORT, "$STA_RUN/report/drc_transition_slown40_bb0p90v_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif  (open (REPORT, "$STA_RUN/report/drc_transition_slow105_bb0p50v_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif  (open (REPORT, "$STA_RUN/report/drc_transition_slown40_bb0p50v_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_transition_fast105_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_transition_fast125_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_transition_fast125_0p99v_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_transition_fast0_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_transition_fast0_0p99v_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_transition_fastn40_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_transition_fastn40_0p99v_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_transition_typ25_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_transition_typ85_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_transition_typ85_0p9v_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_transition_typ25_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_transition_typ25_0p9v_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } else {
                    print $OUT_FILE "\nError: Cannot open $STA_RUN/report/drc_transition_valid.rpt\n";
                    $error_flag = 1;
                    next;
		    $Check_trans_data{$STA_RUN} = 2;
                }
            }
            elsif ($REPORT =~ m/cap/) { #if cap is specified, then open drc_capacitance_valid report
                if (open (REPORT, "$STA_RUN/report/drc_capacitance_slow125_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_capacitance_slow125_0p81v_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_capacitance_slow105_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_capacitance_slown40_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_capacitance_slown40_0p81v_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_capacitance_slow0_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_capacitance_slow0_0p81v_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_capacitance_slown40_bb0p90v_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif  (open (REPORT, "$STA_RUN/report/drc_capacitance_slow105_bb0p50v_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif  (open (REPORT, "$STA_RUN/report/drc_capacitance_slown40_bb0p50v_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_capacitance_fast105_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_capacitance_fast125_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_capacitance_fast125_0p99v_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_capacitance_fastn40_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_capacitance_fastn40_0p99v_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_capacitance_fast0_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_capacitance_fast0_0p99v_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_capacitance_typ85_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_capacitance_typ85_0p9v_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_capacitance_typ25_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } elsif (open (REPORT, "$STA_RUN/report/drc_capacitance_typ25_0p9v_valid.rpt")) {
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";
                } else {
                    print $OUT_FILE "\nError: Cannot open $STA_RUN/report/drc_capacitance_valid.rpt\n";
                    $error_flag = 1;
                    next;
		    $Check_trans_cap{$STA_RUN} = 2;
                }
            }

            my $line_in_report = 0;
            my $violation_counter = 0;
            my $worst_violator = "";
            my $worst_violation = 0;

            my $filename = fileparse($STA_RUN);
            
            while(<REPORT>) { #loop through each line in report
	     if ($REPORT =~ m/data/) {
                if ($line_in_report > 18 and $_ !~ m/^\s*$/ and $_ !~ m/^1$/ ) { #if no. of lines in report is >14 and non-empty and doesnot start with '1'
			#my ($temp, $PIN_NAME, $mean, $sensit, $value, $slack_mean, $slack_sensit, $slack_value, $SLACK) = split(/\s+/); #split report columns
		    my ($temp, $PIN_NAME, $required_value, $actual_value, $SLACK) = split(/\s+/); #split report columns
                    $worst_violator = $PIN_NAME if ($worst_violator =~ m/^\s*$/ or $SLACK < $worst_violation);
                    $worst_violation = $SLACK if ($SLACK < $worst_violation);
                    $violation_counter++;
		    #print "$worst_violation \n " ;
                }
	     } else {
		if ($line_in_report > 14 and $_ !~ m/^\s*$/ and $_ !~ m/^1$/ ) { #if no. of lines in report is >14 and non-empty and doesnot start with '1'
                    my ($temp, $PIN_NAME, $Req_cap, $Act_cap, $SLACK) = split(/\s+/); #split report columns
                    $worst_violator = $PIN_NAME if ($worst_violator =~ m/^\s*$/ or $SLACK < $worst_violation);
                    $worst_violation = $SLACK if ($SLACK < $worst_violation);
                    $violation_counter++;
                }


	       }


                $line_in_report++;
            }
	    my @info = ($worst_violation, $worst_violator);
            if ($line_in_report == 11) {
		    print $OUT_FILE "\t-Clean\n"; 
		    if ($REPORT =~ m/data/) {
	                $Check_trans_data{$STA_RUN} = 0;
		        $num_Check_trans_data{$STA_RUN} = $violation_counter;
		        $worst_Check_trans_data{$STA_RUN} = $worst_violation,;
	            } else {
		        $Check_trans_cap{$STA_RUN} = 0;
			$num_Check_trans_cap{$STA_RUN} = $violation_counter;

	              }
            }
            else {
                if ($error_flag == 0 && $STA_RUN =~ m/typ/) {
                    $error_flag = 2; #this means report warnings (not error). Used when typ corner has violations.
                } else {
                    $error_flag = 1; #this means errors detected
		    if ($REPORT =~ m/data/) {
		        $Check_trans_data{$STA_RUN} = 1;
		        $num_Check_trans_data{$STA_RUN} = $violation_counter;
		        $worst_Check_trans_data{$STA_RUN} = $worst_violation;
		        $sum_Check_trans_data{$STA_RUN} = \@info;
                    } else {

		        $Check_trans_cap{$STA_RUN} = 1;
		        $num_Check_trans_cap{$STA_RUN} = $violation_counter;
		        $sum_Check_trans_cap{$STA_RUN} = \@info;
		    }
                }
                print $OUT_FILE "\t-Number of violations: $violation_counter\n";
                print $OUT_FILE "\t-Worst violator: $worst_violator ($worst_violation)\n";
            }

            close REPORT;
        }
    }
    return $error_flag;
} #sub check_transition

sub check_si {
    my $error_flag = 0;
    my ($OUT_FILE, $REPORT, @STA_RUNS) = (@_);
    my $report_type = $REPORT;	
    foreach (@STA_RUNS) {
        my $STA_RUN = $_;
	#print "Checking Corner: $STA_RUN\n";
        if ($REPORT =~ m/max.rpt|min.rpt/) { #if si is specified, then open report_si_bottleneck report
            if ($STA_RUN =~ m/slown40.*cworst.*setup/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_max_slown40.rpt")) {
		    $Check_si_type{$STA_RUN} = "max";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";}
            } elsif ($STA_RUN =~ m/slown40_0p81v.*/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_slown40_0p81v.rpt")) {
		    $Check_si_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";}
            } elsif ($STA_RUN =~ m/slown40.*/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_slown40.rpt")) {
		    $Check_si_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";}
            } elsif ($STA_RUN =~ m/slow105.*/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_slow105.rpt")) {
		    $Check_si_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";}
            } elsif ($STA_RUN =~ m/slow0_0p81v.*/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_slow0_0p81v.rpt")) {
		    $Check_si_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";}
            } elsif ($STA_RUN =~ m/slow0.*/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_slow0.rpt")) {
		    $Check_si_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";}
            } elsif ($STA_RUN =~ m/slow125_0p81v.*/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_slow125_0p81v.rpt")) {
		    $Check_si_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";}
            } elsif ($STA_RUN =~ m/slow.*cworst.*setup/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_max_slow125.rpt")) {
		    $Check_si_type{$STA_RUN} = "max";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";}
            } elsif ($STA_RUN =~ m/slow.*cworst.*/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_slow125.rpt")) {
		    $Check_si_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";}
            } elsif ($STA_RUN =~ m/fastn40_0p99v.si/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_fastn40_0p99v.rpt")) {
		    $Check_si_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n"; }
            } elsif ($STA_RUN =~ m/fastn40.si/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_fastn40.rpt")) {
		    $Check_si_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n"; }
            } elsif ($STA_RUN =~ m/fast105.si/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_fast105.rpt")) {
		    $Check_si_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n"; }
            } elsif ($STA_RUN =~ m/fast125_0p99v.si/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_fast125_0p99v.rpt")) {
		    $Check_si_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n"; }
            } elsif ($STA_RUN =~ m/fast125.si/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_fast125.rpt")) {
		    $Check_si_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n"; }
            } elsif ($STA_RUN =~ m/fast0.si/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_fast0.rpt")) {
		    $Check_si_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n"; }
            } elsif ($STA_RUN =~ m/typ85_0p9v/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_typ85_0p9v.rpt")) {
		    $Check_si_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n"; }
            } elsif ($STA_RUN =~ m/typ85/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_typ85.rpt")) {
		    $Check_si_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n"; }
            } elsif ($STA_RUN =~ m/typ25_0p9v/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_typ25_0p9v.rpt")) {
		    $Check_si_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n"; }
            } elsif ($STA_RUN =~ m/typ25/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_typ25.rpt")) {
		    $Check_si_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n"; }

            } else {
                #print $OUT_FILE "\nError: Cannot open $STA_RUN/report/report_si_bottleneck.rpt\n";
                #$error_flag = 1;
                next;
		$Check_si{$STA_RUN} = 2;
            }
        } elsif ($REPORT =~ m/with_clock/) {
            if ($STA_RUN =~ m/slown40.*_cworst.*setup/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_max_with_clock_slown40.rpt")) {
		    $Check_si_clk_type{$STA_RUN} = "max";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";}
            } elsif ($STA_RUN =~ m/slown40_0p81v.*/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_with_clock_slown40_0p81v.rpt")) {
		    $Check_si_clk_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";}
            } elsif ($STA_RUN =~ m/slown40.*/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_with_clock_slown40.rpt")) {
		    $Check_si_clk_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";}
            } elsif ($STA_RUN =~ m/slow105.*/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_with_clock_slow105.rpt")) {
		    $Check_si_clk_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";}
            } elsif ($STA_RUN =~ m/slow125_0p81v.*/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_with_clock_slow125_0p81v.rpt")) {
		    $Check_si_clk_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";}
            } elsif ($STA_RUN =~ m/slow125.*cworst.*setup/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_max_with_clock_slow125.rpt")) {
		    $Check_si_clk_type{$STA_RUN} = "max";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";}
            } elsif ($STA_RUN =~ m/slow125.*cworst.*/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_with_clock_slow125.rpt")) {
		    $Check_si_clk_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";}
            } elsif ($STA_RUN =~ m/slow0_0p81v.*/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_with_clock_slow0_0p81v.rpt")) {
		    $Check_si_clk_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";}
            } elsif ($STA_RUN =~ m/slow0.*/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_max_with_clock_slow0.rpt")) {
		    $Check_si_clk_type{$STA_RUN} = "max";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n";}
            } elsif ($STA_RUN =~ m/fastn40.si/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_with_clock_fastn40.rpt")) {
		    $Check_si_clk_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n"; }
            } elsif ($STA_RUN =~ m/fast105.si/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_with_clock_fast105.rpt")) {
		    $Check_si_clk_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n"; }
            } elsif ($STA_RUN =~ m/fast125.si/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_with_clock_fast125.rpt")) {
		    $Check_si_clk_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n"; }
            } elsif ($STA_RUN =~ m/fast0.si/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_with_clock_fast0.rpt")) {
		    $Check_si_clk_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n"; }
            } elsif ($STA_RUN =~ m/typ25/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_with_clock_typ25.rpt")) {
		    $Check_si_clk_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n"; }
            } elsif ($STA_RUN =~ m/typ85/) {
                if (open (REPORT, "$STA_RUN/report/report_si_bottleneck_min_with_clock_typ85.rpt")) {
		    $Check_si_clk_type{$STA_RUN} = "min";
                    my $filename = fileparse($STA_RUN);
                    print $OUT_FILE "\nChecking $filename:\n"; }
            } else {
                #print $OUT_FILE "\nError: Cannot open $STA_RUN/report/report_si_bottleneck.rpt\n";
                #$error_flag = 1;
                next;
		$Check_si_clk{$STA_RUN} = 2;
            }


        }
        my $line_in_report = 0;
        my $violation_counter = 0;
        my $worst_violator = "";
        my $worst_violation = 0;

        my $filename = fileparse($STA_RUN);
	#print "$filename\n";
        while(<REPORT>) { #loop through each line in report
            if ($_ =~ /Information: report_si_bottleneck found zero net to report/) {
                print $OUT_FILE "\t-Clean\n";
                print $OUT_FILE "\t-Number of violations: 0\n";
                print $OUT_FILE "\t-Worst violator:  (0)\n";
		if ($REPORT =~ m/with_clock/) {
			$Check_si_clk{$STA_RUN} = 0;
		} else {
			$Check_si{$STA_RUN} = 0;
		}
                #return $error_flag;
                #last;
            }
            if (($line_in_report > 16 and $REPORT =~ m/max.rpt|min.rpt/ or $line_in_report > 17 and $REPORT =~ m/with_clock/ )and $_ !~ m/^\s*$/ and $_ !~ m/^1$/) { #if no. of lines in report is >15 and non-empty and doesnot start with '1'
                my ($temp, $NET_NAME, $SLACK) = split(/\s+/); #split report columns
                $worst_violator = $NET_NAME if ($worst_violator =~ m/^\s*$/ or $SLACK > $worst_violation);
                $worst_violation = $SLACK if ($SLACK > $worst_violation);
                $violation_counter++;
            }
            $line_in_report++;
        }
        if ($line_in_report == 16) {
		print $OUT_FILE "\t-Clean\n"; 
		if ($REPORT =~ m/with_clock/) {
			$Check_si_clk{$STA_RUN} = 0;
		} else {
			$Check_si{$STA_RUN} = 0;
		}
	}
        else {
            if ($error_flag == 0 && $STA_RUN =~ m/typ/) {
                $error_flag = 2; #this means report warnings (not error). Used when typ corner has violations.
		if ($report_type =~ m/with_clock/) {
			$Check_si_clk{$STA_RUN} = 0;
		} else {
			$Check_si{$STA_RUN} = 0;
		}
            } else {
                $error_flag = 1; #this means errors detected
		my @info = ($worst_violator, $worst_violation);
		$sum_Check_si_clk{$STA_RUN} = \@info;
		$sum_Check_si{$STA_RUN} = \@info;
		if ($report_type =~ m/with_clock/) {
			$Check_si_clk{$STA_RUN} = 1;
			$num_Check_si_clk{$STA_RUN} = $violation_counter;
		} else {
			$Check_si{$STA_RUN} = 1;
			$num_Check_si{$STA_RUN} = $violation_counter;
		}
            }
            print $OUT_FILE "\t-Number of violations: $violation_counter\n";
            print $OUT_FILE "\t-Worst violator: $worst_violator ($worst_violation)\n";
        }

        close REPORT;
    }
    return $error_flag;

} #sub check_si


sub check_clk_xtalk {
    my $error_flag = 0;
    my ($OUT_FILE, @STA_RUNS) = (@_);

    foreach (@STA_RUNS) {
        my $STA_RUN = $_;

        if ($STA_RUN =~ m/slown40_0p81v/) {
            if (open (REPORT, "$STA_RUN/report/clk_xtalk_slown40_0p81v.rpt")) {
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename:\n";}
        } elsif ($STA_RUN =~ m/slown40/) {
            if (open (REPORT, "$STA_RUN/report/clk_xtalk_slown40.rpt")) {
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename:\n";}
        } elsif ($STA_RUN =~ m/slow125_0p81v/) {
            if (open (REPORT, "$STA_RUN/report/clk_xtalk_slow125_0p81v.rpt")) {
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename:\n";}
        } elsif ($STA_RUN =~ m/slow125/) {
            if (open (REPORT, "$STA_RUN/report/clk_xtalk_slow125.rpt")) {
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename:\n";}
        } elsif ($STA_RUN =~ m/slow105/) {
            if (open (REPORT, "$STA_RUN/report/clk_xtalk_slow105.rpt")) {
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename:\n";}
        } elsif ($STA_RUN =~ m/slow0_0p81v/) {
            if (open (REPORT, "$STA_RUN/report/clk_xtalk_slow0p81v.rpt")) {
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename:\n";}
        } elsif ($STA_RUN =~ m/slow0/) {
            if (open (REPORT, "$STA_RUN/report/clk_xtalk_slow0.rpt")) {
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename:\n";}
        } elsif ($STA_RUN =~ m/fastn40_0p99v/) {
            if (open (REPORT, "$STA_RUN/report/clk_xtalk_fastn40_0p99v.rpt")) {
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename:\n"; }
        } elsif ($STA_RUN =~ m/fastn40/) {
            if (open (REPORT, "$STA_RUN/report/clk_xtalk_fastn40.rpt")) {
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename:\n"; }
        } elsif ($STA_RUN =~ m/fast125_0p99v/) {
            if (open (REPORT, "$STA_RUN/report/clk_xtalk_fast125_0p99v.rpt")) {
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename:\n"; }
        } elsif ($STA_RUN =~ m/fast125/) {
            if (open (REPORT, "$STA_RUN/report/clk_xtalk_fast125.rpt")) {
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename:\n"; }
        } elsif ($STA_RUN =~ m/fast105/) {
            if (open (REPORT, "$STA_RUN/report/clk_xtalk_fast105.rpt")) {
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename:\n"; }
        } elsif ($STA_RUN =~ m/fast0_0p99v/) {
            if (open (REPORT, "$STA_RUN/report/clk_xtalk_fast0_0p99v.rpt")) {
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename:\n"; }
        } elsif ($STA_RUN =~ m/fast0/) {
            if (open (REPORT, "$STA_RUN/report/clk_xtalk_fast0.rpt")) {
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename:\n"; }
        } elsif ($STA_RUN =~ m/typ85_0p9v/) {
            if (open (REPORT, "$STA_RUN/report/clk_xtalk_typ85_0p9v.rpt")) {
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename:\n"; }
        } elsif ($STA_RUN =~ m/typ85/) {
            if (open (REPORT, "$STA_RUN/report/clk_xtalk_typ85.rpt")) {
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename:\n"; }
        } elsif ($STA_RUN =~ m/typ25_0p9v/) {
            if (open (REPORT, "$STA_RUN/report/clk_xtalk_typ25_0p9v.rpt")) {
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename:\n"; }
        } elsif ($STA_RUN =~ m/typ25/) {
            if (open (REPORT, "$STA_RUN/report/clk_xtalk_typ25.rpt")) {
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename:\n"; }

        } else {
            #print $OUT_FILE "\nError: Cannot open $STA_RUN/report/report_si_bottleneck.rpt\n";
            #$error_flag = 1;
	    $Check_clk_xtalk{$STA_RUN} = 2;
            next;
        }

        my $line_in_report = 0;
        my $violation_counter = 0;
        my $worst_violator = "";
        my $worst_violation = 0;

        my $filename = fileparse($STA_RUN);

        while(<REPORT>) { #loop through each line in report
            $line_in_report++;
            if (/No Clock Net found which has SI more than/) {
                print $OUT_FILE "\t-Clean\n";
	        $Check_clk_xtalk{$STA_RUN} = 0;
                last;
            }
            if ($line_in_report > 5) {
                my ($NET_NAME, $SLACK) = split(/\s+/); #split report columns
                $worst_violator = $NET_NAME if ($worst_violator =~ m/^\s*$/ or $SLACK > $worst_violation);
                $worst_violation = $SLACK if ($SLACK > $worst_violation);
                $violation_counter++;
            }
        }

        if ($violation_counter > 0) {
            $error_flag = 1; #this means errors detected
            print $OUT_FILE "\t-Number of violations: $violation_counter\n";
            print $OUT_FILE "\t-Worst violator: $worst_violator ($worst_violation)\n";
	    $Check_clk_xtalk{$STA_RUN} = 1;
	    $num_Check_clk_xtalk{$STA_RUN} = $violation_counter;
	    my @info = ($worst_violator, $worst_violation);
	    $sum_Check_clk_xtalk{$STA_RUN} = \@info;
        } else {
            #print $OUT_FILE "\t-Clean\n";
	    $Check_clk_xtalk{$STA_RUN} = 0;
        }

        close REPORT;
    }

    return $error_flag;

} #sub check_clk_xtalk

sub check_noise {
    my $error_flag = 0;
    my ($OUT_FILE, $REPORT, @STA_RUNS) = (@_);

    foreach (@STA_RUNS) {
        my $STA_RUN = $_;

	#print "$STA_RUN\n";
        if ($REPORT =~ m/noise/ ) { #if si is specified, then open report_si_bottleneck report

            opendir(DIR,"$STA_RUN/report") or die "opening directory failed:$!";
            while(my $file=readdir(DIR)) {
                if ($file =~ m/noise_at_end_point_fast|noise_at_end_point_slow|noise_at_end_point_typ/) {
                    $REPORT = $file;
                }
            }

            if (open (REPORT, "$STA_RUN/report/$REPORT")) {
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename:\n";
            } else {
                print $OUT_FILE "\nError: Cannot open $STA_RUN/report/noise_at_end_point.rpt\n";
                $error_flag = 1;
                next;
            }

            my $line_in_report = 0;
            my $violation_counter_aboveLow = 0;
            my $violation_counter_belowHigh = 0;
            my $violation_counter_belowLow = 0;
            my $violation_counter_aboveHigh = 0;
            my $worst_violator_aboveLow = "";
            my $worst_violator_belowHigh = "";
            my $worst_violator_belowLow = "";
            my $worst_violator_aboveHigh = "";
            my $worst_violation_aboveLow = 0;
            my $worst_violation_belowHigh = 0;
            my $worst_violation_belowLow = 0;
            my $worst_violation_aboveHigh = 0;
            my $belowHighFlag = 0;
            my $aboveHighFlag = 0;
            my $belowLowFlag = 0;

            my $total_aboveLow = 0;
            my $total_belowHigh = 0;
            my $total_belowLow = 0;
            my $total_aboveHigh = 0;

            my $filename = fileparse($STA_RUN);

            while(<REPORT>) { #loop through each line in report

                if ($_ =~ m/below_high/) {$belowHighFlag = 1; }
                if ($_ =~ m/above_high/) {$aboveHighFlag = 1; }
                if ($_ =~ m/below_low/) {$belowLowFlag = 1; }
                if ($line_in_report > 14 and $_ !~ m/^\s*$/ and $_ !~ m/^1$/ and $belowHighFlag == 0  and $_ !~ m/below_high/) { #if no. of lines in report is >15 and non-empty and doesnot start with '1'
                    my ($temp, $PIN_NAME, $NET_NAME, $WIDTH, $HEIGHT, $SLACK_aboveLow) = split(/\s+/); #split report columns
                    $worst_violator_aboveLow = $PIN_NAME if ($worst_violator_aboveLow =~ m/^\s*$/ or $SLACK_aboveLow < $worst_violation_aboveLow);
                    $worst_violation_aboveLow = $SLACK_aboveLow if ($SLACK_aboveLow < $worst_violation_aboveLow);
                    $violation_counter_aboveLow++;
                    $total_aboveLow = $total_aboveLow + $SLACK_aboveLow;
                } elsif ($_ !~ m/^\s*$/ and $_ !~ m/^1$/ and $belowHighFlag == 1  and $belowLowFlag == 0 and $_ =~ /\//) {
                    my ($temp, $PIN_NAME, $NET_NAME, $WIDTH, $HEIGHT, $SLACK_belowHigh) = split(/\s+/); #split report columns
                    $worst_violator_belowHigh = $PIN_NAME if ($worst_violator_belowHigh =~ m/^\s*$/ or $SLACK_belowHigh < $worst_violation_belowHigh);
                    $worst_violation_belowHigh = $SLACK_belowHigh if ($SLACK_belowHigh < $worst_violation_belowHigh);
                    $violation_counter_belowHigh++;
                    $total_belowHigh = $total_belowHigh + $SLACK_belowHigh;
                } elsif ($belowHighFlag == 1 and $_ !~ m/^\s*$/ and $_ !~ m/^1$/ and $aboveHighFlag == 0  and $_ !~ m/above_high/ and $_ =~ m/\//) {
                    my ($temp, $PIN_NAME, $NET_NAME, $WIDTH, $HEIGHT, $SLACK_belowLow) = split(/\s+/); #split report columns
                    $worst_violator_belowLow = $PIN_NAME if ($worst_violator_belowLow =~ m/^\s*$/ or $SLACK_belowLow < $worst_violation_belowLow);
                    $worst_violation_belowLow = $SLACK_belowLow if ($SLACK_belowLow < $worst_violation_belowLow);
                    $violation_counter_belowLow++;
                    $total_belowLow = $total_belowLow + $SLACK_belowLow;
                } elsif ($_ !~ m/^\s*$/ and $_ !~ m/^1$/ and $aboveHighFlag == 1  and $_ =~ /\//) {
                    my ($temp, $PIN_NAME, $NET_NAME, $WIDTH, $HEIGHT, $SLACK_aboveHigh) = split(/\s+/); #split report columns
                    $worst_violator_aboveHigh = $PIN_NAME if ($worst_violator_aboveHigh =~ m/^\s*$/ or $SLACK_aboveHigh < $worst_violation_aboveHigh);
                    $worst_violation_aboveHigh = $SLACK_aboveHigh if ($SLACK_aboveHigh < $worst_violation_aboveHigh);
                    $violation_counter_aboveHigh++;
                    $total_aboveHigh = $total_aboveHigh + $SLACK_aboveHigh;
                }
                $line_in_report++;
            }
            if ($line_in_report == 21) {print $OUT_FILE "\t-Clean\n";$Check_noise{$STA_RUN} = 0;}
            else {
                if ($error_flag == 0 && $STA_RUN =~ m/typ/) {
		    $Check_noise{$STA_RUN} = 0;
                    $error_flag = 2; #this means report warnings (not error). Used when typ corner has violations.
                } else {
                    $error_flag = 1; #this means errors detected
		    $Check_noise{$STA_RUN} = 1;
		    $num_Check_noise{$STA_RUN} = $violation_counter_aboveLow + $violation_counter_belowHigh + $violation_counter_belowLow + $violation_counter_aboveHigh;
		    my @info = ($violation_counter_aboveLow, $worst_violator_aboveLow, $total_aboveLow, $violation_counter_belowHigh, $worst_violator_belowHigh,  $total_belowHigh, $violation_counter_belowLow, $worst_violator_belowLow, $total_belowLow, $violation_counter_aboveHigh, $worst_violator_aboveHigh, $total_aboveHigh);
		    $sum_Check_noise{$STA_RUN} = \@info;
                }

                print $OUT_FILE "\t-Number of violations above_low: $violation_counter_aboveLow\n";
                print $OUT_FILE "\t-Worst violator above_low: $worst_violator_aboveLow ($worst_violation_aboveLow)\n";
                print $OUT_FILE "\t-Total violator above_low: $total_aboveLow \n";
                print $OUT_FILE "\t-Number of violations below_high: $violation_counter_belowHigh\n";
                print $OUT_FILE "\t-Worst violator below_high: $worst_violator_belowHigh ($worst_violation_belowHigh)\n";
                print $OUT_FILE "\t-Total violator below_high: $total_belowHigh \n";

                print $OUT_FILE "\t-Number of violations below_low: $violation_counter_belowLow\n";
                print $OUT_FILE "\t-Worst violator below_low: $worst_violator_belowLow ($worst_violation_belowLow)\n";
                print $OUT_FILE "\t-Total violator below_low: $total_belowLow \n";
                print $OUT_FILE "\t-Number of violations above_high: $violation_counter_aboveHigh\n";
                print $OUT_FILE "\t-Worst violator above_high: $worst_violator_aboveHigh ($worst_violation_aboveHigh)\n";
                print $OUT_FILE "\t-Total violator above_high: $total_aboveHigh \n";

            }

            close REPORT;
            closedir DIR;
        }
    }
    return $error_flag;
} #sub check_noise


sub check_noise_double_switching {
    my $error_flag = 0;
    my ($OUT_FILE, $REPORT, @STA_RUNS) = (@_);

    foreach (@STA_RUNS) {
        my $STA_RUN = $_;

        if ($REPORT =~ m/noise_double_switching_on_clock/ ) { #if noise is specified, then open noise_double_switching_on_clock report

            opendir(DIR,"$STA_RUN/report") or die "opening directory failed:$!";
            while(my $file=readdir(DIR)) {
                if ($file =~ m/noise_double_switching_on_clock_fast|noise_double_switching_on_clock_slow|noise_double_switching_on_clock_typ/) {
                    $REPORT = $file;
                }
            }

            if (open (REPORT, "$STA_RUN/report/$REPORT")) {
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename:\n";
            } else {
                print $OUT_FILE "\nError: Cannot open $STA_RUN/report/$REPORT\n";
                $error_flag = 1;
                next;
            }
        } elsif ($REPORT =~ m/noise_double_switching/ ) { #if noise is specified, then open noise_double_switching report
            opendir(DIR,"$STA_RUN/report") or die "opening directory failed:$!";
            while(my $file=readdir(DIR)) {
                if ($file =~ m/noise_double_switching_fast|noise_double_switching_slow|noise_double_switching_typ/) {
                    $REPORT = $file;
                }
            }

            if (open (REPORT, "$STA_RUN/report/$REPORT")) {
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename:\n";
            } else {
                print $OUT_FILE "\nError: Cannot open $STA_RUN/report/$REPORT\n";
                $error_flag = 1;
                next;
            }
        }

        my $line_in_report = 0;
        my $violation_counter = 0;
        my $worst_violator = "";
        my $worst_violation = 0;

        my $filename = fileparse($STA_RUN);


        while(<REPORT>) { #loop through each line in report
            if ($line_in_report > 10 and $_ !~ m/^\s*$/ and $_ !~ m/^1$/ and  $REPORT !~ m/(noise_double_switching.rpt)|(on_clock)/
                or $line_in_report > 11 and $_ !~ m/^\s*$/ and $_ !~ m/^1$/ and $REPORT =~ m/noise_double_switching_on_clock/) { #if no. of lines in report is >15 and non-empty and doesnot start with '1'
                my ($temp, $VICTIM, $DIRECTION, $ACT_BUMP, $REQ_BUMP, $SLACK) = split(/\s+/); #split report columns
                $worst_violator = $VICTIM if ($worst_violator =~ m/^\s*$/ or $SLACK < $worst_violation);
                $worst_violation = $SLACK if ($SLACK < $worst_violation);
                $violation_counter++;
            }
            $line_in_report++;
        }
        if ($line_in_report == 11 or $line_in_report == 12) {
		print $OUT_FILE "\t-Clean\n"; 
		if ($REPORT =~ m/noise_double_switching_on_clock/) {
			$Check_noise_double_switching_clk{$STA_RUN} = 0;
		} else {
			$Check_noise_double_switching{$STA_RUN} = 0;
	        }
	}
        else {
            if ($error_flag == 0 && $STA_RUN =~ m/typ/) {
                $error_flag = 2; #this means report warnings (not error). Used when typ corner has violations.
		if ($REPORT =~ m/noise_double_switching_on_clock/) {
			$Check_noise_double_switching_clk{$STA_RUN} = 0;
		} else {
			$Check_noise_double_switching{$STA_RUN} = 0;
		}
            } else {
                $error_flag = 1; #this means errors detected
		if ($REPORT =~ m/noise_double_switching_on_clock/) {
			$Check_noise_double_switching_clk{$STA_RUN} = 1;
			$num_Check_noise_double_switching_clk{$STA_RUN} = $violation_counter;
		} else {
			$Check_noise_double_switching{$STA_RUN} = 1;
			$num_Check_noise_double_switching{$STA_RUN} = $violation_counter;
		}
            }
            print $OUT_FILE "\t-Number of violations  $violation_counter\n";
            print $OUT_FILE "\t-Worst violator  $worst_violator ($worst_violation)\n";
        }

        close REPORT;
        closedir DIR;
#        }
    }
    return $error_flag;
} #sub check_noise


sub check_nonCTS {

    my $error_flag = 0;
    my ($OUT_FILE, $REPORT, @STA_RUNS) = (@_);

    foreach (@STA_RUNS) {
        my $STA_RUN = $_;

	##($REPORT =~ m/NonCTSCell/ && $STA_RUN =~ m/typ/ )
        if ($REPORT =~ m/NonCTSCell/ ) {
            if (open (REPORT, "$STA_RUN/NonCTSCell.rpt")) {
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename:\n";
            } else {
                print $OUT_FILE "\nError: Cannot open $STA_RUN/NonClkCell.list";
                $error_flag = 1;
		$Check_nonCTS{$STA_RUN} = 2;
                next;
            }
            my $line_in_report = 0;
            my $violation_counter = 0;
            my $uoruxorCell_counter = 0;

            my $filename = fileparse($STA_RUN);

            #print "$STA_RUN/$REPORT\n";
            while(<REPORT>) {
                if ($_ =~ m/Not allowed/) {
                    if ($line_in_report > 0 and $_ !~ m/^\s*$/ and $_ !~ m/^1$/ and $_ =~ m/uor|uxor/)        {
                        $uoruxorCell_counter++;
                    } elsif ($line_in_report > 0 and $_ !~ m/^\s*$/ and $_ !~ m/^1$/)        {
                        $violation_counter++;
                    }
                    $line_in_report++;
                }
            }
	    my @info = ($uoruxorCell_counter);
            if ($line_in_report == 0 || ( $violation_counter == 0 && $uoruxorCell_counter == 0 ) ) {
                print $OUT_FILE "\t-Clean";
		$Check_nonCTS{$STA_RUN} = 0;
            } else {
                if ($violation_counter == 0 && $uoruxorCell_counter != 0 ) {
                    $error_flag = 2;
		    $Check_nonCTS{$STA_RUN} = 0;
		    $num_Check_nonCTS{$STA_RUN} = 0;
		    $sum_Check_nonCTS{$STA_RUN}->[0] = $uoruxorCell_counter;
                } else {
                    $error_flag = 1;
		    $Check_nonCTS{$STA_RUN} = 1;
		    $num_Check_nonCTS{$STA_RUN} = $violation_counter;
		    $sum_Check_nonCTS{$STA_RUN}->[0] = $uoruxorCell_counter;
                }
		#print $OUT_FILE "\t-Error: Number of NonCTS cell: $violation_counter\n" if ($error_flag == 1);
		#print $OUT_FILE "\t-Warning: Number of *uor*,*uxor* cell: $uoruxorCell_counter\n";
		
            }
            close REPORT;
        }
    }

    return $error_flag;

} #sub check_nonCTS


sub check_clkTranNoneClkBuf {
    my $error_flag = 0;
    my ($OUT_FILE, $REPORT, @STA_RUNS) = (@_);

    foreach (@STA_RUNS) {
        my $STA_RUN = $_;

        #opendir(DIR,"$STA_RUN") or die "opening directory failed:$!";
        #while(my $file=readdir(DIR)) {
        #        if ($file =~ m/noneClkBufList/) {
        #                $REPORT = $file;
        #        }
        #}
	if ($STA_RUN =~ m/typ8/) {
            if ( open (REPORT,"$STA_RUN/clkTransition_typ85_noneClkBufList.rpt") ) {
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename:\n";
            } else {
                print $OUT_FILE "\nError: Cannot open $STA_RUN/report/$REPORT.rpt\n";
                $error_flag = 1;
		$Check_clkTranNoneClkBuf{$STA_RUN} = 2;
                next;
            }

            my $line_in_report = 0;
            my $violation_counter = 0;

            while (<REPORT>) {
                if ($_ !~ m/\#/) {
                    $violation_counter++;
                }
            }
            if ($violation_counter != 0) {
                $error_flag = 1;
		$Check_clkTranNoneClkBuf{$STA_RUN} = 1;
		$num_Check_clkTranNoneClkBuf{$STA_RUN} = $violation_counter;
                print $OUT_FILE "\t-Error: Number of NoneClkBufList: $violation_counter\n ";
            } else {
                print $OUT_FILE "\t-Clean;\n";
		$Check_clkTranNoneClkBuf{$STA_RUN} = 0;
            }
            close(REPORT);
	} else {
	    $Check_clkTranNoneClkBuf{$STA_RUN} = 2;
	}
    }
    return $error_flag;

}

sub check_min_pulse {

    my $error_flag = 0;
    my $error_found = 0;
    my ($OUT_FILE, $REPORT, @STA_RUNS) = (@_);
    foreach (@STA_RUNS) {
        my $violation_counter = 0;
        $error_found = 0;
        my $STA_RUN = $_;

        if ($REPORT =~ m/pulse/) { #if pulse is specified, then open pulse width report
            if (open (REPORT, "$STA_RUN/report/allv_min_pulse_width.rpt")) {
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename:\n";
		#print  "\nChecking $filename:\n";
            } else {
                print $OUT_FILE "\nError: Cannot open $STA_RUN/report/allv_min_pulse_width.rpt\n";
                $error_flag = 1;
                $Check_min_pulse{$STA_RUN} = 2;
                next;
            }
        }
        elsif ($REPORT =~ m/period/) { #if period is specified, then open clock period report
            if (open (REPORT, "$STA_RUN/report/allv_min_period.rpt")) {
                my $filename = fileparse($STA_RUN);
                print $OUT_FILE "\nChecking $filename:\n";
            } else {
                print $OUT_FILE "\nError: Cannot open $STA_RUN/report/allv_min_period.rpt\n";
                $error_flag = 1;
                $Check_min_period{$STA_RUN} = 2;
                next;
            }
        }

        my $line_in_report = 0;
        while(<REPORT>) {
            $line_in_report++; #count the number of lines in report
            if (/VIOLATED/) {
                $error_found = 1;
		$violation_counter++;
            }
        }
        close REPORT;
        if ($error_found == 0) {
            print $OUT_FILE "\t-Clean\n";
	    if ($REPORT =~ m/pulse/) {
            	$Check_min_pulse{$STA_RUN} = 0;
            	$num_Check_min_pulse{$STA_RUN} = 0;
	    } else {
		$Check_min_period{$STA_RUN} = 0;
		$num_Check_min_period{$STA_RUN} = 0;
            }
        } else {
            $error_flag = 1;
            if ($REPORT =~ m/pulse/) {
            	$Check_min_pulse{$STA_RUN} = 1;
            	$num_Check_min_pulse{$STA_RUN} = $violation_counter;
	    } else {
		$Check_min_period{$STA_RUN} = 1;
		$num_Check_min_period{$STA_RUN} = $violation_counter;
            }
            print $OUT_FILE "\t-Errors detected. Check report for more details\n";
        }

    }
    return $error_flag;
} #sub check_min_pulse



sub generate_sanity_table {
   my ($mode, @table_sta_runs) = @_;
   my $co;
   my $table_width = ($#table_sta_runs + 1) * 150 + 250 ;
   print $HTML_FILE "<button type=\"button\" onclick=\"document.getElementById(\'${mode}_sanity_table\').style.display=\'none\'\">\n";
   print $HTML_FILE "Hide Sanity Table\n";
   print $HTML_FILE "</button>\n";

   print $HTML_FILE "<button type=\"button\" onclick=\"document.getElementById(\'${mode}_sanity_table\').style.display=\'table\'\">\n";
   print $HTML_FILE "Show Sanity Table\n";
   print $HTML_FILE "</button>\n";


   print $HTML_FILE "<table id=\'${mode}_sanity_table\' border=\"1\" width=${table_width}px>\n";
   print $HTML_FILE "<caption><em> $mode Sanity Checks </caption></em>\n";

   print $HTML_FILE "<tr>\n";
   print $HTML_FILE "<td width=250px>Check Type</td>\n";
   foreach $co (sort(@table_sta_runs)) {
           my $filename = fileparse($co);
           print $HTML_FILE "<td width=180px bgcolor = \"yellow\">$filename</td>\n";
   }
    #--------------------------- 
    #generate check_runlog table
    #--------------------------- 
    generate_tr("runlog", "run.log", \%Check_runlog, \%num_Check_runlog, @table_sta_runs);
    #---------------------------	
    #generate check_sdclog table
    #---------------------------	
    generate_tr("sdclog", "*sdc*log", \%Check_sdclog, \%num_Check_sdclog, @table_sta_runs);
    #---------------------------	
    #generate check_RC table
    #---------------------------	
    generate_tr("parasitics", "parasitics_command.log", \%Check_RC, \%num_Check_RC, @table_sta_runs);
    #------------------------------------------------
    #report/not_annotated_pin_to_pin_parasitics table
    #------------------------------------------------	
    generate_tr("annotated_p2p", "report/not_annotated_pin_to_pin_parasitics_*", \%Check_annotated, \%num_Check_annotated, @table_sta_runs);
    #------------------------------------------------
    #report/not_annotated_cell_pocv table
    #------------------------------------------------	
    generate_tr("annotated_pocv", "report/not_annotated_cell_pocv_*", \%Check_annotated_pocv, \%num_Check_annotated_pocv, @table_sta_runs);
    #------------------------------------------------
    #report/*_checkConstraints.rpt table
    #------------------------------------------------	
    generate_tr("constraint", "report/*checkConstraints.rpt", \%Check_constraint, \%num_Check_constraint, @table_sta_runs);
    #------------------------------------------------
    #report/*_checkTiming.rpt table
    #------------------------------------------------	
    generate_tr("CheckTiming","report/*checkTiming.rpt", \%Check_timing_report, \%Check_timing_report, @table_sta_runs);
    #------------------------------------------------
    #report/*_noclk table
    #------------------------------------------------	
    generate_tr("noclk_report", "report/*noclk.rpt", \%Noclk_report, \%num_Noclk_report, @table_sta_runs);
    #------------------------------------------------	
    #report/drc_transition report
    #------------------------------------------------	
    generate_tr("clk_transition", "*violationSummary.rpt", \%Check_clktransition, \%num_Check_clktransition, @table_sta_runs);
    #------------------------------------------------	
    #report/drc_transition report
    #------------------------------------------------	
    generate_tr("drc_transition", "report/drc_transition*valid.rpt", \%Check_trans_data, \%num_Check_trans_data, @table_sta_runs);
    #------------------------------------------------	
    #report/drc_capacitance report
    #------------------------------------------------	
    generate_tr("drc_capacitance", "report/drc_capacitance*valid.rpt", \%Check_trans_cap, \%num_Check_trans_cap, @table_sta_runs);
    #------------------------------------------------	
    #report/si_bottleneck report
    #------------------------------------------------	
    generate_tr("si_bottleneck", "report/report_si_bottleneck_min_fast*.rpt:report/report_si_bottleneck_max_fast*.rpt:report/report_si_bottleneck_min_slow*.rpt:report/report_si_bottleneck_max_slow*.rpt:report/report_si_bottleneck_min_typ*.rpt:report/report_si_bottleneck_max_typ*.rpt", \%Check_si, \%num_Check_si, @table_sta_runs);
    #------------------------------------------------	
    #report/si_bottleneck with clock report
    #------------------------------------------------	
    generate_tr("si_bottleneck_clk", "report/report_si_bottleneck_min_with_clock_fast*.rpt:report/report_si_bottleneck_max_with_clock_fast*.rpt:report/report_si_bottleneck_min_with_clock_slow*.rpt:report/report_si_bottleneck_max_with_clock_slow*.rpt:report/report_si_bottleneck_min_with_clock_typ*.rpt:report/report_si_bottleneck_max_with_clock_typ*.rpt", \%Check_si_clk, \%num_Check_si_clk, @table_sta_runs);
    #------------------------------------------------	
    #report/clk_xtalk report
    #------------------------------------------------	
    generate_tr("clk_xtalk", "report/clk_xtalk_*.rpt", \%Check_clk_xtalk, \%num_Check_clk_xtalk, @table_sta_runs);
    #------------------------------------------------	
    #report/noise report
    #------------------------------------------------	
    generate_tr("noise", "report/noise_at_end*", \%Check_noise, \%num_Check_noise, @table_sta_runs);
    #------------------------------------------------	
    #report/noise double switching report
    #------------------------------------------------	
    generate_tr("noise_double_sw", "report/noise_double_switching_fast*:report/noise_double_switching_slow*:report/noise_double_switching_typ*", \%Check_noise_double_switching, \%num_Check_noise_double_switching, @table_sta_runs);
    #------------------------------------------------	
    #report/noise double switching on clock report
    #------------------------------------------------	
    generate_tr("noise_double_sw_clk", "report/noise_double_switching_on_clock_fast*:report/noise_double_switching_on_clock_slow*:report/noise_double_switching_on_clock_typ*", \%Check_noise_double_switching_clk, \%num_Check_noise_double_switching_clk, @table_sta_runs);
    #------------------------------------------------	
    #report/nonCTS report
    #------------------------------------------------	
    generate_tr("nonCTS", "NonCTSCell.rpt", \%Check_nonCTS, \%num_Check_nonCTS, @table_sta_runs);
    #------------------------------------------------	
    #report/nonCLK report
    #------------------------------------------------	
    generate_tr("nonCLK", "clkTransition_*_noneClkBufList.rpt", \%Check_clkTranNoneClkBuf, \%num_Check_clkTranNoneClkBuf, @table_sta_runs);
    #------------------------------------------------	
    #report/allv_min_pulse_width report
    #------------------------------------------------	
    generate_tr("min pulse", "report/allv_min_pulse_width.rpt", \%Check_min_pulse, \%num_Check_min_pulse, @table_sta_runs);
    #------------------------------------------------	
    #report/allv_min_period report
    #------------------------------------------------	
    generate_tr("min period", "report/allv_min_period.rpt", \%Check_min_period, \%num_Check_min_period, @table_sta_runs);

    print $HTML_FILE "</table>\n";
    print $HTML_FILE "<script language=\"JavaScript\">\n";
    print $HTML_FILE "document.getElementById(\'${mode}_sanity_table\').style.display=\'display\';\n";
    print $HTML_FILE "</script>\n";
} #generate_sanity_table

sub generate_tr {
    my ($text, $Check_file_glob, $Result, $Error_num, @tr_sta_runs) = @_; 
    my  $temp = $Check_file_glob;
    my @Check_file;
    if ( $Check_file_glob =~ /:/) {
    	    @Check_file = split(/:/, $Check_file_glob);
	    } else {
	    push (@Check_file,($temp));
	    }
    my $co;
    print $HTML_FILE "<tr>\n";
    print $HTML_FILE "<td>$text</td>\n";
    foreach $co (sort(@tr_sta_runs)) {
	#print "DEBUGGING: $co\n";
        my $result = $Result->{$co};
	#if (defined($Error_num->{$co})) {
        	$error_num = $Error_num->{$co};
		#}		
        my $ff;
	my @check_file_full;
	#print @Check_file;
	#print "\n";
	foreach $ff (@Check_file) {
		push(@check_file_full, (glob("$co/$ff"))); 
	}
	generate_td($text, $co, $result, $error_num, @check_file_full);
	#print "@check_file_full\n";
    }
    print $HTML_FILE "</tr>\n";


}
sub generate_td {
	my ($txt, $corner, $re, $er, @check_file) = @_;
	#print "$txt\n";
	#print "@check_file\n";
    	if (defined($check_file[0])) {
		if ($txt eq "si_bottleneck") {
		    if ($Check_si_type{$corner} =~ m/max/) {
		        @check_file = grep {$_ =~ m/max/} @check_file;	    
		    } else {
			@check_file = grep {$_ =~ m/min/} @check_file;
                    }

		}
                if ($txt eq "si_bottleneck_clk") {
		    if ($Check_si_clk_type{$corner} =~ m/max/) {
		        @check_file = grep {$_ =~ m/max/} @check_file;	    
		    } else {
			@check_file = grep {$_ =~ m/min/} @check_file;
                    }

		}
		my $ff;
		@check_file = grep {$_ !~ m/not_valid/} @check_file;
		@check_file = grep {$_ !~ m/verbose/} @check_file;
        	if ($re == 0)  { 
		    print $HTML_FILE "<td bgcolor = \"lightgreen\">";
		    foreach $ff (@check_file) {
		        print $HTML_FILE "<a href= \"$ff\">Clean</a>";
		    }
		    print $HTML_FILE "</td>\n";
		} else {
		    if ($re == 2) {
                        print $HTML_FILE "<td bgcolor = \"lightgreen\">";
		    } else {
			    #print "$txt\n";
			if ($er == 0) {
				print $HTML_FILE "<td bgcolor = \"lightgreen\">";
			} else {
                        	print $HTML_FILE "<td bgcolor = \"lightpink\">";
			}
		    }
		    foreach $ff (@check_file) {
			if (defined($er)) {
			    print $HTML_FILE "<a href= \"$ff\">$er </a>";
			} else {
			    if ($re == 1) { print $HTML_FILE "<a href= \"$ff\">Error </a>";}	
			    if ($re == 2) { print $HTML_FILE "<a href= \"$ff\">No Check </a>";}	
			}
		    }
		    print $HTML_FILE "</td>\n";
        	}
        } else {
            	 print $HTML_FILE "<td bgcolor = \"CornflowerBlue\">No result</td>\n";
        }
}

sub generate_timing_table {
   my $co;
   my ($rpt_type, $mode) = (@_);
   my @co_list;
   my @co_hide_io_list;
   if ($mode =~ m/Func/) {
   	@co_list = grep {$_ !~ m/shift/} grep {$_ !~ m/capture/ } keys(%run_corners);
   }
   if ($mode =~ m/Capture/) {
   	@co_list = grep {$_ =~ m/capture/ } keys(%run_corners);
   }
   if ($mode =~ m/Shift/) {
   	@co_list = grep {$_ =~ m/shift/ } keys(%run_corners);
   }
   
   #my $table_width = ($#co_list + 1) * 180 + 1400;
   print $HTML_FILE "<p>$rpt_type :</p>\n"; 
   print $HTML_FILE "<button type=\"button\" onclick=\"hide_all_tables(\'wns_${mode}_table\', \'nvp_${mode}_table\', \'tns_${mode}_table\', \'wns_${mode}_no_io_table\', \'nvp_${mode}_no_io_table\', \'tns_${mode}_no_io_table\')\">\n";
   print $HTML_FILE "Hide Timing Table\n";
   print $HTML_FILE "</button>\n";

   print $HTML_FILE "<button type=\"button\" onclick=\"checkradio(\'${mode}_group_type\', \'${mode}_table_type\', \'wns_${mode}_table\', \'nvp_${mode}_table\', \'tns_${mode}_table\', \'wns_${mode}_no_io_table\', \'nvp_${mode}_no_io_table\', \'tns_${mode}_no_io_table\')\">\n";
   print $HTML_FILE "Show Timing Table\n";
   print $HTML_FILE "</button>\n";
   print $HTML_FILE "<p>\n";
   print $HTML_FILE "</p>\n";
   print $HTML_FILE "<form name=\"If_IO_Groups\">\n";
   print $HTML_FILE "<input type=\"radio\" name=\"${mode}_group_type\" value=\"wns\" checked onclick=\"checkradio(\'${mode}_group_type\', \'${mode}_table_type\', \'wns_${mode}_table\', \'nvp_${mode}_table\', \'tns_${mode}_table\', \'wns_${mode}_no_io_table\', \'nvp_${mode}_no_io_table\', \'tns_${mode}_no_io_table\')\"/>Fiter IO Groups\n";
   print $HTML_FILE "<input type=\"radio\" name=\"${mode}_group_type\" value=\"wns\"  onclick=\"checkradio(\'${mode}_group_type\', \'${mode}_table_type\', \'wns_${mode}_table\', \'nvp_${mode}_table\', \'tns_${mode}_table\', \'wns_${mode}_no_io_table\', \'nvp_${mode}_no_io_table\', \'tns_${mode}_no_io_table\')\"/>Show IO Groups\n";
   print $HTML_FILE "</form>\n";

   print $HTML_FILE "<form name=\"Table_Type\">\n";
   print $HTML_FILE "<input type=\"radio\" name=\"${mode}_table_type\" value=\"wns\" checked onclick=\"checkradio(\'${mode}_group_type\', \'${mode}_table_type\', \'wns_${mode}_table\', \'nvp_${mode}_table\', \'tns_${mode}_table\',  \'wns_${mode}_no_io_table\', \'nvp_${mode}_no_io_table\', \'tns_${mode}_no_io_table\')\"/>wns\n";
   print $HTML_FILE "<input type=\"radio\" name=\"${mode}_table_type\" value=\"nvp\" onclick=\"checkradio(\'${mode}_group_type\', \'${mode}_table_type\', \'wns_${mode}_table\', \'nvp_${mode}_table\', \'tns_${mode}_table\',  \'wns_${mode}_no_io_table\', \'nvp_${mode}_no_io_table\', \'tns_${mode}_no_io_table\')\"/>nvp\n";
   print $HTML_FILE "<input type=\"radio\" name=\"${mode}_table_type\" value=\"tns\" onclick=\"checkradio(\'${mode}_group_type\', \'${mode}_table_type\', \'wns_${mode}_table\', \'nvp_${mode}_table\', \'tns_${mode}_table\', \'wns_${mode}_no_io_table\', \'nvp_${mode}_no_io_table\', \'tns_${mode}_no_io_table\')\"/>tns<br>\n";
   print $HTML_FILE "</form>\n";
   print $HTML_FILE "<script language=\"JavaScript\">\n";
   print $HTML_FILE "</script>\n";


   ##########################################
   ### generate timing table in NVP order ### 
   ##########################################
   @co_list = sort {$a cmp $b} @co_list;
    my @all_groups;
    #print "============================\n";
    foreach $co (@co_list) {
    	my %run_copy = %{$run_corners{$co}->{$rpt_type}}; 
    	my $group;
	#print Dumper($run_copy);
    	foreach $group (keys(%run_copy)) {
		#print "group: $group\n";
    		push (@all_groups, $group);
    	}
    }
   my %count;
   my @uni_groups = grep {++ $count{$_} == 1} @all_groups;
   my @len_groups ; 
   foreach my $gg_len (@uni_groups) {
	my $len = length($gg_len);
	#print "$gg_len: $len\n";
    	push (@len_groups, $len);
   }	   
   my @sorted_len_groups = sort {$b <=> $a} @len_groups;
   my $group_col_length = $sorted_len_groups[0] * 10;
   my $table_width = ($#co_list + 1) * 45 + $group_col_length ;
   print $HTML_FILE "<table id=\'nvp_${mode}_table\' border=\"2\" width=${table_width}px>\n";
   print $HTML_FILE "<caption><em> $mode Checks (NVP) </caption></em>\n";
   print $HTML_FILE "<tr>\n";
   print $HTML_FILE "<td width=${group_col_length}px>Groups</td>\n";
   foreach $co (@co_list) {
    	print $HTML_FILE "<td width = 110px ><a href = \"$STA_RUN_PATH/$co/report/allv_${rpt_type}_pba_exh.rpt\" style=\"font-size: 13px\">$co</a></td>\n";
   }
    print $HTML_FILE "</tr>\n";
    my @Nvps;
    #print "$rpt_type\n";
    #print "@all_groups\n";
    #print "============================\n";
    ### calculate every group's nvp, wns, tns in all corners
    foreach my $grp (@uni_groups) {
	    my $nvp = 0;
	    my $wns = 0;
	    my $tns = 0;
    	    foreach $co (@co_list) {
    		if (defined($run_corners{$co}->{$rpt_type}->{$grp}->[1])) {
			$nvp = $nvp + $run_corners{$co}->{$rpt_type}->{$grp}->[1];
		} else {
			$nvp = $nvp + 0;
		}
		if (defined($run_corners{$co}->{$rpt_type}->{$grp}->[2])) {
			$wns = $wns + $run_corners{$co}->{$rpt_type}->{$grp}->[2];
		} else {
			$wns = $wns + 0;
		}
		if (defined($run_corners{$co}->{$rpt_type}->{$grp}->[3])) {
			$tns = $tns + $run_corners{$co}->{$rpt_type}->{$grp}->[3];
		} else {
			$tns = $tns + 0;
		}
	    }
	    #print "$grp $nvp $wns $tns \n";
	    push @Nvps, [$grp, $nvp, $wns, $tns];
    }
    my @sorted_uni_groups = map {$_->[0]} sort {$b->[1] <=> $a->[1]} @Nvps;     #group order in nvp
    my @wns_sorted_uni_groups = map {$_->[0]} sort {$a->[2] <=> $b->[2]} @Nvps; #group order in wns
    my @tns_sorted_uni_groups = map {$_->[0]} sort {$a->[3] <=> $b->[3]} @Nvps; #group order in tns
    #print "@sorted_uni_groups \n";
    my $group;
    #print "@sorted_uni_groups\n";
    foreach $group (@sorted_uni_groups) {
	    #print "$group \n";
        if ($group !~ m/anything_which_want_to_filter/) {
    	print $HTML_FILE "<tr>\n";
    	print $HTML_FILE "<td>$group</td>\n";
    	foreach $co (@co_list) {
    		if (defined($run_corners{$co}->{$rpt_type}->{$group}->[1])) {
			if ($co =~ m/fast125.si_pocv_cbest125_vdd0.88/) {
				#print "$group $co \n";
				#print "$run_corners{$co}->{$rpt_type}->{$group}->[1]\n";
			}
			printf $HTML_FILE "<td bgcolor = \"lightpink\">%5d</td>\n",$run_corners{$co}->{$rpt_type}->{$group}->[1];} else
    		{print $HTML_FILE "<td bgcolor = \"lightgreen\">0</td>\n";}
    	}
    	print $HTML_FILE "</tr>\n";
        }
    }
    print $HTML_FILE "</table>\n";
   
   ##########################################
   ### generate timing table in WNS order ### 
   ##########################################
   print $HTML_FILE "<table id=\'wns_${mode}_table\' border=\"2\" width=${table_width}px>\n";
   print $HTML_FILE "<caption><em> $mode Checks (WNS)</caption></em>\n";
   print $HTML_FILE "<tr>\n";
   print $HTML_FILE "<td width=${group_col_length}px>Groups</td>\n";

    foreach $co (@co_list) {
    	#print "==================== DEBUG co : $co\n";
    	print $HTML_FILE "<td width = 110px><a href = \"$STA_RUN_PATH/$co/report/allv_${rpt_type}_pba_exh.rpt\" style=\"font-size: 13px\">$co</a></td>\n";
    	my $run_copy = $run_corners{$co}; 
    	my $group;
    }
    print $HTML_FILE "</tr>\n";

    foreach $group (@wns_sorted_uni_groups) {
	    #print "$group \n";
        if ($group !~ m/anything_which_want_to_filter/) {
    	print $HTML_FILE "<tr>\n";
    	print $HTML_FILE "<td>$group</td>\n";
    	foreach $co (@co_list) {
    		if (defined($run_corners{$co}->{$rpt_type}->{$group}->[2])) {
			if ($co =~ m/fast125.si_pocv_cbest125_vdd0.88/) {
				#print "$group $co \n";
				#print "$run_corners{$co}->{$rpt_type}->{$group}->[2]\n";
			}
			#if ($co =~ m/fast125.si_pocv_rcworst125_vdd0.88/) {
			#	print "$group $run_corners{$co}->{$rpt_type}->{$group}->[2] $run_corners{$co}->{$rpt_type}->{$group}->[3]\n";
			#}
			printf $HTML_FILE "<td bgcolor = \"lightpink\">%4.3f </td>\n", $run_corners{$co}->{$rpt_type}->{$group}->[2];} else
    		{print $HTML_FILE "<td bgcolor = \"lightgreen\">0</td>\n";}
    	}
    	print $HTML_FILE "</tr>\n";
        }
    }
    print $HTML_FILE "</table>\n";

   ##########################################
   ### generate timing table in TNS order ### 
   ##########################################
   print $HTML_FILE "<table id=\'tns_${mode}_table\' border=\"2\" width=${table_width}px>\n";
   print $HTML_FILE "<caption><em> $mode Checks (TNS)</caption></em>\n";
   print $HTML_FILE "<tr>\n";
   print $HTML_FILE "<td width=${group_col_length}px>Groups</td>\n";

    foreach $co (@co_list) {
    	#print "==================== DEBUG co : $co\n";
    	print $HTML_FILE "<td width = 110px><a href = \"$STA_RUN_PATH/$co/report/allv_${rpt_type}_pba_exh.rpt\" style=\"font-size: 13px\">$co</a></td>\n";
    	my $run_copy = $run_corners{$co}; 
    	my $group;
    }
    print $HTML_FILE "</tr>\n";

    foreach $group (@tns_sorted_uni_groups) {
	    #print "$group \n";
        if ($group !~ m/anything_which_want_to_filter/) {
    	print $HTML_FILE "<tr>\n";
    	print $HTML_FILE "<td>$group</td>\n";
    	foreach $co (@co_list) {
    		if (defined($run_corners{$co}->{$rpt_type}->{$group}->[3])) {
			#if ($co =~ m/fast125.si_pocv_rcworst125_vdd0.88/) {
			#	print "$group $run_corners{$co}->{$rpt_type}->{$group}->[2] $run_corners{$co}->{$rpt_type}->{$group}->[3]\n";
			#}
			printf $HTML_FILE "<td bgcolor = \"lightpink\">%4.3f </td>\n", $run_corners{$co}->{$rpt_type}->{$group}->[3];} else
    		{print $HTML_FILE "<td bgcolor = \"lightgreen\">0</td>\n";}
    	}
    	print $HTML_FILE "</tr>\n";
        }
    }
    print $HTML_FILE "</table>\n";
   ##############################################################
   ### generate timing table in NVP order filtering io groups ### 
   ##############################################################
   print $HTML_FILE "<table id=\'nvp_${mode}_no_io_table\' border=\"2\" width=${table_width}px>\n";
   print $HTML_FILE "<caption><em> $mode Checks (NVP) (Filter IO)</caption></em>\n";
   print $HTML_FILE "<tr>\n";
   print $HTML_FILE "<td width=${group_col_length}px>Groups</td>\n";

    foreach $co (@co_list) {
    	#print "==================== DEBUG co : $co\n";
    	print $HTML_FILE "<td width = 110px><a href = \"$STA_RUN_PATH/$co/report/allv_${rpt_type}_pba_exh.rpt\" style=\"font-size: 13px\">$co</a></td>\n";
    	my $run_copy = $run_corners{$co}; 
    	my $group;
    }
    print $HTML_FILE "</tr>\n";
    @nvp_sorted_hide_io_groups = grep {$_ !~ m/in2out/} grep {$_ !~ m/reg2out/} grep {$_ !~ m/io_/} grep {$_ !~ m/Reg2Out/} grep {$_ !~ m/In2Reg/} grep {$_ !~ m/input2reg/} @sorted_uni_groups;
    foreach $group (@nvp_sorted_hide_io_groups) {
        if ($group !~ m/anything_which_want_to_filter/) {
    	print $HTML_FILE "<tr>\n";
    	print $HTML_FILE "<td>$group</td>\n";
    	foreach $co (@co_list) {
    		if (defined($run_corners{$co}->{$rpt_type}->{$group}->[1])) {
			printf $HTML_FILE "<td bgcolor = \"lightpink\">%5d </td>\n", $run_corners{$co}->{$rpt_type}->{$group}->[1];} else
    		{print $HTML_FILE "<td bgcolor = \"lightgreen\">0</td>\n";}
    	}
    	print $HTML_FILE "</tr>\n";
        }
    }
    print $HTML_FILE "</table>\n";

   ##############################################################
   ### generate timing table in WNS order filtering io groups ### 
   ##############################################################
   print $HTML_FILE "<table id=\'wns_${mode}_no_io_table\' border=\"2\" width=${table_width}px>\n";
   print $HTML_FILE "<caption><em> $mode Checks (WNS) (Filter IO)</caption></em>\n";
   print $HTML_FILE "<tr>\n";
   print $HTML_FILE "<td width=${group_col_length}px>Groups</td>\n";

    foreach $co (@co_list) {
    	#print "==================== DEBUG co : $co\n";
    	print $HTML_FILE "<td width = 110px><a href = \"$STA_RUN_PATH/$co/report/allv_${rpt_type}_pba_exh.rpt\" style=\"font-size: 13px\">$co</a></td>\n";
    	my $run_copy = $run_corners{$co}; 
    	my $group;
    }
    print $HTML_FILE "</tr>\n";
    @wns_sorted_hide_io_groups = grep {$_ !~ m/in2out/} grep {$_ !~ m/reg2out/} grep {$_ !~ m/io_/} grep {$_ !~ m/Reg2Out/} grep {$_ !~ m/In2Reg/} grep {$_ !~ m/input2reg/} @wns_sorted_uni_groups;
    foreach $group (@wns_sorted_hide_io_groups) {
	    #print "$group \n";
        if ($group !~ m/anything_which_want_to_filter/) {
    	print $HTML_FILE "<tr>\n";
    	print $HTML_FILE "<td>$group</td>\n";
    	foreach $co (@co_list) {
    		if (defined($run_corners{$co}->{$rpt_type}->{$group}->[2])) {
			printf $HTML_FILE "<td bgcolor = \"lightpink\">%4.3f </td>\n", $run_corners{$co}->{$rpt_type}->{$group}->[2];} else
    		{print $HTML_FILE "<td bgcolor = \"lightgreen\">0</td>\n";}
    	}
    	print $HTML_FILE "</tr>\n";
        }
    }
    print $HTML_FILE "</table>\n";

   ##############################################################
   ### generate timing table in TNS order filtering io groups ### 
   ##############################################################
   print $HTML_FILE "<table id=\'tns_${mode}_no_io_table\' border=\"2\" width=${table_width}px>\n";
   print $HTML_FILE "<caption><em> $mode Checks (TNS) (Filter IO)</caption></em>\n";
   print $HTML_FILE "<tr>\n";
   print $HTML_FILE "<td width=${group_col_length}px>Groups</td>\n";

    foreach $co (@co_list) {
    	#print "==================== DEBUG co : $co\n";
    	print $HTML_FILE "<td width = 110px><a href = \"$STA_RUN_PATH/$co/report/allv_${rpt_type}_pba_exh.rpt\" style=\"font-size: 13px\">$co</a></td>\n";
    	my $run_copy = $run_corners{$co}; 
    	my $group;
    }
    print $HTML_FILE "</tr>\n";
    @tns_sorted_hide_io_groups = grep {$_ !~ m/in2out/} grep {$_ !~ m/reg2out/} grep {$_ !~ m/io_/} grep {$_ !~ m/Reg2Out/} grep {$_ !~ m/In2Reg/} grep {$_ !~ m/input2reg/} @tns_sorted_uni_groups;
    foreach $group (@tns_sorted_hide_io_groups) {
	    #print "$group \n";
        if ($group !~ m/anything_which_want_to_filter/) {
    	print $HTML_FILE "<tr>\n";
    	print $HTML_FILE "<td>$group</td>\n";
    	foreach $co (@co_list) {
    		if (defined($run_corners{$co}->{$rpt_type}->{$group}->[3])) {
			printf $HTML_FILE "<td bgcolor = \"lightpink\">%4.3f </td>\n", $run_corners{$co}->{$rpt_type}->{$group}->[3];} else
    		{print $HTML_FILE "<td bgcolor = \"lightgreen\">0</td>\n";}
    	}
    	print $HTML_FILE "</tr>\n";
        }
    }
    print $HTML_FILE "</table>\n";




print $HTML_FILE "<script language=\"JavaScript\">\n";

print $HTML_FILE "document.getElementById(\'wns_${mode}_table\').style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(\'nvp_${mode}_table\').style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(\'tns_${mode}_table\').style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(\'wns_${mode}_no_io_table\').style.display=\'display\';\n";
print $HTML_FILE "document.getElementById(\'nvp_${mode}_no_io_table\').style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(\'tns_${mode}_no_io_table\').style.display=\'none\';\n";


print $HTML_FILE "function hide_all_tables(id0, id1, id2, id3, id4, id5){\n";
print $HTML_FILE "document.getElementById(id0).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id1).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id2).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id3).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id4).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id5).style.display=\'none\';\n";
print $HTML_FILE "}\n";

print $HTML_FILE "function checkradio(name0, name1, id0, id1, id2, id3, id4, id5){\n";

print $HTML_FILE "var ay0=document.getElementsByName(name0)[0];\n";
print $HTML_FILE "var ay1=document.getElementsByName(name0)[1];\n";
print $HTML_FILE "var by0=document.getElementsByName(name1)[0];\n";
print $HTML_FILE "var by1=document.getElementsByName(name1)[1];\n";
print $HTML_FILE "var by2=document.getElementsByName(name1)[2];\n";

print $HTML_FILE "if(ay1.checked){\n";
print $HTML_FILE "if(by0.checked){\n";
print $HTML_FILE "document.getElementById(id2).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id1).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id0).style.display=\'table\';\n";
print $HTML_FILE "document.getElementById(id5).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id4).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id3).style.display=\'none\';\n";
print $HTML_FILE "}\n";

print $HTML_FILE "if(by1.checked){\n";
print $HTML_FILE "document.getElementById(id2).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id1).style.display=\'table\';\n";
print $HTML_FILE "document.getElementById(id0).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id5).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id4).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id3).style.display=\'none\';\n";
print $HTML_FILE "}\n";

print $HTML_FILE "if(by2.checked){\n";
print $HTML_FILE "document.getElementById(id2).style.display=\'table\';\n";
print $HTML_FILE "document.getElementById(id1).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id0).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id5).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id4).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id3).style.display=\'none\';\n";
print $HTML_FILE "}\n";
print $HTML_FILE "}\n";

print $HTML_FILE "if(ay0.checked){\n";
print $HTML_FILE "if(by0.checked){\n";
print $HTML_FILE "document.getElementById(id5).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id4).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id3).style.display=\'table\';\n";
print $HTML_FILE "document.getElementById(id2).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id1).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id0).style.display=\'none\';\n";
print $HTML_FILE "}\n";

print $HTML_FILE "if(by1.checked){\n";
print $HTML_FILE "document.getElementById(id5).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id4).style.display=\'table\';\n";
print $HTML_FILE "document.getElementById(id3).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id2).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id1).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id0).style.display=\'none\';\n";
print $HTML_FILE "}\n";

print $HTML_FILE "if(by2.checked){\n";
print $HTML_FILE "document.getElementById(id5).style.display=\'table\';\n";
print $HTML_FILE "document.getElementById(id4).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id3).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id2).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id1).style.display=\'none\';\n";
print $HTML_FILE "document.getElementById(id0).style.display=\'none\';\n";
print $HTML_FILE "}\n";

print $HTML_FILE "}\n";

print $HTML_FILE "}\n";
print $HTML_FILE "</script>\n";


   ##################################################
   ### generate summary timing table in WNS order ### 
   ##################################################
   if ($mode =~ m/Func/) {
   my $summary_table_width = 2 * 180 + ${group_col_length};
   print $HTML_FILE "<table id=\'wns_${mode}_sum_table\' border=\"2\" width=${summary_table_width}px>\n";
   print $HTML_FILE "<caption><em> $mode Checks Summary (TNS)</caption></em>\n";
   print $HTML_FILE "<tr>\n";
   print $HTML_FILE "<td width=${group_col_length}px>Groups</td>\n";
   my $worst_co ;
       if ($rpt_type =~ m/setup/) {
           $worst_co = $setup_keys_sorted_by_tns[0];
       } else {
	   $worst_co = $hold_keys_sorted_by_tns[0];
       }
   print "Worst corner :  $worst_co \n ";
   print $HTML_FILE "<td width = 180px><a href = \"$STA_RUN_PATH/$worst_co/report/allv_${rpt_type}_pba_exh.rpt\" style=\"font-size: 13px\">$worst_co</a></td>\n";
   #my $run_copy = $run_corners{$co}; 
   #my $group;
   print $HTML_FILE "</tr>\n";

    foreach $group (@wns_sorted_hide_io_groups) {
            #print "$group \n";
        if ($group !~ m/anything_which_want_to_filter/) {
    	print $HTML_FILE "<tr>\n";
    	print $HTML_FILE "<td>$group</td>\n";
    		if (defined($run_corners{$worst_co}->{$rpt_type}->{$group}->[2])) {
        		printf $HTML_FILE "<td bgcolor = \"lightpink\">%4.3f\/%4.3f\/%d </td>\n", $run_corners{$worst_co}->{$rpt_type}->{$group}->[2], $run_corners{$worst_co}->{$rpt_type}->{$group}->[3], $run_corners{$worst_co}->{$rpt_type}->{$group}->[1];} else
    		{print $HTML_FILE "<td bgcolor = \"lightgreen\">0</td>\n";}
    	print $HTML_FILE "</tr>\n";
        }
    }
    print $HTML_FILE "</table>\n";
   }
   if ($mode =~ m/Shift/ && $rpt_type =~ m/hold/) {
   my $summary_table_width = 2 * 180 + $group_col_length;
   print $HTML_FILE "<table id=\'wns_${mode}_sum_table\' border=\"2\" width=${summary_table_width}px>\n";
   print $HTML_FILE "<caption><em> $mode Checks Summary (TNS)</caption></em>\n";
   print $HTML_FILE "<tr>\n";
   print $HTML_FILE "<td width=${group_col_length}px>Groups</td>\n";
   $worst_co = $shift_hold_keys_sorted_by_tns[0];
   print "Worst corner :  $worst_co \n ";
   print $HTML_FILE "<td width = 180px><a href = \"$STA_RUN_PATH/$worst_co/report/allv_${rpt_type}_pba_exh.rpt\" style=\"font-size: 13px\">$worst_co</a></td>\n";
   #my $run_copy = $run_corners{$co}; 
   #my $group;
   print $HTML_FILE "</tr>\n";

    foreach $group (@wns_sorted_hide_io_groups) {
            #print "$group \n";
        if ($group !~ m/anything_which_want_to_filter/) {
    	print $HTML_FILE "<tr>\n";
    	print $HTML_FILE "<td>$group</td>\n";
    		if (defined($run_corners{$worst_co}->{$rpt_type}->{$group}->[2])) {
        		printf $HTML_FILE "<td bgcolor = \"lightpink\">%4.3f\/%4.3f\/%d </td>\n", $run_corners{$worst_co}->{$rpt_type}->{$group}->[2], $run_corners{$worst_co}->{$rpt_type}->{$group}->[3], $run_corners{$worst_co}->{$rpt_type}->{$group}->[1];} else
    		{print $HTML_FILE "<td bgcolor = \"lightgreen\">0</td>\n";}
    	print $HTML_FILE "</tr>\n";
        }
    }
    print $HTML_FILE "</table>\n";
   }
} #generate_timing_table

#print Dumper(\%run_corners);
#print Dumper(\%sum_corners);
#print Dumper(\%num_Check_si_clk);
#print Dumper(\%Check_RC);
#print Dumper(\%num_Check_RC);
#print Dumper(\%Check_annotated);
#print Dumper(\%num_Check_min_pulse,);
#`awk '(NR>11) && (NR<30){print $0}' run/STA/dsp_ss/dsp_ss_DE1.0/slown40.si_pocv_rcworsttn40_setup_vdd0.72/report/qor_sum_pba_exh.rpt` ;
#
#my $qor_setup_lines = `awk \'(NR>11) && (NR<25){print \$0}\' run/STA/dsp_ss/dsp_ss_DE1.0/slown40.si_pocv_rcworsttn40_setup_vdd0.72/report/qor_sum_pba_exh.rpt` ;

#print "$qor_setup_lines \n";

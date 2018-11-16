#!/usr/bin/env perl
use strict;
use warnings;
use 5.008;

#*******************************************************************************************
# 1. Set FEDORA_HOME to Fedora install path (Where Fedora binaries are located)
#       export FEDORA_HOME="/opt/rails-apps/curate_app/jetty/fedora"
# 2. Execute above command before running this script
# 3. Extract PIDs of the files that you intend to extract in the form sufia:9z903118b and
#       save them in a file. Update $PIDFile accordingly.
# 4. Locate datastreamStore and update $datastreamPath accordingly.
# 5. Set $fedoraBin such that it is $FEDORA_HOME/client/bin
# 6. Create a directory where you want to export files and set $exportPath with the
#       absolute path of the directory that you just created
# 7. Set $port, $adminUser, $adminPass to Port, UID and Password of Fedora
# 8. Add & like "perl exportFiles.pl &" if you want to run this script in the background
#******************************************************************************************


my $PIDFile = "PIDs.txt";
my $datastreamPath = "/opt/rails-apps/curate_app/jetty/fedora/default/data/datastreamStore";
my $fedoraBin = "/opt/rails-apps/curate_app/jetty/fedora/client/bin";
my $exportPath = "/home/webapp/test";
my $port = 4001;
my $adminUser = "fedoraAdmin";
my $adminPass = "fedoraAdmin";


my @PIDandFileVersion;
my $start = 0.0;
my $end = 0.0;
my $total = 0.0;
my $pidCount = 0.0;


open(my $inputFile, $PIDFile) or die $!;
while(my $PID = <$inputFile>) {
        chomp $PID;
        $PIDandFileVersion[$.-1][0] = $PID;
        my $getVersionCmd = 'sh '.$fedoraBin.'/fedora-dsinfo.sh localhost '.$port.' '.$adminUser.' '.$adminPass.' '.$PID.' http | grep VERSION | grep content';
        $start = time;
        my $fileVersion = `$getVersionCmd`;
        $end = time;
        $total += $end - $start;
        chomp $fileVersion;
        $fileVersion = (split(/\n/, $fileVersion))[0];
        $fileVersion = (split(/:/, $fileVersion))[1];
        $fileVersion = (split(/\./, $fileVersion))[1];
        $PIDandFileVersion[$.-1][1] = $fileVersion;
        $pidCount += 1;
}


my $logFile = $exportPath.'/'.'export.log';
open (my $log, '>>', $logFile) or die $!;
foreach my $row (@PIDandFileVersion) {
        `mkdir $exportPath/@$row[0]`;
        my $ver = @$row[1];
        while($ver > -1) {
                `mkdir $exportPath/@$row[0]/$ver`;
                my $partialPID = (split(/:/,@$row[0]))[1];
                my $findFileCmd = 'find '.$datastreamPath.' -name "*'.$partialPID.'*content*'.$ver.'" -print';
                my $exportFile = `$findFileCmd`;
                chomp $exportFile;
                my $copyCMD = 'cp -p '.$exportFile.' '.$exportPath.'/'.@$row[0].'/'.$ver.'/';
                chomp $copyCMD;
                `$copyCMD`;

                my $newChecksum = 'md5sum '.$exportFile;
                $newChecksum = `$newChecksum`;
                $newChecksum = (split(/ /, $newChecksum))[0];
                chomp $newChecksum;

                my $oldChecksum = 'find '.$datastreamPath.' -name "*'.$partialPID.'*characterization*'.$ver.'" -exec grep \'md5checksum\' \{\} \;';
                $oldChecksum = `$oldChecksum`;
                $oldChecksum = (split(/>/, $oldChecksum))[1];
                $oldChecksum = (split(/</, $oldChecksum))[0];
                chomp $oldChecksum;
                if($oldChecksum eq $newChecksum) {
                        print $log @$row[0];
                        print $log " PASS\n";
                }
                else {
                        print $log @$row[0];
                        print $log " FAIL\n";
                }

                my $md5file1 = $exportPath.'/'.@$row[0].'/'.$ver.'/'.'oldChecksum.md5';
                my $md5file2 = $exportPath.'/'.@$row[0].'/'.$ver.'/'.'newChecksum.md5';
                open (my $md51, '>', $md5file1) or die $!;
                open (my $md52, '>', $md5file2) or die $!;
                print $md51 $oldChecksum;
                close $md51;
                print $md52 $newChecksum;
                close $md52;
                $ver--;
        }
}
close $inputFile;
close $log;

print 'Total time to extract '.$pidCount.' PID Versions: '.$total.' secs';
print "\n";
print 'Average time to extract each PID Version: ';
printf("%.3f",($total/$pidCount));
print ' secs';
print "\n";

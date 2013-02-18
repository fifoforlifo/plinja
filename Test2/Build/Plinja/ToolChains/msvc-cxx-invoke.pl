use strict;
use English;
use File::Slurp;
use Carp;

my ($workingDir, $srcFile, $objFile, $depFile, $logFile, $vsInstallDir, $arch, $rspFile) = @ARGV;

# validate environment
die "msvc is only usable on windows" if ($OSNAME ne "MSWin32");
if (scalar(@ARGV) != 8) {
    carp "invalid invocation, see script for required argument list";
}
if (!($arch eq "x86" || $arch eq "amd64")) {
    carp "invalid architecture";
}

sub isOs64Bit
{
    if (uc($ENV{PROCESSOR_ARCHITECTURE}) eq "AMD64" || uc($ENV{PROCESSOR_ARCHITEW6432}) eq "AMD64") {
        return 1;
    }
    return 0;
}

chdir($workingDir);

my $oldPath = $ENV{"PATH"};
$ENV{"INCLUDE"} = "$vsInstallDir\\VC\\include";
if ($arch eq "x86") {
    $ENV{"PATH"} = "$vsInstallDir\\VC\\bin;$vsInstallDir\\Common7\\IDE;$oldPath";
    $ENV{"LIB"} = "$vsInstallDir\\VC\\lib";
}
elsif ($arch eq "amd64") {
    if (isOs64Bit()) {
        $ENV{"PATH"} = "$vsInstallDir\\VC\\bin\\amd64;$vsInstallDir\\Common7\\IDE;$oldPath";
    }
    else {
        $ENV{"PATH"} = "$vsInstallDir\\VC\\bin\\x86_amd64;$vsInstallDir\\Common7\\IDE;$oldPath";
    }
    $ENV{"LIB"} = "$vsInstallDir\\VC\\lib\\amd64";
}

sub GenerateDeps
{
    my $ppFile = "$objFile.pp";
    my $siFile = "$objFile.si";
    my $cmd = "cl /showIncludes /E \"$srcFile\" \"\@$rspFile\"  1>\"$ppFile\" 2>\"$siFile\"";
    my $exitCode = system($cmd);
    if ($exitCode) {
        open(my $LOG, ">$logFile");
        my $log = read_file($siFile);
        print($LOG $log);
        print(STDERR $log);
        exit 1;
    }
    
    open(my $DEPS, ">$depFile") or die "failed to open depFile: $depFile";
    open(my $SI, "<$siFile") or die "failed to open showIncludes file: $siFile";
    print($DEPS "$objFile: \\\n");
    while (my $line = <$SI>) {
        if ($line =~ "Note: including file: ([ ]*)(.*)") {
            print($DEPS "$2 \\\n");
        }
    }
    print($DEPS "\n");
    close($SI);
    close($DEPS);
}

sub Compile()
{
    my $cmd = "cl \"$srcFile\" \"\@$rspFile\" \"/Fo$objFile\" > \"$logFile\" 2>&1";
    my $exitCode = system($cmd);
    if ($exitCode) {
        my $log = read_file($logFile);
        print(STDERR $log);
        exit 1;
    }
}

GenerateDeps();
Compile();

exit 0;
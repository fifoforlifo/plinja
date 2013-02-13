# Usage:
#   msvc-invoke  $srcFile  $depsFile  $$vsInstallDir  $arch  $options

use strict;
use English;
use File::Slurp;

my ($srcFile, $objFile, $depsFile, $logFile, $vsInstallDir, $arch, $rspFile) = @ARGV;

# validate environment
die "msvc is only usable on windows" if ($OSNAME ne "MSWin32");
die "missing srcFile arg" if (!$srcFile);
die "missing objFile arg" if (!$objFile);
die "missing depsFile arg" if (!$depsFile);
die "missing vsInstallDir arg" if (!$vsInstallDir);
die "missing arch arg" if (!$arch);
die "missing rspFile arg" if (!$rspFile);

my $oldPath = $ENV{"PATH"};
$ENV{"PATH"} = "$vsInstallDir\\VC\\bin;$vsInstallDir\\Common7\\IDE;$oldPath";
$ENV{"INCLUDE"} = "$vsInstallDir\\VC\\include";
if ($arch == "x86") {
    $ENV{"LIB"} = "$vsInstallDir\\VC\\lib";
}
elsif ($arch == "amd64") {
    $ENV{"LIB"} = "$vsInstallDir\\VC\\lib\\amd64";
}

sub GenerateDeps
{
    my $ppFile = "$srcFile.pp";
    my $siFile = "$srcFile.si";
    my $cmd = "cl /showIncludes /E $srcFile \@$rspFile  1>\"$ppFile\" 2>\"$siFile\"";
    my $exitCode = system($cmd);
    if ($exitCode) {
        open(my $LOG, ">$logFile");
        my $log = read_file($siFile);
        print($LOG $log);
        print(STDERR $log);
        exit 1;
    }
    
    open(my $DEPS, ">$depsFile") or die "failed to open depsFile: $depsFile";
    open(my $SI, "<$siFile") or die "failed to open showIncludes file: $siFile";
    print($DEPS "$objFile: \\\n");
    while (my $line = <$SI>) {
        if ($line =~ "Note: including file: ([ ]*)(.*)") {
            print($DEPS "$2 \\\n");
        }
    }
    close($SI);
    close($DEPS);
}

sub Compile()
{
    my $cmd = "cl \@$rspFile /Fo:$objFile > \"$logFile\" 2>&1";
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
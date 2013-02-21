use strict;
use English;
use File::Slurp;
use Carp;

my ($workingDir, $logFile, $installDir, $arch, $rspFile) = @ARGV;

# validate environment
die "msvc is only usable on windows" if ($OSNAME ne "MSWin32");
if (scalar(@ARGV) != 5) {
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
$ENV{"INCLUDE"} = "$installDir\\VC\\include";
if ($arch eq "x86") {
    $ENV{"PATH"} = "$installDir\\VC\\bin;$installDir\\Common7\\IDE;$oldPath";
    $ENV{"LIB"} = "$installDir\\VC\\lib";
}
elsif ($arch eq "amd64") {
    if (isOs64Bit()) {
        $ENV{"PATH"} = "$installDir\\VC\\bin\\amd64;$installDir\\Common7\\IDE;$oldPath";
    }
    else {
        $ENV{"PATH"} = "$installDir\\VC\\bin\\x86_amd64;$installDir\\Common7\\IDE;$oldPath";
    }
    $ENV{"LIB"} = "$installDir\\VC\\lib\\amd64";
}

sub CreateLib()
{
    my $cmd = "lib \"\@$rspFile\" > \"$logFile\" 2>&1";
    my $exitCode = system($cmd);
    if ($exitCode) {
        my $log = read_file($logFile);
        print(STDERR $log);
        exit 1;
    }
}

CreateLib();

exit 0;
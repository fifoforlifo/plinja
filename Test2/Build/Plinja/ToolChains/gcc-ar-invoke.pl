use strict;
use English;
use File::Slurp;
use Carp;

my ($workingDir, $logFile, $installDir, $prefix, $suffix, $rspFile) = @ARGV;

# validate environment
if (scalar(@ARGV) != 6) {
    carp "invalid invocation, see script for required argument list";
}
$prefix = "" if ($prefix eq "_NO_PREFIX_");
$suffix = "" if ($suffix eq "_NO_SUFFIX_");

sub path_separator
{
    return ';' if ($OSNAME eq "MSWin32");
    return ':';
}

chdir($workingDir);

my $oldPath = $ENV{"PATH"};
$ENV{"PATH"} = "$installDir/bin" . $path_separator . "$oldPath";

sub CreateLib()
{
    my $cmd = "${prefix}ar${suffix} \"\@$rspFile\" > \"$logFile\" 2>&1";
    my $exitCode = system($cmd);
    if ($exitCode) {
        my $log = read_file($logFile);
        print(STDERR $log);
        exit 1;
    }
}

CreateLib();

exit 0;
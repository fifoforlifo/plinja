use strict;
use English;
use File::Slurp;
use Carp;

my ($workingDir, $srcFile, $objFile, $depFile, $logFile, $installDir, $prefix, $suffix, $rspFile) = @ARGV;

# validate environment
if (scalar(@ARGV) != 9) {
    carp "invalid invocation, see script for required argument list";
}
$prefix = "" if ($prefix eq "_NO_PREFIX_");
$suffix = "" if ($suffix eq "_NO_SUFFIX_");

my $path_separator = ($OSNAME eq "MSWin32") ? ';' : ':';

chdir($workingDir);

my $oldPath = $ENV{"PATH"};
$ENV{"PATH"} = "$installDir/bin" . $path_separator . "$oldPath";
$ENV{"INCLUDE"} = "$installDir/include";
$ENV{"LIBPATH"} = "$installDir/lib";

sub Compile
{
    my $cmd = "${prefix}gcc${suffix} \"$srcFile\" \"\@$rspFile\" -o\"$objFile\" -MD -MF \"$depFile\" > \"$logFile\" 2>&1";
    my $exitCode = system($cmd);
    if ($exitCode) {
        my $log = read_file($logFile);
        print(STDERR $log);
        exit 1;
    }
}

Compile();

exit 0;
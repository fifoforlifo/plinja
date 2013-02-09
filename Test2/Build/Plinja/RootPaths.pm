package RootPaths;
use File::Basename;
use lib dirname(__FILE__) . "/Common";
use lib dirname(__FILE__) . "/Tasks";
use lib dirname(__FILE__) . "/ToolChains";
use File::Basename;
use Cwd 'abs_path';
use Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(%rootPaths $rootDir);

%rootPaths = ();

my $rootDir = dirname(abs_path(dirname(__FILE__)));
print("rootDir = $rootDir\n");

# First, populate rootPaths with default locations for buildable modules.
# These paths will be added to @INC (perl's library search path).
$rootPaths{'MyLib'} = "$rootDir/Source/MyLib";
$rootPaths{'MyExe'} = "$rootDir/Source/MyExe";
$rootPaths{'Boost'} = "$rootDir/Imports/Boost/boost-1_50_0";

# add all rootPaths added so far to @INC
while (my ($moduleName, $modulePath) = each %rootPaths) {
    print( "Adding module $moduleName to perl lib paths: $modulePath\n");
    push(@INC, $modulePath);
}

# Now add paths for other critical locations.
# These locations will not be added to @INC because no plbs scripts will reside there.

# NOTE: msvc in a hermetic build would point to somewhere in the repo
$rootPaths{'msvc'} = 'C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\bin';

1;

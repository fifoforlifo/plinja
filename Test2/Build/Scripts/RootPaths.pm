package RootPaths;
use File::Basename;
use Cwd 'abs_path';
use Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(%rootPaths $rootDir);

%rootPaths = ();

my $rootDir = dirname(dirname(abs_path(dirname(__FILE__)))); # = __DIRECTORY__ + "../.."
print("rootDir = $rootDir\n");

# First, populate rootPaths with default locations for buildable modules.
# These paths will be added to @INC (perl's library search path).
$rootPaths{'LibA0'} = "$rootDir/Modules/LibA0";
$rootPaths{'LibA1'} = "$rootDir/Modules/LibA1";
$rootPaths{'Prog0'} = "$rootDir/Modules/Prog0";
$rootPaths{'Boost'} = "$rootDir/Imports/Boost/boost-1_50_0";

# add all rootPaths added so far to @INC
while (my ($moduleName, $modulePath) = each %rootPaths) {
    print( "Adding module $moduleName to perl lib paths: $modulePath\n");
    push(@INC, $modulePath);
}

# Now add paths for other critical locations.
# These locations will not be added to @INC because no plbs scripts will reside there.

# NOTE: msvc in a hermetic build would point to somewhere in the repo
$rootPaths{'msvc9_root'} = 'C:\Program Files (x86)\Microsoft Visual Studio 9.0';
$rootPaths{'msvc10_root'} = 'C:\Program Files (x86)\Microsoft Visual Studio 10.0';

1;

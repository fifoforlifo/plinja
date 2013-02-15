package RootPaths;
use File::Basename;
use Cwd 'abs_path';
use Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(%rootPaths $rootDir);

%rootPaths = ();

my $rootDir = dirname(dirname(abs_path(dirname(__FILE__)))); # = __DIRECTORY__ + "../.."

# addModuleDir(name, relPath, absPath = nil)
# relPath is the "home" directory for the module.  This is also used to compute the output path within 'Built'.
# absPath = $rootDir/$relPath by default (i.e. if unspecified), but can be provided explicitly for micro-branching
sub addModuleDir
{
    my ($name, $relPath, $absPath) = @_;

    $absPath = "$rootDir/$relPath" if (!$absPath);
    $rootPaths{$name . "_rel"} = $relPath;
    $rootPaths{$name} = $absPath;
    push(@INC, $absPath);
}

addModuleDir("Boost", "Imports/Boost/boost-1_50_0");
addModuleDir("LibA0", "Modules/LibA0");
addModuleDir("LibA1", "Modules/LibA1");
addModuleDir("Prog0", "Modules/Prog0");

# Add paths for other critical locations.
# These locations will not be added to @INC because no perl modules will reside there.

# NOTE: in a hermetic build, these paths would point to somewhere in the repo
$rootPaths{'msvc9_root'} = 'C:\Program Files (x86)\Microsoft Visual Studio 9.0';
$rootPaths{'msvc10_root'} = 'C:\Program Files (x86)\Microsoft Visual Studio 10.0';
$rootPaths{'msvc11_root'} = 'C:\Program Files (x86)\Microsoft Visual Studio 11.0';

# This is the root directory where all out-of-source builds go.
$rootPaths{'Built'} = "$rootDir/Built";

1;

use Cwd;
use File::Basename;
use lib dirname(__FILE__) . "/Build/Plinja";
use lib dirname(__FILE__) . "/Build/Scripts";

# bootstrap paths to all modules
use Plinja;
use RootPaths;
# common build stuff
use ModuleMan;
use MyVariant;
use MsvcToolChain;
# specific projects to build from the root
use Prog0;


# A single build.ninja shall hold all rules + build commands.
mkdir($rootPaths{'Built'});
my $ninjaFile = dirname(__FILE__) . "/Built/build.ninja";
open(my $FH, ">$ninjaFile");


# TODO: use value from commandline if available
my $config = 'dbg';
my $variant_x86   = MyVariant->new(str => "msvc10_x86.$config");
my $variant_amd64 = MyVariant->new(str => "msvc10_amd64.$config");

# Create the module manager, which tracks all modules (projects) being built.
my $moduleMan = ModuleMan->new(FH => $FH);

# Create toolchains.
my $msvc10_x86   = MsvcToolChain->new(name => 'msvc10_x86',   vsInstallDir => $rootPaths{'msvc10_root'}, arch => 'x86');
my $msvc10_amd64 = MsvcToolChain->new(name => 'msvc10_amd64', vsInstallDir => $rootPaths{'msvc10_root'}, arch => 'amd64');
$moduleMan->addToolChain($msvc10_x86);
$moduleMan->addToolChain($msvc10_amd64);

$moduleMan->emitRules();


# Add top-level target modules.
my $prog0_x86   = $moduleMan->gorcModule('Prog0', $variant_x86);
my $prog0_amd64 = $moduleMan->gorcModule('Prog0', $variant_amd64);

Plinja::emitRegeneratorTarget($FH, $ninjaFile, __FILE__);

print($FH "\n\n");

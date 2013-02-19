use Cwd;
use File::Basename;
use File::Path;
use lib dirname(__FILE__) . "/Build/Plinja";
use lib dirname(__FILE__) . "/Build/Scripts";

# bootstrap paths to all modules
use Plinja;
use RootPaths;
# common build stuff
use ModuleMan;
use CppVariant;
use MsvcToolChain;
# specific projects to build from the root
use Prog0;


# A single build.ninja shall hold all rules + build commands.
File::Path::make_path($rootPaths{'Built'});
my $ninjaFile = dirname(__FILE__) . "/Built/build.ninja";
open(my $FH, ">$ninjaFile");


# TODO: use value from commandline if available
my @variants = ();
push(@variants, MyVariant->new(str => "windows.msvc10.x86.dbg.dcrt"));
push(@variants, MyVariant->new(str => "windows.msvc10.x86.rel.dcrt"));
push(@variants, MyVariant->new(str => "windows.msvc10.amd64.dbg.dcrt"));
push(@variants, MyVariant->new(str => "windows.msvc10.amd64.rel.dcrt"));

# Create the module manager, which tracks all modules (projects) being built.
my $moduleMan = ModuleMan->new(FH => $FH);

# Create toolchains.
my $msvc10_x86   = MsvcToolChain->new(name => 'msvc10_x86',   vsInstallDir => $rootPaths{'msvc10_root'}, arch => 'x86');
my $msvc10_amd64 = MsvcToolChain->new(name => 'msvc10_amd64', vsInstallDir => $rootPaths{'msvc10_root'}, arch => 'amd64');
$moduleMan->addToolChain($msvc10_x86);
$moduleMan->addToolChain($msvc10_amd64);

$moduleMan->emitRules();


# Add top-level target modules.
foreach (@variants) {
    my $variant = $_;
    my $prog = $moduleMan->gorcModule('Prog0', $variant);
}

Plinja::emitRegeneratorTarget($FH, $ninjaFile, __FILE__, $moduleMan);

print($FH "\n\n");

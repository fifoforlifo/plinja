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
# specific projects to build from the root
use Prog0;

my $moduleMan = ModuleMan->new();

# TODO: if variant was passed on commandline, use it instead of this default
my $variant = MyVariant->new(str => "msvc10-x86.dbg");
my $exe = $moduleMan->gorcModule('Prog0', $variant);

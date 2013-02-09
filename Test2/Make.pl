use Cwd;
use File::Basename;
use lib dirname(__FILE__) . "/Build/Plinja";
use lib dirname(__FILE__) . "/Build/Scripts";

# bootstrap paths to all modules
use RootPaths;
use ModuleMan;
use MyExe;
use MyVariant;

my $moduleMan = ModuleMan->new();

# TODO: if variant was passed on commandline, use it instead of this default
my $variant = MyVariant->new(str => "msvc10-x86.dbg");

my $variantStr = $variant->str;
my $exe = $moduleMan->gorcModule('MyExe', $variant);

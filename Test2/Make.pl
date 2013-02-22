use strict;
use Cwd;
use Fcntl qw/ LOCK_EX LOCK_NB SEEK_SET /;
use File::Basename;
use File::Copy;
use File::Path;
use File::Temp qw/ tempfile /;
use lib dirname(__FILE__) . "/Build/Plinja";
use lib dirname(__FILE__) . "/Build/Scripts";

# bootstrap paths to all modules
use Plinja;
use RootPaths;
# common build stuff
use ModuleMan;
use CppVariant;
use MsvcToolChain;
use MinGWToolChain;
use GccToolChain;
# specific projects to build from the root
use Prog0;


# A single build.ninja shall hold all rules + build commands.
File::Path::make_path($rootPaths{'Built'});
my $ninjaFile = $rootPaths{'Built'} . "/build.ninja";

# Prevent multiple concurrent executions of this script.
open(my $LOCKFH, ">$ninjaFile.lock") or die "cannot open lockfile $ninjaFile.lock";
flock($LOCKFH, LOCK_EX | LOCK_NB) or die "another build process is concurrently executing";

my $FH = tempfile() or die "Failed to create temp file for new build.ninja";



my @variants = ();
#push(@variants, MyVariant->new(str => "windows.msvc9.x86.dbg.dcrt"));
#push(@variants, MyVariant->new(str => "windows.msvc9.x86.rel.dcrt"));
#push(@variants, MyVariant->new(str => "windows.msvc9.amd64.dbg.dcrt"));
#push(@variants, MyVariant->new(str => "windows.msvc9.amd64.rel.dcrt"));
#push(@variants, MyVariant->new(str => "windows.msvc10.x86.dbg.dcrt"));
#push(@variants, MyVariant->new(str => "windows.msvc10.x86.rel.dcrt"));
#push(@variants, MyVariant->new(str => "windows.msvc10.amd64.dbg.dcrt"));
#push(@variants, MyVariant->new(str => "windows.msvc10.amd64.rel.dcrt"));
push(@variants, MyVariant->new(str => "windows.mingw64.x86.dbg.dcrt"));
push(@variants, MyVariant->new(str => "windows.mingw64.x86.rel.dcrt"));
push(@variants, MyVariant->new(str => "windows.mingw64.amd64.dbg.dcrt"));
push(@variants, MyVariant->new(str => "windows.mingw64.amd64.rel.dcrt"));

# Create the module manager, which tracks all modules (projects) being built.
my $moduleMan = ModuleMan->new(FH => $FH);

# Create toolchains.
my $msvc9_x86    = MsvcToolChain->new( name => 'msvc9_x86',    installDir => $rootPaths{'msvc10_root'},  arch => 'x86');
my $msvc9_amd64  = MsvcToolChain->new( name => 'msvc9_amd64',  installDir => $rootPaths{'msvc10_root'},  arch => 'amd64');
my $msvc10_x86   = MsvcToolChain->new( name => 'msvc10_x86',   installDir => $rootPaths{'msvc10_root'},  arch => 'x86');
my $msvc10_amd64 = MsvcToolChain->new( name => 'msvc10_amd64', installDir => $rootPaths{'msvc10_root'},  arch => 'amd64');
my $mingw64      = MinGWToolChain->new(name => 'mingw64',      installDir => $rootPaths{'mingw64_root'});
$moduleMan->addToolChain($msvc9_x86);
$moduleMan->addToolChain($msvc9_amd64);
$moduleMan->addToolChain($msvc10_x86);
$moduleMan->addToolChain($msvc10_amd64);
$moduleMan->addToolChain($mingw64);


# Begin emitting build.ninja contents.
$moduleMan->emitRules();

print($FH "#############################################\n");
print($FH "# Begin files.\n");
print($FH "\n");

# Add top-level target modules.
foreach (@variants) {
    my $variant = $_;
    my $prog = $moduleMan->getModule('Prog0', $variant);
}

Plinja::emitRegeneratorTarget($FH, $ninjaFile, __FILE__, $moduleMan);

print($FH "\n\n");

seek($FH, 0, SEEK_SET);
copy($FH, $ninjaFile) or die "Could not write to build.ninja";

close($FH);
close($LOCKFH);
unlink("$ninjaFile.lock");

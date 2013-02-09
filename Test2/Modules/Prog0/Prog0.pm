package MyExe;
use Mouse;
use File::Basename;
use File::Spec;
use RootPaths;
use CppModule;

extends CppModule;

sub BUILD
{
    my $mod = shift;
    my $variantStr = $mod->variant->str;
    $mod->{OUTPUT_DIR} = File::Spec->catdir(dirname(__FILE__), "Built", $variantStr);
}

sub outputDir
{
    my $mod = shift;
    return $mod->{OUTPUT_DIR};
}

sub addToGraph_cppModule
{
    my $mod = shift;

    my $myLib = $mod->moduleMan->gorcModule('MyLib', $mod->variant);

    $mod->addStaticLibrary($myLib->{OUTPUT});
    $mod->compile("Source/e0.cpp");
    $mod->compile("Source/e1.cpp");
    $mod->compile("Source/e2.cpp");
    $mod->compile("Source/e3.cpp",
        sub {
            my $task = shift;
            push($task->includePaths, $rootPaths{'Boost'});
        });
    $mod->executable("my.exe");
    # TODO: remove -- print inputs
    foreach (@{$mod->{INPUTS}}) {
        my $outfile = $_->outputFile;
        print "inputs: $outfile\n";
    }
}

sub compileOverride
{
    my $mod = shift;
    my $task = shift;
}

1;

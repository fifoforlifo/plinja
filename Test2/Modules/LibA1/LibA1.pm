package LibA1;
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
    $mod->{OUTPUT_DIR} = File::Spec->catdir($rootPaths{'Built'}, $rootPaths{"LibA1_rel"}, $variantStr);
}

sub outputDir
{
    my $mod = shift;
    return $mod->{OUTPUT_DIR};
}

sub addToGraph_cppModule
{
    my $mod = shift;

    $mod->compile("Source/a1_0.cpp");
    $mod->compile("Source/a1_1.cpp");
    $mod->compile("Source/a1_2.cpp");
    $mod->compile("Source/a1_3.cpp");
    $mod->sharedLibrary("A1");
}

1;

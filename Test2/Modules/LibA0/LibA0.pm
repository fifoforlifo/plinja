package LibA0;
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
    $mod->{OUTPUT_DIR} = File::Spec->catdir($rootPaths{'Built'}, $rootPaths{"LibA0_rel"}, $variantStr);
}

sub outputDir
{
    my $mod = shift;
    return $mod->{OUTPUT_DIR};
}

sub addToGraph_cppModule
{
    my $mod = shift;

    $mod->compile("Source/a0_0.cpp");
    $mod->compile("Source/a0_1.cpp");
    $mod->compile("Source/a0_2.cpp");
    $mod->compile("Source/a0_3.cpp");
    $mod->staticLibrary("A0");
}

1;

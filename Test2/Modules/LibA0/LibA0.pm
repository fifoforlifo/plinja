package LibA1;
use Mouse;
use File::Basename;
use File::Spec;
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

sub defaultTarget
{
    return "mylib.a";
}

sub addToGraph_cppModule
{
    my $mod = shift;

    $mod->compile("Source/a0.cpp");
    $mod->compile("Source/a1.cpp");
    $mod->compile("Source/a2.cpp");
    $mod->compile("Source/a3.cpp");
    $mod->staticLibrary("myLib.a");
}

1;

package LibA0;
use Mouse;
use File::Basename;
use File::Spec;
use RootPaths;
use CppModuleEx;

extends CppModuleEx;

sub define
{
    my $mod = shift;

    $mod->compile("Source/a0_0.cpp");
    $mod->compile("Source/a0_1.cpp");
    $mod->compile("Source/a0_2.cpp");
    $mod->compile("Source/a0_3.cpp");
    $mod->staticLibrary("A0");
}

1;

package LibA1;
use CppModuleEx;

extends CppModuleEx;

sub define
{
    my $mod = shift;

    $mod->compile("Source/a1_0.cpp");
    $mod->compile("Source/a1_1.cpp");
    $mod->compile("Source/a1_2.cpp");
    $mod->compile("Source/a1_3.cpp");
    $mod->sharedLibrary("A1");
}

1;

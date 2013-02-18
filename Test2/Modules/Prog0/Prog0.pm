package Prog0;
use Mouse;
use File::Basename;
use File::Spec;
use RootPaths;
use CppModuleEx;

extends CppModuleEx;

sub define
{
    my $mod = shift;

    my $libA0 = $mod->moduleMan->gorcModule('LibA0', $mod->variant);
    my $libA1 = $mod->moduleMan->gorcModule('LibA1', $mod->variant);

    $mod->addStaticLibrary($libA0->libraryFile);
    $mod->addStaticLibrary($libA1->libraryFile);
    $mod->compile("Source/e0_0.cpp");
    $mod->compile("Source/e0_1.cpp");
    $mod->compile("Source/e0_2.cpp");
    $mod->compile("Source/e0_3.cpp",
        sub {
            my $task = shift;
            push($task->includePaths, $rootPaths{'Boost'});
        });
    $mod->executable("prog0");
}

sub compileOverride
{
    my $mod = shift;
    my $task = shift;
}

1;

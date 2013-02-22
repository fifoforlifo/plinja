# Plinja

Plinja is a meta-build system written in Perl that produces [Ninja Build files](http://martine.github.com/ninja/).

You get to define a perl module for each library or program you want to build, and instantiate it for each
*variant* you wish to build in order to define targets.  Instantiation can occur either from the root level
(for top level targets), or from within another library/program module when there's a dependency.

There are built in abstractions for C/C++ compilation, and it's easy to define custom targets and generators.

Since it's all Perl, everything is fully programmable.  And you can debug it using
e.g. [Padre](http://padre.perlide.org/) or [perldebug](http://perldoc.perl.org/perldebug.html).


## At a glance.

    package Prog0;
    use CppModuleEx;
    use RootPaths;
    extends CppModuleEx;

    sub define
    {
        my ($mod) = @_;

        my $libA0 = $mod->moduleMan->getModule('LibA0', $mod->variant);
        my $libA1 = $mod->moduleMan->getModule('LibA1', $mod->variant);

        $mod->compile("Source/e0_0.cpp");
        $mod->compile("Source/e0_1.cpp");
        $mod->compile("Source/e0_2.cpp");
        $mod->compile("Source/e0_3.cpp",
            sub {
                my ($mod, $task) = @_;
                push(@{$task->includePaths}, $rootPaths{'Boost'});
            });
        $mod->addInputLibrary($libA0->libraryFile);
        $mod->addInputLibrary($libA1->libraryFile);
        $mod->executable("prog0");
    }

    sub setCompileOptions
    {
        my ($mod, $task) = @_;
        $mod->SUPER::setCompileOptions($task);
        push(@{$task->includePaths}, $rootPaths{'LibA0'} . '/Include');
        push(@{$task->includePaths}, $rootPaths{'LibA0'} . '/IncludeSpecial');
        push(@{$task->includePaths}, $rootPaths{'LibA1'} . '/Include');
    }

    1;


The plinja code above shows several capabilities:

-   Defining an executable, via 'CppModuleEx'.
-   Compiling multiple source files.
-   Setting common compiler options in function 'setCompileOptions'.
-   Setting specialized compiler options for a single source file via an anonymous subroutine.
-   Compiler options are modified through a "task" object.  This allows each option
    to be modified independently right up to the point of being serialized to the
    ninja file.
-   Instancing dependencies (libraries in this case) through the 'moduleMan', which
    ensures each module's targets are only instanced once per *variant*.
-   Linking libraries to the executable via 'addInputLibrary'.
    Notice the library file name is provided in the member 'libraryFile', ensuring
    that the file name string isn't repeated in multiple places in the build.


## Guiding principles.

For a meta-build:

-   It must be debuggable.
-   Written in a real programming language.
-   Avoid repetition.
-   No weird assumptions, like a single global toolchain per build.
-   Allow specifying a precise file-level dependency graph.

For a build engine:

-   Incremental builds must be fast.  (ninja - yes!)
-   Full file-level dependency checking.  (ninja - yes!)
-   Implicit dependency checking.  (ninja - yes! - with a dependency generator)
-   Implicit dependency discovery and retry.  (ninja - no - if you have e.g. a generated header, you must define a dependency manually)


## Description of components.

... TODO ...


## Why another build system?

Because the ones out there are *still* not good enough!

... TODO ...


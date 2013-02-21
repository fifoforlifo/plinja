package CppModuleEx;
use Carp;
use CppModule;
use RootPaths;

extends CppModule;

sub calcToolChain
{
    my ($mod) = @_;
    if ($mod->variant->{toolChain} =~ /msvc/) {
        my $toolChainName = $mod->variant->{toolChain} . '_' . $mod->variant->{arch};
        my $toolChain = $mod->moduleMan->getToolChain($toolChainName);
        return ($toolChainName, $toolChain);
    }
    else {
        my $toolChainName = $mod->variant->{toolChain};
        my $toolChain = $mod->moduleMan->getToolChain($toolChainName);
        return ($toolChainName, $toolChain);
    }
}

sub BUILD
{
    my ($mod) = @_;

    my ($toolChainName, $toolChain) = calcToolChain($mod);
    if (!$toolChain) {
        confess "ToolChain \"$toolChainName\" does not exist.";
    }
    $mod->{TOOL_CHAIN} = $toolChain;
}

sub toolChain
{
    my ($mod) = @_;
    return $mod->{TOOL_CHAIN};
}

sub setCompileOptions
{
    my ($mod, $task) = @_;

    if ($mod->variant->{os} eq "windows") {
        if ($mod->variant->{toolChain} =~ /msvc/) {
            push(@{$task->includePaths}, $rootPaths{'winsdk'} . "/Include");
        }
        elsif ($mod->variant->{toolChain} =~ /mingw64/) {
            push(@{$task->includePaths}, $mod->toolChain->installDir . "/x86_64-w64-mingw32\include");
        }
    }

    if ($mod->variant->{toolChain} =~ m/mingw64/) {
        if ($mod->variant->{arch} eq "x86") {
            push(@{$task->extraOptions}, "-m32");
        }
        elsif ($mod->variant->{arch} eq "amd64") {
            push(@{$task->extraOptions}, "-m64");
        }
    }

    if ($mod->variant->{config} eq "dbg") {
        $task->optLevel(1);
    }
    elsif ($mod->variant->{config} eq "rel") {
        $task->optLevel(3);
    }
    $task->dynamicCrt($mod->variant->{crt} eq 'dcrt');

    $task->debugLevel(2);
    if ($mod->variant->{config} eq "dbg") {
        $task->minimalRebuild(1);
    }
}

sub staticLibrary
{
    my ($mod, $outputFileName, $lambda) = @_;

    my $newOutputFileName;
    if ($mod->variant->{toolChain} =~ /msvc/) {
        $newOutputFileName = $outputFileName . ".lib";
    }
    else {
        $newOutputFileName = 'lib' . $outputFileName . '.a';
    }

    return $mod->SUPER::staticLibrary($newOutputFileName, $lambda);
}

sub setStaticLibraryOptions
{
}

sub calcWinsdkLibDir
{
    my ($mod) = @_;
    if ($mod->variant->{arch} eq "x86") {
        return $rootPaths{winsdk} . "/Lib/";
    }
    elsif ($mod->variant->{arch} eq "amd64") {
        return $rootPaths{winsdk} . "/Lib/x64/";
    }
    else {
        confess "unsupported architecture";
    }
}

sub addPlatformLibs
{
    my ($mod, $task) = @_;
    if ($mod->variant->{os} eq "windows") {
        if ($mod->variant->{toolChain} =~ /msvc/) {
            my $winsdkLibDir = $mod->calcWinsdkLibDir();
            push(@{$task->inputs}, $winsdkLibDir . "kernel32.lib");
            push(@{$task->inputs}, $winsdkLibDir . "user32.lib");
            push(@{$task->inputs}, $winsdkLibDir . "gdi32.lib");
        }
        elsif ($mod->variant->{toolChain} =~ /mingw/) {
            # push(@{$task->inputs}, $winsdkLibDir . "-lc");
            # push(@{$task->inputs}, $winsdkLibDir . "-lmsvcrt");
            # push(@{$task->inputs}, $winsdkLibDir . "-lkernel32");
            # push(@{$task->inputs}, $winsdkLibDir . "-luser32");
            # push(@{$task->inputs}, $winsdkLibDir . "-lgdi32");
        }
    }
}

sub sharedLibrary
{
    my ($mod, $outputFile, $lambda) = @_;

    my $newOutputFile;
    if ($mod->variant->{os} eq "windows") {
        if ($mod->variant->{toolChain} =~ /msvc/) {
            $mod->{LIBRARY_FILE} = File::Spec->catfile($mod->outputDir, $outputFile . ".lib");
            $newOutputFile       = File::Spec->catfile($mod->outputDir, $outputFile . ".dll");
        }
        elsif ($mod->variant->{toolChain} =~ /mingw/) {
            # on mingw, ld is smart enough to link directly against a DLL without an implib present
            $newOutputFile       = File::Spec->catfile($mod->outputDir, $outputFile . ".dll");
            $mod->{LIBRARY_FILE} = $newOutputFile;
        }
    }
    else {
        $newOutputFile       = File::Spec->catfile($mod->outputDir, 'lib' . $outputFile . '.so');
        $mod->{LIBRARY_FILE} = $newOutputFile;
    }

    return $mod->SUPER::sharedLibrary($newOutputFile, $lambda);
}

sub setSharedLibraryOptions
{
    my ($mod, $task) = @_;

    if ($mod->variant->{toolChain} =~ m/mingw64/) {
        if ($mod->variant->{arch} eq "x86") {
            push(@{$task->extraOptions}, "-m32");
        }
        elsif ($mod->variant->{arch} eq "amd64") {
            push(@{$task->extraOptions}, "-m64");
        }
    }

    $task->keepDebugInfo(1);
    $mod->addPlatformLibs($task);
}

sub executable
{
    my ($mod, $outputFileName, $lambda) = @_;

    if ($mod->variant->{os} eq "windows") {
        $outputFileName = $outputFileName . ".exe";
    }
    else {
        # just use the plain name
    }

    return $mod->SUPER::executable($outputFileName, $lambda);
}

sub setExecutableOptions
{
    my ($mod, $task) = @_;

    if ($mod->variant->{toolChain} =~ m/mingw64/) {
        if ($mod->variant->{arch} eq "x86") {
            push(@{$task->extraOptions}, "-m32");
        }
        elsif ($mod->variant->{arch} eq "amd64") {
            push(@{$task->extraOptions}, "-m64");
            }
    }

    $task->keepDebugInfo(1);
    $mod->addPlatformLibs($task);
}

1;

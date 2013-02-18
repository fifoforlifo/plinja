package CppModuleEx;
use Carp;
use CppModule;
use RootPaths;

extends CppModule;

sub BUILD
{
    my ($mod) = @_;
    
    my $toolChainName = $mod->variant->{toolChain} . '_' . $mod->variant->{arch};
    my $toolChain = $mod->moduleMan->getToolChain($toolChainName);
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

sub compileOverride
{
    my ($mod, $task) = @_;
    if ($mod->variant->{os} eq "windows") {
        push($task->includePaths, $rootPaths{'winsdk'} . "/Include");
    }
}

sub staticLibraryOverride
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

sub sharedLibraryOverride
{
    my ($mod, $task) = @_;
    if ($mod->variant->{os} eq "windows") {
        my $winsdkLibDir = $mod->calcWinsdkLibDir();
        push($task->inputs, $winsdkLibDir . "user32.lib");
        push($task->inputs, $winsdkLibDir . "kernel32.lib");
    }
}

sub executableOverride
{
    my ($mod, $task) = @_;
    if ($mod->variant->{os} eq "windows") {
        my $winsdkLibDir = $mod->calcWinsdkLibDir();
        push($task->inputs, $winsdkLibDir . "user32.lib");
        push($task->inputs, $winsdkLibDir . "kernel32.lib");
    }
}

1;

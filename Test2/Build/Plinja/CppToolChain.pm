package CppToolChain;
use Mouse;
use ToolChain;
use Carp;

extends ToolChain;

sub emitCompile
{
    my ($toolChain, $FH, $mod, $task) = @_;
    confess sprintf("you need to implement %s::%s", $_[0], (caller(0))[3]);
}

sub emitStaticLibrary
{
    my ($toolChain, $FH, $mod, $task) = @_;
    confess sprintf("you need to implement %s::%s", $_[0], (caller(0))[3]);
}

sub emitSharedLibrary
{
    my ($toolChain, $FH, $mod, $task) = @_;
    confess sprintf("you need to implement %s::%s", $_[0], (caller(0))[3]);
}

sub emitExecutable
{
    my ($toolChain, $FH, $mod, $task) = @_;
    confess sprintf("you need to implement %s::%s", $_[0], (caller(0))[3]);
}

1;

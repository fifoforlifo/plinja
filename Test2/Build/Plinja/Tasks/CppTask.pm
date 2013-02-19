package CppTask;
use Mouse;
use File::Basename;
use File::Spec;
use BuildTask;
use Carp;

extends BuildTask;

has sourceFile => (is => 'ro');
has objectFile => (is => 'ro');
has workingDir => (is => 'ro');
has optLevel => (is => 'rw', default => 0);
has debugLevel => (is => 'rw', default => 2);
has dynamicCrt => (is => 'rw', default => 1); # boolean

# msvc-specific options
has minimalRebuild => (is => 'rw', default => 0);

sub BUILD
{
    my ($task) = @_;
    if (!$task->objectFile) {
        confess "objectFile not defined";
    }
    if (!$task->workingDir) {
        confess "workingDir not defined";
    }
    $task->{INCLUDE_PATHS} = [];
}

sub includePaths
{
    my ($task) = @_;
    return $task->{INCLUDE_PATHS};
}

sub outputFile
{
    my ($task) = @_;
    return $task->objectFile;
}

sub emit
{
    my ($task, $toolChain, $FH, $mod) = @_;
    $toolChain->emitCompile($FH, $mod, $task);
}

1;

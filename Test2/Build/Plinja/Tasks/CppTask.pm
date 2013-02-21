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

# common options (across all toolchains)
has extraOptions => (is => 'ro', default => sub { [] });
has optLevel => (is => 'rw', default => 0);
has debugLevel => (is => 'rw', default => 2);
# includePaths
# defines

# msvc-specific options
has minimalRebuild => (is => 'rw', default => 0);
has dynamicCrt => (is => 'rw', default => 1); # boolean

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
    $task->{DEFINES} = [];
    $task->{EXTRA_OPTIONS} = [];
}

sub includePaths
{
    my ($task) = @_;
    return $task->{INCLUDE_PATHS};
}

sub defines
{
    my ($task) = @_;
    return $task->{DEFINES};
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

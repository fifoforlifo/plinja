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
has optLevel => (is => 'rw');
has debugLevel => (is => 'rw');

sub BUILD
{
    my $task = shift;
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
    my $task = shift;
    return $task->{INCLUDE_PATHS};
}

sub outputFile
{
    my $task = shift;
    return $task->objectFile;
}

sub emit
{
    my ($task, $toolChain, $FH) = @_;
    $toolChain->emitCompile($FH, $task);
}

1;

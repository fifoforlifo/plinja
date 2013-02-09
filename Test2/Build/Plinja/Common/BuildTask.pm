package BuildTask;
use Mouse;
use BuildModule;

has mod => (is => 'ro', isa => 'BuildModule');

sub BUILD
{
    my $task = shift;
    $task->{forcedInputs} = [];
    $task->{forcedOutputs} = [];
}

# Should return the path for the primary output.
# This is used as a base-name for other build tracking files.
sub outputBasePath
{
    die sprintf("you need to implement %s::%s", $_[0], (caller(0))[3]);
}

# Should return a string containing a shell script that can perform the task.
sub createTaskScriptStr
{
    die sprintf("you need to implement %s::%s", $_[0], (caller(0))[3]);
}

# Should return a string containing a shell script that generates implicit deps file.
# Implicit deps file should be named $task->outputBasePath() . ".deps".
sub createDepsScriptStr
{
    die sprintf("you need to implement %s::%s", $_[0], (caller(0))[3]);
}

# Should return an array containing filenames of explicit inputs.
sub getExplicitInputs
{
    die sprintf("you need to implement %s::%s", $_[0], (caller(0))[3]);
}

# Should return an array containing filenames of explicit outputs.
sub getExplicitOutputs
{
    die sprintf("you need to implement %s::%s", $_[0], (caller(0))[3]);
}

sub addExtraInput
{
    my $task = shift;
    my $input = shift;
    push($task->{forcedInputs}, $input);
}

sub addExtraOutput
{
    my $task = shift;
    my $input = shift;
    push($task->{forcedOutputs}, $input);
}

1;

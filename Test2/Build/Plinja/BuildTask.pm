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

# Should emit ninja build directives.
sub emit
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

package CppModule;
use Mouse;
use BuildModule;
use CppTask;
use StaticLibraryTask;
use SharedLibraryTask;
use ExecutableTask;

extends BuildModule;

sub BUILD
{
    my $mod = shift;
    $mod->{INPUTS} = [];
}

# Should return a string containing the output directory for the current module and variant.
sub outputDir
{
    die sprintf("you need to implement %s::%s", $_[0], (caller(0))[3]);
}

sub addToGraph_module
{
    my $mod = shift;
    $mod->addToGraph_cppModule();
}

sub addToGraph_cppModule
{
    die sprintf("you need to implement %s::%s", $_[0], (caller(0))[3]);
}

sub addStaticLibrary
{
    my $mod = shift;
    my $task = shift;
    push($mod->{INPUTS}, $task);
}

sub addInputFile
{
    my $mod = shift;
    my $filename = shift;
    push($mod->{INPUTS}, $filename);
}

sub outputFile
{
    my $mod = shift;
    if (!exists $mod->{OUTPUT}) {
        die "No output selected.";
    }
    return $mod->{OUTPUT}->outputFile;
}

sub compile
{
    my $mod = shift;
    my $sourceFile = shift;
    my $lambda = shift;

    my $task = CppTask->new('sourceFile' => $sourceFile, 'outputDir' => $mod->outputDir);
    $mod->compileOverride($task);
    if ($lambda) {
        &$lambda($task);
    }
    $task->emit();
    
    push($mod->{INPUTS}, $task->outputFile);
    
    return $task;
}

sub compileOverride
{
}

sub staticLibrary
{
    my $mod = shift;
    my $outputFile = shift;
    my $lambda = shift;

    if ($mod->{OUTPUT}) {
        die "Output already selected: $mod->{OUTPUT}";
    }
    if (!$outputFile) {
        die "You must specify an outputFile parameter.";
    }

    my $task = new StaticLibraryTask("outputFileName" => $outputFile, 'outputDir' => $mod->outputDir);
    $mod->staticLibraryOverride($task);
    if ($lambda) {
        &$lambda($task);
    }
    foreach (@{$mod->{INPUTS}}) {
        my $input = $_;
        push($task->{INPUTS}, $input);
    }
    $task->emit();
    
    $mod->{OUTPUT} = $outputFile;
    return $task;
}

sub staticLibraryOverride
{
}

sub sharedLibrary
{
    my $mod = shift;
    my $outputFile = shift;
    my $lambda = shift;
    
    my $task = new SharedLibraryTask("outputFile" => $outputFile, 'outputDir' => $mod->outputDir);
    $mod->sharedLibraryOverride($task);
    if ($lambda) {
        &$lambda($task);
    }
    foreach (@{$mod->{INPUTS}}) {
        my $input = $_;
        push($task->{INPUTS}, $input);
    }
    $task->emit();
    
    $mod->{OUTPUT} = $task;
    return $task;
}

sub sharedLibraryOverride
{
}

sub executable
{
    my $mod = shift;
    my $outputFile = shift;
    my $lambda = shift;
    
    my $task = new ExecutableTask("outputFile" => $outputFile, 'outputDir' => $mod->outputDir);
    $mod->executableOverride($task);
    if ($lambda) {
        &$lambda($task);
    }
    foreach (@{$mod->{INPUTS}}) {
        my $input = $_;
        push($task->{INPUTS}, $input);
    }
    $task->emit();
    
    $mod->{OUTPUT} = $task;
    return $task;
}

sub executableOverride
{
}

1;

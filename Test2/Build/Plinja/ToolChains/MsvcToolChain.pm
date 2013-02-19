package MsvcToolChain;
use Mouse;
use CppToolChain;
use File::Basename;
use Plinja;

extends CppToolChain;

has vsInstallDir => (is => 'ro');
has arch => (is => 'ro');


sub emitRules
{
    my ($toolChain, $FH) = @_;

    my $name = $toolChain->name;
    my $vsInstallDir = $toolChain->vsInstallDir;
    my $arch = $toolChain->arch;
    my $scriptDir = dirname(__FILE__);

    print($FH "#############################################\n");
    print($FH "# $name\n");
    print($FH "\n");
    print($FH "rule ${name}_cxx\n");
    print($FH "  depfile = \$DEP_FILE\n");
    print($FH "  command = perl $scriptDir\\msvc-cxx-invoke.pl  \"\$WORKING_DIR\"  \"\$SRC_FILE\"  \"\$OBJ_FILE\"  \"\$DEP_FILE\"  \"\$LOG_FILE\"  \"$vsInstallDir\"  $arch  \"\$RSP_FILE\"  \n");
    print($FH "  description = ${name}_cxx \$DESC\n");
    print($FH "  restat = 1\n");
    print($FH "\n");
    print($FH "rule ${name}_lib\n");
    print($FH "  command = perl $scriptDir\\msvc-lib-invoke.pl  \"\$WORKING_DIR\"  \"\$LOG_FILE\"  \"$vsInstallDir\"  $arch  \"\$RSP_FILE\"  \n");
    print($FH "  description = ${name}_lib \$DESC\n");
    print($FH "  restat = 1\n");
    print($FH "\n");
    print($FH "rule ${name}_link\n");
    print($FH "  command = perl $scriptDir\\msvc-link-invoke.pl  \"\$WORKING_DIR\"  \"\$LOG_FILE\"  \"$vsInstallDir\"  $arch  \"\$RSP_FILE\"  \n");
    print($FH "  description = ${name}_link \$DESC\n");
    print($FH "  restat = 1\n");
    print($FH "\n");
}

sub translateOptLevel
{
    my ($toolChain, $options, $task) = @_;
    if ($task->optLevel == 0) {
        push(@$options, " /Od"); # optimizations disabled
    }
    elsif (1 <= $task->optLevel && $task->optLevel <= 2) {
        push(@$options, " /O${\$task->optLevel}");
    }
    elsif ($task->optLevel == 3) {
        push(@$options, " /Ox");
    }
    else {
        confess("invalid optimization level ${\$task->optLevel}");
    }
}

sub translateDebugLevel
{
    my ($toolChain, $options, $task) = @_;
    if (!(0 <= $task->debugLevel && $task->debugLevel <= 3)) {
        confess("invalid debug level ${\$task->debugLevel}");
    }

    if ($task->debugLevel == 0) {
        return;
    }

    if ($task->debugLevel == 1) {
        push(@$options, " /Zd"); # line info
    }
    elsif ($task->debugLevel == 2) {
        push(@$options, " /Zi"); # full debug info
    }
    elsif ($task->debugLevel == 3) {
        push(@$options, " /Zi"); # edit-and-continue
    }
    # rename PDB file
    push(@$options, " \"/Fd${\$task->outputFile}.pdb\"");

    if ($task->minimalRebuild) {
        push(@$options, " /Gm");
    }
}

sub translateIncludePaths
{
    my ($toolChain, $options, $task) = @_;
    foreach (@{$task->includePaths}) {
        my $includePath = $_;
        confess "${\$task->outputFile}" if (!$includePath);
        push(@$options, " \"/I$includePath\"");
    }
}

sub translateDynamicCrt
{
    my ($toolChain, $options, $task) = @_;
    if ($task->optLevel == 0) {
        if ($task->dynamicCrt) {
            push(@$options, " /MDd");
        }
        else {
            push(@$options, " /MTd");
        }
    }
    else { # it's an optimized build
        if ($task->dynamicCrt) {
            push(@$options, " /MD");
        }
        else {
            push(@$options, " /MT");
        }
    }
}

sub emitCompile
{
    my ($toolChain, $FH, $mod, $task) = @_;

    my $name = $toolChain->name;
    my $scriptDir = dirname(__FILE__);

    my $outputFile = Plinja::ninjaEscapePath($task->outputFile);
    my $sourceFile = Plinja::ninjaEscapePath($task->sourceFile);
    my $logFile    = Plinja::ninjaEscapePath($task->outputFile . ".log");
    my $sourceFileName = basename($task->sourceFile);
    my $outputFileName = basename($task->outputFile);
    my $scriptFile = Plinja::ninjaEscapePath("$scriptDir\\msvc-cxx-invoke.pl");

    my $debugOutputs = "";
    if ($task->debugLevel >= 1) {
        $debugOutputs = $debugOutputs . " $outputFile.pdb";
    }
    if ($task->minimalRebuild) {
        $debugOutputs = $debugOutputs . " $outputFile.idb";
    }

    print($FH "build $outputFile $debugOutputs $logFile : ${name}_cxx  $sourceFile | $outputFile.rsp $scriptFile\n");
    print($FH "  WORKING_DIR = ${\$task->workingDir}\n");
    print($FH "  SRC_FILE    = ${\$task->sourceFile}\n");
    print($FH "  OBJ_FILE    = ${\$task->outputFile}\n");
    print($FH "  DEP_FILE    = ${\$task->outputFile}.d\n");
    print($FH "  LOG_FILE    = ${\$task->outputFile}.log\n");
    print($FH "  RSP_FILE    = ${\$task->outputFile}.rsp\n");
    print($FH "  DESC        = $sourceFileName -> $outputFileName\n");
    print($FH "\n");

    # generate response file
    my @options = ();
    push(@options, "/nologo /c");
    $toolChain->translateOptLevel(\@options, $task);
    $toolChain->translateDebugLevel(\@options, $task);
    $toolChain->translateDynamicCrt(\@options, $task);
    # add path lists last to make the major options easier to see
    $toolChain->translateIncludePaths(\@options, $task);
    my $rspContents = join('', @options);
    Plinja::writeFileIfDifferent($task->outputFile . '.rsp', $rspContents);

    push($mod->makeFiles, $task->outputFile . '.rsp');
}

sub emitStaticLibrary
{
    my ($toolChain, $FH, $mod, $task) = @_;

    my $name = $toolChain->name;
    my $scriptDir = dirname(__FILE__);

    my $outputFile = Plinja::ninjaEscapePath($task->outputFile);
    my $logFile    = Plinja::ninjaEscapePath($task->outputFile . ".log");
    my $outputFileName = basename($task->outputFile);
    my $scriptFile = Plinja::ninjaEscapePath("$scriptDir\\msvc-lib-invoke.pl");

    print($FH "\n");
    print($FH "build $outputFile $logFile : ${name}_lib | $outputFile.rsp $scriptFile");
        foreach (@{$task->inputs}) {
            my $input = Plinja::ninjaEscapePath($_);
            print($FH " $input");
        }
        print($FH "\n");
    print($FH "  WORKING_DIR = ${\$task->workingDir}\n");
    print($FH "  LOG_FILE    = ${\$task->outputFile}.log\n");
    print($FH "  RSP_FILE    = ${\$task->outputFile}.rsp\n");
    print($FH "  DESC        = -> $outputFileName\n");
    print($FH "\n");

    # generate response file
    my @options = ();
    push(@options, "/nologo \"/OUT:${\$task->outputFile}\"");
    for my $input (@{$task->inputs}) {
        push(@options, " $input");
    }
    my $rspContents = join('', @options);
    Plinja::writeFileIfDifferent($task->outputFile . '.rsp', $rspContents);

    push($mod->makeFiles, $task->outputFile . '.rsp');
}

sub emitSharedLibrary
{
    my ($toolChain, $FH, $mod, $task) = @_;

    my $name = $toolChain->name;
    my $scriptDir = dirname(__FILE__);

    my $outputFile  = Plinja::ninjaEscapePath($task->outputFile);
    my $libraryFile = "";
    if ($task->outputFile ne $task->libraryFile) {
        $libraryFile = Plinja::ninjaEscapePath($task->libraryFile);
    }
    my $logFile     = Plinja::ninjaEscapePath($task->outputFile . ".log");
    my $outputFileName = basename($task->outputFile);
    my $scriptFile = Plinja::ninjaEscapePath("$scriptDir\\msvc-link-invoke.pl");

    print($FH "\n");
    print($FH "build $outputFile $libraryFile $logFile : ${name}_link | $scriptFile");
        foreach (@{$task->inputs}) {
            my $input = $_;
            next if (!File::Spec->file_name_is_absolute($input));
            $input = Plinja::ninjaEscapePath($input);
            print($FH " $input");
        }
        print($FH "\n");
    print($FH "  WORKING_DIR = ${\$task->workingDir}\n");
    print($FH "  LOG_FILE    = ${\$task->outputFile}.log\n");
    print($FH "  RSP_FILE    = ${\$task->outputFile}.rsp\n");
    print($FH "  DESC        = -> $outputFileName\n");
    print($FH "\n");

    # generate response file
    my @options = ();
    push(@options, "/nologo /DLL \"/OUT:${\$task->outputFile}\"");
    for my $input (@{$task->inputs}) {
        if ($input =~ m/[.]lib$/) {
            my $libpath = dirname($input);
            my $libname = basename($input);
            push(@options, " \"/LIBPATH:$libpath\" \"$libname\"");
        }
        else {
            push(@options, " \"$input\"");
        }
    }
    if ($task->keepDebugInfo) {
        push(@options, " /DEBUG");
    }
    my $rspContents = join('', @options);
    Plinja::writeFileIfDifferent($task->outputFile . '.rsp', $rspContents);

    push($mod->makeFiles, $task->outputFile . '.rsp');
}

sub emitExecutable
{
    my ($toolChain, $FH, $mod, $task) = @_;

    my $name = $toolChain->name;
    my $scriptDir = dirname(__FILE__);

    my $outputFile = Plinja::ninjaEscapePath($task->outputFile);
    my $logFile    = Plinja::ninjaEscapePath($task->outputFile . ".log");
    my $outputFileName = basename($task->outputFile);
    my $scriptFile = Plinja::ninjaEscapePath("$scriptDir\\msvc-link-invoke.pl");

    print($FH "\n");
    print($FH "build $outputFile $logFile : ${name}_link | $scriptFile");
        foreach (@{$task->inputs}) {
            my $input = $_;
            next if (!File::Spec->file_name_is_absolute($input));
            $input = Plinja::ninjaEscapePath($input);
            print($FH " $input");
        }
        print($FH "\n");
    print($FH "  WORKING_DIR = ${\$task->workingDir}\n");
    print($FH "  LOG_FILE    = ${\$task->outputFile}.log\n");
    print($FH "  RSP_FILE    = ${\$task->outputFile}.rsp\n");
    print($FH "  DESC        = -> $outputFileName\n");
    print($FH "\n");

    # generate response file
    my @options = ();
    push(@options, "/nologo \"/OUT:${\$task->outputFile}\"");
    for my $input (@{$task->inputs}) {
        if ($input =~ m/[.]lib$/) {
            my $libpath = dirname($input);
            my $libname = basename($input);
            push(@options, " \"/LIBPATH:$libpath\" \"$libname\"");
        }
        else {
            push(@options, " \"$input\"");
        }
    }
    if ($task->keepDebugInfo) {
        push(@options, " /DEBUG");
    }
    my $rspContents = join('', @options);
    Plinja::writeFileIfDifferent($task->outputFile . '.rsp', $rspContents);

    push($mod->makeFiles, $task->outputFile . '.rsp');
}

1;

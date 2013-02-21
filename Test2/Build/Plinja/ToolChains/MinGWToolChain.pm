package MinGWToolChain;
use Mouse;
use CppToolChain;
use File::Basename;
use Plinja;

extends CppToolChain;

has installDir => (is => 'ro');
has prefix => (is => 'ro');
has suffix => (is => 'ro');

my $scriptDir = dirname(__FILE__);
my $cxx_script = "$scriptDir/mingw-cxx-invoke.pl";
my $lib_script = "$scriptDir/mingw-ar-invoke.pl";
my $link_script = "$scriptDir/mingw-ld-invoke.pl";

sub emitRules
{
    my ($toolChain, $FH) = @_;

    my $name = $toolChain->name;
    my $installDir = $toolChain->installDir;
    my $prefix = $toolChain->prefix;
    if (!$prefix) {
        $prefix = "_NO_PREFIX_";
    }
    my $suffix = $toolChain->suffix;
    if (!$suffix) {
        $suffix = "_NO_SUFFIX_";
    }

    print($FH "#############################################\n");
    print($FH "# $name\n");
    print($FH "\n");
    print($FH "rule ${name}_cxx\n");
    print($FH "  depfile = \$DEP_FILE\n");
    print($FH "  command = perl \"$cxx_script\"  \"\$WORKING_DIR\"  \"\$SRC_FILE\"  \"\$OBJ_FILE\"  \"\$DEP_FILE\"  \"\$LOG_FILE\"  \"$installDir\"  $prefix  $suffix  \"\$RSP_FILE\"  \n");
    print($FH "  description = ${name}_cxx \$DESC\n");
    print($FH "  restat = 1\n");
    print($FH "\n");
    print($FH "rule ${name}_lib\n");
    print($FH "  command = perl \"$lib_script\"  \"\$WORKING_DIR\"  \"\$LOG_FILE\"  \"$installDir\"  $prefix  $suffix  \"\$RSP_FILE\"  \n");
    print($FH "  description = ${name}_lib \$DESC\n");
    print($FH "  restat = 1\n");
    print($FH "\n");
    print($FH "rule ${name}_link\n");
    print($FH "  command = perl \"$link_script\"  \"\$WORKING_DIR\"  \"\$LOG_FILE\"  \"$installDir\"  $prefix  $suffix  \"\$RSP_FILE\"  \n");
    print($FH "  description = ${name}_link \$DESC\n");
    print($FH "  restat = 1\n");
    print($FH "\n");
}

sub translateOptLevel
{
    my ($toolChain, $options, $task) = @_;
    if (0 <= $task->optLevel && $task->optLevel <= 3) {
        push(@$options, "-O${\$task->optLevel}");
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

    push(@$options, "-g${\$task->debugLevel}");
    # "minimalRebuild" is not supported on gcc
}

sub translateIncludePaths
{
    my ($toolChain, $options, $task) = @_;
    foreach (@{$task->includePaths}) {
        my $includePath = $_;
        confess "${\$task->outputFile}" if (!$includePath);
        $includePath =~ s%\\%/%g;
        push(@$options, "-I\"$includePath\"");
    }
}

sub translateDefines
{
    my ($toolChain, $options, $task) = @_;
    foreach (@{$task->defines}) {
        my $define = $_;
        confess "empty define for ${\$task->outputFile}" if (!$define);
        push(@$options, "-D\"$define\"");
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
    my $scriptFile = Plinja::ninjaEscapePath($cxx_script);

    print($FH "build $outputFile $logFile : ${name}_cxx  $sourceFile | $outputFile.rsp $scriptFile\n");
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
    push(@options, "-c");
    $toolChain->translateOptLevel(\@options, $task);
    $toolChain->translateDebugLevel(\@options, $task);
    # add path lists last to make the major options easier to see
    $toolChain->translateIncludePaths(\@options, $task);
    $toolChain->translateDefines(\@options, $task);
    push(@options, @{$task->extraOptions});
    my $rspContents = join(' ', @options);
    Plinja::writeFileIfDifferent($task->outputFile . '.rsp', $rspContents);

    push(@{$mod->makeFiles}, $task->outputFile . '.rsp');
}

sub binutilsEscapePath
{
    my ($path) = @_;

    my $pathEsc = $path;
    $pathEsc =~ s%\\%/%g;
    return $pathEsc;
}

sub translateLinkerInputs
{
    my ($toolChain, $options, $task) = @_;

    for my $input (@{$task->inputs}) {
        if ($input =~ ".a\$") {
            my ($inputFile, $inputDir, $ext) = fileparse($input, qr/\.[^.]*/);
            my $inputDirEsc = binutilsEscapePath($inputDir);
            my $libName = substr($inputFile, 3);
            push(@$options, "-L\"$inputDirEsc\"");
            push(@$options, "-l$libName");
        }
        else {
            my $inputEsc = binutilsEscapePath($input);
            push(@$options, "\"$inputEsc\"");
        }
    }
}

sub emitStaticLibrary
{
    my ($toolChain, $FH, $mod, $task) = @_;

    my $name = $toolChain->name;
    my $scriptDir = dirname(__FILE__);

    my $outputFile = Plinja::ninjaEscapePath($task->outputFile);
    my $logFile    = Plinja::ninjaEscapePath($task->outputFile . ".log");
    my $outputFileName = basename($task->outputFile);
    my $scriptFile = Plinja::ninjaEscapePath($lib_script);

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
    push(@options, "rc"); # replace file entries, and create archive if it didn't exist already
    my $outputFileEsc = binutilsEscapePath($task->outputFile);
    push(@options, "\"$outputFileEsc\"");    # first argument is archive name
    $toolChain->translateLinkerInputs(\@options, $task);
    push(@options, @{$task->extraOptions});
    my $rspContents = join(' ', @options);
    Plinja::writeFileIfDifferent($task->outputFile . '.rsp', $rspContents);

    push(@{$mod->makeFiles}, $task->outputFile . '.rsp');
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
    my $scriptFile = Plinja::ninjaEscapePath($link_script);

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
    push(@options, " ");
    push(@options, "-shared");
    my $outputFileEsc = binutilsEscapePath($task->outputFile);
    push(@options, "-o \"$outputFileEsc\"");
    $toolChain->translateLinkerInputs(\@options, $task);
    if (!$task->keepDebugInfo) {
        push(@options, "--strip-debug");
    }
    push(@options, @{$task->extraOptions});
    my $rspContents = join(' ', @options);
    Plinja::writeFileIfDifferent($task->outputFile . '.rsp', $rspContents);

    push(@{$mod->makeFiles}, $task->outputFile . '.rsp');
}

sub emitExecutable
{
    my ($toolChain, $FH, $mod, $task) = @_;

    my $name = $toolChain->name;
    my $scriptDir = dirname(__FILE__);

    my $outputFile = Plinja::ninjaEscapePath($task->outputFile);
    my $logFile    = Plinja::ninjaEscapePath($task->outputFile . ".log");
    my $outputFileName = basename($task->outputFile);
    my $scriptFile = Plinja::ninjaEscapePath($link_script);

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
    push(@options, " ");
    my $outputFileEsc = binutilsEscapePath($task->outputFile);
    push(@options, "-o\"$outputFileEsc\"");
    $toolChain->translateLinkerInputs(\@options, $task);
    if (!$task->keepDebugInfo) {
        push(@options, "--strip-debug");
    }
    push(@options, @{$task->extraOptions});
    my $rspContents = join(' ', @options);
    Plinja::writeFileIfDifferent($task->outputFile . '.rsp', $rspContents);

    push(@{$mod->makeFiles}, $task->outputFile . '.rsp');
}

1;

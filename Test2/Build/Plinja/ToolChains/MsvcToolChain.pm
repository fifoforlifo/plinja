package MsvcToolChain;
use Mouse;
use ToolChain;
use File::Basename;

extends ToolChain;

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
    print($FH "  description = ${name}_cxx target \$out\n");
    print($FH "  restat = 1\n");
    print($FH "\n");
    print($FH "rule ${name}_lib\n");
    print($FH "  command = perl $scriptDir\\msvc-lib-invoke.pl  \"\$WORKING_DIR\"  \"\$LOG_FILE\"  \"$vsInstallDir\"  $arch  \"\$RSP_FILE\"  \n");
    print($FH "  description = ${name}_lib target \$out\n");
    print($FH "  restat = 1\n");
    print($FH "\n");
    print($FH "rule ${name}_link\n");
    print($FH "  command = perl $scriptDir\\msvc-link-invoke.pl  \"\$WORKING_DIR\"  \"\$LOG_FILE\"  \"$vsInstallDir\"  $arch  \"\$RSP_FILE\"  \n");
    print($FH "  description = ${name}_link target \$out\n");
    print($FH "  restat = 1\n");
    print($FH "\n");
}

sub ninjaEscapePath
{
    my $str = shift;
    $str =~ s/:/\$\:/;
    $str =~ s/ /\$ /;
    return $str;
}

sub emitCompile
{
    my ($toolChain, $FH, $task) = @_;
    
    my $name = $toolChain->name;
    my $scriptDir = dirname(__FILE__);
    
    my $outputFile = ninjaEscapePath($task->outputFile);    
    my $sourceFile = ninjaEscapePath($task->sourceFile);
    my $logFile    = ninjaEscapePath($task->outputFile . ".log");
    
    print($FH "\n");
    print($FH "build $outputFile $logFile : ${name}_cxx  $sourceFile\n");
    print($FH "  WORKING_DIR = ${\$task->workingDir}\n");
    print($FH "  SRC_FILE = ${\$task->sourceFile}\n");
    print($FH "  OBJ_FILE = ${\$task->outputFile}\n");
    print($FH "  DEP_FILE = ${\$task->outputFile}.d\n");
    print($FH "  LOG_FILE = ${\$task->outputFile}.log\n");
    print($FH "  RSP_FILE = ${\$task->outputFile}.rsp\n");
    print($FH "  rspfile  = ${\$task->outputFile}.rsp\n");
    print($FH "  rspfile_content = /nologo /c /Od\n");
}

sub emitStaticLibrary
{
    my ($toolChain, $FH, $task) = @_;
    
    my $name = $toolChain->name;
    my $scriptDir = dirname(__FILE__);
    
    my $outputFile = ninjaEscapePath($task->outputFile);
    my $logFile    = ninjaEscapePath($task->outputFile . ".log");
    
    print($FH "\n");
    print($FH "build $outputFile $logFile : ${name}_lib ");
        if (scalar(@{$task->inputs})) {
            print($FH "|");
        }
        foreach (@{$task->inputs}) {
            my $input = ninjaEscapePath($_);
            print($FH " $input");
        }
        print($FH "\n");
    print($FH "  WORKING_DIR = ${\$task->workingDir}\n");
    print($FH "  LOG_FILE = ${\$task->outputFile}.log\n");
    print($FH "  RSP_FILE = ${\$task->outputFile}.rsp\n");
    print($FH "  rspfile  = ${\$task->outputFile}.rsp\n");
    print($FH "  rspfile_content = /nologo /OUT:${\$task->outputFile}");
        foreach (@{$task->inputs}) {
            my $input = $_;
            print($FH " $input");
        }
        print($FH "\n");
    print($FH "\n");
}

sub emitSharedLibrary
{
    my ($toolChain, $FH, $task) = @_;
    
    my $name = $toolChain->name;
    my $scriptDir = dirname(__FILE__);
    
    my $outputFile  = ninjaEscapePath($task->outputFile);
    my $libraryFile = "";
    if ($task->outputFile ne $task->libraryFile) {
        $libraryFile = ninjaEscapePath($task->libraryFile);
    }
    my $logFile     = ninjaEscapePath($task->outputFile . ".log");

    print($FH "\n");
    print($FH "build $outputFile $libraryFile $logFile : ${name}_link ");
        if (scalar(@{$task->inputs})) {
            print($FH "|");
        }
        foreach (@{$task->inputs}) {
            my $input = ninjaEscapePath($_);
            print($FH " $input");
        }
        print($FH "\n");
    print($FH "  WORKING_DIR = ${\$task->workingDir}\n");
    print($FH "  LOG_FILE = ${\$task->outputFile}.log\n");
    print($FH "  RSP_FILE = ${\$task->outputFile}.rsp\n");
    print($FH "  rspfile  = ${\$task->outputFile}.rsp\n");
    print($FH "  rspfile_content = /nologo /DLL /OUT:${\$task->outputFile}");
        foreach (@{$task->libPaths}) {
            my $libPath = $_;
            print($FH " \"/LIBPATH:$libPath\"");
        }
        foreach (@{$task->inputs}) {
            my $input = $_;
            print($FH " \"$input\"");
        }
        print($FH "\n");
    print($FH "\n");
}

sub emitExecutable
{
    my ($toolChain, $FH, $task) = @_;
    
    my $name = $toolChain->name;
    my $scriptDir = dirname(__FILE__);
    
    my $outputFile = ninjaEscapePath($task->outputFile);
    my $logFile    = ninjaEscapePath($task->outputFile . ".log");

    print($FH "\n");
    print($FH "build $outputFile $logFile : ${name}_link ");
        if (scalar(@{$task->inputs})) {
            print($FH "|");
        }
        foreach (@{$task->inputs}) {
            my $input = ninjaEscapePath($_);
            print($FH " $input");
        }
        print($FH "\n");
    print($FH "  WORKING_DIR = ${\$task->workingDir}\n");
    print($FH "  LOG_FILE = ${\$task->outputFile}.log\n");
    print($FH "  RSP_FILE = ${\$task->outputFile}.rsp\n");
    print($FH "  rspfile  = ${\$task->outputFile}.rsp\n");
    print($FH "  rspfile_content = /nologo /OUT:${\$task->outputFile}");
        foreach (@{$task->libPaths}) {
            my $libPath = $_;
            print($FH " \"/LIBPATH:$libPath\"");
        }
        foreach (@{$task->inputs}) {
            my $input = $_;
            print($FH " \"$input\"");
        }
        print($FH "\n");
    print($FH "\n");
}

1;
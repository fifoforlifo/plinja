package Variant;
use Mouse;

has str => (is => 'ro', isa => 'Str');

sub BUILD
{
    my $variant = shift;
    my $fieldDefs = $variant->getFieldDefs();
    my @variantParts = split(".", $variant->str);
    for (my $i = 0; $i < scalar(@variantParts); $i++) {
        my $fieldVal     = $variantParts[$i];
        my $fieldName    = @$fieldDefs[$i * 2 + 0];
        my $fieldOptions = @$fieldDefs[$i * 2 + 1];
        if (!grep($fieldVal, @$fieldOptions)) {
            print "'$fieldVal' is not valid for field '$fieldName'\n";
            print "Valid options are:\n";
            foreach (@$fieldOptions) {
                my $fieldOption = $_;
                print "    $fieldOption\n";
            }
            die;
        }
        $variant->{$fieldName} = $fieldVal;
    }
    return $variant;
}

# Should return an array containing fieldName => [ field_option ].
# For example, ['os' => ['win32', 'linux'], 'arch' => ['x86', 'amd64', 'arm32'], 'config' => ['dbg', 'rel']].
sub getFieldDefs
{
    die sprintf("you need to implement %s::%s", $_[0], (caller(0))[3]);
}

1;

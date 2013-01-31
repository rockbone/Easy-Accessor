package Easy::Accessor;

=head1 NAME Easy::Accessor

 make accessor easy

=cut

use strict;
use Carp;
use base "Exporter";

our $VERSION = '0.01';
our @EXPORT = qw/set_accessor/;
our @EXPORT_OK = qw/set_accessor_read_only set_accessor_class_only set_accessor_class_selected/;
our %EXPORT_TAGS = (
    all     => [ @EXPORT,@EXPORT_OK ]
);
our $box = {};

=head1 FUNCTIONS

=head2 set_accessor

=head4 set accessor of your class object
 
 package Your::Class;
 set_accessor(qw/foo bar baz/);
 
=cut
sub set_accessor {
    my @names = @_;
    my $set_class = caller;
    {
        no strict 'refs';
        for my $name(@names){
            *{"$set_class\::$name"} = sub {
                my $self = shift;
                return $box->{$set_class}{$name} if !@_;
                $box->{$set_class}{$name} = shift;
                return $self;
            };
        }
    }
}

=head2 set_accessor_read_only

=head4 set readonly accessor of your class object
 
 package Your::Class;
 set_accessor_read_only(qw/foo bar baz/);
 
=cut
sub set_accessor_read_only {
    my @names = @_;
    my $set_class = caller;
    {
        no strict 'refs';
        for my $name(@names){
            *{"$set_class\::$name"} = sub {
                my $self = shift;
                return $box->{$set_class}{$name} if !@_;
                croak "Accessor restriction!\nReadonly.Can't set again." if $box->{$set_class}{$name};
                $box->{$set_class}{$name} = shift;
                return $self;
            };
        }
    }
}

=head2 set_accessor_class_only 

=head4 set accessor call from just only the class it set

 package Your::Class;
 set_accessor_class_only(qw/foo bar baz/);
 
=cut

sub set_accessor_class_only {
    my @names = @_;
    my $set_class = caller;
    {
        no strict 'refs';
        for my $name(@names){
            *{"$set_class\::$name"} = sub {
                croak "Accessor restriction!\nYou can call '$name' from just only $set_class package" if caller ne $set_class;
                my $self = shift;
                return $box->{$set_class}{$name} if !@_;
                $box->{$set_class}{$name} = shift;
                return $self;
            };
        }
    }
}

=head2 set_accessor_class_selected

=head4 set accessor call from only a class or classes selected

 package Your::Class;
 set_accessor_class_selected(
     class => 'main',           # possible as [class1,class2,...]
     name  => 'foo'             # possible as [qw/foo bar baz/]
 );
 
=cut

sub set_accessor_class_selected {
    my %arg = @_;
    my @classes = ref $arg{class} ? @{$arg{class}} : ($arg{class});
    my @names = ref $arg{name} ? @{$arg{name}} : ($arg{name});
    my $set_class = caller;
    {
        no strict 'refs';
        for (@classes){
            if (!%{"$_\::"}){ 
                carp "perhaps class '$_' has no entry in that symbole table or class not exist";
            }
        }
        for my $name(@names){
            *{"$set_class\::$name"} = sub {
                croak "Accessor restriction!\nYou can call '$name' only from [@classes] package" if !grep{ caller eq $_ }@classes;
                my $self = shift;
                return $box->{$set_class}{$name} if !@_;
                $box->{$set_class}{$name} = shift;
                return $self;
            };
        }
    }
}
1;

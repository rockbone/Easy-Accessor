package Easy::Accessor;

=head1 NAME Easy::Accessor

 make accessor easy

=cut

=head1 SYNOPSYS
    
    {
        package Your::Class1;

        use Easy::Accessor;                     # import only 'set_accessor'
        use Easy::Accessor qw/:all/;            # import all functions below
        
        sub new {
            ......
            return bless...;
        }

        set_accessor(qw/foo/);
        set_accessor_read_only(qw/bar/);        
        set_accessor_class_only(qw/baz/);
        set_accessor_class_selected(
            class => 'Your::Class2',            # possible as [class1,class2,...]
            name  => 'class2_foo'               # possible as [qw/foo bar baz/]
        );

        our $result = {                         # it must be 'my' and '$' so I can't look into scratchpad of lexical var yet.
           foo => 100,
           bar => {
               baz => 20
           }
        };
        set_accessor_hash_ref($result);
        undef $hash_ref;                        # undef to capsule it self
    }

    {
        package Your::Class2;

        ......
    }

    {
        package main;
        
        my $x = Your::Class->new;
        
        $x->foo("hello");
        print $x->foo;                               # hello
        
        $x->bar(1);                             # once you set
        $x->bar(2);                             # die read only
        
        $x->baz('from_main');                   # die class only

        $x->class2_foo('from_main');            # die access only selected class

        print $x->result->foo;                  # 100
        $x->bar->boo(80);                       # set like hash
    }
=cut
use strict;
use Carp;
use base "Exporter";

our $VERSION = '0.01';
our @EXPORT = qw/set_accessor/;
our @EXPORT_OK = qw/set_accessor_read_only set_accessor_class_only set_accessor_class_selected set_accessor_hash_ref/;
our %EXPORT_TAGS = (
    all     => [ @EXPORT,@EXPORT_OK ]
);
our $box = {};

=head1 FUNCTIONS

=head2 set_accessor

=head4 set accessor of your class object
 
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
                return $box->{$self}{$name} if !@_;
                $box->{$self}{$name} = shift;
                return $self;
            };
        }
    }
}

=head2 set_accessor_read_only

=head4 set readonly accessor of your class object
 
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
                return $box->{$self}{$name} if !@_;
                croak "Accessor restriction!\nReadonly.Can't set again." if $box->{$self}{$name};
                $box->{$self}{$name} = shift;
                return $self;
            };
        }
    }
}

=head2 set_accessor_class_only 

=head4 set accessor call from just only the class it set

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
                return $box->{$self}{$name} if !@_;
                $box->{$self}{$name} = shift;
                return $self;
            };
        }
    }
}

=head2 set_accessor_class_selected

=head4 set accessor call from only a class or classes selected

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
            if (!%{"$_\::"}){  # perhaps no symbole in the package
                carp "perhaps class '$_' has no entry in that symbole table";
            }
        }
        for my $name(@names){
            *{"$set_class\::$name"} = sub {
                croak "Accessor restriction!\nYou can call '$name' only from [@classes] package" if !grep{ caller eq $_ }@classes;
                my $self = shift;
                return $box->{$self}{$name} if !@_;
                $box->{$self}{$name} = shift;
                return $self;
            };
        }
    }
}

=head2 set_accessor_heash_ref

=head4 set accessor of your class hash reference
 
 our $hash_ref = {                  # it must be 'my' and '$' so I can't look into scratchpad of lexical var yet.
    foo => 1,
    bar => {
        baz => 2
    }
 };
 set_accessor_hash_ref($hash_ref);
 undef $hash_ref;                   # undef to capsule it self
 
 you can write... $self->bar->baz   # usually, $hash_ref->{bar}{baz} or $self->getter->{bar}{baz}
 
=cut
sub set_accessor_hash_ref {
    my $hash_ref = shift;
    my $set_class = caller;
    my $smbl = _detect_symbole($hash_ref,$set_class)
        or croak "Set only hash ref!";
    {
        no strict 'refs';
        my $new_class = "$set_class\::$smbl";
        *{"$set_class\::$smbl"} = sub {
            return bless $hash_ref,$new_class;
         };
         _expand_hash_ref($hash_ref,$new_class);
    }
}


sub _detect_symbole {
    my ($ref,$class) = @_;
    no strict 'refs';
    my $smbl_name;
    for my $smbl(keys %{"$class\::"}){
        if ( defined \%{"$class\::$smbl"} && \%{"$class\::$smbl"} eq $ref 
          or defined ${"$class\::$smbl"}  &&  ${"$class\::$smbl"} eq $ref){
            $smbl_name = $smbl;
        }
    }
    return $smbl_name || undef;
}

sub _expand_hash_ref {
    my ($ref,$class) = @_;
    no strict 'refs';
    for my $key(keys %{$ref}){
        if (ref $ref->{$key} eq 'HASH'){
            my $new_class = "$class\::$key";
            *{"$class\::$key"} = sub {
                return bless $ref->{$key},$new_class;
            };
            _expand_hash_ref($ref->{$key},$new_class);
        }
        else{
            *{"$class\::$key"} = sub {
                my $self = shift;
                return $box->{$self}{$key} || $ref->{$key} if !@_;
                $box->{$self}{$key} = shift;
                return $self;
            };
        }
    }
    *{"$class\::AUTOLOAD"} = sub {
        my $self = shift;
        my $arg = shift;
        my %self_box = %$self;                  # avoid deep recursion
        our $AUTOLOAD;
        my ($call) = $AUTOLOAD =~ /::([\w_]+)$/; 
        $self->{$call} = $self_box{$call} = $arg || {};
        delete $self->{DESTROY};
        *{"$class\::$call"} = sub {
            my $self = shift;
            return $box->{$self}{$call} || $self->{$call} if !@_;
            $box->{$self}{$call} = shift;
            return $self;
        };
        return $self if $arg;                   # case setter
        return bless $self_box{$call},$class;   # bless copy so avoid deep recursion
                                                # hand over follow subs
    };
}
1;








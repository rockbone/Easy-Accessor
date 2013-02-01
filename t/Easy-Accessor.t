use strict;
use warnings;

use Test::More tests => 15;
#use Test::More "no_plan";
BEGIN { use_ok('Easy::Accessor') };

{
    package Test1;
    use Easy::Accessor qw/:all/;
    
    sub new {
        return bless {},+shift;
    }

    set_accessor(qw/one/);
    set_accessor_read_only(qw/two/);
    set_accessor_class_only(qw/three/);
    set_accessor_class_selected(
        class   => [ __PACKAGE__,"Test2"],
        name    => [ qw/four/]
    );
    
    sub test1 {
        my $t1 = shift;
        $t1->one(1);
        main::is($t1->one ,1,"set_accessor ok from ".__PACKAGE__);
        $t1->two(2);
        eval{$t1->two(22)};
        main::is($t1->two ,2,"set_accessor_readonly ok from ".__PACKAGE__);
        $t1->three(3);
        main::is($t1->three ,3,"set_accessor_class_only ok from ".__PACKAGE__);
        $t1->four(4);
        main::is($t1->four ,4,"set_accessor_class_selected ok from ".__PACKAGE__);
    }
}

{
    package Test2;
    use base 'Test1';
    
    sub test2 {
        my $t2 = shift;
        $t2->one(11);
        main::is($t2->one ,11,"set_accessor ok from ".__PACKAGE__);
        main::is($t2->two ,2,"set_accessor_readonly ok from ".__PACKAGE__);
        eval{$t2->two(222)};
        main::is($t2->two ,2,"set_accessor_readonly ok from ".__PACKAGE__);
        my $res = eval{$t2->three(33)};
        main::ok(!$res ,"set_accessor_class_only ok from ".__PACKAGE__);
        $t2->four(44);
        main::is($t2->four ,44,"set_accessor_class_selected ok from ".__PACKAGE__);

    }
}

my $m = Test2->new;
use Data::Dumper;

$m->test1;
$m->test2;
test3($m);

sub test3 {
    my $m = shift;
    $m->one(11);
    main::is($m->one ,11,"set_accessor ok from ".__PACKAGE__);
    main::is($m->two ,2,"set_accessor_readonly ok from ".__PACKAGE__);
    eval{$m->two(222)};
    main::is($m->two ,2,"set_accessor_readonly ok from ".__PACKAGE__);
    my $res = eval{$m->three(33)};
    main::ok(!$res ,"set_accessor_class_only ok from ".__PACKAGE__);
    $res = eval{$m->four(44)};
    main::ok(!$res,"set_accessor_class_selected ok from ".__PACKAGE__);

}

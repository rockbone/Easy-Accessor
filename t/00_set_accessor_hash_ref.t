use strict;
use warnings;

#use Test::More tests => 15;
use Test::More "no_plan";
{
    package Test1;
    use Easy::Accessor qw/set_accessor_hash_ref/;
    
    my $x = "hello";
    sub new {
        return bless {},+shift;
    }
   
    our $hash = {
        test1  => 1,
        test2  => 2
    };
    set_accessor_hash_ref($hash);
    undef $hash;
    
    sub test1 {
        my $t1 = shift;
        main::is($t1->hash->test1 ,1,"set_accessor_hash_ref getter ok from ".__PACKAGE__);
        main::is($t1->hash->test2 ,2,"set_accessor_hash_ref getter ok from ".__PACKAGE__);
        main::is(ref $t1->hash->test3 ,'Test1::hash',"set_accessor_hash_ref getter non exist key ok from ".__PACKAGE__);
        $t1->hash->test4(4);
        main::is($t1->hash->test4 ,4,"set_accessor_hash_ref setter ok from ".__PACKAGE__);
        $t1->hash->test1(11);
        main::is($t1->hash->test1 ,11,"set_accessor_hash_ref setter change value ok from ".__PACKAGE__);
    }
}

{
    package Test2;
    use base 'Test1';
    
    sub test2 {
        my $t2 = shift;
        main::is($t2->hash->test1 ,11,"set_accessor_hash_ref getter ok from ".__PACKAGE__);
        main::is($t2->hash->test2 ,2,"set_accessor_hash_ref getter ok from ".__PACKAGE__);
        main::is(ref $t2->hash->test3 ,'Test1::hash',"set_accessor_hash_ref getter non exist key ok from ".__PACKAGE__);
        $t2->hash->test4(44);
        main::is($t2->hash->test4 ,44,"set_accessor_hash_ref setter ok from ".__PACKAGE__);
        $t2->hash->test1(111);
        main::is($t2->hash->test1 ,111,"set_accessor_hash_ref setter change value ok from ".__PACKAGE__);
    }
}

my $m = Test2->new;
use Data::Dumper;

$m->test1;
$m->test2;
test3($m);

sub test3 {
    my $m = shift;
    main::is($m->hash->test1 ,111,"set_accessor_hash_ref getter ok from ".__PACKAGE__);
    main::is($m->hash->test2 ,2,"set_accessor_hash_ref getter ok from ".__PACKAGE__);
    main::is(ref $m->hash->test3 ,'Test1::hash',"set_accessor_hash_ref getter non exist key ok from ".__PACKAGE__);
    $m->hash->test4(444);
    main::is($m->hash->test4 ,444,"set_accessor_hash_ref setter ok from ".__PACKAGE__);
    $m->hash->test1(1111);
    main::is($m->hash->test1 ,1111,"set_accessor_hash_ref setter change value ok from ".__PACKAGE__);
}

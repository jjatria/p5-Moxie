#!perl

use strict;
use warnings;

use Test::More;


=pod

...

=cut

package Foo {
    use Moxie
        traits => [':experimental'];

    extends 'Moxie::Object';

    has '_bar';

    my sub _bar : private;

    sub BUILDARGS : strict( bar? => _bar );

    sub init_bar { _bar = [ 1, 2, 3 ] }
    sub bar      { _bar //= [ 5, 10, 15 ] }

    sub has_bar   : predicate(_bar);
    sub set_bar   : wo(_bar);
    sub clear_bar : clearer(_bar);
}

{
    my $foo = Foo->new;
    ok( $foo->isa( 'Foo' ), '... the object is from class Foo' );

    ok(!$foo->has_bar, '... no bar is set');
    is_deeply($foo->bar, [ 5, 10, 15 ], '... values are defined');

    my $bar_1 = $foo->bar;

    ok($foo->has_bar, '... bar is now set');

    eval { $foo->init_bar };
    is($@, "", '... initialized bar without error');
    is_deeply($foo->bar, [ 1, 2, 3 ], '... value is initialized by the init_bar method');

    eval { $foo->set_bar([1000]) };
    is($@, "", '... set bar without error');
    is_deeply($foo->bar, [1000], '... value is set by the set_bar method');

    eval { $foo->clear_bar };
    is($@, "", '... set bar without error');
    ok(!$foo->has_bar, '... no bar is set');
    is_deeply($foo->bar, [ 5, 10, 15 ], '... values are defined');

    isnt($foo->bar, $bar_1, '... new values are regnerated by the lazy init');
}

{
    my $foo = Foo->new( bar => [10] );
    ok( $foo->isa( 'Foo' ), '... the object is from class Foo' );

    ok($foo->has_bar, '... a bar is set');
    is_deeply($foo->bar, [10], '... values are initialized via the constructor');

    eval { $foo->init_bar };
    is($@, "", '... initialized bar without error');
    ok($foo->has_bar, '... a bar is set');
    is_deeply($foo->bar, [1, 2, 3], '... value is initialized by the init_bar method');

    eval { $foo->set_bar([1000]) };
    is($@, "", '... set bar without error');
    ok($foo->has_bar, '... a bar is set');
    is_deeply($foo->bar, [1000], '... value is set by the set_bar method');

    eval { $foo->clear_bar };
    is($@, "", '... set bar without error');
    ok(!$foo->has_bar, '... no bar is set');
    is_deeply($foo->bar, [ 5, 10, 15 ], '... values are defined');
}


done_testing;

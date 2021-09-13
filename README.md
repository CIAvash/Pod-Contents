NAME
====

Pod::Contents - a [Raku](https://www.raku-lang.ir/en) module for getting Pod contents as a list or string.

DESCRIPTION
===========

Pod::Contents is a [Raku](https://www.raku-lang.ir/en) module for getting the Pod contents as a list of strings or string.

Pod formatters can get inlined, pod contents can be indented (with custom level) and joined with a custom
string and titles can be included for `table` headers and `defn` terms.

SYNOPSIS
========

```raku
use Pod::Contents:auth<zef:CIAvash>;

=NAME My App

=DESCRIPTION An B<app> that does U<stuff>

=begin pod
=head1 A heading

=item An B<item>
=begin item2
Another C<item>

=begin table
hcell00 | hcell01
=================
cell11  | cell12
cell21  | cell22
=end table

     my $app;
     say 'some code';

=end item2

=end pod

put $=pod.&join_pod_contents_of: 'NAME';
=output My App␤

put $=pod.&get_first_pod('NAME').&join_pod_contents;
=output My App␤

put $=pod[0].&join_pod_contents;
=output My App␤

put $=pod[0].&get_pod_contents.join("\n\n");
=output My App␤

put $=pod.&join_pod_contents_of: 'DESCRIPTION';
=output An app that does stuff␤

put $=pod.&join_pod_contents_of: 'DESCRIPTION', :!inline_formatters;
=output An ␤␤app␤␤ that does ␤␤stuff␤

put $=pod.&join_pod_contents_of: 'DESCRIPTION', "\n", :!inline_formatters;
=output An ␤app␤ that does ␤stuff␤

put $=pod.&get_pod_contents_of('DESCRIPTION', :!inline_formatters).raku;
=output ("An ", "app", " that does ", "stuff")␤

put $=pod.&get_first_pod('pod').&join_pod_contents_of: Pod::Heading;
=output A heading␤

put $=pod.&join_pod_contents_of: Pod::Item, :recurse;
=output An item␤

put $=pod.&get_pod_contents_of(Pod::Block::Table, :recurse).raku;
=output (("cell11", "cell12"), ("cell21", "cell22"))␤

put $=pod.&get_pod_contents_of(Pod::Block::Table, :recurse, :include_title).raku;
=output (("hcell00", "hcell01"), ("cell11", "cell12"), ("cell21", "cell22"))␤

put $=pod.&join_pod_contents_of: Pod::Block::Table, :recurse;
=output cell11 cell12␤cell21 cell22␤

put $=pod.&join_pod_contents_of: Pod::Block::Table, :recurse, :include_title;
=output hcell00 hcell01␤cell11 cell12␤cell21 cell22␤

put $=pod.&join_pod_contents_of: Pod::Block::Code, :recurse;
=output my $app;␤say 'some code'␤

put $=pod.&join_pod_contents_of: Pod::Block::Code, :indent_content, :recurse;
=output     my $app;␤    say 'some code'␤

put $=pod.&get_first_pod('pod').contents.grep(Pod::Item)[1].&join_pod_contents(:indent_content);
=output     Another item␤␤   cell11 cell12␤cell21 cell22␤␤        my $app;␤        say 'some code'␤

put $=pod.&get_first_pod('pod').&get_pods(Pod::Item)[1].&join_pod_contents(:indent_content, :indent_level(2));
=output   Another item␤␤ cell11 cell12␤cell21 cell22␤␤      my $app;␤      say 'some code'␤

put $=pod.&get_pods(Pod::Item, :recurse)[1].&join_pod_contents(:indent_content, :indent_level(2));
=output   Another item␤␤ cell11 cell12␤cell21 cell22␤␤      my $app;␤      say 'some code'␤
```

INSTALLATION
============

You need to have [Raku](https://www.raku-lang.ir/en) and [zef](https://github.com/ugexe/zef), then run:

```console
zef install --/test Pod::Contents:auth<zef:CIAvash>
```

or if you have cloned the repo:

```console
zef install .
```

TESTING
=======

```console
prove -ve 'raku -I.' --ext rakutest
```

SUBS
====

## sub get_pod_contents_of

```raku
sub get_pod_contents_of(
    $pod where { ... },
    $thing where { ... },
    Bool :$recurse,
    |c
) returns List:D
```

Returns a list of pod contents.

- Can recursively find pod with `:recurse`.
- Can indent pod contents with `:indent_content`.
- Can include pod titles with `:include_title`.
- Can disable inlining pod formatters with `:!inline_formatters`.
- Can put same level items next to each other with `:adjacent_items`.

## sub join_pod_contents_of

```raku
sub join_pod_contents_of(
    $pod where { ... },
    $thing where { ... },
    Bool :$recurse,
    |c
) returns Str:D
```

Joins pod contents of the requested Pod with the passed string or 2 newlines.

- Can recursively find pod with `:recurse`.
- Can indent pod contents with `:indent_content`.
- Can include pod titles with `:include_title`.
- Can disable inlining pod formatters with `:!inline_formatters`.
- Can put same level items next to each other with `:adjacent_items`.

## sub get_first_pod

```raku
sub get_first_pod(
    $pod where { ... },
    $thing where { ... },
    Bool :$recurse
) returns Pod::Contents::POD
```

Finds the first Pod using the passed `pod` or `name`, does so recursively if `:recurse` is passed.

## sub get_pods

```raku
sub get_pods(
    $pod where { ... },
    $thing where { ... },
    Bool :$recurse
) returns List:D
```

Finds all Pods using the passed `pod` or `name`, does so recursively if `:recurse` is passed

## sub get_pod_contents

```raku
sub get_pod_contents(
    |
) returns Mu
```

Recursively gets the Pod contents of a Pod block as a list of (list of) strings.

- Can indent pod contents with `:indent_content`.
- Can include pod titles with `:include_title`.
- Can disable inlining pod formatters with `:!inline_formatters`.
- Can put same level items next to each other with `:adjacent_items`.

## sub check_pod

```raku
sub check_pod(
    $pod where { ... },
    $pod_type where { ... }
) returns Bool is export(:helpers)
```

Returns `True` if `pod` matches `pod_type`

## sub indent_content

```raku
sub indent_content(
    Str:D $string,
    Int:D $indent_level where { ... } = 4
) returns Str is export(:helpers)
```

Indents `string` by `indent_level`

REPOSITORY
==========

[https://github.com/CIAvash/Pod-Contents/](https://github.com/CIAvash/Pod-Contents/)

BUG
===

[https://github.com/CIAvash/Pod-Contents/issues](https://github.com/CIAvash/Pod-Contents/issues)

AUTHOR
======

Siavash Askari Nasr - [https://www.ciavash.name](https://www.ciavash.name)

COPYRIGHT
=========

Copyright © 2021 Siavash Askari Nasr

LICENSE
=======

This file is part of Pod::Contents.

Pod::Contents is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Pod::Contents is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with Pod::Contents. If not, see <http://www.gnu.org/licenses/>.


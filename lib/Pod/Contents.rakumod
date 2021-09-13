use v6.d;

=NAME Pod::Contents - a L<Raku|https://www.raku-lang.ir/en> module for getting Pod contents as a list or string.

=DESCRIPTION Pod::Contents is a L<Raku|https://www.raku-lang.ir/en> module for getting the Pod contents as a
list of strings or string.
Pod formatters can get inlined, pod contents can be indented (with custom level) and joined with a
custom string and titles can be included for table headers and defn terms.

=begin SYNOPSIS

=begin code :lang<raku>

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

=end code

=end SYNOPSIS

=begin INSTALLATION

You need to have L<Raku|https://www.raku-lang.ir/en> and L<zef|https://github.com/ugexe/zef>,
then run:

=begin code :lang<console>

zef install --/test Pod::Contents:auth<zef:CIAvash>

=end code

or if you have cloned the repo:

=begin code :lang<console>

zef install .

=end code

=end INSTALLATION

=begin TESTING

=begin code :lang<console>

prove -ve 'raku -I.' --ext rakutest

=end code

=end TESTING

unit module Pod::Contents:auth($?DISTRIBUTION.meta<auth>):ver($?DISTRIBUTION.meta<version>);

subset SomePod       where Pod::Block | Pod::Heading     | Pod::FormattingCode;
subset IndentablePod where Pod::Item  | Pod::Block::Code | Pod::Defn;
subset POD           where SomePod    | IndentablePod;
subset StrOrPod      where Str:D      | POD;
subset ArrayOfPod of List where .all ~~ POD;
subset PodOrArrayOfPod where POD | ArrayOfPod;

=SUBS

#| Returns a list of pod contents.
#| Can recursively find pod with C<:recurse>.
#| Can indent pod contents with C<:indent_content>.
#| Can include pod titles with C<:include_title>.
#| Can disable inlining pod formatters with C<:!inline_formatters>.
#| Can put same level items next to each other with C<:adjacent_items>.
sub get_pod_contents_of (PodOrArrayOfPod $pod, StrOrPod $thing, Bool :$recurse, |c --> List:D) is export {
    get_pod_contents $_, |c given get_first_pod $pod, $thing, :$recurse;
}

#| Joins pod contents of the requested Pod with the passed string or 2 newlines.
#| Can recursively find pod with C<:recurse>.
#| Can indent pod contents with C<:indent_content>.
#| Can include pod titles with C<:include_title>.
#| Can disable inlining pod formatters with C<:!inline_formatters>.
#| Can put same level items next to each other with C<:adjacent_items>.
sub join_pod_contents_of (PodOrArrayOfPod $pod, StrOrPod $thing, Bool :$recurse, |c --> Str:D) is export {
    join_pod_contents $_, |c given get_first_pod $pod, $thing, :$recurse;
}

#| Finds the first Pod using the passed C<pod> or C<name>, does so recursively if C<:recurse> is passed.
proto get_first_pod (PodOrArrayOfPod $pod, StrOrPod $thing, Bool :$recurse --> POD) is export {*}

multi get_first_pod (@pod, $pod_type, :$recurse = False --> POD) {
    if $recurse {
        @pod.map: -> POD $pod {
            if check_pod $pod, $pod_type {
                $pod;
            } elsif $pod.contents ~~ ArrayOfPod {
                $_ with samewith $pod.contents, $pod_type, :recurse;
            }
        } andthen .head;
    } else {
        @pod.first: &check_pod.assuming: *, $pod_type;
    }
}

multi get_first_pod (POD $pod, POD $pod_type, :$recurse = False --> POD) {
    samewith $pod.contents, $pod_type, :$recurse;
}

#| Finds all Pods using the passed C<pod> or C<name>, does so recursively if C<:recurse> is passed
proto get_pods (PodOrArrayOfPod $pod, StrOrPod $thing, Bool :$recurse --> List:D) is export {*}

multi get_pods (@pods, $pod_type, :$recurse = False) {
    if $recurse {
        @pods.map: -> POD $pod {
            if check_pod $pod, $pod_type {
                $pod;
            } elsif $pod.contents ~~ ArrayOfPod {
                $_ with |samewith $pod.contents, $pod_type, :recurse;
            }
        } andthen .grep(&so).List;
    } else {
        @pods.grep: &check_pod.assuming: *, $pod_type andthen .List;
    }
}

multi get_pods (POD $pod, $pod_type, :$recurse = False) {
    samewith $pod.contents, $pod_type, :$recurse;
}

#| Joins pod contents of the requested Pod type with the passed string or 2 newlines.
#| Can indent pod contents with C<:indent_content>.
#| Can include pod titles with C<:include_title>.
#| Can disable inlining pod formatters with C<:!inline_formatters>.
#| Can put same level items next to each other with C<:adjacent_items>.
sub join_pod_contents (PodOrArrayOfPod $pod, $with = "\n\n", |c --> Str:D) is export {
    if get_pod_contents $pod, |c -> @contents {
        join $with, do given @contents {
            if $_ ~~ List:D && .elems > 1 && .all ~~ List:D { .join: "\n" }
            else {
                .map: {
                    when List:D { .join: "\n" }
                    default     { $_ }
                };
            }
        }
    } else {
        '';
    }
}

#| Recursively gets the Pod contents of a Pod block as a list of (list of) strings.
#| Can indent pod contents with C<:indent_content>.
#| Can include pod titles with C<:include_title>.
#| Can disable inlining pod formatters with C<:!inline_formatters>.
#| Can put same level items next to each other with C<:adjacent_items>.
proto get_pod_contents (|) is export {*};

multi get_pod_contents (IndentablePod:D $pod,
                        |c (Bool:D :$indent_content       = False,
                            UInt:D :$indent_level is copy = 4,
                            Bool:D :$include_title        = False,
                            |)
                        --> List:D) {
    my @contents = samewith $pod.contents, |c;

    if $indent_content {
        $indent_level ×= .level - 1 when Pod::Item given $pod;

        @contents.=map: *.join("\n").&indent_content: $indent_level;
    }

    if $include_title && $pod ~~ Pod::Defn {
        @contents.unshift: (samewith($pod.term, |c), @contents.shift);
    }

    @contents.List;
}

multi get_pod_contents (SomePod:D $pod, |c (Bool:D :$include_title = False, |) --> List:D) {
    given $pod {
        when Pod::Block::Table:D {
            my List:D $contents       = .contents;
            my List:D $table_contents = $include_title ?? (.headers || Empty, |$contents) !! $contents;

            $table_contents.map({ .map({ samewith $_, |c }).List }).List;
        }
        default {
            samewith .contents, |c;
        }
    }
}

multi get_pod_contents (@pod_contents,
                        |c (Bool:D :$inline_formatters = True, Bool:D :$adjacent_items = False, |)
                        --> List:D) {
    my @contents;

    loop (my $i = 0; $i < @pod_contents; $i++) {
        if $inline_formatters and @pod_contents[$i] ~~ Pod::FormattingCode:D {
            # First observation of pod formatter
            # If the pod content before first pod formatter is a string, consider it the first index,
            # otherwise first index is the pod formatter
            my UInt:D $first_index = $i > 0 && @contents[$i - 1] ~~ Str:D ?? $i - 1 !! $i;

            while @pod_contents[$i] ~~ Pod::FormattingCode:D | Str:D {
                my Str:D $string = samewith(@pod_contents[$i], |c).join;

                # Append string to the first content
                @contents[$first_index] ~= $string;

                $i++;
            }
        } elsif $adjacent_items and @pod_contents[$i] ~~ Pod::Item:D {
            my @item_contents;

            while @pod_contents[$i] ~~ Pod::Item:D {
                @item_contents.append: samewith @pod_contents[$i], |c;

                $i++;
            }

            @contents.push: @item_contents.List;
        } else {
            given @pod_contents[$i] {
                when List:D | Pod::Block::Table:D {
                    @contents.push: samewith($_, |c).List;
                }
                default {
                    @contents.append: samewith($_, |c);
                }
            }
        }
    }

    @contents.List;
}

multi get_pod_contents (Str:D $content, | --> Str:D) {
    $content;
}

#| Returns C<True> if C<pod> matches C<pod_type>
sub check_pod (POD $pod, StrOrPod $pod_type --> Bool:D) is export(:helpers) {
    $pod | $pod.?name ~~ $pod_type;
}

#| Indents C<string> by C<indent_level>
sub indent_content (Str:D $string, UInt:D $indent_level = 4 --> Str:D) is export(:helpers) {
    $string.lines.map(' ' x $indent_level ~ *).join: "\n";
}

=REPOSITORY L<https://github.com/CIAvash/Pod-Contents/>

=BUG L<https://github.com/CIAvash/Pod-Contents/issues>

=AUTHOR Siavash Askari Nasr - L<https://www.ciavash.name>

=COPYRIGHT Copyright © 2021 Siavash Askari Nasr

=begin LICENSE
This file is part of Pod::Contents.

Pod::Contents is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Pod::Contents is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with Pod::Contents.  If not, see <http://www.gnu.org/licenses/>.
=end LICENSE

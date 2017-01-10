%requirement: Wordnet must be loaded into Graph called Wordnet.nt!!!
%Do this by loading it through HTTP:
%http://wordnet-rdf.princeton.edu/wn31.nt.gz
%Run "run_mapping" (main_consec and main_vsnow and infer) to get all the triples.

%To find the nr of LEs:
%aggregate_all(count, (distinct([LexicalEntry], ( rdf(LexicalEntry, example:'semanticChange',_)))), Count).

:- module(wordnet_mapping, [run_mapping/0]).

:- use_module(library(apply)).
:- use_module(library(http/json)).
:- use_module(library(snowball)).
:- use_module(library(semweb/rdf_turtle_write)).
:- use_module(library(semweb/rdf_ntriples)).
:- use_module(library(semweb/rdf_zlib_plugin)).
:- use_module(library(semweb/rdf_http_plugin)).
:- use_module(library(http/http_ssl_plugin)).
:- use_module(library(semweb/rdf_db)).


%:- include(date).
:- rdf_register_prefix('cwi', 'http://project.ia.cwi.nl/semanticChange/').
:- rdf_register_prefix('lemon', 'http://lemon-model.net/lemon#').
:- rdf_register_prefix('time', 'http://www.w3.org/2006/time#').
%:- rdf_register_prefix('xsd', 'http://www.w3.org/2001/XMLSchema').

change_graph(paper1).

run_mapping:-
    %rdf_load('http://wordnet-rdf.princeton.edu/wn31.nt.gz', [graph('Wordnet.nt')]),
    rdf_load('wn31.nt.gz', [graph('Wordnet.nt')]),
    main_consec,
    main_vsnow,
    infer,
    rdf_save_turtle('Driftalod.ttl', [graph(paper1), user_prefixes(true)]).

main_consec:- %BEFORE RUNNING, SET THE DATE FUNCTION TO YEAR + 10!
    %b_setval(Unmatchedset, []),
    open_read_close_json("consec-words", Keys),
    open_read_close_json("consec-years", Years),
    open_read_close_json("consec-values", Values),
    b_setval(offset_formula, 'not appliccable'),
    maplist(iterate_over_keys, Keys, Years, Values).

main_vsnow:-  %BEFORE RUNNING, CHANGE THE DATE FUNCTION! SET OFFSET TO 1990
    open_read_close_json("vsnow-words", Keys),
    open_read_close_json("vsnow-years", Years),
    open_read_close_json("vsnow-values", Values),
    b_setval(offset_formula, '1990'),
    maplist(iterate_over_keys, Keys, Years, Values).

subprop(S):-
    change_graph(G),
    rdf_assert(S, rdfs:subPropertyOf, cwi:'semantic_change', G).

define_subprops:-
     subprop('semantic_change_1810s-1820s'),
subprop('semantic_change_1810s-1990s'),
subprop('semantic_change_1820s-1830s'),
subprop('semantic_change_1820s-1990s'),
subprop('semantic_change_1830s-1840s'),
subprop('semantic_change_1830s-1990s'),
subprop('semantic_change_1840s-1850s'),
subprop('semantic_change_1840s-1990s'),
subprop('semantic_change_1850s-1860s'),
subprop('semantic_change_1850s-1990s'),
subprop('semantic_change_1860s-1870s'),
subprop('semantic_change_1860s-1990s'),
subprop('semantic_change_1870s-1880s'),
subprop('semantic_change_1870s-1990s'),
subprop('semantic_change_1880s-1890s'),
subprop('semantic_change_1880s-1990s'),
subprop('semantic_change_1890s-1900s'),
subprop('semantic_change_1890s-1990s'),
subprop('semantic_change_1900s-1910s'),
subprop('semantic_change_1900s-1990s'),
subprop('semantic_change_1910s-1920s'),
subprop('semantic_change_1910s-1990s'),
subprop('semantic_change_1920s-1930s'),
subprop('semantic_change_1920s-1990s'),
subprop('semantic_change_1930s-1940s'),
subprop('semantic_change_1930s-1990s'),
subprop('semantic_change_1940s-1950s'),
subprop('semantic_change_1940s-1990s'),
subprop('semantic_change_1950s-1960s'),
subprop('semantic_change_1950s-1990s'),
subprop('semantic_change_1960s-1970s'),
subprop('semantic_change_1960s-1990s'),
subprop('semantic_change_1970s-1980s'),
subprop('semantic_change_1970s-1990s'),
subprop('semantic_change_1980s-1990s'),
subprop('semantic_change_1990s-1990s'),
subprop('semantic_change_1990s-2000s').


infer:-
       define_subprops,
       forall(semanticChange_OnsetStart_OffsetStart(LexicalEntry, Value, Onsetstart, Offsetstart),
       define_semanticchange_decade_property(LexicalEntry, Value, Onsetstart, Offsetstart)).

define_semanticchange_decade_property(LexicalEntry, Value, Onsetstart, Offsetstart):-
    change_graph(G),
    onsetdate_offsetdate_to_years(Onsetstart, Offsetstart,  OnsetY,  OffsetY),
    year_decade(OnsetY, OnsetDecade),
    year_decade(OffsetY, OffsetDecade),
    predicate(OnsetDecade, OffsetDecade, Predicate),
    rdf_assert(LexicalEntry, Predicate, Value, G).


predicate(OnsetDecade, OffsetDecade, Predicate):-
    string_concat(OnsetDecade, '-', Part1),
    string_concat(Part1, OffsetDecade, Period),
    atom_concat('semantic_change_', Period, Predicatename),
    atom_concat('http://project.ia.cwi.nl/semanticChange/', Predicatename,  Predicate).

rdf_date(literal(type(_, String)), Y-M-D) :-
    date_string(Y-M-D, String).

date_string(Y-M-D, String) :-
    format(atom(String), '~|~`0t~d~4+-~`0t~d~3+-~`0t~d~3+', [Y,M,D]).

year(Stamp, Year):-
    stamp_date_time(Stamp, DateTime, local),
    date_time_value(year, DateTime, Year).

semanticChange_OnsetStart_OffsetStart(LexicalEntry, Value, Onsetstart, Offsetstart):-
        rdf(LexicalEntry, cwi:'semantic_change', BNode_semChange, G),
        rdf(BNode_semChange, rdfs:value, Value, G),
        rdf(BNode_semChange, rdf:type, cwi:'SemanticChange', G), %todo
        rdf(BNode_semChange, cwi:'onset_reference', BNode_onsetInterval, G),
        rdf(BNode_semChange, cwi:'offset_reference', BNode_offsetInterval, G),
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        rdf(BNode_onsetInterval, time:'hasBeginning',BNode_onsetStarttime, G),
        %rdf(BNode_onsetInterval, time:'hasEnd', BNode_onsetEndtime, G),
        rdf(BNode_offsetInterval, time:'hasBeginning',BNode_offsetStarttime, G),
        %rdf(BNode_offsetInterval, time:'hasEnd', BNode_offsetEndtime, G),
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        rdf(BNode_onsetStarttime, time:'inXSDDateTime',literal(type('http://www.w3.org/2001/XMLSchema#date', Onsetstart)), G),
        rdf(BNode_offsetStarttime, time:'inXSDDateTime', literal(type('http://www.w3.org/2001/XMLSchema#date', Offsetstart)), G).

onsetdate_offsetdate_to_years(Onsetstart, Offsetstart,  OnsetYear,  OffsetYear):-
    parse_time(Onsetstart, Onsetstamp),
    parse_time(Offsetstart, Offsetstamp),
    year(Onsetstamp, OnsetYear),
    year(Offsetstamp, OffsetYear).

year_decade(Year, Decade):-
    string_concat(Year, 's', Decade).




open_read_close_json(Filename, Content):-
    open(Filename,read, Filestream),
    json_read(Filestream, Content),
	close(Filestream).


iterate_over_keys(Key, Yearlist, Valuelist):-
    maplist(iterate_over_years_and_values(Key), Yearlist, Valuelist).

iterate_over_years_and_values(Key, Year, Value):-
    (   number(Value) ->   continue(Key, Year, Value); true).

round(ValueIn, ValueOut):-
    Value is ValueIn,
    Value0 is Value*1000,
    Value1 is floor(Value0),
    ValueOut is Value1/1000.

continue(Key, Year, Value):-
    round(Value, ValueRounded),
    simvalue_to_distvalue(ValueRounded, SemDistValue),
    (   is_canonical_term(Key) ->   process(Key, Year, SemDistValue); stem_and_process(Key, Year, SemDistValue)).


simvalue_to_distvalue(Value, SemDistValue):-
    SemDistValue is acos(Value).

year_to_dateliterals(Year, OnsetStart, OnsetEnd, OffsetStart, OffsetEnd):-
    OnsetStartYear is Year,
    OnsetEndYear is Year + 9,
    (   b_getval(offset_formula, '1990') -> OffsetStartYear is 1990; OffsetStartYear is Year + 10), %change to 1990 for vsnow, Year + 10 for consec!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    OffsetEndYear is OffsetStartYear + 9,
    rdf_date(OnsetStartYear-01-01, OnsetStart),
    rdf_date(OnsetEndYear-12-31, OnsetEnd),
    rdf_date(OffsetStartYear-01-01, OffsetStart),
    rdf_date(OffsetEndYear-12-31, OffsetEnd).

stem_and_process(Key, Year, Value):- %for terms that need to be stemmed
    snowball(english, Key, StemmedKey),
   % (   is_wn_term(StemmedKey) -> create_lexicalentry_and_process(Key, StemmedKey, Year, Value); true).
    (   is_wn_canonical_term(StemmedKey) -> create_lexicalentry_and_process(Key, StemmedKey, Year, Value); true).

                                                   %, b_getval(Unmatchedset, Wordlist),  add_nb_set(Key, Wordlist), b_setval(Unmatchedset, Wordlist))).



create_lexicalentry_and_process(Key, StemmedKey, Year, Value):-
    create_lexicalEntry_and_form(Key, NewLexicalEntryBNode),
    key_form(StemmedKey, StemmedForm),
    form_lexicalEntry(StemmedForm, StemmedLexicalEntry),
    define_as_lexicalvariants(NewLexicalEntryBNode, StemmedLexicalEntry),
    define_semantic_change(NewLexicalEntryBNode, Year, Value).


create_lexicalEntry_and_form(Key, BNode_le):-
	change_graph(G),
        rdf_bnode(BNode_le),
        rdf_assert(BNode_le, rdf:type, 'http://lemon-model.net/lemon#LexicalEntry', G),
        %rdf_assert(BNode_le,  'http://lemon-model.net/lemon#lexicalForm', literal(lang(english, Key))),
        rdf_bnode(BNode_form),
	rdf_assert(BNode_le, 'http://lemon-model.net/lemon#canonicalForm', BNode_form, G),
        rdf_assert(BNode_form, 'http://lemon-model.net/lemon#writtenRep',literal(lang(english, Key)), G).


process(Key, Year, Value):- %for terms that are Wordnet canonicalForms
    forall(
        key_lexicalEntry(Key, LexicalEntry),
	define_semantic_change(LexicalEntry, Year, Value)
        ).

define_semantic_change(LexicalEntry, Year, Value) :-
    change_graph(G),
    year_to_dateliterals(Year, OnsetStart, OnsetEnd, OffsetStart, OffsetEnd),
    rdf_bnode(BNode_semChange),
    rdf_bnode(BNode_onsetInterval),
    rdf_bnode(BNode_offsetInterval),
    rdf_bnode(BNode_onsetStarttime),
    rdf_bnode(BNode_onsetEndtime),
    rdf_bnode(BNode_offsetStarttime),
    rdf_bnode(BNode_offsetEndtime),
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	rdf_assert(LexicalEntry, cwi:'semantic_change', BNode_semChange, G),
    rdf_assert(BNode_semChange, rdf:type, cwi:'SemanticChange', G), %todo
	rdf_assert(BNode_semChange, rdfs:value, literal(type(xsd:float, Value)), G),
	rdf_assert(BNode_semChange, cwi:'onset_reference', BNode_onsetInterval, G),
	rdf_assert(BNode_semChange, cwi:'offset_reference', BNode_offsetInterval, G),
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    rdf_assert(BNode_onsetInterval, time:'hasBeginning',BNode_onsetStarttime, G),
	rdf_assert(BNode_onsetInterval, time:'hasEnd', BNode_onsetEndtime, G),
    rdf_assert(BNode_offsetInterval, time:'hasBeginning',BNode_offsetStarttime, G),
	rdf_assert(BNode_offsetInterval, time:'hasEnd', BNode_offsetEndtime, G),
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	rdf_assert(BNode_onsetStarttime, time:'inXSDDateTime', OnsetStart, G),
	rdf_assert(BNode_offsetStarttime, time:'inXSDDateTime', OffsetStart, G),
	rdf_assert(BNode_onsetEndtime, time:'inXSDDateTime', OnsetEnd, G),
	rdf_assert(BNode_offsetEndtime, time:'inXSDDateTime', OffsetEnd, G).


define_as_lexicalvariants(LexicalEntry1,LexicalEntry2):-
    change_graph(G),
    rdf_assert(LexicalEntry1, 'http://lemon-model.net/lemon#lexicalVariant', LexicalEntry2, G).

is_wn_term(Key):-
	rdf(_, 'http://lemon-model.net/lemon#writtenRep', literal(lang(_, Key)), 'Wordnet.nt').

is_wn_canonical_term(Key):-
	rdf(CForm, 'http://lemon-model.net/lemon#writtenRep', literal(lang(_, Key)), 'Wordnet.nt'),
    rdf(_, 'http://lemon-model.net/lemon#canonicalForm', CForm, 'Wordnet.nt').

is_canonical_term(Key):-
	rdf(CForm, 'http://lemon-model.net/lemon#writtenRep', literal(lang(_, Key))),
    rdf(_, 'http://lemon-model.net/lemon#canonicalForm', CForm).

key_form(Key, Form):-
    %rdf(LexicalEntry, 'http://lemon-model.net/lemon#canonicalForm', Form),
    rdf(Form, 'http://lemon-model.net/lemon#writtenRep', literal(lang(_, Key))).  %, 'Wordnet.nt').

key_wn_form(Key, Form):-
    %rdf(LexicalEntry, 'http://lemon-model.net/lemon#canonicalForm', Form),
    rdf(Form, 'http://lemon-model.net/lemon#writtenRep', literal(lang(_, Key)), 'Wordnet.nt').

form_lexicalEntry(Form, LexicalEntry):-
    rdf(LexicalEntry, 'http://lemon-model.net/lemon#canonicalForm', Form). %, 'Wordnet.nt');
    %rdf(LexicalEntry, 'http://lemon-model.net/lemon#otherForm', Form). %, 'Wordnet.nt'). %added
    %

form_wn_lexicalEntry(Form, LexicalEntry):-
    rdf(LexicalEntry, 'http://lemon-model.net/lemon#canonicalForm', Form, 'Wordnet.nt').
    %rdf(LexicalEntry, 'http://lemon-model.net/lemon#otherForm', Form). %, 'Wordnet.nt'). %added

key_lexicalEntry(Key, LexicalEntry):-
    key_form(Key, Form),
    form_lexicalEntry(Form, LexicalEntry).

key_wn_lexicalEntry(Key, LexicalEntry):-
    key_wn_form(Key, Form),
    form_wn_lexicalEntry(Form, LexicalEntry).

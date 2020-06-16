:- use_module(library(http/http_server)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_files)).

:- initialization
    http_server([port(4080)]).

%:- http_handler(root(.),
                %http_redirect(moved, location_by_id(pwd)),
%                []).

:- http_handler(root(.), http_reply_from_files('.', []), [prefix]).       
%:- http_handler(root(home), home_page, []).


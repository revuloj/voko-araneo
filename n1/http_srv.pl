:- use_module(library(http/http_server)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_files)).
:- use_module(library(http/http_open)).

:- initialization
    http_server([port(4080)]).

revo_url('http://retavortaro.de').

%:- http_handler(root(.),
                %http_redirect(moved, location_by_id(pwd)),
%                []).

:- http_handler(root(.), http_reply_from_files('.', []), [prefix]).       
:- http_handler(root(revo), revo_proxy, [prefix,priority(100)]).
%:- http_handler(root(home), home_page, []).

% elŝutas artikolon el retavortaro.de kaj sendas al la krozilo
revo_proxy(Request) :-   
    %debug(proxy(request),'~q',[Request]),
    % get art parameter
    revo_url(Revo),
    % antaŭŝargu DTD
    %%  vokodtd(vortaro,VokoDTD),
    % elŝutu XML
    member(request_uri(URI),Request),
    atomic_list_concat([Revo,URI],RevoUrl),
    debug(proxy(url),'~q',[RevoUrl]),

    http_open(RevoUrl,HTTPStream,[status_code(Status)]),!,

    % legu artikolon
    (Status = 200
     ->
        set_stream(HTTPStream,encoding(utf8)),
        set_stream(current_output,encoding(utf8)),
        format('Content-type: text/html; charset=UTF-8~n~n'),
        %copy_stream_data(XmlStream,current_output),
        copy_stream_data(HTTPStream,current_output),
        close(HTTPStream)
      ;
        format('Status: ~d~n~n',[Status])
     ).


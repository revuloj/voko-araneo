:- use_module(library(http/http_server)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_server_files)).
:- use_module(library(http/http_files)).
:- use_module(library(http/http_path)).
:- use_module(library(http/http_open)).

:- initialization
    http_server([port(4080)]).

revo_url('http://retavortaro.de').

%:- multifile http:location/3.
%:- dynamic   http:location/3.

user:file_search_path(stl,'./stl').
user:file_search_path(jsc,'./jsc').
user:file_search_path(red,'./red').
%http:location(stl,root(stl),[]).

:- http_handler('/', http_reply_from_files('.', []), [id(root)]).       
:- http_handler('/index.html', http_reply_file('./index.html', []), [id(index)]).       
%:- http_handler('/redaktilo.html', http_reply_file('./redaktilo.html', []), [id(redaktilo), priority(200)]).       
:- http_handler(root(red), serve_files_in_directory(red), [prefix, id(red), priority(100)]).       
:- http_handler(root(stl), serve_files_in_directory(stl), [prefix, id(stl), priority(100)]).       
:- http_handler(root(jsc), serve_files_in_directory(jsc), [prefix, id(jsc), priority(100)]).       
:- http_handler(root(revo), revo_proxy, [prefix, id(revo), priority(100)]).
:- http_handler(root(.), revo_proxy, [prefix, id(revo), priority(0)]).

%:- http_handler(root(home), home_page, []).

% elŝutas artikolon el retavortaro.de kaj sendas al la krozilo
revo_proxy(Request) :-   
    %debug(proxy(request),'~q',[Request]),
    % get art parameter
    % antaŭŝargu DTD
    %%  vokodtd(vortaro,VokoDTD),
    % elŝutu XML
    member(request_uri(URI),Request),
    debug(proxy(uri),'URI: ~q =>',[URI]),
    proxy_path(URI,RevoUrl),
    debug(proxy(url),'URL: => ~q',[RevoUrl]),

    member(accept_language(AL),Request),

    http_open(RevoUrl,HTTPStream,[status_code(Status),
      header(content_type,CType),
      request_header(accept_language=AL)]),!,

    % legu artikolon
    (Status = 200
     ->
        format('Content-type: ~w~n~n',[CType]),
        debug(proxy(header),'ctype: ~q',[CType]),
        (
          sub_atom(CType,_,_,_,html) -> 
          set_stream(HTTPStream,encoding(utf8)),
          set_stream(current_output,encoding(utf8))
          ;
          true
        ),
        %copy_stream_data(XmlStream,current_output),
        copy_stream_data(HTTPStream,current_output),
        close(HTTPStream)
      ;
        format('Status: ~d~n~n',[Status])
     ).

proxy_path(URI,RevoUrl) :-
  revo_url(Revo),
  once((
      atomic_list_concat(['..'|RelPath],'/',URI),
      atomic_list_concat([Revo,revo|RelPath],'/',RevoUrl)
      ;
      % korektu poste: la komencaj '..' ial glutiĝas en URI...
      atomic_list_concat(['',smb|_],'/',URI),
      atomic_list_concat([Revo,'/revo',URI],RevoUrl)
      ;
      atomic_list_concat(['','cgi-bin'|_],'/',URI),
      atomic_list_concat([Revo,URI],RevoUrl)
      ;
      atomic_list_concat(['',revo|_],'/',URI),
      atomic_list_concat([Revo,URI],RevoUrl)
      ;
      atomic_list_concat([Revo,revo,inx,URI],'/',RevoUrl)
    )).


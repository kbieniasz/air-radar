%%%-------------------------------------------------------------------
%%% @author kbieniasz
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. maj 2019 11:53
%%%-------------------------------------------------------------------
-module(pollution_server_sup).
-author("kbieniasz").

%% API
-export([start_pollution_server/0]).

start_pollution_server() ->
  process_flag(trap_exit, true),
  spawn_link(pollution_server, start,[]),
  receive
    {, PID, Reason} -> io:format("Przerwanie ~w ~w ~n",[Reason, PID ])
  end

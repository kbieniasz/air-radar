%%%-------------------------------------------------------------------
%%% @author kbieniasz
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. kwi 2019 14:24
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("kbieniasz").



%% API
-export([start/0, stop/0, get_response/0, flush_function/0,
  addStation/2, addValue/4, removeValue/3, getOneValue/3, getStationMean/2, getDailyMean/2, getMinumumPollutionStation/1, crash/0]).
-compile(export_all).

init () ->
  StartingMonitor = pollution:createMonitor(),
  io:format("Inicjalizacja serwera\n"),
  loop(StartingMonitor).

start() ->
  Pid = spawn(fun() -> init() end),
  register(server,Pid),
  io:format("Start serwara z numerem PID: ~w \n", [Pid]).

stop() ->
  server ! stop .

crash() ->
  server ! crash.


get_response() ->
  receive
    {ok,ReturnValue} -> ReturnValue;
    _ -> io:format("Wystąpił błąd\n"),
      -1
  after 100 -> -2
  end.

flush_function() ->
  receive
    _ -> flush_function()
  after 0 -> ok
  end.

addStation(Name, Coordinates) -> server ! {self(), addStation, Name, Coordinates}.
addValue ( ID, Date, Type, Value) -> server ! {self(), addValue,  ID, Date, Type, Value}.
removeValue( ID,Date, Type) -> server ! {self(), removeValue,  ID,Date, Type}.
getOneValue (ID, Date, Type) -> server ! {self(),  getOneValue, ID, Date, Type}.
getStationMean(ID, Type)  -> server ! {self(), getStationMean, ID, Type}.
getDailyMean (Type, DayDate) -> server ! {self(), getDailyMean, Type, DayDate}.
getMinumumPollutionStation (Type) -> server ! {self(), getMinumumPollutionStation, Type}.

loop(Monitor) ->
  receive
    {Pid, addStation, Name, Coordinates} ->
      NewMonitor = pollution:addStation(Monitor, Name, Coordinates),
      Pid ! {ok, NewMonitor},
      loop(NewMonitor);

    {Pid, addValue, ID, Date, Type, Value} ->
      NewMonitor = pollution:addValue(Monitor,ID, Date, Type, Value),
      Pid ! {ok, NewMonitor},
      loop(NewMonitor);

    {Pid, removeValue,  ID,Date, Type} ->
      NewMonitor = pollution:removeValue(Monitor, ID,Date, Type),
      Pid ! {ok, NewMonitor},
      loop(NewMonitor);

    {Pid, getOneValue, ID, Date, Type} ->
      Pid ! {ok, pollution:getOneValue(Monitor, ID, Date, Type)},
      loop(Monitor);

    {Pid, getStationMean, ID, Type} ->
      Pid ! {ok,pollution: getStationMean(Monitor,ID,Type)},
      loop(Monitor);

    {Pid, getDailyMean, Type, DayDate} ->
      Pid ! {ok, pollution:getDailyMean(Monitor,Type,DayDate)},
      loop(Monitor);

    {Pid, getMinumumPollutionStation, Type} ->
      Pid ! {ok,pollution: getMinumumPollutionStation(Monitor,Type)},
      loop(Monitor);

    stop ->
      io:format("Zatrzymanie serwera ~n"), ok;

    crash ->
      io:format("Blad arytmetyczny ~n"),
      1/0;

    _ ->
      io:format("Nieznany rodzaj komunikatu\n"), loop(Monitor)
  end.
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


-import(pollution,
  [createMonitor/0,
  addStation/3,
  addValue/5,
  addValueByName/5,
  test/0,
  removeValue/4,
  removeValueByName/4,
  getOneValue/4,
  getOneValueByName/4,
  getStationMean/3,
  getStationMeanByName/3,
  getDailyMean/3,
  getStationMeanByNameWithDate/4,
  getMinumumPollutionStation/2,
  getStationMinimumType/3, complexTest/0, dailyMeanTest/1, testMyFuntion/1, stationMeanTest/1, stationMeanTestFail/1
]).

%% API
-export([start/0, stop/0, get_response/0, flush_function/0]).

init () ->
  StartingMonitor = createMonitor(),
  io:format("Inicjalizacja serwera\n"),
  loop(StartingMonitor).

start() ->
  Pid = spawn(fun() -> init() end),
  register(server,Pid),
  io:format("Start serwara z numerem PID: ~w \n", [Pid]).

stop() ->
  global:send(server,stop).


get_response() ->
  receive
    {ok,ReturnValue} -> ReturnValue;
    _ -> io:format("Wystąpił błąd\n"),
      -1
  after 100 -> -1
  end.

flush_function() ->
  receive
    _ -> flush_function()
  after 0 -> ok
  end.

loop(Monitor) ->
  receive
    {Pid, addStation, Name, Coordinates} ->
      NewMonitor = addStation(Monitor, Name, Coordinates),
      Pid ! {ok, NewMonitor},
      loop(NewMonitor);

    {Pid, addValue, ID, Date, Type, Value} ->
      NewMonitor = addValue(Monitor,ID, Date, Type, Value),
      Pid ! {ok, NewMonitor},
      loop(NewMonitor);

    {Pid, removeValue,  ID,Date, Type} ->
      NewMonitor = removeValue(Monitor, ID,Date, Type),
      Pid ! {ok, NewMonitor},
      loop(NewMonitor);

    {Pid, getValue, ID, Date, Type} ->
      Pid ! {ok, getOneValue(Monitor, ID, Date, Type)},
      loop(Monitor);

    {Pid, getStationMean, ID, Type} ->
      Pid ! {ok, getStationMean(Monitor,ID,Type)},
      loop(Monitor);

    {Pid, getDailyMean, Type, DayDate} ->
      Pid ! {ok, getDailyMean(Monitor,Type,DayDate)},
      loop(Monitor);

    {Pid, getMinumumPollutionStation, Monitor, Type} ->
      Pid ! {ok, getMinumumPollutionStation(Monitor,Type)},
      loop(Monitor);

    stop ->
      io:format("Zatrzymanie serwera"), ok;

    _ ->
      io:format("Nieznany rodzaj komunikatu\n"), loop(Monitor)
  end.
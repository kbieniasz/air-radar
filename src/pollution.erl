%%%-------------------------------------------------------------------
%%% @author kbieniasz
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. kwi 2019 14:06
%%%-------------------------------------------------------------------
-module(pollution).
-author("kbieniasz").

%% API
-export([
  createMonitor/0,
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
  getStationMinimumType/3, complexTest/0, dailyMeanTest/1, testMyFuntion/1, stationMeanTest/1, stationMeanTestFail/1]).

-record(monitor,{map_geo_to_name,stations}).
-record (station, {name, geo_coordinates, measurements = []}).
-record (measurement, {type, value, date }).

%% na podstawie map_geo_to_name znajdziemy zawsze nazwę, szukamy po nazwach
createMonitor() -> #monitor{map_geo_to_name = maps:new(),stations = maps:new()}.

addStation(Monitor, Name, Coordinates) ->
  case maps:is_key(Coordinates,Monitor#monitor.map_geo_to_name) or
    maps:is_key(Name,Monitor#monitor.stations) of
    true -> io:format("Nie mozna dodac stacji, gdyz juz istnieje, zwracam niezaktualizowany monitor\n"),
      Monitor;
    false -> New_map_geo = maps:put(Coordinates, Name, Monitor#monitor.map_geo_to_name),
      New_station = #station{name = Name, geo_coordinates = Coordinates, measurements = []},
      New_stations = maps:put(Name,New_station, Monitor#monitor.stations),
      New_monitor = #monitor{map_geo_to_name = New_map_geo, stations = New_stations},
      New_monitor
  end.

addValue(Monitor,ID, Date, Type, Value) ->
  case is_tuple(ID) of
    false ->  case maps:is_key(ID,Monitor#monitor.stations) of
                true -> addValueByName(Monitor,ID, Date,Type,Value);
                false -> io:format("Nie mozna dodac wartosci, gdyz stacja nie istnieje, zwracam niezaktualizowany monitor\n"),
                  Monitor end;
    true ->
      case maps:is_key(ID,Monitor#monitor.map_geo_to_name) of
        true -> {_,Name} = maps:find(ID,Monitor#monitor.map_geo_to_name),
          addValueByName(Monitor,Name, Date,Type,Value);
        false -> io:format("Nie mozna dodac wartosci, gdyz stacja nie istnieje, zwracam niezaktualizowany monitor\n"),
          Monitor
      end
  end.

addValueByName(Monitor,Name, Date, Type, Value) ->
  Measurement = #measurement{type = Type, value = Value, date = Date},
  {_,Find_station} = maps:find(Name,Monitor#monitor.stations),
  Old_measurements = Find_station#station.measurements,
  case (lists:any(fun(Me) -> (Me#measurement.date == Date andalso Me#measurement.type == Type) end, Old_measurements)) of
    false ->
      New_measurements = Old_measurements ++ [Measurement],
      Actualized_station = Find_station#station{measurements = New_measurements},
      New_stations = maps:put(Name,Actualized_station,Monitor#monitor.stations),
      New_monitor = Monitor#monitor{stations = New_stations},
      New_monitor;
    true ->
      io:format("Nie mozna dodac pomiaru, gdyz juz istnieje, zwracam niezaktualizowany monitor\n"),
      Monitor
  end.




%%% najprostszy, bardziej kompletne sa dalej
test() ->

  M =pollution:createMonitor(),
  M1 = pollution:addStation(M,"Mickiewicza",{3,3}),
  M2 = pollution:addValue(M1,"Mickiewicza",{2019},"PM5",75.5),
  M3 = pollution:addValue(M2,{3,3},{2018},"PM5",100),
  M3.


removeValue(Monitor, ID,Date, Type) ->
  case is_tuple(ID) of
    false ->  case maps:is_key(ID,Monitor#monitor.stations) of
                true -> removeValueByName(Monitor,ID, Date,Type);
                false -> io:format("Nie mozna usunac wartosci, gdyz stacja nie istnieje, zwracam niezaktualizowany monitor\n"),
                  Monitor end;
    true ->
      case maps:is_key(ID,Monitor#monitor.map_geo_to_name) of
        true -> {_,Name} = maps:find(ID,Monitor#monitor.map_geo_to_name),
          removeValueByName(Monitor,Name, Date,Type);
        false -> io:format("Nie mozna usunac wartosci, gdyz stacja nie istnieje, zwracam niezaktualizowany monitor\n"),
          Monitor
      end
  end.

removeValueByName(Monitor, Name, Date, Type) ->
  {_,Find_station} = maps:find(Name,Monitor#monitor.stations),
  Old_measurements = Find_station#station.measurements,
  FilterFun = fun (Me) ->
    (not(Me#measurement.date == Date andalso Me#measurement.type == Type)) end,
  Actualised_measurements = lists:filter(FilterFun,Old_measurements),
  Actualized_station = Find_station#station{measurements = Actualised_measurements},
  New_stations = maps:put(Name,Actualized_station,Monitor#monitor.stations),
  New_monitor = Monitor#monitor{stations = New_stations},
  New_monitor.


%%getOneValue/4 - zwraca wartość pomiaru o zadanym typie, z zadanej daty i stacji;
getOneValue(Monitor, ID, Date, Type) ->
  case is_tuple(ID) of
    false ->  case maps:is_key(ID,Monitor#monitor.stations) of
                true -> getOneValueByName(Monitor,ID, Date,Type);
                false -> io:format("Podana stacja nie istnieje\n"),
                  -1 end;
    true ->
      case maps:is_key(ID,Monitor#monitor.map_geo_to_name) of
        true -> {_,Name} = maps:find(ID,Monitor#monitor.map_geo_to_name),
          getOneValueByName(Monitor,Name, Date,Type);
        false -> io:format("Podana stacja nie istnieje\n"),
          -1
      end
  end.


getOneValueByName(Monitor, Name, Date, Type) ->
  {_,Station} = maps:find(Name,Monitor#monitor.stations),
  FilterFun = fun (Me) ->
    (Me#measurement.date == Date andalso Me#measurement.type == Type) end,
  Direct_measurement = lists:filter(FilterFun,Station#station.measurements),
  case length(Direct_measurement) of
    0 -> 0;
    _ -> Direct_measurement#measurement.value
  end.

%%getStationMean/3 - zwraca średnią wartość parametru danego typu z zadanej stacji;

getStationMean(Monitor,ID,Type) ->
  case is_tuple(ID) of
    false ->  case maps:is_key(ID,Monitor#monitor.stations) of
                true -> getStationMeanByName(Monitor,ID,Type);
                false -> io:format("Podana stacja nie istnieje\n"),
                  -1 end;
    true ->
      case maps:is_key(ID,Monitor#monitor.map_geo_to_name) of
        true -> {_,Name} = maps:find(ID,Monitor#monitor.map_geo_to_name),
          getStationMeanByName(Monitor,Name,Type);
        false -> io:format("Podana stacja nie istnieje\n"),
          -1
      end
  end.

getStationMeanByName(Monitor,Name, Type) ->
  {_,Station} = maps:find(Name,Monitor#monitor.stations),
  FilterFun = fun (Me) ->
    (Me#measurement.type == Type) end,
  Direct_measurements = lists:filter(FilterFun,Station#station.measurements),
  Number_of_measurements = length(Direct_measurements),
  %%FoldlFun = fun(M,Sum) -> M#measurement.value + Sum end,
  case Number_of_measurements of
    0 -> brak_danych;
    _ -> (lists:foldl(fun(X, Sum) -> X#measurement.value + Sum end,0,Direct_measurements))/Number_of_measurements
  end.


getStationMeanByNameWithDate(Monitor,Name, Type,DayDate) ->
  {_,Station} = maps:find(Name,Monitor#monitor.stations),
  DayFun = fun({LeftDate,_}, OtherDayDate ) -> LeftDate == OtherDayDate end,
  FilterFun = fun (Me) ->
    (Me#measurement.type == Type andalso DayFun(Me#measurement.date,DayDate)) end,
  Direct_measurements = lists:filter(FilterFun,Station#station.measurements),
  Number_of_measurements = length(Direct_measurements),
  %%FoldlFun = fun(M,Sum) -> M#measurement.value + Sum end,
  case Number_of_measurements of
    0 -> brak_danych;
    _ -> (lists:foldl(fun(X, Sum) -> X#measurement.value + Sum end,0,Direct_measurements))/Number_of_measurements
  end.


%%getDailyMean/3 - zwraca średnią wartość parametru danego typu, danego dnia na wszystkich stacjach;

getDailyMean(Monitor,Type,DayDate) ->
  Stations = maps:values(Monitor#monitor.stations),
  StationsMeans = [getStationMeanByNameWithDate(Monitor, S#station.name,Type,DayDate) || S <- Stations ],
  Filtered_means = [SM ||SM <-StationsMeans, not(is_atom(SM))],
  Number_of_means = length(Filtered_means),
  case Number_of_means of
    0 -> brak_danych;
    _ -> (lists:foldl(fun(X, Sum) -> X+ Sum end,0,Filtered_means))/Number_of_means
  end.

getMinumumPollutionStation(Monitor,Type) ->
  Stations = maps:values(Monitor#monitor.stations),
  List_of_pairs = [{S#station.name, getStationMinimumType(Monitor,S#station.name, Type)} || S <- Stations, not(is_atom(getStationMinimumType(Monitor,S#station.name, Type)))],
  Minimal_val = [getStationMinimumType(Monitor,S#station.name, Type) || S <- Stations],
  Best_station = [ S || {S,V} <- List_of_pairs, (lists:min(Minimal_val)==V) ],
  Best_station.



getStationMinimumType(Monitor,Name, Type) ->
  {_,Station} = maps:find(Name,Monitor#monitor.stations),
  FilterFun = fun (Me) ->
    (Me#measurement.type == Type ) end,
  Direct_measurements = lists:filter(FilterFun,Station#station.measurements),
  Direct_values = [M#measurement.value || M <- Direct_measurements],
  case length(Direct_measurements) of
    0 -> brak_danych;
    _ -> lists:min(Direct_values)
  end.

complexTest() ->
  M1 = pollution:createMonitor(),
  M2 = pollution:addStation(M1,"Aleja Mickiewicza",{50.2345,18.3445}),
  M3 = pollution:addStation(M2,"Aleja Norwida",{50.2345,18.3444}),
  M4 = pollution:addValue(M3,"Aleja Norwida",{{2019,4,8},{23,29,52}},"PM5",50),
  M5 = pollution:addValue(M4,"Aleja Norwida",{{2019,4,8},{22,29,52}},"PM5",100),
  M6 = pollution:removeValue(M5,"Aleja Norwida",{{2019,4,8},{22,29,52}},"PM5"),
  M7 = pollution:addValue(M6,"Aleja Norwida",{{2019,4,8},{21,29,52}},"PM5",20),
  M8 = pollution:addValue(M7,{50.2345,18.3445},{{2019,4,8},{15,00,00}},"PM5",15),
  M9 = pollution:addValue(M8,"Aleja Mickiewicza",{{2019,4,8},{16,00,00}},"PM5",30),
  M10 = pollution:addValue(M9,"Aleja Mickiewicza",{{2019,4,7},{16,00,00}},"PM5",30),
  M11 = pollution:addStation(M10,"Aleja Tuwima",{{50.2345,18.3000}}),
  M11.

dailyMeanTest(M) ->
  B = pollution:getDailyMean(M,"PM5",{2019,4,8}),
  B.

stationMeanTest(M) ->
  B = pollution:getStationMean(M,{50.2345,18.3445},"PM5"),
  B.

stationMeanTestFail(M) ->
  B = pollution:getStationMean(M,"Aleja Kochanowskiego","PM5"),
  B.

testMyFuntion(M) ->
  N = pollution:getMinumumPollutionStation(M,"PM5"),
  N.

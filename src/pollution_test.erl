%%%-------------------------------------------------------------------
%%% @author kbieniasz
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. kwi 2019 17:01
%%%-------------------------------------------------------------------
-module(pollution_test).
-author("kbieniasz").

-include_lib("eunit/include/eunit.hrl").
-compile(export_all).


-record(monitor,{map_geo_to_name,stations}).
-record (station, {name, geo_coordinates, measurements = []}).
-record (measurement, {type, value, date }).

%%simple_test() ->
 %% ?assert(true).

-export([
  get_basic_monitor2/0,
  get_basic_monitor1/0,
  getStationMean_test/0,
  getMinumumPollutionStation_test/0,
  getDailyMean_test/0

]).


get_basic_monitor2() ->
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


get_basic_monitor1() ->
  M1 = pollution:createMonitor(),
  M2 = pollution:addStation(M1,"Aleja Mickiewicza",{50.2345,18.3445}),
  M3 = pollution:addStation(M2,"Aleja Norwida",{50.2345,18.3444}),
  M4 = pollution:addValue(M3,"Aleja Norwida",{{2019,4,8},{23,29,52}},"PM5",50),
  M5 = pollution:addValue(M4,"Aleja Norwida",{{2019,4,8},{22,29,52}},"PM5",100),
  M5.


search_station_by_name_test() ->
  M1 = pollution:createMonitor(),
  M2 = pollution:addStation(M1,"Aleja Mickiewicza",{50.2345,18.3445}),
  M3 = pollution:addStation(M2,"Aleja Norwida",{50.2345,18.3444}),
  M3.

getStationMean_test () -> 75.0 = pollution:getStationMean(get_basic_monitor1(),"Aleja Norwida","PM5").

getMinumumPollutionStation_test () -> ["Aleja Mickiewicza"] = pollution:getMinumumPollutionStation(get_basic_monitor2(),"PM5").


getDailyMean_test() -> 28.75 = pollution:getDailyMean(get_basic_monitor2(),"PM5",{2019,4,8} ).

getDailyMean2_test() -> brak_danych = pollution:getDailyMean(get_basic_monitor2(),"PM5",{2019,4,9} ).





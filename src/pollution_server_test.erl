%%%-------------------------------------------------------------------
%%% @author kbieniasz
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. maj 2019 19:49
%%%-------------------------------------------------------------------
-module(pollution_server_test).
-author("kbieniasz").

%% API
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).

create_basic_monitor1() ->
  pollution_server:start(),
  pollution_server:addStation("Aleja Mickiewicza",{50.2345,18.3445}),
  pollution_server:addStation("Aleja Norwida",{50.2345,18.3444}),
  pollution_server:addValue("Aleja Norwida",{{2019,4,8},{23,29,52}},"PM5",50),
  pollution_server:addValue("Aleja Norwida",{{2019,4,8},{22,29,52}},"PM5",100).

getStationMeanHelper() ->
  create_basic_monitor1(),
  pollution_server:getStationMean("Aleja Norwida","PM5"),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  ReturnValue = pollution_server:get_response(),
  pollution_server:stop(),
  _ = pollution_server:get_response(),
  ReturnValue.

getStationMean_test () ->
  75.0 = getStationMeanHelper().


create_basic_monitor2() ->
  pollution_server:start(),
  pollution_server:addStation("Aleja Mickiewicza",{50.2345,18.3445}),
  pollution_server:addStation("Aleja Norwida",{50.2345,18.3444}),
  pollution_server:addValue("Aleja Norwida",{{2019,4,8},{23,29,52}},"PM5",50),
  pollution_server:addValue("Aleja Norwida",{{2019,4,8},{22,29,52}},"PM5",100),
  pollution_server:removeValue("Aleja Norwida",{{2019,4,8},{22,29,52}},"PM5"),
  pollution_server:addValue("Aleja Norwida",{{2019,4,8},{21,29,52}},"PM5",20),
  pollution_server:addValue({50.2345,18.3445},{{2019,4,8},{15,00,00}},"PM5",15),
  pollution_server:addValue("Aleja Mickiewicza",{{2019,4,8},{16,00,00}},"PM5",30),
  pollution_server:addValue("Aleja Mickiewicza",{{2019,4,7},{16,00,00}},"PM5",30),
  pollution_server:addStation("Aleja Tuwima",{{50.2345,18.3000}}).


getDailyMeanHelper() ->
  create_basic_monitor2(),
  pollution_server:getDailyMean("PM5",{2019,4,8} ),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  ReturnValue = pollution_server:get_response(),
  pollution_server:stop(),
  _ = pollution_server:get_response(),
  ReturnValue.


getDailyMeanHelper2() ->
  create_basic_monitor2(),
  pollution_server:getDailyMean("PM5",{2019,4,9} ),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  ReturnValue = pollution_server:get_response(),
  pollution_server:stop(),
  _ = pollution_server:get_response(),
  ReturnValue.

getMinumumPollutionStationHelper() ->
  create_basic_monitor2(),
  pollution_server:getMinumumPollutionStation("PM5"),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  _ = pollution_server:get_response(),
  ReturnValue = pollution_server:get_response(),
  pollution_server:stop(),
  _ = pollution_server:get_response(),
  ReturnValue.


getMinumumPollutionStation_test () -> ["Aleja Mickiewicza"] = getMinumumPollutionStationHelper().


getDailyMean_test() -> 28.75 = getDailyMeanHelper().

getDailyMean2_test() -> brak_danych = getDailyMeanHelper2().

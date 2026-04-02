module Util exposing (..)

import Time


formatTime : Time.Posix -> String
formatTime posix =
    let
        zone =
            Time.utc

        year =
            String.fromInt (Time.toYear zone posix)

        month =
            String.fromInt (Time.toMonth zone posix |> monthToInt)

        day =
            String.fromInt (Time.toDay zone posix)

        hour =
            String.padLeft 2 '0' (String.fromInt (Time.toHour zone posix))

        minute =
            String.padLeft 2 '0' (String.fromInt (Time.toMinute zone posix))

        seconds =
            String.padLeft 2 '0' (String.fromInt (Time.toSecond zone posix))
    in
    month ++ "/" ++ day ++ "/" ++ year ++ " " ++ hour ++ ":" ++ minute ++ ":" ++ seconds


monthToInt month =
    case month of
        Time.Jan ->
            1

        Time.Feb ->
            2

        Time.Mar ->
            3

        Time.Apr ->
            4

        Time.May ->
            5

        Time.Jun ->
            6

        Time.Jul ->
            7

        Time.Aug ->
            8

        Time.Sep ->
            9

        Time.Oct ->
            10

        Time.Nov ->
            11

        Time.Dec ->
            12

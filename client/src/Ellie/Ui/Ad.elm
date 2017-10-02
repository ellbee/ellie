module Ellie.Ui.Ad exposing (Config, view)

import Ellie.Ui.Ad.Styles as Styles
import Html exposing (Html, div)
import Native.CarbonAds


type alias Config =
    { zoneId : String
    , serve : String
    , placement : String
    }


view : Config -> Html msg
view config =
    div [ Styles.container ]
        [ Native.CarbonAds.ad
            config.zoneId
            config.serve
            config.placement
        ]

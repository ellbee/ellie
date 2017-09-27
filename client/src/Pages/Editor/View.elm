module Pages.Editor.View exposing (view)

import Data.Ellie.SaveState as SaveState
import Ellie.Ui.Toast as Toast
import Html exposing (Html, button, div, header, iframe, main_, span, text)
import Pages.Editor.Header.View as Header
import Pages.Editor.Layout.View as Layout
import Pages.Editor.Model as Model exposing (Model)
import Pages.Editor.Output.View as Output
import Pages.Editor.Routing as Routing exposing (..)
import Pages.Editor.Sidebar.View as Sidebar
import Pages.Editor.Update as Update exposing (Msg(..))
import Pages.Editor.Update.Save as UpdateSave
import RemoteData exposing (RemoteData(..))
import Views.Editors as Editors


viewElm : Model -> Html Msg
viewElm model =
    Editors.elm
        model.vimMode
        (Just ElmCodeChanged)
        model.stagedElmCode
        (Model.compileErrors model)


viewHtml : Model -> Html Msg
viewHtml model =
    Editors.html
        model.vimMode
        (Just HtmlCodeChanged)
        model.stagedHtmlCode


viewHeader : Model -> Html Msg
viewHeader model =
    Header.view
        { onSave = SaveMsg UpdateSave.Start
        , onCompile = CompileRequested
        , onFormat = FormattingRequested
        , model = model.header
        , mapMsg = HeaderMsg
        , revisionId = model.clientRevision.id
        , embedLinkButtonEnabled =
            Routing.isSpecificRevision model.currentRoute
        , saveButtonEnabled =
            Model.canSave model
        , compileButtonEnabled =
            Model.canCompile model
        , buttonsVisible =
            RemoteData.isSuccess model.serverRevision
                && model.isOnline
        , showTerms =
            model.termsShown && (model.acceptedTermsVersion == Just model.latestTermsVersion)
        , saveButtonOption =
            if SaveState.isWorking model.saveState then
                Header.Saving
            else if Model.isOwnedProject model && Model.isSavedProject model then
                Header.Update
            else if Model.isOwnedProject model && not (Model.isSavedProject model) then
                Header.Save
            else
                Header.Fork
        }


viewOutput : Model -> Html Msg
viewOutput model =
    Output.view
        { onClearElmStuff = ClearElmStuff
        , stage = model.compileStage
        }


viewSidebar : Model -> Html Msg
viewSidebar model =
    Sidebar.view
        { title = model.clientRevision.title
        , onTitleChange = TitleChanged
        , description = model.clientRevision.description
        , onDescriptionChange = DescriptionChanged
        , onClearElmStuff = ClearElmStuff
        , installed = model.clientRevision.packages
        , onPackageRemoved = RemovePackageRequested
        , onPackageAdded = PackageSelected
        , latestTerms = model.latestTermsVersion
        , mapMsg = SidebarMsg
        , model = model.sidebar
        }


viewNotifications : Model -> Html Msg
viewNotifications model =
    div [] <|
        List.map
            (\notification ->
                Toast.view
                    { notification = notification
                    , onClose = ClearNotification notification
                    }
            )
            model.notifications


view : Model -> Html Msg
view model =
    Layout.view
        { header = viewHeader model
        , sidebar = viewSidebar model
        , elm = viewElm model
        , html = viewHtml model
        , output = viewOutput model
        , notifications = viewNotifications model
        , mapMsg = LayoutMsg
        , model = model.layout
        , loading =
            RemoteData.isLoading model.serverRevision
                || RemoteData.isNotAsked model.serverRevision
        }

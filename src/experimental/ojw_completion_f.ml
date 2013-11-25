module type TParam = sig
  module Dropdown : Ojw_dropdown_f.T

  type element
  type 'a elt

  val to_dom_elt : element elt -> Dom_html.element Js.t
  val of_dom_elt : Dom_html.element Js.t -> element elt
end

module type T = sig
  include TParam

  class type completion = object
    inherit Dropdown.dropdown

    method value : Js.js_string Js.t Js.prop

    method clear : unit Js.meth
    method refresh : unit Js.meth
  end

  class type completion' = object
    inherit completion

    method _clear : (#completion Js.t, unit -> unit) Js.meth_callback Js.prop
    method _refresh : (#completion Js.t, unit -> unit) Js.meth_callback Js.prop
  end

  val completion :
     refresh : (string -> Dropdown.Traversable.item_element Dropdown.Traversable.elt list)
  -> element elt
  -> Dropdown.Traversable.element Dropdown.Traversable.elt
  -> Dropdown.element Dropdown.elt list
end

module Make(M : TParam)
  : T
    with type element = M.element
    with type Dropdown.element = M.Dropdown.element
    with type Dropdown.Traversable.element = M.Dropdown.Traversable.element
    with type Dropdown.Traversable.item_element = M.Dropdown.Traversable.item_element
    with type Dropdown.Button.element = M.Dropdown.Button.element
    with type 'a elt = 'a M.elt
    with type 'a Dropdown.elt = 'a M.Dropdown.elt
    with type 'a Dropdown.Traversable.elt = 'a M.Dropdown.Traversable.elt
    with type 'a Dropdown.Button.elt = 'a M.Dropdown.Button.elt
  = struct
  include M

  module Dd = Dropdown
  module Tr = Dd.Traversable
  module Bu = Dd.Button

  class type completion = object
    inherit Dropdown.dropdown

    method value : Js.js_string Js.t Js.prop

    method clear : unit Js.meth
    method refresh : unit Js.meth
  end

  class type completion' = object
    inherit completion

    method _clear : (#completion Js.t, unit -> unit) Js.meth_callback Js.prop
    method _refresh : (#completion Js.t, unit -> unit) Js.meth_callback Js.prop
  end

  let completion
        ~refresh
        elt elt_traversable =
    let elt' = (Js.Unsafe.coerce (to_dom_elt elt) :> completion' Js.t) in
    let meth = Js.wrap_meth_callback in

    ignore (Ojw_dropdown.dropdown
              ~focus:false
              (to_dom_elt elt)
              (Tr.to_dom_elt elt_traversable)
    );

    let is_traversable _ = Js.to_bool (Js._true) in

    elt'##_refresh <-
    meth (fun this () ->
      let container = (Tr.to_dom_elt (elt'##traversable##getContainer())) in
      List.iter
        (Dom.appendChild container)
        (List.map (Tr.to_dom_item_elt) (refresh (Js.to_string (elt'##value))))
    );

    elt'##_clear <-
    meth (fun this () ->
       elt'##value <- Js.string "";
       let container = Tr.to_dom_elt elt'##traversable##getContainer() in
       let childs = container##childNodes in
       for i=0 to childs##length; do
         Js.Opt.iter (childs##item(i))
           (Dom.removeChild container);
       done;
    );

    Lwt.async (fun () ->
      Ojw_button.pre_presses (to_dom_elt elt)
        (fun _ _ ->
           if (Js.to_string (elt'##value) = "") then
             elt'##prevent(Js._true);
           Lwt.return ()));

    Lwt.async (fun () ->
      Lwt_js_events.inputs (to_dom_elt elt)
        (fun _ _ ->
           if (Js.to_string (elt'##value) = "")
           then begin
             elt'##unpress();
             elt'##clear();
           end else begin
             elt'##press();
             elt'##refresh();
           end;
           Lwt.return ()));

    [
      M.Dropdown.of_dom_elt (to_dom_elt elt);
      M.Dropdown.of_dom_elt (M.Dropdown.Traversable.to_dom_elt elt_traversable);
    ]
end

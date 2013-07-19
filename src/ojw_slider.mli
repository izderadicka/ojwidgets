(* Copyright Université Paris Diderot. *)

(** Binding of the jQuery_ui slider for ocaml. http://api.jqueryui.com/slider/
    To use it, you must include jquery-ui.js and jquery-1.9.1.js
    @author Christophe Lecointe *)

(** Add a slider to the given element.
    @param vertical : Whether the slider is vertical or not. If it is not present, the slider will be horizontal.
    @param slide : A function called during each slide.
*)
val add_slider : ?vertical:bool -> ?slide:(unit->unit) -> Dom_html.element Js.t -> unit

(** Return the value of the slider. *)
val get_value : Dom_html.element Js.t -> int

(** Replace the callback function done on slides. *)
val on_slide : Dom_html.element Js.t -> (unit -> unit) -> 'a Lwt.t

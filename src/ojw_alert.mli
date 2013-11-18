open Dom
open Dom_html

exception Close_during_initialization

type parent = element Js.t
type container = element Js.t
type container_content = element Js.t

(** The type which reprensents an alert. *)
type t

(** [close a] closes an alert. Be aware that using this function during
  * the initialization of the alert box will raise
  * [Close_during_initialization].
  *)
val close : t -> unit

(** [closed a] returns [true] if the alert box is closed. *)
val closed : t -> bool

(** [alert ?parent ?wrap ?before ?after f] creates an alert box. The
  * content is defined using the function [f] which returns a list of
  * javascript elements.
  *
  * You can change the [parent] to which the alert box will be inserted.
  * By default, it is set to [document##body]. You can also use a specific
  * container for the alert box, using [wrap] function (default: div element).
  *
  * If you want to do some operations before inserting the alert box into the dom
  * (such as positioning your box), you can use [before] callback. There is also
  * a callback [after] which is called after insertion.
  *
  * The initialization is finished once the content of the alert box is
  * returned.
  *)
val alert :
   ?parent:element Js.t
-> ?wrap:(element Js.t list -> element Js.t)
-> ?before:(element Js.t -> unit)
-> ?after:(element Js.t -> unit)
-> (t -> element Js.t list)
-> t
